:: steps to creation
:: 1. initdb -D [myclusterdir]
:: 2. postgres -D [myclusterdir]
:: 3. psql -p [port] -c "create database [DATABASE];"
:: 4. create.sh
:: psql has to be in PATH

ECHO PATH=%PATH%

SET RELEASE=9
SET VERSIONING=/opt/versioning
SET POSTGIS=/opt/postgres/9.1.1/pgsql/share/contrib/postgis-1.5
SET PORT=5432
SET DATABASE=megdb-%RELEASE%

psql -p %PORT% -f %VERSIONING%/install.versioning.sql %DATABASE%
psql -p %PORT% -f %POSTGIS%/postgis.sql %DATABASE%
psql -p %PORT% -f patches+/hstore+.sql %DATABASE%
psql -p %PORT% -f patches+/roles+.sql %DATABASE%
psql -p %PORT% -f patches+/baseline+.sql %DATABASE%
psql -p %PORT% -f patches+/1-partitioning+.sql %DATABASE%
psql -p %PORT% -f patches+/5-view-fix+.sql %DATABASE%
psql -p %PORT% -f patches+/6-drop-sequence-storage-legacy+.sql %DATABASE%

PAUSE