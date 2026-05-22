import csv
import random
from faker import Faker
from datetime import datetime

fake = Faker()

# -----------------------------
# Config
# -----------------------------
NUM_CUSTOMERS = 100
ACCOUNTS_PER_CUSTOMER = 2
CARDS_PER_ACCOUNT = 1
NUM_TRANSACTIONS = 500

SOURCE_PATH = "/mnt/c/Users/sanan/OneDrive/Interview/banking_project_model/source_files"

# -----------------------------
# timestamps (SAFE)
# -----------------------------
load_dt = datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S")
file_ts = datetime.utcnow().strftime("%Y%m%d%H%M%S")

# -----------------------------
# File names
# -----------------------------
CUSTOMER_FILE_PATH = f"{SOURCE_PATH}/customers_{file_ts}.csv"
ACCOUNT_FILE_PATH = f"{SOURCE_PATH}/accounts_{file_ts}.csv"
CARD_FILE_PATH = f"{SOURCE_PATH}/cards_{file_ts}.csv"
TRANSACTION_FILE_PATH = f"{SOURCE_PATH}/transactions_{file_ts}.csv"

CUSTOMER_FILE_NAME = f"customers_{file_ts}.csv"
ACCOUNT_FILE_NAME = f"accounts_{file_ts}.csv"
CARD_FILE_NAME = f"cards_{file_ts}.csv"
TRANSACTION_FILE_NAME = f"transactions_{file_ts}.csv"

# -----------------------------
# Master data
# -----------------------------
transaction_types = ["PURCHASE", "WITHDRAWAL", "TRANSFER", "PAYMENT"]
channels = ["ATM", "WEB", "MOBILE_APP", "POS"]
currencies = ["GBP", "USD", "EUR"]
statuses = ["SUCCESS", "FAILED", "PENDING"]

# =========================================================
# 1. CUSTOMER FILE
# =========================================================
customers = []

for i in range(1, NUM_CUSTOMERS + 1):

    customers.append({
        "load_dt": load_dt,
        "file_name": CUSTOMER_FILE_NAME,
        "customer_id": f"CUST{i:05d}",
        "first_name": fake.first_name(),
        "last_name": fake.last_name(),
        "email": fake.email(),
        "phone": fake.phone_number(),
        "dob": fake.date_of_birth(minimum_age=18, maximum_age=80).strftime("%Y-%m-%d"),
        "gender": random.choice(["M", "F"]),
        "nationality": fake.country()
    })

# =========================================================
# 2. ACCOUNT FILE
# =========================================================
accounts = []

for c in customers:
    for _ in range(ACCOUNTS_PER_CUSTOMER):

        accounts.append({
            "load_dt": load_dt,
            "file_name": ACCOUNT_FILE_NAME,
            "account_id": f"ACCT{random.randint(100000000, 999999999)}",
            "account_number": f"ACC{random.randint(10000000, 99999999)}",
            "customer_id": c["customer_id"],
            "account_type": random.choice(["SAVINGS", "CURRENT"]),
            "currency": random.choice(currencies),
            "balance": round(random.uniform(1000, 50000), 2),
            "status": "ACTIVE"
        })

# =========================================================
# 3. CARD FILE
# =========================================================
cards = []

for acc in accounts:
    for _ in range(CARDS_PER_ACCOUNT):

        cards.append({
            "load_dt": load_dt,
            "file_name": CARD_FILE_NAME,
            "card_id": f"CARD{random.randint(100000000, 999999999)}",
            "card_number": f"{random.randint(4000000000000000, 4999999999999999)}",
            "account_number": acc["account_number"],
            "customer_id": acc["customer_id"],
            "card_type": random.choice(["DEBIT", "CREDIT"]),
            "expiry_date": fake.credit_card_expire(),
            "status": "ACTIVE"
        })

# =========================================================
# 4. TRANSACTION FILE
# =========================================================
transactions = []

for i in range(1, NUM_TRANSACTIONS + 1):

    acc = random.choice(accounts)
    card = random.choice(cards)

    amount = round(random.uniform(10, 5000), 2)

    transactions.append({
        "load_dt": load_dt,
        "file_name": TRANSACTION_FILE_NAME,
        "transaction_id": f"TXN{i:08d}",
        "customer_id": acc["customer_id"],
        "account_number": acc["account_number"],
        "card_number": card["card_number"],
        "transaction_timestamp": fake.date_time_between(
            start_date="-1y",
            end_date="now"
        ).strftime("%Y-%m-%d %H:%M:%S"),
        "transaction_type": random.choice(transaction_types),
        "channel": random.choice(channels),
        "merchant_name": fake.company(),
        "currency": random.choice(currencies),
        "amount": amount,
        "fee_amount": round(amount * 0.02, 2),
        "balance_after_txn": round(random.uniform(1000, 50000), 2),
        "status": random.choice(statuses),
        "is_fraud_flag": random.choice([False, False, False, True])
    })

# =========================================================
# HELPER
# =========================================================
def write_csv(path, data):
    if not data:
        return
    with open(path, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=data[0].keys())
        writer.writeheader()
        writer.writerows(data)

# =========================================================
# WRITE FILES
# =========================================================
write_csv(CUSTOMER_FILE_PATH, customers)
write_csv(ACCOUNT_FILE_PATH, accounts)
write_csv(CARD_FILE_PATH, cards)
write_csv(TRANSACTION_FILE_PATH, transactions)

print("SUCCESS: Files generated")
print(CUSTOMER_FILE_PATH)
print(ACCOUNT_FILE_PATH)
print(CARD_FILE_PATH)
print(TRANSACTION_FILE_PATH)