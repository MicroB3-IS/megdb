

begin;

set search_path to jschnetz;

set role jschnetz;

CREATE TABLE osd_orig_data (
  submission_id integer PRIMARY KEY,
  osd_id integer, 
  site_name text, 
  start_lat numeric, 
  start_lon numeric, 
  stop_lat numeric, 
  stop_lon numeric, 
  sample_start_time text, 
  sample_end_time text, 
  sample_label text, 
  sample_protocol text, 
  sample_depth text, 
  sample_date text, 
  water_temperature text, 
  salinity text, 
  conductivity text,
  UNIQUE (osd_id, start_lat,sample_depth, sample_date)
);

copy osd_orig_data from stdin (format csv, header true);
id,osd_id,site_name,start_lat,start_lon,stop_lat,stop_lon,sample_start_time,sample_end_time,sample_label,sample_protocol,sample_depth,sample_date,water_temperature,salinity,conductivity
190,46,"Gulf of Mexico, Mississippi, USA",30.2484,-88.74825,30.2484,-88.74825,14:00:00,14:15:00,OSD46 - MS A or B 6-19-2014,NPL022,0.05,2014-06-21,29.8,17.5,not determined
44,60,"North Inlet, SC",33.32306,79.16763,33.32306,79.16763,10:45:00,11:00:00,OSD60_06_14_North Inlet_surface,NPL022,0.1,2014-06-19,27.77,35.13,53.34
40,39,"Charleston Harbor, SC",32.7524,79.89954,32.7524,79.89954,13:00:00,13:15:00,OSD39_06_14_Charleston Harbor_surface,NPL022,0.1,2014-06-19,31.3,24.3,37.56
223,65,Leigh,-36.292794,174.818567,-36.292794,174.818567,10:30:00,10:50:00,"Leigh 1, Leigh 2",NE08,0.1,2014-06-20,16,34,not determined
200,3,Helgoland,54.18194,7.9,54.18194,7.9,06:40:00,07:00:00,OSD3_o6_14_Helgoland,NE08,0.1,2014-06-20,14,32.591,not determined
35,136,Jyllinge Harbour,55.7449,12.0974,55.7449,12.0974,11:56:00,14:02:00,OSD136_06_14_Jyllinge Harbour_NPL022_surface,NPL022,0.1,2014-06-21,17,16.2,not determined
34,135,Helsinore Harbor,56.0434,12.6128,56.0434,12.6128,15:01:00,17:00:00,OSD135_06_14_Helsinore Harbour_NPL022_surface,NPL022,0.1,2014-06-21,20,17.3,not determined
142,7,Tiahura,-17.2894,-149.53985,-17.2894,-149.53985,10:00:00,10:15:00,,NPL022,0.1,2014-06-21,27,37,55.7
9,118,Lough Hyne,51.7423,-8.3112,51.7423,-8.3112,12:14:00,12:17:00,OSD118-Lough-Hyne-NPL022-1-surface,NPL022,0.2,2014-06-24,18,38,not determined
15,35,OSD35,38.6792,76.1742,38.6792,76.1742,12:01:00,13:30:00,OSD35_6_21_CHESAPEAKEBAY_NPL022_1_SURFACE,NPL022,0.5,2014-06-21,26.32,8.97,15.41
147,77,Metauro3000,44,13,44,13,12:00:00,13:30:00,OSD77_06_14Metauro3000,NPL022,0.5,2014-06-20,24,26,not determined
144,76,Foglia 3000,44,13,44,13,10:15:00,11:30:00,Foglia3000,NPL022,0.5,2014-06-20,24,28,not determined
156,166,Armintza,43.43255,2.89966,43.43287,2.90056,10:48:00,10:58:00,OSD166_06_14_Armintza_1_surface (till 12),NPL022,0.5,2014-06-21,17.88,35.05,45.83
79,98,OSD98_06_14_Sao Jorge,38.64,-28.13,38.64,-28.13,11:40:00,11:40:10,OSD_98_06_14_Sao Jorge_NPL022_1_surface,NPL022,0.5,2014-06-21,18.7,35.6,not determined
37,97,OSD97-Faial,38.5297,-28.601778,38.5297,-28.601778,11:35:00,12:18:00,OSD97_21-06-2014_Faial,NPL022,0.5,2014-06-21,16.9,35.6,not determined
17,78,Italy-CONISMA,43.57,13.595,43.57,13.595,10:00:00,10:30:00,"OSD78_06_2014_Italy- CONISMA_1_SURFACE, OSD78_06_2014_Italy- CONISMA_2_SURFACE, OSD78_06_2014_Italy- CONISMA_3_SURFACE, OSD78_06_2014_Italy- CONISMA_4_SURFACE,  OSD78_06_2014_Italy- CONISMA_5_SURFACE",NPL022,0.5,2014-06-21,24.25,34.33,not determined
91,61,Vineyard Sound,41.524467,-70.672174,41.524467,-70.672174,16:08:00,16:43:00,"The labels are as follows: OSD61-06-14-Vineyard Sound-NPL022-1-surface water, OSD61-06-14-Vineyard Sound-NPL022-2-surface water........OSD61-06-14-Vineyard Sound-NPL022-5-surface water",NPL022,0.5,2014-06-21,19.2,30.7,not determined
16,36,Delaware,39.3322,75.4699,39.3322,75.4699,12:30:00,13:30:00,OSD36_06_21_DELAWARE_NPL022_1_SURFACE,NPL022,0.5,2014-06-21,23.55,7.2,12.55
182,29,Smithsonian Marine Station,27.4694,80.283366,27.4694,80.283366,10:00:00,10:15:00,OSD29,NPL022,0.5,2014-06-21,26.9,35.7,not determined
181,28,"Carrie Bow Cay Field Station, Belize",16.802575,88.08165,16.802575,88.08165,10:15:00,10:20:00,OSD28,NE08,0.5,2014-06-21,29.5,35,not determined
28,72,Boknis Eck time series station,54.8333,10,54.8333,10,10:12:00,10:23:00,OSD72_06_21_2014_BoknisEck_NPL022_surface,NPL022,0.8,2014-06-21,13.994,14.253,19.853
173,37,Florida Coral 1-Port Everglades,26.10293,-80.09315,26.10293,-80.09315,08:11:00,08:24:00,OSD 37_06_14_Port Everglades_NPL022_1_surface,NPL022,1,2014-06-19,27.7,33.82,not determined
120,5,M3ACrete,35.661,24.99,35.661,24.99,07:15:00,13:15:00,M3ACrete-1m,NPL022,1,2014-06-19,24.45,39.26,58.14
211,157,ELLE2 Time series station,59.622,10.6282,59.622,10.6282,10:00:00,12:30:00,OSD157_n_1m,NPL022,1,2014-06-20,18,26.115,not determined
186,154,Tes Time Series Station,44.66666,-1.16666,44.66666,-1.16666,12:20:00,12:40:00,surface water,NPL022,1,2014-06-20,20.7,32.4,to be measured
22,152,Compass Buoy Station - Bedford Basin,44.6936,-63.6403,44.6936,-63.6403,11:54:00,11:59:00,OSD152_06_20_CBS-BB_1mE,NE08,1,2014-06-20,12.8,28.9,3437
141,76,Foglia 3000,44,13,44,13,10:15:00,11:30:00,Foglia3000,NE08,1,2014-06-20,24,28,to be measured
29,50,Pasaia EOM,43.316666667,-1.927777778,43.316666667,-1.927777778,08:09:00,08:11:00,OSD50_06_14_Pasaia,NPL022,1,2014-06-20,20,34.3,not determined
36,2,Roscoff SOMLIT Time Series Station,48.777778,-3.9375,48.777778,-3.9375,12:26:00,12:45:00,OSD2_06_14_Roscoff,NPL022,1,2014-06-20,14.3,35.086,will not be measured
209,156,Kavringen,59.89961,10.71999,59.89961,10.71999,11:00:00,13:00:00,OSD156_n_1m,NPL022,1,2014-06-21,17.8,30.054,not determined
204,155,OslofjordSteilene,59.81618,10.59863,59.81618,10.59863,08:00:00,11:00:00,155,NPL022,1,2014-06-21,18.7,30.054,not determined
77,143,SRiMP Time Series,31.98282,81.01667,31.98282,81.01667,13:45:00,15:00:00,OSD_SRiMP_029009,NPL022,1,2014-06-21,30.79,26.57,not determined
104,142,NDBC 41008,31.383607,80.866685,31.383607,80.866685,10:00:00,13:00:00,OSDE_06_21_GraysReef_NPL022,NPL022,1,2014-06-21,27.43,35.85,not determined
136,135,OSD135-GUAYMAS-BAY,27.9011,110.8717,27.9011,110.8717,11:03:00,11:30:00,OSD_135_06_14,NPL022,1,2014-06-21,31.2,37.4,56.55
97,133,OSD 133 Robben Island,-33.897069,18.386825,-33.93572,18.47147,09:24:00,10:14:00,"Robben_Island_Surface_1, Robben_Island_Surface_2, Robben_Island_Surface_3, Robben_Island_Surface_4, Robben_Island_Surface_5, Robben_Island_Surface_6",NPL022,1,2014-06-21,15.06,35.16,not determined
66,131,Zlatna ribka,42.244907,27.400804,42.252939,27.415647,10:24:00,13:30:00,OSD_131_06_2014_Zlatna_ribka_1m_1; OSD_131_06_2014_Zlatna_ribka_1m_2; OSD_131_06_2014_Zlatna_ribka_1m_3; OSD_131_06_2014_Zlatna_ribka_1m_4; OSD_131_06_2014_Zlatna_ribka_1m_5,NPL022,1,2014-06-21,22.5,14.3,not determined
164,119,PROGRESO,21.3142,-89.6712,21.3621,-89.6602,12:00:00,12:27:00,OSD_06_14_PROGRESO,NPL022,1,2014-06-21,25.8,36.2,55.6
143,99,OSD99_06_14_Trieste C1,45.70092,13.71003,45.70092,13.71003,11:24:00,12:31:00,OSD99_06_14_Trieste,NPL022,1,2014-06-21,20.821,33.931,47.278
108,95,Singapore,1.2685,103.9168,1.2726,103.9206,16:25:00,16:41:00,OSD95_06_14_Singapore_npl_022_1_surface,NPL022,1,2014-06-21,31,31.03,53.3
115,74,Douro Estuary,41.1416,8.6668,41.1416,8.6668,11:15:00,12:00:00,OSD74_06_14_Douro Estuary_NPLO22-1-Surface,NPL022,1,2014-06-21,20.2,13.75,not determined
172,73,Lima Estuary,41.6835,8.8341,41.6835,8.8341,11:15:00,11:29:00,OSD73_06_14_LimaEstuary_NPL022_1_Surface,NPL022,1,2014-06-21,18.4,32.3,not determined
89,64,Odessa,46.44155,30.77595,46.44155,30.77595,11:30:00,12:30:00,OSD64,NPL022,1,2014-06-21,20.3,17.63,32.2
39,58,PICO (Pivers Island Coastal Observatory),34.7181,-76.6707,34.7181,-76.6707,10:30:00,12:00:00,"zij@duke.edu, OSD58",NPL022,1,2014-06-21,25.8,35.8,will not be measured
140,55,Bigelow Laboratory Dock on Damariscotta River,43.8604,-69.5781,43.8604,-69.5781,11:30:00,12:37:00,OSD55_06_14_Damariscotta,NE08,1,2014-06-21,12.5,32,not determined
139,54,Booth Bay Long Term Times Series Station,43.8444,-69.6409,43.8444,-69.6409,10:45:00,11:30:00,OSD54_06_14_Maine BoothBay,NE08,1,2014-06-21,11.9,31,not determined
81,53,Ras Disha,27.041533,33.907033,27.041533,33.9082,10:43:00,10:50:00,"OSD53-06-14-Ras Disha-NPL022-1-1m, OSD53-06-14-Ras Disha-NPL022-2-1m, OSD53-06-14-Ras Disha-NPL022-3-1m, OSD53-06-14-Ras Disha-NPL022-4-1m, OSD53-06-14-Ras Disha-NPL022-5-1m",NPL022,1,2014-06-21,27.283333333,38.352,60.16383333
59,52,Abu Hashish,27.02527,33.91255,27.02527,33.91253,12:07:00,12:14:00,"OSD52-06-14-Abu Hashish-NPL022-1-1m, OSD52-06-14-Abu Hashish-NPL022-2-1m, OSD52-06-14-Abu Hashish-NPL022-3-1m, OSD52-06-14-Abu Hashish-NPL022-4-1m, OSD52-06-14-Abu Hashish-NPL022-5-1m",NPL022,1,2014-06-21,27,38.34333333,59.8573333
93,41,"Sequim Bay State Park, Sequim Bay, WA, USA",48.04051,-123,48.04051,-123.025684,10:40:00,10:45:00,###############################################################################################################################################################################################################################################################,NPL022,1,2014-06-21,15.9,24.73,32055
94,34,OSD34 Alexandria,31.21667,29.96667,31.21667,29.96667,11:30:00,12:30:00,OSD34_6_14_Alexandria_1-6_surface,NPL022,1,2014-06-21,27,36,57.4
32,15,Villefranche_PtB_SOMLIT,41.1666666,18.5833333,41.1666666,18.5833333,08:30:05,11:30:00,OSD15_06_14_VLFR_1_SURF,NPL022,1,2014-06-21,21.778,37.9702,not determined
45,10,Lake Erie W4,41.839834,83.18995,41.839834,83.18995,15:50:00,17:00:00,OSD10_6_14_Lake ErieW4_1 through 6,NPL022,1,2014-06-21,22.4,0.14,284
42,6,Blanes Bay Microbial Observatory,41.6666,2.8,41.6666,2.8,10:30:00,11:30:00,OSD6_06_14_Blanes_Protocol_Number sample_surface,NPL022,1,2014-06-21,20.66,37.83,not determined
112,5,CreteGOS,35.661,24.99,35.661,24.99,07:15:00,13:15:00,M3ACrete-1m_1,NPL022,1,2014-06-21,24.46,39.29,58.18
117,100,CreteGOS,35.35,25.29,35.35,25.29,10:00:00,12:30:00,CreteGOS-1m,NPL022,1,2014-06-22,24.21,39.05,57.59
153,162,Stonehaven monitoring site,56.9631,-2.1031,56.9631,-2.1031,11:00:00,11:00:00,OSD162_06_14_Stonehaven_NPL022_1_Integrated,NE08,1,2014-06-23,99,99,not determined
163,22,Solemio-SOMLIT Station,43.22639,5.74583,43.22639,5.74583,09:01:00,09:30:00,Niskin #2,NPL022,1,2014-06-23,21.9952,38.0871,not determined
30,186,SERC Rhode River,38.885507,-76.5416,38.885507,-76.5416,12:04:00,12:21:00,OSD186_06_14_SERCRhodeRiver_NPL022_1_1.2m,NPL022,1.2,2014-06-21,26.8,7.2,not determined
13,1,L4 - Time series station,50.151,-4.13,50.151,-4.13,11:10:00,11:25:00,OSD1_06_14_L4_NPL022_(1-5)_surface,NPL022,1.5,2014-06-21,16.66,35.22,not determined
51,93,El Jadida,33.259611,-8.499222,33.259611,-8.499222,11:00:00,12:00:00,OSD93 06 2014 El Jadida NPL022 Surface,NPL022,2,2014-06-21,19,3.92,478000
50,92,Casablanca,33.583917,-7.700639,33.583917,-7.700639,11:00:00,12:00:00,OSD92 06 2014 Casablanca NPL022 Surface,NPL022,2,2014-06-21,24,11.22,44700
52,91,El Oualidya,32.74675,-9.036667,32.74675,-9.036667,11:00:00,12:00:00,OSD91 06 2014 El Oualidya NPL022 Surface,NPL022,2,2014-06-21,19,3.82,39600
155,163,"Scapa, Orkney Islands",58.957,-2.9726,58.957,-2.9726,12:00:00,12:00:00,OSD163_06_14_Scapa,NPL022,2,2014-06-20,99,99,not determined
102,30,Finland/Tv?�¤rminne,59.8822,23.2538,59.8822,23.2538,10:15:00,11:15:00,OSD30_06_14_Finland/Tv?�¤rminne_NPL022_1_surface,NPL022,2,2014-06-20,10.5,5.63,7.203
158,168,IMST-Izmir,38.41333,27.03421,38.41333,27.03421,11:15:10,11:55:10,OSD168_06_14_IMST_Izmir_NPL022_2m,NPL022,2,2014-06-21,25.7352,38.301,58.32
71,90,Etoliko Lagoon - A9 station,38.48435,21.31689,38.48435,21.31689,10:00:00,13:00:00,OSD90_06_14_Etoliko_NPL0.22_surface,NPL022,2,2014-06-21,26.29,15.09,not determined
170,80,"Young Sound, Greenland",74.31,-20.3043,74.31,-20.3043,14:30:00,15:30:00,under-ice seawater,NPL022,2,2014-06-21,-1.6,32,not determined
122,51,STRI Point- Monitoring Program,9.3485,-82.266,9.3485,-82.266,10:56:00,11:02:00,OSD51_06_21_14_Bocas del Toro (Panama)_NPL022_3_2m,NPL022,2,2014-06-21,29,34.6,52.7
127,49,Slovenia (Vida),45.548833,68.05,45.548833,68.05,10:30:00,11:00:00,Slovenia(Vida)_1_surface,NPL022,2,2014-06-21,22,34,not determined
157,165,"Loch Ewe, West Coast, Scotland",57.8498,-5.6495,57.8498,-5.6495,09:00:00,09:00:00,OSD165_06_14_Loch Ewe,NPL022,2,2014-06-23,99,99,not determined
154,14,SOLA Time-Series Station,42.49,3.15,42.49,3.14,09:05:00,09:20:00,"OSD14-06-23-1 2m, OSD14-06-23-2 2m, OSD14-06-23-3, 2m, OSD14-06-23-2m",NPL022,2,2014-06-23,20.45,37.81,51.85
90,159,Brest-Somlit station.,48.359,-4.552,48.359,-4.552,11:00:00,11:30:00,OSD159_06_14_Brest-Somlit_ NPL022_1_surface,NPL022,2,2014-06-19,16,34.78,not determined
76,17,330,51.434733,2.810867,51.434733,2.810867,08:00:22,08:00:22,OSD17station330RV Simon StevinNiskin2014-06-20T08:00:22Z/2014-06-20T08:00:22Z,NPL022,3,2014-06-20,16.6822,34.0252,43.472
43,42,Faro Lake,38.26861,15.63708,38.26861,15.63708,11:00:00,12:00:00,Faro lake,NPL022,3,2014-06-21,20,36.8,not determined
214,185,421,51.481583,2.451483,51.481583,2.451483,14:34:02,14:34:02,OSD185_06_14_421_NPL022_opp3_3m,NPL022,3,2014-06-24,16.1087,34.8998,43.901
213,184,W10,51.682917,2.4152,51.682717,2.414967,18:06:27,18:07:22,OSD184_06_14_W10_NPL022_opp1_3m,NPL022,3,2014-06-24,15.8336,35.033,43.778
212,183,W09,51.74835,2.698,51.74835,2.698,21:58:17,21:58:17,OSD183_06_14_W09_NPL022_opp2_3m,NPL022,3,2014-06-24,15.8014,35.0087,43.719
207,178,435,51.580333,2.7897,51.580317,2.7897,23:20:37,23:20:42,OSD June2014_Midas14-450,NPL022,3,2014-06-24,16.7589,34.4964,44.085
206,177,120,51.18575,2.701667,51.185917,2.702133,11:35:57,11:37:07,OSD177_06_14_120_NPL022_opp1_3m,NPL022,3,2014-06-24,18.7362,32.5834,43.753
205,176,215,51.2777,2.6135,51.277933,2.613667,12:27:17,12:28:12,OSD176_06_14_215_NPL022_opp1_3m,NPL022,3,2014-06-24,18.1228,33.3699,44.104
197,175,ZG02,51.334817,2.50215,51.334817,2.50215,13:13:57,13:13:57,OSD175_06_14_ZG02_NPL022_opp3_3m,NPL022,3,2014-06-24,17.2187,34.2852,44.294
194,174,780,51.471567,3.059167,51.471583,3.0592,01:47:42,01:47:47,OSD178_06_14_780_NPL022_opp2_3m,NPL022,3,2014-06-24,17.9425,33.3739,43.935
195,173,710,51.441017,3.13995,51.441017,3.13995,02:39:52,02:39:52,OSD173_06_14_710_NPL022_opp3_3m,NPL022,3,2014-06-25,18.1816,33.1261,43.872
193,172,700,51.37485,3.218333,51.37485,3.218333,03:45:37,03:45:37,OSD172_06_14_700_NPL022_opp4_3m,NPL022,3,2014-06-25,18.4817,32.3383,43.219
192,171,230,51.307333,2.849333,51.307333,2.849333,05:23:32,05:23:32,OSD171_06_14_230_NPL022_opp2_3m OSD171_06_14_230_NPL022_opp3_3m,NPL022,3,2014-06-25,18.2617,32.8054,43.568
191,170,130,51.269517,2.9047,51.2695,2.90465,06:04:57,06:05:02,OSD170_06_14_130_NPL022_opp2_3m,NPL022,3,2014-06-25,18.6188,32.2575,43.251
189,123,Tel Shikmona,32,32,32,32,11:00:00,13:00:00,"OSD123-X (i.e. 1,2,etc.)",NPL022,4,2014-06-22,27,39.4,not determined
179,105,"Cambridge Bay, Nunavut, Canada",69.023323,-105.34339,69.023323,-105.34339,11:39:00,12:00:00,under-ice seawater,NPL022,4.12,2014-06-21,-0.72,26.91,not determined
24,152,Compass Buoy Station - Bedford Basin,44.6936,-63.6403,44.6936,-63.6403,12:30:00,12:35:00,OSD152_06_20_CBS-BB_5m_2,NPL022,5,2014-06-20,10.8,29.8,3363
106,141,Raunefjorden,60.12121,511.504,60.12121,511.504,09:45:00,10:00:00,OSD_141_06_14_Raunefjorden_NPL022_1_5m,NPL022,5,2014-06-20,10.13,30.67,not determined
56,146,"PS85/455-2, Fram Strait",78.453333,-2.829667,78.453333,-2.829667,05:42:00,06:29:00,OSD146_06_2014_FramStrait_NPL022_surface,NPL022,5,2014-06-21,-1.6,33.8,2.68
184,124,OSD124-Osaka Bay,34.32444,135.12083,34.32444,135.12083,12:25:00,12:40:00,OSD124_06_14_Osaka Bay_NPL022_(1-6)_5m,NPL022,5,2014-06-21,21.15,33.19,not determined
166,121,CELESTUN,20.8841,-90.4967,20.8841,-90.4967,11:59:00,12:30:00,OSD_06_14_CELESTUN,NPL022,5,2014-06-21,28.6,36.8,60.7
167,120,DZILAM,21.4934,-88.8468,21.4934,-88.8468,12:13:00,13:00:00,OSD_06_14_DZILAM,NPL022,5,2014-06-21,26.7,38.98,not determined
14,87,Eastern English Channel,51.1953,1.3405,51.1953,1.3405,11:07:00,13:45:00,OSD87_06_14_EasternEnglishChannel_1_9m to OSD87_06_14_EasternEnglishChannel_8_9m,NPL022,9,2014-06-21,15.86,35.08,4.39
26,152,Compass Buoy Station - Bedford Basin,44.6936,-63.6403,44.6936,-63.6403,12:50:00,12:59:00,OSD152_06_20_CBS-BB_10m_2,NPL022,10,2014-06-20,8.5,30.1,3218
180,11,RaTS CTD site 1,67.344,68.135,67.344,68.135,12:03:00,12:10:00,OSD_17_06_14,NPL022,15,2014-06-17,-1.62,33.47,will not be measured
225,106,Reykis,65.9449,-22.4192,65.9449,-22.4192,11:30:00,12:30:00,OSD106 - 15m (bottom),NPL022,15,2014-06-20,7.5,2.9,to be measured
227,20,Faxafl?�³i.,64.208333,-22.015,64.208333,-22.015,10:30:00,11:00:00,OSD20-20m,NPL022,20,2014-06-20,11,3.12,to be measured
116,100,CreteGOS,35.35,25.29,35.35,25.29,10:00:00,12:30:00,CreteGOS-20m,NPL022,20,2014-06-22,23.13,39.11,5.64
12,17,330,51.434733,2.810867,51.434733,2.810867,08:00:22,08:00:22,OSD17_06_14_330_NPL022_(1-6)_3m,NPL022,23.43,2014-06-20,16.6822,34.0252,43.472
222,113,CascaisWatch Time Series Station,38.6667,-9.4367,38.6667,-9.4367,11:25:00,12:00:00,OSD113_06_2014_NE_IA_CW,NPL022,39,2014-06-21,18,35.27,not determined
33,15,Villefranche_PtB-SOMLIT station,41.1666666,18.5833333,41.1666666,18.5833333,08:30:05,11:30:00,OSD15_06_14_VLFR_50m,NPL022,50,2014-06-21,16.0522,37.981,not determined
114,5,M3ACrete,35.661,24.99,35.661,24.99,13:00:00,15:00:00,M3ACrete-75m,NPL022,75,2014-06-19,16.87,39.21,49.58
148,18,Kyrenia 1,35.363732,33.289649,35.362826,33.287118,10:00:00,10:20:00,OSD18_06_14_NEU_Kyrenia_1_75;OSD18_06_14_NEU_Kyrenia_2_75; OSD18_06_14_NEU_Kyrenia_3_75,NPL022,75,2014-06-20,19.7,38.7,not determined
49,94,Saidia Marina,35.086353,-2.214658,35.086353,-2.214658,10:30:00,11:00:00,OSD94-06-2014-Saidia Marina-NPL022-Surface,NPL022,0,2014-06-21,23.6,31,51.37
47,26,Tangier,35.82,-5.75,35.82,-5.75,12:45:00,15:00:00,OSD26-06-2014-Tangier-NPL022-Surface,NPL022,0,2014-06-21,28,24.87,49.7
48,25,Saidia Rocher,35.086353,-2.214658,35.086353,-2.214658,10:00:00,11:00:00,OSD25-06-2014-Saidia Rocher-NPL022-Surface,NPL022,0,2014-06-21,23.1,30,51.1
46,24,Marchica Nador,35.1927,-2.88005,35.1927,-2.88005,12:30:00,14:00:00,OSD24 06 2014 Marchica NPL022 Surface,NPL022,0,2014-06-21,26.5,25.9,52.03
85,151,OSD151 South Atlantioc Microbial Observatory,-34.42,-54.16,-34.42,-54.16,11:30:00,12:00:00,OSD151_06_14_South Atlantioc Microbial Observatory_NE08,NE08,0,2014-06-21,11.67,32.86,37.5
8,9,San Pedro Ocean Time-series station or SPOT,33.55,-118.4,33.55,-118.4,20:18:00,20:27:00,OSD9_06_14_SPOT_NPL022_0m,NPL022,0,2014-06-18,19.2,33.56,4.54
224,106,Reykis,65.9449,-22.4192,65.9449,-22.4192,11:00:00,13:00:00,OSD106,NPL022,0,2014-06-20,7.6,1.9,to be measured
160,63,VENICE ACQUA ALTA,45.31435,12.508317,45.31435,12.508317,12:30:00,14:30:00,OSD63_06_14_VENICEACQUAALTA_NRN_SURFACE,NPL022,0,2014-06-20,21.781,32.768,46.894
174,38,Florida Coral 2 - Long Key,24.7449,-82.78375,24.7449,-82.78375,11:55:00,12:15:00,OSD 38_06_14_Long Key_NPL022_1_surface,NPL022,0,2014-06-20,29.6,36.25,not determined
226,20,Faxafl?�³i.,64.208333,-22.015,64.208333,-22.015,10:30:00,10:50:00,OSD20 surface,NPL022,0,2014-06-20,11,3.12,to be measured
168,4,"Long-term MareChiara station (LTER-MC), Naples",40.808,14.25,40.808,14.25,10:00:00,12:00:00,OSD4_6_2014_Naples_NPL022_N,NPL022,0,2014-06-20,23.206,37.064,53306.44746
88,158,Ribeira Quente,37.4328,-25.29,37.4328,-25.29,10:20:00,11:00:00,OSD158_06_14SaoMiguel_surface,NPL022,0,2014-06-21,19.2,35.7,26.9
134,153,Faro Island,36.997655,-7.973119,36.997655,-7.973119,10:15:00,10:35:00,OSD153_06_14_Faro_1_surface;OSD153_06_14_Faro_2_surface; OSD153_06_14_Faro_3_surface; OSD153_06_14_Faro_4_surface; OSD153_06_14_Faro_5_surface,NPL022,0,2014-06-21,21.1,34.4,will not be measured
80,149,OSD149 Laguna Rocha Norte,-34.37,-54.16,-34.37,-54.16,11:40:00,11:50:00,OSD149_06_14_LagunaRochaNorte_NPL022,NPL022,0,2014-06-21,10.98,14.3,20940
83,149,OSD149 Laguna Rocha Sur,-34.6759,-54.2752,-34.6759,-54.2752,12:00:00,12:10:00,OSD150_06_14_LagunaRochaSur_NPL022,NPL022,0,2014-06-21,9.99,18,20.94
18,148,Wadden Sea,53.580926,8.148636,53.580926,8.148636,09:45:00,10:00:00,OSD148_06_14_WaddenSea_NPL022_1_surface,NPL022,0,2014-06-21,17.77,31.14,to be measured
10,147,RAJARATA,8.5216,81.0521,8.5216,81.0521,11:03:00,11:25:00,"OSD147_06_14_Rajarata_01,  OSD147_06_14_Rajarata_02,  OSD147_06_14_Rajarata_03,  OSD147_06_14_Rajarata_04, OSD147_06_14_Rajarata_05",NE08,0,2014-06-21,28.8,33,53.2
221,145,Blankenberge,51.361369,3.118856,51.361369,3.118856,11:45:00,12:05:00,OSD145_06_14_Blankenberge_NPL022_1_surface,NPL022,0,2014-06-21,17,,not determined
215,117,Tavira Beach,37.167,-7.504,37.167,-7.504,16:10:00,16:40:00,OSD117_06_2014_SIA_TB,NPL022,0,2014-06-21,23.64,37.93,not determined
87,96,Caloura,37.4257,-23.3156,37.4257,-23.3156,11:50:00,12:10:00,OSD96_06_14SaoMiguel_surface,NPL022,0,2014-06-21,18.5,35,27.9
135,81,Ria Formosa Lagoon,37.005053,-7.973119,37.005053,-7.973119,10:58:00,11:20:00,OSD81_06_14_RiaFormosa_1_Surface;OSD81_06_14_RiaFormosa_2_Surface; OSD81_06_14_RiaFormosa_3_Surface;OSD81_06_14_RiaFormosa_4_Surface;OSD81_06_14_RiaFormosa_5_Surface;,NPL022,0,2014-06-21,22.2,34.3,will not be measured
178,80,"Young Sound, Greenland",74.31,-20.3043,20.3043,-20.3043,16:30:00,17:30:00,under-ice meltwater,NPL022,0,2014-06-21,-0.1,5,not determined
96,71,Otago,-45.7442,170.7706,-45.7555,170.7586,11:35:00,11:45:00,"OSD-June-2014_research vessel, BERYL BREWIN_Bucket and Horiba U-50 Multiparameter_2014-06-21T11:35:00",NPL022,0,2014-06-21,10.99,35.2,54.5
152,70,Venice Lido,45.4142,12.4378,45.4142,12.4378,12:11:00,12:13:00,OSD70_06-14_Venice_Lido_NPL022_N?�°_surface,NPL022,0,2014-06-21,23.4,31.67,will not be measured
151,69,Venice Marghera,45.4568,12.2605,45.4568,12.2605,16:08:00,16:11:00,OSD69_06-14_Venice_Marghera_NPL022_N?�°_surface,NPL022,0,2014-06-21,25.7,29.41,will not be measured
188,62,OSD62 Bangor,53.225417,-4.159028,53.225417,-4.159028,10:00:00,10:02:00,"OSD62 filters Nr 2, 3, 4, 5, 6, 7",NPL022,0,2014-06-21,16,34,not determined
150,48,Venice Gulf,45.4125,12.5265,45.4125,12.5265,10:50:00,10:52:00,OSD48_06-14_Venice_Gulf_NPL022_N?�°_surface,NPL022,0,2014-06-21,22.2,33.14,will not be measured
149,47,Venice Lagoon,45.502,12.4176,45.502,12.4176,13:56:00,13:57:00,OSD47_06-14_Venice_Lagoon_NPL022_N?�°_surface,NPL022,0,2014-06-21,25.3,27.42,will not be measured
92,43,Scripps Pier,32.86698,-117.25725,32.86698,-117.25725,10:49:00,12:25:00,OSD43_06_14_CAScripps-SIOpier_1_surface,NPL022,0,2014-06-21,21.03,33.54,not determined
217,21,RV1,43.6387194444,-116.2413513485,43.6387194444,-116.2413513485,11:55:00,12:05:00,6/2014,NPL022,0,2014-06-21,19.5,37.1,will not be measured
31,13,Varna Bay,43.175843,27.908643,43.175843,27.908643,08:30:00,08:45:00,Varna Bay_surface,NPL022,0,2014-06-21,22.87,12.6,not determined
198,132,Sdot Yam,32.0694,34.843,32.0694,34.843,10:45:00,11:00:00,OSD3-06-14 Sdotyam  NPL022 1Surface,NPL022,0,2014-06-22,27.3,39.35,not determined
196,122,Station A1 Eilat,29.4667,34.9291,29.4667,34.9291,09:45:00,10:45:00,OSD3-06-14 St a1 eilat NPL022 1Surface,NPL022,0,2014-06-22,24,40.5,will not be measured
175,45,Gulf of Mexico-Florida - Tampa Bay,27.61578,-82.72587,27.61578,-82.72587,16:30:00,16:55:00,OSD 45_06_14_Tampa Bay_NPL022_1_surface,NPL022,0,2014-06-22,31.2,33.84,not determined
53,144,MAUNALUA BAY,21.26882,157.72231,21.26882,157.72231,20:08:00,20:08:00,NPL022,NPL022,0,2014-06-24,25.8,35,not determined
55,57,ALAWAI,21.28656,157.84351,21.28656,157.84351,21:38:00,21:38:00,NPL022,NPL022,0,2014-06-24,27.58,34,not determined
54,56,KAKAAKO/KEWALO,21.2888,156.86362,21.2888,156.86362,21:20:00,21:20:00,NPL022,NPL022,0,2014-06-24,26.06,35,not determined
\.



--\copy osd_orig_data from '/home/renzo/src/megdb/scratch/osd_submissions_2014-12-22_original_cleaned.csv' (format csv, header true);


--with test as  (
CREATE VIEW osd_satellite_data AS 
select osd.*,
       t.sst as terra_sst,
       m.sst as modis_sst,
       count( t.sst ) OVER () as terra_cnt,
       count( m.sst ) OVER () as modis_cnt,
       count( osd.osd_id) OVER (partition by osd.osd_id, osd.sample_depth) as c
  from osd_orig_data as osd
       left join
         terra_osd as t on ( osd.submission_id = t.id)
       left join
         modis_osd as m ON ( osd.submission_id = m.id )
       left join
         osdregistry.samples as sam ON (osd.submission_id = sam.submission_id)
       
 WHERE m.id is not null or t.id is not null
  order by osd.osd_id
  ;
--)

--select * from test where c > 1;

commit;


       
