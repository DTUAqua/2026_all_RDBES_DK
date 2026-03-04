options nocenter label missing=' ' pagesize=70 linesize=120;

%let prg_navn=indl_biologi.sas;

libname spr 'Q:\mynd\Assessement_discard_and_the_like\WG\HAWG\wg2024\HAWGOutput\SASData';

%let aar=2023;

proc format;
value $om
'4','4a','4b','4c',
'4A','4B','4C'     = '4'
'20'               = '3an'
'21'               = '3as'
'22'			   = '22'
'23'			   = '23'
'24'               = '24'
'25'			   = '25'
'26'			   = '26'
'27'			   = '27'
'28'			   = '28'
'29'			   = '29'
'2a','2A'          = 'lla'
OTHER              = 'UUUUU';
run;

proc sql;
connect to odbc (dsn='FishLineDW');
create table silbrs1 as
select *,
       datepart(rdsk_sat) as dato, qtr(datepart(rdsk_sat)) as kv,
	   floor(lgd/10) as lgdcm,/*floor(lgd/5)/2 as lgdcm,*/ put(dfuarea,$om.) as area, round(weight*1000) as vgt,
       input(compress(substr(intsq,1,2)||put(rank(substr(intsq,3,1))-64,1.0)
                                        ||substr(intsq,4,1)),4.0) as n3sq,
       input(put(rank(substr(intsq,3,1))-64,1.0)||substr(intsq,4,1),4.0) as b,
       input(substr(intsq,1,2),2.0) as a
from connection to odbc
(SELECT     sampleid, sp.[year] AS aar, sp.dateGearStart as rdsk_sat, sp.cruise AS togt, sp.trip AS tur, sp.tripType AS type, sp.station AS stat, sp.dfuArea, 
                      sp.statisticalRectangle AS intsq, sp.gearType AS rdsk, sp.meshSize AS maske, sp.speciesCode AS art, sp.landingCategory AS kat0, 
                      sp.dfuBase_Category, sp.treatment AS bhgr, sp.raisingFactor AS gf, a.representative AS rep, a.length AS lgd, a.lengthMeasureUnit AS enh, 
                      a.number AS ant, a.weight, ag.length AS a_lgd, ag.age AS ald, ag.number AS aant, ag.otolithReadingRemark
FROM         dbo.SpeciesList sp INNER JOIN
                      dbo.Animal a ON sp.speciesListId = a.speciesListId LEFT OUTER JOIN
                      dbo.Age ag ON a.animalId = ag.animalId
WHERE     (sp.[year] =&aar) AND (sp.speciesCode = N'sil' OR
                      sp.speciesCode = N'brs') AND (sp.cruise = N'in-hirt' OR sp.cruise = N'in-3 part' OR sp.cruise = N'in-fisker' OR
                      sp.cruise = N'in-lyng' OR sp.cruise = N'brs20' OR sp.cruise = N'gudp-vind' OR sp.cruise = N'sil20' OR sp.cruise = N'spe20')
					  );
disconnect from odbc;
quit;
%put &sqlxmsg;
run;

data silbrs;
set silbrs1;
if ald>70 then ald=.;
if otolithReadingRemark = 'D' then ald = .;
if aar=2017 and togt='GUDP-VIND' and stat in ('402','404','405') then delete;
run;

data sbr; set silbrs(where=(area ne 'UUUUU'));
length kat area $10.;

if aar=2010 and stat in ('1342','1343','1346','1347') and ald>6 then delete;
if aar=2019 and togt = 'IN-LYNG' and stat in ('630') then delete; *from a gillnetter - don't fit the fishery;
if weight=' ' then delete;

if aar = 2022 and stat in ('1410', '1411', '1412', '1413', '1414', '1415') then kat0 = 'KON';

kat=kat0;
if dfuarea in ('22','23','24','25','26','27','28','29','30','31','32') and art='SIL' then do; kat='KONIND'; area=dfuarea; end;

if kat = 'KONIND' and dfuarea in ('22','23','24') then do;
	if rdsk in ('OTM','PTM') then kat = 'Active';
	if rdsk in ('GNS') then kat = 'Passive';
	if rdsk in ('FPN') then kat = 'Passive';
end;

if art='BRS' and kat='KON' then kat='IND';


if substr(area,1,1) in ('4') and kat='KON' and art='SIL' then do;
  if 43<a<53 and 55<b<62 then area='4aw';
  if 43<a<53 and 61<b<68 then area='4ae';
  if 35<a<44 and 55<b<63 then area='4b';
  if 35<a<44 and 62<b<69 then area='4b';
  if 30<a<36 and 55<b<69 then area='4c ';
end;
else if substr(area,1,1) in ('4') and kat='IND' and art='SIL' then do;
  if 43<a<53 and 55<b<62 then area='4aw';
  if 43<a<53 and 61<b<67 then area='4ae';
  if 35<a<44 and 55<b<63 then area='4b';
  if 35<a<44 and 62<b<69 then do;
  if          62<b<66 then area='4b';
  else                     area='4b';
  end;
  if intsq in ('40F7', '41F7', '42F7', '40F8', '41F8', '42F8') then area='4b';
  if 30<a<36 and 55<b<69 then area='4c ';
end;
else if substr(area,1,1) in ('4') and kat='IND' and art='BRS' then do;
  if 43<a<53 and 55<b<62 then area='4a';
  if 43<a<53 and 61<b<68 then area='4a';
  if 35<a<44 and 55<b<63 then area='4bw';
  if 35<a<44 and 62<b<69 then area='4be';
  if 30<a<36 and 55<b<69 then area='4c ';
end;

*Add North Sea transfer;

if substr(area, 1, 1) = '4' and intsq in ('43F3', '43F4', '43F5', '43F6', '43F7', '43F8',
							  '44F3', '44F4', '44F5', '44F6', '44F7',
							  '45F3', '45F4', '45F5', '45F6',
							  '46F3', '46F4', '46F5',
							  '47F3', '47F4', '47F5') then transfer_4 = 'yes';
else transfer_4 = 'no';

if substr(area, 1, 1) = '4' and transfer_4 = 'yes' then area = 'trans';

run;

data an; set sbr;
keep aar art area kv kat ald lgdcm aant;

where ald>. and aant>.;

proc sort data=an; by aar area kv kat art lgdcm;

data an2; set an;  by aar area kv kat art lgdcm;
keep aar art area kv kat lgdcm a0-a11 totaldret;
array age a0-a11;
retain a0-a11;

if area in ('3an','3as','22','23','24','25','26','27','28','29','30','31','32') and ald>8 then ald=8;
else if ald>9 then ald=9;

if first.lgdcm then do; do i=1 to 12; age[i]=0; end; end;

age[ald+1]+aant; 

if last.lgdcm then do; totaldret=sum(of a0-a11); output; end;
run;

data an2; set an2;
output;
if aar=2004 and area='4ae' and art='SIL' and kat='KON' and kv=1 and lgdcm>30 then do;
  area='4aw'; output;
  if lgdcm>31 then do; lgdcm=33; output; lgdcm=34; output; end;
end;
if aar=2004 and area='lllaN' and art='SIL' and kat='IND' and kv=3 and lgdcm>19 then do;
  area='lllaS'; output;
  if lgdcm=24 then do; lgdcm=23; output; end;
end;
if aar=2017 and area='4ae' and art='SIL' and kat='KON' and kv=1 and lgdcm=28 then do;
  lgdcm=29; output;
end;
if aar=2017 and area='4b' and art='SIL' and kat='KON' and kv=3 and lgdcm=32 then do;
  lgdcm=33; output;
end;
if aar=2018 and area='22' and art='SIL' and kat='KONIND' and kv=1 and lgdcm=10 then do;
  lgdcm=8; manual_imp = 'yes'; output;
  lgdcm=9; output;
end;
if aar=2018 and area='22' and art='SIL' and kat='KONIND' and kv=1 and lgdcm=15 then do;
  lgdcm=16; manual_imp = 'yes'; output;
end;
if aar=2018 and area='22' and art='SIL' and kat='KONIND' and kv=1 and lgdcm=18 then do;
  lgdcm=17; manual_imp = 'yes'; output;
end;
if aar=2018 and area='24' and art='SIL' and kat='KONIND' and kv=4 and lgdcm=16 then do;
  lgdcm=15; manual_imp = 'yes'; output;
end;
if aar=2018 and area='24' and art='SIL' and kat='KONIND' and kv=2 and lgdcm=26 then do;
  lgdcm=27; manual_imp = 'yes'; output;
end;
if aar=2018 and area='24' and art='SIL' and kat='KONIND' and kv=4 and lgdcm=13 then do;
  lgdcm=12; manual_imp = 'yes'; output;
end;
if aar=2018 and area='24' and art='SIL' and kat='KONIND' and kv=4 and lgdcm=28 then do;
  lgdcm=29; manual_imp = 'yes'; output;
  lgdcm=30; manual_imp = 'yes'; output;
end;

if aar=2018 and area='3as' and art='SIL' and kat='KON' and kv=4 and lgdcm=15 then do;
  lgdcm=14; manual_imp = 'yes'; output;
end;
if aar=2018 and area='4aw' and art='SIL' and kat='KON' and kv=1 and lgdcm=31 then do;
  lgdcm=34; manual_imp = 'yes'; output;
end;
if aar=2018 and area='4aw' and art='SIL' and kat='KON' and kv=2 and lgdcm=22 then do;
  lgdcm=23; manual_imp = 'yes'; output;
end;
if aar=2018 and area='4aw' and art='SIL' and kat='KON' and kv=4 and lgdcm=34 then do;
  lgdcm=36; manual_imp = 'yes'; output;
end;

if aar=2018 and area='4b' and art='SIL' and kat='IND' and kv=3 and lgdcm=11 then do;
  lgdcm=14; manual_imp = 'yes'; output;
  lgdcm=15; manual_imp = 'yes'; output;
end;
if aar=2018 and area='4b' and art='SIL' and kat='IND' and kv=4 and lgdcm=31 then do;
  lgdcm=32; manual_imp = 'yes'; output;
end;

if aar=2018 and area='22' and art='BRS' and kat='IND' and kv=1 and lgdcm=8 then do;
  lgdcm=7; manual_imp = 'yes'; output;
end;
if aar=2018 and area='26' and art='BRS' and kat='IND' and kv=1 and lgdcm=7 then do;
  lgdcm=6; manual_imp = 'yes'; output;
end;
if aar=2018 and area='28' and art='BRS' and kat='IND' and kv=1 and lgdcm=12 then do;
  lgdcm=13; manual_imp = 'yes'; output;
end;
if aar=2018 and area='29' and art='BRS' and kat='IND' and kv=1 and lgdcm=7 then do;
  lgdcm=6; manual_imp = 'yes'; output;
end;
if aar=2018 and area='29' and art='BRS' and kat='IND' and kv=1 and lgdcm=12 then do;
  lgdcm=13; manual_imp = 'yes'; output;
end;
if aar=2018 and area='26' and art='BRS' and kat='IND' and kv=1 then do;
  kv=2; manual_imp = 'yes'; output;
end;

if aar=2019 and area='4aw' and art='SIL' and kat='KON' and kv=1 and lgdcm=32 then do;
  lgdcm=33; manual_imp = 'yes'; output;
end;
if aar=2019 and area='4aw' and art='SIL' and kat='KON' and kv=1 and lgdcm=30 then do;
  lgdcm=31; manual_imp = 'yes'; output;
end;
if aar=2019 and area='4aw' and art='SIL' and kat='KON' and kv=1 and lgdcm=22 then do;
  lgdcm=23; manual_imp = 'yes'; output;
end;
if aar=2019 and area='4aw' and art='SIL' and kat='KON' and kv=2 and lgdcm=29 then do;
  lgdcm=30; manual_imp = 'yes'; output;
end;
if aar=2019 and area='4aw' and art='SIL' and kat='KON' and kv=4 and lgdcm=29 then do;
  lgdcm=30; manual_imp = 'yes'; output;
end;
if aar=2019 and area='4aw' and art='SIL' and kat='KON' and kv=4 and lgdcm=31 then do;
  lgdcm=32; manual_imp = 'yes'; output;
end;

if aar=2019 and area='4b' and art='SIL' and kat='IND' and kv=2 and lgdcm=9 then do;
  lgdcm=10; manual_imp = 'yes'; output;
  lgdcm=11; manual_imp = 'yes'; output;
  lgdcm=12; manual_imp = 'yes'; output;
end;
if aar=2019 and area='4b' and art='SIL' and kat='IND' and kv=2 and lgdcm=13 then do;
  lgdcm=14; manual_imp = 'yes'; output;
  lgdcm=15; manual_imp = 'yes'; output;
  lgdcm=18; manual_imp = 'yes'; output;
end;

if aar=2019 and area='4b' and art='SIL' and kat='KON' and kv=3 and lgdcm=33 then do;
  lgdcm=34; manual_imp = 'yes'; output;
end;
if aar=2019 and area='4b' and art='SIL' and kat='KON' and kv=4 and lgdcm=31 then do;
  lgdcm=33; manual_imp = 'yes'; output;
end;

if aar=2019 and area='3as' and art='SIL' and kat='IND' and kv=3 and lgdcm=18 then do;
  lgdcm=19; manual_imp = 'yes'; output;
end;

if aar=2019 and area='22' and art='SIL' and kv=4 and lgdcm=12 then do;
  lgdcm=13; manual_imp = 'yes'; output;
end;
if aar=2019 and area='22' and art='SIL' and kv=4 and lgdcm=14 then do;
  lgdcm=15; manual_imp = 'yes'; output;
end;
if aar=2019 and area='22' and art='SIL' and kv=4 and lgdcm=16 then do;
  lgdcm=17; manual_imp = 'yes'; output;
end;

if aar=2019 and area='23' and art='SIL' and kv=4 and lgdcm=31 then do;
  lgdcm=32; manual_imp = 'yes'; output;
end;

if aar=2019 and area='24' and art='SIL' and kv=1 and lgdcm=12 then do;
  lgdcm=13; manual_imp = 'yes'; output;
end;
if aar=2019 and area='24' and art='SIL' and kv=3 and lgdcm=16 then do;
  lgdcm=15; manual_imp = 'yes'; output;
end;
if aar=2019 and area='24' and art='SIL' and kv=4 and lgdcm=12 then do;
  lgdcm=11; manual_imp = 'yes'; output;
end;
if aar=2019 and area='24' and art='SIL' and kv=4 and lgdcm=13 then do;
  lgdcm=14; manual_imp = 'yes'; output;
end;
if aar=2019 and area='24' and art='SIL' and kv=4 and lgdcm=29 then do;
  lgdcm=30; manual_imp = 'yes'; output;
end;

if aar=2019 and area='25' and art='SIL' and kv=1 and lgdcm=20 then do;
  lgdcm=21; manual_imp = 'yes'; output;
  lgdcm=22; manual_imp = 'yes'; output;
end;
if aar=2019 and area='29' and art='SIL' and kv=1 and lgdcm=13 then do;
  lgdcm=12; manual_imp = 'yes'; output;
end;
if aar=2019 and area='24' and art='BRS' and kv=4 and lgdcm=8 then do;
  lgdcm=7; manual_imp = 'yes'; output;
end;
if aar=2019 and area='25' and art='BRS' and kv=1 and lgdcm=8 then do;
  lgdcm=7; manual_imp = 'yes'; output;
end;


if aar=2020 and area='4b' and art='SIL' and kat='IND' and kv=2 and lgdcm=6 then do;
  lgdcm=5; manual_imp = 'yes'; output;
end;
if aar=2020 and area='4b' and art='SIL' and kat='IND' and kv=2 and lgdcm=12 then do;
  lgdcm=11; manual_imp = 'yes'; output;
  lgdcm=13; manual_imp = 'yes'; output;
end;
if aar=2020 and area='4b' and art='SIL' and kat='IND' and kv=2 and lgdcm=8 then do;
  lgdcm=9; manual_imp = 'yes'; output;
  lgdcm=10; manual_imp = 'yes'; output;
end;

if aar=2020 and area='4aw' and art='SIL' and kat='KON' and kv=1 and lgdcm=30 then do;
  lgdcm=31; manual_imp = 'yes'; output;
end;
if aar=2020 and area='4b' and art='SIL' and kat='KON' and kv=3 and lgdcm=32 then do;
  lgdcm=33; manual_imp = 'yes'; output;
end;
if aar=2020 and area='4b' and art='SIL' and kat='KON' and kv=4 and lgdcm=32 then do;
  lgdcm=33; manual_imp = 'yes'; output;
end;
if aar=2020 and area='4c' and art='SIL' and kat='KON' and kv=4 and lgdcm=30 then do;
  lgdcm=31; manual_imp = 'yes'; output;
end;


if aar=2020 and area='3an' and art='SIL' and kat='KON' and kv=3 and lgdcm=17 then do;
  lgdcm=17; kat = 'IND'; manual_imp = 'yes'; output;
end;
if aar=2020 and area='3an' and art='SIL' and kat='KON' and kv=3 and lgdcm=18 then do;
  lgdcm=18; kat = 'IND'; manual_imp = 'yes'; output;
end;
if aar=2020 and area='3an' and art='SIL' and kat='KON' and kv=3 and lgdcm=19 then do;
  lgdcm=19; kat = 'IND'; manual_imp = 'yes'; output;
end;
if aar=2020 and area='3an' and art='SIL' and kat='KON' and kv=3 and lgdcm=21 then do;
  lgdcm=21; kat = 'IND'; manual_imp = 'yes'; output;
end;
if aar=2020 and area='3an' and art='SIL' and kat='KON' and kv=3 and lgdcm=22 then do;
  lgdcm=22; kat = 'IND'; manual_imp = 'yes'; output;
end;
if aar=2020 and area='3an' and art='SIL' and kat='KON' and kv=3 and lgdcm=23 then do;
  lgdcm=23; kat = 'IND'; manual_imp = 'yes'; output;
end;
if aar=2020 and area='3an' and art='SIL' and kat='KON' and kv=3 and lgdcm=24 then do;
  lgdcm=24; kat = 'IND'; manual_imp = 'yes'; output;
end;
if aar=2020 and area='3an' and art='SIL' and kat='IND' and kv=3 and lgdcm=12 then do;
  lgdcm=15; kat = 'IND'; manual_imp = 'yes'; output;
  lgdcm=16; kat = 'IND'; manual_imp = 'yes'; output;
end;

if aar=2020 and area='29' and art='BRS' and kat='IND' and kv=1 and lgdcm=6 then do;
  lgdcm=5; manual_imp = 'yes'; output;
end;
if aar=2020 and area='25' and art='SIL' and kat='KONIND' and kv=1 and lgdcm=20 then do;
  lgdcm=21; manual_imp = 'yes'; output;
end;

if aar=2021 and area='4aw' and art='SIL' and kat='KON' and kv=1 and lgdcm=31 then do;
  lgdcm=32; manual_imp = 'yes'; output;
end;
if aar=2021 and area='4aw' and art='SIL' and kat='KON' and kv=4 and lgdcm=22 then do;
  lgdcm=21; manual_imp = 'yes'; output;
end;
if aar=2021 and area='4aw' and art='SIL' and kat='KON' and kv=4 and lgdcm=31 then do;
  lgdcm=32; manual_imp = 'yes'; output;
end;
if aar=2021 and area='4b' and art='SIL' and kat='KON' and kv=3 and lgdcm=32 then do;
  lgdcm=33; manual_imp = 'yes'; output;
end;
if aar=2021 and area='4b' and art='SIL' and kat='IND' and kv=3 and lgdcm=17 then do;
  lgdcm=18; manual_imp = 'yes'; output;
  lgdcm=19; manual_imp = 'yes'; output;
  lgdcm=20; manual_imp = 'yes'; output;
end;

if aar=2021 and area='24' and art='SIL' and kat='Active' and kv=1 and lgdcm=15 then do;
  lgdcm=16; manual_imp = 'yes'; output;
end;
if aar=2021 and area='24' and art='SIL' and kat='Active' and kv=4 and lgdcm=27 then do;
  lgdcm=28; manual_imp = 'yes'; output;
end;
if aar=2021 and area='27' and art='BRS' and kat='IND' and kv=1 and lgdcm=7 then do;
  lgdcm=8; manual_imp = 'yes'; output;
end;

*2022;
if aar=2022 and area='4aw' and art='SIL' and kat='IND' and kv=1 and lgdcm=23 then do;
  lgdcm=26; manual_imp = 'yes'; output;
end;
if aar=2022 and area='4b' and art='SIL' and kat='IND' and kv=2 and lgdcm=10 then do;
  lgdcm=13; manual_imp = 'yes'; output;
  lgdcm=14; manual_imp = 'yes'; output;
  lgdcm=15; manual_imp = 'yes'; output;
  lgdcm=16; manual_imp = 'yes'; output;
  lgdcm=17; manual_imp = 'yes'; output;
end;
if aar=2022 and area='4b' and art='SIL' and kat='IND' and kv=4 and lgdcm=8 then do;
  lgdcm=7; manual_imp = 'yes'; output;
end;
if aar=2022 and area='4b' and art='SIL' and kat='IND' and kv=4 and lgdcm=19 then do;
  lgdcm=20; manual_imp = 'yes'; output;
  lgdcm=21; manual_imp = 'yes'; output;
end;
if aar=2022 and area='4b' and art='SIL' and kat='IND' and kv=4 and lgdcm=22 then do;
  lgdcm=23; manual_imp = 'yes'; output;
  lgdcm=24; manual_imp = 'yes'; output;
end;
if aar=2022 and area='4b' and art='SIL' and kat='IND' and kv=4 and lgdcm=25 then do;
  lgdcm=26; manual_imp = 'yes'; output;
  lgdcm=29; manual_imp = 'yes'; output;
  lgdcm=30; manual_imp = 'yes'; output;
end;

*2022, trans;
if aar=2022 and area='4b' and art='SIL' and kat='KON' and kv=3 and lgdcm=32 then do;
  lgdcm=33; manual_imp = 'yes'; output;
end;
if aar=2022 and area='4b' and art='SIL' and kat='KON' and kv=4 and lgdcm=30 then do;
  lgdcm=31; manual_imp = 'yes'; output;
end;
if aar=2022 and area='4b' and art='SIL' and kat='KON' and kv=4 and lgdcm=32 then do;
  lgdcm=33; manual_imp = 'yes'; output;
end;
if aar=2022 and area='trans' and art='SIL' and kat='KON' and kv=1 and lgdcm=25 then do;
  lgdcm=26; manual_imp = 'yes'; output;
  lgdcm=27; manual_imp = 'yes'; output;
  lgdcm=28; manual_imp = 'yes'; output;
end;
if aar=2022 and area='trans' and art='SIL' and kat='KON' and kv=1 and lgdcm=29 then do;
  lgdcm=31; manual_imp = 'yes'; output;
end;
if aar=2022 and area='trans' and art='SIL' and kat='KON' and kv=3 and lgdcm=28 then do;
  lgdcm=29; manual_imp = 'yes'; output;
end;
if aar=2022 and area='trans' and art='SIL' and kat='KON' and kv=4 and lgdcm=21 then do;
  lgdcm=16; manual_imp = 'yes'; output;
  lgdcm=18; manual_imp = 'yes'; output;
  lgdcm=19; manual_imp = 'yes'; output;
end;
if aar=2022 and area='trans' and art='SIL' and kat='KON' and kv=4 and lgdcm=28 then do;
  lgdcm=29; manual_imp = 'yes'; output;
end;
if aar=2022 and area='trans' and art='SIL' and kat='KON' and kv=4 and lgdcm=30 then do;
  lgdcm=31; manual_imp = 'yes'; output;
end;

* 2023;
if aar=2023 and area='4aw' and art='SIL' and kat='KON' and kv=1 and lgdcm=32 then do;
  lgdcm=31; manual_imp = 'yes'; output;
  lgdcm=33; manual_imp = 'yes'; output;
end;
if aar=2023 and area='4aw' and art='SIL' and kat='KON' and kv=2 and lgdcm=30 then do;
  lgdcm=31; manual_imp = 'yes'; output;
end;
if aar=2023 and area='4aw' and art='SIL' and kat='KON' and kv=3 and lgdcm=32 then do;
  lgdcm=33; manual_imp = 'yes'; output;
end;
if aar=2023 and area='4aw' and art='SIL' and kat='KON' and kv=4 and lgdcm=30 then do;
  lgdcm=31; manual_imp = 'yes'; output;
end;
if aar=2023 and area='4b' and art='SIL' and kat='KON' and kv=4 and lgdcm=30 then do;
  lgdcm=31; manual_imp = 'yes'; output;
end;

proc sort data=an2; by aar area kv kat art lgdcm;
run;

data lgd; set sbr(where=(rep='ja'));
keep sampleid aar art area dfuarea kv kat ald lgdcm rdsk_sat togt tur stat type fid intsq rdsk
     maske bhgr gf trin lgd enh ant ald aant dato vgt n3sq a b;
run;
/****** vedr. alders-statistik pr station **********************************;
proc sort data=an1; by aar togt tur stat area kv kat art lgdcm;

data an21; set an1;  by aar togt tur stat area kv kat art lgdcm;
keep aar togt tur stat art area kv kat lgdcm a0-a11 totaldret;
array age a0-a11;
retain a0-a11;

if ald>11 then ald=11;

if first.lgdcm then do; do i=1 to 12; age[i]=0; end; end;

age[ald+1]+aant; 

if last.lgdcm then do; totaldret=sum(of a0-a11); output; end;
run;
proc tabulate noseps data=an21;
format stat $6.;
class aar stat area kat art kv;
var a0-a11;
table aar, kat*area*art*kv*(stat all) all, (a0 a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11)*sum=''*f=comma4./rts=40;
run;
****** vedr. alders-statistik pr station **********************************;*/

proc summary nway data=sbr(where=(rep='ja' and vgt>.));
class aar art area kv kat lgdcm;
var ant vgt;
output out=ln(drop=_type_ _freq) sum=tot vgt;

proc sort data=an2; by aar area kv kat art lgdcm;
proc sort data=lgd; by aar area kv kat art lgdcm;

data al; merge lgd(in=aa) an2(in=bb); by aar area kv kat art lgdcm; if aa then output;
run;

proc sql;
create table noage_1 as
select aar, area, kv, kat, art, sum(aant) as Noage
from sbr
group by aar, area, kv, kat, art;

proc sql;
create table stkkg as 
select aar, area, kv, kat, art, count(distinct sampleid) as NoSamples, sum(ant) as NoLength, 
			sum(ant)/(sum(vgt)/1000) as stkkg
from al
where totaldret ne .
group by aar, area, kv, kat, art;

proc sql;
create table t_ald as
select aar, area, kv, kat, art, lgdcm, a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, totaldret, sum(ant) as t_ant, sum(vgt) as sum_vgt, 
			sum(vgt)/sum(ant) as m_vgt
from al
where totaldret ne .
group by aar, area, kv, kat, art, lgdcm, a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, totaldret;

data t_ald_1;
set t_ald;
a0=a0*(t_ant/totaldret);
a1=a1*(t_ant/totaldret);
a2=a2*(t_ant/totaldret);
a3=a3*(t_ant/totaldret);
a4=a4*(t_ant/totaldret);
a5=a5*(t_ant/totaldret);
a6=a6*(t_ant/totaldret);
a7=a7*(t_ant/totaldret);
a8=a8*(t_ant/totaldret);
a9=a9*(t_ant/totaldret);
a10=a10*(t_ant/totaldret);
a11=a11*(t_ant/totaldret);

run;

proc sql;
create table total as
select aar, area, kv, kat, art, 'Total' as var,
	sum(a0) as a0, sum(a1) as a1, sum(a2) as a2, sum(a3) as a3, sum(a4) as a4, sum(a5) as a5, sum(a6) as a6, sum(a7) as a7,
	sum(a8) as a8, sum(a9) as a9, sum(a10) as a10, sum(a11) as a11, sum(t_ant) as all
from t_ald_1
group by  aar, area, kv, kat, art, var
order by  aar, area, kv, kat, art, var;

proc transpose data=total out=total1;
by aar area kv kat art;
id var;
var a0-a11;
run;

proc sql;
create table antal_pct as
select aar, area, kv, kat, art, 'Antal' as var,
	sum(a0)/sum(t_ant) as a0, sum(a1)/sum(t_ant) as a1, sum(a2)/sum(t_ant) as a2, sum(a3)/sum(t_ant) as a3, sum(a4)/sum(t_ant) as a4, 
	sum(a5)/sum(t_ant) as a5, sum(a6)/sum(t_ant) as a6, sum(a7)/sum(t_ant) as a7,
	sum(a8)/sum(t_ant) as a8, sum(a9)/sum(t_ant) as a9, sum(a10)/sum(t_ant) as a10, sum(a11)/sum(t_ant) as a11
from t_ald_1
group by  aar, area, kv, kat, art, var;

data tjek_antal;
set antal_pct;
tjek=a0+a1+a2+a3+a4+a5+a6+a7+a8+a9+a10+a11;
run;

proc transpose data=antal_pct out=antal_pct1;
by aar area kv kat art;
id var;
var a0-a11;
run;

proc sql;
create table mlgd as
select aar, area, kv, kat, art, 'M_lgd' as var,
	sum(a0*lgdcm)/sum(a0) as a0, sum(a1*lgdcm)/sum(a1) as a1, sum(a2*lgdcm)/sum(a2) as a2, sum(a3*lgdcm)/sum(a3) as a3, 
	sum(a4*lgdcm)/sum(a4) as a4, 
	sum(a5*lgdcm)/sum(a5) as a5, sum(a6*lgdcm)/sum(a6) as a6, sum(a7*lgdcm)/sum(a7) as a7,
	sum(a8*lgdcm)/sum(a8) as a8, sum(a9*lgdcm)/sum(a9) as a9, sum(a10*lgdcm)/sum(a10) as a10, sum(a11*lgdcm)/sum(a11) as a11
from t_ald_1
group by  aar, area, kv, kat, art, var;

proc transpose data=mlgd out=mlgd1;
by aar area kv kat art;
id var;
var a0-a11;
run;

proc sql;
create table mvgt as
select aar, area, kv, kat, art, 'M_vgt' as var,
	sum(a0*m_vgt)/sum(a0) as a0, sum(a1*m_vgt)/sum(a1) as a1, sum(a2*m_vgt)/sum(a2) as a2, sum(a3*m_vgt)/sum(a3) as a3, 
	sum(a4*m_vgt)/sum(a4) as a4, 
	sum(a5*m_vgt)/sum(a5) as a5, sum(a6*m_vgt)/sum(a6) as a6, sum(a7*m_vgt)/sum(a7) as a7,
	sum(a8*m_vgt)/sum(a8) as a8, sum(a9*m_vgt)/sum(a9) as a9, sum(a10*m_vgt)/sum(a10) as a10, sum(a11*m_vgt)/sum(a11) as a11
from t_ald_1
group by  aar, area, kv, kat, art, var;

proc transpose data=mvgt out=mvgt1;
by aar area kv kat art;
id var;
var a0-a11;
run;

data biologi;
merge stkkg noage_1 total1 antal_pct1 mlgd1 mvgt1;
by  aar area kv kat art;
run;

proc sql;
create table lan as
select year as aar, new_area as area, transfer_4, quarter as kv, kategori as kat, art, sum(ton*1000) as kg, sum(ton) as ton
from spr.lan_&aar.
group by aar, area, transfer_4, kv, kat, art;

data lan;
set lan;

if substr(area, 1, 1) = '4' and transfer_4 = 'yes' then area = 'trans';

run;

proc sql;
create table lan as
select aar, area, kv, kat, art, sum(kg) as kg, sum(ton) as ton
from lan
group by aar, area, kv, kat, art;


data final;
merge lan biologi;
by  aar area kv kat art;
stk_a=antal*stkkg*kg;
stk_a_1000=(antal*stkkg*kg)/1000;
stk_a_1000000=(antal*stkkg*kg)/1000000;
mw_kg = m_vgt/1000;
run;

proc sql;
create table tjek_sop as
select aar, area, kv, kat, art, kg, (sum(stk_a*m_vgt))/1000 as sop, (kg-((sum(stk_a*m_vgt))/1000))/kg as pct_sop
from final
group by aar, area, kv, kat, art, kg;

data sampling;
merge stkkg noage_1;
by  aar area kv kat art;
run;

data spr.canum_trans_&aar.;
set final;
run;

PROC EXPORT DATA= WORK.final
            OUTFILE= "Q:\mynd\Assessement_discard_and_the_like\WG\HAWG\wg2024\HAWGOutput\CANUM_trans_&aar..csv" 
            DBMS=CSV LABEL REPLACE;
RUN;
PROC EXPORT DATA= WORK.lan
            OUTFILE= "Q:\mynd\Assessement_discard_and_the_like\WG\HAWG\wg2024\HAWGOutput\Landings_trans_&aar..csv" 
            DBMS=CSV LABEL REPLACE;
RUN;
PROC EXPORT DATA= WORK.sampling
            OUTFILE= "Q:\mynd\Assessement_discard_and_the_like\WG\HAWG\wg2024\HAWGOutput\sampling_trans_&aar..csv" 
            DBMS=CSV LABEL REPLACE;
RUN;

*Længdefordelinger;
/*
data lgd2; set sbr(where=(rep='ja'));
keep sampleid aar art area dfuarea kv kat ald lgd rdsk_sat togt tur stat type fid intsq rdsk
     maske bhgr gf trin lgd enh ant ald aant dato vgt n3sq a b;
run;

proc sql;
create table ld as
select aar, area, kv, kat, art, floor(lgd/5) as lgdsc, sum(ant) as ant_lgd
from lgd2
group by aar, area, kv, kat, art, lgdsc;

proc sql;
create table ld_1 as
select aar, area, kv, kat, art, lgdsc, ant_lgd, sum(ant_lgd) as ant_tot, ant_lgd/sum(ant_lgd) as ld
from ld
group by aar, area, kv, kat, art;

proc sql;
create table tjek_ld as
select aar, area, kv, kat, art, sum(ld) as tjek
from ld_1
group by aar, area, kv, kat, art;

data final_ld;
merge lan stkkg ld_1;
by  aar area kv kat art;
stk_l=ld*stkkg*kg;
stk_l_1000=(ld*stkkg*kg)/1000;
stk_l_1000000=(ld*stkkg*kg)/1000000;
run;

PROC EXPORT DATA= WORK.final_ld
            OUTFILE= "Q:\mynd\Assessement_discard_and_the_like\WG\HAWG\wg2024\HAWGOutput\LD_&aar..csv" 
            DBMS=CSV LABEL REPLACE;
RUN;
