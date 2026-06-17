/* Adapted from
   HAWG/data_scripts/her.27.20-24/original_sas/indl_biologi_FishLine.sas
   (DTUAqua/2026_all_RDBES_DK).

   The full script builds the catch-at-age (CANUM) for North Sea / Skagerrak
   herring and sprat from FishLineDW. This bundle keeps the heart of that
   process: the age-length-key construction. For each length class (lgdcm)
   within a year/area/quarter/category/species BY group it accumulates the
   numbers-aged into an a0-a11 array with RETAIN and FIRST./LAST. flags,
   sums the per-class total, then rolls the key up with PROC SUMMARY and
   pivots it to one row per length class with PROC TRANSPOSE.

   The ODBC FishLineDW pull and the upstream recoding are replaced by an
   inline `sbr` sample carrying the columns these steps read; the array
   binning, PROC SORT, PROC SUMMARY and PROC TRANSPOSE run unchanged. */

options nocenter label missing=' ';

%let aar=2025;

/* --- sample stand-in for the cleaned biology table `sbr` --- */
data sbr;
  length art $4 area $10 kat $10 rep $4;
  input aar art $ area $ kv kat $ ald lgdcm aant ant vgt rep $ sampleid;
datalines;
2025 SIL 4b 3 IND 0 18 12 40 0.05 ja 101
2025 SIL 4b 3 IND 1 18 30 40 0.05 ja 101
2025 SIL 4b 3 IND 2 18 18 40 0.05 ja 101
2025 SIL 4b 3 IND 1 20 22 35 0.07 ja 101
2025 SIL 4b 3 IND 3 20 41 35 0.07 ja 101
2025 SIL 4aw 1 KON 2 30 15 22 0.18 ja 102
2025 SIL 4aw 1 KON 3 30 28 22 0.18 ja 102
2025 SIL 4aw 1 KON 4 31 12 18 0.20 ja 102
2025 BRS 22 4 IND 1 8 33 30 0.01 ja 103
2025 BRS 22 4 IND 2 8 21 30 0.01 ja 103
2025 BRS 22 4 IND 1 9 14 25 0.01 ja 103
;
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

proc sort data=an2; by aar area kv kat art lgdcm;
run;

proc print data=an2 noobs;
title "Age-length key: numbers aged per length class (a0-a11) and class total";
var aar area kv kat art lgdcm a0 a1 a2 a3 a4 totaldret;
run;

proc summary nway data=an2;
class aar area kv kat art;
var a0-a11 totaldret;
output out=key_tot(drop=_type_ _freq_) sum=;
run;

proc print data=key_tot noobs;
title "Age-length key rolled up to year/area/quarter/category/species";
var aar area kv kat art a0 a1 a2 a3 a4 totaldret;
run;

proc transpose data=an2 out=an2_long(rename=(col1=naged)) name=agegroup;
by aar area kv kat art lgdcm;
var a0-a11;
run;

proc print data=an2_long(obs=20) noobs;
title "Age-length key in long form (one row per length class x age group)";
var aar area kv kat art lgdcm agegroup naged;
run;
