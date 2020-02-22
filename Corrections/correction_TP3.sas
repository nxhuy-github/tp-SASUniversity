

/* création d'une table pour tester les codes */


data jeu1;
do i=1 to 10 by 1;
variable1=rannor(0);
output;
end;
run;


/* 1ere question */ 

%macro affiche(table);
/* pour définir le nom de la macro et les arguments qu'elle prend en entrée */
/* les paramètres en entrée sont les macros variables */
/* à l'intérieur de la macro  on les appelle en ajoutant & devant le nom de la macro variable*/

Proc print data=&table;
run;

%mend;

%affiche(jeu1);
options mprint mlogic;
/* options nomprint nomlogic; */
/* 2ème question */

%macro stat(table,variable); 

proc means data=&table;
var &variable;
output out=stat mean=m;
run;

data _null_;
/* avec cette instruction on peut récupérer les infos d'une table sans créer un nouvelle table */
set stat;
call symput ("moy",m);
/* on utilise call symput pour créer une macro variable à partir d'une observation contenue 
dans une variable d'une table SAS */
/* la macro variable  moy contient la moyenne de la variable */
/* call symput s'utilise toujours dans une étape data */

run;

%put « la valeur de la moyenne de la variable &variable de la table &table est &moy »;
/* % put permet d'afficher le résultat dans le journal */

%mend; 

%stat(jeu1);

/* 3ème question*/

%macro extraire(chaine,num_mot) ;

%let mot=%scan(&chaine,&num_mot) ;
/* on cree ue nouvelle macro variable appelée mot qui correspond au mot extrait, on utilise 
pour cela l'instruction %let */
/* la fonction scan permet d'extraire un mot d'une chaîne de caractère 
Comme on l'utilise dans une macro variable il faut rajouter % devant le nom de la fonction */

%put « le mot extrait est &mot »;

%mend ;

%extraire ("le logiciel SAS",2);

/* 4ème question */

%macro stat2(table,variable); 

proc means data=&table;
var &variable;
output out=stat mean=m std=s;
run;

data _null_;
set stat;
call symput ("moy",m);
call symput ("et",s);
run;

data simul;
%do i=1 %to 100 %by 1;
simul=rannor(0)*&et+&moy;
/* on appelle ici les macros variables contenant les paramètres de la loi à simuler */
output;
%end;
run;

%mend; 

%stat2(jeu1);


/* A RETENIR : une macro variable est crée:
- soit comme un argument de la macro 
- soit dans le code de la macro avec l'instruction %let 
- soit est extraite d'une table SAS avec l'instruction call symput */

/* dans tous les cas, quand on appelle la macro variable il faut penser au & devant */



/* question 5 */

%macro decoupe(table);

/* 1ère étape : récupérer le nombre de lignes de la table */
data _null_;
set &table nobs=nobs1;
call symput ("nligne",nobs1);
run;

/* 2ème étape : ajouter une colonne dans le tableau qui contient le numéro de la ligne */

data &table._nb_ligne;
set &table;
retain n 0;
n=n+1; 
run;

/* 3ème étape : créer successivement les tableaux qui contiennent la ligne i de la table */

%do i=1 %to &nligne %by 1;

data &table._&i.;
set &table._nb_ligne;
where n=&i;
run;

/* à la première itération de la boucle on réalise une table SAS qui s'appelle &table_1 et qui
contient seulement la ligne  de la table
/* on continue jusqu'à arriver à la fin du tableau */

/* penser à mettre des % devant les paramètres de la boucle do car on est dans une macro */
%end; /* fin de la boucle do */

%mend;

%decoupe(jeu1);


/* question 6 */

%macro puissance_test(m1,std1,n, H0);

%let nb_simul=100;
/* on va réaliser 1000 jeu de données de 10 valeurs */
/* on rentre le paramètre nombre de simul en macro variable avec %let */

%do i=1 %to &nb_simul ;

/* 1er étape générer le jeu de données */

data simul_&i;

%do j=1 %to &n;
result=rannor(0)*&std1+&m1;
output;

/* chaque table simul contient n simulations de la loi normale */
/* en tout 100 tables avec n simulations de la loi normale */
%end;

/* 2ème étape : réaliser le test de comp de moyennes pr chaque jeu de données */


proc ttest data=simul_&i H0=&H0 ; 
var result;
ods output Ttests=Ttest_&i;
run;

/* dans la table T_test_i on récupère la p.value du ttest correspond au jeu de données i */

/* pour l'instant les p.values des 100 simulations sont dans 100 fichiers différents*/

/* pour pouvoir calculer le % de cas ou p.value<0.05, il faut les regrouper 
dans le même table : 3ème étape */

/* si on est à la première itération on met dans la table les résultats de la 1ere itération */
%if &i=1 %then %do;
data bilan;
set Ttest_&i;
run;
%end;
/* sinon on ajoute les résultats du jeu i aux résultats des jeu i-1, i-2 déja présent dans la table 
bilan */

%else %do;
data bilan;
set bilan Ttest_&i;
run;

%end;

/* de cette manière là, à la fin de la première boucle do, la table bilan contient les 100 p.values
des 100 jeux de données */


%end;

/* 4ème étape : calculer le pourcentage de cas ou la p.value est < 0.05 */


PROC FORMAT ;
value signif low-<0.05= "<0.05"
	  0.05<-high=">0.05";
	  run;


title "pourcentage de jeu de données de &n valeurs où la moyenne est significativement 
différente de la moyenne théorique";

proc freq data=bilan;
tables Probt;
format Probt signif.;
run;


%mend ;

%puissance_test(m1=5,std1=2,n=10,H0=5);


