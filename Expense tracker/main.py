from PySide6.QtWidgets import (
    QApplication, QMainWindow, QWidget, QVBoxLayout, QHBoxLayout,
    QLabel, QPushButton, QLineEdit, QComboBox, QCalendarWidget,
    QTableWidget, QTableWidgetItem, QMessageBox, QCheckBox
)
from PySide6.QtCore import Qt, QDate
from matplotlib.backends.backend_qt5agg import FigureCanvasQTAgg as FigureCanvas
import matplotlib.pyplot as plt
import pandas as pd
import sys
import sqlite3
from database import connect_db, insert_expense, fetch_expenses, delete_expense


class ExpenseTracker(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Expense Tracker")
        self.setGeometry(100, 100, 1100, 700)

        connect_db()
        self.expenses = fetch_expenses()

        # --- Layout setup ---
        main_layout = QVBoxLayout()
        top_layout = QHBoxLayout()
        bottom_layout = QVBoxLayout()

        # === LEFT PANEL ===
        left_layout = QVBoxLayout()
        self.calendar = QCalendarWidget()
        self.calendar.setGridVisible(True)
        left_layout.addWidget(self.calendar)

        # Category
        left_layout.addWidget(QLabel("Category"))
        self.category_input = QComboBox()
        self.category_input.addItems(["Select", "Food", "Bills", "Transport", "Shopping", "Travel", "Other"])
        left_layout.addWidget(self.category_input)

        # Amount
        left_layout.addWidget(QLabel("Amount"))
        self.amount_input = QLineEdit()
        left_layout.addWidget(self.amount_input)

        # Notes
        left_layout.addWidget(QLabel("Notes"))
        self.notes_input = QLineEdit()
        left_layout.addWidget(self.notes_input)

        # Buttons
        button_layout = QHBoxLayout()
        self.submit_button = QPushButton("Submit")
        self.submit_button.clicked.connect(self.add_expense)

        self.delete_button = QPushButton("Delete")
        self.delete_button.clicked.connect(self.delete_selected)

        button_layout.addWidget(self.submit_button)
        button_layout.addWidget(self.delete_button)
        left_layout.addLayout(button_layout)

        # === RIGHT PANEL ===
        right_layout = QVBoxLayout()
        self.figure, self.ax = plt.subplots(figsize=(4, 4))
        self.canvas = FigureCanvas(self.figure)
        right_layout.addWidget(self.canvas)

        top_layout.addLayout(left_layout)
        top_layout.addLayout(right_layout)

        # === TABLE SECTION ===
        self.table = QTableWidget()
        self.table.setColumnCount(5)
        self.table.setHorizontalHeaderLabels(["ID", "Date", "Amount", "Category", "Notes"])
        bottom_layout.addWidget(self.table)

        main_layout.addLayout(top_layout)
        main_layout.addLayout(bottom_layout)

        container = QWidget()
        container.setLayout(main_layout)
        self.setCentralWidget(container)

        self.load_expenses()
        self.update_chart()

    # ------------------------
    # Functions
    # ------------------------
    def load_expenses(self):
        self.table.setRowCount(0)
        data = fetch_expenses()
        for row_num, row_data in enumerate(data):
            self.table.insertRow(row_num)
            for col, value in enumerate(row_data):
                self.table.setItem(row_num, col, QTableWidgetItem(str(value)))
        self.update_chart()

    def add_expense(self):
        date = self.calendar.selectedDate().toString("yyyy-MM-dd")
        category = self.category_input.currentText()
        amount = self.amount_input.text()
        notes = self.notes_input.text()

        if category == "Select" or not amount.strip():
            QMessageBox.warning(self, "Error", "Please select category and enter amount.")
            return

        try:
            insert_expense(date, category, float(amount), notes)
            QMessageBox.information(self, "Success", "Expense added successfully!")
            self.amount_input.clear()
            self.notes_input.clear()
            self.load_expenses()
        except ValueError:
            QMessageBox.warning(self, "Error", "Invalid amount entered.")


    def delete_selected(self):
        selected = self.table.currentRow()
        if selected == -1:
            QMessageBox.warning(self, "Error", "Select a row to delete.")
            return
        expense_id = int(self.table.item(selected, 0).text())
        delete_expense(expense_id)
        QMessageBox.information(self, "Deleted", "Expense deleted successfully.")
        self.load_expenses()

    def update_chart(self):
        # Get selected month and year from the calendar
        selected_date = self.calendar.selectedDate()
        selected_month = selected_date.month()
        selected_year = selected_date.year()

        conn = sqlite3.connect("expenses.db")
        df = pd.read_sql_query("SELECT * FROM expenses", conn)
        conn.close()

        if df.empty:
            self.ax.clear()
            self.ax.text(0.5, 0.5, "No Data", ha='center', va='center')
            self.canvas.draw()
            return

        # Convert 'date' column to datetime
        df['date'] = pd.to_datetime(df['date'], errors='coerce')

        # Filter data for selected month and year
        df_filtered = df[(df['date'].dt.month == selected_month) &
                        (df['date'].dt.year == selected_year)]

        if df_filtered.empty:
            self.ax.clear()
            self.ax.text(0.5, 0.5, f"No data for {selected_date.toString('MMMM yyyy')}",
                        ha='center', va='center')
            self.canvas.draw()
            return

        # Group and plot category-wise monthly data
        summary = df_filtered.groupby("category")["amount"].sum()

        self.ax.clear()
        self.ax.pie(summary.values, labels=summary.index, autopct='%1.0f%%', startangle=90)
        self.ax.set_title(f"Expense Breakdown – {selected_date.toString('MMMM yyyy')}")
        self.canvas.draw()



if __name__ == "__main__":
    app = QApplication(sys.argv)
    window = ExpenseTracker()
    window.show()
    sys.exit(app.exec())
