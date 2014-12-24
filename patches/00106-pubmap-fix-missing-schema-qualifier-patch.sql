
BEGIN;
SELECT _v.register_patch('00106-pubmap-fix-missing-schema-qualifier',
                          array['00105-pubmap-n-places'] );

-- section of creation best as user role megdb_admin
SET ROLE megdb_admin;


CREATE OR REPLACE FUNCTION pubmap.mergePubMedArticle(article pubmap.raw_pubmap) 
   RETURNS pubmap.raw_pubmap AS $$
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

      -- now if both already existed, we do not need to insert into article_places
      IF (article_exists AND place_exists) THEN 
         RAISE DEBUG 'nothing to do';
      ELSE
         INSERT INTO pubmap.article_places (article_id, place_id) 
         VALUES (article_id, place_id);
      END IF;
   RETURN article;
   END;
$$ LANGUAGE plpgsql SECURITY DEFINER; 

GRANT execute ON FUNCTION pubmap.mergePubMedArticle(article pubmap.raw_pubmap) TO megxuser;


-- for some test queries as user megxuser
-- SET ROLE megxuser;


commit;


