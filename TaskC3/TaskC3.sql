-- Report 1: What are the top 10 average number of sales from each suburb and property type?
-- V1
SELECT *
FROM (
SELECT suburb, property_type,
 (SUM(total_rental_fees)/NULLIF(SUM(total_num_of_rent), 0)) AS avg_rental_fee,
 RANK() OVER (ORDER BY (SUM(total_rental_fees)/NULLIF(SUM(total_num_of_rent), 0)) DESC)
 AS fee_rank
FROM RentFact_V1
GROUP BY suburb, property_type
)
WHERE fee_rank <= 10;

-- V2
SELECT *
FROM (
SELECT S.suburb, PT.property_type,
 (SUM(F.total_rental_fees)/NULLIF(SUM(F.total_num_of_rent), 0)) AS avg_rental_fee,
 RANK() OVER (ORDER BY (SUM(F.total_rental_fees)/NULLIF(SUM(F.total_num_of_rent), 0)) DESC)
 AS fee_rank
FROM RentFact_V2 F, SuburbDim_V2 S, PropertyTypeDim_V2 PT
WHERE F.suburb = S.suburb
AND F.property_type = PT.property_type
GROUP BY S.suburb, PT.property_type
)
WHERE fee_rank <= 10;

-- Report 2 what is the top 5% average rental fee from each suburb and property type?
-- V1
SELECT suburb,property_type, avg_rental_fee, percent_rank
FROM (
 SELECT
 suburb,
 property_type,
 (SUM(total_rental_fees)/NULLIF(SUM(total_num_of_rent), 0)) AS avg_rental_fee,
 PERCENT_RANK () OVER (ORDER BY (SUM(total_rental_fees)/NULLIF(SUM(total_num_of_rent), 0))) AS percent_rank
 FROM RentFact_V1
 GROUP BY suburb, property_type
) 
WHERE percent_rank >= 0.95
ORDER BY percent_rank DESC;

-- V2
SELECT suburb,property_type, avg_rental_fee, percent_rank
FROM (
 SELECT
 S.suburb,
 PT.property_type,
 (SUM(F.total_rental_fees)/NULLIF(SUM(F.total_num_of_rent), 0)) AS avg_rental_fee,
 PERCENT_RANK () OVER (ORDER BY (SUM(F.total_rental_fees)/NULLIF(SUM(F.total_num_of_rent), 0))) AS percent_rank
FROM RentFact_V2 F, SuburbDim_V2 S, PropertyTypeDim_V2 PT
WHERE F.suburb = S.suburb
AND F.property_type = PT.property_type
 GROUP BY S.suburb, PT.property_type
) 
WHERE percent_rank >= 0.95
ORDER BY percent_rank DESC;

-- Report 3 Show the total number of clients that are female and have high budget plan.
-- V1
SELECT gender, budget_range, SUM(total_num_of_clients)
FROM ClientFact_V1
WHERE gender = 'Female'
AND budget_range = 'High'
GROUP BY gender, budget_range;

-- V2
SELECT G.gender, B.budget_range, SUM(F.total_num_of_clients)
FROM ClientFact_V2 F, MaxBudgetRangeDim_V2 B, Agent_ClientGenderDim_V2 G
WHERE G.gender = F.gender
AND B.budget_range = F.budget_range
AND G.gender = 'Female'
AND B.budget_range = 'High'
GROUP BY G.gender, B.budget_range;

-- Report 4 & 5: What are the sub-total and total rental fees from each suburb, time period, and property type?
-- Cube_V1
SELECT
 DECODE(GROUPING(period), 1, 'All Period', period) As Period,
 DECODE(GROUPING(suburb), 1, 'All Suburb', suburb) AS Suburb,
 DECODE(GROUPING(property_type), 1, 'All Property Type', property_type) As Property_Type,
 SUM(total_rental_fees)
FROM RentFact_V2
GROUP BY CUBE (period, suburb, property_type)
ORDER BY property_type;

-- Partial_Cube_V1
SELECT
 DECODE(GROUPING(period), 1, 'All Period', period) As Period,
 DECODE(GROUPING(suburb), 1, 'All Suburb', suburb) AS Suburb,
 DECODE(GROUPING(property_type), 1, 'All Property Type', property_type) As Property_Type,
 SUM(total_rental_fees)
FROM RentFact_V2
GROUP BY CUBE (suburb, property_type), period
ORDER BY property_type;

-- Cube_V2
SELECT
 DECODE(GROUPING(RP.period), 1, 'All Periods', RP.period) As Period,
 DECODE(GROUPING(S.suburb), 1, 'All Suburbs', S.suburb) AS Suburb,
 DECODE(GROUPING(P.property_type), 1, 'All Property Types', P.property_type) As Property_Type,
 SUM(total_rental_fees)
FROM RentFact_V2 F, RentalPeriodDim_V2 RP, SuburbDim_V2 S, PropertyTypeDim_V2 P
WHERE F.period = RP.period
AND F.suburb = S.suburb
AND F.property_type = P.property_type
GROUP BY CUBE (RP.period, S.suburb, P.property_type)
ORDER BY P.property_type;

-- Partial_Cube_V2
SELECT
 DECODE(GROUPING(RP.period), 1, 'All Periods', RP.period) As Period,
 DECODE(GROUPING(S.suburb), 1, 'All Suburbs', S.suburb) AS Suburb,
 DECODE(GROUPING(P.property_type), 1, 'All Property Types', P.property_type) As Property_Type,
 SUM(total_rental_fees)
FROM RentFact_V2 F, RentalPeriodDim_V2 RP, SuburbDim_V2 S, PropertyTypeDim_V2 P
WHERE F.period = RP.period
AND F.suburb = S.suburb
AND F.property_type = P.property_type
GROUP BY CUBE (S.suburb, P.property_type), RP.period
ORDER BY P.property_type;

-- Report 6 & Report 7: What are the sub-total and total average number of salaries for each gender, and office size?
-- Roll_up_V1
SELECT
 DECODE(GROUPING(gender), 1, 'All Genders', gender) As Gender,
 DECODE(GROUPING(office_size), 1, 'All Office Sizes', office_size) AS Office_Size,
 (SUM(total_salary)/NULLIF(SUM(total_num_of_agents), 0)) AS avg_no_of_salaries
FROM AgentFact_V1
GROUP BY ROLLUP (gender, office_size)
ORDER BY gender;

-- Partial_Roll_up_V1
SELECT
 DECODE(GROUPING(gender), 1, 'All Genders', gender) As Gender,
 DECODE(GROUPING(office_size), 1, 'All Office Sizes', office_size) AS Office_Size,
 (SUM(total_salary)/NULLIF(SUM(total_num_of_agents), 0)) AS avg_no_of_salaries
FROM AgentFact_V1
GROUP BY ROLLUP (gender), office_size
ORDER BY gender;

-- Roll_up_V2
SELECT
 DECODE(GROUPING(G.gender), 1, 'All Genders', G.gender) As Gender,
 DECODE(GROUPING(OS.office_size), 1, 'All Office Sizes', OS.office_size) AS Office_Size,
 (SUM(F.total_salary)/NULLIF(SUM(F.total_num_of_agents), 0)) AS avg_no_of_salaries
FROM AgentFact_V2 F, OfficeSizeDim_V2 OS, Agent_ClientGenderDim_V2 G
WHERE F.gender = G.gender
AND F.office_size = OS.office_size
GROUP BY ROLLUP (G.gender, OS.office_size)
ORDER BY G.gender;

-- Partial_Roll_up_V2
SELECT
 DECODE(GROUPING(G.gender), 1, 'All Genders', G.gender) As Gender,
 DECODE(GROUPING(OS.office_size), 1, 'All Office Sizes', OS.office_size) AS Office_Size,
 (SUM(F.total_salary)/NULLIF(SUM(F.total_num_of_agents), 0)) AS avg_no_of_salaries
FROM AgentFact_V2 F, OfficeSizeDim_V2 OS, Agent_ClientGenderDim_V2 G
WHERE F.gender = G.gender
AND F.office_size = OS.office_size
GROUP BY ROLLUP (G.gender), OS.office_size
ORDER BY G.gender;

-- Report 8: What is the total number of clients and cumulative number of clients with a high budget in each year?
-- Cumulative_V1
Select T.year, SUM(F.total_num_of_visit),
 TO_CHAR(SUM(SUM(F.total_num_of_visit))
 OVER(ORDER BY T.year ROWS UNBOUNDED PRECEDING),'9,999,999') AS Cummulative_visitors
FROM VisitFact_V1 F, TimeDim_V1 T
WHERE F.budget_range = 'High'
AND F.time_id = T.time_id
GROUP BY T.year;

-- Cumulative_V2
Select T.year, SUM(F.total_num_of_visit),
TO_CHAR(SUM(SUM(F.total_num_of_visit))
OVER(ORDER BY T.year ROWS UNBOUNDED PRECEDING),'9,999,999') AS Cummulative_visitors
FROM VisitFact_V2 F, TimeDim_V2 T, MaxBudgetRangeDim_V2 MB
WHERE F.budget_range = MB.budget_range
AND F.time_id = T.time_id
AND MB.budget_range = 'High'
Group By T.year;

-- Report 9: What is the total number of sale and moving aggregate number of sales of 2 monthly in 2020?
-- Moving_aggregate_V1
Select T.month, SUM(F.total_num_of_sale),
TO_CHAR(SUM(SUM(F.total_num_of_sale))
OVER(ORDER BY T.month ROWS 1 PRECEDING), '9,999,999') AS Moving_2_Months_Avg
FROM SaleFact_V1 F, TimeDim_V1 T
WHERE F.time_id = T.time_id
AND T.year = 2020
Group By T.month;

-- Moving_aggregate_V2
Select T.month, SUM(F.total_num_of_sale),
TO_CHAR(SUM(SUM(F.total_num_of_sale))
OVER(ORDER BY T.month ROWS 1 PRECEDING), '9,999,999') AS Moving_2_Months_Avg
FROM SaleFact_V2 F, TimeDim_V1 T
WHERE F.time_id = T.time_id
AND T.year = 2020
Group By T.month;

-- Report 10: What is the total number of sales and cumulative number of sales with small property scale in each year?
-- Cumulative_V1
Select T.year, SUM(F.total_num_of_sale),
 TO_CHAR(SUM(SUM(F.total_num_of_sale))
 OVER(ORDER BY T.year ROWS UNBOUNDED PRECEDING),'9,999,999') AS Cummulative_visitors
FROM SaleFact_V1 F, TimeDim_V1 T
WHERE F.property_scale = 'Small'
AND F.time_id = T.time_id
Group By T.year;

-- Cumulative_V2
Select T.year, SUM(F.total_num_of_sale),
TO_CHAR(SUM(SUM(F.total_num_of_sale))
OVER(ORDER BY T.year ROWS UNBOUNDED PRECEDING),'9,999,999') AS Cummulative_visitors
FROM SaleFact_V2 F, TimeDim_V2 T, PropertyScaleDim_V2 PS
WHERE F.property_scale = PS.property_scale
AND PS.property_scale = 'Small'
AND F.time_id = T.time_id
Group By T.year;

-- Report 11: Show ranking of each property type based on the yearly
-- total number of sales and the ranking of each state based on the yearly total number of sales. 
--V1
SELECT T.year, F.property_type, F.state_code,
TO_CHAR(SUM(F.total_sales)) AS Total_Sales,
RANK() OVER (PARTITION BY F.property_type ORDER BY SUM(F.total_sales) DESC) AS Rank_By_Property_Type,
RANK() OVER (PARTITION BY F.state_code ORDER BY SUM(F.total_sales) DESC) AS Rank_By_State
FROM SaleFact_V1 F, TimeDim_V1 T 
WHERE F.time_id = T.time_id
GROUP BY T.year, F.property_type, F.state_code;

--V2
SELECT T.year, PT.property_type, S.state_code,
TO_CHAR(SUM(F.total_sales)) AS Total_Sales,
RANK() OVER (PARTITION BY PT.property_type ORDER BY SUM(F.total_sales) DESC) AS Rank_By_Property_Type,
RANK() OVER (PARTITION BY S.state_code ORDER BY SUM(F.total_sales) DESC) AS Rank_By_State
FROM SaleFact_V2 F, PropertyTypeDim_V2 PT, StateDim_V2 S, TimeDim_V2 T 
WHERE F.time_id = T.time_id
AND F.property_type = PT.property_type
AND F.state_code = S.state_code
GROUP BY T.year, PT.property_type, S.state_code;

-- Report 12: Show ranking of each suburb based on the monthly total number of rent
-- and the ranking of each property scale based on monthly total number of rents.
--V1
SELECT T.month, F.property_scale, F.suburb,
TO_CHAR(SUM(F.total_rental_fees)) AS Total_Rental_Fees,
RANK() OVER (PARTITION BY F.property_scale ORDER BY SUM(F.total_rental_fees) DESC) AS Rank_By_Property_Type,
RANK() OVER (PARTITION BY F.suburb ORDER BY SUM(F.total_rental_fees) DESC) AS Rank_By_State
FROM RentFact_V1 F, TimeDim_V1 T 
WHERE F.time_id = T.time_id
GROUP BY T.month, F.property_scale, F.suburb;

--V2
SELECT T.month, PS.property_scale, S.suburb,
TO_CHAR(SUM(F.total_rental_fees)) AS Total_Rental_Fees,
RANK() OVER (PARTITION BY PS.property_scale ORDER BY SUM(F.total_rental_fees) DESC) AS Rank_By_Property_Scale,
RANK() OVER (PARTITION BY S.suburb ORDER BY SUM(F.total_rental_fees) DESC) AS Rank_By_Suburb
FROM RentFact_V2 F, SuburbDim_V2 S, PropertyScaleDim_V2 PS, TimeDim_V2 T 
WHERE F.time_id = T.time_id
AND F.property_scale = PS.property_scale
AND F.suburb = S.suburb
GROUP BY T.month, PS.property_scale, S.suburb;














