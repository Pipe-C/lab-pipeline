"""
API mínima de ejemplo para el laboratorio de DevSecOps (SAST + Secret Scanning).

Este archivo contiene, A PROPÓSITO, dos fallas que un pipeline de CI/CD
debería atrapar antes de llegar a producción:

  1. Una API key "harcodeada" (secreto en texto plano en el código).
  2. Una consulta SQL construida por concatenación (inyección SQL),
     el mismo tipo de hallazgo que un SAST como Semgrep marca.

Nota: el secreto de abajo usa un formato GENÉRICO a propósito (no el de
AWS/Stripe/GitHub/etc.) para que el push protection nativo de GitHub
—que bloquea por defecto los formatos de proveedores conocidos en repos
públicos— no interfiera con la demo. El que debe atraparlo es NUESTRO
pipeline (detect-secrets + Semgrep), no el de GitHub.
"""
import sqlite3
from flask import Flask, request

app = Flask(__name__)

# --- Falla 1: secreto harcodeado (lo detecta detect-secrets / gitleaks) ---
PAYMENTS_API_KEY = "cw9Lq3Xz7Hb2Vn5Rt8Yp1Ma4Kd6Jf0Se3Gh7Ux9"

@app.route("/customers")
def search_customers():
    name = request.args.get("name", "")
    conn = sqlite3.connect(":memory:")
    cur = conn.cursor()
    cur.execute("CREATE TABLE customers (id INTEGER, name TEXT)")
    cur.execute("INSERT INTO customers VALUES (1, 'Distribuidora Andina')")

    # --- Falla 2: SQL armado por concatenación (lo detecta Semgrep) ---
    query = "SELECT * FROM customers WHERE name = '" + name + "'"
    cur.execute(query)
    return {"results": cur.fetchall()}


if __name__ == "__main__":
    app.run(debug=True)
