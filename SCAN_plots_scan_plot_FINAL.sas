options nocenter fullstimer symbolgen mprint
        compress=binary fullstimer
        mstored sasmstore=macin source2 ;


%let home=/home/jonasbilenas0/SCAN;
%let macin=/home/jonasbilenas0/MACROS/;

%let nplots=4;
%LET lib=sashelp;
%let ds=baseball;
%let iv=CrAtBat;
%let rows=2;

%SYSMSTORECLEAR;
options nocenter;

libname stuff "&home.";
libname macin "&macin."  ACCESS=READONLY;

ods EXCEL file="&home./SCAN_Plots_PLOTSFINAL2.xlsx"
        style=SASWEB
          OPTIONS (fittopage = 'yes' 
                   frozen_headers='no' 
                   autofilter='none' 
                   embedded_titles = 'YES' 
                   embedded_footnotes = 'YES' 
                   zoom = '100' 
                   orientation='Landscape' 
                   Pages_FitHeight = '100' 
                   center_horizontal = 'no' 
                   center_vertical = 'no'   
              ); 
ods EXCEL options(sheet_interval="none"
            sheet_name="SGSCATTER_PLOT_SCAN"
           );
             

proc contents data=&lib..&ds noprint out=cnts; run;
/* Why are we creating an output data set from PROC CONTENTS? */

  
proc sql noprint;
  select name 
    into: vars separated by ' '
      from cnts
        WHERE type=1 and name NOT eq "&iv."
  ;
quit;

/* The above code generates a macro variable called
vars that has each variable name separated with a
space */
%put vars = &vars.;


%macro plotit;
%let I = 1; /* Initialize &I. */
  
  %do %until(%scan(&vars,&I.,%str( ) ) = %str( ) );
    %let var=%scan(&vars,&I.,%str( ) );
    
    %do plt_stream= 1 %to &nplots;
      %let plt_&plt_stream. = %scan(&vars,&I.,%str( ) );
      %let I = %eval(&I. + 1);
    %end;

    proc sgscatter data=&lib..&ds.;
      PLOT  &iv. * (
        %do plt_stream= 1 %to &nplots;
          &&plt_&plt_stream.
        %end; )
      /  markerattrs=(size=2 color=black) GRID
      LOESS=(smooth=0.5
      lineattrs=(color=red thickness=.5))
      rows=&rows. 
      ;
      title bold box=1 "SGSCATER PLOTS";
    run;
    
    %*let I = %eval(&I. + 1);
  %end;

%mend; /* END MACRO */
%plotit;
%break;
ODS excel close;