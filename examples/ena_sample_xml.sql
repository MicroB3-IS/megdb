    
SELECT xmlelement(name "SAMPLE_SET", t.s)  FROM (select xmlagg( sample order by osd_id DESC) as s  from osdregistry.ena_m2b3_sample_xml) as t(s);


\a
\t
\copy (SELECT xmlelement(name "SAMPLE_SET", t.s::xml) FROM (select xmlagg( sample order by osd_id DESC)::xml as s from osdregistry.ena_m2b3_sample_xml) as t(s)) TO '/home/renzo/src/osd-submissions/2014/sample-dirty.xml' 
