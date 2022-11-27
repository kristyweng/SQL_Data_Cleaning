
select *
from NashvilleHousing;


-------------------------------------------------------------------------------------------------------------------------


-- Standardize Date Format


select saledate
from NashvilleHousing;

UPDATE NashvilleHousing 
SET saledate = convert(saledate, DATE);


-------------------------------------------------------------------------------------------------------------------------


-- Populate PropertyAddress data


select * 
from NashvilleHousing
where PropertyAddress is null;


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ifnull(a.PropertyAddress, b.PropertyAddress)
from nashvillehousing a
join nashvillehousing b
	on a.ParcelID = b.ParcelID
    and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null;


Update nashvillehousing a
join nashvillehousing b
		on a.ParcelID = b.ParcelID
		and a.UniqueID <> b.UniqueID
Set a.PropertyAddress = b.PropertyAddress
where a.PropertyAddress is null;


-------------------------------------------------------------------------------------------------------------------------


-- Break out PropertyAddress into Columns (Address, City, State)


select substring(PropertyAddress, 1, position(',' in PropertyAddress)-1) as Address, 
	substring(PropertyAddress, position(',' in PropertyAddress)+1, length(PropertyAddress)) as City
from nashvillehousing;

-- Add Address column

Alter Table nashvillehousing
add PropertySplitAddress nvarchar(255);

Update nashvillehousing
set PropertySplitAddress = substring(PropertyAddress, 1, position(',' in PropertyAddress)-1);

-- Add City column

Alter Table nashvillehousing
add PropertySplitCity nvarchar(255);

Update nashvillehousing
set PropertySplitCity = substring(PropertyAddress, position(',' in PropertyAddress)+1, length(PropertyAddress));	


-- Break out OwnerAddress into Columns (Address, City, State)


select substring_index(OwnerAddress, ',', 1) as OwnerSplitAddress,
substring_index(substring_index(OwnerAddress, ',', 2),',',-1) as OwnerSplitCity,
substring_index(OwnerAddress, ',', -1) as OwnerSplitState
from nashvillehousing;

-- Add Address column

Alter Table nashvillehousing
add OwnerSplitAddress nvarchar(255);

Update nashvillehousing
set OwnerSplitAddress = substring_index(OwnerAddress, ',', 1);

-- Add City column

Alter Table nashvillehousing
add OwnerSplitCity nvarchar(255);

Update nashvillehousing
set OwnerSplitCity = substring_index(substring_index(OwnerAddress, ',', 2),',',-1);

-- Add State column

Alter Table nashvillehousing
add OwnerSplitState nvarchar(255);

Update nashvillehousing
set OwnerSplitState = substring_index(OwnerAddress, ',', -1);


-------------------------------------------------------------------------------------------------------------------------


-- Replace Y and N with YES and NO in SoldAsVacant field


select SoldAsVacant, count(SoldAsVacant)
from nashvillehousing
group by SoldAsVacant
order by 2;

select SoldAsVacant,
	case when SoldAsVacant = 'Y' then 'Yes'
    when SoldAsVacant = 'N' then 'No'
    Else SoldAsVacant END 
from nashvillehousing;

Update nashvillehousing
Set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
    when SoldAsVacant = 'N' then 'No'
    Else SoldAsVacant END;
    

-------------------------------------------------------------------------------------------------------------------------


-- Delete duplicate


With RowNum as (
select *, 
	row_number() over (partition by ParcelID,
									LandUse,
                                    PropertyAddress,
                                    SaleDate,
                                    SalePrice,
                                    LegalReference 
                                    order by UniqueID) as RowNumber
from nashvillehousing)

Delete
from nashvillehousing
where UniqueID in (
	select UniqueID
	from RowNum
	where RowNumber>1);
    

-- Delete unused columns


select * 
from nashvillehousing;

Alter table nashvillehousing
	Drop column PropertyAddress, 
	Drop column OwnerAddress, 
	Drop column TaxDistrict;


