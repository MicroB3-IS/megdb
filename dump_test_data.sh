#!/usr/bin/sh

SRC_DB_PORT=5440
SRC_DB_NAME=megdb_r8
SCHEMA_LIST="-n core -n partitions -n cv -n elayers -n pgq -n pgq_ext -n web_r8 -n silva_r102_ssu -n silva_r102_lsu -n pfam_23 -n pfam_24"

pg_dump -Fc --data-only -f megdb.dump ${SCHEMA_LIST} -p ${SRC_DB_PORT} ${SRC_DB_NAME}
