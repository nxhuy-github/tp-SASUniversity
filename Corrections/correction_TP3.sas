

/* cr�ation d'une table pour tester les codes */


data jeu1;
do i=1 to 10 by 1;
variable1=rannor(0);
output;
end;
run;


/* 1ere question */ 

%macro affiche(table);
/* pour d�finir le nom de la macro et les arguments qu'elle prend en entr�e */
/* les param�tres en entr�e sont les macros variables */
/* � l'int�rieur de la macro  on les appelle en ajoutant & devant le nom de la macro variable*/

Proc print data=&table;
run;

%mend;

%affiche(jeu1);
options mprint mlogic;
/* options nomprint nomlogic; */
/* 2�me question */

%macro stat(table,variable); 

proc means data=&table;
var &variable;
output out=stat mean=m;
run;

data _null_;
/* avec cette instruction on peut r�cup�rer les infos d'une table sans cr�er un nouvelle table */
set stat;
call symput ("moy",m);
/* on utilise call symput pour cr�er une macro variable � partir d'une observation contenue 
dans une variable d'une table SAS */
/* la macro variable  moy contient la moyenne de la variable */
/* call symput s'utilise toujours dans une �tape data */

run;

%put � la valeur de la moyenne de la variable &variable de la table &table est &moy �;
/* % put permet d'afficher le r�sultat dans le journal */

%mend; 

%stat(jeu1);

/* 3�me question*/

%macro extraire(chaine,num_mot) ;

%let mot=%scan(&chaine,&num_mot) ;
/* on cree ue nouvelle macro variable appel�e mot qui correspond au mot extrait, on utilise 
pour cela l'instruction %let */
/* la fonction scan permet d'extraire un mot d'une cha�ne de caract�re 
Comme on l'utilise dans une macro variable il faut rajouter % devant le nom de la fonction */

%put � le mot extrait est &mot �;

%mend ;

%extraire ("le logiciel SAS",2);

/* 4�me question */

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
/* on appelle ici les macros variables contenant les param�tres de la loi � simuler */
output;
%end;
run;

%mend; 

%stat2(jeu1);


/* A RETENIR : une macro variable est cr�e:
- soit comme un argument de la macro 
- soit dans le code de la macro avec l'instruction %let 
- soit est extraite d'une table SAS avec l'instruction call symput */

/* dans tous les cas, quand on appelle la macro variable il faut penser au & devant */



/* question 5 */

%macro decoupe(table);

/* 1�re �tape : r�cup�rer le nombre de lignes de la table */
data _null_;
set &table nobs=nobs1;
call symput ("nligne",nobs1);
run;

/* 2�me �tape : ajouter une colonne dans le tableau qui contient le num�ro de la ligne */

data &table._nb_ligne;
set &table;
retain n 0;
n=n+1; 
run;

/* 3�me �tape : cr�er successivement les tableaux qui contiennent la ligne i de la table */

%do i=1 %to &nligne %by 1;

data &table._&i.;
set &table._nb_ligne;
where n=&i;
run;

/* � la premi�re it�ration de la boucle on r�alise une table SAS qui s'appelle &table_1 et qui
contient seulement la ligne  de la table
/* on continue jusqu'� arriver � la fin du tableau */

/* penser � mettre des % devant les param�tres de la boucle do car on est dans une macro */
%end; /* fin de la boucle do */

%mend;

%decoupe(jeu1);


/* question 6 */

%macro puissance_test(m1,std1,n, H0);

%let nb_simul=100;
/* on va r�aliser 1000 jeu de donn�es de 10 valeurs */
/* on rentre le param�tre nombre de simul en macro variable avec %let */

%do i=1 %to &nb_simul ;

/* 1er �tape g�n�rer le jeu de donn�es */

data simul_&i;

%do j=1 %to &n;
result=rannor(0)*&std1+&m1;
output;

/* chaque table simul contient n simulations de la loi normale */
/* en tout 100 tables avec n simulations de la loi normale */
%end;

/* 2�me �tape : r�aliser le test de comp de moyennes pr chaque jeu de donn�es */


proc ttest data=simul_&i H0=&H0 ; 
var result;
ods output Ttests=Ttest_&i;
run;

/* dans la table T_test_i on r�cup�re la p.value du ttest correspond au jeu de donn�es i */

/* pour l'instant les p.values des 100 simulations sont dans 100 fichiers diff�rents*/

/* pour pouvoir calculer le % de cas ou p.value<0.05, il faut les regrouper 
dans le m�me table : 3�me �tape */

/* si on est � la premi�re it�ration on met dans la table les r�sultats de la 1ere it�ration */
%if &i=1 %then %do;
data bilan;
set Ttest_&i;
run;
%end;
/* sinon on ajoute les r�sultats du jeu i aux r�sultats des jeu i-1, i-2 d�ja pr�sent dans la table 
bilan */

%else %do;
data bilan;
set bilan Ttest_&i;
run;

%end;

/* de cette mani�re l�, � la fin de la premi�re boucle do, la table bilan contient les 100 p.values
des 100 jeux de donn�es */


%end;

/* 4�me �tape : calculer le pourcentage de cas ou la p.value est < 0.05 */


PROC FORMAT ;
value signif low-<0.05= "<0.05"
	  0.05<-high=">0.05";
	  run;


title "pourcentage de jeu de donn�es de &n valeurs o� la moyenne est significativement 
diff�rente de la moyenne th�orique";

proc freq data=bilan;
tables Probt;
format Probt signif.;
run;


%mend ;

%puissance_test(m1=5,std1=2,n=10,H0=5);


