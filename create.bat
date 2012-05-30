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
SET POSTGIS=C:\Program Files (x86)\PostgreSQL\9.1\share\contrib\postgis-1.5
SET PORT=5432
SET DATABASE=megdb-%RELEASE%
SET PSQL_ARGS=%PSQL_ARGS% -v ON_ERROR_STOP=1 -U postgres 


createdb -U postgres -E UTF8 %DATABASE%

PAUSE

psql %PSQL_ARGS% -f patches/add-versioning.sql %DATABASE%
psql %PSQL_ARGS% -f "%POSTGIS%/postgis.sql" %DATABASE%
psql %PSQL_ARGS% -f "%POSTGIS%/spatial_ref_sys.sql" %DATABASE%
psql %PSQL_ARGS% -f "%POSTGIS%/postgis_comments.sql" %DATABASE%
psql %PSQL_ARGS% -f patches/hstore.sql %DATABASE%
psql %PSQL_ARGS% -f patches/roles.sql %DATABASE%
psql %PSQL_ARGS% -f patches/baseline.sql %DATABASE%
psql %PSQL_ARGS% -f patches/1-partitioning.sql %DATABASE%
psql %PSQL_ARGS% -f patches/5-view-fix.sql %DATABASE%
psql %PSQL_ARGS% -f patches/6-drop-sequence-storage-legacy.sql %DATABASE%

PAUSE