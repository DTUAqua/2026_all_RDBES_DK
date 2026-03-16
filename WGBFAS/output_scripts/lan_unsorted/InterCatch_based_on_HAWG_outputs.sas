
*InterCatch file based on HAWG output;

libname input 'C:\Users\kibi\OneDrive - Danmarks Tekniske Universitet\2026_all_RDBES_DK\WGBFAS\model\lan_unsorted\original_sas';
libname library 'Q:\50-radgivning\02-mynd\Formater\Formater_94';

%let WG='WGBFAS';*'HAWG-NS-HER';*'HAWG'; *'WGBFAS'; *'HAWG-SPR';
%let year=2025;
%let name=WGBFAS;
%let usage='NA';
%let countryname=DNK;
%let country='DK';
%let type=spr.27.22-32;
%let species='BRS';
%let path=C:\Users\kibi\OneDrive - Danmarks Tekniske Universitet\2026_all_RDBES_DK\WGBFAS\output\intercatch;

data canum;
set input.canum_&year.;
length fleet $20. area1 $15.;

if art=&species.;

if area in ('3an') then do; area1='27.3.a.20'; areatype='SubDiv'; end;
if area in ('3as') then do; area1='27.3.a.21'; areatype='SubDiv'; end;
if area in ('4a') then do; area1='27.4.a'; areatype='Div'; end;
if area in ('4b') then do; area1='27.4.b'; areatype='Div'; end;
if area in ('4c') then do; area1='27.4.c'; areatype='Div'; end;
if area in ('4ae') then do; area1='27.4.a.e'; areatype='SubDiv'; end;
if area in ('4aw') then do; area1='27.4.a.w'; areatype='SubDiv'; end;
if area in ('4be','4bee','4bew','BK') then do; area1='27.4.b.e'; areatype='SubDiv'; end;
if area in ('4bw') then do; area1='27.4.b.w'; areatype='SubDiv'; end;
if area in ('6a') then do; area1='27.6.a.n'; areatype='SubDiv'; end;
if area in ('7c') then do; area1='27.7.c'; areatype='Div'; end;
if area in ('7d') then do; area1='27.7.d'; areatype='Div'; end;
if area in ('7e') then do; area1='27.7.e'; areatype='Div'; end;
if area in ('7h') then do; area1='27.7.h'; areatype='Div'; end;
if area in ('7k') then do; area1='27.7.k'; areatype='Div'; end;
if area in ('7j') then do; area1='27.7.j'; areatype='Div'; end;
if area in ('22') then do; area1='27.3.c.22'; areatype='SubDiv'; end;
if area in ('23') then do; area1='27.3.b.23'; areatype='SubDiv'; end;
if area in ('24') then do; area1='27.3.d.24'; areatype='SubDiv'; end;
if area in ('25') then do; area1='27.3.d.25'; areatype='SubDiv'; end;
if area in ('26') then do; area1='27.3.d.26'; areatype='SubDiv'; end;
if area in ('27') then do; area1='27.3.d.27'; areatype='SubDiv'; end;
if area in ('28') then do; area1='27.3.d.28'; areatype='SubDiv'; end;
if area in ('29') then do; area1='27.3.d.29'; areatype='SubDiv'; end;
if area in ('30') then do; area1='27.3.d.30'; areatype='SubDiv'; end;
if area in ('31') then do; area1='27.3.d.31'; areatype='SubDiv'; end;
if area in ('32') then do; area1='27.3.d.32'; areatype='SubDiv'; end;

if area = '4l' then delete;

if &WG.='HAWG' then do;
if art='BRS' then fleet='All';

if art='SIL' then do;
	if kat='KON' and area in ('4a','4ae','4aw','4b','4be','4bee','4bew','4bw','4c','BK') then fleet='Fleet-A'; 
	if kat='IND' and area in ('4a','4ae','4aw','4b','4be','4bee','4bew','4bw','4c','BK') then fleet='Fleet-B'; 
	if kat='KON' and area in ('3an','3as') then fleet='Fleet-C'; 
	if kat='IND' and area in ('3an','3as') then fleet='Fleet-D'; 
	if kat='KONIND' and area in ('22','23','24') then fleet='Fleet-F'; 
	if area in ('6a') then fleet='All';
end;

if art='SIL' and area1 in ('27.3.d.25','27.3.d.26','27.3.d.27','27.3.d.28','27.3.d.28.1','27.3.d.28.2','27.3.d.29','27.3.d.30',
'27.3.d.31','27.3.d.32') or art='BRS' and area1 in ('27.3.b.23','27.3.c.22','27.3.d.24','27.3.d.25','27.3.d.26','27.3.d.27','27.3.d.28','27.3.d.28.1','27.3.d.28.2','27.3.d.29','27.3.d.30',
'27.3.d.31','27.3.d.32') then delete;
end;


if &WG.='HAWG-SPR' then do;
if art='BRS' then fleet='All';

if art='SIL' and area1 in ('27.3.d.25','27.3.d.26','27.3.d.27','27.3.d.28','27.3.d.28.1','27.3.d.28.2','27.3.d.29','27.3.d.30',
'27.3.d.31','27.3.d.32') or art='BRS' and area1 in ('27.3.b.23','27.3.c.22','27.3.d.24','27.3.d.25','27.3.d.26','27.3.d.27','27.3.d.28','27.3.d.28.1','27.3.d.28.2','27.3.d.29','27.3.d.30',
'27.3.d.31','27.3.d.32') then delete;

end;


if &WG.='HAWG-NS-HER' then do;
if art='BRS' then delete;

if art='SIL' then do;
	if kat='KON' and area in ('4a','4ae','4aw','4b','4be','4bee','4bew','4bw','4c','BK') then fleet='Fleet-A'; 
	if kat='IND' and area in ('4a','4ae','4aw','4b','4be','4bee','4bew','4bw','4c','BK') then fleet='Fleet-B'; 
	if kat='KON' and area in ('3an','3as') then fleet='Fleet-C'; 
	if kat='IND' and area in ('3an','3as') then fleet='Fleet-D'; 
	if kat='KONIND' and area in ('22','23','24') then fleet='Fleet-F'; 
	if area in ('6a','7c','7k') then fleet='All';
end;
if fleet not in ('Fleet-A','Fleet-B') then delete;
end;

if &WG.='WGBFAS' then do;
fleet='Pelagic trawlers';
if art='SIL' and area='28' then area1='27.3.d.28.2';

if art='SIL' and area1 not in ('27.3.d.25','27.3.d.26','27.3.d.27','27.3.d.28','27.3.d.28.1','27.3.d.28.2','27.3.d.29','27.3.d.30',
'27.3.d.31','27.3.d.32') or art='BRS' and area1 not in ('27.3.b.23','27.3.c.22','27.3.d.24','27.3.d.25','27.3.d.26','27.3.d.27','27.3.d.28','27.3.d.28.1','27.3.d.28.2','27.3.d.29','27.3.d.30',
'27.3.d.31','27.3.d.32') then delete;
end;

catchcat='L';

if fleet=' ' then delete;

run;

proc sql;
create table canum4 as
select aar, kv, art, fleet, area1, areaType, catchCat, _Name_, sum(kg) as kg, sum(ton) as ton, sum(NoSamples) as NoSamples,
	sum(NoLength) as NoLength, sum(stkkg) as stkkg, sum(NoAge) as NoAge, sum(total) As total, sum(antal) as antal, sum(m_lgd) as m_lgd,
	sum(m_vgt) as m_vgt, sum(stk_a) as stk_a, sum(stk_a_1000) as stk_a_1000, sum(stk_a_1000000) as stk_a_1000000
from canum
group by aar, kv, art, fleet, area1, areaType, catchCat, _Name_;

data final_2;
set canum4;
length effortunit $3.;
das=round(effort_das,1.);
if das=. then do; das=-9; effortunit='NA'; end;
if das ne -9 then do; effortunit='dop'; end;
age=substr(_name_,2,2)*1;
*if nolength <  10 then age = .;
if age=. and kg=0 then delete;
if kg = . then delete;
kg = round(kg);
year=&year.;
if das=. then das=-9;
if art='BRS' then species='SPR';
else species='HER';
usage=&usage.;
country=&country.;

proc sort;
by fleet area1 kv species usage catchCat age;
run;

data _NULL_;
set final_2;
by fleet area1 kv species usage catchCat age;
file "&path.\IC_DNK_Age_&name._&type._&year._&sysdate..csv";
if first.kv then 
  put 'HI,' country ',' year ',Quarter,' kv ',' fleet ',' AreaType ',' area1 ',NA,' effortunit ',' das ',NA';
if first.catchCat then
  put 'SI,' country ',' year ',Quarter,' kv ',' fleet ',' AreaType ',' area1 ',NA,' Species ',NA,' catchCat ',R,NA,' usage ',M,NA,kg,' kg ',' 
			kg ',-9,Trip,NA,NA';
if first.age  and age ne . and kg ne 0 and antal ne 0 then 
  put 'SD,' country ',' year ',Quarter,' kv ',' fleet ',' AreaType ',' area1 ',NA,' Species ',NA,' catchCat ',R,N,age,' age ',-9,' kg ',' 
			nosamples ',' nolength ',' nosamples ',' noage ',g,k,year,cm,NA,' stk_a_1000 ',' m_vgt ',' m_lgd ',-9,-9,-9';
run;

data _NULL_;
set final_2;
by fleet area1 kv usage catchCat species age;
file "&path.\IC_DNK_NoBio_&name._&type._&year._&sysdate..csv";
if first.kv then 
  put 'HI,' country ',' year ',Quarter,' kv ',' fleet ',' AreaType ',' area1 ',NA,' effortunit ',' das ',NA';
if first.species then
  put 'SI,' country ',' year ',Quarter,' kv ',' fleet ',' AreaType ',' area1 ',NA,' Species ',NA,' catchCat ',R,NA,' usage ',M,NA,kg,' kg ',' 
			kg ',-9,NA,NA,NA';
run;


