libname malib '/folders/myfolders/TPSAS/TP2';

proc import datafile='/folders/myfolders/TPSAS/TP2/dose_patients.csv' 
	out=malib.dose_patients_bis DBMS=CSV replace; 
	delimiter=';';
run;

proc print data = malib.dose_patients_bis NOOBS;
	format dose 10.1;
run;


proc sort data=malib.dose_patients_bis
	out=malib.second_dose_patients;
	by descending statut descending dose;
run;

proc delete data = malib.second_dose_patients;
run;

proc import datafile='/folders/myfolders/TPSAS/TP2/info_patient.txt'
	out=malib.info_patient_bis DBMS=TAB replace;
	delimiter='	';
run;

/*MERGE*/
data malib.info_patient_bis;
	set malib.info_patient_bis;
	rename id_patient=identifiant;
run;

proc sort data=malib.info_patient_bis;
	by identifiant;
run;

proc sort data=malib.dose_patients_bis;
	by identifiant;
run;

data malib.merge_dose_info_patients;
	merge malib.dose_patients_bis malib.info_patient_bis;
	by identifiant;
run;

/*SQL*/
data malib.info_patient_bis;
	set malib.info_patient_bis;
	rename identifiant=id_patient;
run;

proc sql;
	create table malib.merge_dose_info_patients_bis as
	select * from malib.dose_patients_bis as tab1 inner join malib.info_patient_bis as tab2
	on tab2.id_patient = tab1.identifiant;
quit;

proc sort data=malib.merge_dose_info_patients_bis;
	by identifiant statut sexe age fumeur;
run;

proc transpose data=malib.merge_dose_info_patients_bis out=malib.patient_t(drop=_NAME_)
prefix=dose_bmq;
	by identifiant statut sexe age fumeur;
	var dose;
	id biomarqueur;
run;

proc format ;
	value tranche
		low-<30= 'faible'
		30<-high= 'fort';
run;

data malib.patient_t;
	set malib.patient_t;
	format dose_bmq1 tranche.;
run;

proc freq data=malib.patient_t;
	tables sexe*fumeur sexe*statut/norow nocol chisq;
run;

proc sort data=malib.patient_t;
	by statut;
run;

proc means data=malib.patient_t mean std var median min max;
	by statut;
	var dose_bmq1 dose_bmq2;
	output out=malib.stat2;
run;

proc sort data=malib.patient_t;
	by age;
run;

proc means data=malib.patient_t mean std var median min max;
	by age;
	where age > 40;
	var dose_bmq1 dose_bmq2;
	output out=malib.stat3;
run;

proc sort data=malib.patient_t;
	by statut;
run;

data malib.patient_t;
	set malib.patient_t;
	format dose_bmq1 10.2;
run;

proc univariate data=malib.patient_t;
	by statut;
	var dose_bmq1 dose_bmq2;
	histogram / normal;
run;

proc univariate data=malib.patient_t normaltest;
	by statut;
	var dose_bmq1;
	histogram / normal;
run;


proc univariate data=malib.patient_t normaltest;
	by statut;
	var dose_bmq1;
	where dose_bmq1 < 30;
	histogram / normal;
run;


symbol1 v=dot c=blue;
symbol2 v=dot c=orange;
proc gplot data=malib.patient_t;
	plot age*dose_bmq1 age*dose_bmq2 / overlay legend;
run;

proc sgplot data=malib.merge_dose_info_patients_bis;
	scatter x=age y=dose / group=biomarqueur;
run;

proc import datafile='/folders/myfolders/TPSAS/TP2/loyer.csv' 
	out=malib.loyer_bis DBMS=CSV replace; 
	delimiter=';';
run;

axis1 order=(0 to 25 by 5);
proc boxplot data=malib.loyer_bis;
	plot loyer*situation / vaxis=axis1;
	by annee;
run;

proc contents data=malib.patient_t;
run;

proc rank data=malib.patient_t out=malib.patient_t_bis;
	var dose_bmq1;
	ranks my_rank;
run;

proc sort data=malib.patient_t_bis;
	by my_rank;
run;
























	








