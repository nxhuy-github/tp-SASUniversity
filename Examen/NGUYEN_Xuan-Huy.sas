/*exo 1*/
/*question 1*/
data distance;
infile "/folders/myfolders/TPSAS/Examen/distance.csv" firstobs=2 delimiter=";";
input lieu$ age distance;
proc print data=distance;
run;

/*question 2*/
/*distance_corrige: table contient la colonne 'lieu' qui est corrige*/
data distance_corrige;
	set distance;
	if age = 7 then delete;
	if lieu = "Pa ris" then lieu = "Paris";
	if lieu = "Lyon" then lieu = "Lyon";
	proc print data = distance_corrige;
run;

/*question 3*/
data distance_corrige;
	set distance_corrige;
	if age >= 20 and age < 40 then categorie_age = 1;
	if age >= 40 and age < 60 then categorie_age = 2;
	proc print data=distance_corrige;
run;

/*question 4*/
proc sort data=distance_corrige;
	by lieu;
run;
proc means data=distance_corrige mean std p25 p75;
	by lieu;
	var distance;
	output out=stat mean= std= p25= p75= / autoname;
run;
data stat;
	set stat;
	moy = distance_Mean;
	s = distance_StdDev;
	Q1 = distance_P25;
	Q3 = distance_P75;
	IQR = Q3 - Q1;
	drop distance_Mean distance_StdDev distance_P25 distance_P75 _TYPE_ _FREQ_;
	proc print data=stat;
run;

/*question 5*/
proc sql;
	create table Tukey as
	select tab1.lieu, age, distance, moy, s, Q1, Q3
	from distance_corrige as tab1 inner join stat as tab2
	on tab1.lieu = tab2.lieu;
run;

/*question 6*/
data Tukey;
	set Tukey;
	if Q1-1.5*(Q3-Q1) > distance or  Q3+1.5*(Q3-Q1) < distance then outlier = 1;
	else outlier = 0;
	proc print data =Tukey;
run;

/*exo 2*/
/*question 1*/
proc freq data= distance_corrige;
	tables categorie_age lieu;
run;
proc freq data=distance_corrige;
	tables categorie_age*lieu / chisq;
run;

/*question 2*/
proc ttest data=distance_corrige alpha=0.1;
	var distance;
	class lieu;
run;

/*question 3*/
proc sgplot data=distance_corrige;
	vbox distance /category=lieu;
run;

/*exo 3*/
%let table = Tukey;
%let rep = distance;
%let mod = lieu;
%let ligne = 30;

%macro boxplot(Table, MyRep, Mod, ligne);	
	proc sgplot data=&Table;
		vbox &MyRep / category=&Mod;
		refline &ligne / axis = y LINEATTRS=(Color=black thickness=10);
	run;	
%mend;

%boxplot(&table, &rep, &mod, &ligne);





