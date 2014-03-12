Begin;

SELECT _v.register_patch('61-core-biodb-table',
                          array['60-mg-traits-pk-pca-table.sql'] );

--table for biodb
CREATE TABLE core.biodb (
label text NOT NULL, -- name of the biodb
cat text NOT NULL DEFAULT ''::text, -- The main category this biodb belongs
remark text NOT NULL DEFAULT ''::text, -- A remark on this entry
descr text NOT NULL DEFAULT ''::text, -- description of the biodb
ctime timestamp with time zone NOT NULL DEFAULT now(),
mtime timestamp with time zone NOT NULL DEFAULT now(),
PRIMARY KEY (label)
);
ALTER TABLE core.biodb OWNER TO megdb_admin;
GRANT ALL ON TABLE core.biodb TO megdb_admin;
GRANT SELECT ON TABLE core.biodb TO selectors;
GRANT SELECT ON TABLE core.biodb TO megxuser;
GRANT SELECT, INSERT ON TABLE core.biodb TO sge;
COMMENT ON TABLE core.biodb IS 'List of name databases as distributed in the cluster.';
INSERT INTO core.biodb (label,descr) VALUES 
('pfam','database of protein families');

INSERT INTO core.biodb (label,cat,descr) 
    VALUES 
('unknowns', 'blast', 'Based on unknown networks by Fernandez-Guerra et al.'), 
('prok_genomes', 'blast', 'Blast DB of archaeal and bacterial proteins'), 
('gos', 'blast', 'Blast DB of all Global Ocean Survey (GOS) reads '), 
('marine_phages', 'blast', 'Blast DB of marine phage proteins'), 
('silva_lsu', 'blast', 'Blast DB of all SILVA Long Subunit (lsu) rDNAs'),
('silva_ssu', 'blast', 'Blast DB of all SILVA Small Subunit (ssu) rDNAs'); 

--table for biodb versions
CREATE TABLE core.biodb_version (
label text NOT NULL,
ver text NOT NULL,
descr text NOT NULL DEFAULT ''::text, -- description of the biodb
PRIMARY KEY (label, ver),
FOREIGN KEY (label)
   REFERENCES core.biodb (label)
   ON UPDATE CASCADE ON DELETE NO ACTION
);
ALTER TABLE core.biodb_version OWNER TO megdb_admin;
GRANT ALL ON TABLE core.biodb_version TO megdb_admin;
GRANT SELECT ON TABLE core.biodb_version TO selectors;
GRANT SELECT ON TABLE core.biodb_version TO megxuser;
GRANT SELECT, INSERT ON TABLE core.biodb_version TO sge;
COMMENT ON TABLE core.biodb_version IS 'List of versions for databases distributed in the cluster.';

INSERT INTO core.biodb_version (label, ver) VALUES ('pfam', '26.0'), ('prok_genomes','r8'), ('gos', 'r8'), ('marine_phages','r8'), ('silva_lsu','r8'), ('silva_ssu','r8'); 
INSERT INTO core.biodb_version (label, ver, descr) VALUES ('unknowns', '24-02-2014_aa', 'UnknownDB built using PFAM 26.0 and HMMER3 against GOS.');

-- select * from core.biodb;
-- select * from core.biodb_version;

commit;
