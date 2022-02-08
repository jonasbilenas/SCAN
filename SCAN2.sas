options nocenter fullstimer symbolgen mprint
        compress=binary fullstimer
        mstored sasmstore=macin source2;


%let home=/home/jonasbilenas0/SCAN/;
%let macin=/home/jonasbilenas0/MACROS/;

%SYSMSTORECLEAR;
options nocenter;


libname stuff "&home.";
libname macin "&macin."  ACCESS=READONLY;

ods EXCEL file="&home./SCAN20200208.xlsx"
	      style=SASWEB
          OPTIONS (fittopage = 'yes' 
                   frozen_headers='no' 
                   autofilter='none' 
                   embedded_titles = 'YES' 
                   embedded_footnotes = 'YES' 
                   zoom = '90' 
                   orientation='Landscape' 
                   Pages_FitHeight = '100' 
                   center_horizontal = 'no' 
                   center_vertical = 'no'	
              ); 
ods EXCEL options(sheet_interval="none"
	          sheet_name="First Contents"
	         );
             
data test;
  AAA2 = 5; bbb4 =6; CC4 = 7; ddd_2 = 8; xYz44='BB';
output;
run; /* How many observations in test? */

%let ds=work.test;
proc contents data=test  out=cnts; 
  title First Contents;
run;
/* Why are we creating an output data set from PROC CONTENTS? */
title;
proc contents data=cnts; run;

proc sql noprint;
select name into: vars separated by ' '
from cnts
;
quit;
/* The above code generates a macro variable called
vars that has each variable name separated with a
space */
%put vars = &vars.;

proc sql noprint;
  select name into: vars separated by ' '
    from cnts
;
quit;

/* The above code generates a macro variable called
vars that has each variable name separated with a
space */

%put vars = &vars.;

%macro rename;
%let I = 1; /* Initialize &I. */
proc datasets lib=work nolist; /* DATASETS to modify the data*/
  modify test;
  %do %until(%scan(&vars,&I.,%str( ) ) = %str( ) );
    %let var=%scan(&vars,&I.,%str( ) );
    %let ren=%upcase(&var.); /* &REN=Upcase of &var */
    %if &var. ne &ren %then %do; /* if &VAR not equal to &REN*/
      rename &var. = &ren.; /* Use RENAME STATEMENT in PROC DATASETS */
    %end; /* END THE 2nd LOOP */
    %let I = %eval(&I. + 1); /* Increment &I by 1 */
  %end; /* End First Loop */
run;quit;

%break;
ods EXCEL options(sheet_interval="none"
	          sheet_name="Fixed Contents"
	         );
proc contents data=test;
  title Fixed Contents;
run;
%mend; /* END MACRO */
%rename;
%break;
ODS excel close;