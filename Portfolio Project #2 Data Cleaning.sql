SELECT *
FROM my_database.nashville_housing;

SELECT *
FROM nashville_housing
-- WHERE PropertyAddress = '';
ORDER BY ParcelID;


-- Ran an inner join to join the table with itself to see where ParcelID equals ParcelID
-- and where UniqueID does not equal UniqueID to populate the correct PropertyAddress
-- to our blank columns

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM nashville_housing a
INNER JOIN nashville_housing b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress = '';

-- Updated table to fill in blank property address field with correct address 

UPDATE nashville_housing a
INNER JOIN nashville_housing b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = NULLIF(b.PropertyAddress, a.PropertyAddress)
WHERE a.PropertyAddress = '';
    

SELECT PropertyAddress
FROM nashville_housing;

-- used substring_index function to separate address from city

SELECT 
substring_index(PropertyAddress,',', 1) as Address,
substring_index(PropertyAddress, ',', -1) as City
FROM nashville_housing;

-- used position function to find position of where our street address is separated for all
-- addresses 

-- SELECT 
-- position(',' IN PropertyAddress) as position
-- FROM nashville_housing;


-- Alter and update table to add separate columns for address and city to make it more usable

ALTER TABLE nashville_housing
ADD property_split_address NVARCHAR(255);

UPDATE nashville_housing
SET property_split_address = substring_index(PropertyAddress,',', 1);

ALTER TABLE nashville_housing
ADD property_split_city VARCHAR(255);

UPDATE nashville_housing
SET property_split_city = substring_index(PropertyAddress, ',', -1);

SELECT *  -- ran a quick check to make sure our table was updated correctly 
FROM nashville_housing;

-- Split Owner address, city, and state for easier use

SELECT 
substring_index(OwnerAddress, ',', 1) as Address,
SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', -2), ',', 1) as City,
substring_index(OwnerAddress, ',', -1) as State
FROM nashville_housing;


-- alter and update table for OwnerAddress 

ALTER TABLE nashville_housing
ADD owner_split_address VARCHAR(255);

UPDATE nashville_housing
SET owner_split_address = substring_index(OwnerAddress, ',', 1);

ALTER TABLE nashville_housing
ADD owner_split_city VARCHAR(255);

UPDATE nashville_housing
SET owner_split_city = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', -2), ',', 1);

ALTER TABLE nashville_housing
ADD owner_split_state VARCHAR(255);

UPDATE nashville_housing
SET owner_split_state = substring_index(OwnerAddress, ',', -1);


-- Looking to see how many options we have for saying yes or no within the SoldAsVacant column

SELECT distinct SoldAsVacant, COUNT(SoldAsVacant)
FROM nashville_housing
GROUP BY SoldAsVacant
ORDER BY COUNT(SoldAsVacant);

-- Changing answer from Y or N to yes or no for cleaner data 

SELECT SoldAsVacant,
	CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
		END
FROM nashville_housing;

-- updating SoldAsVacant column to show only yes or no answers in column

UPDATE nashville_housing
SET SoldAsVacant = CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
		END;


-- remove duplicates

CREATE TABLE nashville_houisng_copy LIKE nashville_housing;

INSERT INTO my_database.nashville_houisng_copy
	SELECT DISTINCT *
    FROM nashville_housing;

DROP TABLE my_database.nashville_housing;

RENAME TABLE my_database.nashville_houisng_copy TO nashville_housing;

-- Delete unused columns 

SELECT * 
FROM nashville_housing; 


ALTER TABLE nashville_housing
DROP COLUMN OwnerAddress,
DROP COLUMN TaxDistrict, 
DROP COLUMN PropertyAddress;




    

