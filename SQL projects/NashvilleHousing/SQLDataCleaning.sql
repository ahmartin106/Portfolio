/*  Cleaning NashvilleHousingData using SQL */

SELECT *
FROM NashvilleHousingData


/* Formatting SaleDate to Date format */


---Attempting to convert the SaleDate column to date format
SELECT SaleDate, CONVERT(Date, SaleDate)
FROM NashvilleHousingData

Update NashvilleHousingData
SET SaleDate = CONVERT(Date, SaleDate)

---The above didn't work strangely, so I then added a new column to the table, then converted
---This worked
ALTER TABLE NashvilleHousingData
ADD SaleDateConverted Date;

Update NashvilleHousingData
SET SaleDateConverted = CONVERT(Date, SaleDate)

SELECT SaleDate, SaleDateConverted
FROM NashvilleHousingData


/* Updating null Property addresses based on ParcelID */

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousingData a
JOIN NashvilleHousingData b 
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousingData a
JOIN NashvilleHousingData b 
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]

/* Splitting up PropertyAddress into Address, City columns */

SELECT PropertyAddress
FROM NashvilleHousingData

---Using SUBSTRING to split the address and the city
SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City
FROM NashvilleHousingData


---After confirming the above worked, altered the tables
ALTER TABLE NashvilleHousingData
ADD PropertySplitAddress Nvarchar(255);

Update NashvilleHousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousingData
ADD PropertySplitCity Nvarchar(255);

Update NashvilleHousingData
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))


/* Splitting OwnerAddress using PARSENAME into OwnerSplitAddress, 
OwnerSplitCity, OwnerSplitState */

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM NashvilleHousingData


---Altering with the first column
ALTER TABLE NashvilleHousingData
ADD OwnerSplitAddress Nvarchar(255);

Update NashvilleHousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

---Checking once again to ensure this was correct
SELECT *
FROM NashvilleHousingData


---Altering the next 2 columns
ALTER TABLE NashvilleHousingData
ADD OwnerSplitCity Nvarchar(255);

Update NashvilleHousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousingData
ADD OwnerSplitState Nvarchar(255);

Update NashvilleHousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT *
FROM NashvilleHousingData

/* Changing "Y" and "N" in SoldAsVacant column to "Yes" and "No" respectively */

---First viewing the counts of Yes, No, Y, and N
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousingData
GROUP BY SoldAsVacant
ORDER BY 2

---Writing case statement to change Y and N to Yes and No respectively
SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM NashvilleHousingData


---Updating the column with the case statement
UPDATE NashvilleHousingData
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END

---Checking to ensure the update was correctly done
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousingData
GROUP BY SoldAsVacant
ORDER BY 2


/* Removing duplicate records using a CTE based on ParcelID, Property Address, SalePrice, SaleDate, and Legal Reference */

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY  ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY 
					UniqueID
					) Row_Num
FROM NashvilleHousingData
)
DELETE
FROM RowNumCTE
WHERE Row_Num > 1


/* Deleting unused columns */

SELECT *
FROM NashvilleHousingData

ALTER TABLE NashvilleHousingData
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

