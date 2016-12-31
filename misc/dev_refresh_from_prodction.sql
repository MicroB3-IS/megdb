
/* 
 * Having some foreign data table conencting from production, we can
 * refresh some dev DB data from production DB.
 */

BEGIN;

DELETE FROM esa.samples;

INSERT INTO esa.samples 
   SELECT * 
     FROM prod_stage.esa_samples;



commit;