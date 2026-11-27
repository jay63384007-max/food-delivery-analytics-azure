# Food Delivery Customer and Restaurant Analytics

Data engineering project (Team 7): combine four CSV sources into an analytics-ready
star schema on Azure and report on it in Power BI.

## Architecture
CSV files -> Azure Blob Storage (raw, clean) -> Azure Data Factory -> Azure SQL Database (staging -> star schema) -> Power BI

## Tech stack
Python (pandas), Azure Blob Storage / ADLS Gen2, Azure Data Factory, Azure SQL Database, Power BI, Git

## Repository structure
| Folder | Contents |
|---|---|
| `data/raw` | Original CSV files |
| `data/clean` | Cleaned CSV files |
| `python/` | Cleaning script |
| `sql/` | DDL, load procedure, analysis queries |
| `adf/` | Data Factory pipeline definitions |
| `docs/` | Problem statement, data model, mapping, screenshots |
| `powerbi/` | Power BI report |

## How to run
1. `pip install pandas`
2. `python python/clean.py` (reads `data/raw`, writes `data/clean`)
3. Upload `data/raw` and `data/clean` to the `raw` and `clean` containers in Azure Blob Storage
4. Run `sql/01_ddl.sql` and `sql/02_load_procedure.sql` in Azure SQL Database
5. Run the ADF pipeline `pl_load_food_delivery`
6. Open the report in `powerbi/`

## Assumptions
- Cancelled orders are excluded from revenue
- Cancelled orders have no delivery record
- Delivery duration is given in minutes (no timestamps), valid range 1-180
- Restaurant city is used for city rankings
