libname dfadudv 'Q:\20-forskning\20-dfad\data\Data\udvidet_data';
libname dfadbase 'Q:\20-forskning\20-dfad\data\Data\grunddata';
libname fdfmt 'Q:\50-radgivning\02-mynd\SAS Library\FD_Format';

%let aar=2025;
%let aar1=2026;

*19-09-2018: Aftalt med Ole E. at bruge udvidet DFAD til at finde metier, men slå industriartsfordeling fra. Samt at tilføje logbogsfangst uden afregning;

*%macro loop(aar=2018);

*aar;
data rejer;
set dfadudv.dfad_udvidet&aar(where=(dfadfvd_ret=:'4' or dfadfvd_ret='3AN' or dfadfvd_ret='3AS') keep=ldato afrfvd fvd art ltilst forarb hel vrd square ihovedart fangst metier_level6_ret square_ret dfadfvd_ret oal);
if ihovedart ne '' then art=ihovedart;
year=year(ldato);
quarter=qtr(ldato);
metier=metier_level6_ret;
kg=hel;
kg_log_u_afr=fangst;

if ltilst='K' or forarb='K' then kategori='Kogt ';
else kategori='Fersk';

length area $5.;

if square_ret in ('52F2','52F3','52F4','52F5','52F6','52F7','52F8','52F9','52G0','52G1','52G2', 
              '51F2','51F3','51F4','51F5','51F6','51F7','51F8','51F9','51G0','51G1','51G2', 
              '50F2','50F3','50F4','50F5','50F6','50F7','50F8','50F9','50G0','50G1','50G2', 
              '49F2','49F3','49F4','49F5','49F6','49F7','49F8','49F9','49G0','49G1','49G2', 
              '48F2','48F3','48F4','48F5','48F6','47F2','47F3','47F4','47F5','47F6','46F2',
              '46F3','46F4','46F5','46F6','45F2','45F3','45F4','45F5','45F6','44F2','44F3',
              '44F4','44F5','44F6','43F5','43F6','43F7') then area='IVa';

if square_ret in ('48F7','48F8','48F9','48G0','48G1','48G2', 
              '47F7','47F8','47F9','47G0','47G1','47G2', 
              '46F7','46F8','46F9','46G0','46G1','46G2', 
              '45F7','45F8','45F9','45G0','45G1','45G2', 
			  '44F7','44F8','44F9','44G0','44G1','44G2',
              '43F8','43F9','43G1','43G0') then area='IIIa';

if square_ret in ('49F1','49F0','49E9','48F1','48F0','48E9',
			  '47F1','47F0','47E9','46F1','46F0','46E9',
              '46E8','45F1','45F0','45E9','45E8','44F1',
              '44F0','44E9')then area='FLA';

if square_ret in ('40E9','40E8','40E7','40E6','39E8','39E9',
			  '38E8','38E9','37E9','36E9')then area='FAR';

if art='DVR' and (kg>0 or kg_log_u_afr>0);

*if ltilst in ('X','A','L','S','7','I','U') then kategori='Fersk';
*else if ltilst in ('K') then kategori='Kogt';
run;

proc summary nway data=rejer missing;
class year dfadfvd_ret quarter art ltilst kategori square_ret area metier;
var kg vrd kg_log_u_afr;
output out=rejer1_&aar(drop=_type_ _freq_) sum=;
run;

proc summary nway data=rejer missing;
class year art square_ret area;
var kg vrd kg_log_u_afr;
output out=rejer_plot_&aar(drop=_type_ _freq_) sum=;
run;

proc summary nway data=rejer1_&aar missing;
class year dfadfvd_ret area quarter art ltilst kategori metier;
var kg vrd kg_log_u_afr;
output out=rejer2_&aar(drop=_type_ _freq_) sum=;
run;

proc export data=rejer1_&aar
            outfile="C:\Users\kibi\OneDrive - Danmarks Tekniske Universitet\2026_all_RDBES_DK\NIPAG\boot\data\data_old_format\rejer_square_&aar._3.csv"
			dbms=csv replace;
run;

/*
proc export data=rejer_plot_&aar
            outfile="Q:\20-forskning\20-dfad\users\olei\data\Data_rejeassessment\2024\rejer_square_&aar._3_plot.csv"
			dbms=csv replace;
run;

proc export data=rejer2_&aar
            outfile="Q:\20-forskning\20-dfad\users\olei\data\Data_rejeassessment\2024\rejer_&aar._3.csv"
			dbms=csv replace;
run;
*/
**********************************************************************************;
*aar1 kvartal1;
data rejer;
set dfadudv.dfad_udvidet&aar1(where=(dfadfvd_ret=:'4' or dfadfvd_ret='3AN' or dfadfvd_ret='3AS') keep=ldato afrfvd fvd art ltilst forarb hel vrd square ihovedart fangst metier_level6_ret square_ret dfadfvd_ret oal);
if ihovedart ne '' then art=ihovedart;
year=year(ldato);
quarter=qtr(ldato);
if quarter=1;
metier=metier_level6_ret;
kg=hel;
kg_log_u_afr=fangst;

if ltilst='K' or forarb='K' then kategori='Kogt ';
else kategori='Fersk';

length area $5.;

if square_ret in ('52F2','52F3','52F4','52F5','52F6','52F7','52F8','52F9','52G0','52G1','52G2', 
              '51F2','51F3','51F4','51F5','51F6','51F7','51F8','51F9','51G0','51G1','51G2', 
              '50F2','50F3','50F4','50F5','50F6','50F7','50F8','50F9','50G0','50G1','50G2', 
              '49F2','49F3','49F4','49F5','49F6','49F7','49F8','49F9','49G0','49G1','49G2', 
              '48F2','48F3','48F4','48F5','48F6','47F2','47F3','47F4','47F5','47F6','46F2',
              '46F3','46F4','46F5','46F6','45F2','45F3','45F4','45F5','45F6','44F2','44F3',
              '44F4','44F5','44F6','43F5','43F6','43F7') then area='IVa';

if square_ret in ('48F7','48F8','48F9','48G0','48G1','48G2', 
              '47F7','47F8','47F9','47G0','47G1','47G2', 
              '46F7','46F8','46F9','46G0','46G1','46G2', 
              '45F7','45F8','45F9','45G0','45G1','45G2', 
			  '44F7','44F8','44F9','44G0','44G1','44G2',
              '43F8','43F9','43G1','43G0') then area='IIIa';

if square_ret in ('49F1','49F0','49E9','48F1','48F0','48E9',
			  '47F1','47F0','47E9','46F1','46F0','46E9',
              '46E8','45F1','45F0','45E9','45E8','44F1',
              '44F0','44E9')then area='FLA';

if square_ret in ('40E9','40E8','40E7','40E6','39E8','39E9',
			  '38E8','38E9','37E9','36E9')then area='FAR';

if art='DVR' and (kg>0 or kg_log_u_afr>0);

*if ltilst in ('X','A','L','S','7','I','U') then kategori='Fersk';
*else if ltilst in ('K') then kategori='Kogt';
run;

proc summary nway data=rejer missing;
class year dfadfvd_ret quarter art ltilst kategori square_ret area metier;
var kg vrd kg_log_u_afr;
output out=rejer1_&aar1(drop=_type_ _freq_) sum=;
run;

proc summary nway data=rejer missing;
class year art square_ret area;
var kg vrd kg_log_u_afr;
output out=rejer_plot_&aar1(drop=_type_ _freq_) sum=;
run;

proc summary nway data=rejer1_&aar missing;
class year dfadfvd_ret area quarter art ltilst kategori metier;
var kg vrd kg_log_u_afr;
output out=rejer2_&aar1(drop=_type_ _freq_) sum=;
run;

proc export data=rejer1_&aar1
            outfile="C:\Users\kibi\OneDrive - Danmarks Tekniske Universitet\2026_all_RDBES_DK\NIPAG\boot\data\data_old_format\rejer_square_&aar1._kv1_3.csv"
			dbms=csv replace;
run;

/*
proc export data=rejer_plot_&aar1
            outfile="Q:\20-forskning\20-dfad\users\olei\data\Data_rejeassessment\2024\rejer_square_&aar._kv1_3_plot.csv"
			dbms=csv replace;
run;

proc export data=rejer2_&aar1
            outfile="C:\Users\kibi\OneDrive - Danmarks Tekniske Universitet\gits\2025_all_RDBES_DK\NIPAG\boot\data\old_boot_data\rejer_&aar._kv1_3.csv"
			dbms=csv replace;
run;



/*
%mend loop;
%loop(aar=2018);
%loop(aar=2017);
%loop(aar=2016);
%loop(aar=2015);
%loop(aar=2014);
%loop(aar=2013);
%loop(aar=2012);
%loop(aar=2011);
%loop(aar=2010);
%loop(aar=2009);
%loop(aar=2008);
%loop(aar=2007);
%loop(aar=2006);
%loop(aar=2005);
%loop(aar=2004);
%loop(aar=2003);
%loop(aar=2002);
%loop(aar=2001);
%loop(aar=2000);
%loop(aar=1999);
%loop(aar=1998);
%loop(aar=1997);
%loop(aar=1996);
%loop(aar=1995);
%loop(aar=1994);
%loop(aar=1993);
%loop(aar=1992);
%loop(aar=1991);
%loop(aar=1990);
%loop(aar=1989);
%loop(aar=1988);
%loop(aar=1987);


data rejer_sq_1990t2018;
set Rejer1_1990 Rejer1_1991 Rejer1_1992 Rejer1_1993 Rejer1_1994 Rejer1_1995
Rejer1_1996 Rejer1_1997 Rejer1_1998 Rejer1_1999 Rejer1_2000 Rejer1_2001 Rejer1_2002 Rejer1_2003 Rejer1_2004
Rejer1_2005 Rejer1_2006 Rejer1_2007 Rejer1_2008 Rejer1_2009 Rejer1_2010 Rejer1_2011 Rejer1_2012 Rejer1_2013 
Rejer1_2014 Rejer1_2015 Rejer1_2016 Rejer1_2017 Rejer1_2018;
run;

proc export data=rejer_sq_1990t2018
            outfile="Q:\50-radgivning\02-mynd\Josefine\Personer\Ole_Eigaard\Kogte_rejer\rejer_square_1990t2018_3.csv"
			dbms=csv replace;
run;
*/
