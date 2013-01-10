CREATE EXTENSION mysql_fdw;
CREATE SERVER silva_server FOREIGN DATA WRAPPER mysql_fdw OPTIONS (address 'silva-dev', port '3306');
CREATE USER MAPPING FOR PUBLIC SERVER silva_server OPTIONS (username 'mschneid', password 'asdf');
CREATE SCHEMA silva_r113_ssu_web;


CREATE TABLE silva_r113_ssu_web.Publication (
  seqent_id INT  ,
  primaryAccession TEXT ,
  authors TEXT ,
  comment TEXT ,
  info TEXT ,
  position TEXT ,
  refs TEXT ,
  title TEXT );


CREATE TABLE silva_r113_ssu_web.PublicationRefs (
  seqent_id INT ,
  reftype TEXT ,
  refvalue TEXT );


CREATE TABLE silva_r113_ssu_web.Region (
  seqent_id INT  ,
  isRef INT  ,
  isRefNR INT  ,
  isLTP INT  ,
  primaryAccession TEXT ,
  start INT  ,
  stop INT  ,
  alignedStart INT  ,
  alignedStop INT  ,
  alignmentDate timestamp  ,
  alignmentFamAvg float  ,
  alignmentFamMax float  ,
  alignmentFamSize smallINT  ,
  alignmentFilter TEXT  ,
  alignmentIdentity FLOAT  ,
  alignmentLog TEXT  ,
  alignmentQuality FLOAT  ,
  alignmentStatus TEXT  ,
  alignmentReference TEXT   ,
  BPScore INT   ,
  annotationSource TEXT  ,
  complement TEXT ,
  contaminationVector smallINT  ,
  countRepetative smallINT  ,
  cutoffHead INT   ,
  cutoffTail INT   ,
  description TEXT  ,
  geneName TEXT  ,
  joins text ,
  msaName TEXT ,
  percentAligned decimal(18,2) ,
  percentAmbiguity FLOAT  ,
  percentRepetative FLOAT  ,
  percentVector FLOAT   ,
  pintailScore smallINT  ,
  pintailTests smallINT  ,
  pintailQuality decimal(11,2) ,
  product TEXT  ,
  quality FLOAT ,
  refs TEXT ,
  regionLength INT   ,
  repetativeEvents smallINT  ,
  revComp TEXT   ,
  searchReferences TEXT   ,
  startFlag INT  ,
  stopFlag INT  ,
  type TEXT  ,
  crc TEXT );


CREATE TABLE silva_r113_ssu_web.Seq2Tag (
  seqent_id INT ,
  tag_id INT  );


CREATE TABLE silva_r113_ssu_web.SequenceEntry (
  seqent_id INT ,
  primaryAccession TEXT ,
  accessions TEXT,
  alternativeName TEXT ,
  bioMaterial TEXT ,
  circular TEXT ,
  clone text,
  cloneLib text,
  collectionDate TEXT ,
  collector text,
  country text,
  cultureCollection text,
  dataClass TEXT ,
  dataSource TEXT ,
  dateImported timestamp NULL ,
  dateModified date ,
  dateSubmitted date ,
  depth TEXT ,
  description TEXT ,
  division TEXT ,
  embl_class TEXT ,
  embl_division TEXT ,
  envSample text,
  flags TEXT  ,
  filename TEXT ,
  haplotype text,
  habitat TEXT ,
  identifiedBy text,
  insdc INT ,
  isolate text,
  isolationSource text,
  keywords TEXT ,
  labHost text,
  latLong text,
  sequenceLength INT ,
  molecularType TEXT ,
  namesHist TEXT,
  organelle TEXT ,
  organismName TEXT ,
  pcrPrimers TEXT ,
  plasmidName text,
  refs TEXT,
  sequenceVersion smallINT ,
  specificHost text,
  specimenVoucher text,
  strain TEXT,
  strainID INT ,
  subSpecies text,
  taxonomy TEXT ,
  numRegions bigINT  );


CREATE TABLE silva_r113_ssu_web.Tags (
  tag_id INT  ,
  tag_text TEXT );


CREATE TABLE silva_r113_ssu_web.aligned_sequence (
  primaryAccession TEXT  ,
  start INT  ,
  stop INT  ,
  alignedSequence TEXT);


CREATE TABLE silva_r113_ssu_web.basemapping (
  reference TEXT  ,
  refbase INT ,
  alignedbase INT );


CREATE TABLE silva_r113_ssu_web.cart_entries (
  cart_id INT ,
  seqent_id INT );


CREATE TABLE silva_r113_ssu_web.cart_list (
  cart_id INT ,
  updated timestamp  ,
  ses_id TEXT );


CREATE TABLE silva_r113_ssu_web.cart_tax (
  cart_id INT  ,
  node_id INT  ,
  selected INT  );


CREATE TABLE silva_r113_ssu_web.sequence (
  primaryAccession TEXT  ,
  crc TEXT  ,
  sequence TEXT,
  sequenceVersion smallINT );


CREATE TABLE silva_r113_ssu_web.tax_leaf (
  seqent_id INT  ,
  node_id INT  );


CREATE TABLE silva_r113_ssu_web.tax_node (
  node_id INT  ,
  tax_id INT  ,
  lft INT ,
  rgt INT ,
  lvl INT ,
  accs INT ,
  node_name TEXT );


CREATE TABLE silva_r113_ssu_web.tax_tree (
  tax_id INT ,
  tax_name TEXT ,
  tax_fullname TEXT ,
  listorder INT );


CREATE TABLE silva_r113_ssu_web.taxmap (
  seqent_id INT  ,
  node_id INT  ,
  primaryAccession TEXT ,
  organismName TEXT ,
  path TEXT ,
  taxname TEXT );


CREATE TABLE silva_r113_ssu_web.taxonomy (
  node_id INT ,
  fpath TEXT ,
  node_name TEXT ,
  path TEXT ,
  taxname TEXT );




CREATE FOREIGN TABLE silva_r113_ssu_web.Publication_f (
  seqent_id INT  ,
  primaryAccession TEXT ,
  authors TEXT ,
  comment TEXT ,
  info TEXT ,
  position TEXT ,
  refs TEXT ,
  title TEXT ) SERVER silva_server OPTIONS (table 'silva_r113_ssu_web.Publication');

INSERT INTO silva_r113_ssu_web.Publication SELECT * FROM silva_r113_ssu_web.Publication_f;
DROP FOREIGN TABLE silva_r113_ssu_web.Publication_f;

CREATE FOREIGN TABLE silva_r113_ssu_web.PublicationRefs_f (
  seqent_id INT ,
  reftype TEXT ,
  refvalue TEXT ) SERVER silva_server OPTIONS (table 'silva_r113_ssu_web.PublicationRefs');

INSERT INTO silva_r113_ssu_web.PublicationRefs SELECT * FROM silva_r113_ssu_web.PublicationRefs_f;
DROP FOREIGN TABLE silva_r113_ssu_web.PublicationRefs_f;

CREATE FOREIGN TABLE silva_r113_ssu_web.Region_f (
  seqent_id INT  ,
  isRef INT  ,
  isRefNR INT  ,
  isLTP INT  ,
  primaryAccession TEXT ,
  start INT  ,
  stop INT  ,
  alignedStart INT  ,
  alignedStop INT  ,
  alignmentDate timestamp  ,
  alignmentFamAvg float  ,
  alignmentFamMax float  ,
  alignmentFamSize smallINT  ,
  alignmentFilter TEXT  ,
  alignmentIdentity FLOAT  ,
  alignmentLog TEXT  ,
  alignmentQuality FLOAT  ,
  alignmentStatus TEXT  ,
  alignmentReference TEXT   ,
  BPScore INT   ,
  annotationSource TEXT  ,
  complement TEXT ,
  contaminationVector smallINT  ,
  countRepetative smallINT  ,
  cutoffHead INT   ,
  cutoffTail INT   ,
  description TEXT  ,
  geneName TEXT  ,
  joins text ,
  msaName TEXT ,
  percentAligned decimal(18,2) ,
  percentAmbiguity FLOAT  ,
  percentRepetative FLOAT  ,
  percentVector FLOAT   ,
  pintailScore smallINT  ,
  pintailTests smallINT  ,
  pintailQuality decimal(11,2) ,
  product TEXT  ,
  quality FLOAT ,
  refs TEXT ,
  regionLength INT   ,
  repetativeEvents smallINT  ,
  revComp TEXT   ,
  searchReferences TEXT   ,
  startFlag INT  ,
  stopFlag INT  ,
  type TEXT  ,
  crc TEXT ) SERVER silva_server OPTIONS (table 'silva_r113_ssu_web.Region');

INSERT INTO silva_r113_ssu_web.Region SELECT * FROM silva_r113_ssu_web.Region_f;
DROP FOREIGN TABLE silva_r113_ssu_web.Region_f;

CREATE FOREIGN TABLE silva_r113_ssu_web.Seq2Tag_f (
  seqent_id INT ,
  tag_id INT  ) SERVER silva_server OPTIONS (table 'silva_r113_ssu_web.Seq2Tag');

INSERT INTO silva_r113_ssu_web.Seq2Tag SELECT * FROM silva_r113_ssu_web.Seq2Tag_f;
DROP FOREIGN TABLE silva_r113_ssu_web.Seq2Tag_f;

CREATE FOREIGN TABLE silva_r113_ssu_web.SequenceEntry_f (
  seqent_id INT ,
  primaryAccession TEXT ,
  accessions TEXT,
  alternativeName TEXT ,
  bioMaterial TEXT ,
  circular TEXT ,
  clone text,
  cloneLib text,
  collectionDate TEXT ,
  collector text,
  country text,
  cultureCollection text,
  dataClass TEXT ,
  dataSource TEXT ,
  dateImported timestamp NULL ,
  dateModified date ,
  dateSubmitted date ,
  depth TEXT ,
  description TEXT ,
  division TEXT ,
  embl_class TEXT ,
  embl_division TEXT ,
  envSample text,
  flags TEXT  ,
  filename TEXT ,
  haplotype text,
  habitat TEXT ,
  identifiedBy text,
  insdc INT ,
  isolate text,
  isolationSource text,
  keywords TEXT ,
  labHost text,
  latLong text,
  sequenceLength INT ,
  molecularType TEXT ,
  namesHist TEXT,
  organelle TEXT ,
  organismName TEXT ,
  pcrPrimers TEXT ,
  plasmidName text,
  refs TEXT,
  sequenceVersion smallINT ,
  specificHost text,
  specimenVoucher text,
  strain TEXT,
  strainID INT ,
  subSpecies text,
  taxonomy TEXT ,
  numRegions bigINT  ) SERVER silva_server OPTIONS (table 'silva_r113_ssu_web.SequenceEntry');

INSERT INTO silva_r113_ssu_web.SequenceEntry SELECT * FROM silva_r113_ssu_web.SequenceEntry_f;
DROP FOREIGN TABLE silva_r113_ssu_web.SequenceEntry_f;

CREATE FOREIGN TABLE silva_r113_ssu_web.Tags_f (
  tag_id INT  ,
  tag_text TEXT ) SERVER silva_server OPTIONS (table 'silva_r113_ssu_web.Tags');

INSERT INTO silva_r113_ssu_web.Tags SELECT * FROM silva_r113_ssu_web.Tags_f;
DROP FOREIGN TABLE silva_r113_ssu_web.Tags_f;

CREATE FOREIGN TABLE silva_r113_ssu_web.aligned_sequence_f (
  primaryAccession TEXT  ,
  start INT  ,
  stop INT  ,
  alignedSequence TEXT) SERVER silva_server OPTIONS (query 'SELECT primaryAccession,start,stop,uncompress(alignedSequence) FROM silva_r113_ssu_web.aligned_sequence');

INSERT INTO silva_r113_ssu_web.aligned_sequence SELECT * FROM silva_r113_ssu_web.aligned_sequence_f;
DROP FOREIGN TABLE silva_r113_ssu_web.aligned_sequence_f;

CREATE FOREIGN TABLE silva_r113_ssu_web.basemapping_f (
  reference TEXT  ,
  refbase INT ,
  alignedbase INT ) SERVER silva_server OPTIONS (table 'silva_r113_ssu_web.basemapping');

INSERT INTO silva_r113_ssu_web.basemapping SELECT * FROM silva_r113_ssu_web.basemapping_f;
DROP FOREIGN TABLE silva_r113_ssu_web.basemapping_f;

CREATE FOREIGN TABLE silva_r113_ssu_web.cart_entries_f (
  cart_id INT ,
  seqent_id INT ) SERVER silva_server OPTIONS (table 'silva_r113_ssu_web.cart_entries');

INSERT INTO silva_r113_ssu_web.cart_entries SELECT * FROM silva_r113_ssu_web.cart_entries_f;
DROP FOREIGN TABLE silva_r113_ssu_web.cart_entries_f;

CREATE FOREIGN TABLE silva_r113_ssu_web.cart_list_f (
  cart_id INT ,
  updated timestamp  ,
  ses_id TEXT ) SERVER silva_server OPTIONS (table 'silva_r113_ssu_web.cart_list');

INSERT INTO silva_r113_ssu_web.cart_list SELECT * FROM silva_r113_ssu_web.cart_list_f;
DROP FOREIGN TABLE silva_r113_ssu_web.cart_list_f;

CREATE FOREIGN TABLE silva_r113_ssu_web.cart_tax_f (
  cart_id INT  ,
  node_id INT  ,
  selected INT  ) SERVER silva_server OPTIONS (table 'silva_r113_ssu_web.cart_tax');

INSERT INTO silva_r113_ssu_web.cart_tax SELECT * FROM silva_r113_ssu_web.cart_tax_f;
DROP FOREIGN TABLE silva_r113_ssu_web.cart_tax_f;

CREATE FOREIGN TABLE silva_r113_ssu_web.sequence_f (
  primaryAccession TEXT  ,
  crc TEXT  ,
  sequence TEXT,
  sequenceVersion smallINT ) SERVER silva_server OPTIONS (query 'SELECT primaryAccession,crc,uncompress(sequence),sequenceVersion FROM silva_r113_ssu_web.sequence');

INSERT INTO silva_r113_ssu_web.sequence SELECT * FROM silva_r113_ssu_web.sequence_f;
DROP FOREIGN TABLE silva_r113_ssu_web.sequence_f;

CREATE FOREIGN TABLE silva_r113_ssu_web.tax_leaf_f (
  seqent_id INT  ,
  node_id INT  ) SERVER silva_server OPTIONS (table 'silva_r113_ssu_web.tax_leaf');

INSERT INTO silva_r113_ssu_web.tax_leaf SELECT * FROM silva_r113_ssu_web.tax_leaf_f;
DROP FOREIGN TABLE silva_r113_ssu_web.tax_leaf_f;

CREATE FOREIGN TABLE silva_r113_ssu_web.tax_node_f (
  node_id INT  ,
  tax_id INT  ,
  lft INT ,
  rgt INT ,
  lvl INT ,
  accs INT ,
  node_name TEXT ) SERVER silva_server OPTIONS (table 'silva_r113_ssu_web.tax_node');

INSERT INTO silva_r113_ssu_web.tax_node SELECT * FROM silva_r113_ssu_web.tax_node_f;
DROP FOREIGN TABLE silva_r113_ssu_web.tax_node_f;

CREATE FOREIGN TABLE silva_r113_ssu_web.tax_tree_f (
  tax_id INT ,
  tax_name TEXT ,
  tax_fullname TEXT ,
  listorder INT ) SERVER silva_server OPTIONS (table 'silva_r113_ssu_web.tax_tree');

INSERT INTO silva_r113_ssu_web.tax_tree SELECT * FROM silva_r113_ssu_web.tax_tree_f;
DROP FOREIGN TABLE silva_r113_ssu_web.tax_tree_f;

CREATE FOREIGN TABLE silva_r113_ssu_web.taxmap_f (
  seqent_id INT  ,
  node_id INT  ,
  primaryAccession TEXT ,
  organismName TEXT ,
  path TEXT ,
  taxname TEXT ) SERVER silva_server OPTIONS (table 'silva_r113_ssu_web.taxmap');

INSERT INTO silva_r113_ssu_web.taxmap SELECT * FROM silva_r113_ssu_web.taxmap_f;
DROP FOREIGN TABLE silva_r113_ssu_web.taxmap_f;

CREATE FOREIGN TABLE silva_r113_ssu_web.taxonomy_f (
  node_id INT ,
  fpath TEXT ,
  node_name TEXT ,
  path TEXT ,
  taxname TEXT ) SERVER silva_server OPTIONS (table 'silva_r113_ssu_web.taxonomy');

INSERT INTO silva_r113_ssu_web.taxonomy SELECT * FROM silva_r113_ssu_web.taxonomy_f;
DROP FOREIGN TABLE silva_r113_ssu_web.taxonomy_f;

CREATE SCHEMA silva_r113_lsu_web;


CREATE TABLE silva_r113_lsu_web.Publication (
  seqent_id INT  ,
  primaryAccession TEXT ,
  authors TEXT ,
  comment TEXT ,
  info TEXT ,
  position TEXT ,
  refs TEXT ,
  title TEXT );


CREATE TABLE silva_r113_lsu_web.PublicationRefs (
  seqent_id INT ,
  reftype TEXT ,
  refvalue TEXT );


CREATE TABLE silva_r113_lsu_web.Region (
  seqent_id INT  ,
  isRef INT  ,
  isRefNR INT  ,
  isLTP INT  ,
  primaryAccession TEXT ,
  start INT  ,
  stop INT  ,
  alignedStart INT  ,
  alignedStop INT  ,
  alignmentDate timestamp  ,
  alignmentFamAvg float  ,
  alignmentFamMax float  ,
  alignmentFamSize smallINT  ,
  alignmentFilter TEXT  ,
  alignmentIdentity FLOAT  ,
  alignmentLog TEXT  ,
  alignmentQuality FLOAT  ,
  alignmentStatus TEXT  ,
  alignmentReference TEXT   ,
  BPScore INT   ,
  annotationSource TEXT  ,
  complement TEXT ,
  contaminationVector smallINT  ,
  countRepetative smallINT  ,
  cutoffHead INT   ,
  cutoffTail INT   ,
  description TEXT  ,
  geneName TEXT  ,
  joins text ,
  msaName TEXT ,
  percentAligned decimal(18,2) ,
  percentAmbiguity FLOAT  ,
  percentRepetative FLOAT  ,
  percentVector FLOAT   ,
  pintailScore smallINT  ,
  pintailTests smallINT  ,
  pintailQuality decimal(11,2) ,
  product TEXT  ,
  quality FLOAT ,
  refs TEXT ,
  regionLength INT   ,
  repetativeEvents smallINT  ,
  revComp TEXT   ,
  searchReferences TEXT   ,
  startFlag INT  ,
  stopFlag INT  ,
  type TEXT  ,
  crc TEXT );


CREATE TABLE silva_r113_lsu_web.Seq2Tag (
  seqent_id INT ,
  tag_id INT  );


CREATE TABLE silva_r113_lsu_web.SequenceEntry (
  seqent_id INT ,
  primaryAccession TEXT ,
  accessions TEXT,
  alternativeName TEXT ,
  bioMaterial TEXT ,
  circular TEXT ,
  clone text,
  cloneLib text,
  collectionDate TEXT ,
  collector text,
  country text,
  cultureCollection text,
  dataClass TEXT ,
  dataSource TEXT ,
  dateImported timestamp NULL ,
  dateModified date ,
  dateSubmitted date ,
  depth TEXT ,
  description TEXT ,
  division TEXT ,
  embl_class TEXT ,
  embl_division TEXT ,
  envSample text,
  flags TEXT  ,
  filename TEXT ,
  haplotype text,
  habitat TEXT ,
  identifiedBy text,
  insdc INT ,
  isolate text,
  isolationSource text,
  keywords TEXT ,
  labHost text,
  latLong text,
  sequenceLength INT ,
  molecularType TEXT ,
  namesHist TEXT,
  organelle TEXT ,
  organismName TEXT ,
  pcrPrimers TEXT ,
  plasmidName text,
  refs TEXT,
  sequenceVersion smallINT ,
  specificHost text,
  specimenVoucher text,
  strain TEXT,
  strainID INT ,
  subSpecies text,
  taxonomy TEXT ,
  numRegions bigINT  );


CREATE TABLE silva_r113_lsu_web.Tags (
  tag_id INT  ,
  tag_text TEXT );


CREATE TABLE silva_r113_lsu_web.aligned_sequence (
  primaryAccession TEXT  ,
  start INT  ,
  stop INT  ,
  alignedSequence TEXT);


CREATE TABLE silva_r113_lsu_web.basemapping (
  reference TEXT  ,
  refbase INT ,
  alignedbase INT );


CREATE TABLE silva_r113_lsu_web.cart_entries (
  cart_id INT ,
  seqent_id INT );


CREATE TABLE silva_r113_lsu_web.cart_list (
  cart_id INT ,
  updated timestamp  ,
  ses_id TEXT );


CREATE TABLE silva_r113_lsu_web.cart_tax (
  cart_id INT  ,
  node_id INT  ,
  selected INT  );


CREATE TABLE silva_r113_lsu_web.sequence (
  primaryAccession TEXT  ,
  crc TEXT  ,
  sequence TEXT,
  sequenceVersion smallINT );


CREATE TABLE silva_r113_lsu_web.tax_leaf (
  seqent_id INT  ,
  node_id INT  );


CREATE TABLE silva_r113_lsu_web.tax_node (
  node_id INT  ,
  tax_id INT  ,
  lft INT ,
  rgt INT ,
  lvl INT ,
  accs INT ,
  node_name TEXT );


CREATE TABLE silva_r113_lsu_web.tax_tree (
  tax_id INT ,
  tax_name TEXT ,
  tax_fullname TEXT ,
  listorder INT );


CREATE TABLE silva_r113_lsu_web.taxmap (
  seqent_id INT  ,
  node_id INT  ,
  primaryAccession TEXT ,
  organismName TEXT ,
  path TEXT ,
  taxname TEXT );


CREATE TABLE silva_r113_lsu_web.taxonomy (
  node_id INT ,
  fpath TEXT ,
  node_name TEXT ,
  path TEXT ,
  taxname TEXT );




CREATE FOREIGN TABLE silva_r113_lsu_web.Publication_f (
  seqent_id INT  ,
  primaryAccession TEXT ,
  authors TEXT ,
  comment TEXT ,
  info TEXT ,
  position TEXT ,
  refs TEXT ,
  title TEXT ) SERVER silva_server OPTIONS (table 'silva_r113_lsu_web.Publication');

INSERT INTO silva_r113_lsu_web.Publication SELECT * FROM silva_r113_lsu_web.Publication_f;
DROP FOREIGN TABLE silva_r113_lsu_web.Publication_f;

CREATE FOREIGN TABLE silva_r113_lsu_web.PublicationRefs_f (
  seqent_id INT ,
  reftype TEXT ,
  refvalue TEXT ) SERVER silva_server OPTIONS (table 'silva_r113_lsu_web.PublicationRefs');

INSERT INTO silva_r113_lsu_web.PublicationRefs SELECT * FROM silva_r113_lsu_web.PublicationRefs_f;
DROP FOREIGN TABLE silva_r113_lsu_web.PublicationRefs_f;

CREATE FOREIGN TABLE silva_r113_lsu_web.Region_f (
  seqent_id INT  ,
  isRef INT  ,
  isRefNR INT  ,
  isLTP INT  ,
  primaryAccession TEXT ,
  start INT  ,
  stop INT  ,
  alignedStart INT  ,
  alignedStop INT  ,
  alignmentDate timestamp  ,
  alignmentFamAvg float  ,
  alignmentFamMax float  ,
  alignmentFamSize smallINT  ,
  alignmentFilter TEXT  ,
  alignmentIdentity FLOAT  ,
  alignmentLog TEXT  ,
  alignmentQuality FLOAT  ,
  alignmentStatus TEXT  ,
  alignmentReference TEXT   ,
  BPScore INT   ,
  annotationSource TEXT  ,
  complement TEXT ,
  contaminationVector smallINT  ,
  countRepetative smallINT  ,
  cutoffHead INT   ,
  cutoffTail INT   ,
  description TEXT  ,
  geneName TEXT  ,
  joins text ,
  msaName TEXT ,
  percentAligned decimal(18,2) ,
  percentAmbiguity FLOAT  ,
  percentRepetative FLOAT  ,
  percentVector FLOAT   ,
  pintailScore smallINT  ,
  pintailTests smallINT  ,
  pintailQuality decimal(11,2) ,
  product TEXT  ,
  quality FLOAT ,
  refs TEXT ,
  regionLength INT   ,
  repetativeEvents smallINT  ,
  revComp TEXT   ,
  searchReferences TEXT   ,
  startFlag INT  ,
  stopFlag INT  ,
  type TEXT  ,
  crc TEXT ) SERVER silva_server OPTIONS (table 'silva_r113_lsu_web.Region');

INSERT INTO silva_r113_lsu_web.Region SELECT * FROM silva_r113_lsu_web.Region_f;
DROP FOREIGN TABLE silva_r113_lsu_web.Region_f;

CREATE FOREIGN TABLE silva_r113_lsu_web.Seq2Tag_f (
  seqent_id INT ,
  tag_id INT  ) SERVER silva_server OPTIONS (table 'silva_r113_lsu_web.Seq2Tag');

INSERT INTO silva_r113_lsu_web.Seq2Tag SELECT * FROM silva_r113_lsu_web.Seq2Tag_f;
DROP FOREIGN TABLE silva_r113_lsu_web.Seq2Tag_f;

CREATE FOREIGN TABLE silva_r113_lsu_web.SequenceEntry_f (
  seqent_id INT ,
  primaryAccession TEXT ,
  accessions TEXT,
  alternativeName TEXT ,
  bioMaterial TEXT ,
  circular TEXT ,
  clone text,
  cloneLib text,
  collectionDate TEXT ,
  collector text,
  country text,
  cultureCollection text,
  dataClass TEXT ,
  dataSource TEXT ,
  dateImported timestamp NULL ,
  dateModified date ,
  dateSubmitted date ,
  depth TEXT ,
  description TEXT ,
  division TEXT ,
  embl_class TEXT ,
  embl_division TEXT ,
  envSample text,
  flags TEXT  ,
  filename TEXT ,
  haplotype text,
  habitat TEXT ,
  identifiedBy text,
  insdc INT ,
  isolate text,
  isolationSource text,
  keywords TEXT ,
  labHost text,
  latLong text,
  sequenceLength INT ,
  molecularType TEXT ,
  namesHist TEXT,
  organelle TEXT ,
  organismName TEXT ,
  pcrPrimers TEXT ,
  plasmidName text,
  refs TEXT,
  sequenceVersion smallINT ,
  specificHost text,
  specimenVoucher text,
  strain TEXT,
  strainID INT ,
  subSpecies text,
  taxonomy TEXT ,
  numRegions bigINT  ) SERVER silva_server OPTIONS (table 'silva_r113_lsu_web.SequenceEntry');

INSERT INTO silva_r113_lsu_web.SequenceEntry SELECT * FROM silva_r113_lsu_web.SequenceEntry_f;
DROP FOREIGN TABLE silva_r113_lsu_web.SequenceEntry_f;

CREATE FOREIGN TABLE silva_r113_lsu_web.Tags_f (
  tag_id INT  ,
  tag_text TEXT ) SERVER silva_server OPTIONS (table 'silva_r113_lsu_web.Tags');

INSERT INTO silva_r113_lsu_web.Tags SELECT * FROM silva_r113_lsu_web.Tags_f;
DROP FOREIGN TABLE silva_r113_lsu_web.Tags_f;

CREATE FOREIGN TABLE silva_r113_lsu_web.aligned_sequence_f (
  primaryAccession TEXT  ,
  start INT  ,
  stop INT  ,
  alignedSequence TEXT) SERVER silva_server OPTIONS (query 'SELECT primaryAccession,start,stop,uncompress(alignedSequence) FROM silva_r113_lsu_web.aligned_sequence');

INSERT INTO silva_r113_lsu_web.aligned_sequence SELECT * FROM silva_r113_lsu_web.aligned_sequence_f;
DROP FOREIGN TABLE silva_r113_lsu_web.aligned_sequence_f;

CREATE FOREIGN TABLE silva_r113_lsu_web.basemapping_f (
  reference TEXT  ,
  refbase INT ,
  alignedbase INT ) SERVER silva_server OPTIONS (table 'silva_r113_lsu_web.basemapping');

INSERT INTO silva_r113_lsu_web.basemapping SELECT * FROM silva_r113_lsu_web.basemapping_f;
DROP FOREIGN TABLE silva_r113_lsu_web.basemapping_f;

CREATE FOREIGN TABLE silva_r113_lsu_web.cart_entries_f (
  cart_id INT ,
  seqent_id INT ) SERVER silva_server OPTIONS (table 'silva_r113_lsu_web.cart_entries');

INSERT INTO silva_r113_lsu_web.cart_entries SELECT * FROM silva_r113_lsu_web.cart_entries_f;
DROP FOREIGN TABLE silva_r113_lsu_web.cart_entries_f;

CREATE FOREIGN TABLE silva_r113_lsu_web.cart_list_f (
  cart_id INT ,
  updated timestamp  ,
  ses_id TEXT ) SERVER silva_server OPTIONS (table 'silva_r113_lsu_web.cart_list');

INSERT INTO silva_r113_lsu_web.cart_list SELECT * FROM silva_r113_lsu_web.cart_list_f;
DROP FOREIGN TABLE silva_r113_lsu_web.cart_list_f;

CREATE FOREIGN TABLE silva_r113_lsu_web.cart_tax_f (
  cart_id INT  ,
  node_id INT  ,
  selected INT  ) SERVER silva_server OPTIONS (table 'silva_r113_lsu_web.cart_tax');

INSERT INTO silva_r113_lsu_web.cart_tax SELECT * FROM silva_r113_lsu_web.cart_tax_f;
DROP FOREIGN TABLE silva_r113_lsu_web.cart_tax_f;

CREATE FOREIGN TABLE silva_r113_lsu_web.sequence_f (
  primaryAccession TEXT  ,
  crc TEXT  ,
  sequence TEXT,
  sequenceVersion smallINT ) SERVER silva_server OPTIONS (query 'SELECT primaryAccession,crc,uncompress(sequence),sequenceVersion FROM silva_r113_lsu_web.sequence');

INSERT INTO silva_r113_lsu_web.sequence SELECT * FROM silva_r113_lsu_web.sequence_f;
DROP FOREIGN TABLE silva_r113_lsu_web.sequence_f;

CREATE FOREIGN TABLE silva_r113_lsu_web.tax_leaf_f (
  seqent_id INT  ,
  node_id INT  ) SERVER silva_server OPTIONS (table 'silva_r113_lsu_web.tax_leaf');

INSERT INTO silva_r113_lsu_web.tax_leaf SELECT * FROM silva_r113_lsu_web.tax_leaf_f;
DROP FOREIGN TABLE silva_r113_lsu_web.tax_leaf_f;

CREATE FOREIGN TABLE silva_r113_lsu_web.tax_node_f (
  node_id INT  ,
  tax_id INT  ,
  lft INT ,
  rgt INT ,
  lvl INT ,
  accs INT ,
  node_name TEXT ) SERVER silva_server OPTIONS (table 'silva_r113_lsu_web.tax_node');

INSERT INTO silva_r113_lsu_web.tax_node SELECT * FROM silva_r113_lsu_web.tax_node_f;
DROP FOREIGN TABLE silva_r113_lsu_web.tax_node_f;

CREATE FOREIGN TABLE silva_r113_lsu_web.tax_tree_f (
  tax_id INT ,
  tax_name TEXT ,
  tax_fullname TEXT ,
  listorder INT ) SERVER silva_server OPTIONS (table 'silva_r113_lsu_web.tax_tree');

INSERT INTO silva_r113_lsu_web.tax_tree SELECT * FROM silva_r113_lsu_web.tax_tree_f;
DROP FOREIGN TABLE silva_r113_lsu_web.tax_tree_f;

CREATE FOREIGN TABLE silva_r113_lsu_web.taxmap_f (
  seqent_id INT  ,
  node_id INT  ,
  primaryAccession TEXT ,
  organismName TEXT ,
  path TEXT ,
  taxname TEXT ) SERVER silva_server OPTIONS (table 'silva_r113_lsu_web.taxmap');

INSERT INTO silva_r113_lsu_web.taxmap SELECT * FROM silva_r113_lsu_web.taxmap_f;
DROP FOREIGN TABLE silva_r113_lsu_web.taxmap_f;

CREATE FOREIGN TABLE silva_r113_lsu_web.taxonomy_f (
  node_id INT ,
  fpath TEXT ,
  node_name TEXT ,
  path TEXT ,
  taxname TEXT ) SERVER silva_server OPTIONS (table 'silva_r113_lsu_web.taxonomy');

INSERT INTO silva_r113_lsu_web.taxonomy SELECT * FROM silva_r113_lsu_web.taxonomy_f;
DROP FOREIGN TABLE silva_r113_lsu_web.taxonomy_f;

