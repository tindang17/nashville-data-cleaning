-- Standardize date format
ALTER TABLE 
    nashville_housing.nashville_housing_data
ALTER COLUMN
    sale_date SET DATA TYPE DATE;

-- Populate Property Address data
SELECT
    a.parcel_id, a.property_address, b.parcel_id, b.property_address, IFNULL(a.property_address, b.property_address)
FROM
    nashville_housing.nashville_housing_data a
JOIN
    nashville_housing.nashville_housing_data b
    ON a.parcel_id = b.parcel_id
    AND a.id <> b.id
WHERE
    a.property_address is NULL;
    
-- MIN returns the non-numerical value as close alphabetically to "A" as possible
-- Combine with GROUP BY helps to eliminate UPDATE/MERGE must match at most one source row for each target row
UPDATE 
    nashville_housing.nashville_housing_data a
SET 
    property_address = b.property_address
FROM 
    (SELECT 
        parcel_id,
        MIN(property_address) as property_address
    FROM
        nashville_housing.nashville_housing_data
    WHERE
        property_address is not NULL
    GROUP BY
        parcel_id
    ) b
WHERE a.parcel_id = b.parcel_id
AND a.property_address is NULL;

--breaking out address into individual columns (address, city, state)
-- Property address
ALTER TABLE nashville_housing.nashville_housing_data
ADD COLUMN property_split_address STRING;

UPDATE nashville_housing.nashville_housing_data
SET property_split_address = SUBSTR(property_address, 1, STRPOS(property_address, ',') - 1)
WHERE property_split_address is NULL;

ALTER TABLE nashville_housing.nashville_housing_data
ADD COLUMN property_split_city STRING;

UPDATE nashville_housing.nashville_housing_data
SET property_split_city = SUBSTR(property_address, STRPOS(property_address, ',') + 1)
WHERE property_split_city is NULL;

-- owner's address
ALTER TABLE nashville_housing.nashville_housing_data
ADD COLUMN owner_split_address STRING;

UPDATE nashville_housing.nashville_housing_data
SET owner_split_address = SUBSTR(owner_address, 1, STRPOS(owner_address, ',') - 1)
WHERE owner_split_address is NULL;

ALTER TABLE nashville_housing.nashville_housing_data
ADD COLUMN owner_split_city STRING;

UPDATE nashville_housing.nashville_housing_data
SET owner_split_city = SUBSTR(SUBSTR(owner_address, STRPOS(owner_address, ',') + 1), 1, STRPOS(SUBSTR(owner_address, STRPOS(owner_address, ',') + 1), ',') - 1)
WHERE owner_split_city is NULL;

ALTER TABLE nashville_housing.nashville_housing_data
ADD COLUMN owner_split_state STRING;

UPDATE nashville_housing.nashville_housing_data
SET owner_split_state = SUBSTR(owner_address, -2, 2)
WHERE owner_split_state is NULL;
