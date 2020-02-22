/*exo 1*/
data ex1;
input groupe$ taille poids;
cards;
A 175 85
B 190 92
C . . 
;
run;

%macro affiche(table);
	proc print data = &table;
	run;
%mend;

%affiche(ex1);

/*exo 2*/
%macro stat(table, variable);
	proc means data=&table;
	var &variable;
	output out= mytable mean=m;
	run;
	
	data _null_;
	set mytable;
	call symput ("moy", m);
	run;
	
	%put "la valeur de la moyenne de la variable &variable de la table &table est &moy";
%mend;

%stat('/folders/myfolders/TPSAS/TP2/dose_patients_bis.sas7bdat', dose);

/*exo 3*/
%macro extraire(chaine, num_mot);
	%let mot = %scan(&chaine, &num_mot, " ");
	%put "le mot extrait est &mot";
%mend;

%extraire("NGUYEN Xuan Huy", 1);

/*exo 4*/
%macro stat_bis(table, variable);
	proc means data=&table;
	var &variable;
	output out=mystat mean=m std=std;
	run;
	
	data _null_;
	set mystat;
	call symput('moy', m);
	call symput('ecart', std);
	run;
	
	data simul;
	%do i=1 %to 100;
		col = rannor(0)*&moy + &ecart;
		output;
	%end;
	run;
%mend;

%stat_bis('/folders/myfolders/TPSAS/TP2/dose_patients_bis.sas7bdat', dose);

/*exo 5*/
%macro decoupe(table);
	data _null_;
	set &table nobs=n;
	call symput ("nbligne", n);
	run;
	
	data tmp;
	set &table;
	num_ligne = _n_;
	run;
	
	%do i=1 %to &nbligne %by 1;
		data &table._&i.;
			set tmp;
			where num_ligne = &i;
		run;
	%end;
%mend;

%decoupe('/folders/myfolders/TPSAS/TP2/dose_patients_bis.sas7bdat');

/*exo 6*/
%macro exo6(nobs, nsamp, moy, ecart);
	%do i=1 %to &nsamp;
		data table_&i.;
		%do j=1 %to &nobs;
			col = rannor(0)*&moy + &ecart;
			output;
		%end;
		run;
	%end;
	
	ods graphics on;
	%do i=1 %to &nsamp;
		proc ttest data=table_&i.;
			var col;
			ods output Ttests=result_Ttests;
		run;
	%end;
	ods graphics off;
%mend;
%exo6(10, 5, 5, 2);

%macro exo6_bis(nobs, nsamp, moy, sigma);
	data table;
	%do i=1 %to &nsamp;
		%do j=1 %to &nobs;
			group = &i;
			col = rannor(0)*&sigma + &moy;
			output;
		%end;
	%end;
	run;
	
	ods graphics on;
	%do i=1 %to &nsamp;
		proc ttest data=table h0=&moy;
			var col;
			by group;
			ods output Ttests=result_Ttests;
		run;
	%end;
	ods graphics off;
%mend;
%exo6_bis(10, 5, 5, 2);








