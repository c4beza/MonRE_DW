-- Exploring and cleaning the data
--------------------------------------------------------------------------------
-- Exploring the data
--------------------------------------------------------------------------------
SELECT * FROM MonRE.Address; 
SELECT * FROM MonRE.Advertisement; 
SELECT * FROM MonRE.Agent; 
SELECT * FROM MonRE.Agent_Office; 
SELECT * FROM MonRE.Client; 
SELECT * FROM MonRE.Client_Wish; 
SELECT * FROM MonRE.Feature; 
SELECT * FROM MonRE.Office; 
SELECT * FROM MonRE.Person; 
SELECT * FROM MonRE.Postcode; 
SELECT * FROM MonRE.Property; 
SELECT * FROM MonRE.Property_Advert; 
SELECT * FROM MonRE.Property_Feature;
SELECT * FROM MonRE.Rent;
SELECT * FROM MonRE.Sale;
SELECT * FROM MonRE.State;
SELECT * FROM MonRE.Visit;

SELECT count(*) FROM MonRE.Address; 
SELECT count(*) FROM MonRE.Advertisement; 
SELECT count(*) FROM MonRE.Agent; 
SELECT count(*) FROM MonRE.Agent_Office; 
SELECT count(*) FROM MonRE.Client; 
SELECT count(*) FROM MonRE.Client_Wish; 
SELECT count(*) FROM MonRE.Feature; 
SELECT count(*) FROM MonRE.Office; 
SELECT count(*) FROM MonRE.Person; 
SELECT count(*) FROM MonRE.Postcode; 
SELECT count(*) FROM MonRE.Property; 
SELECT count(*) FROM MonRE.Property_Advert; 
SELECT count(*) FROM MonRE.Property_Feature; 
SELECT count(*) FROM MonRE.Rent; 
SELECT count(*) FROM MonRE.Sale; 
SELECT count(*) FROM MonRE.State; 
SELECT count(*) FROM MonRE.Visit; 

--------------------------------------------------------------------------------
-- Finding the errors:
--------------------------------------------------------------------------------
--(ERROR) check if there are duplicate records in MonRE.Address 
SELECT street, suburb, postcode, COUNT(*) AS duplicate_address_records
FROM MonRE.Address
GROUP BY street, suburb, postcode
HAVING COUNT(*) > 1;

-- check if there are null and illegal values in MonRE.Address
SELECT * 
FROM MonRE.Address
WHERE address_id IS NULL
OR street IS NULL
OR suburb IS NULL
OR postcode IS NULL
OR postcode <= 0
OR address_id <= 0;

-- check if there are records in MonRE.Address not in MonRE.Postcode
SELECT * FROM MonRE.Address
WHERE postcode NOT IN (SELECT postcode from MonRE.Postcode);

-- check if there are duplicate records in MonRE.Advertisement
SELECT advert_name, COUNT(*) AS duplicate_advertisement_records
FROM MonRE.Advertisement
GROUP BY advert_name
HAVING COUNT(*) > 1;

-- check if there are null and illegal values in MonRE.Advertisement
SELECT * 
FROM MonRE.Advertisement
WHERE advert_id IS NULL
OR advert_name IS NULL
OR advert_id <= 0;

--(ERROR) check if there are null and illegal values in MonRE.Agent 
SELECT * 
FROM MonRE.Agent
WHERE person_id IS NULL
OR salary IS NULL
OR person_id <= 0
OR salary <= 0;

-- check if there are records in MonRE.Agent not in MonRE.Person 
SELECT * FROM MonRE.Agent
WHERE person_id NOT IN (SELECT person_id from MonRE.Person);

-- check if there are records in MonRE.Agent_Office not in MonRE.Person and MonRE.Office 
SELECT * FROM MonRE.Agent_Office
WHERE person_id NOT IN (SELECT person_id from MonRE.Person)
OR office_id NOT IN (SELECT office_id from MonRE.Office);

-- (ERROR)check if there are null and illegal values in MonRE.Client
SELECT * 
FROM MonRE.Client
WHERE person_id IS NULL
OR min_budget IS NULL
OR max_budget IS NULL
OR person_id <= 0
OR min_budget <= 0
OR max_budget <= 0
OR min_budget >= max_budget;

-- check if there are illegal values in MonRE.Client_Wish
SELECT * 
FROM MonRE.Client_Wish
WHERE feature_code <= 0
OR person_id <= 0;

-- check if there are records in MonRE.Client_Wish not in MonRE.Feature and MonRE.Person
SELECT * FROM MonRE.Client_Wish
WHERE feature_code NOT IN (SELECT feature_code from MonRE.Feature)
OR person_id NOT IN (SELECT person_id from MonRE.Person);

-- check if there are null and illegal values in MonRE.Feature
SELECT * 
FROM MonRE.Feature
WHERE feature_code IS NULL
OR feature_code <= 0;

-- check if there are duplicate records in MonRE.Feature
SELECT feature_description, COUNT(*) 
FROM MonRE.Feature
GROUP BY feature_description
HAVING COUNT(*) > 1;

-- check if there are duplicate records in MonRE.Office
SELECT office_id, COUNT(*) 
FROM MonRE.Office
GROUP BY office_id
HAVING COUNT(*) > 1;

-- check if there are illegal and null values in MonRE.Office
SELECT * 
FROM MonRE.Office
WHERE office_id IS NULL
OR office_id <= 0;

-- (ERROR)check if there are duplicate records in MonRE.Person
SELECT person_id, COUNT(*) 
FROM MonRE.Person
GROUP BY person_id
HAVING COUNT(*) > 1;

-- check if there are illegal and null values in MonRE.Person
SELECT * 
FROM MonRE.Person
WHERE person_id IS NULL
OR address_id IS NULL
OR person_id <= 0
OR address_id <= 0;

-- (ERROR)check if there are records in MonRE.Person not in MonRE.Address
SELECT * FROM MonRE.Person
WHERE address_id NOT IN (SELECT address_id from MonRE.Address);

-- check if there are illegal and null values in MonRE.Postcode
SELECT * 
FROM MonRE.Postcode
WHERE postcode IS NULL
OR postcode <= 0;

-- check if there are records in MonRE.Postcode not in MonRE.State
SELECT * FROM MonRE.Postcode
WHERE state_code NOT IN (SELECT state_code from MonRE.State);

-- check if there are duplicate records in MonRE.Postcode
SELECT postcode, COUNT(*) 
FROM MonRE.Postcode
GROUP BY postcode
HAVING COUNT(*) > 1;

-- (ERROR)check if there are illegal and null values in MonRE.Property
SELECT * 
FROM MonRE.Property
WHERE property_id IS NULL
OR property_date_added IS NULL
OR property_type IS NULL
OR property_no_of_bedrooms IS NULL
OR property_no_of_bathrooms IS NULL
OR property_no_of_garages IS NULL
OR property_size IS NULL
OR property_description IS NULL
OR property_id <= 0
OR property_no_of_bedrooms < 0
OR property_no_of_bathrooms < 0
OR property_no_of_garages < 0
OR property_size < 0;

-- (ERROR)check if there are duplicate records in MonRE.Property
SELECT property_id, COUNT(*) 
FROM MonRE.Property
GROUP BY property_id
HAVING COUNT(*) > 1;

-- check if there are records in MonRE.Property not in MonRE.Address
SELECT * FROM MonRE.Property
WHERE address_id NOT IN (SELECT address_id from MonRE.Address);

-- check if there are illegal and null values in MonRE.Property_Advert
SELECT * 
FROM MonRE.Property_Advert
WHERE cost IS NULL
OR cost <= 0;

-- check if there are records in MonRE.Property_Advert not in MonRE.Address, MonRE.Advertisement, and MonRE.Agent
SELECT * FROM MonRE.Property_Advert
WHERE property_id NOT IN (SELECT property_id from MonRE.Property)
OR advert_id NOT IN (SELECT advert_id from MonRE.Advertisement)
OR agent_person_Id NOT IN (SELECT person_id from MonRE.Agent);

-- check if there are illegal and null values in MonRE.Property_Feature
SELECT * 
FROM MonRE.Property_Feature
WHERE property_id <= 0
OR feature_code <= 0;

-- check if there are records in MonRE.Property_Feature not in MonRE.Address and MonRE.Feature
SELECT * FROM MonRE.Property_Feature
WHERE property_id NOT IN (SELECT property_id from MonRE.Property)
OR feature_code NOT IN (SELECT feature_code from MonRE.Feature);

-- check if there are duplicate records in MonRE.Rent
SELECT property_id, rent_start_date, rent_end_date, COUNT(*) 
FROM MonRE.Rent
GROUP BY property_id, rent_start_date, rent_end_date
HAVING COUNT(*) > 1;

-- (ERROR)check if there are illegal and null values in MonRE.Rent
SELECT * 
FROM MonRE.Rent
WHERE rent_id IS NULL
OR client_person_id IS NULL
OR rent_start_date IS NULL
OR rent_end_date IS NULL
OR price IS NULL
OR rent_id <= 0
OR price <= 0;

-- check if there are records in MonRE.Rent not in MonRE.Person and MonRE.Property
SELECT * FROM MonRE.Rent
WHERE agent_person_Id NOT IN (SELECT person_id from MonRE.Person)
OR client_person_id NOT IN (SELECT person_id from MonRE.Person)
OR property_id NOT IN (SELECT property_id from MonRE.Property);

-- check if there are duplicate records in MonRE.Sale
SELECT sale_date, property_id, COUNT(*) 
FROM MonRE.Sale
GROUP BY sale_date, property_id
HAVING COUNT(*) > 1;

-- (ERROR)check if there are illegal and null values in MonRE.Sale
SELECT * 
FROM MonRE.Sale
WHERE sale_id IS NULL
OR client_person_id IS NULL
OR sale_date IS NULL
OR price IS NULL
OR sale_id <=0
OR agent_person_Id <= 0
OR client_person_id <= 0
OR property_id <= 0
OR price <= 0;

-- check if there are records in MonRE.Sale not in MonRE.Person and MonRE.Property
SELECT * FROM MonRE.Sale
WHERE agent_person_Id NOT IN (SELECT person_id from MonRE.Person)
OR client_person_id NOT IN (SELECT person_id from MonRE.Person)
OR property_id NOT IN (SELECT property_id from MonRE.Property);

-- (ERROR)check if there are illegal and null values in MonRE.State
SELECT * 
FROM MonRE.State
WHERE state_code IS NULL
OR state_name IS NULL;

-- check if there are illegal and null values in MonRE.Visit
SELECT * 
FROM MonRE.Visit
WHERE client_person_id <= 0 
OR agent_person_Id <= 0
OR property_id <= 0
OR duration IS NULL;

-- check if there are records in MonRE.Visit not in MonRE.Person and MonRE.Property
SELECT * FROM MonRE.Sale
WHERE agent_person_Id NOT IN (SELECT person_id from MonRE.Person)
OR client_person_id NOT IN (SELECT person_id from MonRE.Person)
OR property_id NOT IN (SELECT property_id from MonRE.Property);
--------------------------------------------------------------------------------
-- Cleaning the data
--------------------------------------------------------------------------------
-- Error 1: Duplicate record in ADDRESS table 
--(39 out of 13204 records were redundant)
--------------------------------------------------------------------------------
-- Detection Strategy:
SELECT SUM(duplicate_address_records)
FROM(
SELECT street, suburb, postcode, COUNT(*) AS duplicate_address_records
FROM MonRE.Address
GROUP BY street, suburb, postcode
HAVING COUNT(*) > 1);

SELECT COUNT(*) 
FROM (SELECT street, suburb, postcode, COUNT(*) AS duplicate_address_records
FROM MonRE.Address
GROUP BY street, suburb, postcode
HAVING COUNT(*) > 1);

SELECT COUNT(*) FROM MonRE.Address; 

-- Solution:
select count(*) from 
(select max(address_id) address_id, street, suburb, postcode from MonRE.Address group by street, suburb, postcode);

-- Error 2: Dirty record in Agent table 
--(There are 0 and negative values in MonRE.Agent)
--------------------------------------------------------------------------------
-- Detection Strategy:
SELECT COUNT(*) FROM MonRE.Agent;

SELECT COUNT(*) FROM(
SELECT * 
FROM MonRE.Agent
WHERE person_id IS NULL
OR salary IS NULL
OR person_id <= 0
OR salary <= 0);

-- Solution:
SELECT COUNT(*) FROM(
SELECT * 
FROM MonRE.Agent
WHERE salary > 0);

-- Error 3: Dirty record in Client table 
--(There is negative value in MonRE.Client and there are 
--maximum budget that are smaller than minimum budget)
--------------------------------------------------------------------------------
-- Detection Strategy:
SELECT COUNT(*) FROM MonRE.Client;

SELECT COUNT(*) FROM(
SELECT * 
FROM MonRE.Client
WHERE person_id IS NULL
OR min_budget IS NULL
OR max_budget IS NULL
OR person_id <= 0
OR min_budget <= 0
OR max_budget <= 0
OR max_budget <= min_budget);

-- Solution:
SELECT COUNT(*) FROM ( 
SELECT * 
FROM MonRE.Client
WHERE max_budget > 0 
AND max_budget > min_budget);

-- Error 4: Dirty record in Person table 
--(There are 4 duplicate values in MonRE.Person, we will just keep 1 record in the database)
--------------------------------------------------------------------------------
-- Detection Strategy:
SELECT COUNT(*) FROM MonRE.Person;

SELECT SUM(duplicate_person_record) FROM(
SELECT person_id, COUNT(*) AS duplicate_person_record
FROM MonRE.Person
GROUP BY person_id
HAVING COUNT(*) > 1);

-- Solution:
SELECT COUNT(*) FROM ( 
SELECT DISTINCT person_id, title, first_name, last_name, gender, address_id, phone_no, email
FROM MonRE.Person);

-- Error 5: Dirty record in Person table 
--(There is one person with no title, no name, no email, and meaningless phone number in Person table)
--------------------------------------------------------------------------------
-- Detection Strategy:
SELECT COUNT(*) FROM MonRE.Person;

SELECT COUNT(*) FROM(
SELECT * FROM MonRE.Person
WHERE address_id NOT IN (SELECT address_id from MonRE.Address));

-- Solution:
SELECT COUNT(*) FROM ( 
SELECT * FROM MonRE.Person
WHERE address_id IN (SELECT address_id from MonRE.Address));

-- Error 6: Dirty record in Property table 
--(There is 4403 records with no property size value in Property table, we will simply set it to 0 showing that it is not availabe)
--------------------------------------------------------------------------------
-- Detection Strategy:
SELECT COUNT(*) FROM MonRE.Property;

SELECT COUNT(*)
FROM(SELECT * 
FROM MonRE.Property
WHERE property_size IS NULL
);

-- Solution:
SELECT COUNT(*) FROM ( 
SELECT property_id, property_date_added, address_id, property_type, 
property_no_of_bedrooms, property_no_of_bathrooms, property_no_of_garages, NVL(property_size, 0),
property_description FROM MonRE.Property);

-- Error 7: Dirty record in Property table 
--(There are 20 redundant records in Property table, we will keep it distinct in the database)
--------------------------------------------------------------------------------
-- Detection Strategy:
SELECT COUNT(*) FROM MonRE.Property;

SELECT SUM (duplicate_property_record)
FROM(SELECT property_id, COUNT(*) AS duplicate_property_record
FROM MonRE.Property
GROUP BY property_id
HAVING COUNT(*) > 1
);

-- Solution:
SELECT COUNT(*) FROM ( 
SELECT DISTINCT property_id, property_date_added, address_id, property_type, 
property_no_of_bedrooms, property_no_of_bathrooms, property_no_of_garages, NVL(property_size, 0),
property_description FROM MonRE.Property);

-- Error 8: Dirty record in Rent table 
--(There are 1637 records without client_person_id, rent_start_date, and rent_end_date in Rent 
-- table. In terms of integrity, we will delete it from the database)
--------------------------------------------------------------------------------
-- Detection Strategy:
SELECT COUNT(*) FROM MonRE.Rent;

SELECT COUNT(*)
FROM(
SELECT * 
FROM MonRE.Rent
WHERE client_person_id IS NULL
OR rent_start_date IS NULL
OR rent_end_date IS NULL
);

-- Solution:
SELECT COUNT(*) FROM ( 
SELECT * 
FROM MonRE.Rent
WHERE client_person_id IS NOT NULL
AND rent_start_date IS NOT NULL
AND rent_end_date IS NOT NULL);

-- Error 9: Dirty record in Sale table 
--(There are 2009 records without client_person_id, sale_date in Sale 
-- table. In terms of integrity, we will delete it from the database)
--------------------------------------------------------------------------------
-- Detection Strategy:
SELECT COUNT(*) FROM MonRE.Sale;

SELECT COUNT(*)
FROM(
SELECT * 
FROM MonRE.Sale
WHERE client_person_id IS NULL
OR sale_date IS NULL
);

-- Solution:
SELECT COUNT(*) FROM ( 
SELECT * 
FROM MonRE.Sale
WHERE client_person_id IS NOT NULL
AND sale_date IS NOT NULL);

-- Error 10: Dirty record in State table 
--(There is 1 record without state_code in State 
-- table. In terms of integrity, we will delete it from the database)
--------------------------------------------------------------------------------
-- Detection Strategy:
SELECT COUNT(*) FROM MonRE.State;

SELECT COUNT(*)
FROM(
SELECT * 
FROM MonRE.State
WHERE state_code IS NULL
OR state_name IS NULL
);

-- Solution:
SELECT COUNT(*) FROM ( 
SELECT * 
FROM MonRE.State
WHERE state_code IS NOT NULL
AND state_name IS NOT NULL);


