-- Cleaning data from Nashville housing dataset

-- Change date format to (year-mon-date)

ALTER TABLE NashvilleHousing
ALTER COLUMN SaleDate Date;


-- Replace NULL property addresses with the address of other entries with the same parcel ID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject1..NashvilleHousing AS a
JOIN PortfolioProject1..NashvilleHousing AS b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID != b.UniqueID
WHERE a.PropertyAddress is NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject1..NashvilleHousing AS a
JOIN PortfolioProject1..NashvilleHousing AS b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID != b.UniqueID
WHERE a.PropertyAddress is NULL


-- Split property address into 2 new columns (address, city)

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);
ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)
UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))


-- Split owner address into 3 new columns (address, city, state)

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(250);
ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(250);
ALTER TABLE NashvilleHousing
ADD OwnerSplitState NvarChar(250);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


-- Change Y and N to 'Yes' and 'No' in the SoldAsVacant column

SELECT SoldAsVacant,
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END
FROM PortfolioProject1..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant =
	CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END


-- Remove Duplicates

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference 
	ORDER BY UniqueID
	) AS row_num
FROM PortfolioProject1..NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1


-- Delete Unused Columns

SELECT * 
FROM PortfolioProject1..NashvilleHousing

ALTER TABLE PortfolioProject1.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

-- Finished product

SELECT TOP 5 *
FROM PortfolioProject1..NashvilleHousing

-- Inspiration taken from Alex the Analyst