--CLEANING DATA IN SQL

SELECT *
  FROM dbo.NashvilleHousing;

----------------------------------------------------------------------------------	
--Standardize the Date Format

ALTER TABLE NashvilleHousing
  ADD SaleDateConverted DATE;

UPDATE NashvilleHousing
  SET SaleDateConverted = CONVERT(Date,SaleDate);

 SELECT SaleDateConverted, CONVERT(Date,SaleDate)
  FROM dbo.NashvilleHousing;

---------------------------------------------------------------------------------
--Populate Property Address Data

 SELECT *, PropertyAddress
   FROM dbo.NashvilleHousing
  WHERE PropertyAddress IS NULL
  ORDER BY ParcelID;

  --1.
  SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
    FROM NashvilleHousing AS a	
	JOIN NashvilleHousing AS b
	  ON a.ParcelID = b.ParcelID AND a.[UniqueID ]<> b.[UniqueID ]
   WHERE a.PropertyAddress IS NULL;

   --2.
  SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) AS UpdatedPropertyAddress
    FROM NashvilleHousing AS a	
	JOIN NashvilleHousing AS b
	  ON a.ParcelID = b.ParcelID AND a.[UniqueID ]<> b.[UniqueID ]
   WHERE a.PropertyAddress IS NULL;

   --3.
   UPDATE a
     SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
	   FROM NashvilleHousing AS a	
	   JOIN NashvilleHousing AS b
	     ON a.ParcelID = b.ParcelID AND a.[UniqueID ]<> b.[UniqueID ]
	  WHERE a.PropertyAddress IS NULL;

----------------------------------------------------------------------------------
--Breaking out Address into Individual Columns

 SELECT PropertyAddress
   FROM dbo.NashvilleHousing;

  --1.
SELECT PropertyAddress,
       SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)- 1) AS Address,
       SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+ 1, LEN(PropertyAddress)) AS Address
  FROM dbo.NashvilleHousing;

  --2.
ALTER TABLE NashvilleHousing
  ADD PropertySplitAddress NVARCHAR(255);

  UPDATE NashvilleHousing
  SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)- 1);

ALTER TABLE NashvilleHousing
  ADD PropertySplitCity NVARCHAR(255);

  UPDATE NashvilleHousing
  SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+ 1, LEN(PropertyAddress));

 SELECT *
   FROM dbo.NashvilleHousing;

  --3.
SELECT *, OwnerAddress
  FROM dbo.NashvilleHousing;

SELECT
  PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
  PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
  PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
  FROM dbo.NashvilleHousing;

ALTER TABLE NashvilleHousing
  ADD OwnerSplitAddress NVARCHAR(255);

  UPDATE NashvilleHousing
  SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

ALTER TABLE NashvilleHousing
  ADD OwnerSplitCity NVARCHAR(255);

  UPDATE NashvilleHousing
  SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

ALTER TABLE NashvilleHousing
  ADD OwnerSplitState NVARCHAR(255);

  UPDATE NashvilleHousing
  SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)


--------------------------------------------------------------------------------------
--Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
  FROM dbo.NashvilleHousing
  GROUP BY SoldAsVacant
  ORDER BY 2;

  --1.
  SELECT SoldAsVacant,
    CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
         WHEN SoldASVacant = 'N' THEN 'No'
	     ELSE SoldAsVacant
	     END
    FROM dbo.NashvilleHousing;

 --2.
UPDATE dbo.NashvilleHousing
  SET SoldAsVacant = 
      CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldASVacant = 'N' THEN 'No'
	    ELSE SoldAsVacant
	    END


 --------------------------------------------------------------------------------------
 --Remove Duplicates

 --1.
WITH RowNumCTE AS(
SELECT *,
  ROW_NUMBER() OVER(
  PARTITION BY ParcelID,
               PropertyAddress,
			   SalePrice,
			   SaleDate,
			   LegalReference
			   ORDER BY
			     UniqueID) row_num
  FROM dbo.NashvilleHousing
  --ORDER BY ParcelID
)

 --2.
DELETE 
  FROM RowNumCTE
  WHERE row_num > 1
  --ORDER BY PropertyAddress;


  ---------------------------------------------------------------------------------------
  --Delete Unused Columns

  ALTER TABLE dbo.NashvilleHousing
    DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress;

  SELECT *
    FROM dbo.NashvilleHousing;

  ALTER TABLE dbo.NashvilleHousing
    DROP COLUMN SaleDate;

