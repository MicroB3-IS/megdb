
BEGIN;
SELECT _v.register_patch('00105-pubmap-n-places',
                          array['00104-better-citizien-list'] );

-- section of creation best as user role megdb_admin

SET ROLE megdb_admin;
set search_path to pubmap,public;


DROP TABLE pubmap.raw_pubmap;

CREATE TABLE pubmap.articles (
  id BIGSERIAL PRIMARY KEY,
  pmid integer UNIQUE,
  pubmed_xml xml DEFAULT '<e/>'::xml,
  user_name text NOT NULL DEFAULT 'anonymous',
  raw json NOT NULL DEFAULT '{}',
  created timestamp with time zone NOT NULL DEFAULT now(),
  modified timestamp with time zone NOT NULL DEFAULT now()
);

ALTER TABLE pubmap.articles
  OWNER TO megdb_admin;


CREATE TABLE pubmap.places ( 
  id BIGSERIAL,
  geog geography(POINT,4326) NOT NULL,
  world_region text NOT NULL DEFAULT ''::text,
  place_name text NOT NULL DEFAULT ''::text,
  user_name text NOT NULL DEFAULT 'anonymous',
  created timestamp with time zone NOT NULL DEFAULT now(),
  modified timestamp with time zone NOT NULL DEFAULT now(),

  georef_geodetic_datum text NOT NULL DEFAULT 'not recorded',
  max_uncertain numeric NOT NULL DEFAULT 'NaN'::numeric, 

  coords_verb text NOT NULL DEFAULT ''::text, 
  coord_sys_verb text NOT NULL DEFAULT ''::text, 
  georef_verification text NOT NULL DEFAULT ''::text, 
  georef_validation text NOT NULL DEFAULT ''::text, 
  georef_protocol text NOT NULL DEFAULT ''::text, 
  georef_source text NOT NULL DEFAULT ''::text,
  spatial_fit numeric NOT NULL DEFAULT 'nan',
  georef_by text NOT NULL DEFAULT 'anonymous', 
  georef_created timestamp with time zone NOT NULL DEFAULT now(), 
  georef_modified timestamp with time zone NOT NULL DEFAULT now(), 
  georef_remark text NOT NULL DEFAULT ''::text, 
  place_name_verb text,

  PRIMARY KEY (id),
  UNIQUE (geog,max_uncertain)
);

COMMENT ON TABLE pubmap.places
  IS 'A place on earth; Table conforms to OpenGIS Simple Features Specification for SQL. Enables georeferencing acording to BioGeomancer Guide (see GeoReferencing and http://www2.gbif.org/BioGeomancerGuide.pdf';

COMMENT ON COLUMN pubmap.places.max_uncertain IS 'The upper limit of the distance IN METER from the given latitude and longitude describing a circle within which the whole of the described locality must lie';
COMMENT ON COLUMN pubmap.places.coords_verb IS 'The original (verbatim) coordinates of the raw data before any transformations were carried out';
COMMENT ON COLUMN pubmap.places.coord_sys_verb IS 'The coordinate system in which the raw data were recorded. If data are being entered into the database in Decimal Degrees. For example the geographic coordinates of the map or gazetteer used should be entered (e.g. decimal degrees degrees-minutes-seconds degrees-decimal minutes UTM coordinates)';
COMMENT ON COLUMN pubmap.places.georef_verification IS 'A categorical description of the extent to which the georeference and uncertainty have been verified to represent the location and uncertainty for where the specimen or observation was collected. See table cv.verification_codes';
COMMENT ON COLUMN pubmap.places.georef_validation IS 'Shows what validation procedures have been conducted on the georeferences for example various outlier detection procedures revisits to the location etc. Relates to Verification Status. NOt sure if useful for MegDb';
COMMENT ON COLUMN pubmap.places.georef_protocol IS 'A reference to the method(s) used for determining the coordinates and uncertainty estimates (e.g. MaNIS Georeferencing Calculator).';
COMMENT ON COLUMN pubmap.places.georef_source IS 'A measure of how well the geometric representation matches the original spatial representation and is reported as the ratio of the area of the presented geometry to the area of the original spatial representation. A value of 1 is an exact match or 100% overlap. This is a new concept for use with biodiversity data but one that we are recommending here';
COMMENT ON COLUMN pubmap.places.georef_by IS 'The person or organization making the coordinate and uncertainty determination';
COMMENT ON COLUMN pubmap.places.georef_created IS 'The time on which the determination was made';
COMMENT ON COLUMN pubmap.places.georef_created IS 'The time on which the determination was last modified';
COMMENT ON COLUMN pubmap.places.georef_remark IS 'Comments on methods and assumptions used in determining coordinates or uncertainties when those methods or assumptions differ from or expand upon the methods referenced in the Georeference Protocol field';

SELECT AddGeometryColumn(
  'pubmap',
  'places',
  'geom',
   4326,
  'POINT',
  2
);

ALTER TABLE pubmap.places ALTER geom SET NOT NULL;
ALTER TABLE pubmap.places ADD UNIQUE(geom,max_uncertain);


CREATE FUNCTION i_place_trg() RETURNS trigger AS $i$
   BEGIN
     
     NEW.geog = NEW.geom::geography;     
       
     RETURN NEW;
   END;
$i$ LANGUAGE plpgsql;

CREATE TRIGGER i_place 
   BEFORE INSERT OR UPDATE ON pubmap.places
       FOR EACH ROW EXECUTE PROCEDURE i_place_trg();





CREATE TABLE pubmap.article_places (
  article_id bigint REFERENCES articles (id),
  place_id bigint REFERENCES places (id),
  PRIMARY KEY (article_id, place_id)
);



-- Table: pubmap.raw_pubmap

-- DROP TABLE pubmap.raw_pubmap;

CREATE VIEW pubmap.raw_pubmap AS 
   SELECT
      a.pmid,
      p.geom,
      a.pubmed_xml as article_xml,
      a.user_name,
      a.raw as megxbar,
      a.created,
      p.world_region,
      p.place_name as place
    FROM articles a 
    INNER JOIN article_places ap ON (a.id = ap.article_id)
    INNER JOIN places p ON (ap.place_id = p.id);

ALTER TABLE pubmap.raw_pubmap 
   ALTER article_xml SET DEFAULT '<e/>';

ALTER TABLE pubmap.raw_pubmap 
   ALTER user_name SET DEFAULT 'anonymous';


ALTER TABLE pubmap.raw_pubmap 
   ALTER world_region SET DEFAULT '';


ALTER TABLE pubmap.raw_pubmap 
   ALTER place SET DEFAULT '';

ALTER TABLE pubmap.raw_pubmap
  OWNER TO megdb_admin;

REVOKE ALL ON TABLE pubmap.raw_pubmap FROM PUBLIC;

GRANT ALL ON TABLE pubmap.raw_pubmap TO megdb_admin;
GRANT SELECT, INSERT ON TABLE pubmap.raw_pubmap TO megxuser;



CREATE OR REPLACE FUNCTION pubmap.mergePubMedArticle(article raw_pubmap) 
   RETURNS raw_pubmap AS $$
   DECLARE 
      article_exists boolean;
      place_exists boolean;
      article_id bigint;
      place_id bigint;
   BEGIN
      IF article.pmid IS NULL THEN
         RAISE EXCEPTION 'PubMed ID (pmid) cannot be null';
      END IF;
 
      -- chekcing for article
      SELECT id INTO article_id 
        FROM pubmap.articles 
       WHERE pmid = article.pmid;

      article_exists := FOUND;

      -- checking for place
      SELECT id INTO place_id 
        FROM pubmap.places 
       WHERE geom = article.geom;      
      place_exists := FOUND;

      IF article_exists THEN
         RAISE DEBUG 'article with pmid=% found=%', article.pmid, article_exists;
         UPDATE pubmap.articles 
            SET (pmid, pubmed_xml, user_name, raw) 
              = (article.pmid, article.article_xml,article.user_name, article.megxbar)
         WHERE id = article_id;

      ELSE
         INSERT into pubmap.articles 
           (pmid, pubmed_xml, raw, user_name) 
           VALUES
           (article.pmid, article.article_xml,article.megxbar,article.user_name) 
         RETURNING id INTO STRICT article_id;
      END IF;

      IF place_exists THEN
         RAISE DEBUG 'place with geom=% found=%', article.geom, place_exists;
         UPDATE pubmap.places 
            SET (geom,geog,world_region, place_name) 
              = (article.geom, article.geom::geography,article.world_region, article.place) 
          WHERE id = place_id;

      ELSE
         INSERT into places 
           (geog,geom) 
           VALUES
           (article.geom::geography,article.geom) 
         RETURNING id INTO STRICT place_id;
      END IF;

      -- now if both already existed, we do not need to insert into artilce_places
      IF (article_exists AND place_exists) THEN 
         RAISE DEBUG 'nothing to do';
      ELSE
         INSERT INTO pubmap.article_places (article_id, place_id) 
         VALUES (article_id, place_id);
      END IF;
   RETURN article;
   END;
$$ LANGUAGE plpgsql SECURITY DEFINER; 

GRANT execute ON FUNCTION pubmap.mergePubMedArticle(article raw_pubmap) TO megxuser;

CREATE FUNCTION i_article_trg() RETURNS trigger AS $i$
   BEGIN
     IF NEW.pmid IS NOT NULL THEN
       PERFORM pubmap.mergePubMedArticle(NEW);
     ELSE
        RAISE EXCEPTION 'PubMed Id (=pmid) can not be null';    
     END IF;
       
     RETURN NEW;
   END;
$i$ LANGUAGE plpgsql;

CREATE TRIGGER i_article 
   INSTEAD OF INSERT ON raw_pubmap
       FOR EACH ROW EXECUTE PROCEDURE i_article_trg();

-- testing

/*
INSERT into pubmap.articles(pmid,user_name) values (1,'test_user') returning id; 

INSERT into pubmap.places
  (geog,geom) 
  values 
   ( ST_GeogFromText('SRID=4326;POINT(' || '0' || ' ' || '0' || ')'),
ST_GeomFromEWKT('SRID=4326;POINT(' || '0' || ' ' || '0' || ')')
  ); 

SET role megxuser;

-- should work as first
INSERT into pubmap.raw_pubmap
  (pmid, geom, megxbar) 
  values 
   (
   2,
   ST_GeomFromEWKT('SRID=4326;POINT(' || '2' || ' ' || '0' || ')'),
'{"megxbar":"test"}'
  ); 

-- shoudl result in update

INSERT into pubmap.raw_pubmap
  (pmid, geom, megxbar) 
  values 
   (
   2,
   ST_GeomFromEWKT('SRID=4326;POINT(' || '0' || ' ' || '0' || ')'),
   '{"megxbar":"test"}'
  ); 
--*/

set role megdb_admin;

select * from pubmap.articles;
select * from pubmap.places;
select * from pubmap.article_places;

set role megxuser;
select * from pubmap.raw_pubmap;



commit;


