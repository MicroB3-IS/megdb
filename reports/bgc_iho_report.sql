

Begin;
\pset null null


create temp table bgc_iho_counts (
  iho_label text PRIMARY KEY,
  num integer
);

copy bgc_iho_counts(iho_label, num) FROM STDIN;
Adriatic Sea	16
Aegean Sea	5
Alboran Sea	3
Balearic Sea	1
Bay of Bengal	2
Bay of Biscay	2
Black Sea	3
Caribbean Sea	1
Celtic Sea	2
Coral Sea	2
English Channel	2
Great Australian Bight	1
Greenland Sea	10
Gulf of Aqaba	1
Gulf of Finland	2
Gulf of Mexico	5
Indian Ocean	1
Inner Seas off the West Coast of Scotland	1
Ionian Sea	1
Irish Sea and St. George's Channel	1
Japan Sea	2
Kattegat	4
Mediterranean Sea - Eastern Basin	5
Mediterranean Sea - Western Basin	3
North Atlantic Ocean	50
North Pacific Ocean	6
North Sea	25
Northwestern Passages	1
Red Sea	2
Singapore Strait	1
Skaggerak	6
South Atlantic Ocean	6
South Pacific Ocean	3
Southern Ocean	1
Strait of Gibraltar	1
Tasman Sea	2
The Coastal Waters of Southeast Alaska and British Columbia	1
Timor Sea	1
Tyrrhenian Sea	3
\.
--'
\echo osd sites in the meditereanen

select * 
  from bgc_iho_counts bgc
inner join
       marine_regions_stage.iho iho 
    ON (bgc.iho_label = iho.label)
 where iho.id 
    in ( 
          '28A', -- med sea western basin
          '28B', -- med seaeastern  basin
          '28a', -- strait gibraltar
          '28b', -- alboran sea
          '28c', -- balearic
          '28d', -- ligurien
          '28e', -- thyrr
          '28f', -- ion
          '28g', -- adriat
          '28h', -- aegean
          '28f' -- ion
       ) ;


\echo black sea (which is not med!)







rollback;
