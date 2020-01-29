Libname Exercise 'file path';

Data Exercise.Exe6;
     Set Exercise.SMART_AD;
   	 Drop Date Campaign_Name Content_Category Creative_Size Site_Name;
	 CTR=Clicks_Recorded/Impressions_Delivered;
	 CPC=Media_cost/Clicks_Recorded;
     COA=Media_cost/Units_sold;
	 Format CTR 8.4 CPC 8.4 COA 8.2;
run;

/*Linear regression to test assumptions and check for outliers, influentials, leverage*/
ods noproctitle;
ods graphics / imagemap=on tipmax=4200;

proc print data=work.reg_stats_unitsold;
var ID rstudent_ h_ cookd_ dffits_;
where ID in ('1','512', '1023', '277', '874','902');
run;

data Exercise.Exe6_outlier_removal;
set EXERCISE.exe6;
where ID not in ('1','512', '1023', '277', '874','902'); /*remove outliers*/
run;


proc glmselect data=EXERCISE.EXE6 outdesign(addinputvars)=Work.reg_design 
		plots=(criterionpanel);
	class Content_Cat_Group Product Creative Creative_Size_Group Site_Name_Group / 
		param=glm;
	model Units_sold=Impressions_Delivered Clicks_Recorded Media_cost 
		Content_Cat_Group Product Creative Creative_Size_Group Site_Name_Group / 
		showpvalues selection=stepwise
    
   (select=adjrsq stop=adjrsq choose=adjrsq);
run;

proc reg data=Work.reg_design alpha=0.05 plots(only)=(diagnostics(unpack) 
		residuals partial rstudentbypredicted dffits dfbetas observedbypredicted);
	where Content_Cat_Group is not missing and Product is not missing and Creative 
		is not missing and Creative_Size_Group is not missing and Site_Name_Group is 
		not missing;
	ods select ParameterEstimates ResidualHistogram ResidualByPredicted 
		RStudentByPredicted ObservedByPredicted CooksDPlot RStudentByLeverage QQPlot 
		RFPlot ResidualPlot PartialPlot RStudentByPredicted DFFITSPlot DFBETASPanel 
		ObservedByPredicted;
	model Units_sold=&_GLSMOD / stb vif partial;
	output out=WORK.Reg_stats_UnitSold cookd=cookd_ covratio=covratio_ 
		dffits=dffits_ h=h_ p=p_ student=student_ rstudent=rstudent_;
	run;
quit;

proc delete data=Work.reg_design;
run;


* Using Proc surveyselect to split data into calibration and validation - split rate is about 70-30*;
* Note sampling rate is 70% given by RATE=0.7, change this to a different number if you do not want 70-30 split*;
* Note random seed is 12345 - change this to a different number if you want random seed to change*;
* Note  Flag=1 is Trainning data,, Flag=0 is validation data*;
* Note if your target variable is nominal, use stratifed sampling using your target as strata variable*;
* Note code is also showing summary statistics for target variable, PCT-Video*;


data A; set Exercise.Exe6_outlier_removal; 
proc surveyselect data=A out=B    
method=SRS RATE=0.7
seed=12345 outall;
run;

Data Exercise.Exe6withFlag; Set B;
Flag=Selected;
Drop Selected;
proc sort; by Flag;
proc freq data=Exercise.Exe6withFlag;
	tables Flag / ;
Proc means data=Exercise.Exe6withFlag;
Var Units_Sold; /* Add in other independent variables if you want*/;
By Flag;
Run;



/* Using SBC criteria to select model based on training data
 * Creating MSE and MAPE for both training and validation data
 * /


proc glmselect data=Exercise.Exe6withFlag outdesign(addinputvars)=Work.reg_design 
		plots=(criterionpanel);
	class Content_Cat_Group Product Creative Creative_Size_Group Site_Name_Group/ param=glm;
	Freq Flag;
	model Units_sold=Impressions_Delivered Clicks_Recorded Media_cost 
		Content_Cat_Group Product Creative Creative_Size_Group Site_Name_Group / showpvalues selection=stepwise 
   (Select=SBC) ; /*using SBC criteria to select model - may change to other valid options*/
run;
		
proc reg data=Work.reg_design alpha=0.05 plots(only)=(diagnostics residuals 
		observedbypredicted);
	where Content_Cat_Group is not missing and Product is not missing and Creative is not missing and Site_Name_Group is not missing and Creative_Size_Group is not missing;
	ods select DiagnosticsPanel ResidualPlot ObservedByPredicted;
	model Units_sold=&_GLSMOD /;
	output out=WORK.Reg_stats0001 p=p_  r=r_;
	run;
quit;

/* creating error indices */

Data Temp; Set work.reg_stats0001;
Sqr_error=(r_)**2;
Abs_Pct_error=100*ABS(r_)/CPC;

Proc Means; by Flag;
Var Sqr_error Abs_pct_error;
Title "MSE and MAPE for Training (Flag=1) and Validation (Flag=0) Data";
run;

proc delete data=Work.reg_design;
run;




