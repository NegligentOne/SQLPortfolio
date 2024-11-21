SELECT * FROM CBC

--How many ethnicities are we measuring?
SELECT DISTINCT(race)
FROM CBC

--How many men and women have attended CBC in the last 10 years? (Graphed)
SELECT STARTYEAR, SUM(CASE WHEN gender = 'M' THEN 1 ELSE 0 end) AS totalMen,
SUM(CASE WHEN gender = 'F' THEN 1 ELSE 0 END) AS totalFemale
FROM CBC 
GROUP BY STARTYEAR 
ORDER BY STARTYEAR DESC;

--Different ethnicities over the years (Graphed)
SELECT startyear, SUM(CASE WHEN race='White' THEN 1 ELSE 0 END) AS white,
SUM(CASE WHEN race='Hispanic' THEN 1 ELSE 0 END) AS Hisp,
SUM(CASE WHEN race='Neither' THEN 1 ELSE 0 END) AS neith
FROM CBC 
GROUP BY STARTYEAR
ORDER BY STARTYEAR DESC;

--Average credits gained per year (25,18,7)
SELECT AVG(1cred),AVG(2cred),AVG(3cred)
FROM CBC

--Average credits gained per year by race (no anomaly)
SELECT race, avg(1cred), avg(2cred),avg(3cred)
FROM CBC
--WHERE FULLPART LIKE "F"
GROUP BY race


--Average credits gained per year by Running Start students (33, 26, 7)
SELECT AVG(1cred),AVG(2cred),AVG(3cred)
FROM CBC 
WHERE RUNSTART = 1;

--Average credits gained per year by NON Running Start students (22, 15, 7)
SELECT AVG(1cred),AVG(2cred),AVG(3cred)
FROM CBC 
WHERE RUNSTART != 1;

--Average credits gained by FULL TIME first year (29)
SELECT count(pkey), AVG(1cred)
FROM CBC 
WHERE FULLPART = 'F'

--Average credits gained by PART TIME first year (17)
SELECT count(pkey), AVG(1cred)
FROM CBC 
WHERE FULLPART = 'P'

--Adding a new column to calculate total credits
ALTER TABLE CBC 
ADD COLUMN totalCredits NUMERIC
UPDATE CBC 
SET totalCredits = [1cred] + [2cred] + [3cred] 

SELECT count(*) FROM CBC -- (20,000 records)

--JASON number of students > 60 credits (you say these are graduates/transfers with 90%)
SELECT STARTYEAR, count(pkey) AS numStudents
FROM CBC 
WHERE totalcredits >= 60
GROUP BY STARTYEAR
ORDER  BY STARTYEAR DESC 

--Students > 60 credits separated by race
SELECT STARTYEAR, count(pkey) AS numStudents,
	sum(CASE WHEN race='Hispanic' THEN 1 ELSE 0 end) AS Hispanic,
	sum(CASE WHEN RACE='White' THEN 1 ELSE 0 END) AS White,
	sum(CASE WHEN RACE='Neither' THEN 1 ELSE 0 END) AS Minority
FROM CBC 
WHERE totalcredits >= 60
GROUP BY STARTYEAR
ORDER  BY STARTYEAR DESC

--Students > 60 credits separated by gender
SELECT STARTYEAR,
	sum(CASE WHEN GENDER ='M' THEN 1 ELSE 0 end) AS Male,
	sum(CASE WHEN GENDER ='F' THEN 1 ELSE 0 END) AS Female
FROM CBC 
WHERE totalcredits >= 60
GROUP BY STARTYEAR
ORDER  BY STARTYEAR DESC

--Deeper dive into >60 credits. Hispanic Females HUUUUUUUGGGGGGEEEEEEE!!!!!!!!
SELECT STARTYEAR, count(pkey),
	sum(CASE WHEN RACE='Hispanic' AND GENDER ='F' THEN 1 ELSE 0 end) AS HispanicFemale,
	sum(CASE WHEN race='Hispanic' AND GENDER ='M' THEN 1 ELSE 0 end) AS HispanicMale,
	sum(CASE WHEN RACE='White' AND GENDER ='F' THEN 1 ELSE 0 END) AS WhiteFemale,
	sum(CASE WHEN Race='White' AND Gender ='M' THEN 1 ELSE 0 END) AS WhiteMale,
	sum(CASE WHEN RACE='Neither' AND GENDER='F' THEN 1 ELSE 0 END) AS MinorityFemale,
	SUM(CASE WHEN RACE='Neither' AND GENDER='M' THEN 1 ELSE 0 END) AS MinorityMale 
FROM CBC 
WHERE totalcredits >= 60
GROUP BY STARTYEAR
ORDER  BY STARTYEAR DESC

--Graduation rate based on this data set
SELECT startyear,
		count(pkey) AS totalStudents,
		sum(CASE WHEN [totalCredits] >= 60 THEN 1 ELSE 0 end) AS numGraduates,
		(sum(CASE WHEN [totalCredits] >= 60 THEN 1 ELSE 0 end) * 100.0 / count(pkey)) AS gradPercent
	FROM CBC 
	GROUP BY STARTYEAR 
	ORDER BY STARTYEAR DESC;

--Hispanic Female graduation rates
SELECT startyear,
		count(CASE WHEN GENDER = 'F' AND RACE ='Hispanic' THEN 1 ELSE 0 END) AS totalHispFemale,
		sum(CASE WHEN [totalCredits] >= 60 AND GENDER ='F' AND RACE ='Hispanic' THEN 1 ELSE 0 end) AS numGraduates,
		(sum(CASE WHEN [totalCredits] >= 60 AND GENDER ='F' AND RACE ='Hispanic' THEN 1 ELSE 0 end) * 100.0 / 
		count(CASE WHEN GENDER='F' AND RACE='Hispanic' THEN 1 ELSE NULL end)) AS gradPercent
	FROM CBC 
	GROUP BY STARTYEAR 
	ORDER BY STARTYEAR DESC;

--Graduation rates separated
SELECT startyear,
		(sum(CASE WHEN [totalCredits] >=60 AND race='Hispanic' THEN 1 ELSE 0 end) * 100.0 / count(CASE WHEN race='Hispanic' THEN 1 ELSE 0 end)) AS Hispanic,
		(sum(CASE WHEN [totalCredits] >=60 AND race='White' THEN 1 ELSE 0 end) * 100.0 / count(CASE WHEN race='White' THEN 1 ELSE 0 END))AS White,
		(sum(CASE WHEN [totalCredits] >=60 AND race='Neither' THEN 1 ELSE 0 end) * 100.0 / count(CASE WHEN race='Neither' THEN 1 ELSE 0 end)) AS Neither
	FROM CBC 
	GROUP BY STARTYEAR 
	ORDER  BY STARTYEAR DESC;

--Adding in Gender because it's curious
SELECT startyear,
		(sum(CASE WHEN [totalCredits] >=60 AND race='Hispanic' AND GENDER ='F' THEN 1 ELSE 0 end) * 100.0 / 
		count(CASE WHEN [totalCredits] >=60 THEN 1 ELSE 0 end)) AS HispanicFemale,
		(sum(CASE WHEN [totalCredits] >=60 AND race='Hispanic' AND GENDER ='M' THEN 1 ELSE 0 end) * 100.0 / 
		count(CASE WHEN [totalCredits] >=60 THEN 1 ELSE 0 end)) AS HispanicMale,
		(sum(CASE WHEN [totalCredits] >=60 AND race='White' AND GENDER ='F' THEN 1 ELSE 0 end) * 100.0 / 
		count(CASE WHEN [totalCredits] >=60 THEN 1 ELSE 0 END))AS WhiteFemale,
		(sum(CASE WHEN [totalCredits] >=60 AND race='White' AND GENDER ='M' THEN 1 ELSE 0 end) * 100.0 / 
		count(CASE WHEN [totalCredits] >=60 THEN 1 ELSE 0 END))AS WhiteMale,
		(sum(CASE WHEN [totalCredits] >=60 AND race='Neither' AND GENDER ='F' THEN 1 ELSE 0 end) * 100.0 / 
		count(CASE WHEN [totalCredits] >=60 THEN 1 ELSE 0 end)) AS NeitherFemale,
		(sum(CASE WHEN [totalCredits] >=60 AND race='Neither' AND GENDER ='M' THEN 1 ELSE 0 end) * 100.0 / 
		count(CASE WHEN [totalCredits] >=60 THEN 1 ELSE 0 end)) AS NeitherMale
	FROM CBC 
	GROUP BY STARTYEAR 
	ORDER  BY STARTYEAR DESC;

--Student Enrollment
SELECT startyear,
		sum(CASE WHEN RACE ='Hispanic' AND GENDER ='F' THEN 1 ELSE 0 end) AS HispanicFemale,
		sum(CASE WHEN RACE ='Hispanic' AND GENDER ='M' THEN 1 ELSE 0 end) AS HispanicMale,
		sum(CASE WHEN RACE ='White' AND GENDER ='F' THEN 1 ELSE 0 end) AS WhiteFemale,
		sum(CASE WHEN RACE ='White' AND GENDER ='M' THEN 1 ELSE 0 end) AS WhiteMale,
		sum(CASE WHEN race ='Neither' AND GENDER ='F' THEN 1 ELSE 0 END) AS NeitherFemale,
		sum(CASE WHEN RACE = 'Neither' AND GENDER ='M' THEN 1 ELSE 0 END) AS NeitherMale
	FROM CBC 
	GROUP BY STARTYEAR 
	ORDER  BY STARTYEAR DESC;

SELECT startyear, RACE , AVG([1cred]), avg([2cred]), AVG([3cred]) 
FROM CBC 
GROUP BY STARTYEAR , RACE 
ORDER BY STARTYEAR , RACE 

SELECT startyear, GENDER , AVG([1cred]), avg([2cred]), AVG([3cred]) 
FROM CBC 
GROUP BY STARTYEAR , GENDER 
ORDER BY STARTYEAR , GENDER 
--WHERE RUNSTART = 0

