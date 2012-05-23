#!/usr/bin/sh

SRC_DB_PORT=5491
SRC_DB_NAME=megdb_r8
SCHEMA_LIST="-n core -n cv -n elayers -n mfdata -n mflayers -n mfmetadata -n mfresults -n pgq -n pgq_ext -n stage_r8 -n web_r8 -n silva_r* -n pfam_* -n web"

pg_dumpall --roles-only -f roles.sql -p ${SRC_DB_PORT}
pg_dump -s -f baseline.sql ${SCHEMA_LIST} -p ${SRC_DB_PORT} ${SRC_DB_NAME}
pg_dump -Fc --data-only -f dumpfile ${SCHEMA_LIST} -p ${SRC_DB_PORT} ${SRC_DB_NAME}
