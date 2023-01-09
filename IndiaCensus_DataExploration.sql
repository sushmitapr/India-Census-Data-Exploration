
USE Census      -- connecting to database

-- Preview of Datasets

SELECT
	District,
	State,
	Growth,
	Sex_Ratio,
	Literacy
FROM Data1;                                   --Dataset 1

SELECT
	District,
	State,
	Area_km2,
	Population
FROM Data2;                                    --Dataset 2

-- Total number of rows present on dataset 1 

SELECT
	COUNT(*) AS Total_rows_data1
FROM Data1;


-- Total number of rows present on dataset 2

SELECT
	COUNT(*) AS Total_rows_data2
FROM Data2;

-- Calculating Dataset from 

SELECT
	[District],
	[State],
	[Growth],
	[Sex_Ratio],
	[Literacy]
FROM Data1
WHERE state IN ('Jharkhand', 'Bihar');

--Population Of Inida
SELECT
	SUM(population) AS Total_Population
FROM data2;

-- Average Growth Of India

SELECT
	(AVG(growth) * 100) AS Average_Growth
FROM data1;

-- Average Growth Of India by state

SELECT
	state,
	(AVG(growth) * 100) AS Average_Growth
FROM data1
GROUP BY state;

-- Average Sex Ratio Of India

SELECT
	state,
	ROUND(AVG(sex_ratio), 0) AS Average_Sex_Ratio
FROM data1
GROUP BY state
ORDER BY Average_Sex_Ratio DESC;

-- Average Literacy Rate

SELECT
	state,
	ROUND(AVG(literacy), 0) AS Average_Literacy_rate
FROM data1
GROUP BY state
HAVING ROUND(AVG(literacy), 0) > 90
ORDER BY Average_Literacy_rate DESC;

--Top 3 states with highest growth ratio

SELECT TOP 3
	(state),
	(AVG(growth) * 100) AS Average_Growth
FROM data1
GROUP BY state
ORDER BY Average_Growth DESC;

--Bottom 3 states with lowest growth ratio

SELECT TOP 3
	(state),
	(AVG(growth) * 100) AS Average_Growth
FROM data1
GROUP BY state
ORDER BY Average_Growth ASC;

--Top 3 states with highest Sex ratio

SELECT TOP 3
	(state),
	ROUND(AVG(sex_ratio), 0) AS Average_Sex_Ratio
FROM data1
GROUP BY state
ORDER BY Average_Sex_Ratio DESC;

--Bottom 3 states with Lowest sex ratio
SELECT TOP 3
	(state),
	ROUND(AVG(sex_ratio), 0) AS Average_Sex_Ratio
FROM data1
GROUP BY state
ORDER BY Average_Sex_Ratio ASC;

--Top and Bottom # states in Literacy State

DROP TABLE IF EXISTS #Top_States_by_Literacy_Rate
CREATE TABLE #Top_States_by_Literacy_Rate (
	State nvarchar(255),
	Literacy_Rate float
);

INSERT INTO #Top_States_by_Literacy_Rate
	SELECT
		state,
		ROUND(AVG(literacy), 0) AS Average_Literacy_Rate
	FROM data1
	GROUP BY state
	ORDER BY Average_Literacy_Rate DESC;

SELECT TOP 3
	(state),
	Literacy_Rate
FROM #Top_States_by_Literacy_Rate
ORDER BY Literacy_Rate DESC

--Bottom # states in Literacy State

DROP TABLE IF EXISTS #Bottom_States_by_Literacy_Rate
CREATE TABLE #Bottom_States_by_Literacy_Rate (
	State nvarchar(255),
	Literacy_Rate float
)

INSERT INTO #Bottom_States_by_Literacy_Rate
	SELECT
		state,
		ROUND(AVG(literacy), 0) AS Average_Literacy_Rate
	FROM data1
	GROUP BY state
	ORDER BY Average_Literacy_Rate ASC;

SELECT TOP 3
	(state),
	Literacy_Rate
FROM #Bottom_States_by_Literacy_Rate
ORDER BY Literacy_Rate ASC;

--Union

SELECT t.state,
       t.Literacy_Rate
FROM (SELECT TOP 3
	(state),
	Literacy_Rate
FROM #Top_States_by_Literacy_Rate
ORDER BY Literacy_Rate DESC) t
UNION
SELECT
	(state),
	Literacy_Rate
FROM (SELECT TOP 3
	(state),
	Literacy_Rate
FROM #Bottom_States_by_Literacy_Rate
ORDER BY Literacy_Rate ASC) b
ORDER BY Literacy_Rate DESC;




--Join Query

--Total males and females 

SELECT
	dd.state,
	SUM(dd.males) AS Total_Males,
	SUM(dd.females) AS Total_Females
FROM (SELECT
	d.district,
	d.state,
	ROUND(d.population / (d.sex_ratio + 1), 0) AS males,
	ROUND((d.population * d.sex_ratio) / (d.sex_ratio + 1), 0) AS females
FROM (SELECT
	d1.district,
	d1.state,
	(d1.sex_ratio / 1000) AS sex_ratio,
	d2.population
FROM data1 d1
INNER JOIN data2 d2
	ON d1.District = d2.District) d) dd
GROUP BY dd.State;

--Total Literacy Rate

SELECT
	dd.state,
	SUM(dd.literate_people) AS total_literate_pop,
	SUM(dd.illiterate_people) AS total_lliterate_pop
FROM (SELECT
	d.district,
	d.state,
	ROUND(d.literacy_ratio * d.population, 0) AS literate_people,
	ROUND((1 - d.literacy_ratio) * d.population, 0) AS illiterate_people
FROM (SELECT
	d1.district,
	d1.state,
	(d1.literacy / 100) AS literacy_ratio,
	d2.population
FROM data1 d1
INNER JOIN data2 d2
	ON d1.district = d2.District) d) dd
GROUP BY dd.State;


-- population in previous census


SELECT
	SUM(d12.previous_census_population) AS previous_census_population,
	SUM(d12.current_census_population) AS current_census_population
FROM (SELECT
	dd.state,
	SUM(dd.previous_census_population) AS previous_census_population,
	SUM(dd.current_census_population) AS current_census_population
FROM (SELECT
	d.district,
	d.state,
	ROUND(d.population / (1 + d.growth), 0) AS previous_census_population,
	d.population AS current_census_population
FROM (SELECT
	d1.district,
	d1.state,
	d1.growth AS growth,
	d2.population
FROM data1 d1
INNER JOIN data2 d2
	ON d1.district = d2.district) d) dd
GROUP BY dd.state) d12;



-- Rank function
-- Top 3 distrct from each state with  highest literacy rate

SELECT
	r.district,r.state,r.literacy,r.rankk
FROM (SELECT
	district,state,literacy, RANK() OVER (PARTITION BY state ORDER BY literacy DESC) rankk
FROM data1) r

WHERE r.rankk IN (1, 2, 3)
ORDER BY state ASC;