
CREATE OR REPLACE PROCEDURE RPT.Daily_Calendar_PRC is
tmpVar NUMBER;

/******************************************************************************
   NAME:       Daily_Calendar_PRC
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        01/01/2018   T924831       1. Daily procedure to create enterprise calendar 

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     Daily_Calendar_PRC
      Sysdate:         01/01/2018
      Date and Time:   01/01/2018, 7:56:24 aM, and 01/01/2018 7:56:24 AM
      Username:        T924831 (set in TOAD Options, Procedure Editor)
      Table Name:     Daily_Calendar_PRC (set in the "New PL/SQL Object" dialog)

******************************************************************************/
BEGIN
   tmpVar := 0;

execute immediate 'truncate table Reporting_Calendar';
insert into Reporting_Calendar 
With Current_Year
as
(
SELECT 
TO_CHAR(TO_DATE('1-jan-2019')+ DAYNUM+1,'IYYY') AS ISO_YEAR,
EXTRACT (YEAR FROM TO_DATE('1-jan-2019')+ DAYNUM) AS CALENDAR_YEAR,
TO_CHAR(TO_DATE('1-jan-2019')+ DAYNUM,'Q') AS QUARTER,
TO_CHAR(TO_DATE('1-jan-2019')+ DAYNUM,'Month') AS MONTH,
TO_CHAR(TO_DATE('1-jan-2019')+ DAYNUM,'MM') AS MONTHNUM,
to_char(to_date('1-jan-2019')+ daynum-(TRUNC (to_date('1-jan-2019')+ daynum+1)- TRUNC (to_date('1-jan-2019')+ daynum+1, 'IW')),'MM/DD')||'-'||
to_char(to_date('1-jan-2019')+ daynum-(TRUNC (to_date('1-jan-2019')+ daynum)- TRUNC (to_date('1-jan-2019')+ daynum+1, 'IW'))+5,'MM/DD') as Weekrange,
TO_CHAR(TO_DATE('1-jan-2019')+ DAYNUM+1,'IW') AS WEEKOFYEAR,
2 + TRUNC (TO_DATE('1-jan-2019')+ DAYNUM)- TRUNC (TO_DATE('1-jan-2019')+ DAYNUM+1, 'IW') AS DAYOFWEEK,
TO_CHAR(TO_DATE('1-jan-2019')+ DAYNUM, 'DAY') AS DAYNAME,
TO_DATE('1-jan-2019') + DAYNUM AS DAY,
TO_DATE('1-jan-2019') + DAYNUM-2 AS FISCAL_DAY,
TO_DATE('1-jan-2019') + DAYNUM+2 AS FINANCE_DAY,
TO_CHAR(TO_DATE('1-jan-2019')+ DAYNUM, 'DD') AS DAYNUM,
TO_CHAR(TO_DATE('1-jan-2019')+ DAYNUM, 'DDD') AS DAYOFYEAR
FROM 
(
SELECT ROWNUM-1 AS DAYNUM
        FROM DUAL
        CONNECT BY ROWNUM < SYSDATE+720 - TO_DATE('1-jan-2019')+1
        )
        ),      
Previous_Year
as
(
SELECT 
TO_CHAR(TO_DATE('1-jan-2018')+ DAYNUM+1,'IYYY') AS ISO_YEAR,
EXTRACT (YEAR FROM TO_DATE('1-jan-2018')+ DAYNUM) AS CALENDAR_YEAR,
TO_CHAR(TO_DATE('1-jan-2018')+ DAYNUM,'Q') AS QUARTER,
TO_CHAR(TO_DATE('1-jan-2018')+ DAYNUM,'Month') AS MONTH,
TO_CHAR(TO_DATE('1-jan-2018')+ DAYNUM,'MM') AS MONTHNUM,
to_char(to_date('1-jan-2018')+ daynum-(TRUNC (to_date('1-jan-2019')+ daynum+1)- TRUNC (to_date('1-jan-2019')+ daynum+1, 'IW')),'MM/DD')||'-'||
to_char(to_date('1-jan-2018')+ daynum-(TRUNC (to_date('1-jan-2019')+ daynum)- TRUNC (to_date('1-jan-2019')+ daynum+1, 'IW'))+5,'MM/DD') as Weekrange,
TO_CHAR(TO_DATE('1-jan-2018')+ DAYNUM+1,'IW') AS WEEKOFYEAR,
2 + TRUNC (TO_DATE('1-jan-2018')+ DAYNUM)- TRUNC (TO_DATE('1-jan-2019')+ DAYNUM+1, 'IW') AS DAYOFWEEK,
TO_CHAR(TO_DATE('1-jan-2018')+ DAYNUM, 'DAY') AS DAYNAME,
TO_DATE('1-jan-2018') + DAYNUM AS DAY,
TO_DATE('1-jan-2018') + DAYNUM-2 AS FISCAL_DAY,
TO_DATE('1-jan-2019') + DAYNUM+2 AS FINANCE_DAY,
TO_CHAR(TO_DATE('1-jan-2018')+ DAYNUM, 'DD') AS DAYNUM,
TO_CHAR(TO_DATE('1-jan-2018')+ DAYNUM, 'DDD') AS DAYOFYEAR,
Case when TO_CHAR(TO_DATE('1-jan-2018')+ DAYNUM, 'DDD') <= TO_CHAR(TO_DATE(sysdate), 'DDD') then 'Comparible' else 'Not Comparable' end as time_period_type
FROM 
(
SELECT ROWNUM-1 AS DAYNUM
        FROM DUAL
        CONNECT BY ROWNUM < SYSDATE+360 - TO_DATE('1-jan-2019')+1
        )
        )
Select distinct Current_Year.*,Previous_Year.Day as Previous_Year_Day,Previous_Year.WEEKRANGE Prev_Year_Week_Range,Previous_Year.weekofyear Prev_Year_Weekofyear,Previous_Year.CALENDAR_YEAR Prev_Year_Num, Previous_Year.time_period_type
From Current_Year
Left Join Previous_Year on Current_Year.CALENDAR_YEAR = Previous_Year.CALENDAR_YEAR+1
and Current_Year.DAYOFYEAR = Previous_Year.DAYOFYEAR
--and current_year.MONTHNUM = Previous_Year.MONTHNUM
--and Current_Year.Daynum = Previous_Year.Daynum
order by current_year.day asc
;
Commit;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       NULL;
     WHEN OTHERS THEN
     RAISE; 
END Daily_Calendar_PRC;
/
