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
DROP TABLE Agent_ClientGenderDim_V2;
--1. create Agent_ClientGenderDim_V2  
CREATE TABLE Agent_ClientGenderDim_V2 AS
SELECT DISTINCT gender FROM Person;
--------------------------------------------------------------------------------
DROP TABLE PropertyFeatureDim_V2;
--2. create PropertyFeatureDim_V2 
CREATE TABLE PropertyFeatureDim_V2 AS
SELECT P.property_id,
1.0/COUNT(*) AS weight_factor,
listagg (PF.feature_code,'_') within GROUP (ORDER BY PF.feature_code) AS property_feature_list
FROM Property P, Property_Feature PF
WHERE P.property_id = PF.property_id
GROUP BY P.property_id;
--------------------------------------------------------------------------------
DROP TABLE Property_Feature_Bridge_Table_V2;
--3. create Property_Feature_Bridge_Table_V2
CREATE TABLE Property_Feature_Bridge_Table_V2 AS
SELECT * FROM Property_Feature;
--------------------------------------------------------------------------------
DROP TABLE FeatureDim_V2;
--4. create FeatureDim_V2 Dim_V2ension
CREATE TABLE FeatureDim_V2 AS
SELECT * FROM Feature;
--------------------------------------------------------------------------------
DROP TABLE RentPriceDim_V2;
--5. create RentPriceDim_V2 Dim_V2ension
CREATE TABLE RentPriceDim_V2 AS
SELECT property_id, rent_start_date, rent_end_date, price
FROM Rent;
--------------------------------------------------------------------------------
DROP TABLE PropertyScaleDim_V2;
--6. create PropertyScaleDim_V2 Dim_V2ension
CREATE TABLE PropertyScaleDim_V2 (
    property_scale        VARCHAR2(50),
    scale_description     VARCHAR2(50)
);
--------------------------------------------------------------------------------
DROP TABLE PropertyFeatureCategoryDim_V2;
--7. create PropertyFeatureCategoryDim_V2 Dim_V2ension
CREATE TABLE PropertyFeatureCategoryDim_V2 (
    property_feature_category        VARCHAR2(50),
    category_description     VARCHAR2(50)
);
--------------------------------------------------------------------------------
DROP TABLE SuburbDim_V2;
--8. create SuburbDim_V2 Dim_V2ension
CREATE TABLE SuburbDim_V2 AS
SELECT DISTINCT suburb
FROM Address;
--------------------------------------------------------------------------------
DROP TABLE PropertyTypeDim_V2;
--9. create PropertyTypeDim_V2 Dim_V2ension
CREATE TABLE PropertyTypeDim_V2 AS
SELECT DISTINCT property_type
FROM Property;
--------------------------------------------------------------------------------
DROP TABLE StateDim_V2;
--10. create StateDim_V2 Dim_V2ension
CREATE TABLE StateDim_V2 AS
SELECT DISTINCT state_code
FROM State;
--------------------------------------------------------------------------------
DROP TABLE AgentDim_V2;
--11. AgentDim_V2 Dim_V2ension 
CREATE TABLE AgentDim_V2 AS
SELECT A.person_id,
P.first_name || ' ' || P.last_name AS agent_name,
1.0/COUNT(*) AS weight_factor,
listagg (AO.office_id,'_') within GROUP (ORDER BY AO.office_id) AS agent_office_list
FROM Agent A, Agent_Office AO, Person P
WHERE A.person_id = P.person_id
AND A.person_id = AO.person_id
GROUP BY A.person_id, P.first_name || ' ' || P.last_name;
--------------------------------------------------------------------------------
DROP TABLE Agent_Office_Bridge_Table_V2;
--12. create Agent_Office_Bridge_Table_V2
CREATE TABLE Agent_Office_Bridge_Table_V2 AS
SELECT * FROM Agent_Office;
--------------------------------------------------------------------------------
DROP TABLE OfficeDim_V2;
--13. create OfficeDim_V2 Dim_V2ension
CREATE TABLE OfficeDim_V2 AS
SELECT * FROM Office;
--------------------------------------------------------------------------------
DROP TABLE RentalPeriodDim_V2;
--14. create RentalPeriodDim_V2 Dim_V2ension
CREATE TABLE RentalPeriodDim_V2(
    period        VARCHAR2(50),
    period_description     VARCHAR2(50)
);
--------------------------------------------------------------------------------
DROP TABLE SeasonDim_V2;
--15. create SeasonDim_V2 Dim_V2ension
CREATE TABLE SeasonDim_V2(
    season_id        VARCHAR2(50),
    season_description     VARCHAR2(50)
);
--------------------------------------------------------------------------------
DROP TABLE MaxBudgetRangeDim_V2;
--16. create MaxBudgetRangeDim_V2 Dim_V2ension
CREATE TABLE MaxBudgetRangeDim_V2(
    budget_range        VARCHAR2(50),
    range_description     VARCHAR2(50)
);
--------------------------------------------------------------------------------
DROP TABLE OfficeSizeDim_V2;
--17. create OfficeSizeDim_V2 Dim_V2ension
CREATE TABLE OfficeSizeDim_V2(
    office_size        VARCHAR2(50),
    office_size_description     VARCHAR2(50)
);
--------------------------------------------------------------------------------
DROP TABLE TimeDim_V2;
--18. create TimeDim_V2 Dim_V2ension
CREATE TABLE TimeDim_V2 AS
SELECT time_id,"year" as year, "month" as month, "day" as day FROM (
SELECT
TO_CHAR(sale_date,'YYYYMMDD') AS time_id,
TO_CHAR(sale_date,'YYYY') AS "year",
TO_CHAR(sale_date,'MM') AS "month",
TO_CHAR(sale_date,'DD') AS "day"
FROM Sale
UNION
SELECT
TO_CHAR(rent_start_date,'YYYYMMDD') AS time_id,
TO_CHAR(rent_start_date,'YYYY') AS "year",
TO_CHAR(rent_start_date, 'MM') AS "month",
TO_CHAR(rent_start_date, 'DD') AS "day"
FROM Rent
UNION
SELECT
TO_CHAR(visit_date,'YYYYMMDD') AS time_id,
TO_CHAR(visit_date,'YYYY') AS "year",
TO_CHAR(visit_date, 'MM') AS "month",
TO_CHAR(visit_date,  'DD') AS "day"
FROM Visit
UNION
SELECT
TO_CHAR(property_date_added,'YYYYMMDD') AS time_id,
TO_CHAR(property_date_added,'YYYY') AS "year",
TO_CHAR(property_date_added, 'MM') AS "month",
TO_CHAR(property_date_added, 'DD') AS "day"
FROM Property
);
--------------------------------------------------------------------------------
DROP TABLE PropertyAdDim_V2;
--19. create PropertyAdDim_V2 Dim_V2ension 
CREATE TABLE PropertyAdDim_V2 AS
SELECT P.property_id,
1.0/COUNT(*) AS weight_factor,
listagg (PA.advert_id,'_') within GROUP (ORDER BY PA.advert_id) AS property_ad_list
FROM Property P, Property_Advert PA
WHERE P.property_id = PA.property_id
GROUP BY P.property_id;
--------------------------------------------------------------------------------
DROP TABLE Property_Ad_Bridge_Table_V2;
--20. create Property_Ad_Bridge_Table_V2
CREATE TABLE Property_Ad_Bridge_Table_V2 AS
SELECT property_id, advert_id FROM Property_Advert;
--------------------------------------------------------------------------------
DROP TABLE AdvertisementDim_V2;
--21. create AdvertisementDim_V2 Dim_V2ension
CREATE TABLE AdvertisementDim_V2 AS
SELECT * FROM Advertisement;
--------------------------------------------------------------------------------
DROP TABLE ClientDim_V2;
--22. create ClientDim_V2 Dim_V2ension 
CREATE TABLE ClientDim_V2 AS
SELECT C.person_id,
P.first_name || ' ' || P.last_name AS client_name,
1.0/COUNT(*) AS weight_factor,
listagg (CW.feature_code,'_') within GROUP (ORDER BY CW.feature_code) AS property_ad_list
FROM Client C, Person P, Client_Wish CW
WHERE C.person_id = P.person_id
AND CW. person_id = C.person_id
GROUP BY C.person_id, P.first_name || ' ' || P.last_name;
--------------------------------------------------------------------------------
DROP TABLE Client_Wish_Bridge_Table_V2;
--23. create Client_Wish_Bridge_Table_V2
CREATE TABLE Client_Wish_Bridge_Table_V2 AS
SELECT * FROM Client_Wish;

--------------------------------------------------------------------------------
-- populate Dimensions created from scratch (i.e. PropertyScaleDim_V2, PropertyFeatureCategoryDim_V2
-- RentalPeriodDim_V2, SeasonDim_V2, MaxBudgetRangeDim_V2, OfficeSizeDim_V2 )
--------------------------------------------------------------------------------
-- populate Property Scale dimension
INSERT INTO PropertyScaleDim_V2 
VALUES ('Extra Small', 'Has one or zero bedroom');

INSERT INTO PropertyScaleDim_V2 
VALUES ('Small', 'Has two or three bedrooms');

INSERT INTO PropertyScaleDim_V2 
VALUES ('Medium', 'Has three to six bedrooms');

INSERT INTO PropertyScaleDim_V2 
VALUES ('Large', 'Has six to ten bedrooms');

INSERT INTO PropertyScaleDim_V2 
VALUES ('Extra Large', 'Has more than ten bedrooms');

-- populate Property Feature Category dimension
INSERT INTO PropertyFeatureCategoryDim_V2 
VALUES ('Very Basic', 'Has less than ten features');

INSERT INTO PropertyFeatureCategoryDim_V2 
VALUES ('Standard', 'Has ten to twenty features');

INSERT INTO PropertyFeatureCategoryDim_V2 
VALUES ('Luxurious', 'Has more than twenty features');

-- populate Rental Period dimension
INSERT INTO RentalPeriodDim_V2 
VALUES ('Short', 'Less than six months');

INSERT INTO RentalPeriodDim_V2 
VALUES ('Medium', 'Six to twelve months');

INSERT INTO RentalPeriodDim_V2 
VALUES ('Long', 'More than twelve months');

-- populate Season dimension
INSERT INTO SeasonDim_V2 
VALUES ('spring', 'Sep, Oct, Nov');

INSERT INTO SeasonDim_V2 
VALUES ('summer', 'Dec, Jan, Feb');

INSERT INTO SeasonDim_V2 
VALUES ('autumn', 'Mar, Apr, May');

INSERT INTO SeasonDim_V2 
VALUES ('winter', 'Jun, Jul, Aug');

-- populate Max Budget Range dimension
INSERT INTO MaxBudgetRangeDim_V2 
VALUES ('Low', '0 to 1000');

INSERT INTO MaxBudgetRangeDim_V2 
VALUES ('Medium', '1001 to 100000');

INSERT INTO MaxBudgetRangeDim_V2 
VALUES ('High', '100001 to 10000000');

-- populate Office Size dimension
INSERT INTO OfficeSizeDim_V2 
VALUES ('Small', 'Less than four employees');

INSERT INTO OfficeSizeDim_V2 
VALUES ('Medium', 'Four to twelve employees');

INSERT INTO OfficeSizeDim_V2 
VALUES ('Big', 'More than twelve employees');
--------------------------------------------------------------------------------
-- create temp fact tables to extract from Sale table 
--------------------------------------------------------------------------------
DROP TABLE TempSaleFact1_V2;

CREATE TABLE TempSaleFact1_V2 AS
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
	
DROP TABLE TempSaleFact2_V2;	
CREATE TABLE TempSaleFact2_V2 AS
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
    FROM TempSaleFact1_V2 F, Person PE, Property_Feature PF
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

	
ALTER TABLE TempSaleFact2_V2 ADD
(
season_id VARCHAR2(50),
property_feature_category  VARCHAR2(50),
property_scale VARCHAR2(50)
);

UPDATE TempSaleFact2_V2
SET
season_id = 'spring'
WHERE TO_CHAR(sale_date,'MM') = 09
OR TO_CHAR(sale_date,'MM') = 10
OR TO_CHAR(sale_date,'MM') = 11;

UPDATE TempSaleFact2_V2
SET
season_id = 'summer'
WHERE TO_CHAR(sale_date,'MM') = 12
OR TO_CHAR(sale_date,'MM') = 01
OR TO_CHAR(sale_date,'MM') = 02;

UPDATE TempSaleFact2_V2
SET
season_id = 'autumn'
WHERE TO_CHAR(sale_date,'MM') = 3
OR TO_CHAR(sale_date,'MM') = 4
OR TO_CHAR(sale_date,'MM') = 5;

UPDATE TempSaleFact2_V2
SET
season_id = 'winter'
WHERE TO_CHAR(sale_date,'MM') = 6
OR TO_CHAR(sale_date,'MM') = 7
OR TO_CHAR(sale_date,'MM') = 8;

UPDATE TempSaleFact2_V2
SET
property_feature_category = 'Very Basic'
WHERE num_of_feature <= 10;

UPDATE TempSaleFact2_V2
SET
property_feature_category = 'Standard'
WHERE num_of_feature <= 20
AND num_of_feature > 10;

UPDATE TempSaleFact2_V2
SET
property_feature_category = 'Luxurious'
WHERE num_of_feature > 20;

UPDATE TempSaleFact2_V2
SET
property_scale = 'Extra Small'
WHERE property_no_of_bedrooms <= 1;

UPDATE TempSaleFact2_V2
SET
property_scale = 'Small'
WHERE property_no_of_bedrooms = 2
OR property_no_of_bedrooms = 3;

UPDATE TempSaleFact2_V2
SET
property_scale = 'Medium'
WHERE property_no_of_bedrooms = 4
OR property_no_of_bedrooms = 5
OR property_no_of_bedrooms = 6;

UPDATE TempSaleFact2_V2
SET
property_scale = 'Large'
WHERE property_no_of_bedrooms = 7
OR property_no_of_bedrooms = 8
OR property_no_of_bedrooms = 9
OR property_no_of_bedrooms = 10;

UPDATE TempSaleFact2_V2
SET
property_scale = 'Extra Large'
WHERE property_no_of_bedrooms > 10;
--------------------------------------------------------------------------------
-- create the fact table
--------------------------------------------------------------------------------
DROP TABLE SaleFact_V2;	
CREATE TABLE SaleFact_V2 AS
    SELECT
	time_id,
	season_id,
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
    FROM TempSaleFact2_V2
	GROUP BY 	
	time_id,
	season_id,
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
DROP TABLE TempRentFact1_V2;

CREATE TABLE TempRentFact1_V2 AS
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
	
DROP TABLE TempRentFact2_V2;
CREATE TABLE TempRentFact2_V2 AS
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
    FROM TempRentFact1_V2 F, Person PE, Property_Feature PF
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
------------------------check
ALTER TABLE TempRentFact2_V2 ADD
(
season_id VARCHAR2(50),
period VARCHAR2(50),
property_feature_category  VARCHAR2(50),
property_scale VARCHAR2(50)
);

UPDATE TempRentFact2_V2
SET
season_id = 'spring'
WHERE TO_CHAR(rent_start_date,'MM') = 9
OR TO_CHAR(rent_start_date,'MM') = 10
OR TO_CHAR(rent_start_date,'MM') = 11;

UPDATE TempRentFact2_V2
SET
season_id = 'summer'
WHERE TO_CHAR(rent_start_date,'MM') = 12
OR TO_CHAR(rent_start_date,'MM') = 1
OR TO_CHAR(rent_start_date,'MM') = 2;

UPDATE TempRentFact2_V2
SET
season_id = 'autumn'
WHERE TO_CHAR(rent_start_date,'MM') = 3
OR TO_CHAR(rent_start_date,'MM') = 4
OR TO_CHAR(rent_start_date,'MM') = 5;

UPDATE TempRentFact2_V2
SET
season_id = 'winter'
WHERE TO_CHAR(rent_start_date,'MM') = 6
OR TO_CHAR(rent_start_date,'MM') = 7
OR TO_CHAR(rent_start_date,'MM') = 8;

UPDATE TempRentFact2_V2
SET
property_feature_category = 'Very Basic'
WHERE num_of_feature <= 10;

UPDATE TempRentFact2_V2
SET
property_feature_category = 'Standard'
WHERE num_of_feature <= 20
AND num_of_feature > 10;

UPDATE TempRentFact2_V2
SET
property_feature_category = 'Luxurious'
WHERE num_of_feature > 20;

UPDATE TempRentFact2_V2
SET
property_scale = 'Extra Small'
WHERE property_no_of_bedrooms <= 1;

UPDATE TempRentFact2_V2
SET
property_scale = 'Small'
WHERE property_no_of_bedrooms = 2
OR property_no_of_bedrooms = 3;

UPDATE TempRentFact2_V2
SET
property_scale = 'Medium'
WHERE property_no_of_bedrooms = 4
OR property_no_of_bedrooms = 5
OR property_no_of_bedrooms = 6;

UPDATE TempRentFact2_V2
SET
property_scale = 'Large'
WHERE property_no_of_bedrooms = 7
OR property_no_of_bedrooms = 8
OR property_no_of_bedrooms = 9
OR property_no_of_bedrooms = 10;

UPDATE TempRentFact2_V2
SET
property_scale = 'Extra Large'
WHERE property_no_of_bedrooms > 10;

UPDATE TempRentFact2_V2
SET
period = 'Short'
WHERE  month_diff < 6;

UPDATE TempRentFact2_V2
SET
period = 'Medium'
WHERE month_diff >= 6
AND month_diff < 12;

UPDATE TempRentFact2_V2
SET
period = 'Long'
WHERE  month_diff >= 12;
--------------------------------------------------------------------------------
-- create the fact table
--------------------------------------------------------------------------------
DROP TABLE RentFact_V2;	
CREATE TABLE RentFact_V2 AS
    SELECT
	time_id,
	season_id,
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
    FROM TempRentFact2_V2
	GROUP BY 	
	time_id,
	season_id,	
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
DROP TABLE TempClientFact1_V2;

CREATE TABLE TempClientFact1_V2 AS
    SELECT DISTINCT
	P.gender,
	C.person_id AS client_id,
	C.max_budget
	FROM Client C, Person P
	WHERE C.person_id = P.person_id;

ALTER TABLE TempClientFact1_V2 ADD
(
budget_range VARCHAR2(50)
);

UPDATE TempClientFact1_V2
SET
budget_range = 'Low'
WHERE max_budget <= 1000;

UPDATE TempClientFact1_V2
SET
budget_range = 'Medium'
WHERE max_budget <= 100000
AND max_budget > 1000;

UPDATE TempClientFact1_V2
SET
budget_range = 'High'
WHERE max_budget <= 10000000
AND max_budget > 100000;

--------------------------------------------------------------------------------
-- create the fact table
--------------------------------------------------------------------------------
DROP TABLE ClientFact_V2;	
CREATE TABLE ClientFact_V2 AS
    SELECT
	gender,
	client_id,
	budget_range,
	COUNT(client_id) AS total_num_of_clients
    FROM TempClientFact1_V2
	GROUP BY 	
	gender,
	client_id,
	budget_range;
--------------------------------------------------------------------------------
-- create temp fact tables to extract from Visit table 
--------------------------------------------------------------------------------
DROP TABLE TempVisitFact1_V2;

CREATE TABLE TempVisitFact1_V2 AS
    SELECT DISTINCT
	TO_CHAR(V.visit_date,'YYYYMMDD') AS time_id,
	V.visit_date,
	V.property_id,
	V.property_id || V.client_person_id || V.agent_person_id  AS visit_id,
	C.max_budget
	FROM Client C, Visit V
	WHERE V.client_person_id = C.person_id;

ALTER TABLE TempVisitFact1_V2 ADD
(
budget_range VARCHAR2(50),
season_id VARCHAR2(50)
);

UPDATE TempVisitFact1_V2
SET
season_id = 'spring'
WHERE TO_CHAR(visit_date,'MM') = 9
OR TO_CHAR(visit_date,'MM') = 10
OR TO_CHAR(visit_date,'MM') = 11;

UPDATE TempVisitFact1_V2
SET
season_id = 'summer'
WHERE TO_CHAR(visit_date,'MM') = 12
OR TO_CHAR(visit_date,'MM') = 1
OR TO_CHAR(visit_date,'MM') = 2;

UPDATE TempVisitFact1_V2
SET
season_id = 'autumn'
WHERE TO_CHAR(visit_date,'MM') = 3
OR TO_CHAR(visit_date,'MM') = 4
OR TO_CHAR(visit_date,'MM') = 5;

UPDATE TempVisitFact1_V2
SET
season_id = 'winter'
WHERE TO_CHAR(visit_date,'MM') = 6
OR TO_CHAR(visit_date,'MM') = 7
OR TO_CHAR(visit_date,'MM') = 8;

UPDATE TempVisitFact1_V2
SET
budget_range = 'Low'
WHERE max_budget <= 1000;

UPDATE TempVisitFact1_V2
SET
budget_range = 'Medium'
WHERE max_budget <= 100000
AND max_budget > 1000;

UPDATE TempVisitFact1_V2
SET
budget_range = 'High'
WHERE max_budget <= 10000000
AND max_budget > 100000;
--------------------------------------------------------------------------------
-- create the fact table
--------------------------------------------------------------------------------
DROP TABLE VisitFact_V2;	
CREATE TABLE VisitFact_V2 AS
    SELECT
	time_id,
	season_id,
	budget_range,
	COUNT(visit_id) AS total_num_of_visit,
	COUNT(property_id) AS total_num_of_property_has_visit
    FROM TempVisitFact1_V2
	GROUP BY 	
	time_id,
	season_id,
	budget_range;
		
--------------------------------------------------------------------------------
-- create temp fact tables to extract from Advertisement table 
--------------------------------------------------------------------------------
DROP TABLE TempAdFact1_V2;

CREATE TABLE TempAdFact1_V2 AS
    SELECT DISTINCT
	TO_CHAR(P.property_date_added,'YYYYMMDD') AS time_id,
	PA.property_id
	FROM Property P, Property_Advert PA
	WHERE P.property_id =  PA.property_id;

--------------------------------------------------------------------------------
-- create the fact table
--------------------------------------------------------------------------------
DROP TABLE AdFact_V2;	
CREATE TABLE AdFact_V2 AS
    SELECT
	time_id,
	property_id,
	COUNT(property_id) AS total_num_of_property_has_ads
    FROM TempAdFact1_V2
	GROUP BY 	
	time_id,
	property_id;		

--------------------------------------------------------------------------------
-- create temp fact tables to extract from Agent table 
--------------------------------------------------------------------------------
DROP TABLE TempAgentFact1_V2;
CREATE TABLE TempAgentFact1_V2 AS
	SELECT 
	office_id,
	COUNT(*) AS num_of_employees
	FROM Agent_Office AO
	GROUP BY office_id;
	
DROP TABLE TempAgentFact2_V2;
CREATE TABLE TempAgentFact2_V2 AS
    SELECT DISTINCT
	AO.office_id,
	A.person_id AS agent_id,
	P.gender,
	A.salary,
	F.num_of_employees
	FROM TempAgentFact1_V2 F, Agent_Office AO, Agent A, Person P
	WHERE F.office_id = AO.office_id
	AND AO.person_id = A.person_id
	AND A.person_id = P.person_id;

ALTER TABLE TempAgentFact2_V2 ADD
(
office_size VARCHAR2(50)
);

UPDATE TempAgentFact2_V2
SET
office_size = 'Small'
WHERE num_of_employees < 4;

UPDATE TempAgentFact2_V2
SET
office_size = 'Medium'
WHERE num_of_employees >= 4
AND num_of_employees <= 12;

UPDATE TempAgentFact2_V2
SET
office_size = 'Big'
WHERE num_of_employees > 12 ;

--------------------------------------------------------------------------------
-- create the fact table
--------------------------------------------------------------------------------
DROP TABLE AgentFact_V2;	
CREATE TABLE AgentFact_V2 AS
    SELECT
	office_size,
	gender,
	agent_id,
	SUM(salary) AS total_salary,
	COUNT(agent_id) AS total_num_of_agents
    FROM TempAgentFact2_V2
	GROUP BY 	
	office_size,
	gender,
	agent_id;
	




































