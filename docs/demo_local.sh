#!/usr/bin/env bash
# Reproduce la misma demo que corre en GitHub Actions, pero en tu máquina.
# Úsalo como plan de contingencia si la red del salón falla, o para
# ensayar antes de la sustentación.
set -e

cd "$(dirname "$0")/.."

echo "== Preparando entorno virtual =="
python3 -m venv .venv-demo 2>/dev/null || true
./.venv-demo/bin/pip install --quiet --upgrade pip
./.venv-demo/bin/pip install --quiet detect-secrets semgrep

echo
echo "== 1) Escaneo de secretos (detect-secrets) sobre la versión VULNERABLE =="
cp docs/referencia/app_vulnerable.py app/app.py
./.venv-demo/bin/detect-secrets scan --all-files app/ | python3 -c "
import json, sys
d = json.load(sys.stdin)
print(json.dumps(d['results'], indent=2, ensure_ascii=False))
sys.exit(1 if d['results'] else 0)
" && echo "✅ sin secretos" || echo "❌ PIPELINE FALLARÍA: se encontraron secretos harcodeados"

echo
echo "== 2) Análisis estático (Semgrep) sobre la versión VULNERABLE =="
./.venv-demo/bin/semgrep --config=.semgrep/sql-injection.yml app/app.py --error \
  && echo "✅ sin hallazgos" || echo "❌ PIPELINE FALLARÍA: inyección SQL detectada"

echo
echo "== Ahora la versión CORREGIDA =="
cp docs/referencia/app_corregida.py app/app.py

echo
echo "== 1) Escaneo de secretos sobre la versión CORREGIDA =="
./.venv-demo/bin/detect-secrets scan --all-files app/ | python3 -c "
import json, sys
d = json.load(sys.stdin)
print(json.dumps(d['results'], indent=2, ensure_ascii=False))
sys.exit(1 if d['results'] else 0)
" && echo "✅ sin secretos — el pipeline pasaría" || echo "❌ aún hay secretos"

echo
echo "== 2) Semgrep sobre la versión CORREGIDA =="
./.venv-demo/bin/semgrep --config=.semgrep/sql-injection.yml app/app.py --error \
  && echo "✅ sin hallazgos — el pipeline pasaría" || echo "❌ aún hay inyección SQL"
