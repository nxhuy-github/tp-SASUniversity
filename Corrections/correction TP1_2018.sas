/* TP1 SAS */

/* Question 1: creation de la librairie malib*/
libname malib 'C:\Users\Gabriela.Ciuperca\M2PRO\logiciel_SAS\an2018';


/* Question 2: création de la table SAS malib.note1 */
data malib.note1;
input Nom$ naissance DDMMYY10. sexe$ Note_Math Note_Physique;
cards;
Anne-Laure 10/05/1985 F 17 12
Antoine 24/04/1985 M 9 14
Claire 18/09/1985 F 6 9
David 05/01/1986 M 12 7
run;

/* Le symbole $ indique qu'il faut lire la variable comme une chaîne de caractère, par défaut,
si l'on indique rien la  variable est lue comme numérique
Le symbole DDMMYY10. indique qu'il faut lire la variable sous le format date jj/mm/aaaa
Dans la table SAS, l'affichage de la colonne naissance ne correspond pas à celle voulue :
SAS présente la variable naissance sous le format date par défaut (nb de secondes depuis 01/01/1960)
Pour changer ça, il faut utiliser l'instruction format qui modifiera le format d'affichage */

/* FORMAT */
data note1;
input Nom$ naissance DDMMYY10.  sexe$ Note_Math Note_Physique;
format naissance ddmmyy10.;
cards;
Anne-Laure 10/05/1985 F 17 12
Antoine 24/04/1985 M 9 14
Claire 18/09/1985 F 6 9
David 05/01/1986 M 12 7
run;

/* On peut tester d'autre type d'affichage de la variable naissance */
data malib.n1;
input Nom$ naissance DDMMYY10.  sexe$ Note_Math Note_Physique;
format naissance FRADFWDX.; /* Affichage avec le mois en lettre et en français */
cards;
Anne-Laure 10/05/1985 F 17 12
Antoine 24/04/1985 M 9 14
Claire 18/09/1985 F 6 9
David 05/01/1986 M 12 7
run;

data note1;
input Nom$ naissance DDMMYY10.  sexe$ Note_Math Note_Physique;
format naissance date9.1; /* Affichage avec le mois en lettre abrégé et en anglais */
cards;
Anne-Laure 10/05/1985 F 17 12
Antoine 24/04/1985 M 9 14
Claire 18/09/1985 F 6 9
David 05/01/1986 M 12 7
run;
/* NB : Le format correspond juste à l'affichage de la variable et ne change pas sa valeur */

/* LENGTH */
/* Par défaut, la longueur d'une variable SAS est de 8 bites
Pour augmenter la taille d'une variable, il faut utiliser l'instruction length */
data note21;
length Nom $10;
input Nom$ naissance DDMMYY10. sexe$ Note_Math Note_Physique;
format naissance DDMMYY10.;
cards;
Anne-Laure 10/05/1985 F 17 12
Antoine 24/04/1985 M 9 14
Claire 18/09/1985 F 6 9
David 05/01/1986 M 12 7
run;

/* Une autre possibilité pour modifier la taille de la variable Nom : */
data note22;
input Nom$ :10. naissance DDMMYY10. sexe$ Note_Math Note_Physique;
format naissance DDMMYY10.;
cards;
Anne-Laure 10/05/1985 F 17 12
Antoine 24/04/1985 M 9 14
Claire 18/09/1985 F 6 9
David 05/01/1986 M 12 7
run;


 /* Question 3:  importer le fichier note2.csv */
data note2;
infile 'C:\Users\Gabriela.Ciuperca\M2PRO\logiciel_SAS\an2018\note2.csv' firstobs=2  DLM=";";
length Nom $10;
input Nom$ naissance DDMMYY10.  sexe$ Note_Math Note_Physique;
format naissance DDMMYY10.;
run;
/* firstobs indique la ligne à partir de laquelle il faut lire les données dans le fichier
DLM indique le séparateur des colonnes dans le fichier, pour les CSV, c'est ; */

proc print data=note2;
run;

/* NB : import pour les colonnes à taille fixe*/
data malib.test;
input identifiant 1-4 sexe$ 5 salaire 9-13;
cards;
2550F***32000
2214M***45650
2612M***63000
;
run;
proc print data=malib.test; run;


 /* Question 4 : copie d'une table */
data malib.copie;
        set note1;
run;
proc print data=malib.copie; run;

 /* et concaténation de 2 tables dans la table note : */
data malib.note;
        set note1 note2;
run;

proc print ;
title "Le tableau malib.note";
run;


/* Question 5: filtrage d'observation avec l'instruction where  */
data femme;
        set malib.note;
        where Sexe="F";
run;
proc print;
title"tableau femme"; run;

/* Question 6 : idem mais avec l'instruction : if then delete */
data homme;
        set malib.note;
        if Sexe="F" then delete;
run;
proc print ;
title "tablea homme"; run;


/* Question 7 : création de 2 tables à partir de la table note */
data tab1 tab2;
        set malib.note;
        if sexe="F" and note_Math in (10,12,14) then output tab1;
        else output tab2;
run;

/* tab1 va contenir les étudiantes ayant des notes en mathématique à 10, 12 ou 14
tab2 va contenir tous les autres étudiant(e)s
*/

/* Question 8 : filtrage d'infos avec where pour les élèves ayant au moins 10 dans une des 2 matières */
data moy;
        set malib.note;
        where note_Math>=10 or note_Physique>=10;
run;

/* on peut aussi utiliser le symbole | à la place de or : */
data moy2;
        set malib.note;
        where note_Math>=10 | note_Physique>=10;
run;


/*Question 9 : sélection de variable avec keep  */
data Math;
        set malib.note;
        keep Nom Naissance Sexe Note_Math;
run;


/* Question 10 : idem mais avec l'instruction drop*/
data Physique;
        set malib.note;
        drop Note_Math;
run;

      proc print data=math;
proc print data=physique; run;

/* Question 11 : Fusionner les tables avec l'instruction merge*/
data note_bis;
        merge Math Physique;
run;
/* Les infos des 2 tables sont concaténées ligne par ligne */

proc print data=note_bis;
title "tab note_bis"; run;

/* Question 12: ajout de colonnes */
data malib.note;
        set malib.note;
        moyenne=(Note_Math + Note_Physique)/2;
        annee=year(naissance);
run;

/* On peut également utiliser la fonction mean() pour calculer la moyenne de 2 colonnes existantes : */
data malib.note;
        set malib.note;
        moyenne_bis = mean(Note_Math,Note_Physique);
        /* pour calculer la moyenne sur toutes les colonnes dont le nom commence par "Note"  */
        moyenne_ter = mean(of Note:);
        /* autres fonctions possibles sur les dates : */
        mois = month(naissance);
        jour = day(naissance);
run;


/* Question 13 : changer le nom d'une colonne */
data malib.note;
        set malib.note;
        rename Moyenne = moy ;
run;


/* Question 14 : utilisation de l'instruction if then  */
data malib.note;
        set malib.note;
        if moy >= 10 then admis="Oui" ;
        else admis ="Non";
run;

/* Si on a plusieurs instructions à faire avec un if on utilise l'instruction do */
/* Une boucle do se termine par end */
data malib.note;
        set malib.note;
        if moy >= 10 then do;
                admission = "Oui" ;
                rattrapage = "Non";
        end;
        else if moy < 10 & moy >= 8 then do
                admission = "Non" ;
                rattrapage = "Oui";
        end;
        else do;
                admission = "Non";
                rattrapage = "Non";
        end;
run;


/* Question 15 */
data normal;
        do I=1 to 1000;
                X=2+3*rannor(0);
                output;
        end;
run;
/* X contient 1000 valeurs simulées selon une loi normale de moyenne 2 et d'écart-type 3 */
/* Si l'on ne met pas output, les valeurs sont effacées et remplacées à chaque itération */


/* Question 16 : calcul de la somme cumulée des notes par année */
data somme;
        set malib.note;
        by annee;
        retain cumule;
        if first.annee then cumule=note_Math;
        else cumule=cumule+note_Physique;
run;
/* Si on enlève l'instruction retain, SAS ne se souvient pas de la valeur de la variable
cumule à la ligne précédente */


/* Question 17 : ajouter le num d'observation */
data malib.note;
        set malib.note;
        retain num_obs 0;
        num_obs+1;
run;

/* Sinon il existe dans SAS une variable temporaire nommée _n_ qui correspond au numéro d'observation*/
data malib.note;
        set malib.note;
        num_obs=_n_;
run;


/* Question 18 : Affichage des prénoms contenant la lettre u */
data _null_;
        set malib.note;
        where nom contains "u" ;
        put nom;
run;

/* En SAS, il faut passer par une table pour faire la plupart des actions, si on ne veut pas créer
de table en plus, on utilise _null_ */
/* Dans la log (ou journal) est affiché les étudiants dont le nom contient un u */
