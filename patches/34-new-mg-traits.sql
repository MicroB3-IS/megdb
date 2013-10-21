-- DO NOT APPLY THIS PATCH YET


BEGIN;

GRANT USAGE ON SCHEMA _v TO GROUP megdb_admin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION _v.register_patch(text) TO GROUP megdb_admin;
GRANT EXECUTE ON FUNCTION _v.register_patch(text, text[]) TO GROUP megdb_admin;
GRANT EXECUTE ON FUNCTION _v.register_patch(text, text[], text[]) TO GROUP megdb_admin;
GRANT EXECUTE ON FUNCTION _v.unregister_patch(text) TO GROUP megdb_admin;


SELECT _v.register_patch('34-new-mg-traits', 
                          array['8-authdb','31-mg-traits', '34-rewire-queues' ] );


ALTER SCHEMA mg_traits OWNER TO megdb_admin;
ALTER TABLE mg_traits.mg_traits_jobs OWNER TO megdb_admin;
ALTER TABLE mg_traits.mg_traits_results OWNER TO megdb_admin;


-- set role only for this tranaction
SET LOCAL ROLE megdb_admin;


GRANT USAGE ON SCHEMA mg_traits TO GROUP selectors;
ALTER DEFAULT PRIVILEGES IN SCHEMA mg_traits
    GRANT SELECT ON TABLES
    TO selectors;

SET search_path to mg_traits,core;


ALTER TABLE mg_traits.mg_traits_jobs ADD COLUMN make_public interval NOT NULL DEFAULT '0 day';
ALTER TABLE mg_traits.mg_traits_jobs ADD COLUMN keep_data interval NOT NULL DEFAULT '1 week';

CREATE TABLE mg_traits_aa (
    sample_label text NOT NULL,
    ala numeric DEFAULT 'NaN'::numeric NOT NULL,
    cys numeric DEFAULT 'NaN'::numeric NOT NULL,
    asp numeric DEFAULT 'NaN'::numeric NOT NULL,
    glu numeric DEFAULT 'NaN'::numeric NOT NULL,
    phe numeric DEFAULT 'NaN'::numeric NOT NULL,
    gly numeric DEFAULT 'NaN'::numeric NOT NULL,
    his numeric DEFAULT 'NaN'::numeric NOT NULL,
    ile numeric DEFAULT 'NaN'::numeric NOT NULL,
    lys numeric DEFAULT 'NaN'::numeric NOT NULL,
    leu numeric DEFAULT 'NaN'::numeric NOT NULL,
    met numeric DEFAULT 'NaN'::numeric NOT NULL,
    asn numeric DEFAULT 'NaN'::numeric NOT NULL,
    pro numeric DEFAULT 'NaN'::numeric NOT NULL,
    gln numeric DEFAULT 'NaN'::numeric NOT NULL,
    arg numeric DEFAULT 'NaN'::numeric NOT NULL,
    ser numeric DEFAULT 'NaN'::numeric NOT NULL,
    thr numeric DEFAULT 'NaN'::numeric NOT NULL,
    val numeric DEFAULT 'NaN'::numeric NOT NULL,
    trp numeric DEFAULT 'NaN'::numeric NOT NULL,
    tyr numeric DEFAULT 'NaN'::numeric NOT NULL
);


CREATE TABLE mg_traits_dinuc (
    sample_label text NOT NULL,
    paa_ptt numeric DEFAULT 'NaN'::numeric NOT NULL,
    pac_pgt numeric DEFAULT 'NaN'::numeric NOT NULL,
    pcc_pgg numeric DEFAULT 'NaN'::numeric NOT NULL,
    pca_ptg numeric DEFAULT 'NaN'::numeric NOT NULL,
    pga_ptc numeric DEFAULT 'NaN'::numeric NOT NULL,
    pag_pct numeric DEFAULT 'NaN'::numeric NOT NULL,
    pat numeric DEFAULT 'NaN'::numeric NOT NULL,
    pcg numeric DEFAULT 'NaN'::numeric NOT NULL,
    pgc numeric DEFAULT 'NaN'::numeric NOT NULL,
    pta numeric DEFAULT 'NaN'::numeric NOT NULL
);

CREATE TABLE mg_traits_pfam (
    sample_label text NOT NULL,
    pfam text[]
);

ALTER TABLE mg_traits.mg_traits_results ADD COLUMN num_genes numeric DEFAULT 'NaN'::numeric NOT NULL;

ALTER TABLE mg_traits.mg_traits_results ADD COLUMN total_mb numeric DEFAULT 'NaN'::numeric NOT NULL;

ALTER TABLE mg_traits.mg_traits_results ADD COLUMN num_reads numeric DEFAULT 'NaN'::numeric NOT NULL;

ALTER TABLE mg_traits.mg_traits_results ADD COLUMN ab_ratio numeric DEFAULT 'NaN'::numeric NOT NULL;

ALTER TABLE mg_traits.mg_traits_results ADD COLUMN perc_tf numeric DEFAULT 'NaN'::numeric NOT NULL;

ALTER TABLE mg_traits.mg_traits_results ADD COLUMN perc_classified numeric DEFAULT 'NaN'::numeric NOT NULL;


ALTER TABLE ONLY mg_traits_aa
    ADD CONSTRAINT mg_traits_aa_pkey PRIMARY KEY (sample_label);


ALTER TABLE ONLY mg_traits_dinuc
    ADD CONSTRAINT mg_traits_dinuc_pkey PRIMARY KEY (sample_label);


ALTER TABLE ONLY mg_traits_pfam
    ADD CONSTRAINT mg_traits_pfam_pkey PRIMARY KEY (sample_label);


ALTER TABLE ONLY mg_traits_aa
    ADD CONSTRAINT mg_traits_aa_sample_label_fkey FOREIGN KEY (sample_label) REFERENCES mg_traits_jobs(sample_label);


ALTER TABLE ONLY mg_traits_dinuc
    ADD CONSTRAINT mg_traits_dinuc_sample_label_fkey FOREIGN KEY (sample_label) REFERENCES mg_traits_jobs(sample_label);


ALTER TABLE ONLY mg_traits_pfam
    ADD CONSTRAINT mg_traits_pfam_sample_label_fkey FOREIGN KEY (sample_label) REFERENCES mg_traits_jobs(sample_label);


commit;





