/*exo 1*/
data pharynx;
infile "/folders/myfolders/TPSAS/Examen/pharynx.dat" expandtabs;
input case inst$ sex$ tx$ grade$ age cond$ site$ t_stage$ n_stage$ entry_dt status$ time;
proc print data=pharynx;
run;

proc freq data=pharynx;
	tables  inst sex tx grade cond site t_stage n_stage status / chisq;
run;

proc freq data=pharynx;
	tables t_stage*n_stage / chisq;
run;

proc means data=pharynx;
	var age time;
run;

proc corr data=pharynx;
	var age time;
run;

proc univariate data=pharynx normaltest;
	var age;
run;

proc univariate data=pharynx normaltest;
	var age;
	histogram age /normal;
	qqplot age /normal;
run;

proc plot data=pharynx;
	plot time*age="*" $sex;
run;

data q10;
	set pharynx;
	if (tx="1" & status="0") then qualitative="A";
	if (tx="1" & status="1") then qualitative="B";
	if (tx="2" & status="0") then qualitative="C";
	if (tx="2" & status="1") then qualitative="D";
proc print data=q10;
run;

data numeriques;
	set q10;
	keep age time;
	file "/folders/myfolders/TPSAS/Examen/numeriques.txt";
	put age time;
run;

data caracteres;
	set q10;
	keep case inst sex tx grade cond site t_stage n_stage entry_dt status qualitative;
	file "/folders/myfolders/TPSAS/Examen/caracteres.txt";
	put case inst sex tx grade cond site t_stage n_stage entry_dt status qualitative;
run;

/*exo 2*/
proc iml;
	use pharynx;
	read all var {age time} into X;
	close pharynx;
	print(X[93,]);
	X[93,1] = 57;
	print(X[93,]);
	V = J(nrow(X), 1, 0);
	do i=1 to nrow(V);
		if X[i, 1] <= 25 then V[i] = 1;
		if (25 < X[i, 1] & X[i, 1] < 50) then V[i] = 2;
		if (50 <= X[i, 1] & X[i, 1] <= 75) then V[i] = 3;
		if X[i, 1] > 75 then V[i] = 4;
	end;
	print(V);
	Y = X[,1] || V;
	print(Y);
	create table_Y from Y [colname={age categorie}];
	append from Y;
	close table_Y;
run;

/*exo 3*/
data tmp;
	set q10;
	drop age;
	data final;
		merge tmp table_Y;
		proc print data=final;
run;

data correct;
	set final;
	if case = 125 then delete;
	proc print data=correct;
run;

/*exo 5*/
%let m_tab = correct;
%let m_age=AGE; 
%let m_time=time; 
%let m_status=status; 
%let m_stage=t_stage; 

%macro q2(V1, V2, tab);
	proc corr data=&tab;
		var &V1 &V2;
	run;
%mend;
%macro q3(V3, V4, tab);
	proc freq data=&tab;
		tables &V3 &V4;
	run;
%mend;

%q2(&m_age, &m_time, &m_tab);
%q3(&m_status, &m_stage, &m_tab);





























