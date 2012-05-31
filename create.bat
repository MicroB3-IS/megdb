:: steps to creation
:: 1. initdb -D [myclusterdir]
:: 2. postgres -D [myclusterdir]
:: 3. psql -p [port] -c "create database [DATABASE];"
:: 4. create.sh
:: the postgresql bin has to be in PATH

@ECHO off
ECHO PATH=%PATH%

SET RELEASE=9
:: SET VERSIONING=/opt/versioning
SET POSTGIS=E:\dev\pg-91\share\contrib\postgis-1.5
SET PORT=5432
SET DATABASE=megdb-%RELEASE%
SET PSQL_ARGS=-v ON_ERROR_STOP=1 -U postgres 
SET DUMP_FILE=E:\Dropbox\work\megx\megdb\megdb.dump

:: this schema list is without pgq


ECHO Creating developer database %DATABASE%

createdb -U postgres -E UTF8 %DATABASE%

PAUSE

ECHO Setting up baseline DDL

psql %PSQL_ARGS% -f baseline/add-versioning.sql %DATABASE%
psql %PSQL_ARGS% -f "%POSTGIS%/postgis.sql" %DATABASE%
psql %PSQL_ARGS% -f "%POSTGIS%/spatial_ref_sys.sql" %DATABASE%
psql %PSQL_ARGS% -f "%POSTGIS%/postgis_comments.sql" %DATABASE%
psql %PSQL_ARGS% -f baseline/hstore.sql %DATABASE%
::psql %PSQL_ARGS% -f patches/roles.sql %DATABASE%
psql %PSQL_ARGS% -f baseline/windows-baseline.sql %DATABASE%

ECHO Applying patches now...

psql %PSQL_ARGS% -f patches/1-partitioning.sql %DATABASE%
psql %PSQL_ARGS% -f patches/5-view-fix.sql %DATABASE%
psql %PSQL_ARGS% -f patches/6-drop-sequence-storage-legacy.sql %DATABASE%

PAUSE

ECHO Loading test data

psql %PSQL_ARGS% -f before_pg_restore_test_data.sql %DATABASE%

ECHO Now restoring data

pg_restore -a -v -e -p %PORT% -n cv -d %DATABASE% %DUMP_FILE% 
pg_restore -a -v -e -p %PORT% -n pfam_23 -d %DATABASE% %DUMP_FILE%
pg_restore -a -v -e -p %PORT% -n pfam_24 -d %DATABASE% %DUMP_FILE%
pg_restore -a -v -e -p %PORT% -n core -d %DATABASE% %DUMP_FILE%
pg_restore -a -v -e -p %PORT% -n partitions -d %DATABASE% %DUMP_FILE%
pg_restore -a -v -e -p %PORT% -n elayers -d %DATABASE% %DUMP_FILE%
pg_restore -a -v -e -p %PORT% -n web_r8 -d %DATABASE% %DUMP_FILE%
pg_restore -a -v -e -p %PORT% -n silva_r102_ssu -d %DATABASE% %DUMP_FILE%
pg_restore -a -v -e -p %PORT% -n silva_r102_lsu -d %DATABASE% %DUMP_FILE%


ECHO recreating trigger
psql %PSQL_ARGS% -f after_pg_restore_test_data.sql %DATABASE%

ECHO Done