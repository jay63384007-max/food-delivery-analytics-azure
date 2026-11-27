import pandas as pd
from pathlib import Path

RAW = Path("data/raw")
CLEAN = Path("data/clean")
CLEAN.mkdir(parents=True, exist_ok=True)

# Load files
customers = pd.read_csv(RAW / "customers.csv")
restaurants = pd.read_csv(RAW / "restaurants.csv")
orders = pd.read_csv(RAW / "food_orders.csv")
delivery = pd.read_csv(RAW / "delivery.csv")

# Orders: remove duplicates, fix status, fix dates
orders = orders.drop_duplicates(subset="order_id")
orders["order_status"] = orders["order_status"].str.strip().str.upper()
orders["order_date"] = pd.to_datetime(orders["order_date"], errors="coerce")
orders = orders.dropna(subset=["order_date", "order_amount"])

# Orders: ratings must be 1 to 5, otherwise blank
orders.loc[~orders["rating"].between(1, 5), "rating"] = None

# Delivery: remove duplicates and invalid minutes
delivery = delivery.drop_duplicates(subset="order_id")
delivery = delivery[delivery["delivery_minutes"] > 0]
delivery.loc[~delivery["delivery_rating"].between(1, 5), "delivery_rating"] = None

# Keep only delivery rows that belong to a valid order
delivery = delivery[delivery["order_id"].isin(orders["order_id"])]

# Save cleaned files
customers.to_csv(CLEAN / "customers.csv", index=False)
restaurants.to_csv(CLEAN / "restaurants.csv", index=False)
orders.to_csv(CLEAN / "food_orders.csv", index=False)
delivery.to_csv(CLEAN / "delivery.csv", index=False)

print("Orders:", len(orders))
print("Delivery:", len(delivery))
print("Done. Cleaned files saved in data/clean")