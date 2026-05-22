import csv
import random
from faker import Faker
from datetime import datetime

fake = Faker()

# -----------------------------------
# Configuration
# -----------------------------------
NUM_CUSTOMERS = 100
NUM_TRANSACTIONS = 500


load_dt = datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S")

file_ts = datetime.utcnow().strftime("%Y%m%d%H%M%S")

# File paths
CUSTOMER_FILE_PATH = f"/mnt/c/Users/sanan/OneDrive/Interview/source_files/customers_{file_ts}.csv"

TRANSACTION_FILE_PATH = f"/mnt/c/Users/sanan/OneDrive/Interview/source_files/transactions_{file_ts}.csv"

CUSTOMER_FILE = f"customer_{load_dt}.csv"

TRANSACTION_FILE = f"transaction_{load_dt}.csv"

# -----------------------------------
# Master Data
# -----------------------------------
genders = ["Male", "Female", "Other"]

nationalities = [
    "British",
    "American",
    "Indian",
    "Canadian",
    "Australian",
    "German",
    "French"
]

transaction_types = [
    "PURCHASE",
    "WITHDRAWAL",
    "TRANSFER",
    "PAYMENT",
    "REFUND"
]

channels = [
    "ATM",
    "MOBILE_APP",
    "WEB",
    "POS",
    "BRANCH"
]

merchant_names = [
    "Amazon",
    "Tesco",
    "Walmart",
    "Starbucks",
    "Apple Store",
    "Uber",
    "Shell",
    "Target"
]

currencies = ["USD", "GBP", "EUR", "INR"]

statuses = ["SUCCESS", "FAILED", "PENDING"]

# -----------------------------------
# Generate Customer Data
# -----------------------------------
customers = []

for i in range(1, NUM_CUSTOMERS + 1):

    customer = {
        "load_dt":load_dt,
        "file_name": CUSTOMER_FILE,
        "customer_id": f"CUST{i:05d}",
        "first_name": fake.first_name(),
        "last_name": fake.last_name(),
        "email": fake.email(),
        "phone": fake.phone_number(),
        "dob": fake.date_of_birth(
            minimum_age=18,
            maximum_age=80
        ).strftime("%Y-%m-%d"),
        "gender": random.choice(genders),
        "nationality": random.choice(nationalities)
    }

    customers.append(customer)

# Write customer CSV
with open(CUSTOMER_FILE_PATH, mode="w", newline="", encoding="utf-8") as file:

    writer = csv.DictWriter(
        file,
        fieldnames=[
            "load_dt",
            "file_name",
            "customer_id",
            "first_name",
            "last_name",
            "email",
            "phone",
            "dob",
            "gender",
            "nationality"
        ]
    )

    writer.writeheader()
    writer.writerows(customers)

print(f"{CUSTOMER_FILE_PATH} created successfully!")

# -----------------------------------
# Generate Transaction Data
# -----------------------------------
transactions = []

for i in range(1, NUM_TRANSACTIONS + 1):

    customer = random.choice(customers)

    amount = round(random.uniform(10, 5000), 2)
    fee_amount = round(random.uniform(0, 25), 2)

    opening_balance = round(random.uniform(1000, 50000), 2)

    balance_after_txn = round(
        opening_balance - amount - fee_amount,
        2
    )

    transaction = {
        "load_dt":load_dt,
        "file_name": TRANSACTION_FILE,
        "transaction_id": f"TXN{i:08d}",
        "customer_key": int(customer["customer_id"].replace("CUST", "")),
        "account_key": random.randint(100000, 999999),
        "card_key": random.randint(1000000, 9999999),
        "transaction_timestamp": fake.date_time_between(
            start_date="-1y",
            end_date="now"
        ).strftime("%Y-%m-%d %H:%M:%S"),
        "transaction_type": random.choice(transaction_types),
        "channel": random.choice(channels),
        "merchant_name": random.choice(merchant_names),
        "currency": random.choice(currencies),
        "amount": amount,
        "fee_amount": fee_amount,
        "balance_after_txn": balance_after_txn,
        "status": random.choice(statuses),
        "is_fraud_flag": random.choice([True, False])
    }

    transactions.append(transaction)

# Write transaction CSV
with open(TRANSACTION_FILE_PATH, mode="w", newline="", encoding="utf-8") as file:

    writer = csv.DictWriter(
        file,
        fieldnames=[
            "load_dt",
            "file_name",
            "transaction_id",
            "customer_key",
            "account_key",
            "card_key",
            "transaction_timestamp",
            "transaction_type",
            "channel",
            "merchant_name",
            "currency",
            "amount",
            "fee_amount",
            "balance_after_txn",
            "status",
            "is_fraud_flag"
        ]
    )

    writer.writeheader()
    writer.writerows(transactions)

print(f"{TRANSACTION_FILE_PATH} created successfully!")

print("\nData generation completed successfully!")