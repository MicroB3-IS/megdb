#!/bin/bash


valid_year=("2014" "2015")
YEAR=${1}

[[ ${YEAR} = *[^[:space:]]* ]] || { echo "no year given"; exit 9; }

if [[ "${valid_year[*]}" =~ "${YEAR}" ]]; then
    echo "Exporting env data for year ${YEAR}"
else
    echo "Wrong year";
    exit 100;
fi

CMD='psql -h localhost -p 5491 -U rkottman -d megdb_r8'
$CMD -c "\copy (select * from osdregistry.sample_environmental_data s where s.local_date between '${YEAR}-03-01' AND '${YEAR}-12-31') TO '/home/renzo/src/megdb/exports/OSD${YEAR}-env_data_$(date --rfc-3339=date).csv' (FORMAT CSV, delimiter '|', header true);"
