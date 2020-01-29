options nodate nonumber ls=95 ps=80 formdlim='-';
ods noproctitle;
ODS GRAPHICS ON/ IMAGEMAP=ON;
title;

LIBNAME Case 'file path';

data Case.Beautiful;
     Set Case.Beautiful;
     If Time_of_Day in (1, 2) then Contact_Time = "daytime";
	 Else Contact_Time = "evening";
	 if 27 <= Age <= 44 then Age_Group = 'From 27 to 44';
	 else Age_Group = 'Others';
run;

data Case.Beautiful_2009 Case.Beautiful_2010 Case.Beautiful_2011;
     Set Case.Beautiful;
	 If Year = 2009 then output Case.Beautiful_2009;
     Else if Year = 2010 then output Case.Beautiful_2010;
     Else output Case.Beautiful_2011;
run;

/* 1.Descriptive Statistics & Plots */
/* 2009 */
proc means data=Case.Beautiful_2009 printalltypes maxdec=2;
    var Number_of_contacts;
    class Time_of_Day;
    title 'Q1.Descriptive Statistics of Number of Contacts by Time of Day - 2009';
run;
proc means data=Case.Beautiful_2010 printalltypes maxdec=2;
    var Number_of_contacts;
    class Time_of_Day;
    title 'Q1.Descriptive Statistics of Number of Contacts by Time of Day - 2010';
run;
proc means data=Case.Beautiful_2011 printalltypes maxdec=2;
    var Number_of_contacts;
    class Time_of_Day;
    title 'Q1.Descriptive Statistics of Number of Contacts by Time of Day - 2011';
run;

proc means data=Case.Beautiful_2009 printalltypes maxdec=2;
    var Number_of_contacts;
    class Employed;
    title 'Q1.Descriptive Statistics of Number of Contacts by Employed - 2009';
run;
proc means data=Case.Beautiful_2010 printalltypes maxdec=2;
    var Number_of_contacts;
    class Employed;
    title 'Q1.Descriptive Statistics of Number of Contacts by Employed - 2010';
run;
proc means data=Case.Beautiful_2011 printalltypes maxdec=2;
    var Number_of_contacts;
    class Employed;
    title 'Q1.Descriptive Statistics of Number of Contacts by Employed - 2011';
run;


/* 2. Across three-year statistics */
proc means data=case.beautiful mean median stddev min max maxdec=2;
     var Number_of_contacts Time_of_Day Employed Age Number_of_children;
     class Year;
	 title 'Q2.Descriptive Statistics for 5 relevant variables by Year';
run;

proc freq data=case.beautiful;
     tables Time_of_Day Employed Number_of_children Number_of_contacts;
     by year; 
     title 'Q2.Descriptive Statistics/ Frequency for 5 relevant variables by Year';
run;

proc means data=Case.Beautiful printalltypes maxdec=2;
    var Number_of_contacts;
    class Year Time_of_Day;
    title 'Q2.Descriptive Statistics of Number of Contacts by Time of Day across three-year period';
run;

proc means data=Case.Beautiful printalltypes maxdec=2;
    var Number_of_contacts;
    class Year Employed;
    title 'Q2.Descriptive Statistics of Number of Contacts by Employed across three-year period';
run;

proc means data=Case.Beautiful printalltypes maxdec=2;
    var Number_of_contacts;
    class Year Number_of_children;
    title 'Q2.Descriptive Statistics of Number of Contacts by Number of Children across three-year period';
run;


/* 3. Carol's discussion of typical customer*/
proc freq data=case.beautiful;
     tables Employed * Year;
	 title "Q3. Test Carol's discussion of typical customer"; 
run;

proc freq data=case.beautiful;
     tables Age_Group * Year;
	 title "Q3. Test Carol's discussion of typical customer"; 
run;


/* 4.Description of typical customer in 2011 */
proc means data=case.beautiful_2011;
    var Employed Number_of_children Number_of_contacts Time_of_Day;
    title "Q4.Description of typycal customer in 2011 (1)";
run;

proc freq data=case.beautiful_2011;
     tables Age Employed Number_of_children Number_of_contacts Time_of_Day / nocum;
	 title "Q4.Description of typycal customer in 2011 (2)";
run;


/* 5.Advertising during daytime TV shows? */
proc freq data=case.beautiful;
     Tables Contact_Time * Year;
	 title "Q5.Frequency of Contact Time by Year";
run;


proc glm data=case.beautiful_2011;
     class Contact_Time;
     model Number_of_contacts=Contact_Time;
     title 'Q5.Testing for Equality of average Number of Contacts by Contact_Time in 2011';
run;
proc glm data=case.beautiful_2011;
     class Employed;
     model Number_of_contacts=Employed;
     title 'Q5.Testing for Equality of average Number of Contacts by Employed in 2011';
run;

proc glm data=case.beautiful_2011;
     class Contact_Time Employed;
     model Number_of_contacts=Contact_Time Employed Contact_Time*Employed;
     title 'Q5.Testing for Equality of average Number of Contacts by Contact_Time and Employed in 2011';
run;

title;
