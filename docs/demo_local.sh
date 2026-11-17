#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

echo "== Preparando entorno virtual =="
if command -v python.exe >/dev/null 2>&1; then
  PYTHON=python.exe
elif command -v python3 >/dev/null 2>&1; then
  PYTHON=python3
else
  PYTHON=python
fi

"$PYTHON" -m venv .venv-demo

if [ -x .venv-demo/Scripts/python.exe ]; then
  VENV_PY=.venv-demo/Scripts/python.exe
  DETECT_SECRETS=.venv-demo/Scripts/detect-secrets.exe
  SEMGREP=.venv-demo/Scripts/semgrep.exe
else
  VENV_PY=.venv-demo/bin/python
  DETECT_SECRETS=.venv-demo/bin/detect-secrets
  SEMGREP=.venv-demo/bin/semgrep
fi

"$VENV_PY" -m pip install --quiet --upgrade pip
"$VENV_PY" -m pip install --quiet detect-secrets semgrep

restore_vulnerable() {
  cp docs/referencia/app_vulnerable.py app/app.py
  cp docs/referencia/config_vulnerable.ts frontend/src/config.ts
}

show_findings() {
  "$VENV_PY" - "$1" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as report:
    data = json.load(report)

print(json.dumps(data["results"], indent=2, ensure_ascii=False))
sys.exit(1 if data["results"] else 0)
PY
}

scan_secrets() {
  "$DETECT_SECRETS" scan --all-files app/ frontend/src/ > .venv-demo/secrets-report.json
  show_findings .venv-demo/secrets-report.json
}

scan_sast() {
  "$SEMGREP" --config=.semgrep/sql-injection.yml app/app.py --error --quiet
}

trap restore_vulnerable EXIT
restore_vulnerable

echo
echo "== 1) Secret scanning sobre la versión VULNERABLE (API + landing) =="
if scan_secrets; then
  echo "✅ sin secretos"
else
  echo "❌ PIPELINE FALLARÍA: se encontraron secretos harcodeados"
fi

echo
echo "== 2) SAST sobre la versión VULNERABLE =="
if scan_sast; then
  echo "✅ sin hallazgos"
else
  echo "❌ PIPELINE FALLARÍA: inyección SQL detectada"
fi

echo
echo "== Ahora la versión CORREGIDA =="
cp docs/referencia/app_corregida.py app/app.py
cp docs/referencia/config_corregido.ts frontend/src/config.ts

echo
echo "== 1) Secret scanning sobre la versión CORREGIDA =="
if scan_secrets; then
  echo "✅ sin secretos — el pipeline pasaría"
else
  echo "❌ aún hay secretos"
fi

echo
echo "== 2) SAST sobre la versión CORREGIDA =="
if scan_sast; then
  echo "✅ sin hallazgos — el pipeline pasaría"
else
  echo "❌ aún hay inyección SQL"
fi

echo
echo "El script restaura el estado vulnerable al terminar, listo para la demo."
