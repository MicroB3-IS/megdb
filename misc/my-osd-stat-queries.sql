 select label, count(iho.label)
   from myosd.registrations as myosd
   left join elayers.ocean_limits as iho
     on ( iho.label in ( 'North Sea', 'Baltic Sea' )
	  AND st_dwithin (myosd.geog,
	                  iho.geog, 10000)
        )
where iho.label is not null group by iho.label;	


--\copy ( select myosd.id as reg_id, myosd.myosd_id, myosd.user_name, myosd.place_name, iho.label  from myosd.registrations as myosd  left join elayers.ocean_limits as iho on ( iho.label in ( 'North Sea', 'Baltic Sea' )  AND st_dwithin (myosd.geog, iho.geog, 10000)  ) where iho.label is not null ) to '/tmp/myosd-ocean-samples.csv' (format csv, header);	
