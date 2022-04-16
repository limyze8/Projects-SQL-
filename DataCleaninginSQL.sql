-- Cleaning Data in SQL Queries

SELECT SaleDate
FROM DataCleaningInSQL..NashvilleHousing



-- Standardise Date Fromat
SELECT SaleDate, CONVERT(Date,SaleDate)
FROM DataCleaningInSQL..NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)



-- Populate property address data (ParcelID correlates with PropertyAddress)
SELECT *
FROM DataCleaningInSQL..NashvilleHousing
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM DataCleaningInSQL..NashvilleHousing a
JOIN DataCleaningInSQL..NashvilleHousing b
     ON a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM DataCleaningInSQL..NashvilleHousing a
JOIN DataCleaningInSQL..NashvilleHousing b
     ON a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null



-- Breaking out address into individual columns by Address, City, State

SELECT PropertyAddress
FROM DataCleaningInSQL..NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address
FROM DataCleaningInSQL..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress VARCHAR(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity VARCHAR(255)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


SELECT *
FROM DataCleaningInSQL..NashvilleHousing




-- Breaking Owner Address 
SELECT OwnerAddress
FROM DataCleaningInSQL..NashvilleHousing

SELECT
--PARSENAME is only useful for '.', hence replacing ','
PARSENAME(REPLACE(OwnerAddress,',','.'), 3)
, PARSENAME(REPLACE(OwnerAddress,',','.'), 2)
, PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
FROM DataCleaningInSQL..NashvilleHousing



ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress VARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity VARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState VARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)


SELECT *
FROM DataCleaningInSQL..NashvilleHousing



-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), Count(SoldAsVacant)
FROM DataCleaningInSQL..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


Select SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM DataCleaningInSQL..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
                        WHEN SoldAsVacant = 'N' THEN 'No'
	                    ELSE SoldAsVacant
	                    END



-- Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
             PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 ORDER BY UniqueID) row_num
FROM DataCleaningInSQL..NashvilleHousing
)

-- Delete duplicates
DELETE
FROM RowNumCTE
WHERE row_num > 1



-- Delete unused columns
SELECT *
FROM DataCleaningInSQL..NashvilleHousing

ALTER TABLE DataCleaningInSQL..NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress
