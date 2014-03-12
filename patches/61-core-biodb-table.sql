Begin;
SELECT _v.register_patch('61-core-biodb-table',
                          array['60-mg-traits-pk-pca-table'] );

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
INSERT INTO core.biodb (label) VALUES ('pfam'), ('unknowns'), ('genomes'), ('gos'), ('marine_phages'), ('silva_lsu'), ('silva_ssu'); 

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
INSERT INTO core.biodb (label, ver) VALUES ('pfam', '26.0'), ('genomes','r8'), ('gos'), ('marine_phages','r8'), ('silva_lsu','r8'), ('silva_ssu'.'r8'); 
INSERT INTO core.biodb (label, ver, descr)('unknowns', '24-02-2014_aa', 'UnknownDB built using PFAM 26.0 and HMMER3 against GOS.');
rollback;
--commit;
