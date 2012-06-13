# steps to creation
# 1. initdb -D [myclusterdir]
# 2. postgres -D [myclusterdir]
# 4. create.sh

VERSIONING=/opt/versioning
POSTGIS=/opt/postgres/9.1.1/pgsql/share/contrib/postgis-1.5
PORT=5432
DATABASE=megdb
DUMPFILE=megdb.dump

echo Creating developer database ${DATABASE} 

createdb -U postgres -E UTF8 ${DATABASE}

echo Setting up baseline DDL

psql -p ${PORT} -f baseline/add-versioning.sql ${DATABASE}
psql -p ${PORT} -f ${POSTGIS}/postgis.sql ${DATABASE}
psql -p ${PORT} -f ${POSTGIS}/spatial_ref_sys.sql ${DATABASE}
psql -p ${PORT} -f ${POSTGIS}/postgis_comments.sql ${DATABASE}
psql -p ${PORT} -f baseline/hstore.sql ${DATABASE}
psql -p ${PORT} -f baseline/roles.sql ${DATABASE}
psql -p ${PORT} -f baseline/baseline.sql ${DATABASE}

echo Applying patches now...

psql -p ${PORT} -f patches/1-partitioning.sql ${DATABASE}
psql -p ${PORT} -f patches/5-view-fix.sql ${DATABASE}
psql -p ${PORT} -f patches/6-drop-sequence-storage-legacy.sql ${DATABASE}

echo Loading test data

psql -p ${PORT} -f before_pg_restore_test_data.sql ${DATABASE}

echo Now restoring data

pg_restore -a -v -e -p ${PORT} -n cv -d ${DATABASE} ${DUMP_FILE} 
pg_restore -a -v -e -p ${PORT} -n pfam_23 -d ${DATABASE} ${DUMP_FILE}
pg_restore -a -v -e -p ${PORT} -n pfam_24 -d ${DATABASE} ${DUMP_FILE}
pg_restore -a -v -e -p ${PORT} -n core -d ${DATABASE} ${DUMP_FILE}
pg_restore -a -v -e -p ${PORT} -n partitions -d ${DATABASE} ${DUMP_FILE}
pg_restore -a -v -e -p ${PORT} -n elayers -d ${DATABASE} ${DUMP_FILE}
pg_restore -a -v -e -p ${PORT} -n web_r8 -d ${DATABASE} ${DUMP_FILE}
pg_restore -a -v -e -p ${PORT} -n silva_r102_ssu -d ${DATABASE} ${DUMP_FILE}
pg_restore -a -v -e -p ${PORT} -n silva_r102_lsu -d ${DATABASE} ${DUMP_FILE}


echo recreating trigger
psql -p ${PORT} -f after_pg_restore_test_data.sql ${DATABASE}

echo Done
