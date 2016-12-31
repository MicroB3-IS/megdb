taking list of ENVO terms and corresponding ids from https://code.google.com/p/envo/source/browse/trunk/src/envo/reports/envo-edges.csv?spec=svn209&r=209 


raw CSV is: http://envo.googlecode.com/svn/trunk/src/envo/reports/envo-edges.csv?p=209


uique list:

cat envo-edges.csv |  tail -n +2  | cut -d ',' -f -2  | sort -u | cut -d '_' -f 2 > envo_stage_$(date +%Y%m%d).csv


or possibly new version in future.
