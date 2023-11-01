/*
Data cleaning with SQL Queries
*/

Select *
From PortfolioProject..NashvilleHousingData

-- Standardize Date Format
Select SaleDateConverted, CONVERT(DATE, SaleDate)
From PortfolioProject..NashvilleHousingData

--UPDATE NashvilleHousingData
--SET SaleDate = CONVERT(DATE, SaleDate)

--Select SaleDate
--From PortfolioProject..NashvilleHousingData

ALTER TABLE NashvilleHousingData
Add SaleDateConverted Date

UPDATE NashvilleHousingData
SET SaleDateConverted = CONVERT(DATE, SaleDate)

-- Populate the property address data

Select *
From PortfolioProject..NashvilleHousingData
--Where propertyAddress is null
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousingData a
JOIN PortfolioProject..NashvilleHousingData b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
	Where a.PropertyAddress is null OR b.PropertyAddress is null

	UPDATE a
	SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousingData a
JOIN PortfolioProject..NashvilleHousingData b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
	Where a.PropertyAddress is null


-- Breaking out Address into individual columns(Address, City, State)

Select PropertyAddress
From PortfolioProject..NashvilleHousingData
--Where propertyAddress is null
--order by ParcelID

Select SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1, len(PropertyAddress)) as Address
From PortfolioProject..NashvilleHousingData

ALTER TABLE NashvilleHousingData
Add PropertySplitAddress Nvarchar(255)

UPDATE NashvilleHousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)

ALTER TABLE NashvilleHousingData
Add PropertySplitCity Nvarchar(255)

UPDATE NashvilleHousingData
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1, len(PropertyAddress))


Select OwnerAddress
From PortfolioProject..NashvilleHousingData

Select PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From PortfolioProject..NashvilleHousingData


ALTER TABLE NashvilleHousingData
Add OwnerSplitAddress Nvarchar(255)

UPDATE NashvilleHousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousingData
Add OwnerSplitCity Nvarchar(255)

UPDATE NashvilleHousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousingData
Add OwnerSplitState Nvarchar(255)

UPDATE NashvilleHousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

Select Distinct(SoldAsVacant), Count(*)
From PortfolioProject..NashvilleHousingData
Group by SoldAsVacant
Order by 2


Select SoldAsVacant,
CASE when SoldAsVacant = 'Y' THEN 'Yes'
	when SoldAsVacant ='N' THEN 'No'
	ELSE SoldAsVacant 
	End
From PortfolioProject..NashvilleHousingData

UPDATE NashvilleHousingData
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'Yes'
	when SoldAsVacant ='N' THEN 'No'
	ELSE SoldAsVacant 
	End
From PortfolioProject..NashvilleHousingData


-- Remove Duplicates

WIth RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	Partition By ParcelID,
				PropertyAddress,
				SalePrice,
				LegalReference
	            Order By
				UniqueID ) row_num
From PortfolioProject..NashvilleHousingData
--Order By ParcelID
)

	Select *
	From RowNumCTE
	Where row_num>1
	Order By PropertyAddress

	-- Delete Unused Columns
Select *
From PortfolioProject..NashvilleHousingData

ALTER TABLE NashvilleHousingData
DROP COLUMN PropertyAddress,OwnerAddress,TaxDistrict

ALTER TABLE NashvilleHousingData
DROP COLUMN SaleDate

