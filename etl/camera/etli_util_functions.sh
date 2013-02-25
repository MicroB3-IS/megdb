get_iso_date() {
  echo $(date --rfc-3339=date)
}


create_local_wd ( )
{
  echo "${2} ${3}" #????
  local -r dirname=${WORK_DIR}/${1:?"ERROR: missing local dir name!"}
  mkdir -p $dirname
  if [ -d $dirname ]
  then
   LCD=$dirname
   #now creating standard subdirs
   if mkdir -p ${dirname}/${DOWN_DIR_NAME:?"ERROR: missing download dir name"}
   then
     echo "Created download dir=${dirname}/${DOWN_DIR_NAME}"
     return
   fi
  else
    echo "Could not create work directory structure"
    exit 2
  fi
}

clean_local_wd () {
  cd ${WORK_DIR}
  rm ${WORK_DIR}/${DOWN_DIR_NAME}/* -rf
  cd -
  return
}

# returns result
csv_header_to_pg_cols() {

  local -r FILE=${1:?"ERROR: missing file name !"}
  result=''

  if [ ! -r ${FILE} ]; then
   exit "Could not access ${FILE_NAME}"
  fi

  ## removes leading and trailing whitespace and removes DOS line
  line_clean_cmd="sed -e 's/^[ ^t]*//'"

result=$(head -n1 ${FILE} | eval ${line_clean_cmd} | tr '[:upper:]' '[:lower:]' | tr '\t ' '\n_' | sed -e 's/_\?\(.*\)/_\1/' | sed -e "s/\$/ text DEFAULT ''::text,/")

 echo $result

}

skip_check () {
  if [[ -z "$1" ]]; then
    echo "skip_check missing argument"
    return 1
  elif [[ "$1" == "yes" || "$1" == "y" ]]; then
    echo "skipping function $2"
    return 0
  else 
    return 1
  fi
}

 
clean_file() {
  caller 0
  local -r FILE=${1:?"ERROR: missing file name !"}

  if [ ! -r ${FILE} ]; then
   exit "No read permission on ${FILE_NAME}"
  fi
  if [ ! -w ${FILE} ]; then
   exit "No write permission on ${FILE_NAME}"
  fi

  dos2unix ${FILE}
}