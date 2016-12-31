
BEGIN;
SELECT _v.register_patch('00135-osdregistry_jambooree_envo_update_table',
                          array['00134-osdregistry-envo-terms-fks'] );

-- section of creation best as user role megdb_admin
SET ROLE megdb_admin;

set search_path to osdregistry;

CREATE TABLE  osdregistry.jam_corrections_2014 (
  osd_id text NOT NULL check (osd_id ~ 'OSD[0-9]{1,3}$'),
  ena_acc text,
  envo_biome text  REFERENCES envo.terms(term),
  envo_feature text,
  envo_material text
);
COMMENT ON TABLE osdregistry.jam_corrections_2014
  IS 'Corrections by jamborre 2014 people exported from google spreadsheet https://docs.google.com/spreadsheets/d/1x6QvuVuOhfptRo6ZeNzaTcltHvdbLYnEFNQx9pAH6Q8/edit#gid=475360534';
  
COPY jam_corrections_2014 FROM STDIN (NULL '');
OSD191	ERS667474	marine pelagic biome	surface water layer	sea water
OSD190	ERS667475	marine pelagic biome	surface water layer	sea water
OSD189	ERS667476	marine pelagic biome	surface water layer	sea water
OSD188	ERS667477	marine pelagic biome	surface water layer	sea water
OSD186	ERS667478	freshwater river biome	brackish estuary	brackish water
OSD185	ERS667479		surface water layer	sea water
OSD184	ERS667480	marine biome	surface water layer	sea water
OSD183	ERS667481	marine biome	surface water layer	sea water
OSD182	ERS667482	marine biome	surface water layer	sea water
OSD178	ERS667483	marine biome	surface water layer	sea water
OSD177	ERS667484	marine biome	surface water layer	sea water
OSD176	ERS667485	marine biome	surface water layer	sea water
OSD175	ERS667486	marine biome	surface water layer	sea water
OSD174	ERS667487	marine biome	surface water layer	sea water
OSD173	ERS667488	marine biome	surface water layer	sea water
OSD172	ERS667489	marine biome	surface water layer	sea water
OSD171	ERS667490	marine biome	surface water layer	sea water
OSD170	ERS667491	marine biome	surface water layer	sea water
OSD169	ERS667492	marine biome	surface water layer	sea water
OSD168	ERS667493	marine biome	surface water layer	coastal water
OSD167	ERS667494	marine biome	fjord	coastal water
OSD166	ERS667495	marine pelagic biome	pelagic isothermal surface	oligotrophic water
OSD165	ERS667496	marine biome	sea loch	sea water
OSD163	ERS667497	marine biome	surface water layer	ocean water
OSD162	ERS667498	marine biome	surface water layer	sea water
OSD159	ERS667499	marine biome	surface water layer	sea water
OSD158	ERS667500	marine biome	surface water layer	sea water
OSD157	ERS667501	marine pelagic biome	fjord	sea water
OSD157	ERS667502	marine pelagic biome	fjord	sea water
OSD156	ERS667503	marine pelagic biome	fjord	sea water
OSD156	ERS667504	marine pelagic biome	fjord	sea water
OSD155	ERS667505	marine pelagic biome	fjord	sea water
OSD155	ERS667506	marine pelagic biome	fjord	sea water
OSD154	ERS667507	marine pelagic biome	surface water layer	sea water
OSD153	ERS667508	marine biome	surface water layer	coastal water
OSD152	ERS667509	neritic epipelagic zone biome	natural harbor	coastal water
OSD152	ERS667510	neritic epipelagic zone biome	natural harbor	coastal water
OSD152	ERS667511	neritic epipelagic zone biome	natural harbor	coastal water
OSD152	ERS667512	neritic epipelagic zone biome	natural harbor	coastal water
OSD151	ERS667513	marine biome	surface water layer	seawater
OSD151	ERS667514	marine biome	surface water layer	sea water
OSD150	ERS667515	marine biome	lagoon	coastal water
OSD149	ERS667516	marine biome	surface water layer	seawater
OSD149	ERS667517	marine biome	lagoon	coastal water
OSD148	ERS667518	estuarine biome	surface water layer	sea water
OSD147	ERS667519	marine biome	surface water layer	sea water
OSD146	ERS667520	marine biome	surface water layer	sea water
OSD145	ERS667521	marine biome	surface water layer	sea water
OSD144	ERS667522	marine biome	surface water layer	sea water
OSD143	ERS667523	estuarine biome	surface water layer	sea water
OSD143	ERS667524	marine biome	surface water layer	seawater
OSD142	ERS667525	marine biome	surface water layer	seawater
OSD142	ERS667526	marine biome	continental shelf	sea water
OSD141	ERS667527	marine biome	surface water layer	seawater
OSD141	ERS667528	marine biome	fjord	sea water
OSD136	ERS667529	marine biome	surface water layer	seawater
OSD135	ERS667530	marine biome	surface water layer	seawater
OSD135	ERS667531	marine biome	surface water layer	seawater
OSD133	ERS667532	marine biome	surface water layer	sea water
OSD132	ERS667533	marine biome	surface water layer	oligotrophic water
OSD131	ERS667534	marine biome	coastal water body	coastal water
OSD130	ERS667535	marine biome	fjord	coastal water
OSD129	ERS667536	marine biome	fjord	ocean water
OSD128	ERS667537	marine biome	fjord	sea water
OSD127	ERS667538	marine biome	fjord	ocean water
OSD126	ERS667539	marine biome	fjord	coastal water
OSD125	ERS667540	marine biome	surface water layer	sea water
OSD124	ERS667541	marine biome	surface water layer	sea water
OSD124	ERS667542	marine biome	surface water layer	seawater
OSD123	ERS667543	marine biome	surface water layer	sea water
OSD122	ERS667544	marine biome	surface water layer	oligotrophic water
OSD121	ERS667545	marine pelagic biome	surface water layer	sea water
OSD120	ERS667546	marine pelagic biome	surface water layer	sea water
OSD119	ERS667547	marine pelagic biome	surface water layer	sea water
OSD118	ERS667548	neritic epipelagic zone biome	surface water layer	sea water
OSD117	ERS667549	marine biome	pelagic isothermal surface	mesotrophic water
OSD116	ERS667550	estuarine biome	surface water layer	coastal water
OSD115	ERS667551	marine biome	surface water layer	coastal water
OSD114	ERS667552	marine biome	surface water layer	mesotrophic water
OSD113	ERS667553	marine biome	pelagic isothermal surface	mesotrophic water
OSD111	ERS667554	estuarine biome	surface water layer	coastal water
OSD110	ERS667555	estuarine biome	surface water layer	coastal water
OSD109	ERS667556	estuarine biome	surface water layer	coastal water
OSD108	ERS667557	estuarine biome	surface water layer	coastal water
OSD107	ERS667558	estuarine biome	surface water layer	coastal water
OSD106	ERS667559	marine biome		sea water
OSD106	ERS667560	marine biome	surface water layer	sea water
OSD105	ERS667561	marine biome	surface water layer	sea water
OSD103	ERS667562	marine biome	surface water layer	sea water
OSD102	ERS667563	marine biome	surface water layer	sea water
OSD101	ERS667564	marine biome	surface water layer	sea water
OSD100	ERS667565	oceanic epipelagic zone biome	surface water layer	oligotrophic water
OSD100	ERS667566	marine biome	deep chlorophyll maximum layer	seawater
OSD99	ERS667567	marine biome	surface water layer	sea water
OSD99	ERS667568	marine biome	surface water layer	seawater
OSD98	ERS667569	marine biome	surface water layer	sea water
OSD97	ERS667570	oceanic epipelagic zone biome	surface water layer	coastal water
OSD96	ERS667571	marine biome	surface water layer	sea water
OSD95	ERS667572	marine biome	surface water layer	sea water
OSD94	ERS667573	mediterranean sea biome	surface water layer	coastal water
OSD93	ERS667574	neritic mesopelagic zone biome	surface water layer	coastal water
OSD92	ERS667575	neritic mesopelagic zone biome	surface water layer	coastal water
OSD91	ERS667576	neritic mesopelagic zone biome	surface water layer	coastal water
OSD90	ERS667577	freshwater lake biome	surface water layer	fresh water
OSD87	ERS667578	marine biome		seawater
OSD81	ERS667579	marine biome	surface water layer	sea water
OSD80	ERS667580	marine biome	surface water layer	sea water
OSD80	ERS667581	marine biome	surface water layer	seawater
OSD80	ERS667582	marine biome	surface water layer	sea water
OSD78	ERS667583	marine biome	surface water layer	sea water
OSD77	ERS667584	marine biome	surface water layer	seawater
OSD77	ERS667585	marine biome	surface water layer	sea water
OSD76	ERS667586	marine biome	surface water layer	sea water
OSD76	ERS667587	marine biome	surface water layer	seawater
OSD74	ERS667588	estuarine biome	surface water layer	coastal water
OSD73	ERS667589	estuarine biome	surface water layer	coastal water
OSD72	ERS667590	marine biome	surface water layer	seawater
OSD72	ERS667591	marine biome	surface water layer	sea water
OSD71	ERS667592	neritic epipelagic zone biome	surface water layer	sea water
OSD70	ERS667593	mediterranean sea biome	coastal inlet	sea water
OSD69	ERS667594	mediterranean sea biome	lagoon	brackish water
OSD65	ERS667595	marine biome	surface water layer	coastal water
OSD64	ERS667596	marine biome	surface water layer	sea water
OSD63	ERS667597	marine biome	surface water layer	sea water
OSD62	ERS667598	marine biome	surface water layer	sea water
OSD61	ERS667599	marine biome	surface water layer	sea water
OSD60	ERS667600	marine biome	coast	brackish water
OSD58	ERS667601	estuarine biome	surface water layer	ocean water
OSD56	ERS667603	marine biome	surface water layer	sea water
OSD57	ERS667602	marine biome	surface water layer	sea water
OSD55	ERS667604	marine biome	surface water layer	sea water
OSD55	ERS667605	marine biome	surface water layer	seawater
OSD54	ERS667606	marine biome	surface water layer	sea water
OSD54	ERS667607	marine biome	surface water layer	seawater
OSD53	ERS667608	marine biome	surface water layer	sea water
OSD52	ERS667609	marine biome	surface water layer	sea water
OSD51	ERS667616	marine pelagic biome	surface water layer	coastal water
OSD50	ERS667618	marine biome	surface water layer	sea water
OSD49	ERS667619	mediterranean sea biome	coastal water	sea water
OSD48	ERS667620	mediterranean sea biome	coast	sea water
OSD47	ERS667621	mediterranean sea biome	lagoon	brackish water
OSD46	ERS667622	marine biome	surface water layer	sea water
OSD45	ERS667623	marine biome	surface water layer	sea water
OSD43	ERS667624	marine biome	surface water layer	seawater
OSD43	ERS667625	marine biome	surface water layer	sea water
OSD42	ERS667626	marine biome	meromictic lake	water
OSD41	ERS667627	marine biome	marine algal bloom	sea water
OSD39	ERS667628	estuarine biome	harbor	sea water
OSD38	ERS667629	marine biome	surface water layer	sea water
OSD37	ERS667630	marine biome	surface water layer	sea water
OSD37	ERS667631	marine biome	surface water layer	seawater
OSD36	ERS667632	marine biome	surface water layer	estuarine water
OSD35	ERS667633	marine biome	surface water layer	estuarine water
OSD34	ERS667634	marine biome	surface water layer	sea water
OSD33	ERS667635	marine pelagic biome	surface water layer	sea water
OSD32	ERS667636	marine pelagic biome	surface water layer	sea water
OSD31	ERS667637	marine pelagic biome	surface water layer	sea water
OSD30	ERS667638	marine pelagic biome	; mixed surface layer	sea water
OSD30	ERS667639	marine biome	surface water layer	seawater
OSD29	ERS667640	marine biome	surface water layer	sea water
OSD28	ERS667641	marine reef biome	surface water layer	sea water
OSD26	ERS667642	mediterranean sea biome	surface water layer	sea water
OSD25	ERS667643	mediterranean sea biome	surface water layer	coastal water
OSD24	ERS667644	mediterranean sea biome	brackish water habitat	coastal water
OSD22	ERS667645	mediterranean sea biome	surface water layer	sea water
OSD21	ERS667646	mediterranean sea biome	surface water layer	sea water
OSD20	ERS667647	marine biome	surface water layer	sea water
OSD20	ERS667648	marine biome		sea water
OSD19	ERS667649	marine biome	surface water layer	sea water
OSD18	ERS667650	marine biome		sea water
OSD17	ERS667651	marine biome	surface water layer	sea water
OSD15	ERS667652	marine biome		sea water
OSD15	ERS667653	marine biome	surface water layer	sea water
OSD14	ERS667654	marine biome	surface water layer	sea water
OSD13	ERS667655	marine biome	surface water layer	sea water
OSD11	ERS667656	marine biome		seawater
OSD10	ERS667657	Large lake biome	surface water layer	fresh water
OSD9	ERS667658	oceanic epipelagic zone biome	marine wind mixed layer	sea water
OSD7	ERS667659	marine reef biome	surface water layer	sea water
OSD6	ERS667660	marine biome	coast	sea water
OSD5	ERS667661	oceanic epipelagic zone biome	deep chlorophyll maximum layer	oligotrophic water
OSD5	ERS667662	oceanic epipelagic zone biome	surface water layer	oligotrophic water
OSD4	ERS667663	marine biome	surface water layer	seawater
OSD4	ERS667664	marine biome	surface water layer	sea water
OSD3	ERS667665	marine biome	surface water layer	sea water
OSD3	ERS667666	marine biome	surface water layer	seawater
OSD2	ERS667667	neritic epipelagic zone biome	coastal water body	coastal water
OSD1	ERS667668	marine pelagic biome	surface water layer	seawater
OSD164		marine biome	surface water layer	seawater
\.

commit;

