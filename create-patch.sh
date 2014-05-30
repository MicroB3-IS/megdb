#!/bin/bash

# input patch name

# checks patch does not exist automatically adds newest number

# file name patch ${num}-${name}-patch.sql

# file name patch ${num}-${name}-rollback.sql

# find last content changed file (mtime) ls -1rt

declare -r PATCH_DIR_NAME='patches'
declare -r ROLLBACK_DIR_NAME='rollbacks'



function check() {

  if [[ ! -d "${PATCH_DIR_NAME}" ]]; then
    echo "directory ${PATCH_DIR_NAME} does not exist" || exit
  fi

  if [[ ! -d "${ROLLBACK_DIR_NAME}" ]]; then
    echo "directory ${ROLLBACK_DIR_NAME} does not exist" || exit
  fi

}

function make_patch_name() {
  local -r old_name=${1}

  read -p 'patch name:' name
  ## todo check not empty
  if [[ -z "${name}" ]]; then
      
      echo "Please provide a patch name"
	  exit 1
  fi

  num=${old_name/-*/}
  ## next only works with extended globbing on
  shopt -s extglob; 
  num=${num##+(0)}
  (( num += 1 ))
  printf -v t "%05d" ${num}
  echo "${t}-${name}" 
}


function create_patch_file() {

  local PATCH_NAME="${1}"
  local latest_dep="${2}"
  local output="${PATCH_DIR_NAME}/${PATCH_NAME}-patch.sql"

  cat > "${output}" <<EOF 

BEGIN;
SELECT _v.register_patch('${PATCH_NAME}',
                          array['${latest_dep}'] );


rollback;


EOF
}

function create_rollback_file() {
  local PATCH_NAME="${1}"
  local output="${ROLLBACK_DIR_NAME}/${PATCH_NAME}-rollback.sql"

cat > ${output} <<EOF

BEGIN;

SELECT _v.unregister_patch( '${PATCH_NAME}');


ROLLBACK;
EOF

}

function main() {
  local patch_name
  local latest_patch_file

  check || exit "not all required stuff here"
  
  latest_patch_file=$(ls -1tr ${PATCH_DIR_NAME}/*.sql | tail -n1)

  latest_patch_name=$(basename "${latest_patch_file}" '.sql')

  echo "Latest patch=${latest_patch_file}"
  
  patch_name=$(make_patch_name ${latest_patch_name})

  create_rollback_file ${patch_name}
  create_patch_file ${patch_name} ${latest_patch_name}
}

main "$@"

exit
