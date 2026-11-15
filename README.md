# Laboratorio DevSecOps — Automatización de pruebas de seguridad en CI/CD

Tema 7 de la exposición: **Automatización de Pruebas de Seguridad en
Pipelines CI/CD**. Un pipeline de GitHub Actions que bloquea el despliegue
automáticamente cuando el código trae un secreto harcodeado o una falla de
seguridad básica (inyección SQL), usando dos herramientas reales:
**detect-secrets** (análisis de secretos) y **Semgrep** (SAST).

## Por qué GitHub Actions y no Jenkins

Para una demo en vivo de 10–12 minutos, **GitHub Actions** es la opción más
segura: no hay nada que instalar ni un servidor que mantener vivo — el
pipeline corre en la nube de GitHub en cuanto haces `git push`, y el
resultado (✅/❌) aparece solo en la pestaña **Actions** del repositorio.
Jenkins exige instalar y configurar un servidor (Java, plugins, un agente),
lo cual añade un punto de falla justo el día de la sustentación y consume
minutos de tus 10–12 disponibles solo en arrancarlo. Si de verdad quieres
mostrar Jenkins porque lo pide el docente o por aprendizaje, la sección
"Alternativa con Jenkins" de `docs/GUION_EXPOSICION.md` explica cómo adaptar
exactamente este mismo pipeline.

## Qué contiene

```
app/app.py                   La app "en vivo": arranca en versión vulnerable
app/requirements.txt
.github/workflows/devsecops.yml   El pipeline: detect-secrets + Semgrep
.semgrep/sql-injection.yml        Regla propia de Semgrep (no depende de internet)
docs/referencia/app_vulnerable.py Copia de referencia (fuera de app/, nunca se escanea)
docs/referencia/app_corregida.py  Copia de referencia ya corregida
docs/demo_local.sh                Plan de contingencia: la misma demo, en tu máquina
docs/GUION_EXPOSICION.md          Guion minuto a minuto para los 3 bloques de la exposición
```

`app/app.py` empieza en su estado **vulnerable** (dos fallas a propósito):

1. Credenciales de AWS harcodeadas en el código (`AWS_ACCESS_KEY_ID`,
   `AWS_SECRET_ACCESS_KEY`).
2. Una consulta SQL construida por concatenación de strings
   (`"...'" + name + "'"`), inyección SQL clásica.

## Cómo probarlo tú mismo antes de la clase

### Opción A — en GitHub (lo que vas a mostrar al profesor)

0. **Crea el repositorio como privado.** GitHub tiene su propia protección
   ("push protection para usuarios"), activada por defecto en toda cuenta,
   que bloquea el `git push` mismo —antes de que corra tu pipeline— si
   detecta un secreto con formato de un proveedor conocido (AWS, Stripe,
   etc.), pero **solo en repositorios públicos**. Si el repo es privado,
   esa protección no actúa, y el que atrapa el secreto es tu propio
   pipeline (`detect-secrets` + Semgrep) — que es justo lo que quieres
   mostrar. Por eso además el secreto de ejemplo (`PAYMENTS_API_KEY`) usa
   un formato genérico y no uno de un proveedor real: así, aunque alguien
   use el repo como público, GitHub no interfiere con la demo.
1. Sube esta carpeta completa
   (`git init && git add -A && git commit -m "estado vulnerable" && git push`).
2. Ve a la pestaña **Actions** de tu repositorio: el workflow
   "DevSecOps — SAST y Secret Scanning" corre solo y **falla** (❌) en los
   dos jobs — ese es tu "Bloque 2" en vivo.
3. Reemplaza el contenido de `app/app.py` por el de
   `docs/referencia/app_corregida.py`, haz commit y push de nuevo.
4. Vuelve a la pestaña Actions: el mismo workflow ahora **pasa** (✅) —
   ese es tu "Bloque 3".

### Opción B — en tu máquina (plan de contingencia)

```bash
bash docs/demo_local.sh
```

Corre exactamente los mismos dos escáneres, en el mismo orden, sobre la
versión vulnerable y luego sobre la corregida, e imprime ❌/✅ igual que lo
haría GitHub Actions. Dura segundos y no depende de la red del salón.

## Créditos de las herramientas

- [detect-secrets](https://github.com/Yelp/detect-secrets) (Yelp, código
  abierto) — escaneo de secretos.
- [Semgrep](https://semgrep.dev/) (open source) — SAST, con una regla propia
  (`.semgrep/sql-injection.yml`) que no depende de la red, más el registro
  público `p/owasp-top-ten` cuando corre en GitHub Actions (si el salón de
  clase sí tiene internet).
