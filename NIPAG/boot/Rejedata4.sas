libname dfadudv 'Q:\20-forskning\20-dfad\data\Data\udvidet_data';
*libname ole 'Q:\50-radgivning\02-mynd\Josefine\Personer\Ole_Eigaard';

*%let aar=1987;

%macro loop(aar=2010);

data reje;
set dfadudv.dfad_udvidet&aar(where=(fvd=:'4' or fvd='3AN' or fvd='3AS'));
if art='DVR' then do; DVR_hel=hel; DVR_vrd=vrd; end;
aar=&aar;
maaned=month(ldato);
hk=max*1;
oal1=oal*1;
run;

proc summary nway data=reje missing;
class aar maaned fvd fid match redskb maske hk oal1 square;
id fisketid havtime havdag_tur havdag_fvd efdage fisketid;
var DVR_hel hel DVR_vrd vrd;
output out=reje1(drop=_type_ _freq_) sum=;
run;

data rejer&aar;
set reje1;
reje_pct=DVR_vrd/vrd;
if reje_pct>=0.3 and match ne '';
run;
%mend loop;


%loop(aar=1987);
%loop(aar=1988);
%loop(aar=1989);
%loop(aar=1990);
%loop(aar=1991);
%loop(aar=1992);
%loop(aar=1993);
%loop(aar=1994);
%loop(aar=1995);
%loop(aar=1996);
%loop(aar=1997);
%loop(aar=1998);
%loop(aar=1999);
%loop(aar=2000);
%loop(aar=2001);
%loop(aar=2002);
%loop(aar=2003);
%loop(aar=2004);
%loop(aar=2005);
%loop(aar=2006);
%loop(aar=2007);
%loop(aar=2008);
%loop(aar=2009);
%loop(aar=2010);
%loop(aar=2011);
%loop(aar=2012);
%loop(aar=2013);
%loop(aar=2014);
%loop(aar=2015);
%loop(aar=2016);

%loop(aar=2017);
%loop(aar=2018);
%loop(aar=2019);
%loop(aar=2020);
%loop(aar=2021);
%loop(aar=2022);
%loop(aar=2023);

%loop(aar=2024);
%loop(aar=2025);
%loop(aar=2026);

proc export data=rejer2025
            outfile="C:\Users\kibi\OneDrive - Danmarks Tekniske Universitet\2026_all_RDBES_DK\NIPAG\boot\data\data_old_format\rejer_NS_S_K_2025.csv"
			dbms=csv replace;
run;

proc export data=rejer2026
            outfile="C:\Users\kibi\OneDrive - Danmarks Tekniske Universitet\gits\2025_all_RDBES_DK\NIPAG\boot\data\old_boot_data\rejer_NS_S_K_2026.csv"
			dbms=csv replace;
run;

data rejer87_25(rename=(oal1=oal));
set rejer1987 rejer1988 rejer1989 rejer1990 rejer1991 rejer1992 rejer1993 rejer1994 rejer1995 
rejer1996 rejer1997 rejer1998 rejer1999 rejer2000 rejer2001 rejer2002 rejer2003 rejer2004 
rejer2005 rejer2006 rejer2007 rejer2008 rejer2009 rejer2010 rejer2011 rejer2012 rejer2013 rejer2014 
rejer2015 rejer2016 rejer2017 rejer2018 rejer2019 rejer2020 rejer2021 rejer2022 rejer2023 rejer2024
rejer2025 rejer2026;
run; 
/*
data ole.rejer_NS_S_K_87_25;
set rejer87_24;
run;
*/
proc export data=rejer87_25
            outfile="C:\Users\kibi\OneDrive - Danmarks Tekniske Universitet\2026_all_RDBES_DK\NIPAG\boot\data\data_old_format\rejer_NS_S_K_1987_2026.csv"
			dbms=csv replace;
run;


*/
