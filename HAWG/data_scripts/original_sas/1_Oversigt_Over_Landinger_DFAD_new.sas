
*Oversigt til Lotte med silde og brislinge landinger;
*Talle bliver lavet som til FF vha. dfadfvd_ret;

options missing='';

*temp indeholder udvidet DFAD med level 6 sat på;
libname temp 'Q:\dfad\data\Data\udvidet_data';
libname lplads 'Q:\mynd\SAS Library\Lplads';
libname library 'Q:\mynd\Formater\Formater_94';
libname out 'Q:\mynd\Assessement_discard_and_the_like\WG\HAWG\wg2024\HAWGOutput\SASData';


%let year=2023;

*Fordeling af uoplyste square;
data data0;
set temp.dfad_udvidet&year.;
*set out.dfad2006;
length match_alle $15. rectangle_original $5.;

if match ne '' then match_alle=match;
else match_alle=compress(fid||'_'||put(ldato,yymmdd6.));

if dfadfvd_ret in ('3D282','3D281') then dfadfvd_ret='3D28';

*rectangle_original=isb!!isl;
rectangle_original=square_ret;
*if square_ret_mrk in ('Harbour >=12','Harbour default','Harbour <12') then rectangle_original=square;
if rectangle_original in ('','99A9',' .A9','NONE') then rectangle_original='99A9';

run;

*hvis square er missing find square fra tidligere tur;
proc sql;
create table data1 as
select *, sum(hel) as kg
from data0
group by dfadfvd_ret, rectangle_original, fid;

data data1;
set data1;
if rectangle_original='99A9' then kg=0;
run;

proc sort data=data1; by dfadfvd_ret fid desending kg; run; *Ændret i forhold til tidligere;

data data2;
set data1;
by dfadfvd_ret fid; *Ændret i forhold til før;
if first.fid then rectangle_old=rectangle_original;
retain rectangle_old;
run;

*Square fra landingshavn findes;
proc sql;
create table data3 as
select a.*, b.lplads_sq
from data2 a left join lplads.lplads b
on a.lplads=b.start;

data data4;
set data3;
rectangle=rectangle_original;
if (rectangle in('','99A9',' .A9','NONE') and match ne ' ') or  (rectangle in('','99A9',' .A9','NONE') and oal>=10)
		then rectangle=rectangle_old; *ændret i forhold til før;
if rectangle in('','99A9',' .A9','NONE') then rectangle=lplads_sq;
if rectangle in('','99A9',' .A9') then rectangle=rectangle_old;

if fid = 'AS202' and ldato = 180826 then rectangle = '45F0';
if match_alle = 'AS202_180904' then rectangle = '46F0';


if rectangle_original in ('','99A9',' .A9','NONE') and dfadfvd_ret = '4L' then rectangle='42F8';
if rectangle_original in ('','99A9',' .A9','NONE') and dfadfvd_ret = '4N' then rectangle='41F8';
if rectangle_original in ('','99A9',' .A9','NONE') and dfadfvd_ret = '4R' then rectangle='40F8';

run;

proc sql;
create table missing_sq as
select distinct lplads, dfadfvd_ret, rectangle, lplads_sq, rectangle_old
from data4
where rectangle='99A9' and substr(dfadfvd_ret,1,1) not in ('F','N');


*Opdeling per IND og KON- ændret fra tidligere - nu følger det den oprindeling definition fra fx IAF.;
*20230302 - IND som landingskategori defineres i første omgang vha. ltilst og avend (som FST) ;
* - efterfølgende tages der hensyn til maske (dette er ikke helt magen til FST);

proc sql;
create table target as
select match_alle, dfadfvd_ret, art, sum(hel) as kg
from data4
group by match_alle, dfadfvd_ret, art;
proc sort data=target; by match_alle dfadfvd_ret desending kg; run;

data target_1;
set target;
by match_alle dfadfvd_ret;
if first.dfadfvd_ret then target = art;
retain target;
run;

proc sql;
create table target_2 as
select distinct match_alle, dfadfvd_ret, target
from target_1;

/*
proc datasets library=work nolist;
   delete data0 data1 data2 data3;
quit;
*/

proc sql;
create table data5 as
select *
from data4 a left join target_2 b
on a.match_alle=b.match_alle
and a.dfadfvd_ret=b.dfadfvd_ret;

data data6;
set data5;
length kategori $10. maske_num $12.;

if target in("BLH","BRS","HMK","KRI","LSS","LOD","PIL","SPE","TBS","ARG","SKO","GUK","HAG") 
and (ltilst in ('I') or (ltilst in ('X','U') and anvend in ('F','I'))) then kategori='IND'; 
*else if ihovedart ne ' ' then kategori='IND'; 
else if bms='yes' then kategori='BMS';
else if match_alle in ('0004399971','0004413401') then kategori='KON';
else kategori='KON';

/*
maske_num = maske*1;

if maske not in (., 0) and maske >= 32 then kategori='KON';
if maske not in (., 0) and maske <32 then kategori = 'IND';
*/
run;

proc sql;
create table test_kat as
select dfadfvd_ret, maske, target, kategori, art, sum(hel) as kg
from data6
where art = 'SIL'
group by dfadfvd_ret, maske, target, kategori, art;

data data5;
set data6;

length ff_area new_area Kategori $10.;

Month=month(ldato);
Quarter=qtr(ldato);
if art in ('SIL','BRS');
FF_area=put(dfadfvd_ret,$fishframearea.);

/*
if ltilst='I' then Kategori='IND';
else Kategori='KON';
*/
/*
if art in("BLH","BRS","HMK","KRI","LSS","LOD","PIL","SPE","TBS","ARG","SKO","GUK","HAG") 
and ltilst = "I" then kategori='IND'; 
else if ihovedart ne ' ' then kategori='IND'; 
else if bms='yes' then kategori='BMS';
else kategori='KON';
*/
if art='BRS' then kategori='IND';

sq=rectangle;
new_square=rectangle;
new_sq=rectangle;

substr(new_sq,3,1)=put(rank(substr(new_sq,3,1))-64,1.0);
n3sq=input(new_sq,4.0);
a=int(n3sq/100); b=n3sq-a*100;

if substr(FF_area,1,1) in ('4') and Kategori='KON' and art='SIL' then do;
  if 43<a<53 and 55<b<62 then FF_area='4aw';
  if 43<a<53 and 61<b<68 then FF_area='4ae';
  if 35<a<44 and 55<b<63 then FF_area='4b';
  if 35<a<44 and 62<b<69 then FF_area='4b';
  if 30<a<36 and 55<b<69 then FF_area='4c ';
end;
else if substr(FF_area,1,1) in ('4') and Kategori='IND' and art='SIL' then do;
  if 43<a<53 and 55<b<62 then FF_area='4aw';
  if 43<a<53 and 61<b<67 then FF_area='4ae';
  if 35<a<44 and 55<b<63 then FF_area='4b';
  if 35<a<44 and 62<b<69 then do;
       if          62<b<66 then FF_area='4b';
       else                     FF_area='4b';
  end;
  if new_square in ('40F7', '41F7', '42F7', '40F8', '41F8', '42F8') then ff_area='4b';
  if 30<a<36 and 55<b<69 then ff_area='4c ';
end;
else if substr(FF_area,1,1) in ('4') and Kategori='IND' and art='BRS' then do;
  if 43<a<53 and 55<b<62 then FF_area='4a';
  if 43<a<53 and 61<b<68 then FF_area='4a';
  if 35<a<44 and 55<b<63 then FF_area='4bw';
  if 35<a<44 and 62<b<69 then FF_area='4be';
  if 30<a<36 and 55<b<69 then FF_area='4c ';
end;

*Add North Sea transfer;

if substr(ff_area, 1, 1) = '4' and new_square in ('43F3', '43F4', '43F5', '43F6', '43F7', '43F8',
							  '44F3', '44F4', '44F5', '44F6', '44F7',
							  '45F3', '45F4', '45F5', '45F6',
							  '46F3', '46F4', '46F5',
							  '47F3', '47F4', '47F5') then transfer_4 = 'yes';
else transfer_4 = 'no';

/*
if new_square in ('44G1','44G0','43F8','44F7') then new_area='3an';
else if new_square in ('41G1','41G2') then new_area='3as';
else if new_square in ('41G0','40G1') then new_area='22';
else if new_square in ('39G2','39G4') then new_area='24';

else*/
new_area=ff_area;

if new_area in ('22','23','24','25','26','27','28','29','30','31','32') and art='SIL' then do; kategori='KONIND'; end;

if kategori = 'KONIND' and new_area in ('22','23','24') then do;
	if substr(metier_level6_ret, 1, 3) in ('OTM','PTM','SSC','OTB') then kategori = 'Active';
	if substr(metier_level6_ret, 1, 3) in ('GNS','FPN','No_') then kategori = 'Passive';
end;

run;

data data6;
set data5;
if hel=. then delete;
Year=year(ldato);
run;

proc sort data=data6; by match_alle; run;

data data7;
set data6;
by match_alle;
if first.match_alle then TripNo=_n_;
retain;
run;

proc sql;
create table data8 as
select TripNo, Year, quarter, month, art, kategori, ihovedart, ltilst, anvend, maske, metier_level6_ret, ff_area, square_ret_mrk, square, new_square, new_area, dfadfvd, dfadfvd_ret, transfer_4, sum(hel)/1000 as Ton
from data7
group by TripNo, Year, quarter, month, art, kategori, ihovedart, ltilst, anvend, maske, metier_level6_ret, ff_area, square_ret_mrk, square, new_square, new_area, dfadfvd, dfadfvd_ret, transfer_4;

	PROC EXPORT DATA= WORK.data8
	            OUTFILE= "Q:\mynd\Assessement_discard_and_the_like\WG\HAWG\wg2024\HAWGOutput\Landings_FD_PerTrip_new_&year._&sysdate..csv" 
	            DBMS=CSV LABEL REPLACE;
	RUN;

	data out.lan_&year.;
	set data8;
	run;

	proc sql;
	create table areas as 
	select distinct ff_area
	from data7;

	proc sql;
	create table data9 as
	select Year, quarter, art, new_square, sum(hel)/1000 as Ton
	from data7
	where ff_area in ('22','23','24','3an','3as') and art = 'SIL'
	group by Year, quarter, art, new_square
	order by new_square;

	proc transpose data=data9 out=land2;
	by new_square;
	var ton;
	id art quarter;
	run;

	PROC IMPORT OUT= WORK.wgsquare 
	            DATAFILE= "Q:\mynd\Assessement_discard_and_the_like\Input\YellowSheetCodes\WGSquare_HAWG.csv" 
	            DBMS=DLM REPLACE;
	     DELIMITER='3B'x; 
	     GETNAMES=YES;
	     DATAROW=2; 
	RUN;

	data wgsquare;
	set wgsquare;
	if rect=' ' then delete;
	run;

	proc sql;
	create table land3 as
	select *
	from wgsquare a full join land2 b
	on a.rect_2024=b.new_square
	order by rect_2024;

	PROC EXPORT DATA= WORK.land3
	            OUTFILE= "Q:\mynd\Assessement_discard_and_the_like\WG\HAWG\wg2024\HAWGOutput\Landings_pr_square_2024_&year..csv" 
	            DBMS=csv REPLACE;
	RUN;

	proc sql;
	create table data9 as
	select Year, quarter, art, kategori, new_square, sum(hel)/1000 as Ton
	from data7
	where art = 'SIL' and ff_area not in ('22','23','24','25','26','27','28','28.1','29','30','31')
	group by Year, quarter, art, kategori, new_square
	order by new_square;

	proc transpose data=data9 out=land2a;
	by new_square;
	var ton;
	id art quarter kategori;
	run;

	proc sql;
	create table land3a as
	select *
	from wgsquare a full join land2a b
	on a.rect=b.new_square
	order by rect;

	PROC EXPORT DATA= WORK.land3a
	            OUTFILE= "Q:\mynd\Assessement_discard_and_the_like\WG\HAWG\wg2024\HAWGOutput\Landings_pr_square_subkategori_&year..csv" 
	            DBMS=csv REPLACE;
	RUN;

	proc sql;
	create table data9 as
	select Year, quarter, art, kategori, new_square, sum(hel)/1000 as Ton
	from data7
	where substr(ff_area, 1, 1) = '4' and art = 'SIL'
	group by Year, quarter, art, kategori, new_square
	order by new_square;

	proc transpose data=data9 out=land2b;
	by new_square;
	var ton;
	id art quarter kategori;
	run;

	proc sql;
	create table land3b as
	select *
	from wgsquare a full join land2b b
	on a.rect_trans=b.new_square
	order by rect_trans;

	PROC EXPORT DATA= WORK.land3b
	            OUTFILE= "Q:\mynd\Assessement_discard_and_the_like\WG\HAWG\wg2024\HAWGOutput\Landings_pr_square_subkategori_transfer_&year..csv" 
	            DBMS=csv REPLACE;
	RUN;
