/*
 ISDS 570 Data Transformation for Business - SQL Review
 Dr. Kalczynski

 https://www.postgresql.org/docs/current/static/sql-expressions.html
 https://www.w3schools.com/SQL/
 https://www.postgresqltutorial.com/

*/

--------------------------------------------------------------
-- First, create a database "stockmarket" under "Databases" --
--------------------------------------------------------------

-- Use pgAdmin's interface

------------------------------------------------------------------------------------
-- Let us now investigate the csv files, create a temporary table and import data --
------------------------------------------------------------------------------------

-- Use Microsoft Excel (OpenOffice or Google Spreasheets) to investigate small csv files
-- Make sure to check the lengths of the fields!

/*
This is only in case you are unable to create it manually
-- LIFELINE
-- DROP TABLE public._temp_company_list;
CREATE TABLE public._temp_company_list
(
    symbol character varying(255) COLLATE pg_catalog."default",
    name character varying(255) COLLATE pg_catalog."default",
    last_sale character varying(255) COLLATE pg_catalog."default",
    net_change character varying(255) COLLATE pg_catalog."default",
	pct_change character varying(255) COLLATE pg_catalog."default",
	market_cap character varying(255) COLLATE pg_catalog."default",
	country character varying(255) COLLATE pg_catalog."default",
    ipo_year character varying(255) COLLATE pg_catalog."default",
    volume character varying(255) COLLATE pg_catalog."default",
    sector character varying(255) COLLATE pg_catalog."default",
    industry character varying(255) COLLATE pg_catalog."default"
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public._temp_company_list
    OWNER to postgres;
*/

-------------------------------------------------
-- Import NASDAQ companies to the temporary table
-------------------------------------------------

/*
	Set the header ON, separator to a comma and text delimiter to double-quote
	You need to change rights to folders to execute PSQL import statement on Windows 10 - so you need to be able to do it by hand
*/

----------------------------------------------
-- Check if we have data in the correct format
-----------------------------------------------
SELECT * FROM _temp_company_list LIMIT 10;
SELECT COUNT(*) from _temp_company_list;

--------------------------------------------------------------
-- Now, let us create the actual tables to transfer data there
--------------------------------------------------------------

-- table stock_mkt with just one column stock_mkt_name(16,PK)

/*
-- LIFELINE
-- DROP TABLE public.stock_mkt;
CREATE TABLE public.stock_mkt
(
    stock_mkt_name character varying(16) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT stock_mkt_pkey PRIMARY KEY (stock_mkt_name)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public.stock_mkt
    OWNER to postgres;
*/

-- table company_list with stock_mkt_name(16,PK), symbol(16,PK), company_name(100), market_cap, sector(100), industry(100)

/*
-- LIFELINE

-- DROP TABLE public.company_list;
CREATE TABLE public.company_list
(
    symbol character varying(16) COLLATE pg_catalog."default" NOT NULL,
    stock_mkt_name character varying(16) COLLATE pg_catalog."default" NOT NULL,
    company_name character varying(255) COLLATE pg_catalog."default",
    market_cap double precision,
	country character varying(255) COLLATE pg_catalog."default",
	ipo_year integer,
	sector character varying(255) COLLATE pg_catalog."default",
    industry character varying(255) COLLATE pg_catalog."default",
    CONSTRAINT company_list_pkey PRIMARY KEY (symbol, stock_mkt_name)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public.company_list
    OWNER to postgres;

*/

-- We have PK and other entity integrity constraints, now let us set the referential integrity (FK) constraints

/*
-- LIFELINE
ALTER TABLE public.company_list
    ADD CONSTRAINT company_list_fkey FOREIGN KEY (stock_mkt_name)
    REFERENCES public.stock_mkt (stock_mkt_name) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;
CREATE INDEX fki_company_list_fkey
    ON public.company_list(stock_mkt_name);
*/
-- Validate the FK (company_list->Constraints->right-click on the fkey->Validate)

----------------------------------------------
-- Populate the final tables with data
-----------------------------------------------

-- First, add the markets to the stock_mkt (otherwise you will get an integrity error)
TRUNCATE TABLE public.stock_mkt; -- Fast delete all content (no restoring) but will not work if we have referential integrity
DELETE FROM stock_mkt; -- The "normal" delete procedure
-- But we have nothing to delete - we need to add data
INSERT INTO stock_mkt (stock_mkt_name) VALUES ('NASDAQ');
-- Check!
SELECT * FROM stock_mkt;

-- Next we will load the company_list with data stored in _temp_company_list
-- Prepare
SELECT symbol, 'NASDAQ' AS stock_mkt_name, name company_name, market_cap,country, ipo_year,sector, industry 
FROM _temp_company_list;

-- INSERT INTO will not work!
INSERT INTO company_list
SELECT symbol, 'NASDAQ' AS stock_mkt_name, name company_name, market_cap, country, ipo_year,sector,industry 
FROM _temp_company_list;

-- Insert with proper casting (type conversion)
INSERT INTO company_list
SELECT symbol, 'NASDAQ' AS stock_mkt_name, name company_name, market_cap::double precision ,country, ipo_year::integer, sector,industry 
FROM _temp_company_list;
-- Check
SELECT * FROM company_list LIMIT 10;
SELECT COUNT(*) FROM company_list;

/*
******** RESTORE POINT stockmarket1
In order to continue learning, you need to have all the previous steps completed
If you would like to review later (and you need to know how to complete these steps).
However, in the interest of time, I have created a backup of the current progress and 
will now demonstrate how to restore it.

IMPORTANT: remove the current database and recreate it to restore from backup
DO NOT RESTORE THE BACKUP TO THE postgres database!
*/

-------------------------------------------------
-- YOUR TURN: Import NYSE and AMEX companies ----
-------------------------------------------------
-- HINT: add rows with market names (NYSE and AMEX) to the stock_mkt table first
-- HINT: truncate the _temp_company_list before each new import, otherwise you will create duplicates
-- HINT: do now forget to manually change the market name with each import

-----------------------------------------------------------------
-- Dealing with unwanted values  and leading/trailing blanks ----
-----------------------------------------------------------------
SELECT * FROM company_list order by market_cap LIMIT 100;
UPDATE company_list SET market_cap=NULL WHERE market_cap=0;
SELECT * FROM company_list order by market_cap LIMIT 100;

UPDATE stock_mkt SET stock_mkt_name=TRIM(stock_mkt_name);

UPDATE company_list SET 
	stock_mkt_name=TRIM(stock_mkt_name)
	,company_name=TRIM(company_name)
	,country=TRIM(country)	
	,sector=TRIM(sector)
	,industry=TRIM(industry);

SELECT * FROM company_list LIMIT 10;

-- Please install R and R Studio (see the appropriate appendix) before the next session.

----------------------------------------------
----------------- End of Part a --------------
----------------------------------------------


----------------------------------------------
------------- Beginning of Part b ------------
----------------------------------------------

----------------------------------------------
----------------- Create a View --------------
----------------------------------------------

-- Let us create a view v_company_list using the select statement with numeric market cap

/*
-- LIFELINE

CREATE OR REPLACE VIEW public.v_company_list AS
 SELECT company_list.symbol,
    company_list.stock_mkt_name,
    company_list.company_name,
    company_list.market_cap,
    company_list.country,	
    company_list.sector,
    company_list.industry
   FROM company_list;

ALTER TABLE public.v_company_list
    OWNER TO postgres;

*/

-- Check!
SELECT * FROM v_company_list;


----------------------------------------------------------
----------------- Import EOD (End of Day) Quotes ---------
----------------------------------------------------------
-- Let's assume that this is curated data (so, no temporary table)
-- Use R's read.csv with a row limit to identify the number and types of columns
-- Create table eod_quotes
-- NOTE: ticker and date will be the PK; volume numeric, and other numbers real (4 bytes)
-- NOTE: double precision and bigint will result in an import error on Windows

/*
-- LIFELINE
-- DROP TABLE public.eod_quotes;

CREATE TABLE public.eod_quotes
(
    ticker character varying(16) COLLATE pg_catalog."default" NOT NULL,
    date date NOT NULL,
    adj_open real,
    adj_high real,
    adj_low real,
    adj_close real,
    adj_volume numeric,
    CONSTRAINT eod_quotes_pkey PRIMARY KEY (ticker, date)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public.eod_quotes
    OWNER to postgres;
*/

-- Import eod.csv to the table - it will take some time (approx. 17 million rows)

-- Check!
SELECT * FROM eod_quotes LIMIT 10;
SELECT COUNT(*) FROM eod_quotes; -- this will take some time the first time; should be 16,891,814

-- Now let's join the view with the table and extract the "NULL" sector in NASDAQ
SELECT ticker,date,company_name,market_cap,country,adj_open,adj_high,adj_low,adj_close,adj_volume
FROM v_company_list C INNER JOIN eod_quotes Q ON C.symbol=Q.ticker 
WHERE C.sector IS NULL AND C.stock_mkt_name='NASDAQ';

-- And let us store the results in a separate table
SELECT ticker,date,company_name,market_cap,country,adj_open,adj_high,adj_low,adj_close,adj_volume
INTO eod_quotes_nasdaq_null_sector
FROM v_company_list C INNER JOIN eod_quotes Q ON C.symbol=Q.ticker 
WHERE C.sector IS NULL AND C.stock_mkt_name='NASDAQ';

-- Check!
SELECT * FROM eod_quotes_nasdaq_null_sector;
-- Adjust the PK by adding a contraint - properties will not work!

/*
--LIFELINE
-- ALTER TABLE public.eod_quotes_nasdaq_null_sector DROP CONSTRAINT eod_quotes_nasdaq_null_sector_pkey;

ALTER TABLE public.eod_quotes_nasdaq_null_sector
    ADD CONSTRAINT eod_quotes_nasdaq_null_sector_pkey PRIMARY KEY (ticker, date);
*/

/*
******** RESTORE POINT stockmarket2
In order to continue learning, you need to have all the previous steps completed
If you would like to review later (and you need to know how to complete these steps).
However, in the interest of time, I have created a backup of the current progress and 
will now demonstrate how to restore it.

IMPORTANT: remove the current database and recreate it to restore from backup
DO NOT RESTORE THE BACKUP TO THE postgres database!
*/

---------------------------------------------------
----------------- Anaylze the null sector ---------
---------------------------------------------------

-- How many distinct companies (list them)?
SELECT DISTINCT ticker 
FROM eod_quotes_nasdaq_null_sector;

-- But how many?
SELECT COUNT(*) FROM (SELECT DISTINCT ticker FROM eod_quotes_nasdaq_null_sector) A;

-- From how many different countries?
SELECT COUNT(*) FROM (SELECT DISTINCT country FROM eod_quotes_nasdaq_null_sector) A;

-- Date range for all companies
SELECT ticker, MIN(date) AS first_date, MAX(date) as last_date
FROM eod_quotes_nasdaq_null_sector
GROUP BY ticker
ORDER BY first_date;

-- Which company/companies (if any) was/were listed first?
SELECT DISTINCT ticker,date FROM eod_quotes_nasdaq_null_sector
WHERE date = (SELECT MIN(date) FROM eod_quotes_nasdaq_null_sector);

-- Which company/companies (if any) was/were listed last?
-- Not so simple...
SELECT ticker, MIN(date) AS first_date, MAX(date) as last_date
FROM eod_quotes_nasdaq_null_sector
GROUP BY ticker
HAVING MIN(date)= 
	(
	SELECT MAX(first_date) 
	FROM (SELECT ticker, MIN(date) AS first_date FROM eod_quotes_nasdaq_null_sector GROUP BY ticker) LFD
	);

-- Extract date parts
-- https://www.postgresql.org/docs/10/static/functions-datetime.html
SELECT *, date_part('year',date) AS Y,date_part('month',date) AS M,date_part('day',date) AS D 
FROM eod_quotes_nasdaq_null_sector;

-- YOUR TURN: How many dates are available for each ticker symbol?
-- YOUR TURN: What was the min, average, and maximum adj_close for each ticker in 2017?

--------------------------------------------
----------------- Review JOINS -------------
--------------------------------------------

-- We have reviewed the inner join, let's now look at outer joins
-- Which NASDAQ v_company_list companies are not present in the eod_quotes (large) table?
-- Method 1
SELECT DISTINCT symbol FROM v_company_list C LEFT JOIN eod_quotes Q ON C.symbol=Q.ticker
WHERE C.stock_mkt_name='NASDAQ' AND Q.ticker IS NULL;
-- Method 2
SELECT DISTINCT symbol
FROM v_company_list 
WHERE stock_mkt_name='NASDAQ' AND symbol NOT IN (SELECT DISTINCT ticker FROM eod_quotes);

-- Which eod_quotes (large) table companies are not present in the NASDAQ v_company_list view?
-- Method 1
SELECT DISTINCT ticker 
FROM (SELECT * FROM v_company_list WHERE stock_mkt_name='NASDAQ') C RIGHT JOIN eod_quotes Q ON C.symbol=Q.ticker
WHERE C.symbol IS NULL;
-- Method 2
SELECT DISTINCT ticker 
FROM eod_quotes 
WHERE ticker NOT IN (SELECT DISTINCT symbol FROM v_company_list WHERE stock_mkt_name='NASDAQ');

-- Provide the full list of unique tickers from the v_company_list and eod_quotes
-- Method 1 - takes too long!
SELECT DISTINCT CASE WHEN symbol IS NULL THEN ticker WHEN ticker IS NULL THEN symbol ELSE ticker END AS tck
FROM v_company_list C FULL OUTER JOIN eod_quotes Q ON C.symbol=Q.ticker;

-- Method 2 - much faster
SELECT DISTINCT symbol FROM v_company_list
UNION
SELECT DISTINCT ticker FROM eod_quotes;

--------------------------------------------
----------------- WILDCARDS -------------
--------------------------------------------

-- Which company names include 'Tech'?
-- https://www.postgresql.org/docs/10/static/functions-matching.html#FUNCTIONS-LIKE
SELECT DISTINCT company_name
FROM v_company_list 
WHERE company_name LIKE '%Tech%'

-- YOUR TURN: Which company names end with 'Inc.'

----------------------------------------------
----------------- End of Part  ---------------
----------------------------------------------