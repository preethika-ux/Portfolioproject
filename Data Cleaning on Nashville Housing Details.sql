--selecting the data
SELECT *
FROM portfolio..Nashville

-------------------------------------------------------------------
--change to actual date format
SELECT SaleDate, CONVERT(Date, SaleDate)
FROM portfolio..Nashville

ALTER TABLE Nashville
ADD SaleDateConverted Date;

UPDATE Nashville 
SET SaleDateConverted = CONVERT(Date,SaleDate)

SELECT SaleDateConverted
FROM portfolio..Nashville

--------------------------------------------------------------------

--Populate Property Address data
SELECT [UniqueID ] , ParcelID, LandUse, PropertyAddress
FROM portfolio..Nashville
ORDER BY ParcelID

--Changing Address for the Duplicates from Null to another Copy's Address

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM portfolio..Nashville a
JOIN portfolio..Nashville b
   ON a.ParcelID = b.ParcelID
   AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a 
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM portfolio..Nashville a
JOIN portfolio..Nashville b
   ON a.ParcelID = b.ParcelID
   AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

-------------------------------------------------------------------------


-- Breaking out Address into Individual Columns (Address, City, State)


SELECT PropertyAddress
FROM portfolio..Nashville
--Where PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

FROM portfolio..Nashville


ALTER TABLE Nashville
ADD PropertySplitAddress Nvarchar(255);

Update Nashville
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE Nashville
Add PropertySplitCity Nvarchar(255);

UPDATE Nashville
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

SELECT *
FROM portfolio..Nashville


--Owner Address


SELECT OwnerAddress
FROM portfolio..Nashville


SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM portfolio..Nashville



ALTER TABLE Nashville
ADD OwnerSplitAddress Nvarchar(255);

UPDATE Nashville
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE Nashville
ADD OwnerSplitCity Nvarchar(255);

UPDATE Nashville
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE Nashville
ADD OwnerSplitState Nvarchar(255);

UPDATE Nashville
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



SELECT *
FROM portfolio..Nashville


-----------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


SELECT Distinct(SoldAsVacant), Count(SoldAsVacant)
FROM portfolio..Nashville
GROUP BY SoldAsVacant
ORDER BY 2




SELECT SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM portfolio..Nashville


UPDATE Nashville
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

FROM portfolio..Nashville
--order by ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

SELECT *
FROM portfolio..Nashville


-------------------------------------------------------------------------

-- Delete Unused Columns



Select *
From portfolio..Nashville


ALTER TABLE portfolio..Nashville
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


--------------------------------------------------------------------------
