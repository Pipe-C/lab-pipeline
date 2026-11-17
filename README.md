# Laboratorio DevSecOps — Automatización de pruebas de seguridad en CI/CD

Tema 7 de la exposición: **Automatización de Pruebas de Seguridad en
Pipelines CI/CD**. Un pipeline de GitHub Actions que bloquea el cambio
automáticamente cuando el código trae un secreto harcodeado o una falla de
seguridad básica (inyección SQL), usando dos herramientas reales:
**detect-secrets** (análisis de secretos) y **Semgrep** (SAST).

La demo tiene dos piezas visibles: una API Flask mínima y una landing Vite +
TypeScript que se abre con `npm run dev`. El mismo secreto de ejemplo aparece
en ambas a propósito, para que el escaneo de secretos muestre hallazgos en
backend y frontend.

## Por qué GitHub Actions y no Jenkins

Para una demo en vivo de 10–12 minutos, **GitHub Actions** es la opción más
segura: no hay nada que instalar ni un servidor que mantener vivo; el
pipeline corre en la nube de GitHub en cuanto haces `git push`, y el
resultado (✅/❌) aparece solo en la pestaña **Actions** del repositorio.
Jenkins exige instalar y configurar un servidor (Java, plugins, un agente),
lo cual añade un punto de falla justo el día de la sustentación. Si de verdad
quieres mostrar Jenkins porque lo pide el docente, la sección "Alternativa
con Jenkins" de `docs/GUION_EXPOSICION.md` explica cómo adaptar este mismo
pipeline.

## Qué contiene

```
app/app.py                          API vulnerable: secreto + inyección SQL
app/requirements.txt                Flask + python-dotenv
frontend/                           Landing Vite + TypeScript (npm run dev)
frontend/src/config.ts              Estado vulnerable: clave harcodeada
frontend/.env.example               Plantilla pública de Vite (sin secretos)
.env.example                        Plantilla del servidor (sin secretos reales)
.github/workflows/devsecops.yml     Pipeline: detect-secrets + Semgrep (+ SonarQube opcional)
.semgrep/sql-injection.yml          Regla propia de Semgrep, sin depender de internet
sonar-project.properties            Config de SonarQube Cloud (rellenar antes de usarlo)
docs/referencia/app_vulnerable.py   Copia vulnerable de la API
docs/referencia/app_corregida.py    Copia corregida de la API
docs/referencia/config_vulnerable.ts  Copia vulnerable de la landing
docs/referencia/config_corregido.ts   Copia corregida de la landing
docs/demo_local.sh                  Misma demo en local, sin depender de la red
docs/GUIA_DEMO.md                   Guía paso a paso de preparación y ejecución
docs/GUION_EXPOSICION.md            Guion minuto a minuto de los 3 bloques
docs/prompts/                       Dos prompts para agentes (pipeline y laboratorio)
```

`app/app.py` y `frontend/src/config.ts` empiezan en estado vulnerable:

1. Credencial de pasarela de pagos escrita en el código, con formato genérico
   a propósito (no AWS/Stripe/GitHub) para que el *push protection* de GitHub
   no interfiera en un repo público.
2. Una consulta SQL construida por concatenación (`"...'" + name + "'"`),
   inyección SQL clásica detectada por Semgrep.

## Variables de entorno: cómo sí hacerlo

- `.env.example` y `frontend/.env.example` son plantillas versionadas. Solo
  contienen marcadores de posición, sin comillas alrededor del valor: así
  `detect-secrets` no confunde un ejemplo con una credencial real.
- `.env` y `frontend/.env` están en `.gitignore`. Ahí sí van los valores
  locales reales, que nunca se suben.
- En PowerShell puedes cargar la variable del servidor sin comillas en el
  comando: `$env:PAYMENTS_API_KEY = valor-local-de-prueba`. La API corregida
  también carga `.env` automáticamente con `python-dotenv`.
- Las variables `VITE_*` del frontend se incrustan en el bundle y son
  **públicas**. Por eso la clave de pagos nunca debe vivir ahí: la lee solo el
  backend desde su entorno.

## Cómo probarlo antes de clase

La secuencia completa, con todos los comandos, está en `docs/GUIA_DEMO.md`.
Resumen:

### En GitHub (lo que se muestra al profesor)

1. El repositorio es público (`Pipe-C/lab-pipeline`). Eso es seguro aquí
   porque no hay credenciales reales ni datos privados.
2. Sube el estado vulnerable. El workflow falla (❌) en detect-secrets y
   Semgrep; en la pestaña **Actions** verás los hallazgos de la API y de la
   landing.
3. Abre la landing en local:

   ```bash
   cd frontend
   npm ci
   npm run dev
   ```

4. En clase, copia las dos correcciones y vuelve a subir:

   ```bash
   cp docs/referencia/app_corregida.py app/app.py
   cp docs/referencia/config_corregido.ts frontend/src/config.ts
   git add -A
   git commit -m "fix(security): externalizar secreto y parametrizar consulta SQL"
   git push
   ```

5. El mismo workflow ahora pasa (✅). La landing muestra "Estado corregido" y
   "Sin secretos en el bundle".

### En tu máquina (plan de contingencia)

```bash
bash docs/demo_local.sh
```

Corre los mismos dos escáneres sobre la versión vulnerable y luego sobre la
corregida, imprime ❌/✅ y al terminar restaura el estado vulnerable para que
el repo quede listo para la demostración.

## Créditos de las herramientas

- [detect-secrets](https://github.com/Yelp/detect-secrets) (Yelp, código
  abierto): escaneo de secretos.
- [Semgrep](https://semgrep.dev/) (open source): SAST, con una regla propia
  (`.semgrep/sql-injection.yml`) que no depende de la red, más el registro
  público `p/owasp-top-ten` cuando corre en GitHub Actions.
- [Vite](https://vite.dev/) y TypeScript para la landing de ejemplo.
- [Impeccable](https://impeccable.style/) como referencia de diseño de la
  landing; el detector `npx impeccable detect` pasa sin hallazgos.
