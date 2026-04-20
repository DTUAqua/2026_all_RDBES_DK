libname dfadudv 'Q:\20-forskning\20-dfad\data\Data\udvidet_data';
libname fdfmt 'Q:\50-radgivning\02-mynd\SAS Library\FD_Format';

%let aar=2024;
%let aar1=2025;

*aar;
data dfad;
set dfadudv.dfad_udvidet&aar(where=(metier_level6_ret='OTB_CRU_32-69_0_0' or (fid='R38')));
aar=year(ldato);
kvartal=qtr(ldato);
keep aar art hel kvartal redskb maske dfadfvd_ret metier_level6_ret;
run;

proc sort data=fdfmt.art(rename=(art=dkart start=art)) out=art(keep=art dkart eart); by art; run;
proc sort data=dfad; by art; run;

data dfad1;
merge dfad (in=aa) art (in=bb);
by art;
if aa and hel ne .;
run;

proc summary nway data=dfad1(where=(redskb ne 'LHP')) missing;
class aar kvartal metier_level6_ret redskb maske art dkart eart dfadfvd_ret;
var hel;
output out=dfad2(drop=_type_ _freq_) sum=;
run;

proc export data=dfad2
            outfile="C:\Users\kibi\OneDrive - Danmarks Tekniske Universitet\gits\2025_all_RDBES_DK\NIPAG\boot\data\old_boot_data\pandalus_landinger_&aar._inclR38.csv"
			dbms=csv replace;
run;


*************************************************************************************;
*aar1 kvartal 1;
data dfad;
set dfadudv.dfad_udvidet&aar1(where=(metier_level6_ret='OTB_CRU_32-69_0_0' or (fid='R38')));
aar=year(ldato);
kvartal=qtr(ldato);
if kvartal=1;
keep aar art hel kvartal redskb maske dfadfvd_ret metier_level6_ret;
run;

proc sort data=fdfmt.art(rename=(art=dkart start=art)) out=art(keep=art dkart eart); by art; run;
proc sort data=dfad; by art; run;

data dfad1;
merge dfad (in=aa) art (in=bb);
by art;
if aa and hel ne .;
run;

proc summary nway data=dfad1(where=(redskb ne 'LHP')) missing;
class aar kvartal metier_level6_ret redskb maske art dkart eart dfadfvd_ret;
var hel;
output out=dfad2(drop=_type_ _freq_) sum=;
run;

proc export data=dfad2
            outfile="C:\Users\kibi\OneDrive - Danmarks Tekniske Universitet\gits\2025_all_RDBES_DK\NIPAG\boot\data\old_boot_data\pandalus_landinger_&aar1._kv1_inclR38.csv"
			dbms=csv replace;
run;
