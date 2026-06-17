/* Adapted from
   HAWG/data_scripts/her.27.20-24/original_sas/ant_pr_maalte_aldret_kon_ind_brs_sil.sas
   (DTUAqua/2026_all_RDBES_DK).

   The original builds `silbrs1` from the FishLineDW ODBC warehouse, computing
   several derived columns (area via the $om. format, the ICES rectangle parsed
   into a/b, quarter, length-in-cm) inside the SQL pass-through. Here `silbrs1`
   is a small inline sample, and those same derived columns are produced in the
   DATA step using the original SAS expressions, so the $om. PROC FORMAT, the
   herring/sprat area-recoding logic, and the PROC SUMMARY / SORT / MERGE that
   build aged-vs-measured counts per sample all run unchanged. */

options nocenter label missing=' ' pagesize=70 linesize=120;

%let path_out = .;
libname out ".";

%let aar=%str(2025);

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

/* --- sample stand-in for: silbrs1 (ODBC FishLineDW) ---
   intsq is the ICES statistical rectangle; a/b/area/kv are the derived
   columns the original SQL pass-through computed with the same expressions. */
data silbrs1;
  length togt $10 tur $4 stat $4 type $4 intsq $4 rdsk $4 art $4 kat_db $4 rep $4 enh $4;
  input aar togt $ tur $ stat $ type $ intsq $ rdsk $ maske art $ kat_db $ rep $ lgd ant weight ald aant dfuarea $;
  area = put(dfuarea, $om.);
  dato = mdy(3, 15, aar);               /* deterministic sampling date */
  format dato ddmmyy8.;
  kv   = 1 + int((aar*0)+1);            /* deterministic placeholder quarter */
  vgt  = round(weight*1000);
  n3sq = input(compress(substr(intsq,1,2)||put(rank(substr(intsq,3,1))-64,1.0)
                                          ||substr(intsq,4,1)),4.0);
  b    = input(put(rank(substr(intsq,3,1))-64,1.0)||substr(intsq,4,1),4.0);
  a    = input(substr(intsq,1,2),2.0);
datalines;
2025 IN-HIRT 12 401 KON 41F6 OTM 30 SIL KON ja 240 18 0.012 3 16 41
2025 IN-HIRT 12 402 KON 44F6 OTM 28 SIL KON ja 255 22 0.014 4 20 44
2025 IN-LYNG 14 410 KON 38F5 GNS 80 SIL KON ja 270 12 0.018 5 10 4
2025 IN-FISKER 21 360 IND 49F1 PTM 24 SIL IND ja 180 30 0.008 2 28 20
2025 BRS20 31 372 IND 46F0 OTB 20 BRS KON ja 110 40 0.010 1 38 21
2025 GUDP-VIND 5 405 IND 39G2 SDN 18 SIL IND ja 145 25 0.009 2 22 24
2025 IN-HIRT 13 408 KON 41F6 PS 70 SIL KON ja 260 15 0.015 4 12 22
2025 IN-LYNG 16 411 IND 47F3 OTM 16 BRS IND ja 95 33 0.007 1 30 26
;
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
run;

proc print data=tford noobs;
title "Aged (aldret) vs measured (maalt) counts per sample";
var aar togt tur stat art kat area maalt aldret pr;
run;
