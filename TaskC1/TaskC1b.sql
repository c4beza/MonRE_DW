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
SELECT Street, COUNT(*) 
FROM ADDRESS
GROUP BY Street
HAVING COUNT(*) > 1;
