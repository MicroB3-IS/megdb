
BEGIN;

GRANT EXECUTE ON FUNCTION _v.register_patch(text, text[], text[]) TO GROUP megdb_admin;
GRANT EXECUTE ON FUNCTION _v.register_patch(text, text[]) TO GROUP megdb_admin;
GRANT EXECUTE ON FUNCTION _v.register_patch(text) TO GROUP megdb_admin;
GRANT EXECUTE ON FUNCTION _v.unregister_patch(text) TO GROUP megdb_admin;
GRANT ALL ON TABLE _v.patches TO GROUP megdb_admin;

SELECT _v.register_patch( '7-author_article_journal_web_views', ARRAY['6-drop-sequence-storage-legacy'], NULL );


-- Table: core.journals

DROP TABLE core.authorlists;
DROP TABLE IF EXISTS core.articles;
DROP TABLE IF EXISTS core.journals;




CREATE TABLE core.journals
(
  title text PRIMARY KEY check(length(title) > 2), -- name of journal
  publisher text NOT NULL DEFAULT ''::text, -- publisher of the journal
  iso_abbr text NOT NULL DEFAULT ''::text, -- Abbreveation of journals established by ISO Standard
  med_abbr text NOT NULL DEFAULT ''::text,
  homepage core.url, -- Homepage of journal
  pissn text NOT NULL DEFAULT ''::text, -- ISSN of journals print version
  eissn text NOT NULL DEFAULT ''::text, -- ISSN of journals electronic version
  country text NOT NULL DEFAULT ''::text, -- Home country of journal
  pubstart text NOT NULL DEFAULT ''::text, -- date the journal startet to publish
  lang text NOT NULL DEFAULT ''::text, -- Language of journal
  nlmid text NOT NULL DEFAULT ''::text, -- National Library of Medicine Identifier
  created timestamp with time zone NOT NULL DEFAULT now(),
  created_by text NOT NULL DEFAULT '',
  updated timestamp with time zone NOT NULL DEFAULT now(),
  updated_by text NOT NULL DEFAULT ''
  )
WITH (
  OIDS=FALSE
);

CREATE UNIQUE INDEX lower_title_key ON core.journals (lower(title));

CREATE UNIQUE INDEX iso_abbr_unique_constraint
  ON core.journals
  USING btree
  (iso_abbr COLLATE pg_catalog."default" )
  WHERE NOT iso_abbr = ''::text;

CREATE UNIQUE INDEX journals_eissn_key
  ON core.journals
  USING btree
  (eissn)
  WHERE NOT eissn = ''::text;

CREATE UNIQUE INDEX journals_med_abbr_key
  ON core.journals
  USING btree
  (med_abbr )
  WHERE NOT med_abbr  = ''::text;
  
CREATE UNIQUE INDEX journals_nlmid_key 
  ON core.journals
  USING btree
  (nlmid)
  WHERE NOT nlmid  = ''::text;
  
CREATE UNIQUE INDEX journals_pissn_key 
  ON core.journals
  USING btree
  (pissn)
  WHERE NOT pissn = ''::text;


ALTER TABLE core.journals
  OWNER TO megdb_admin;
GRANT ALL ON TABLE core.journals TO megdb_admin;

COMMENT ON TABLE core.journals
  IS 'The journals articles are published. Most attributes are taken from www.pubmed.com entries';
COMMENT ON COLUMN core.journals.title IS 'name of journal';
COMMENT ON COLUMN core.journals.publisher IS 'publisher of the journal';
COMMENT ON COLUMN core.journals.iso_abbr IS 'Abbreveation of journals established by ISO Standard';
COMMENT ON COLUMN core.journals.homepage IS 'Homepage of journal';
COMMENT ON COLUMN core.journals.pissn IS 'ISSN of journals print version';
COMMENT ON COLUMN core.journals.eissn IS 'ISSN of journals electronic version';
COMMENT ON COLUMN core.journals.country IS 'Home country of journal';
COMMENT ON COLUMN core.journals.pubstart IS 'date the journal startet to publish';
COMMENT ON COLUMN core.journals.lang IS 'Language of journal';
COMMENT ON COLUMN core.journals.nlmid IS 'National Library of Medicine Identifier';





-- Table: core.articles


CREATE TABLE core.articles
(
  id text NOT NULL DEFAULT ''::text,
  id_code text NOT NULL,
  title text NOT NULL DEFAULT ''::text, -- Title of article
  pubstatus text NOT NULL DEFAULT ''::text, -- status of publication
  linkout core.http, -- The url of the fulltext as given bu NCBI LinkOut database
  journal text, -- The journal this article is published
  issue text NOT NULL DEFAULT ''::text, -- Issue of journal
  volume text NOT NULL DEFAULT ''::text, -- Volume of journal
  yr text NOT NULL DEFAULT ''::text, -- Year of publication
  mon text NOT NULL DEFAULT ''::text, -- Month of publication
  firstpage text NOT NULL DEFAULT ''::text, -- First page number
  lastpage text NOT NULL DEFAULT ''::text, -- Last page number
  abstract text NOT NULL DEFAULT ''::text, -- Abstract of article
  published boolean NOT NULL DEFAULT false, -- Whether article is officially published
  pdf core.http, -- name of the pdf document containing the article
  html_abstract core.http, -- html version of the articles abstract
  html_fulltext core.http, -- html version of the full article
  created timestamp with time zone NOT NULL DEFAULT now(),
  created_by text NOT NULL DEFAULT '',
  updated timestamp with time zone NOT NULL DEFAULT now(),
  updated_by text NOT NULL DEFAULT '',
  CONSTRAINT articles_pkey PRIMARY KEY (id , id_code ),
  CONSTRAINT articles_id_code_fkey FOREIGN KEY (id_code)
      REFERENCES core.id_codes (code) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE NO ACTION,
  CONSTRAINT articles_journalid_fkey FOREIGN KEY (journal)
      REFERENCES core.journals (title) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE RESTRICT
)
WITH (
  OIDS=FALSE
);
ALTER TABLE core.articles
  OWNER TO rkottman;
GRANT ALL ON TABLE core.articles TO rkottman;
GRANT SELECT ON TABLE core.articles TO selectors;
COMMENT ON TABLE core.articles
  IS 'Scientific publications. Most attributes are taken from www.pubmed.com entries';
COMMENT ON COLUMN core.articles.title IS 'Title of article';
COMMENT ON COLUMN core.articles.pubstatus IS 'status of publication';
COMMENT ON COLUMN core.articles.linkout IS 'The url of the fulltext as given bu NCBI LinkOut database';
COMMENT ON COLUMN core.articles.journal IS 'The journal publishing this article';
COMMENT ON COLUMN core.articles.issue IS 'Issue of journal';
COMMENT ON COLUMN core.articles.volume IS 'Volume of journal';
COMMENT ON COLUMN core.articles.yr IS 'Year of publication';
COMMENT ON COLUMN core.articles.mon IS 'Month of publication';
COMMENT ON COLUMN core.articles.firstpage IS 'First page number';
COMMENT ON COLUMN core.articles.lastpage IS 'Last page number';
COMMENT ON COLUMN core.articles.abstract IS 'Abstract of article';
COMMENT ON COLUMN core.articles.published IS 'Whether article is officially published';
COMMENT ON COLUMN core.articles.pdf IS 'name of the pdf document containing the article';
COMMENT ON COLUMN core.articles.html_abstract IS 'html version of the articles abstract';
COMMENT ON COLUMN core.articles.html_fulltext IS 'html version of the full article';



CREATE TABLE core.authorlists
(
  article_id text NOT NULL, -- article identifier
  article_id_code text NOT NULL,
  first_name text NOT NULL, -- first name of the author
  initials text NOT NULL, -- initials of the author
  last_name text NOT NULL, -- last name of the author
  sex core.gender NOT NULL, -- ISO gender code for sex. 0=unknown; 1=male; 2=female; 9=not applicable
  pos smallint NOT NULL, -- The position of the author in an article. Zero if not known
  corres boolean NOT NULL DEFAULT false, -- correspondence information
  CONSTRAINT authorlists_pkey PRIMARY KEY (article_id , article_id_code , first_name , initials , last_name , sex , pos ),
  CONSTRAINT authorlists_article_id_fkey FOREIGN KEY (article_id, article_id_code)
      REFERENCES core.articles (id, id_code) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT authorlists_first_name_fkey FOREIGN KEY (first_name, initials, last_name, sex)
      REFERENCES core.authors (first_name, initials, last_name, sex) MATCH SIMPLE
      ON UPDATE CASCADE
)
WITH (
  OIDS=FALSE
);
ALTER TABLE core.authorlists
  OWNER TO rkottman;
GRANT ALL ON TABLE core.authorlists TO rkottman;
GRANT SELECT ON TABLE core.authorlists TO selectors;
COMMENT ON TABLE core.authorlists
  IS 'Ordered list of authors for each article';
COMMENT ON COLUMN core.authorlists.article_id IS 'article identifier';
COMMENT ON COLUMN core.authorlists.first_name IS 'first name of the author';
COMMENT ON COLUMN core.authorlists.initials IS 'initials of the author';
COMMENT ON COLUMN core.authorlists.last_name IS 'last name of the author';
COMMENT ON COLUMN core.authorlists.sex IS 'ISO gender code for sex. 0=unknown; 1=male; 2=female; 9=not applicable';
COMMENT ON COLUMN core.authorlists.pos IS 'The position of the author in an article. Zero if not known';
COMMENT ON COLUMN core.authorlists.corres IS 'correspondence information';


commit;