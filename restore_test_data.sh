#!/usr/bin/sh

SRC_DB_PORT=5432
SRC_DB_NAME=megdb
SCHEMA_LIST="-n core -n partitions -n cv -n elayers -n pgq -n pgq_ext -n web_r8 -n silva_r102_ssu -n silva_r102_lsu -n pfam_23 -n pfam_24"

psql -p ${SRC_DB_PORT} -f before_pg_restore_test_data.sql $SRC_DB_NAME
pg_restore -p ${SRC_DB_PORT} -d ${SRC_DB_NAME} megdb.dump 
psql -p ${SRC_DB_PORT} -f after_pg_restore_test_data.sql $SRC_DB_NAME