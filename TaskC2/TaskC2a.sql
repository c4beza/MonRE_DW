-- Loading cleaned data
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
DROP TABLE Address;
-- create Address table
CREATE TABLE Address AS 
SELECT MAX(address_id) address_id, street, suburb, postcode 
FROM MonRE.Address 
GROUP BY street, suburb, postcode; 
--------------------------------------------------------------------------------
DROP TABLE Advertisement;
-- create Advertisement table
CREATE TABLE Advertisement AS SELECT * FROM MonRE.Advertisement; 
--------------------------------------------------------------------------------
DROP TABLE Agent;
-- create Agent table
CREATE TABLE Agent AS
SELECT * 
FROM MonRE.Agent
WHERE salary > 0; 
--------------------------------------------------------------------------------
DROP TABLE Agent_Office;
-- create Agent_Office table
CREATE TABLE Agent_Office AS SELECT * FROM MonRE.Agent_Office; 
--------------------------------------------------------------------------------
DROP TABLE Client;
-- create Client table
CREATE TABLE Client AS
SELECT * 
FROM MonRE.Client
WHERE max_budget > 0 
AND max_budget > min_budget; 
--------------------------------------------------------------------------------
DROP TABLE Client_Wish;
-- create Client_Wish table
CREATE TABLE Client_Wish AS SELECT * FROM MonRE.Client_Wish; 
--------------------------------------------------------------------------------
DROP TABLE Feature;
-- create Feature table
CREATE TABLE Feature AS SELECT * FROM MonRE.Feature; 
--------------------------------------------------------------------------------
DROP TABLE Office;
-- create Office table
CREATE TABLE Office AS SELECT * FROM MonRE.Office; 
--------------------------------------------------------------------------------
DROP TABLE Person;
-- create Person table
CREATE TABLE Person AS 
SELECT DISTINCT person_id, title, first_name, last_name, gender, address_id, phone_no, email
FROM MonRE.Person
WHERE address_id IN (SELECT address_id from Address); 
--------------------------------------------------------------------------------
DROP TABLE Postcode;
-- create Postcode table
CREATE TABLE Postcode AS SELECT * FROM MonRE.Postcode; 
--------------------------------------------------------------------------------
DROP TABLE Property;
-- create Property table
CREATE TABLE Property AS 
SELECT DISTINCT property_id, property_date_added, address_id, property_type, 
property_no_of_bedrooms, property_no_of_bathrooms, property_no_of_garages, NVL(property_size, 0) AS property_size,
property_description 
FROM MonRE.Property; 
--------------------------------------------------------------------------------
DROP TABLE Property_Advert;
-- create Property_Advert table
CREATE TABLE Property_Advert AS SELECT * FROM MonRE.Property_Advert; 
--------------------------------------------------------------------------------
DROP TABLE Property_Feature;
-- create Property_Feature table
CREATE TABLE Property_Feature AS SELECT * FROM MonRE.Property_Feature;
--------------------------------------------------------------------------------
DROP TABLE Rent;
-- create Rent table
CREATE TABLE Rent AS 
SELECT * 
FROM MonRE.Rent
WHERE client_person_id IS NOT NULL
AND rent_start_date IS NOT NULL
AND rent_end_date IS NOT NULL;
--------------------------------------------------------------------------------
DROP TABLE Sale;
-- create Sale table
CREATE TABLE Sale AS 
SELECT * 
FROM MonRE.Sale
WHERE client_person_id IS NOT NULL
AND sale_date IS NOT NULL;
--------------------------------------------------------------------------------
DROP TABLE State;
-- create State table
CREATE TABLE State AS
SELECT * 
FROM MonRE.State
WHERE state_code IS NOT NULL
AND state_name IS NOT NULL;
--------------------------------------------------------------------------------
DROP TABLE Visit;
-- create Visit table
CREATE TABLE Visit AS SELECT * FROM MonRE.Visit;
--------------------------------------------------------------------------------
-- Creating the MonRE Data Warehouse with cleaned data
--------------------------------------------------------------------------------
-- first create the dimensions
--------------------------------------------------------------------------------
DROP TABLE RentPriceDim_V1;
--1. create RentPriceDim_V1 dimension
CREATE TABLE RentPriceDim_V1 AS
SELECT property_id, rent_start_date, rent_end_date, price
FROM Rent;
--------------------------------------------------------------------------------
DROP TABLE PropertyFeatureDim_V1;
--2. create PropertyFeatureDim_V1 dimension 
CREATE TABLE PropertyFeatureDim_V1 AS
SELECT P.property_id,
1.0/COUNT(*) AS weight_factor,
listagg (PF.feature_code,'_') within GROUP (ORDER BY PF.feature_code) AS property_feature_list
FROM Property P, Property_Feature PF
WHERE P.property_id = PF.property_id
GROUP BY P.property_id;
--------------------------------------------------------------------------------
DROP TABLE Property_Feature_Bridge_Table_V1;
--3. create Property_Feature_Bridge_Table_V1
CREATE TABLE Property_Feature_Bridge_Table_V1 AS
SELECT * FROM Property_Feature;
--------------------------------------------------------------------------------
DROP TABLE FeatureDim_V1;
--4. create FeatureDim_V1 dimension
CREATE TABLE FeatureDim_V1 AS
SELECT * FROM Feature;
--------------------------------------------------------------------------------
DROP TABLE AgentDim_V1;
--5. create AgentDim_V1 dimension 
CREATE TABLE AgentDim_V1 AS
SELECT A.person_id,
P.first_name || ' ' || P.last_name AS agent_name,
1.0/COUNT(*) AS weight_factor,
listagg (AO.office_id,'_') within GROUP (ORDER BY AO.office_id) AS agent_office_list
FROM Agent A, Agent_Office AO, Person P
WHERE A.person_id = P.person_id
AND A.person_id = AO.person_id
GROUP BY A.person_id, P.first_name || ' ' || P.last_name;
--------------------------------------------------------------------------------
DROP TABLE Agent_Office_Bridge_Table_V1;
--6. create Agent_Office_Bridge_Table_V1
CREATE TABLE Agent_Office_Bridge_Table_V1 AS
SELECT * FROM Agent_Office;
--------------------------------------------------------------------------------
DROP TABLE OfficeDim_V1;
--7. create OfficeDim_V1 dimension
CREATE TABLE OfficeDim_V1 AS
SELECT * FROM Office;
--------------------------------------------------------------------------------
DROP TABLE TimeDim_V1;
--8. create TimeDim_V1 dimension
CREATE TABLE TimeDim_V1 AS
SELECT * FROM (
SELECT
TO_CHAR(sale_date,'YYYYMMDD') AS time_id,
TO_CHAR(sale_date,'YYYY') AS "year",
TO_CHAR(sale_date,'MM') AS "month",
TO_CHAR(sale_date,'DD') AS "date"
FROM Sale
UNION
SELECT
TO_CHAR(rent_start_date,'YYYYMMDD') AS time_id,
TO_CHAR(rent_start_date,'YYYY') AS "year",
TO_CHAR(rent_start_date, 'MM') AS "month",
TO_CHAR(rent_start_date, 'DD') AS "date"
FROM Rent
UNION
SELECT
TO_CHAR(visit_date,'YYYYMMDD') AS time_id,
TO_CHAR(visit_date,'YYYY') AS "year",
TO_CHAR(visit_date, 'MM') AS "month",
TO_CHAR(visit_date,  'DD') AS "date"
FROM Visit
UNION
SELECT
TO_CHAR(property_date_added,'YYYYMMDD') AS time_id,
TO_CHAR(property_date_added,'YYYY') AS "year",
TO_CHAR(property_date_added, 'MM') AS "month",
TO_CHAR(property_date_added, 'DD') AS "date"
FROM Property
);
ALTER TABLE TimeDim_V1 ADD
(
season VARCHAR2(50)
);

UPDATE TimeDim_V1
SET
season = 'spring'
WHERE "month" = 09
OR "month" = 10
OR "month" = 11;

UPDATE TimeDim_V1
SET
season = 'summer'
WHERE "month" = 12
OR "month" = 01
OR "month" = 02;

UPDATE TimeDim_V1
SET
season = 'autumn'
WHERE "month" = 3
OR "month" = 4
OR "month" = 5;

UPDATE TimeDim_V1
SET
season = 'winter'
WHERE "month" = 6
OR "month" = 7
OR "month" = 8;
--------------------------------------------------------------------------------
-- create temp fact tables to extract from Sale table 
--------------------------------------------------------------------------------
DROP TABLE TempSaleFact1_V1;

CREATE TABLE TempSaleFact1_V1 AS
    SELECT DISTINCT
	TO_CHAR(S.sale_date,'YYYYMMDD') AS time_id,
	S.sale_date,
	ST.state_code, 
	P.property_type, 
	A.suburb,
	P.property_no_of_bedrooms,
	S.property_id,
	PE.gender AS agent_gender,
	S.client_person_id,
	S.agent_person_id AS agent_id,
	S.sale_id,
	s.price
    FROM Sale S, State ST, Property P, Address A, Postcode PO, Person PE
    WHERE S.property_id = P.property_id
	AND P.address_id = A.address_id
	AND A.postcode = PO.postcode
	AND PO.state_code = ST.state_code
	AND S.agent_person_id = PE.person_id;
	
DROP TABLE TempSaleFact2_V1;	
CREATE TABLE TempSaleFact2_V1 AS
    SELECT
	F.time_id,
	F.sale_date,
	F.state_code, 
	F.property_type, 
	F.suburb,
	F.property_no_of_bedrooms,
	F.property_id,
	F.agent_gender,
	F.agent_id,
	F.sale_id,
	F.price,
	PE.gender AS client_gender?
	COUNT(PF.feature_code) AS num_of_feature
    FROM TempSaleFact1_V1 F, Person PE, Property_Feature PF
    WHERE F.client_person_id = PE.person_id
	AND F.property_id = PF.property_id
	GROUP BY
	F.time_id,
	F.sale_date,	
	F.state_code, 
	F.property_type, 
	F.suburb,
	F.property_no_of_bedrooms,
	F.property_id,
	F.agent_gender,
	F.agent_id,
	F.sale_id,
	F.price,
	PE.gender; 	

	
ALTER TABLE TempSaleFact2_V1 ADD
(
property_feature_category  VARCHAR2(50),
property_scale VARCHAR2(50)
);

UPDATE TempSaleFact2_V1
SET
property_feature_category = 'Very Basic'
WHERE num_of_feature <= 10;

UPDATE TempSaleFact2_V1
SET
property_feature_category = 'Standard'
WHERE num_of_feature <= 20
AND num_of_feature > 10;

UPDATE TempSaleFact2_V1
SET
property_feature_category = 'Luxurious'
WHERE num_of_feature > 20;

UPDATE TempSaleFact2_V1
SET
property_scale = 'Extra Small'
WHERE property_no_of_bedrooms <= 1;

UPDATE TempSaleFact2_V1
SET
property_scale = 'Small'
WHERE property_no_of_bedrooms = 2
OR property_no_of_bedrooms = 3;

UPDATE TempSaleFact2_V1
SET
property_scale = 'Medium'
WHERE property_no_of_bedrooms = 4
OR property_no_of_bedrooms = 5
OR property_no_of_bedrooms = 6;

UPDATE TempSaleFact2_V1
SET
property_scale = 'Large'
WHERE property_no_of_bedrooms = 7
OR property_no_of_bedrooms = 8
OR property_no_of_bedrooms = 9
OR property_no_of_bedrooms = 10;

UPDATE TempSaleFact2_V1
SET
property_scale = 'Extra Large'
WHERE property_no_of_bedrooms > 10;
--------------------------------------------------------------------------------
-- create the fact table
--------------------------------------------------------------------------------
DROP TABLE SaleFact_V1;	
CREATE TABLE SaleFact_V1 AS
    SELECT
	time_id,
	state_code, 
	property_type, 
	suburb,
	property_scale,
	property_feature_category,
	property_id,
	agent_gender,
	client_gender,
	agent_id,
	COUNT(sale_id) AS total_num_of_sale,
	SUM(price) AS total_sales
    FROM TempSaleFact2_V1
	GROUP BY 	
	time_id,
	state_code, 
	property_type, 
	suburb,
	property_scale,
	property_feature_category,
	property_id,
	agent_gender,
	client_gender,
	agent_id;
--------------------------------------------------------------------------------
-- create temp fact tables to extract from Rent table 
--------------------------------------------------------------------------------
DROP TABLE TempRentFact1_V1;

CREATE TABLE TempRentFact1_V1 AS
    SELECT DISTINCT
	TO_CHAR(R.rent_start_date,'YYYYMMDD') AS time_id,
	R.rent_start_date,
	R.rent_end_date,
	PE.gender AS agent_gender,
	R.client_person_id,
	R.property_id,
	P.property_no_of_bedrooms,
	P.property_type, 
	A.suburb,
	ST.state_code, 	
	R.agent_person_id AS agent_id,
	R.rent_id,
	R.price
    FROM Rent R, State ST, Property P, Address A, Postcode PO, Person PE
    WHERE R.property_id = P.property_id
	AND P.address_id = A.address_id
	AND A.postcode = PO.postcode
	AND PO.state_code = ST.state_code
	AND R.agent_person_id = PE.person_id;
	
DROP TABLE TempRentFact2_V1;
CREATE TABLE TempRentFact2_V1 AS
    SELECT
	F.time_id,
	(F.rent_end_date - F.rent_start_date)/30 AS month_diff,
	F.agent_gender,
	F.rent_start_date,
    F.rent_end_date,
	PE.gender AS client_gender,
	F.property_id,
	F.property_type, 	
	F.state_code, 
	F.suburb,
	F.agent_id,
	F.property_no_of_bedrooms,
	F.rent_id,
	F.price,
	COUNT(PF.feature_code) AS num_of_feature
    FROM TempRentFact1_V1 F, Person PE, Property_Feature PF
    WHERE F.client_person_id = PE.person_id
	AND F.property_id = PF.property_id
	GROUP BY 	
	F.time_id,
	(F.rent_end_date - F.rent_start_date)/30, 
	F.agent_gender,
	F.rent_start_date,
    F.rent_end_date,
	PE.gender,
	F.property_id,
	F.property_type, 	
	F.state_code, 
	F.suburb,
	F.agent_id,
	F.property_no_of_bedrooms,
	F.rent_id,
	F.price;

ALTER TABLE TempRentFact2_V1 ADD
(
period VARCHAR2(50),
property_feature_category  VARCHAR2(50),
property_scale VARCHAR2(50)
);

UPDATE TempRentFact2_V1
SET
property_feature_category = 'Very Basic'
WHERE num_of_feature <= 10;

UPDATE TempRentFact2_V1
SET
property_feature_category = 'Standard'
WHERE num_of_feature <= 20
AND num_of_feature > 10;

UPDATE TempRentFact2_V1
SET
property_feature_category = 'Luxurious'
WHERE num_of_feature > 20;

UPDATE TempRentFact2_V1
SET
property_scale = 'Extra Small'
WHERE property_no_of_bedrooms <= 1;

UPDATE TempRentFact2_V1
SET
property_scale = 'Small'
WHERE property_no_of_bedrooms = 2
OR property_no_of_bedrooms = 3;

UPDATE TempRentFact2_V1
SET
property_scale = 'Medium'
WHERE property_no_of_bedrooms = 4
OR property_no_of_bedrooms = 5
OR property_no_of_bedrooms = 6;

UPDATE TempRentFact2_V1
SET
property_scale = 'Large'
WHERE property_no_of_bedrooms = 7
OR property_no_of_bedrooms = 8
OR property_no_of_bedrooms = 9
OR property_no_of_bedrooms = 10;

UPDATE TempRentFact2_V1
SET
property_scale = 'Extra Large'
WHERE property_no_of_bedrooms > 10;

UPDATE TempRentFact2_V1
SET
period = 'Short'
WHERE  month_diff < 6;

UPDATE TempRentFact2_V1
SET
period = 'Medium'
WHERE month_diff >= 6
AND month_diff < 12;

UPDATE TempRentFact2_V1
SET
period = 'Long'
WHERE  month_diff >= 12;
--------------------------------------------------------------------------------
-- create the fact table
--------------------------------------------------------------------------------
DROP TABLE RentFact_V1;	
CREATE TABLE RentFact_V1 AS
    SELECT
	time_id,
	period,
	agent_gender,
	client_gender,
	property_id,
	property_scale,
	property_feature_category,
	property_type, 
	suburb,
	state_code, 
	agent_id,
	COUNT(rent_id) AS total_num_of_rent,
	SUM(price) AS total_rental_fees
    FROM TempRentFact2_V1
	GROUP BY 	
	time_id,
	period,
	agent_gender,
	client_gender,
	property_id,
	property_scale,
	property_feature_category,
	property_type, 
	suburb,
	state_code, 
	agent_id;

--------------------------------------------------------------------------------
-- create temp fact tables to extract from Client table 
--------------------------------------------------------------------------------
DROP TABLE TempClientFact1_V1;

CREATE TABLE TempClientFact1_V1 AS
    SELECT DISTINCT
	P.gender,
	C.person_id AS client_id,
	C.max_budget
	FROM Client C, Person P
	WHERE C.person_id = P.person_id;

ALTER TABLE TempClientFact1_V1 ADD
(
budget_range VARCHAR2(50)
);

UPDATE TempClientFact1_V1
SET
budget_range = 'Low'
WHERE max_budget <= 1000;

UPDATE TempClientFact1_V1
SET
budget_range = 'Medium'
WHERE max_budget <= 100000
AND max_budget > 1000;

UPDATE TempClientFact1_V1
SET
budget_range = 'High'
WHERE max_budget <= 10000000
AND max_budget > 100000;

--------------------------------------------------------------------------------
-- create the fact table
--------------------------------------------------------------------------------
DROP TABLE ClientFact_V1;	
CREATE TABLE ClientFact_V1 AS
    SELECT
	gender,
	budget_range,
	COUNT(client_id) AS total_num_of_clients
    FROM TempClientFact1_V1
	GROUP BY 	
	gender,
	budget_range;

--------------------------------------------------------------------------------
-- create temp fact tables to extract from Visit table 
--------------------------------------------------------------------------------
DROP TABLE TempVisitFact1_V1;

CREATE TABLE TempVisitFact1_V1 AS
    SELECT DISTINCT
	TO_CHAR(V.visit_date,'YYYYMMDD') AS time_id,
	V.visit_date,
	V.property_id,
	V.property_id || V.client_person_id || V.agent_person_id  AS visit_id,
	C.max_budget
	FROM Client C, Visit V
	WHERE V.client_person_id = C.person_id;

ALTER TABLE TempVisitFact1_V1 ADD
(
budget_range VARCHAR2(50)
);

UPDATE TempVisitFact1_V1
SET
budget_range = 'Low'
WHERE max_budget <= 1000;

UPDATE TempVisitFact1_V1
SET
budget_range = 'Medium'
WHERE max_budget <= 100000
AND max_budget > 1000;

UPDATE TempVisitFact1_V1
SET
budget_range = 'High'
WHERE max_budget <= 10000000
AND max_budget > 100000;

--------------------------------------------------------------------------------
-- create the fact table
--------------------------------------------------------------------------------
DROP TABLE VisitFact_V1;	
CREATE TABLE VisitFact_V1 AS
    SELECT
	time_id,
	budget_range,
	COUNT(visit_id) AS total_num_of_visit,
	COUNT(property_id) AS total_num_of_property_has_visit
    FROM TempVisitFact1_V1
	GROUP BY 	
	time_id,
	budget_range;
--------------------------------------------------------------------------------
-- create temp fact tables to extract from Advertisement table 
--------------------------------------------------------------------------------
DROP TABLE TempAdFact1_V1;

CREATE TABLE TempAdFact1_V1 AS
    SELECT DISTINCT
	TO_CHAR(P.property_date_added,'YYYYMMDD') AS time_id,
	PA.property_id,
	PA.advert_id
	FROM Property P, Property_Advert PA
	WHERE P.property_id =  PA.property_id (+);

ALTER TABLE TempAdFact1_V1 ADD
(
advert_type VARCHAR2(50)
);
UPDATE TempAdFact1_V1
SET
advert_type = 'Rent'
WHERE advert_id >= 1
AND advert_id <=11;

UPDATE TempAdFact1_V1
SET
advert_type = 'Sale'
WHERE advert_id >= 12
AND advert_id <= 25;
--------------------------------------------------------------------------------
-- create the fact table
--------------------------------------------------------------------------------
DROP TABLE AdFact_V1;	
CREATE TABLE AdFact_V1 AS
    SELECT
	time_id,
	advert_type,
	COUNT(property_id) AS total_num_of_property_has_ads
    FROM TempAdFact1_V1
	GROUP BY 	
	time_id,
	advert_type;		
--------------------------------------------------------------------------------
-- create temp fact tables to extract from Agent table 
--------------------------------------------------------------------------------
DROP TABLE TempAgentFact1_V1;
CREATE TABLE TempAgentFact1_V1 AS
	SELECT 
	office_id,
	COUNT(*) AS num_of_employees
	FROM Agent_Office AO
	GROUP BY office_id;
	
DROP TABLE TempAgentFact2_V1;
CREATE TABLE TempAgentFact2_V1 AS
    SELECT DISTINCT
	AO.office_id,
	A.person_id AS agent_id,
	P.gender,
	A.salary,
	F.num_of_employees
	FROM TempAgentFact1_V1 F, Agent_Office AO, Agent A, Person P
	WHERE F.office_id = AO.office_id
	AND AO.person_id = A.person_id
	AND A.person_id = P.person_id;
	
ALTER TABLE TempAgentFact2_V1 ADD
(
office_size VARCHAR2(50)
);

UPDATE TempAgentFact2_V1
SET
office_size = 'Small'
WHERE num_of_employees < 4;

UPDATE TempAgentFact2_V1
SET
office_size = 'Medium'
WHERE num_of_employees >= 4
AND num_of_employees <= 12;

UPDATE TempAgentFact2_V1
SET
office_size = 'Big'
WHERE num_of_employees > 12 ;

--------------------------------------------------------------------------------
-- create the fact table
--------------------------------------------------------------------------------
DROP TABLE AgentFact_V1;	
CREATE TABLE AgentFact_V1 AS
    SELECT
	office_size,
	gender,
	agent_id,
	SUM(salary) AS total_salary,
	COUNT(agent_id) AS total_num_of_agents
    FROM TempAgentFact2_V1
	GROUP BY 	
	office_size,
	gender,
	agent_id;
	















































