
BEGIN;

SELECT _v.register_patch( '9-improve-article-table', ARRAY['8-authdb','7-author_article_journal_web_views'], NULL );

set client_encoding = 'UTF8';

ALTER TABLE core.articles RENAME pdf  TO pdf_url;
COMMENT ON COLUMN core.articles.pdf_url IS 'URL of the articels pdf document';

ALTER TABLE core.articles RENAME html_abstract  TO abstract_html_url;

ALTER TABLE core.articles RENAME html_fulltext  TO fulltext_url;

COMMENT ON COLUMN core.articles.fulltext_url IS 'URL to html version of the full article';

ALTER TABLE core.articles RENAME created  TO ctime;
COMMENT ON COLUMN core.articles.ctime IS 'time of record creation';

ALTER TABLE core.articles RENAME updated  TO utime;
COMMENT ON COLUMN core.articles.utime IS 'time of last update of this record';

ALTER TABLE core.articles
   ALTER COLUMN journal SET DEFAULT '';

ALTER TABLE core.articles
   ALTER COLUMN journal SET NOT NULL;

ALTER TABLE core.articles ADD COLUMN fulltext_html text NOT NULL DEFAULT '';

ALTER TABLE core.articles OWNER TO megdb_admin;

ALTER TABLE core.articles DROP CONSTRAINT articles_journalid_fkey;

ALTER TABLE core.articles ADD CONSTRAINT articles_journalid_fkey FOREIGN KEY (journal)
      REFERENCES core.journals (title) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE RESTRICT;

commit;