create table gameSales(
	Standing SMALLINT,
	Title VARCHAR(150),
	Platform VARCHAR(50),
	releaseYear INT,
	Genre VARCHAR(50),
	Publisher VARCHAR(50),
	NA_Sales numeric,
	EU_Sales numeric,
	JP_Sales numeric,
	Other_Sales numeric,
	Global_Sales numeric
);

--import CSV data
copy gameSales(Standing,Title,Platform,releaseYear,Genre,Publisher,NA_Sales,EU_Sales,JP_Sales,Other_Sales,Global_Sales)
from 'C:\Users\Negligent\Desktop\Course-python-data-science-master\vgsales.csv'
DELIMITER ',' 
null 'N/A'
csv header;

select * from gameSales;

--Checking for outliers
select releaseyear
from gameSales
order by releaseyear desc;

--Searching for Duplicates
select title, platform, global_sales, COUNT(*)
from gamesales g 
group by title, platform, global_sales
having count(*)>1;

--Looking at Top10 Selling Publishers World Wide
drop table if exists temp1;
create table temp1 (
Publisher varchar(50),
Total_Sales numeric
);

insert into temp1
select publisher,
SUM(global_sales) as total_Sales
from gamesales g 
group by publisher
order by total_Sales desc
limit 10;
select*from temp1;

--Top 10 Publishers and Genres World Wide 
drop table if exists temp2;
create table temp2 (
Publisher varchar(50),
Genre varchar(20),
Total_Sales numeric
);
insert into temp2
select publisher, genre,
SUM(global_sales) as total_Sales
from gamesales g 
where publisher in (select publisher from temp1)
group by publisher, genre
order by total_Sales desc;
select*from temp2;

--Top 10 American sellers and percentage of their global sales
select publisher,
	sum(NA_Sales) as total_NA,
	sum(global_sales) as total_Global,
	ROUND((sum(na_sales)/sum(global_sales)*100),2) as Percent_of_Global
from gamesales g 
group by publisher
order by total_na desc, Percent_of_Global  desc
limit 10;

--Top 10 Europe sellers
select publisher,
	sum(EU_Sales) as total_EU,
	sum(global_sales) as total_Global,
	ROUND((sum(EU_sales)/sum(global_sales)*100),2) as Percent_of_Global
from gamesales g 
group by publisher
order by total_EU desc, Percent_of_Global  desc
limit 10;

--Top 10 Japan sellers
select publisher,
	sum(JP_Sales) as total_JP,
	sum(global_sales) as total_Global,
	ROUND((sum(JP_sales)/sum(global_sales)*100),2) as Percent_of_Global
from gamesales g 
group by publisher
order by total_JP desc, Percent_of_Global  desc
limit 10;

--Best selling Genre 
select genre, sum(na_sales) as NorthAmerica,
sum(eu_sales) as Europe,
sum(jp_sales) as Japan,
sum(global_sales) as World_Wide
from gamesales g 
group by genre 
order by world_wide desc
limit 10;

--Top 10 Publisher sales by Genre with regions
select publisher, genre, sum(na_sales) as NorthAmerica,
sum(eu_sales) as Europe,
sum(jp_sales) as Japan,
sum(global_sales) as World_Wide
from gamesales g
where publisher in (
	select publisher
	from temp1)
group by publisher, genre 
order by publisher, world_wide desc;

--Getting the top 10 Publisher's sales per Genre Worldwide
select publisher, 
	genre, 
	sum(global_sales) as total_sales
from gamesales g
where publisher in (select publisher from temp1)
group by 1,2
order by 1, 3 desc;

--Highest Genre's by sales worldwide
select genre, sum(global_sales) as maxglobal
from gamesales g 
group by genre
order by 2 desc

--Each Genre's percentage of the world market
    select genre,max(global_sales) as MaxSales, sum(global_sales) as TotalSales,
    ROUND((max(global_sales)/sum(global_sales)*100),2) as Percentage_of_Market
    from gamesales 
    group by genre
    order by 4 desc;
	
--Best selling game/publisher in each genre
select a.title, a.publisher, a.genre, a.global_sales
from (
	select genre, max(global_sales) as global_sales
	from gamesales 
	group by genre
	) as b inner join gamesales as a on a.genre=b.genre 
	 and a.global_sales =b.global_sales 
	order by 4 desc;

-- Each game's percentage of total market by genre
select  a.title, a.publisher, a.genre, a.global_sales, b.TotalSales, b.Percentage_of_Market  
from (
	select genre, max(global_sales) as global_sales, sum(global_sales) as TotalSales,
    ROUND((max(global_sales)/sum(global_sales)*100),2) as Percentage_of_Market
	from gamesales 
	group by genre
	) as b inner join gamesales as a on a.genre=b.genre 
	 and a.global_sales =b.global_sales 
	order by 4 desc;

