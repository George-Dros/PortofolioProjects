
--Standardize Date Format



SELECT *
FROM PortofolioProject..NashvilleHousing

SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM PortofolioProject..NashvilleHousing

UPDATE PortofolioProject..NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE PortofolioProject..NashvilleHousing
ADD SaleDateConverted Date;

UPDATE PortofolioProject..NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


-- Populate Property Address Data


SELECT *
FROM PortofolioProject..NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID,  a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortofolioProject..NashvilleHousing a
JOIN PortofolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


UPDATE a 
SET PropertyAddress =  ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortofolioProject..NashvilleHousing a
JOIN PortofolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


-- Breaking Address into Individual Columns


SELECT PropertyAddress
FROM PortofolioProject..NashvilleHousing
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) AS City

FROM PortofolioProject..NashvilleHousing

ALTER TABLE PortofolioProject..NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

UPDATE PortofolioProject..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE PortofolioProject..NashvilleHousing
ADD PropertySplitCity nvarchar(255);

UPDATE PortofolioProject..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))

SELECT * 
FROM PortofolioProject..NashvilleHousing

SELECT OwnerAddress
FROM PortofolioProject..NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress,',' , '.'), 3)
,PARSENAME(REPLACE(OwnerAddress,',' , '.'), 2)
,PARSENAME(REPLACE(OwnerAddress,',' , '.'), 1)
FROM PortofolioProject..NashvilleHousing

ALTER TABLE PortofolioProject..NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);

UPDATE PortofolioProject..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',' , '.'), 3)

ALTER TABLE PortofolioProject..NashvilleHousing
ADD OwnerSplitCity nvarchar(255);

UPDATE PortofolioProject..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',' , '.'), 2)

ALTER TABLE PortofolioProject..NashvilleHousing
ADD OwnerSplitState nvarchar(255);

UPDATE PortofolioProject..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',' , '.'), 1)


-- Change Y and N to Yes and No in "Sold as Vacant Field"


SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From PortofolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM PortofolioProject..NashvilleHousing

UPDATE PortofolioProject..NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END



-- Remove Duplicates

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY 
					UniqueID
					) AS row_num

FROM PortofolioProject..NashvilleHousing
--ORDER BY ParcelID
)

SELECT *
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress


-- Delete Unused Columns


SELECT *
FROM PortofolioProject..NashvilleHousing

ALTER TABLE PortofolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortofolioProject..NashvilleHousing
DROP COLUMN SaleDate
