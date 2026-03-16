options nocenter label missing=' ' pagesize=70 linesize=120;

%let prg_navn=ant_pr_maalte_aldret_kon_ind_brs_sil.sas;

%let path_repo = C:\Users\kibi\OneDrive - Danmarks Tekniske Universitet\2026_all_RDBES_DK;
%let awg = HAWG;
libname out "&path_repo.\&awg.\data\original_sas";
%let path_out = &path_repo.\&awg.\data\original_sas;

%let aar=%str(2025);

*libname spr '\\hfi01\sasdata\hawg\wg2007\data';
*libname spr '\\ch-fil01\sasdata\hawg\wg2009\data';

proc format;

value $om
'4','4a','4b','4c',
'4A','4B','4C'     = '4'
'20'               = 'lllaN'
'21'               = 'lllaS'
'22','23','24'     = '22-24'
'25','26','27','28','29','30','31','32' = '25-32'
'2a','2A'          = 'lla'
OTHER              = 'UU';
run;


proc sql;
connect to odbc (dsn='FishLineDW');
create table silbrs1 as
select *,
       datepart(rdsk_sat) as dato, qtr(datepart(rdsk_sat)) as kv,
	   round(lgd/10) as lgdcm,/*floor(lgd/5)/2 as lgdcm,*/ put(dfuarea,$om.) as area, round(weight*1000) as vgt,
       input(compress(substr(intsq,1,2)||put(rank(substr(intsq,3,1))-64,1.0)
                                        ||substr(intsq,4,1)),4.0) as n3sq,
       input(put(rank(substr(intsq,3,1))-64,1.0)||substr(intsq,4,1),4.0) as b,
       input(substr(intsq,1,2),2.0) as a
from connection to odbc
(SELECT     sp.[year] AS aar, sp.dateGearStart as rdsk_sat, sp.cruise AS togt, sp.trip AS tur, sp.tripType AS type, sp.station AS stat, sp.dfuArea, 
                      sp.statisticalRectangle AS intsq, sp.gearType AS rdsk, sp.meshSize AS maske, sp.speciesCode AS art, sp.landingCategory AS kat_db, 
                      sp.dfuBase_Category, sp.treatment AS bhgr, sp.raisingFactor AS gf, a.representative AS rep, a.length AS lgd, a.lengthMeasureUnit AS enh, 
                      a.number AS ant, a.weight, ag.length AS a_lgd, ag.age AS ald, ag.number AS aant
FROM         dbo.SpeciesList sp INNER JOIN
                      dbo.Animal a ON sp.speciesListId = a.speciesListId LEFT OUTER JOIN
                      dbo.Age ag ON a.animalId = ag.animalId
WHERE     (sp.[year]  in (&aar.)) AND (sp.speciesCode = N'sil' OR
                      sp.speciesCode = N'brs') AND (sp.cruise = N'in-hirt' OR
                      sp.cruise = N'in-lyng' OR  sp.cruise = N'in-3 part' OR 
					  sp.cruise = N'in-fisker' OR sp.cruise = N'tbm23' OR sp.cruise = N'tbm24' OR sp.cruise = N'tbm25' OR
					  sp.cruise = N'brs13' OR sp.cruise = N'brs14' OR 
					  sp.cruise = N'brs15' OR sp.cruise = N'brs16' OR sp.cruise = N'brs17' OR sp.cruise = N'brs18' OR sp.cruise = N'brs19' OR
					  sp.cruise = N'brs20' OR sp.cruise = N'brs21' OR sp.cruise = N'gudp-vind')
					  );
disconnect from odbc;
quit;
%put &sqlxmsg;
run;

data silbrs;
set silbrs1;
if aar=2017 and togt='GUDP-VIND' and stat in ('402','404','405') then delete;
run;

data sbr; set silbrs(where=(area ne 'UU'));
length kat $10.;

kat = kat_db;

if aar=2013 and stat='408' then do; a=49; b=61; intsq='49F1'; end;
if art='BRS' and kat='KON' then kat='IND';

if substr(area,1,1) in ('4') and kat='KON' then do;
  if 43<a<53 and 55<b<62 then area='4aw';
  if 43<a<53 and 61<b<68 then area='4ae';
  if 35<a<44 and 55<b<63 then area='4b';
  if 35<a<44 and 62<b<69 then area='4b';
  if 30<a<36 and 55<b<69 then area='4c ';
end;
else if substr(area,1,1) in ('4') and kat='IND' and art='SIL' then do;
  if 43<a<53 and 55<b<62 then area='4aw';
  if 43<a<53 and 61<b<67 then area='4ae';
  if 35<a<44 and 55<b<63 then area='4bw';
  if 35<a<44 and 62<b<69 then do;
       if          62<b<66 then area='4bew';
       else                     area='4bee';
  end;
  if 30<a<36 and 55<b<69 then area='4c ';
end;
else if substr(area,1,1) in ('4') and kat='IND' and art='BRS' then do;
  if 43<a<53 and 55<b<62 then area='4a';
  if 43<a<53 and 61<b<68 then area='4a';
  if 35<a<44 and 55<b<63 then area='4bw';
  if 35<a<44 and 62<b<69 then area='4be';
  if 30<a<36 and 55<b<69 then area='4c ';
end;

* 20240309 - in 2023 we have some samples from the 90-119 fishery. We have never sampled these fisheries for SIL KON - only discard;

run;

data sbr;
set sbr;


if kat='KON' and art='SIL' and maske >69 then kat = 'NEP';

if art = 'SIL' and dfuarea in ('20','21','22','23','24') then do;
	if rdsk in ('PS') then kat = 'PS';
	if rdsk in ('OTM','PTM','SSC','OTB','SDN') and 
		maske <32 then kat = 'Active<32';
	if rdsk in ('OTM','PTM','SSC','OTB','SDN') and 
		maske >=32 
			then kat = 'Active>=32';
	if rdsk in ('GNS','FPN') then kat = 'Passive';
end;

if dfuarea in ('25','26','27','28','29','30','31','32') and art='SIL' then do; kat='KONIND'; end;

run;
proc summary nway data=sbr missing;
where ald>. ;
class aar togt tur stat art kat;
id dato intsq kv area dfuarea;
var aant;
output out=aford(drop=_type_ _freq_) sum=aldret; 
proc summary nway data=sbr missing;
where rep='ja';
class aar togt tur stat art kat;
id dato intsq kv area dfuarea rep;
var ant;
output out=mford(drop=_type_ _freq_) sum=maalt; 

proc sort data=aford; by aar togt tur stat art kat;
proc sort data=mford; by aar togt tur stat art kat;

data tford; merge mford(in=aa) aford(in=bb); by aar togt tur stat art kat;
pr=1;

proc summary nway data=sbr;
where ald>. ;
class aar togt tur stat art kat;
id dato intsq kv area dfuarea rdsk maske;
var aant;
output out=aford(drop=_type_ _freq_) sum=aldret; 
proc summary nway data=sbr;
where rep='ja';
class aar togt tur stat art kat;
id dato intsq kv area dfuarea rdsk maske rep;
var ant;
output out=mford(drop=_type_ _freq_) sum=maalt; 

proc sort data=aford; by aar togt tur stat art kat;
proc sort data=mford; by aar togt tur stat art kat;

data tford; merge mford(in=aa) aford(in=bb); by aar togt tur stat art kat;
pr=1;

PROC EXPORT DATA= tford
            OUTFILE= "&path_out.\bio_statistik_sil_brs_per_sample_&aar._&sysdate..csv" 
            DBMS=CSV LABEL REPLACE;
RUN;
