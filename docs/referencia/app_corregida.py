"""
Versión corregida de la API de ejemplo (DevSecOps — SAST + Secret Scanning).

Correcciones:
  1. El secreto ya no vive en el código: se lee de una variable de entorno.
  2. La consulta SQL usa un parámetro (placeholder) en vez de concatenación.
"""
import os
import sqlite3
from flask import Flask, request
from dotenv import load_dotenv

app = Flask(__name__)
load_dotenv()

PAYMENTS_API_KEY = os.environ.get("PAYMENTS_API_KEY")

if not PAYMENTS_API_KEY:
    raise RuntimeError("Configura PAYMENTS_API_KEY antes de iniciar la API")


@app.route("/customers")
def search_customers():
    name = request.args.get("name", "")
    conn = sqlite3.connect(":memory:")
    cur = conn.cursor()
    cur.execute("CREATE TABLE customers (id INTEGER, name TEXT)")
    cur.execute("INSERT INTO customers VALUES (1, 'Distribuidora Andina')")
    cur.execute("SELECT * FROM customers WHERE name = ?", (name,))
    return {"results": cur.fetchall()}


if __name__ == "__main__":
    app.run(debug=True)
