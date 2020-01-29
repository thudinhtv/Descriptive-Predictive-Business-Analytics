libname Exercise 'file path';

Data sasuser.S_Awareness sasuser.S_Conversion;
    Set Exercise.'MART$'n;
	Drop Date Product Creative Creative_Size Site_Name;
	CTR=Clicks_Recorded/Impressions_Delivered;
	CPC=Media_cost/Clicks_Recorded;
    COA=Media_cost/Units_sold;
	Format CTR percent8.2 CPC 8.4 COA 8.2;
	label CTR='Click-through-Rate' CPC='Cost-per-Click' COA='Cost of Acquisition';
	If Campaign_Name='SMART Awareness Mar-May' then output sasuser.S_Awareness;
	Else output sasuser.S_Conversion;
run;

Data sasuser.Mart_All;
     Set sasuser.S_Awareness sasuser.S_Conversion;
	 By Campaign_Name;
	 If Content_Category='Acquisition' then Content_Category='Acquisition';
	 Else if Content_Category='Retargeting' then Content_Category='Retargeting';
	 Else Content_Category='Others';
run;

proc print data=sasuser.S_Awareness;
run;

proc print data=sasuser.S_Conversion;
run;

proc print data=sasuser.Mart_All;
run;

/*T Test for average CTR for Awareness campaign*/
ods rtf file='T Test CTR_Awareness';
Proc TTest data=sasuser.S_Awareness sides=2 h0=0.05 plots(showh0); 
     var CTR;
run;
ods rtf close;


/*Test for normality and T Test for average CPC for all campaigns*/
ods noproctitle;
ods graphics/ imagemap=on;
ods rtf file='Average CPC for all Campaigns';
Proc univariate data=sasuser.MART_ALL normal mu0=0.15;
     ods select TestsForNormality;
	 var CPC;
run;

Proc ttest data=sasuser.MART_ALL sides=2 h0=0.15 plots(showh0); 
	 Var CPC;
run;
ods rtf close;


/*Test for normality and T Test for average COA for Conversion campaign*/
ods rtf file='Average COA_Conversion';
Proc univariate data=sasuser.S_Conversion normal mu0=20;
     ods select TestsForNormality;
	 var COA;
run;

Proc ttest data=sasuser.S_Conversion sides=2 h0=20 plots(showh0); 
	 Var COA;
run;
ods rtf close;


/*Chi-Square test for categorical variable - with 3 values*/
ods rtf file='Chi-Square Test for Content_Category_ALL';
Proc freq data=sasuser.MART_ALL ;
     Tables Content_Category/ nocum chisq plots=(freqplot cumfreqplot) testp=(25,45,30);
run;
ods rtf close;
