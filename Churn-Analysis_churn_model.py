# ============================================================
# PROJECT 2: Customer Churn & Revenue Risk Analysis
# File: churn_model.py
# Description: Loads the SQL master export, trains a logistic
#              regression model to predict churn probability,
#              and exports a scored CSV for Tableau.
#
# Requirements: pip install pandas scikit-learn
# ============================================================

import pandas as pd
from sklearn.linear_model import LogisticRegression
from sklearn.preprocessing import StandardScaler

# ---- 1. Load the master export from SQL ----------------
df = pd.read_csv("churn_master.csv")

# ---- 2. Select features for the model ------------------
# These are the signals SQL identified as churn indicators
features = [
    "avg_usage_score",
    "avg_logins",
    "avg_features_used",
    "billing_tickets",
    "avg_satisfaction",
    "tenure_years",
    "monthly_revenue"
]

# Fill any missing satisfaction scores with neutral value 3
df["avg_satisfaction"] = df["avg_satisfaction"].fillna(3.0)

X = df[features]
y = df["churned"]

# ---- 3. Scale features and train model -----------------
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

model = LogisticRegression(random_state=42)
model.fit(X_scaled, y)

# ---- 4. Score every customer with churn probability ----
df["churn_probability"] = model.predict_proba(X_scaled)[:, 1]
df["churn_probability"] = df["churn_probability"].round(3)

# Translate probability to a label for Tableau
df["model_risk_label"] = df["churn_probability"].apply(
    lambda p: "Critical" if p >= 0.75
         else "High"     if p >= 0.50
         else "Medium"   if p >= 0.25
         else "Low"
)

# ---- 5. Print feature importance -----------------------
print("Feature importance (model coefficients):")
for feat, coef in sorted(zip(features, model.coef_[0]), key=lambda x: abs(x[1]), reverse=True):
    print(f"  {feat:<25} {coef:+.3f}")

# ---- 6. Export scored file for Tableau -----------------
output_cols = [
    "customer_id", "full_name", "segment", "region", "industry",
    "account_manager", "plan_name", "monthly_revenue", "contract_type",
    "status", "churned", "tenure_years",
    "avg_usage_score", "avg_logins", "avg_features_used",
    "billing_tickets", "avg_satisfaction",
    "risk_level", "churn_probability", "model_risk_label"
]

df[output_cols].to_csv("churn_scored.csv", index=False)
print(f"\nExported {len(df)} scored customers to churn_scored.csv")
print(f"\nChurn probability summary:")
print(df.groupby("model_risk_label")["monthly_revenue"].agg(["count","sum"]).rename(
    columns={"count": "customers", "sum": "mrr_at_risk"}
))
