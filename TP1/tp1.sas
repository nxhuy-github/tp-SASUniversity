/*Exercice 1*/
data math1;
input Nom$ Note_Math @@;
cards;
n1 7 n2 6 n3 14 n4 19 n5 16 n6 8 n7 11 n8 18
n9 12 n10 14 n11 10 n12 12 n13 . n14 7 n15 15
run;

data physique1;
input Nom$ Note_Physique @@;
cards;
n1 9 n2 5 n3 12 n4 16 n5 17 n6 10 n7 13 n8 14
n9 12 n10 13 n11 . n12 13 n13 . n14 10 n15 16
run;

data notes1;
	merge math1 physique1;
run;

data notes2;
input Nom$ Note_Math Note_Physique;
cards;
n16 17 19
n17 12 15
n18 14 12
run;

data notes3;
	set notes1 notes2;
run;

/*Exercice 3*/
data svt;
input Nom$ SVT @@;
cards;
n14 17 n8 16 n3 11 n4 15 n5 15 n1 8 n7 12 n11 13
n9 10 n10 14 n2 9 n12 8 n13 14 n6 17 n15 15 n16 12 n17 14 n18 13
run;

proc sort data=svt;
by Nom;
run;

proc sort data=notes3;
by Nom;
run;

data notes4;
	merge notes3 svt;
	by Nom;
run;

data moyennes;
	set notes4;
run;
proc means data = moyennes;
var Note_Math;
var Note_Physique;
var svt;
run;

proc gplot data = moyennes;
plot Note_Math*Note_Physique;
run;

proc corr data = moyennes;
var Note_Math Note_Physique svt;
run;

proc univariate data = moyennes;
histogram;
run;

data moyennes;
	set moyennes;
	Y = 1;
run;

proc sort data=moyennes;
by Note_Math;
run;

proc boxplot data = moyennes;
plot Note_Physique*Note_Math;
run;


	












