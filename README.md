# Chi-Square Test Using Pure SQL

## Overview

This project demonstrates how to implement a **Chi-Square Test of Independence entirely in SQL** without using Python, R, or external statistical libraries.

The goal is to test whether **marital status and education level are statistically independent**.

## Dataset

The dataset represents counts of individuals categorized by marital status and education level.

| Marital Status | Middle School | High School | Bachelors | Masters | PhD |
|----------------|--------------|-------------|-----------|---------|-----|
| Never Married | 18 | 36 | 21 | 9 | 6 |
| Married | 12 | 36 | 45 | 36 | 21 |
| Divorced | 6 | 9 | 9 | 3 | 3 |
| Widowed | 3 | 9 | 9 | 3 | 3 |

## Methodology

The SQL script performs the following steps:

1. Create the observed contingency table
2. Compute column totals and grand total
3. Calculate expected frequencies

Expected frequency formula:

Expected = (Row Total × Column Total) / Grand Total

4. Compute chi-square components:

(O − E)² / E

5. Sum components to obtain the **Chi-Square statistic**

6. Calculate **degrees of freedom**

df = (rows − 1) × (columns − 1)

7. Compare the statistic with the **critical value from a chi-square distribution table**

## Hypothesis

H0: Marital status and education level are independent.

H1: Marital status and education level are related.

## Technologies Used

- MySQL
- SQL aggregation
- Mathematical functions
- Hypothesis testing

## File

- `chi_square_test.sql`  
  Contains the full SQL implementation of the Chi-Square Test of Independence, including:
  - creation of observed contingency table
  - calculation of expected frequencies
  - computation of chi-square statistic
  - calculation of degrees of freedom
  - comparison with chi-square critical values
  - final hypothesis decision
