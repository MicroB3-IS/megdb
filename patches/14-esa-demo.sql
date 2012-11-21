begin;

drop schema if exists esa cascade;
create schema esa;

alter schema esa OWNER to megdb_admin;
set search_path = esa, public, pg_catalog;
set default_tablespace = '';
set default_with_oids = false;


drop  table if exists samples;
create table samples(
	id text not null, -- sample id
	taken timestamp with time zone not null, -- datetime the sample was taken on
	modified timestamp with time zone not null, -- datetime when the sample was modified
	collector_id text not null, -- who created the sample, user.login would fit most in here, but no restrictions for now...
	label text not null, -- sample label
	raw_data text not null, -- JSON data of the sample
	
	-- we're starting the general properties here...
	barcode text,
	project_id text,
	user_name text,
	ship_name text,
	nationality text,
	-- time is mapped with `taken`
	elevation decimal default 0,
	biome text,
	feature text,
	collection text,
	permit text,
	sampling_depth decimal default 0,
	water_depth decimal default 0,
	sample_size int default 0,
	weather_condition text,
	air_temperature decimal default 0,
	water_temperature decimal default 0,
	conductivity text,
	wind_speed decimal default 0,
	salinity decimal default 0,
	comment text,
--	geom geometry(Point, 4326),
	
	constraint pk_samples primary key (id)
);
select AddGeometryColumn('esa','samples','geom',4326, 'POINT',2);


drop table if exists sample_images;
create table sample_images(
	uuid text not null,
	sid text not null, -- sample id
	data bytea, -- the image data
	path text, -- path to the image
	mime_type text, -- the MIME type
	
	constraint pk_sample_images primary key (uuid),
	constraint fk_sample_images_samples foreign key (sid)
			references samples(id) on update cascade
								 on delete cascade
);

drop table if exists gen_config;
create table gen_config(
	category text not null,
	name text not null,
	value text,
	
	constraint pk_gen_config primary key (category, name)
);

-- Configuration data dump
insert into gen_config
	(category, name, value)
values

-- Sample Materials
( 'sampleMaterials', 'not known',           'Not Known' ),
( 'sampleMaterials', 'air',                 'Air'       ),
( 'sampleMaterials', 'drainage water',      'Drainage Water'),
( 'sampleMaterials', 'dust',                'Dust'),
( 'sampleMaterials', 'fecal',               'Fecal'),
( 'sampleMaterials', 'gas',                 'Gas' ),
( 'sampleMaterials', 'geysir water',        'Geysir Water' ),
( 'sampleMaterials', 'ground water',        'Groud Water' ),
( 'sampleMaterials', 'lake sediment',       'Lake Sediment' ),
( 'sampleMaterials', 'lake water',          'Lake Water' ),
( 'sampleMaterials', 'meteorite',           'Meteorite' ),
( 'sampleMaterials', 'mountain ice',        'Mountain Ice' ),
( 'sampleMaterials', 'mud',                 'Mud' ),
( 'sampleMaterials', 'ocean sediment',      'Ocean Sediment' ),
( 'sampleMaterials', 'ocean water',         'Ocean Water' ),
( 'sampleMaterials', 'organism',            'Organism'),
( 'sampleMaterials', 'physical',            'Physical'),
( 'sampleMaterials', 'river sediment',      'River Sediment'),
( 'sampleMaterials', 'river water',         'River Water'),
( 'sampleMaterials', 'rock',                'Rock'),
( 'sampleMaterials', 'sea ice',             'Sea Ice'),
( 'sampleMaterials', 'sediment pore water', 'Sediment Pore Water' ),
( 'sampleMaterials', 'soil',                'Soil' ),
( 'sampleMaterials', 'spittle',             'Spittle' ),
( 'sampleMaterials', 'stone',               'Stone' ),
( 'sampleMaterials', 'tissue',              'Tissue' ),
( 'sampleMaterials', 'vent fluid',          'Vent Fluid' ),
( 'sampleMaterials', 'whale bone',          'Whale Bone' ),

-- enable export
('categories', 'sampleMaterials','exported'),

-- Projects
('projects',  'microB3', 'Micro B3'),
('projects',  'biovel',   'Biovel'),
-- export
('categories', 'projects','exported'),


-- Weather conditions
('weatherConditions', 'Clear night','Clear night'),
('weatherConditions', 'Sunny day','Sunny day'),
('weatherConditions', 'Partly cloudy','Partly cloudy'),
('weatherConditions', 'Sunny intervals', 'Sunny intervals'),
('weatherConditions', 'Dust', 'Dust'),
('weatherConditions', 'Mist', 'Mist'),
('weatherConditions', 'Fog', 'Fog'),
('weatherConditions', 'Cloudy', 'Cloudy'),
('weatherConditions', 'Overcast', 'Overcast'),
('weatherConditions', 'Drizzle', 'Drizzle'),
('weatherConditions', 'Light rain', 'Light rain'),
('weatherConditions', 'Heavy rain', 'Heavy rain'),
('weatherConditions', 'Sleet shower', 'Sleet shower'),
('weatherConditions', 'Sleet', 'Sleet'),
('weatherConditions', 'Hail shower', 'Hail shower'),
('weatherConditions', 'Hail', 'Hail'),
('weatherConditions', 'Light snow', 'Light snow'),
('weatherConditions', 'Heavy snow', 'Heavy snow'),
('weatherConditions', 'Thunder shower', 'Thunder shower'),
('weatherConditions', 'Thunder', 'Thunder'),
('weatherConditions', 'Tropical storm', 'Tropical storm'),
('weatherConditions', 'Haze', 'Haze'),
('weatherConditions', 'No data', 'No data'),
-- export
('categories','weatherConditions','exported');


commit;