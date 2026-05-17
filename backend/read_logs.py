import sqlite3

# Connect to the database
conn = sqlite3.connect("aegis_audit.db")
cursor = conn.cursor()

# Capture the logs (ID, User, Secure?, Captured Assets, Masked Text)
cursor.execute("SELECT id, user_id, is_secure, detected_entities FROM audit_logs")
loglar = cursor.fetchall()

print("\n AEGIS-DLP Security Logs")
print("-" * 60)
for log in loglar:
    status = " SECURE" if log[2] else " LEAK DETECTED"
    print(f"ID: {log[0]} | User: {log[1]} | Status: {status}")
    print(f"Captured Data: {log[3]}")
    print("-" * 60)