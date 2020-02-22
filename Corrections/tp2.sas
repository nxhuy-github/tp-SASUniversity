/* exercice 1 */
data eaux;
infile "C:\Users\Gabriela.Ciuperca\M2PRO\logiciel_SAS\eaux.txt";
 input hco3 so4 cl ca mg na source$ pays$ ;
run;
proc univariate data=eaux normal;
 var hco3 so4 cl ca mg na; 
histogram hco3 so4 cl ca mg na/ normal;
run;
proc corr data =eaux pearson spearman kendall;
  var hco3 so4 cl ca mg na; run;
proc sort data=eaux; 
by hco3; run;

proc plot data=eaux; 
plot so4*hco3 $ca; run;


/* question 3 */
axis1 value=(c=blue) label=(c=blue 'SO4');
axis2 value=(c=red) label=(c=red 'HCO3');
axis3 value=(c=red) label=(c=red 'Cl');
proc gplot data=eaux;
  plot so4*hco3 / vaxis=axis1 haxis=axis2;
  symbol1 interpol=j color=red ;
  plot2 cl*hco3 / vaxis=axis3 haxis=axis2;;
 symbol2 interpol=j color=blue;
  run;
  proc sort data=eaux;
    by mg; run;
	proc print data=eaux; run;
  /* question  4 */
	/* ods pdf body="C:\Users\Gabriela.Ciuperca\M2PRO\logiciel_SAS\tp2.pdf"; 
	ods graphics on; */
	axis1 value=(c=blue) label=(c=blue 'Ca');
axis2 value=(c=red) label=(c=red 'Mg');
  proc gplot data=eaux;
    plot Ca*Mg / vaxis=axis1 haxis=axis2;
	symbol1 i=j color=blue v=star; 
    title "Graphique Ca fonction de Mg";
run;

  quit;
 /* ods graphics off;
  ods pdf close; */
  /* question 5 */

proc sort data=eaux;
  by pays; run;
  proc print; run;
  proc univariate data=eaux normal;
 var hco3 so4 cl ca mg na; 
 histogram hco3 so4 cl ca mg na/ normal;
by pays;
run;

  /* exercice 2*/

  proc iml;
  A={5 3 -2, 3 4 -3, 4 2 -5};
C={5,2,-7};
print a; print c;
X=inv(a)*c;
print(x);
print(a*a);
print(a#a);
d=a||c;
print("la matrice D"); print  d;

/* exercice 3 */
proc iml;
use eaux;
read all var {hco3 so4 cl ca mg na} into X;
close eaux;
print X;
print(x[2,]);
print(x[,3:4]);
m1=j(ncol(X),1,0);
s1=m1;
do i=1 to ncol(X);
  print("moyenne var="); print(i) ;
  print(mean(X[,i]));
  print(std(X[,i]));
  m1[i]=mean(X[,i]);
  s1[i]=std(X[,i]);
end;
print m1 s1;
print(X[:,]);
print(std(X));
xx=x[,2:6]; print(xx);
y=x[,1];
xx=j(nrow(x),1,1)||xx; print(xx);
b=inv(t(xx)*xx)*t(xx)*y; 
print(b);
prevY=xx*b; print(prevY);
ri=Y-prevY;;
print ("Les résidus"); print(ri);
sr=t(ri)*ri; print("SR"); print(sr);
p=ncol(xx)-1; n=nrow(xx);
print("ecart type des residus"); print((sr/(nrow(xx)-p-1))**(1/2));
st=t(y-mean(y))*(y-mean(y));
SM=t(prevy-mean(y))*(prevy-mean(y));
/* statistique de test pour le modèle */
Z=(SM/p)/(sr/(n-p-1));
/* fractile loi fisher */
q95 = finv(0.95,p,n-p-1);
print("la quantile Fisher"); print(q95);
print ("valeur statistique test"); print(Z);
if (z>q95) then do;
                 print("modèle significatif(H1 acceptée)");
				 pvalue=1-probf(z,p,n-p-1);
				 print("la pvalue");
				 print(pvalue);
                end;
		   else print("Modèle non significatif(H0 acceptée)");
/* calcul R2 */
R2=SM/ST;
print("R2"); print(R2);

quit;

proc reg data=eaux;
  model HCO3=so4 cl ca mg na;
  run;
