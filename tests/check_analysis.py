"""Sample and boundary checks for SQLP1.sql queries 1-9 (Python standard library).
Query 10 uses PostgreSQL-specific date syntax and needs PostgreSQL validation.
Run: python tests/check_analysis.py
"""
from pathlib import Path
import re
import sqlite3

text = (Path(__file__).resolve().parents[1] / "SQLP1.sql").read_text(encoding="utf-8")
text = re.sub(r"/\*.*?\*/", "", text, flags=re.S)
text = re.sub(r"--[^\n]*", "", text)
statements = [s.strip() for s in text.split(";") if s.strip()]
assert len(statements) == 16, f"Expected 6 setup and 10 analysis statements, got {len(statements)}"
db = sqlite3.connect(":memory:")
for statement in statements[:6]:
    db.execute(statement)
queries = statements[6:]
def results(index):
    return db.execute(queries[index - 1]).fetchall()

assert dict(results(1)) == {"A": 76, "B": 74, "C": 36}
assert dict(results(2)) == {"A": 4, "B": 6, "C": 2}
assert set(results(3)) == {
    ("A", "2021-01-01", "sushi"), ("A", "2021-01-01", "curry"),
    ("B", "2021-01-01", "curry"), ("C", "2021-01-01", "ramen")}
assert results(4) == [("ramen", 8)]
assert set(results(5)) == {("A", "ramen", 3), ("B", "sushi", 2),
    ("B", "curry", 2), ("B", "ramen", 2), ("C", "ramen", 3)}
assert set(results(6)) == {("A", "curry"), ("B", "sushi")}
assert set(results(7)) == {("A", "sushi", "2021-01-01"),
    ("A", "curry", "2021-01-01"), ("B", "sushi", "2021-01-04")}
assert set(results(8)) == {("A", 2, 25), ("B", 3, 40)}
assert dict(results(9)) == {"A": 860, "B": 940, "C": 360}
# Add a join-date purchase tied with A's curry to verify inclusion and tie handling.
db.execute("INSERT INTO sales VALUES ('A', '2021-01-07', 1)")
assert ("A", "sushi") in results(6) and ("A", "curry") in results(6)
print("PASS: queries 1-9 sample results; same-day ties; join-date inclusion.")
print("NOT RUN: query 10 requires PostgreSQL.")
