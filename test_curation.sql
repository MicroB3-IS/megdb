
begin;

DROP TABLE IF EXISTS sites_curation_ctx;
DROP TABLE IF EXISTS sites;

DROP FUNCTION site_curation_i_trg();
DROP FUNCTION IF EXISTS site_curation_u_trg();

-- here the constraint just have to be on which data is accetable for curation!

-- so PK and uniques are on the original (verbatim fields)
-- as such overall already NOT NULL and first uniqness are tested 

CREATE TABLE sites_curation_ctx (
  lat text,
  lat_verb text,
  lon text,
  lon_verb text,
  PRIMARY KEY(lat_verb,lon_verb) 
);

CREATE TABLE sites (

  lat double precision check (lat between 0 and 90),
  lat_verb text,
  lon double precision,
  lon_verb text,
  UNIQUE (lat,lon)
);

-- inserts only on curation ctx but make avail for target ctx (final) 

CREATE OR REPLACE FUNCTION site_curation_i_trg()
  RETURNS trigger AS
$BODY$
BEGIN

    INSERT INTO sites (lat_verb, lon_verb) VALUES (NEW.lat_verb, NEW.lon_verb);
 
RETURN NEW;
END;
$BODY$	
LANGUAGE plpgsql
;

CREATE TRIGGER site_curation_insert
  AFTER insert
  ON sites_curation_ctx
  FOR EACH ROW
  EXECUTE PROCEDURE site_curation_i_trg();

CREATE OR REPLACE FUNCTION site_curation_u_trg()
  RETURNS trigger AS
$BODY$
BEGIN

    UPDATE sites 
       SET lat = NEW.lat_verb::double precision, lon = NEW.lon_verb::double precision 
     WHERE lat_verb=OLD.lat_verb 
       AND lon_verb = OLD.lon_verb;

       NEW.lat :=  NEW.lat_verb;
       NEW.lon := NEW.lon_verb;
 
RETURN NEW;
END;
$BODY$	
LANGUAGE plpgsql
;

CREATE TRIGGER site_curation_update
  BEFORE update
  ON sites_curation_ctx
  FOR EACH ROW
  EXECUTE PROCEDURE site_curation_u_trg();


-- now testing

-- initially correct
insert into  sites_curation_ctx (lat_verb, lon_verb) VALUES ('0','0');

-- initially wrong

insert into  sites_curation_ctx (lat_verb, lon_verb) VALUES ('111.5.5.3','7 deg 5 m');




commit;

