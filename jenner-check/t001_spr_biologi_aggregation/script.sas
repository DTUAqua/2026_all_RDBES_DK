/* Adapted from HAWG/data_scripts/spr.27.3a4/original_sas/spr_biologi.sas
   (DTUAqua/2026_all_RDBES_DK).

   The original pulls the `length` and `age` tables from the FishLineDW ODBC
   data warehouse. Here those two PROC SQL ODBC blocks are replaced with small
   in-line sample tables that carry the exact columns the downstream steps read,
   so the recoding DATA steps and the PROC SQL aggregations run unchanged.
   Sprat (BRS) survey + commercial samples, her.27.3a4. */

libname out ".";
%let path_out = .;

*20190311 - raisingfactor not included in calculating number and weight for the rep;

/* --- sample stand-in for: length (ODBC FishLineDW) --- */
data length;
  length cruise $12 landingCategory $4 speciesCode $4 dfuArea $4;
  input year cruise $ landingCategory $ speciesCode $ dfuArea $ number weight_new raisingfactor length;
datalines;
2024 BIT-1   IND BRS 22 120 0.014 1.0 95
2024 BIT-1   IND BRS 22  88 0.016 1.0 105
2024 IBTS-1  DIS BRS 24  44 0.011 1.0 85
2025 BRS21   DIS BRS 22 210 0.013 1.2 100
2025 BRS21   DIS BRS 22 175 0.015 1.2 110
2025 IN-FISKER DIS BRS 23 64 0.012 1.0 90
2026 BIT-2   IND BRS 24  31 0.018 1.0 120
2026 IBTS-2  IND BRS 22  52 0.017 1.0 115
;
run;

/* --- sample stand-in for: age (ODBC FishLineDW) --- */
data age;
  length cruise $12 landingCategory $4 speciesCode $4 dfuArea $4 otolithReadingRemark $8;
  input year cruise $ landingCategory $ speciesCode $ dfuArea $ length age number otolithReadingRemark $;
datalines;
2024 BIT-1   IND BRS 22  95 2 120 .
2024 BIT-1   IND BRS 22 105 3  88 .
2024 IBTS-1  DIS BRS 24  85 1  44 AQ3
2025 BRS21   DIS BRS 22 100 2 210 .
2025 BRS21   DIS BRS 22 110 3 175 AQ3_QA
2025 IN-FISKER DIS BRS 23 90 2  64 .
2026 BIT-2   IND BRS 24 120 4  31 .
2026 IBTS-2  IND BRS 22 115 9999 52 .
;
run;

*Database problemer :-(;

data out.length_including_survey;
set length;
if cruise in ('BRS11','BRS12','BRS13','BRS14','BRS15','BRS16','BRS17','BRS18','BRS19','BRS20','BRS21','IN-FISKER') and landingcategory='DIS' then landingcategory='IND';
run;

proc sql;
create table check_age_remark as
select year, age, otolithReadingRemark, sum(number) as number
from age
group by year, age, otolithReadingRemark;
quit;

data out.age_including_survey;
set age;
if age>1000 then delete;
if otolithReadingRemark in ('AQ3','AQ3_QA') then age = .;
if cruise in ('BRS11','BRS12','BRS13','BRS14','BRS15','BRS16','BRS17','BRS18','BRS19','BRS20','BRS21','IN-FISKER') and landingcategory='DIS' then landingcategory='IND';
run;


PROC EXPORT DATA= out.length_including_survey
            OUTFILE= "&path_out./length_including_survey.csv"
            DBMS=CSV REPLACE;
     DELIMITER='3B'x;
     PUTNAMES=YES;
RUN;

PROC EXPORT DATA= out.age_including_survey
            OUTFILE= "&path_out./age_including_survey.csv"
            DBMS=CSV REPLACE;
     DELIMITER='3B'x;
     PUTNAMES=YES;
RUN;

*Test no fish;

proc sql;
create table no_age as
select year, cruise, dfuarea, sum(number) as no_fish
from age
where speciescode = 'BRS' and year in (2024, 2025, 2026)
group by year, cruise, dfuarea;
quit;

proc sql;
create table no_length as
select year, cruise, dfuarea, sum(number) as no_fish
from length
where speciescode = 'BRS' and year in (2024, 2025, 2026)
group by year, cruise, dfuarea;
quit;

proc print data=no_length noobs; title "Sprat numbers by year/cruise/area (length table)"; run;
proc print data=no_age noobs; title "Sprat numbers by year/cruise/area (age table)"; run;
