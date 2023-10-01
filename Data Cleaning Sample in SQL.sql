--selecting the dataset

select * from PortfolioProjects..NashvilleHousing


---------------------------------------------
--updating the date

select SaleDate from PortfolioProjects..NashvilleHousing

select SaleDate, convert(date, SaleDate) from PortfolioProjects..NashvilleHousing

--This is a wrong method of updating the column as the UPDATE does not change data types.
update PortfolioProjects..NashvilleHousing
set SaleDate = CONVERT(date, SaleDate)

--To change the data type of a certain column, use ALTER TABLE then ALTER COLUMN
ALTER TABLE PortfolioProjects..NashvilleHousing ALTER COLUMN SaleDate DATE


----------------------------------------------------------------------------------

--Populate Property Address
select * from PortfolioProjects..NashvilleHousing a
where ParcelID in (select ParcelID from PortfolioProjects..NashvilleHousing where PropertyAddress is null)

--This query can only be used to select everything that has different PropertyAddress on the SAME ParcelID
--It cannot be used to update the NULL values as there is only one table, meaning one source of data.
select * from PortfolioProjects..NashvilleHousing a
where ParcelID in (select ParcelID from PortfolioProjects..NashvilleHousing b)

/* update PortfolioProjects..NashvilleHousing
set PropertyAddress = PropertyAddress
where ParcelID in (select ParcelID from PortfolioProjects..NashvilleHousing b)
and PropertyAddress is null */

--This query is used to select the null values on the pro
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProjects..NashvilleHousing a 
join PortfolioProjects..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
--where a.PropertyAddress is null
order by a.ParcelID

update a
set a.PropertyAddress = b.PropertyAddress
from PortfolioProjects..NashvilleHousing a 
join PortfolioProjects..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null
--order by a.ParcelID


---------
--splitting text in a column

select * from PortfolioProjects..NashvilleHousing;


--USING SUBSTRING
alter table PortfolioProjects..NashvilleHousing
add PropertyAddressModified Nvarchar(255);

update PortfolioProjects..NashvilleHousing
set PropertyAddressModified = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)


alter table PortfolioProjects..NashvilleHousing
add PropertyCity Nvarchar(255);

update PortfolioProjects..NashvilleHousing
set PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))


--USING PARSENAME


alter table PortfolioProjects..NashvilleHousing
add OwnerAddressModified Nvarchar(255);

alter table PortfolioProjects..NashvilleHousing
add OwnerAddressCity Nvarchar(255);

alter table PortfolioProjects..NashvilleHousing
add OwnerAddressState Nvarchar(255);


update PortfolioProjects..NashvilleHousing
set OwnerAddressModified = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

update PortfolioProjects..NashvilleHousing
set OwnerAddressCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

update PortfolioProjects..NashvilleHousing
set OwnerAddressState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)



--------------------------
--changing Y and N to Yes and No


select DISTINCT SoldAsVacant from PortfolioProjects..NashvilleHousing;

Update PortfolioProjects..NashvilleHousing
set SoldAsVacant = (CASE WHEN SoldAsVacant = 'Y' THEN 'Yes' ELSE 'No' 
END);



--------------------------------------------------
--Deleting duplicate values


with RowNumCTE as (
select *, 
			ROW_NUMBER() over (
			partition by ParcelID,
						 PropertyAddress,
						 SalePrice,
						 SaleDate,
						 LegalReference
						 order by 
						 UniqueID
						 ) row_num
from PortfolioProjects..NashvilleHousing
--order by ParcelID
)
select * from RowNumCTE
where row_num > 1
order by PropertyAddress