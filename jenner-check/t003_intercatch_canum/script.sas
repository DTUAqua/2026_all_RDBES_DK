/* Adapted from
   WGBFAS/output_scripts/lan_unsorted/InterCatch_based_on_HAWG_outputs.sas
   (DTUAqua/2026_all_RDBES_DK).

   This step builds the WGBFAS InterCatch input from the CANUM age-structured
   catch table: it maps DTU area codes to ICES Subdivisions, applies the
   macro-driven (&WG.=WGBFAS) fleet/area filtering that keeps only the Baltic
   stock units, rolls the rows up by fleet/area/quarter/age with PROC SQL, and
   sorts into the InterCatch record order. The original reads `input.canum_2025`
   from a Windows libname; here `canum` is a small inline sample carrying the
   columns the step consumes, and the final catch-at-age table is printed. */

%let WG='WGBFAS';
%let year=2025;
%let name=WGBFAS;
%let usage='NA';
%let countryname=DNK;
%let country='DK';
%let type=spr.27.22-32;
%let species='BRS';
%let path=.;

/* --- sample stand-in for: input.canum_2025 --- */
data canum;
  length art $4 area $6 _Name_ $4;
  input aar kv art $ area $ _Name_ $ kg ton NoSamples NoLength stkkg NoAge total antal m_lgd m_vgt stk_a stk_a_1000 stk_a_1000000 effort_das;
datalines;
2025 1 BRS 22 a1 1500 1.5 3 120 42.0 30 150 80 11.2 14.1 96000 96.0 0.096 .
2025 1 BRS 22 a2 1500 1.5 3 120 42.0 30 150 50 13.4 18.7 60000 60.0 0.060 .
2025 2 BRS 24 a1 2200 2.2 4 200 38.0 40 250 130 11.8 13.9 84000 84.0 0.084 12
2025 2 BRS 24 a2 2200 2.2 4 200 38.0 40 250 90 13.9 19.2 58000 58.0 0.058 12
2025 3 BRS 25 a1 1800 1.8 2 90 45.0 18 110 70 12.1 15.0 81000 81.0 0.081 .
2025 1 BRS 4a a1  900 0.9 2 60 33.0 12 80 40 11.5 13.2 26000 26.0 0.026 .
;
run;

data canum;
set canum;
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
	sum(m_vgt) as m_vgt, sum(stk_a) as stk_a, sum(stk_a_1000) as stk_a_1000, sum(stk_a_1000000) as stk_a_1000000, sum(effort_das) as effort_das
from canum
group by aar, kv, art, fleet, area1, areaType, catchCat, _Name_;
quit;

data final_2;
set canum4;
length effortunit $3.;
das=round(effort_das,1.);
if das=. then do; das=-9; effortunit='NA'; end;
if das ne -9 then do; effortunit='dop'; end;
age=substr(_name_,2,2)*1;
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

proc print data=final_2 noobs;
title "WGBFAS InterCatch input: sprat (SPR) catch-at-age, ICES Subdivisions";
var aar kv species area1 areatype fleet age kg antal stk_a_1000;
run;
