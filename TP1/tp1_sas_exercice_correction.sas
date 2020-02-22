/* Fiche de TP1 */
data ex1;
input groupe$ taille poids;
cards;
A 175 85
B 190 92
C . . 
;
run;
/* EXERCICE 1 */
/* question 1 */
data math1;
  input nom$ note_math;
  cards;
  n1 7
  n2 6
  n3 14
  n4 19
  n5 16
  n6 8
  n7 11
  n8 18
  n9 12
  n10 14
  n11 10
  n12 12
  n13 .
  n14 7
  n15 15
  ;
  run;
/* question 2 */
data physique1;
  input nom$ note_physique;
  cards;
  n1 9
  n2 5
  n3 12
  n4 16
  n5 17
  n6 10
  n7 13
  n8 14
  n9 12
  n10 13
  n11 .
  n12 13
  n13 .
  n14 10
  n15 16
  ;
  /* question 3*/
 data note1;
     merge math1 physique1;
 proc print data=note1; 
 title "Le tableau NOTE1 ";
run;

/* question 4 */
 data note2;
 input nom$ note_math note_physique;
 cards;
 n16 17 19
 n17 12 15
 n18 14 12
 ;
 proc print data=note2; 
title "Le tableau NOTE2"; 
run;

 /* question 5 */
 data note;
 set note1 note2;
 proc print data=note; 
 title "NOTE";
run;


 /* EXERCICE 2 */
/* question 1 */
 data auto;
 infile "C:\Users\Gabriela.Ciuperca\M2PRO\logiciel_SAS\auto.txt" expandtabs;
  input mpg 1-4 cylinders 17 displace 33-36 horseplace 49-52 accel 65-69 year 81-82
    weight 97-100 origin 113 make$ 129-140 model$ 145-156 price 160-164;
	if _N_<141;
 run;
 /* question 2 */
data auto1;
   set auto;
   ARRAY varCar $ _CHARACTER_ ;
	ARRAY varNum _NUMERIC_ ;
RUN ;
data auto2;
  set auto1; 
  ARRAY varCar $ _CHARACTER_ ;
	IF NMISS(OF _NUMERIC_)>0 THEN DELETE ;
	DO OVER varCar ;
		IF MISSING(varCar) THEN DELETE ;
	END ;
RUN ;

   proc print data=auto2; run;
   /* question 3 */
   data question3;
   set auto2; 
     conso=(1.609/4.5)/mpg;  /* litres/km */
	 conso2=conso*100; 
	 run;
	 proc print data=question3; run;
	data usa;
	  set question3;
	  if origin=1;   /* ce tableau va contenir qseulement les observations avec des voitures USA */
      keep mpg accel weight price; /* on garde dans le tableau seulement ces 4 variables  */
file "C:\Users\Gabriela.Ciuperca\M2PRO\logiciel_SAS\auto_usa.txt";  /* on va écrire dans ce fichier */
  put mpg accel weight price; run;  /* on spécifie les variables à écrire dans le fichier spécifié */

data euro;
	  set question3;
	  if origin=2; 
	  keep mpg accel weight price;   /* garder seulement ces 4 variables */ 
	   file "C:\Users\Gabriela.Ciuperca\M2PRO\logiciel_SAS\auto_euro.txt";  /* pas du tout convenable */
	   put (_ALL_); run;    /* on écrit toutes les variables du tableau EURO */
data asie;
	  set question3;
	  keep mpg accel weight price; 
	  if origin=3; run;

data question6;   /* la première façon de faire */
  set auto;
  drop make model;
  proc sort data=question6; 
    by descending mpg ;
	run;
	proc print data=question6; run;
proc sort data=auto out=q6bis(drop=make model);  /* la 2ème façon de faire */
 by descending mpg ;
	run;
	proc print data=q6bis; run;


   /* Exercice 3 */
data svt;
  input nom$ note_svt;
  cards;
  n14 17
  n8 16
  n3 11
  n4 15
  n5 15
  n1 8
  n7 12
  n11 13
  n9 10
  n10 14
  n2 9
  n12 14
  n13 14
  n6 17
  n15 15
  n16 12
  n17 14
  n18 13
  ;
  proc print data=svt; run;
  proc sort data=svt;
  by  nom;
  proc sort data=note ;
  by  nom; 
  run;

  /** question 2 */
  data final;
    merge note svt;
	by nom;

	proc print data=final;
	run;

	/* question 3 */

proc means data=final;
  var note_math note_physique note_svt;
  run;
 proc plot data=final;
    plot note_math*note_physique ; 
	run;
	proc plot data=final;
    plot note_math*note_physique="*"; 
	run;

  proc plot data=final;
    plot note_math*note_physique $note_svt; /* pour avoir toute la valeur de lqa note en SVT */
	run;

	proc sort data=final;
	  by note_physique;
symbol1 V=star C=blue i=join;
proc gplot data=final;
   plot note_math*note_physique;
   run;
   quit;

   /* dans un fichier */
   ods rtf body="C:\Users\Gabriela.Ciuperca\M2PRO\logiciel_SAS\tp1_graphe1.rtf";
   ods graphics on;
proc gplot data=final;
   plot note_math*note_physique;
   run;
   quit;

   ods graphics off;
   ods rtf close;

   /* correlations */
proc corr data=final pearson kendall spearman;
  var note_math note_physique note_svt;
  run;

  /* histogramme avec univariate*/
  proc univariate data=final normal plot;  /* test de normalité */
    histogram note_math note_physique note_svt /normal;  /* avec la densité loi normale */
	qqplot note_math note_physique note_svt/normal;
  run;

  /* histogramme avec gchart*/
 /* on pourrait faire aussi avec PROC CHART, mais c'est plus basique */
  proc gchart data=final;
    vbar note_math note_physique note_svt; run;
	 hbar note_math note_physique note_svt; 
	run;
	quit;
data final1;
  set final;
    nn=1;  /* création d une variable fictive */
	proc boxplot data=final1;
	 plot(note_math note_physique note_svt)*nn;
	 run;
