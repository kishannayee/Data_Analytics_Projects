use  blinkitdb;

select * from blinkit_data ;

select count(*) from blinkit_data ;

SELECT COUNT(*)
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'blinkit_data';

SELECT DISTINCT Item_Fat_Content
FROM blinkit_data;

SELECT DISTINCT Item_Fat_Content COLLATE Latin1_General_CS_AS AS Item_Fat_Content
FROM blinkit_data;


-- Data Cleaning

-- remove duplicate 

update blinkit_data
set Item_Fat_Content = 
case	
when Item_Fat_Content in ('LF','low fat') then 'Low Fat'
when Item_Fat_Content in ('reg') then 'Regular'
else Item_Fat_Content 
end ; 

-- KPIs

-- 1] Total sales 

select sum(Sales) as Total_Sales
from blinkit_data ;

-- total sales in millions 

select cast(sum(Sales)/1000000 as decimal(10,2)) as Total_Sales_Millions
from blinkit_data ;


-- 2] AVERAGE SALES

select cast(AVG(Sales)as INT) as AVG_Sales
from blinkit_data ;

-- 3] NO OF ITEMS

select count(*) AS NO_OF_ORDERS
from blinkit_data ;

-- 4] AVG RATING

SELECT CAST(AVG(Rating)AS decimal(10,2)) as AVG_Rating 
FROM blinkit_data

-- Granular Requirementa

-- Total Sales by Fat Content 

select Item_Fat_Content,
       cast(sum(Sales)/1000 as decimal(10,2) ) as Total_Sales_Thousands,
       cast(AVG(Sales)as INT) as AVG_Sales,
	   count(*) AS NO_OF_ORDERS,
	   CAST(AVG(Rating)AS decimal(10,2)) as AVG_Rating 
from blinkit_data
group by Item_Fat_Content
order by Total_Sales_Thousands desc;

-- by item types

select top 5 Item_Type,
       cast(sum(Sales) as decimal(10,2) ) as Total_Sales,
       cast(AVG(Sales)as INT) as AVG_Sales,
	   count(*) AS NO_OF_ORDERS,
	   CAST(AVG(Rating)AS decimal(10,2)) as AVG_Rating 
from blinkit_data
group by Item_Type
order by Total_Sales desc

-- item fat content by outlet for total sales

select Item_Fat_Content,Outlet_Location_Type,
       cast(sum(Sales) as decimal(10,2) ) as Total_Sales,
       cast(AVG(Sales)as INT) as AVG_Sales,
	   count(*) AS NO_OF_ORDERS,
	   CAST(AVG(Rating)AS decimal(10,2)) as AVG_Rating 
from blinkit_data
group by Item_Fat_Content,Outlet_Location_Type
order by Total_Sales desc;






SELECT 
    Outlet_Location_Type,
    ISNULL([Low Fat], 0) AS [Low Fat],
    ISNULL([Regular], 0) AS [Regular]
FROM (
    SELECT 
        Item_Fat_Content,
        Outlet_Location_Type,
        CAST(SUM(Sales) AS DECIMAL(10,2)) AS Total_Sales
    FROM blinkit_data
    GROUP BY Item_Fat_Content, Outlet_Location_Type
) AS sourceTable

-- pivot use of rows to columns

PIVOT (
    SUM(Total_Sales) 
    FOR Item_Fat_Content IN ([Low Fat],[Regular])
) AS PivotTable
ORDER BY Outlet_Location_Type;


-- total sales by outlet establishment year


select Outlet_Establishment_Year,
       cast(sum(Sales) as decimal(10,2) ) as Total_Sales,
	    cast(AVG(Sales)as INT) as AVG_Sales,
	   count(*) AS NO_OF_ORDERS,
	   CAST(AVG(Rating)AS decimal(10,2)) as AVG_Rating 
from blinkit_data
group by Outlet_Establishment_Year
order by Total_Sales DESC;


-- percentage of sales by outlet size

select outlet_Size,
        cast(sum(Sales) as decimal(10,2) ) as Total_Sales,
		 cast((sum(Sales) *100.0 / sum(sum(Sales)) over()) as decimal(10,2) ) as Sales_Percentage
from blinkit_data
group by Outlet_Size
Order by Total_Sales desc;

-- sales by outlet location

select Outlet_Location_Type,
       cast(sum(Sales) as decimal(10,2) ) as Total_Sales,
	    cast((sum(Sales) *100.0 / sum(sum(Sales)) over()) as decimal(10,2) ) as Sales_Percentage,
	    cast(AVG(Sales)as INT) as AVG_Sales,
	   count(*) AS NO_OF_ORDERS,
	   CAST(AVG(Rating)AS decimal(10,2)) as AVG_Rating 
from blinkit_data
group by Outlet_Location_Type
order by Total_Sales DESC;

-- all matrix by outlet type

select Outlet_Type,
       cast(sum(Sales) as decimal(10,2) ) as Total_Sales,
	    cast((sum(Sales) *100.0 / sum(sum(Sales)) over()) as decimal(10,2) ) as Sales_Percentage,
	    cast(AVG(Sales)as INT) as AVG_Sales,
	   count(*) AS NO_OF_ORDERS,
	   CAST(AVG(Rating)AS decimal(10,2)) as AVG_Rating 
from blinkit_data
group by Outlet_Type
order by Total_Sales DESC;


