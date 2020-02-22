/*exo 1*/

data mercury;
infile "/folders/myfolders/TPSAS/Examen/mercury.txt" expandtabs;
input id lake$ alkalinity ph calcium cholophyll avg_m nosamples minn maxx yrstd age_data;
run;

proc print data=mercury;
run;

data mercury_age no_age;
	set mercury;
	if age_data = 1 then do; 
		drop age_data; 
		output mercury_age;
		end;
	else do;
		drop age_data; 
		output no_age;
		end;
run;

proc print data=mercury_age;
proc print data=no_age;

proc means data=mercury_age;
	var alkalinity ph calcium cholophyll avg_m nosamples minn maxx yrstd;
run;

proc corr data=mercury_age;
	var alkalinity ph avg_m yrstd;
run;

proc univariate data=mercury_age normal;
	var avg_m yrstd;
	histogram avg_m yrstd/normal; 
run;

data n_mercury;
	set mercury;
	log_alkalinity = log(alkalinity);
	log_yrstd = log(yrstd);
run;

proc univariate data=n_mercury normaltest;
	var log_alkalinity log_yrstd;
	histogram log_alkalinity log_yrstd /normal;
run;

proc means data=n_mercury;
	var log_alkalinity log_yrstd;
run;

data n2_mercury;
	set n_mercury;
	diff = log_alkalinity - log_yrstd;
	proc univariate data = n2_mercury;
		var diff;
	run;

/*exo 2*/
proc iml;
	use mercury;
	read all var {alkalinity ph avg_m yrstd} into X;
	print(X);
	V = X[,3] - X[,4];
	print(V);
	Z = J(nrow(X), 1, 1);
	do i=1 to nrow(Z);
		if V[i] < 0 then Z[i] = -1;
		if V[i] = 0 then Z[i] = 0;
		if V[i] > 0 then Z[i] = 1;
	end;
	VZ = V || Z;
	print(VZ);
	Y = X || VZ;
	print(Y);
	create nouveau from Y [colname={alkalinity ph avg_m yrstd diff Z}];
	append from Y;
	close nouveau;	
quit;

/*exo 3*/
data final;
	merge work.mercury work.nouveau;
	v = diff;
	z = Z;
	keep id lake alkalinity ph calcium cholophyll avg_m nosamples minn maxx yrstd age_data v z;
	proc print data=final;
run;

/*exo 4*/
proc sort data=final ;
	    by pH; run;
		axis1 value=(c=green) label=(c=green "alkalinity");
		axis2 value=(c=black) label=(c=black "pH");
	  proc gplot data=final;
	  plot alkalinity*pH / vaxis=axis1 haxis=axis2;
	  symbol1 interpol=j color=blue v=star;
	  title "alkalinity fonction du pH";
	  run;
quit;

/*exo 5*/
%let tableau = final;
%let V1 = pH;
%let V2 = alkalinity;
%let V3 = calcium;
%let V4 = avg_m;

%macro regression(X1, X2, X3);
	proc reg data=&tableau;
		model &X3 = &X1 &X2;
	run;
%mend;

%regression(&V1, &V2, &V4);
%regression(&V1, &V3, &V4);











