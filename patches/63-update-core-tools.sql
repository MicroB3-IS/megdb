Begin;

SELECT _v.register_patch('63-update-core-tools',
                          array['62-mg-traits-jobs-fix-environment-columns'] );

ALTER TABLE core.tools OWNER TO megdb_admin;
ALTER TABLE core.tool_versions OWNER TO megdb_admin;

INSERT INTO core.tools (label,descr) 
    VALUES 
('blast+', 'Basic Local Alignment Search Tool');

INSERT INTO core.tool_versions (label,ver) 
    VALUES 
('blast+', '2.2.28');


commit;
