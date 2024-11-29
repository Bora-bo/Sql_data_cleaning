SELECT *
FROM Nashville_housing..housing_data;

--#comment1: reformatting saleDate column
SELECT 
	--saledate, 
	SalesDateConverted
FROM 
	Nashville_housing..housing_data;


--#comment2: adding a new column for sales date
ALTER TABLE 
	Nashville_housing..housing_data
ADD 
	SalesDateConverted DATE;

UPDATE Nashville_housing..housing_data
SET SalesDateConverted = CONVERT(DATE,SaleDate);


--comment3:handling NULL address values
SELECT 
	table1.ParcelID t1_parcelID,
	table2.ParcelID t2_parcelID,
	table1.PropertyAddress,
	table2.PropertyAddress,
	ISNULL(table2.PropertyAddress, table1.PropertyAddress) Fill_in_address
FROM
	Nashville_housing..housing_data table1
JOIN 
	Nashville_housing..housing_data table2
ON	
	table1.ParcelID = table2.ParcelID
	AND	table1.[UniqueID ] <> table2.[UniqueID ]
WHERE table2.PropertyAddress IS NULL;


UPDATE table2
SET PropertyAddress = ISNULL(table2.PropertyAddress, table1.PropertyAddress)
FROM
	Nashville_housing..housing_data table1
JOIN 
	Nashville_housing..housing_data table2
ON	
	table1.ParcelID = table2.ParcelID
	AND	table1.[UniqueID ] <> table2.[UniqueID ]
WHERE table2.PropertyAddress IS NULL;


--#comment4: breaking the properyAddress into single values
SELECT 
	house.PropertyAddress,
	SUBSTRING(house.PropertyAddress, 1, CHARINDEX(',', house.PropertyAddress) -1) Address,
	SUBSTRING(house.PropertyAddress, CHARINDEX(',', house.PropertyAddress) +1, LEN(house.PropertyAddress)) City
FROM Nashville_housing..housing_data house;


--#comment5:Adding 2 new columns for address and city
ALTER TABLE Nashville_housing..housing_data
ADD Property_Address_Unit VARCHAR(400);

ALTER TABLE Nashville_housing..housing_data
ADD Property_City VARCHAR(150);

UPDATE 
	Nashville_housing..housing_data
SET 
	Property_Address_Unit = SUBSTRING(house.PropertyAddress, 1, CHARINDEX(',', house.PropertyAddress) -1)
FROM 
	Nashville_housing..housing_data house;

UPDATE 
	Nashville_housing..housing_data
SET 
	Property_City = SUBSTRING(house.PropertyAddress, CHARINDEX(',', house.PropertyAddress) +1, LEN(house.PropertyAddress))
FROM 
	Nashville_housing..housing_data house;


--#comment6: seprating out OwnerAddress field into single units
SELECT 
	--house.OwnerAddress,
	PARSENAME(REPLACE(house.OwnerAddress, ',', '.'), 3),
	PARSENAME(REPLACE(house.OwnerAddress, ',', '.'), 2),
	PARSENAME(REPLACE(house.OwnerAddress, ',', '.'), 1)
FROM Nashville_housing..housing_data house;



ALTER TABLE 
	Nashville_housing..housing_data
ADD 
	Owner_Address VARCHAR(300);


ALTER TABLE 
	Nashville_housing..housing_data
ADD 
	Owner_City VARCHAR(150);


ALTER TABLE Nashville_housing..housing_data
ADD Owner_State VARCHAR(20);

UPDATE Nashville_housing..housing_data
SET Owner_Address = PARSENAME(REPLACE(house.OwnerAddress, ',', '.'), 3)
FROM 
	Nashville_housing..housing_data house;

UPDATE Nashville_housing..housing_data
SET Owner_City = PARSENAME(REPLACE(house.OwnerAddress, ',', '.'), 2)
FROM 
	Nashville_housing..housing_data house;

UPDATE Nashville_housing..housing_data
SET Owner_State = PARSENAME(REPLACE(house.OwnerAddress, ',', '.'), 1)
FROM 
	Nashville_housing..housing_data house;


--#comment7: Aligning the 'N' and 'Y' values in SoldAsVacant with 'No' and 'Yes'
SELECT 
	DISTINCT(house.SoldAsVacant), 
	COUNT(house.SoldAsVacant) 
FROM Nashville_housing..housing_data house
GROUP BY house.SoldAsVacant
ORDER BY 2;

SELECT
	CASE
		WHEN house.SoldAsVacant = 'N' THEN 'No'
		WHEN house.SoldAsVacant = 'Yes' THEN 'Yes'
		ELSE house.SoldAsVacant
	END
FROM Nashville_housing..housing_data house;


UPDATE Nashville_housing..housing_data
SET SoldAsVacant = CASE
						WHEN SoldAsVacant = 'N' THEN 'No'
						WHEN SoldAsVacant = 'Y' THEN 'Yes'
						ELSE SoldAsVacant
					END;


--#comment8: Searching for duplicates
WITH duplicate_data AS(
SELECT *,
	ROW_NUMBER()
	OVER(
	PARTITION BY
		ParcelID,
		PropertyAddress,
		SaleDate,
		SalePrice,
		LegalReference,
		OwnerName,
		OwnerAddress
	ORDER BY 
		ParcelID
	) row_num
	
FROM Nashville_housing..housing_data house
) 
SELECT * 
FROM duplicate_data
WHERE row_num > 1
ORDER BY ParcelID;


--#comment9: removing extraneous columns
ALTER TABLE Nashville_housing..housing_data 
DROP COLUMN PropertyAddress, SaleDate, OwnerAddress, TaxDistrict;

SELECT *
FROM Nashville_housing..housing_data;
