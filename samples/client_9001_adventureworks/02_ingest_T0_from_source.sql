/*
------------------------------------------------------------
Client 9001 – AdventureWorks (Demo)
T0 Ingestion Script
Carga inicial de datos fuente hacia el esquema raw del SDM.
------------------------------------------------------------
*/

-- Ejemplo: tabla Customer
BULK INSERT raw.Customer
FROM '$(FILEPATH)/Customer.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    TABLOCK
);
