#set -x

# in general here is a mess in using variables

declare -r STAGE_HOME='/megx/data/megx-portal/megdb/'
# renzo: is this used for the directory but it differs from the one used for the database BAD!

declare -r STAGE_VERSION='r9' # for ease of use in schema naming (i.e. non-dir contexts) the forward slashes are omitted

# braces explicitly define variable boundaries
declare -r WORK_DIR=${STAGE_HOME}${STAGE_VERSION} 

declare -r DOWN_DIR_NAME='download'

declare -r FTP_PROXY='ftp://firewall.mpi-bremen.de'

declare -r  FTP_NCBI='ftp://ftp.ncbi.nih.gov'

declare -r PSQL_PROMPT='psql -h antares -p 5491 megdb_r8 '
#TODO rename to PSQL_CMD
declare -r PSQL="${PSQL_PROMPT} -c "

#renzo: this var should be generated with the STAGE_VERSION 
declare -r PSQL_SCHEMA="stage_r8"
declare -r PSQL_SEARCH_PATH="SET search_path TO ${PSQL_SCHEMA};"


declare -r MYSQL_USER='agrigore'
declare -r MYSQL_PASSWORD='36ice94cream'
declare -r MYSQL_CONNECT="mysql -h mg-mysql -u ${MYSQL_USER} -p${MYSQL_PASSWORD}"
declare -r MYSQL_STANDARDOUTPUT_CONNECT="${MYSQL_CONNECT} --quick --max_allowed_packet=1099511627776 -N -e"



