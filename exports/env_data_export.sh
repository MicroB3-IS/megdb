#!/bin/bash

CMD='psql -h localhost -p 5491 -U rkottman -d megdb_r8'
${CMD} -c "\copy (select * from osdregistry.sample_environmental_data s where s.local_date between '2014-03-01' AND '2014-08-01') TO '/home/renzo/src/megdb/exports/OSD2014-env_data_$(date --rfc-3339=date).csv' (FORMAT CSV, delimiter '|', header true);"
