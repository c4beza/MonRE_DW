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
DROP TABLE Agent_ClientGenderDim;
--1. create Agent_ClientGenderDim dimension 
CREATE TABLE Agent_ClientGenderDim AS
SELECT DISTINCT gender FROM Person;
--------------------------------------------------------------------------------
DROP TABLE PropertyFeatureDim;
--2. create PropertyFeatureDim dimension 
CREATE TABLE PropertyFeatureDim AS
SELECT P.property_id,
1.0/COUNT(*) AS weight_factor,
listagg (PF.feature_code,'_') within GROUP (ORDER BY PF.feature_code) AS property_feature_list
FROM Property P, Property_Feature PF
WHERE P.property_id = PF.property_id
GROUP BY P.property_id;
--------------------------------------------------------------------------------
DROP TABLE Property_Feature_Bridge_Table;
--3. create Property_Feature_Bridge_Table
CREATE TABLE Property_Feature_Bridge_Table AS
SELECT * FROM Property_Feature;
--------------------------------------------------------------------------------
DROP TABLE FeatureDim;
--4. create FeatureDim dimension
CREATE TABLE FeatureDim AS
SELECT * FROM Feature;
--------------------------------------------------------------------------------
DROP TABLE RentPriceDim;
--5. create RentPriceDim dimension
CREATE TABLE RentPriceDim AS
SELECT property_id, rent_start_date, rent_end_date, price
FROM Rent;
--------------------------------------------------------------------------------
DROP TABLE PropertyScaleDim;
--6. create PropertyScaleDim dimension
CREATE TABLE PropertyScaleDim (
    property_scale        VARCHAR2(50),
    scale_description     VARCHAR2(50)
);
--------------------------------------------------------------------------------
DROP TABLE PropertyFeatureCategoryDim;
--7. create PropertyFeatureCategoryDim dimension
CREATE TABLE PropertyFeatureCategoryDim (
    property_feature_category        VARCHAR2(50),
    category_description     VARCHAR2(50)
);
--------------------------------------------------------------------------------
DROP TABLE SuburbDim;
--8. create SuburbDim dimension
CREATE TABLE SuburbDim AS
SELECT DISTINCT suburb
FROM Address;
--------------------------------------------------------------------------------
DROP TABLE PropertyTypeDim;
--9. create PropertyTypeDim dimension
CREATE TABLE PropertyTypeDim AS
SELECT DISTINCT property_type
FROM Property;
--------------------------------------------------------------------------------
DROP TABLE StateDim;
--10. create StateDim dimension
CREATE TABLE StateDim AS
SELECT DISTINCT state_code
FROM State;
--------------------------------------------------------------------------------
DROP TABLE AgentDim;
--11. AgentDim dimension 
CREATE TABLE AgentDim AS
SELECT A.person_id,
P.first_name || ' ' || P.last_name AS agent_name,
1.0/COUNT(*) AS weight_factor,
listagg (AO.office_id,'_') within GROUP (ORDER BY AO.office_id) AS agent_office_list
FROM Agent A, Agent_Office AO, Person P
WHERE A.person_id = P.person_id
AND A.person_id = AO.person_id
GROUP BY A.person_id, P.first_name || ' ' || P.last_name;
--------------------------------------------------------------------------------
DROP TABLE Agent_Ofiice_Bridge_Table;
--12. create Agent_Ofiice_Bridge_Table
CREATE TABLE Agent_Ofiice_Bridge_Table AS
SELECT * FROM Agent_Office;
--------------------------------------------------------------------------------
DROP TABLE OfficeDim;
--13. create OfficeDim dimension
CREATE TABLE OfficeDim AS
SELECT * FROM Office;
--------------------------------------------------------------------------------
DROP TABLE RentalPeriodDim;
--14. create RentalPeriodDim dimension
CREATE TABLE RentalPeriodDim(
    period        VARCHAR2(50),
    period_description     VARCHAR2(50)
);
--------------------------------------------------------------------------------
DROP TABLE SeasonDim;
--15. create SeasonDim dimension
CREATE TABLE SeasonDim(
    season_id        VARCHAR2(50),
    season_description     VARCHAR2(50)
);
--------------------------------------------------------------------------------
DROP TABLE MaxBudgetRangeDim;
--16. create MaxBudgetRangeDim dimension
CREATE TABLE MaxBudgetRangeDim(
    budget_range        VARCHAR2(50),
    range_description     VARCHAR2(50)
);
--------------------------------------------------------------------------------
DROP TABLE OfficeSizeDim;
--17. create OfficeSizeDim dimension
CREATE TABLE OfficeSizeDim(
    office_size        VARCHAR2(50),
    office_size_description     VARCHAR2(50)
);
--------------------------------------------------------------------------------
DROP TABLE TimeDim;
--18. create TimeDim dimension
CREATE TABLE TimeDim AS
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
--------------------------------------------------------------------------------
DROP TABLE PropertyAdDim;
--19. create PropertyAdDim dimension 
CREATE TABLE PropertyAdDim AS
SELECT P.property_id,
1.0/COUNT(*) AS weight_factor,
listagg (PA.advert_id,'_') within GROUP (ORDER BY PA.advert_id) AS property_ad_list
FROM Property P, Property_Advert PA
WHERE P.property_id = PA.property_id
GROUP BY P.property_id;
--------------------------------------------------------------------------------
DROP TABLE Property_Ad_Bridge_Table;
--20. create Property_Ad_Bridge_Table
CREATE TABLE Property_Ad_Bridge_Table AS
SELECT property_id, advert_id FROM Property_Advert;
--------------------------------------------------------------------------------
DROP TABLE AdvertisementDim;
--21. create AdvertisementDim dimension
CREATE TABLE AdvertisementDim AS
SELECT * FROM Advertisement;
--------------------------------------------------------------------------------
DROP TABLE ClientDim;
--22. create ClientDim dimension 
CREATE TABLE ClientDim AS
SELECT C.person_id,
P.first_name || ' ' || P.last_name AS client_name,
1.0/COUNT(*) AS weight_factor,
listagg (CW.feature_code,'_') within GROUP (ORDER BY CW.feature_code) AS property_ad_list
FROM Client C, Person P, Client_Wish CW
WHERE C.person_id = P.person_id
AND CW. person_id = C.person_id
GROUP BY C.person_id, P.first_name || ' ' || P.last_name;
--------------------------------------------------------------------------------
DROP TABLE Client_Wish_Bridge_Table;
--23. create Client_Wish_Bridge_Table
CREATE TABLE Client_Wish_Bridge_Table AS
SELECT * FROM Client_Wish;

--------------------------------------------------------------------------------
-- populate dimensions created from scratch (i.e. PropertyScaleDim, PropertyFeatureCategoryDim
-- RentalPeriodDim, SeasonDim, MaxBudgetRangeDim, OfficeSizeDim )
--------------------------------------------------------------------------------
-- populate Property Scale dimension
INSERT INTO PropertyScaleDim 
VALUES ('Extra Small', 'Has one or zero bedroom');

INSERT INTO PropertyScaleDim 
VALUES ('Small', 'Has two or three bedrooms');

INSERT INTO PropertyScaleDim 
VALUES ('Medium', 'Has three to six bedrooms');

INSERT INTO PropertyScaleDim 
VALUES ('Large', 'Has six to ten bedrooms');

INSERT INTO PropertyScaleDim 
VALUES ('Extra Large', 'Has more than ten bedrooms');

-- populate Property Feature Category dimension
INSERT INTO PropertyFeatureCategoryDim 
VALUES ('Very Basic', 'Has less than ten features');

INSERT INTO PropertyFeatureCategoryDim 
VALUES ('Standard', 'Has ten to twenty features');

INSERT INTO PropertyFeatureCategoryDim 
VALUES ('Luxurious', 'Has more than twenty features');

-- populate Rental Period dimension
INSERT INTO RentalPeriodDim 
VALUES ('Short', 'Less than six months');

INSERT INTO RentalPeriodDim 
VALUES ('Medium', 'Six to twelve months');

INSERT INTO RentalPeriodDim 
VALUES ('Short', 'More than twelve months');

-- populate Season dimension
INSERT INTO SeasonDim 
VALUES ('spring', 'Sep, Oct, Nov');

INSERT INTO SeasonDim 
VALUES ('summer', 'Dec, Jan, Feb');

INSERT INTO SeasonDim 
VALUES ('autumn', 'Mar, Apr, May');

INSERT INTO SeasonDim 
VALUES ('winter', 'Jun, Jul, Aug');

-- populate Max Budget Range dimension
INSERT INTO MaxBudgetRangeDim 
VALUES ('Low', '0 to 1000');

INSERT INTO MaxBudgetRangeDim 
VALUES ('Medium', '1001 to 100000');

INSERT INTO MaxBudgetRangeDim 
VALUES ('High', '100001 to 10000000');

-- populate Office Size dimension
INSERT INTO OfficeSizeDim 
VALUES ('Small', 'Less than four employees');

INSERT INTO OfficeSizeDim 
VALUES ('Medium', 'Four to twelve employees');

INSERT INTO OfficeSizeDim 
VALUES ('Big', 'More than twelve employees');
--------------------------------------------------------------------------------
-- secondly, create a temp fact table to extract from uselog table 
--------------------------------------------------------------------------------
























































