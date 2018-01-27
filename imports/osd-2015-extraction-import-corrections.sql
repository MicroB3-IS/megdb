
begin;



DELETE FROM osdregistry_stage.osd_2015_extraction
 WHERE osd_id > 200;

update osdregistry_stage.osd_2015_extraction
   SET depth = 0
   WHEre depth is null returning osd_id;


ALTER TABLE osdregistry_stage.osd_2015_extraction
  ADD PRIMARY KEY (osd_id, depth);


commit;