
Begin;

create temp table lifewatch as 
     Select osd_id 
       from (VALUES 
       (123)
,(124)
,(132)
,(14)
,(141)
,(143)
,(146)
,(149)
,(150)
,(151)
,(152)
,(159)
,(2)
,(22)
,(3)
,(30)
,(37)
,(39)
,(43)
,(49)
,(54)
,(55)
,(6)
,(60)
,(71)
,(72)
,(76)
,(77)
,(80)
,(9)
,(99)
) as o(osd_id);

\echo all lifewatch we need

select * from lifewatch order by osd_id;

\echo which lifewatch are we missing?

select lifewatch.*, sam.osd_id from lifewatch 
  Left join osdregistry.samples sam 
    ON ( lifewatch.osd_id = sam.osd_id AND sam.protocol = 'NE08')
 where sam.submission_id is null
order by lifewatch.osd_id
 ;

\echo which lifewatch are we missing but have correwpsonding bacterial samples?

select lifewatch.*, sam.osd_id from lifewatch 
  Left join osdregistry.samples sam 
    ON ( lifewatch.osd_id = sam.osd_id AND sam.protocol = 'NE08')
  Left join osdregistry.samples proks 
    ON ( lifewatch.osd_id = proks.osd_id AND proks.protocol = 'NPL022')
 where sam.submission_id is null
order by lifewatch.osd_id
 ;

\echo which lifewatch do we have via form but not in samples table
select subs.osd_id, subs.submission_id
  from osdregistry.submission_overview subs 
  Left join osdregistry.samples sam 
    ON ( sam.submission_id = subs.submission_id )
 where sam.submission_id is null
   AND subs.sample_protocol = 'NE08' and subs.submission_id not in (270,271,277,275)
order by subs.osd_id ;
 ;

\echo  >> all NE08 already in DB

select osd_id from osdregistry.samples where protocol = 'NE08' and local_date between '2014-06-01' and '2014-08-01' order by osd_id;


select lifewatch.osd_id as lw_id, sam.osd_id, subs.osd_id as subs from lifewatch 
   left join osdregistry.samples sam 
    ON ( lifewatch.osd_id = sam.osd_id AND sam.protocol = 'NE08' )
    --where sam.submission_id is null or lifewatch.osd_id is null
  Left join osdregistry.submission_overview subs  
    ON ( lifewatch.osd_id = subs.osd_id 
   AND subs.sample_protocol = 'NE08' 
   and subs.submission_id not in (270,271,277,275))
    --ON ( lifewatch.osd_id = proks.osd_id AND proks.protocol = 'NPL022')
 
order by lifewatch.osd_id
 ;



 
 rollback;



 