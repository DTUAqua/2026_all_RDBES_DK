

*Dybvandsrejer;

*Format fra stens program;
proc format; 
value $om
'43F6','43F5','44F6','44F5','44F4','44F3','44F2',
'45F6','45F5','45F4','45F3','45F2','46F5','46F4','46F3','46F2',
'47F4','47F3','47F2','48F4','48F3','48F2','49F4','49F3','49F2','50F3','50F2','51F2' ='Norske Rende'
'43F7','43F8','43F9','44F7','44F8','44F9','44G0','45F9','45G0','46F9','46G0'        ='Skagerrak'
'44G1','43G0','43G1','43G2','42G1','42G2','41G1','41G2', '37G1'                     ='Kattegat'
'44F0','44F1','45F0','45F1','46F0','46F1','47F0','47F1',
'48F0','48F1','49F0','49F1'                                                         ='Fladen'
'41F5','41F6','40F5','40F6','39F5','39F6','38F6'                                    ='ved Horns Rev'
other                                                                               ='Andre sq i IVa-c';

*Stationer;
Proc sql ;
connect to odbc (dsn='FishlineDW');
	create table hh
		as select *, put(statisticalRectangle,$om.) as fu
	from connection to odbc
(
SELECT sampleId, tripId, year, cruise, trip, station, gearQuality, quarterGearStart, fishingtime, dfuArea, statisticalRectangle, catchRegistration, 
			speciesRegistration, gearType, selectionDevice, meshSize
FROM  Sample
WHERE (year between 2007 and 2026) AND (targetSpecies1 = 'DRJ') AND (tripType = 'S?S') AND (cruise IN ('SEAS', 'MON', 'Rejer Fladen')) OR
               (year between 2007 and 2026) AND (tripType = 'SØS') AND (cruise IN ('SEAS', 'MON', 'Rejer Fladen')) AND (gearType IN ('OTT', 'OTB')) 
						AND (meshSize BETWEEN 32 AND 69) or (year between 2007 and 2026) and cruise = 'Rejer Fladen'
)
;
	create table sp
		as select *, put(statisticalRectangle,$om.) as fu
	from connection to odbc
(
SELECT sampleId, year, cruise, trip, station, quarterGearStart, statisticalRectangle, speciesCode, landingCategory, dfuBase_Category, sizeSortingEU, 
				sizeSortingDFU, sexCode, cuticulaHardness, ovigorous, treatment, weightStep0, weightStep1, weightStep2, 
                  weightStep3, treatmentFactor, raisingFactor, number
FROM     SpeciesList
WHERE  (year BETWEEN 2007 AND 2026) AND (speciesCode = 'DRJ') AND (tripType = 'SØS') AND (cruise IN ('SEAS', 'MON', 'Rejer Fladen'))
)
;
	create table hl
		as select *, put(statisticalRectangle,$om.) as fu
	from connection to odbc
(
SELECT AnimalRaised.animalRaisedId, AnimalRaised.speciesListRaisedId, AnimalRaised.year, AnimalRaised.cruise, AnimalRaised.trip, AnimalRaised.tripType, 
               AnimalRaised.station, AnimalRaised.dateGearStart, AnimalRaised.quarterGearStart, AnimalRaised.dfuArea, AnimalRaised.statisticalRectangle, 
               AnimalRaised.gearQuality, AnimalRaised.gearType, AnimalRaised.meshSize, AnimalRaised.speciesCode, AnimalRaised.landingCategory, 
               AnimalRaised.dfuBase_Category, AnimalRaised.sizeSortingEU, AnimalRaised.sizeSortingDFU, AnimalRaised.speciesList_sexCode, AnimalRaised.sexCode, 
               AnimalRaised.cuticulaHardness, AnimalRaised.ovigorous, AnimalRaised.broodingPhase, AnimalRaised.length, AnimalRaised.lengthMeasureUnit, 
               AnimalRaised.numberSumSamplePerLength, AnimalRaised.numberTotalPerLength, AnimalRaised.weightMean, SpeciesListRaised.weightSubSample, 
               SpeciesListRaised.weightTotal, Sample.fishingtime
FROM  AnimalRaised INNER JOIN
               SpeciesListRaised ON AnimalRaised.speciesListRaisedId = SpeciesListRaised.speciesListRaisedId INNER JOIN
               Sample ON SpeciesListRaised.sampleId = Sample.sampleId
WHERE (AnimalRaised.year between 2007 and 2026) AND (AnimalRaised.speciesCode = 'DRJ') AND (AnimalRaised.tripType = 'SØS') AND (AnimalRaised.cruise IN ('SEAS', 'MON', 'Rejer Fladen'))
)
;
disconnect from odbc;
quit;

data hh1;
set hh;

if gearquality ne 'V' then delete;
*if gearquality ne 'V' or catchRegistration ne 'ALL' or speciesRegistration ne 'ALL' then delete;
*if trip='1187' then delete;

run;

data sp;
set sp;

if landingcategory='IND' then landingcategory='KON';
if landingcategory='SLP' then delete;

if raisingfactor = . then delete;

weightSubSample = min(weightStep0, weightStep1, weightStep2, 
                  weightStep3);

weightTotal = min(weightStep0, weightStep1, weightStep2, 
                  weightStep3) * raisingFactor;

run;

proc sql;
create table hl_sum as
select year, fu, quartergearstart, cruise, trip, station, landingcategory, 
		sizeSortingDFU, speciesList_sexCode, ovigorous, sum(numberSumSamplePerLength) as numberSubSample, 
		sum(numberTotalPerLength) as numberTotal
from hl
group by year, fu, quartergearstart, cruise, trip, station, landingcategory, 
		sizeSortingDFU, speciesList_sexCode, ovigorous;

proc sql;
create table sp_1 as 
select *
from sp a left join hl_sum b
on a.year = b.year 
and a.fu = b.fu 
and a.quartergearstart = b.quartergearstart
and a.cruise = b.cruise
and a.trip = b.trip
and a.station = b.station
and a.landingcategory = b.landingcategory
and a.sizeSortingDFU = b.sizeSortingDFU
and a.sexcode = b.speciesList_sexCode
and a.ovigorous = b.ovigorous;

proc sql;
create table hhsp as
select a.year as aar, a.fu, a.quartergearstart as kv, a.cruise as togt, a.trip as tur, a.station as stat, a.catchRegistration,
	a.speciesRegistration, b.landingcategory as kat, b.sizeSortingDFU,
	'N' as koen, numberSubSample as maalt, numberTotal as N_maalt, weightSubSample as kg, weightTotal as totkg, fishingtime, selectiondevice
from hh1 a left join sp_1 b
on a.sampleid=b.sampleid;

PROC EXPORT DATA= hhsp
            OUTFILE= "C:\Users\kibi\OneDrive - Danmarks Tekniske Universitet\2026_all_RDBES_DK\NIPAG\boot\data\data_old_format\Pandalus_Stations_spWeights_2007_2026.csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;

data hl;
set hl;

*if trip='1187' then delete;
if landingcategory='IND' then landingcategory='KON';
if landingcategory='SLP' then delete;

run;

proc sql;
create table hl1 as
select year, fu, quartergearstart as kv, cruise as togt, trip as tur, station as stat, landingcategory, 
		sizeSortingDFU, length, sexcode, sum(numberSumSamplePerLength) as ant, 
		sum(numberTotalPerLength) as opgant
from hl
group by year, fu, kv, togt, tur, stat, landingcategory, sizeSortingDFU, length, sexcode;

proc sql;
create table sp1 as 
select aar, fu, kv, togt, tur, stat, catchRegistration, speciesRegistration, kat, 
		sizeSortingDFU, sum(distinct kg) as prvgt1, sum(distinct totkg) as opgvgt, 
		count(distinct stat) as n_stat, sum(distinct fishingtime) as antmin
from hhsp
group by aar, fu, kv, togt, tur, stat, catchRegistration, speciesRegistration, kat, sizeSortingDFU;

proc sql;
create table hlsp as
select b.aar, a.fu, a.kv, a.togt, a.tur, a.stat, b.kat, a.sizeSortingDFU, 'N' as koen, length as lgd, 
	sexcode as sex, ant, opgant, prvgt1, opgvgt, antmin, n_stat, round(opgant/(antmin/60),1.) as n_pr_time, opgvgt/(antmin/60) as kg_pr_time
from hl1 a left join sp1 b
on a.year=b.aar
and a.fu=b.fu
and a.kv=b.kv
and a.togt=b.togt
and a.tur=b.tur
and a.stat=b.stat
and a.landingcategory=b.kat
and a.sizeSortingDFU=b.sizeSortingDFU;

PROC EXPORT DATA= hlsp
            OUTFILE= "C:\Users\kibi\OneDrive - Danmarks Tekniske Universitet\2026_all_RDBES_DK\NIPAG\boot\data\data_old_format\Pandalus_Stations_LD_2007_2026.csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;
