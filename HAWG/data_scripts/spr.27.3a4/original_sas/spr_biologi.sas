
%let path_repo = C:\Users\kibi\OneDrive - Danmarks Tekniske Universitet\2026_all_RDBES_DK;
%let awg = HAWG;
%let stock = spr.27.3a4;
libname out "&path_repo.\&awg.\data\original_sas\&stock.";
%let path_out = &path_repo.\&awg.\data\original_sas\&stock.;

*20190311 - raisingfactor not included in calculating number and weight for the rep;

Proc sql ;
connect to odbc (dsn='FishLineDW');
	create table length
		as select *, datepart(dateGearStart) as date format=ddmmyy8.
	from connection to odbc
(
SELECT     dbo.SpeciesList.sampleId, dbo.SpeciesList.year, dbo.SpeciesList.cruise, dbo.SpeciesList.trip, dbo.SpeciesList.tripType, dbo.SpeciesList.station, 
                      dbo.Sample.targetSpecies1, dbo.Sample.dfuArea, dbo.Sample.statisticalRectangle, dbo.SpeciesList.speciesCode, dbo.SpeciesList.landingCategory, 
                      dbo.Animal.representative, dbo.Animal.length, dbo.SpeciesList.raisingfactor, dbo.Animal.number as number, 
					  dbo.Animal.weight as weight_new, dbo.Sample.dateGearStart
FROM         dbo.Trip INNER JOIN
                      dbo.Sample ON dbo.Trip.tripId = dbo.Sample.tripId INNER JOIN
                      dbo.Cruise ON dbo.Trip.cruiseId = dbo.Cruise.cruiseId LEFT OUTER JOIN
                      dbo.SpeciesList LEFT OUTER JOIN
                      dbo.Animal ON dbo.SpeciesList.speciesListId = dbo.Animal.speciesListId ON dbo.Sample.sampleId = dbo.SpeciesList.sampleId
WHERE     (dbo.SpeciesList.speciesCode = 'BRS') AND (dbo.Cruise.cruise like ('BIT%')) and dbo.Animal.representative='ja' 
			OR (dbo.SpeciesList.speciesCode = 'BRS') AND (dbo.Cruise.cruise like ('IBT%')) and dbo.Animal.representative='ja' 
			OR (dbo.SpeciesList.speciesCode = 'BRS') AND (dbo.SpeciesList.cruise in ('IBTS-1','IBTS-2','BITS-1','BITS-2','1Y','GUDP-VIND')) and dbo.Animal.representative='ja' 
			OR (dbo.SpeciesList.speciesCode = 'BRS') AND (dbo.SpeciesList.tripType = 'HVN') and dbo.Animal.representative='ja' 
			OR (dbo.SpeciesList.cruise IN ('BRS11','BRS12','BRS13','BRS14','BRS15','BRS16','BRS17','BRS18','BRS19','BRS20','BRS21','IN-FISKER')) and dbo.Animal.representative='ja'
ORDER BY dbo.SpeciesList.year 
)
;
create table age
		as select *, datepart(dateGearStart) as date format=ddmmyy8.
	from connection to odbc
(
SELECT     dbo.SpeciesList.sampleId, dbo.SpeciesList.year, dbo.SpeciesList.cruise, dbo.SpeciesList.trip, dbo.SpeciesList.tripType, dbo.SpeciesList.station, 
                      dbo.Sample.targetSpecies1, dbo.Sample.dfuArea, dbo.Sample.statisticalRectangle, dbo.SpeciesList.speciesCode, dbo.SpeciesList.landingCategory, 
                      dbo.Animal.representative, dbo.Age.length, dbo.Age.age, dbo.Age.number, dbo.Sample.dateGearStart, dbo.Age.ageReadId, dbo.Age.otolithReadingRemark
FROM         dbo.Sample INNER JOIN
                      dbo.SpeciesList ON dbo.Sample.sampleId = dbo.SpeciesList.sampleId INNER JOIN
                      dbo.Age INNER JOIN
                      dbo.Animal ON dbo.Age.animalId = dbo.Animal.animalId ON dbo.SpeciesList.speciesListId = dbo.Animal.speciesListId INNER JOIN
                      dbo.Trip ON dbo.Sample.tripId = dbo.Trip.tripId INNER JOIN
                      dbo.Cruise ON dbo.Trip.cruiseId = dbo.Cruise.cruiseId
WHERE     (dbo.SpeciesList.speciesCode = 'BRS') AND (dbo.Cruise.cruise like ('BIT%')) and dbo.Animal.representative='ja' 
			OR (dbo.SpeciesList.speciesCode = 'BRS') AND (dbo.Cruise.cruise like ('IBT%')) and dbo.Animal.representative='ja' 
			OR (dbo.SpeciesList.speciesCode = 'BRS') AND (dbo.SpeciesList.cruise in ('IBTS-1','IBTS-2','BITS-1','BITS-2','1Y','GUDP-VIND')) 
			OR (dbo.SpeciesList.speciesCode = 'BRS') AND (dbo.SpeciesList.tripType = 'HVN')
			OR (dbo.SpeciesList.cruise IN ('BRS11','BRS12','BRS13','BRS14','BRS15','BRS16','BRS17','BRS18','BRS19','BRS20','BRS21','IN-FISKER')) 
ORDER BY dbo.SpeciesList.year
)
;
disconnect from odbc;
quit;

*Database problemer :-(;

data out.length_including_survey;
set length;
if cruise in ('BRS11','BRS12','BRS13','BRS14','BRS15','BRS16','BRS17','BRS18','BRS19','BRS20','BRS21','IN-FISKER') and landingcategory='DIS' then landingcategory='IND';
run;

proc sql;
create table check_age_remark as
select year, age, otolithReadingRemark, sum(number)
from age
group by year, age, otolithReadingRemark;

data out.age_including_survey;
set age;
if age>1000 then delete;
if otolithReadingRemark in ('AQ3','AQ3_QA') then age = .;
if cruise in ('BRS11','BRS12','BRS13','BRS14','BRS15','BRS16','BRS17','BRS18','BRS19','BRS20','BRS21','IN-FISKER') and landingcategory='DIS' then landingcategory='IND';
run;


PROC EXPORT DATA= out.length_including_survey
            OUTFILE= "&path_out.\length_including_survey.csv" 
            DBMS=CSV REPLACE;
     DELIMITER='3B'x; 
     PUTNAMES=YES;
RUN;

PROC EXPORT DATA= out.age_including_survey
            OUTFILE= "&path_out.\age_including_survey.csv" 
            DBMS=CSV REPLACE;
     DELIMITER='3B'x; 
     PUTNAMES=YES;
RUN;

/*
proc sql;
create table fejl as
select distinct year, cruise, trip, station, landingcategory
from length
where cruise in ('BRS11','BRS12','BRS13','BRS14','BRS15','BRS16','BRS17','BRS18','BRS19','BRS20','BRS21','IN-FISKER') and landingcategory='DIS';

PROC EXPORT DATA= WORK.fejl
            OUTFILE= "Q:\mynd\Assessement_discard_and_the_like\WG\HAWG\wg2023\sprat\BRS_Industri_FiskeProever_fejl_DIS.csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;
*/

*Test no fish;

proc sql;
create table no_age as
select year, cruise, dfuarea, sum(number) as no_fish
from age
where speciescode = 'BRS' and year in (2024, 2025)
group by year, cruise, dfuarea;

proc sql;
create table no_length as
select year, cruise, dfuarea, sum(number) as no_fish
from length
where speciescode = 'BRS' and year in (2024, 2025)
group by year, cruise, dfuarea;
