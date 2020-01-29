options nodate nonumber ls=95 ps=80 formdlim='-';
ods noproctitle;
ODS GRAPHICS ON/ IMAGEMAP=ON;

/* Import csv file */

LIBNAME Exercise 'file path';

Data Exercise.Ex1;
     Infile 'Path\ex1.csv' dsd dlm=',' firstobs=2;
	 Input Skill Hand Limit Final;
	 Format Final 8.2;
run;

proc print data=Exercise.Ex1 (obs=20);
   title 'Poker winning hands';
run;

/* 1.Report Descriptive Statistics of each of the factors (Skill, Hand, and Limit individually on the final cash balance */

proc means data=Exercise.Ex1 printalltypes maxdec=2;
    var Final;
    class Skill;
    title 'Descriptive Statistics of Final cash balance by Skill';
run;

proc means data=Exercise.Ex1 printalltypes maxdec=2;
    var Final;
    class Hand;
    title 'Descriptive Statistics of Final cash balance by Hand';
run;

proc means data=Exercise.Ex1 printalltypes maxdec=2;
    var Final;
    class Limit;
    title 'Descriptive Statistics of Final cash balance by Limit';
run;

/* 2.Plots of each of the factors on final cash balance */
proc sgplot data=Exercise.Ex1;
    vbox Final / category=Skill;
    title "Box and Whisker Plots of Final cash balance by Skill";
run;

proc sgplot data=Exercise.Ex1;
    vbox Final / category=Hand;
    title "Box and Whisker Plots of Final cash balance by Hand";
run;

proc sgplot data=Exercise.Ex1;
    vbox Final / category=Limit;
    title "Box and Whisker Plots of Final cash balance by Limit";
run;

/* 3.One-Way ANOVA: Skill-Final Cash balance */
/*without diagnostics*/
proc glm data=Exercise.Ex1;
     class Skill;
     model Final=Skill;
     title 'Skill_Testing for Equality of average Final Cash Balance with PROC GLM';
run;

/*with diagnostics*/
proc glm data=Exercise.Ex1 plots(only)=diagnostics; 
     class Skill;
     model Final=Skill;
     means Skill / hovtest;
     title 'Skill_ANOVA Diagnostics for testing Assumptions with PROC GLM';
run;

/* Welch ANOVA */
proc glm data=Exercise.Ex1 plots(only)=diagnostics; 
     class Skill;
     model Final=Skill;
     means Skill/ Welch;
     title 'Skill_Welch ANOVA when homogenity of Variance Assumption is violated';
run;


/* 4.One-Way ANOVA: Hand-Final Cash balance */
/*without diagnostics*/
proc glm data=Exercise.Ex1;
     class Hand;
     model Final=Hand;
     title 'HAND_Testing for Equality of average Final Cash Balance with PROC GLM';
run;

/*with diagnostics*/
proc glm data=Exercise.Ex1 plots(only)=diagnostics; 
     class Hand;
     model Final=Hand;
     means Hand / hovtest;
     title 'HAND_ANOVA Diagnostics for testing Assumptions with PROC GLM';
run;

/* Welch ANOVA */
proc glm data=Exercise.Ex1 plots(only)=diagnostics; 
     class Hand;
     model Final=Hand;
     means Hand/ Welch;
     title 'HAND_Welch ANOVA when homogenity of Variance Assumption is violated';
run;

/* Tukey's HSD Test */
proc glm data=Exercise.Ex1  
         plots(only)=(controlplot diffplot(center));
    class Hand;
    model Final=Hand;
    lsmeans Hand / pdiff=all adjust=tukey; 
    title 'HAND_Multiple Comparisons - All posssible Pairs via Tukey Test';
run;


/* 5.One-Way ANOVA: Limit-Final Cash balance */
/*without diagnostics*/
proc glm data=Exercise.Ex1;
     class Limit;
     model Final=Limit;
     title 'LIMIT_Testing for Equality of average Final Cash Balance with PROC GLM';
run;

/*with diagnostics*/
proc glm data=Exercise.Ex1 plots(only)=diagnostics; 
     class Limit;
     model Final=Limit;
     means Limit / hovtest;
     title 'LIMIT_ANOVA Diagnostics for testing Assumptions with PROC GLM';
run;

/* Welch ANOVA */
proc glm data=Exercise.Ex1 plots(only)=diagnostics; 
     class Limit;
     model Final=Limit;
     means Limit/ Welch;
     title 'LIMIT_Welch ANOVA when homogenity of Variance Assumption is violated';
run;


/* 6.Two-way ANOVA: Hand-Limit-Final cash balance - Tukey*/
proc glm data=Exercise.Ex1 plots(only)=diagnostics;
     class Hand Limit;
     model Final=Hand Limit;
	 lsmeans Hand/ pdiff=all adjust=tukey;
     title 'ANOVA with diagnostics - using Limit as blocking variable with Tukey pothoc test';
run;


/* Factorial ANOVA via GLM starts here */
/* Looking at all possible comoinations of factors and the mean of Dependent Variable*/
 PROC MEANS DATA=Exercise.Ex1
	FW=12
	PRINTALLTYPES
	CHARTYPE	
		MEAN 
		STD 
		MIN 
		MAX 
		N	;
	VAR Final;
	CLASS Hand /	ORDER=UNFORMATTED ASCENDING;
	CLASS Limit /	ORDER=UNFORMATTED ASCENDING;
Title 'Means of average Final Cash Balance for all combinations of Hand and Limit';
RUN;

/* GLM codes for factorial ANOVA */
ODS GRAPHICS ON/ IMAGEMAP=ON;
PROC GLM DATA=Exercise.Ex1;
CLASS Hand Limit;
MODEL Final=Hand Limit Hand*Limit;
Title 'Analyzing Effects of Hand and Limit on Final Cash Balance via GLM';
Run;

ODS GRAPHICS ON/ IMAGEMAP=ON;
PROC GLM DATA=Exercise.Ex1 PLOTS(ONLY)=INTPLOT;
CLASS Hand Limit;
MODEL Final=Hand Limit Hand*Limit / SS3;
LSMEANS Hand Limit Hand*Limit / ;
Title 'Analyzing Effects of Hand and Limit on Final Cash Balance via GLM';
Title2 'Creating Interaction plots and using only Type III SS';
Run;

ODS GRAPHICS ON/ IMAGEMAP=ON;
PROC GLM DATA=Exercise.Ex1 PLOTS(ONLY)=INTPLOT;
CLASS Hand Limit;
MODEL Final=Hand Limit Hand*Limit / SS3;
LSMEANS Hand Limit Hand*Limit / ADJUST=TUKEY;
Title 'Analyzing Effects of Hand and Limit on Final Cash Balance via GLM';
Title2 'Tukey follow up tests on main and interaction effects';
Run;

ODS GRAPHICS ON/ IMAGEMAP=ON;
PROC GLM DATA=Exercise.Ex1 PLOTS(ONLY)=DIAGNOSTICS(UNPACK)
		PLOTS(ONLY)=RESIDUALS;
CLASS Hand Limit;
MODEL Final=Hand Limit Hand*Limit / SS3;
Title 'Analyzing Effects of Hand and Limit on Final Cash Balance via GLM';
Title2 'Unpacked Diagnostic plots for GLM';
Run;
