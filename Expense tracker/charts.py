import matplotlib.pyplot as plt
import sqlite3
import pandas as pd

def show_monthly_summary():
    conn = sqlite3.connect("expenses.db")
    df = pd.read_sql_query("SELECT * FROM expenses", conn)
    df['date'] = pd.to_datetime(df['date'])
    df['month'] = df['date'].dt.to_period('M')
    monthly = df.groupby('month')['amount'].sum()

    plt.bar(monthly.index.astype(str), monthly.values)
    plt.title("Monthly Expense Summary")
    plt.xlabel("Month")
    plt.ylabel("Total Spending (₹)")
    plt.xticks(rotation=45)
    plt.tight_layout()
    plt.show()
    conn.close()
