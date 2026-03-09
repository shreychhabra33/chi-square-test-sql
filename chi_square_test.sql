-- ==========================================================
-- Project: Implementing Chi-Square Test Using Pure SQL
-- Author: Shrey
-- Description:
-- Testing whether marital status and education level
-- are independent using Chi-Square Test of Independence.
-- ==========================================================

CREATE DATABASE data_analysis;
USE data_analysis;

-- ==========================================================
-- Step 1: Create Observed Values Table
-- ==========================================================

CREATE TABLE observed_values(
qual_marital VARCHAR(20),
middle_school INT,
high_school INT,
bachelors INT,
masters INT,
phd INT,
total INT
);

-- Insert observed values (row totals included)

INSERT INTO observed_values VALUES
('never_married',18,36,21,9,6,90),
('married',12,36,45,36,21,150),
('divorced',6,9,9,3,3,30),
('widowed',3,9,9,3,3,27);

-- ==========================================================
-- Step 2: Add Column Totals Row
-- ==========================================================

INSERT INTO observed_values VALUES
(
'row_total',
(SELECT SUM(middle_school) FROM observed_values),
(SELECT SUM(high_school) FROM observed_values),
(SELECT SUM(bachelors) FROM observed_values),
(SELECT SUM(masters) FROM observed_values),
(SELECT SUM(phd) FROM observed_values),
(SELECT SUM(total) FROM observed_values)
);

-- ==========================================================
-- Step 3: Store Column Totals for Expected Value Calculation
-- ==========================================================

SELECT middle_school INTO @ms FROM observed_values WHERE qual_marital='row_total';
SELECT high_school INTO @hs FROM observed_values WHERE qual_marital='row_total';
SELECT bachelors INTO @bs FROM observed_values WHERE qual_marital='row_total';
SELECT masters INTO @mas FROM observed_values WHERE qual_marital='row_total';
SELECT phd INTO @ph FROM observed_values WHERE qual_marital='row_total';
SELECT total INTO @gt FROM observed_values WHERE qual_marital='row_total';

-- ==========================================================
-- Step 4: Create Expected Values Table
-- Formula: Expected = (Row Total × Column Total) / Grand Total
-- ==========================================================

CREATE TABLE expected_values AS
SELECT
qual_marital AS qual_maritals,
TRUNCATE((total*@ms)/@gt,2) AS middle_schools,
TRUNCATE((total*@hs)/@gt,2) AS high_schools,
TRUNCATE((total*@bs)/@gt,2) AS bachelorss,
TRUNCATE((total*@mas)/@gt,2) AS masterss,
TRUNCATE((total*@ph)/@gt,2) AS phds
FROM observed_values;

ALTER TABLE expected_values ADD COLUMN totals INT;

UPDATE expected_values
SET totals = middle_schools + high_schools + bachelorss + masterss + phds
WHERE qual_maritals!='row_total';

-- ==========================================================
-- Step 5: Combine Observed and Expected Values
-- ==========================================================

CREATE TABLE combined_values AS
SELECT *
FROM observed_values o
LEFT JOIN expected_values e
ON o.qual_marital = e.qual_maritals;

-- ==========================================================
-- Step 6: Compute Chi-Square Components
-- Formula: (Observed - Expected)^2 / Expected
-- ==========================================================

CREATE TABLE cstatistics AS
SELECT
qual_marital,
TRUNCATE(POW(ABS(middle_school-middle_schools),2)/middle_schools,2) AS cmid_school,
TRUNCATE(POW(ABS(high_school-high_schools),2)/high_schools,2) AS chigh_school,
TRUNCATE(POW(ABS(bachelors-bachelorss),2)/bachelorss,2) AS cbachelors,
TRUNCATE(POW(ABS(masters-masterss),2)/masterss,2) AS cmasters,
TRUNCATE(POW(ABS(phd-phds),2)/phds,2) AS cphd
FROM combined_values;

-- ==========================================================
-- Step 7: Calculate Chi-Square Statistic
-- ==========================================================

SELECT
TRUNCATE(
SUM(cmid_school) +
SUM(chigh_school) +
SUM(cbachelors) +
SUM(cmasters) +
SUM(cphd)
,2)
INTO @chi_square_stat
FROM cstatistics
WHERE qual_marital!='row_total';

-- ==========================================================
-- Step 8: Calculate Degrees of Freedom
-- df = (rows - 1) × (columns - 1)
-- ==========================================================

SELECT COUNT(*) INTO @rows
FROM cstatistics
WHERE qual_marital!='row_total';

SELECT COUNT(*) INTO @cols
FROM information_schema.columns
WHERE table_name='cstatistics'
AND column_name!='qual_marital';

SET @df = (@rows-1)*(@cols-1);

-- ==========================================================
-- Step 9: Chi-Square Critical Value Table
-- ==========================================================

CREATE TABLE chi_square_table (
df INT,
alpha DECIMAL(5,3),
critical_value DECIMAL(10,4)
);

INSERT INTO chi_square_table VALUES
(11, 0.995, 2.6032), (11, 0.990, 3.0535), (11, 0.975, 3.8167), (11, 0.950, 4.5748),
(11, 0.900, 5.5781), (11, 0.100, 17.2750), (11, 0.050, 19.6751), (11, 0.025, 22.6181),
(11, 0.010, 24.7250), (11, 0.005, 26.7569),
(12, 0.995, 3.0740), (12, 0.990, 3.5716), (12, 0.975, 4.4038), (12, 0.950, 5.2260),
(12, 0.900, 6.3046), (12, 0.100, 18.5476), (12, 0.050, 21.0261), (12, 0.025, 23.3367),
(12, 0.010, 26.2170), (12, 0.005, 28.2995),
(13, 0.995, 3.5650), (13, 0.990, 4.1073), (13, 0.975, 5.0088), (13, 0.950, 5.8907),
(13, 0.900, 7.0415), (13, 0.100, 19.8119), (13, 0.050, 22.3620), (13, 0.025, 24.7360),
(13, 0.010, 27.6882), (13, 0.005, 29.8195),
(14, 0.995, 4.0757), (14, 0.990, 4.6604), (14, 0.975, 5.6294), (14, 0.950, 6.5682),
(14, 0.900, 7.7860), (14, 0.100, 21.0641), (14, 0.050, 23.6848), (14, 0.025, 26.1189),
(14, 0.010, 29.1412), (14, 0.005, 31.3193),
(15, 0.995, 4.6052), (15, 0.990, 5.2293), (15, 0.975, 6.2621), (15, 0.950, 7.2561),
(15, 0.900, 8.5347), (15, 0.100, 22.3071), (15, 0.050, 24.9958), (15, 0.025, 27.4884),
(15, 0.010, 30.5779), (15, 0.005, 32.8013),
(16, 0.995, 5.1515), (16, 0.990, 5.8122), (16, 0.975, 6.9077), (16, 0.950, 7.9626),
(16, 0.900, 9.2864), (16, 0.100, 23.5418), (16, 0.050, 26.2962), (16, 0.025, 28.8454),
(16, 0.010, 32.0000), (16, 0.005, 34.2672),
(17, 0.995, 5.7137), (17, 0.990, 6.4077), (17, 0.975, 7.5642), (17, 0.950, 8.6758),
(17, 0.900, 10.0409), (17, 0.100, 24.7690), (17, 0.050, 27.5871), (17, 0.025, 30.1910),
(17, 0.010, 33.4099), (17, 0.005, 35.7185),
(18, 0.995, 6.2906), (18, 0.990, 7.0149), (18, 0.975, 8.2307), (18, 0.950, 9.3960),
(18, 0.900, 10.7979), (18, 0.100, 25.9894), (18, 0.050, 28.8693), (18, 0.025, 31.5264),
(18, 0.010, 34.8053), (18, 0.005, 37.1564),
(19, 0.995, 6.8801), (19, 0.990, 7.6327), (19, 0.975, 8.9065), (19, 0.950, 10.1170),
(19, 0.900, 11.5574), (19, 0.100, 27.2036), (19, 0.050, 30.1435), (19, 0.025, 32.8523),
(19, 0.010, 36.1910), (19, 0.005, 38.5820),
(20, 0.995, 7.4805), (20, 0.990, 8.2604), (20, 0.975, 9.5908), (20, 0.950, 10.8508),
(20, 0.900, 12.3189), (20, 0.100, 28.4120), (20, 0.050, 31.4104), (20, 0.025, 34.1696),
(20, 0.010, 37.5662), (20, 0.005, 39.9968);

-- ==========================================================
-- Step 10: Retrieve Critical Value
-- ==========================================================

SELECT critical_value
INTO @critical_value
FROM chi_square_table
WHERE df=@df AND alpha=0.050;

-- ==========================================================
-- Step 11: Hypothesis Test Decision
-- ==========================================================

SELECT
@chi_square_stat AS chi_square_statistic,
@critical_value AS critical_value,
CASE
WHEN @chi_square_stat > @critical_value
THEN 'Reject H0: Marital status and education are related.'
ELSE 'Fail to reject H0: Marital status and education appear independent.'
END AS conclusion;