/* creation de la librairie */
libname data 'C:\Users\Gabriela.Ciuperca\M2PRO\logiciel_SAS\an2018' ;

/* Question 1 : importer le fichier dose_patients */
data data.dose_patients;
	length statut$15;
	infile 'C:\Users\Gabriela.Ciuperca\M2PRO\logiciel_SAS\an2018\dose_patients.csv' firstobs=2  DLM=";";
	input identifiant statut$ biomarqueur dose;
run;

/* Une procédure existe pour également importer un fichier : proc import */
proc import datafile='C:\Users\Gabriela.Ciuperca\M2PRO\logiciel_SAS\an2018\dose_patients.csv' out=data.dose_patients_bis DBMS=CSV replace;
	delimiter=";"; 
run;
/* "DBMS" indique le type du fichier à importer,
"replace" permet de remplacer la table data.dose_bis si elle existe déjà
et "delimiter" indique le séparateur de colonnes du fichier à importer (; pour les csv)
*/


/* Question 2 */
proc print data=data.dose_patients noobs;
	format dose 10.1;
run;
/* "noobs" pour supprimer l'affichage du numéro d'observation 
 Le format 10.1 indique que la variable sera affichée avec 10 caractères dont 1 décimale */


/* Question 3 : Tri d'une table */
proc sort data=data.dose_patients;
	by statut dose;
run;
/* Par défaut, le tri se fait dans l'ordre croissant pour chaque colonne indiquée dans le by */

/* Pour trier par ordre décroissant, il faut précéder le nom de la colonne par "descending" */
proc sort data=data.dose_patients out=data.sort;
	by statut descending dose ;
run;
/* NB : Si on souhaite trier une table par ordre décroissant pour plusieurs colonnes, il faut mettre 
"descending" devant chaque colonne */

/* Suppression de la table data.sort */
proc delete data=data.sort data.dose_patients_bis;
run;
/* NB : On peut supprimer plusieurs tables en même temps */


/* Question 4 */
data data.info_patient;
infile 'C:\Users\Gabriela.Ciuperca\M2PRO\logiciel_SAS\an2018\info_patient.txt' firstobs=2  DLM='09'x;
input id_patient age sexe$ fumeur$;
run;

/* Autre option avec la proc import :*/
proc import datafile="C:\Users\Gabriela.Ciuperca\M2PRO\logiciel_SAS\an2018\info_patient.txt" out=data.info_patient2 dbms=TAB replace;
run;

/* Assemblage des 2 tables info_patient et dose_patients
Pour cela, il faut que les colonnes communes aient le même nom.
On renomme donc la colonne id_patient pour qu'elle corresponde à la colonne de la table data.dose */
data data.info_patient;
	set data.info_patient;
	rename id_patient=identifiant;
run;
proc print; run;

/* on trie les 2 tables par identifiant */
proc sort data=data.info_patient;
	by identifiant;
run;
proc print; run;
proc sort data=data.dose_patients;
	by identifiant;
run;
proc print; run;

/* On regroupe les deux tables en fonction de l'identifiant */
data data.patient;
	merge data.dose_patients data.info_patient;
	by identifiant;
run;
proc print; run;

/* On peut supprimer les individus qui n'étaient pas présent dans la table data.dose_patients */
data data.patient;
	set data.patient;
	if biomarqueur = . then delete;
run;

/* Les deux dernières étapes peuvent être regroupées en une seule */
data patient2;
	merge data.dose_patients data.info_patient;
	by identifiant;
	if biomarqueur = . then delete;
run;


/* Question 5 : idem avec PROC SQL */
proc sql;
	create table data.patients_bis as
	select * from data.dose_patients as tab1 INNER JOIN data.info_patient as tab2
	on tab1.identifiant=tab2.identifiant;
quit;
/* Avec la PROC SQL, on regroupe les deux tables plus rapidement, pas besoin que les colonnes 
aient le même nom (on évite l'étape rename), pas besoin de trier les tables (on évite l'étape PROC 
SORT), et on peut choisir de garder dans la table de sortie seulement les individus
présents dans les deux tables avec INNER JOIN (on évite de faire une étape delete) */


/* Question 6 : Transposition de la table de données */
proc sort data=data.patient;
	by identifiant Statut sexe Age fumeur ;
run;
proc transpose data=data.patient out=data.patient_t(drop=_NAME_) prefix=Dose_Bmq;
	by identifiant Statut sexe Age fumeur ;
	var dose;
	id biomarqueur;
run;
/* "prefix" permet de donner un préfixe aux colonnes transposées et "id" permet de compléter le 
préfixe indiqué. Sans ces deux options, les colonnes seront nommées par défaut "COL1" et "COL2". 
   "drop=_NAME_" permet de supprimer la colonne qui est automatiquement créée lors d'une proc transpose qui contient 
le nom de la colonne qui a été transposée
*/



/* Question 7 : proc FORMAT permet de créer des formats d'affichage particuliers */
proc format ;
	value tranche 
	  low-<30= "faible"
	  30<-high="fort";
run;
/* On peut appliquer le format à la variable dose_bmq1 ; la variable ne change pas, seulement
son affichage */
data data.patient_t;
	set data.patient_t;
	format dose_bmq1 tranche.;
run;

/* Pour revenir au format numérique : */
data data.patient_t;
	set data.patient_t;
	format dose_bmq1 10.3;
run;


/* Question 8 */
/* Pour supprimer les pourcentages en ligne et en colonne, ajouter les options norow et nocol 
Pour le test du Khi 2, ajouter l'option chisq */
proc freq data=data.patient_t ;
	tables sexe statut*fumeur / norow nocol chisq;
run;


/* Question 9 */
proc sort data=data.patient_t;
	by statut;
run;

proc means data=data.patient_t mean std median min max var  ;
	by statut ;
	var dose_bmq1 dose_bmq2; /* possibilité de calculer les stats sur 2 variables en même temps */
	output out=stat1 mean=mean_bmq1 mean_bmq2 ; /* pour stocker les moyennes dans une table */
run;
/* Le by permet de réaliser une analyse différente pour chaque modalité de la variable statut
Et pour utiliser le by, il faut réaliser un tri de la table sur ces variables */

/* Pour stocker toutes les stats dans une même table : 
+ Ajout de l'option noprint pour ne rien afficher dans l'output */
proc means data=data.patient_t mean std median min max var noprint ; 
	by statut ;
	var dose_bmq1 dose_bmq2;
	output out=stat2;
run;
/* Permet de stocker toutes les stats d'une variable dans une même colonne */

/* Une autre manière de stocker toutes les stats dans une table : */
proc means data=data.patient_t ;
	by statut ;
	var dose_bmq1 dose_bmq2;
	output out=stat3  mean=Moyenne N=N std=Ecart_Type median=Mediane min=Minimum max=Maximum var=Variance;
run;
/* Permet de stocker toutes les stats d'une variable sur une même ligne dans des colonnes différentes 
= stat3 est une transposition de la table stat2 */

/* Enregistrement de cette table de statistiques par la procédure EXPORT */
proc export data=stat3 outfile='F:\TP SAS\TP2\Statistiques sur les doses des biomarqueurs 1 et 2.csv' DBMS=CSV replace;
	delimiter=";"; 
run;

/* Calcul de statistiques pour les patients agés de plus de 40 ans*/
proc means data=data.patient_t mean std median min max var  ;
	by statut ;
	where age>40;
	var dose_bmq1 dose_bmq2;
	output out=stat4 mean=mean_bmq1 mean_bmq2 ;
run;
/* where permet de filtrer les individus sur lesquels on veut réaliser l'analyse */

/* Autre possibilité en positionnant le where juste après la table data.patient_t : */
proc means data=data.patient_t(where=(age>40)) mean std median min max var  ;
	by statut ;
	var dose_bmq1 dose_bmq2;
	output out=stat4_bis mean=mean_bmq1 mean_bmq2 ;
run;


/* Question 10 */
proc sort data=data.patient_t;
	by statut ;
run;
proc univariate data=data.patient_t;
	by statut  ;
	var dose_bmq1 dose_bmq2;
	histogram / normal ;
run;

/* On supprime la valeur aberrante pour le biomarqueur 1 avec le statut non malade */
data data.patient_bis;
	set data.patient_t;
	if dose_bmq1>40 and statut="non malade" then delete;
run;

/* On réalise de nouveau l'analyse */
proc univariate data=data.patient_bis;
	var dose_bmq1 dose_bmq2;
	by statut ;
	histogram / normal ;
run;


/* Question 11 */
proc sort data=data.patient_t;
	by statut;
run;

proc ttest data=data.patient_t ;
	var dose_bmq1 dose_bmq2;
	class statut;
	ods output Ttests=result_Ttests;
run;
/* "class" est l'instruction qui indique qu'il faut comparer les moyennes obtenues selon les 
deux modalités de la variable qualitative "statut" */



/* Question 12 */
symbol1 v=dot c=big;
symbol2 v=square c=purple;
proc gplot data=data.patient_t;
	plot (dose_bmq1 dose_bmq2)*age / overlay legend;
run;
/* L'option "legend" permet d'afficher la légende. Si on veut modifier cette légende, utiliser l'instruction legend */
/* L'option "overlay" permet d'afficher tous les tracés sur le même graph */


/* Question 13 */
proc sgplot data=data.patient;
	scatter x=age y=dose / group=biomarqueur;
run;


/* Question 14 */
data data.loyer;
	infile 'F:\TP SAS\TP2\loyer.csv' firstobs=2  DLM=';';
	input annee$ situation$ loyer;
run;

proc sort data=data.loyer;
	by  annee situation;
run;

/* Pour comparer avan/après modification des options : */
proc boxplot data=data.loyer;
	plot loyer*situation ;
	by annee;
run;

axis1 order=(2.5 to 26 by 2.5) style=1 width=1 c=blue label=("Loyer" ) ;
axis2 style=1 width=1 value=(angle=45 height=8pt) c=blue minor=NONE ;
title 'prix du loyer en fonction de la situation';
proc boxplot data=data.loyer;
	plot loyer*situation / vaxis=axis1 haxis=axis2 vref=10 caxis=black ctext=blue  cboxes=dagr  cboxfill=yellow idcolor=blue idsymbol=circle idcolor=cyan boxstyle=schematic;
	by annee;
run;

/* Quand on veut générer un seul boxplot il faut rajouter une variable qui prend la même 
modalité pour toutes les observations de la table */
data data.loyer;
	set data.loyer;
	v=1;
run;

proc boxplot data=data.loyer;
	plot loyer*v / haxis=axis2;
run;


/* Question 15 */
/* ods rtf file permet de copier les sorties générées dans l'output dans un fichier rtf : */
ods rtf file='F:\TP SAS\TP2\Q2 - Results proccontents.rtf';

	proc contents data=data.dose_patients;
	run;

ods rtf close;
/* pour terminer le copiage dans le fichier rtf */


/* Question 16 */
proc rank data=data.patient_t out=resultat_rank;
	var dose_bmq1;
	ranks rang;
run;

proc sort data=resultat_rank;
	by rang;
run;
/* La proc RANK permet d'attribuer un rang à chaque observation en fonction d'une variable */


/* Question 17 */
proc sort data=data.loyer;
	by annee situation;
run;

proc anova data=data.loyer outstat=stat;
	class annee situation;
	model loyer=annee situation annee*situation;
	means annee*situation ;
run;
/* class définit les variables qualitatives = les facteurs de l'anova */


/* Question 18 */
data data.poids;
	infile 'F:\TP SAS\TP2\poids.csv' firstobs=2  DLM=';';
	input annee poids_N poids_1an;
run;

proc reg data=data.poids outest=data.stat edf tableout;
	model poids_1an = poids_N;
	plot poids_1an * poids_N ;
	plot r. * p. ;
	plot rstudent. * p.;
	output out=data.results p=prediction lcl=borne_inf ucl=borne_sup cookd=Cook;
run;


/* Question 19 */
proc sort data=data.results;
	by poids_N;
run;

symbol1 v=triangle c=blue h=1 interpol=none;
symbol2 v=none c=red interpol=join w=2;
symbol3 v=none c=green interpol=join l=2 w=1;
symbol4 v=none c=green interpol=join w=1 l=2;
goptions ftext="arial" htext=1 ctext=black;
legend1 label=none value=( "valeurs observées"  "valeurs prédites"  "borne_inf"  "borne_sup") position=(top inside left) cborder=blue cshadow=blue across=1 cframe=yellow ; 

proc gplot data=data.results;
	plot poids_1an*Poids_N prediction*poids_N borne_inf*poids_N borne_sup*poids_N  / overlay legend=legend1;
	title "resultats de la regression lineaire" ;
run;
/* "overlay" permet d'afficher tous les tracés sur le même graph */

/* NB : Pour effacer les options graphiques modifiées via l'instruction goptions, il suffit de lancer la ligne :
goptions reset=all;
*/



/* Autres exemples de graphiques :
La proc gchart permet de réaliser des histogrammes, des diagrammes circulaires des variables qualitatives */
proc gchart data=data.loyer;
	hbar situation / group=annee ;
	vbar situation;
	star situation;
	block situation;
	pie annee;
run;

/* Un autre exemple de procédure pour faire des graphiques */
proc sgpanel data=data.loyer;
	panelby situation / novarname columns=3 ;
	vbar annee / group=annee;
run;
