

\copy (Select DISTINCT ON (label) 'OSD_' || label AS center_name FROM osdregistry.institute_sites ) TO '/home/renzo/src/megdb/osd_center_names_2014.csv' HEADER CSV DELIMITER ';'