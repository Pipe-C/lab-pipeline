# Guía de demostración — DevSecOps Lab

Todo lo necesario para preparar, ensayar y ejecutar la demo de 20 minutos.
Los comandos de PowerShell son para Windows; los de `bash` funcionan en Git
Bash, Linux o macOS.

## 0. Estado esperado del repo

Antes de empezar, el código debe estar **vulnerable**:

- `app/app.py` con `PAYMENTS_API_KEY = "…"` y la SQL concatenada.
- `frontend/src/config.ts` con la misma clave harcodeada.
- `docs/referencia/` con las cuatro copias (dos vulnerables, dos corregidas).

Comprueba lo que tienes pendiente:

```powershell
git status --short
git diff --stat
```

## 1. Preparar variables de entorno

Las plantillas se versionan; los archivos con valores reales no:

```powershell
Copy-Item .env.example .env
Copy-Item frontend\.env.example frontend\.env
git check-ignore -v .env frontend\.env
```

Salida esperada: Git confirma que ambos `.env` están ignorados. Las plantillas
`.env.example` sí aparecen en `git status` y deben subirse.

Si quieres cargar la variable solo en la sesión actual de PowerShell, sin
comillas alrededor del valor (eso evita el falso positivo de `detect-secrets`
en comentarios de ejemplo):

```powershell
$env:PAYMENTS_API_KEY = valor-local-de-prueba
```

La API corregida también lee `.env` automáticamente mediante `python-dotenv`.

## 2. Preparar la landing

```powershell
cd frontend
npm ci
npm run dev
```

Abre `http://localhost:5173`. Debe verse una landing sobria con el panel
"Estado actual del código" en rojo: origen `hardcodeado en
frontend/src/config.ts` y clave enmascarada.

Verificaciones adicionales:

```powershell
npm run build
npm audit --omit=dev
npx impeccable detect src index.html
```

`npm audit --omit=dev` da 0 vulnerabilidades. `npm audit` completo reporta un
aviso de desarrollo en `picomatch` (transitivo de Vite, sin versión corregida
publicada a la fecha); no se incluye en el bundle ni afecta a la demo.

Vuelve a la raíz:

```powershell
cd ..
```

## 3. Ensayar la demo sin red

En Git Bash (el script es `bash`, no PowerShell):

```bash
bash docs/demo_local.sh
```

El script:

1. Instala `detect-secrets` y `semgrep` en `.venv-demo` (ignorado por Git).
2. Escanea `app/` **y** `frontend/src/` en estado vulnerable: ❌ en ambos.
3. Copia las dos versiones corregidas y repite: ✅ en ambos.
4. Restaura automáticamente el estado vulnerable al terminar.

Comprueba la restauración:

```powershell
git diff --stat -- app/app.py frontend/src/config.ts
```

Sin salida = todo listo para la clase.

## 4. Preparar GitHub

El repo es público (`Pipe-C/lab-pipeline`). El secreto de ejemplo es genérico,
así que el *push protection* de GitHub no bloquea el `git push`; quien falla es
el pipeline propio.

1. Sube el estado vulnerable con los commits de la sección 6.
2. Entra a **Actions** y habilita los workflows si aparece el botón de
   confirmación.
3. Espera el primer run rojo y abre los dos jobs. Deben aparecer:
   - detect-secrets: hallazgos en `app/app.py` y `frontend/src/config.ts`.
   - Semgrep: inyección SQL en `app/app.py`.
4. Graba un video corto de respaldo por si falla la red del salón.

## 5. En clase, paso a paso

1. Muestra la landing con `npm run dev` y señala el panel en rojo.
2. Abre `app/app.py` y `frontend/src/config.ts` en el editor.
3. Abre el run rojo en **Actions** y lee los hallazgos en voz alta.
4. Corrige en vivo:

   ```bash
   cp docs/referencia/app_corregida.py app/app.py
   cp docs/referencia/config_corregido.ts frontend/src/config.ts
   ```

5. Sube:

   ```bash
   git add -A
   git commit -m "fix(security): externalizar secreto y parametrizar consulta SQL"
   git push
   ```

6. Recarga la landing: ahora dice "Estado corregido" y "no disponible en el
   bundle".
7. Espera 20–40 s y muestra el run verde en **Actions**.
8. Si falla la red: `bash docs/demo_local.sh` y explica la misma salida ❌/✅.

## 6. Commits sugeridos

El orden importa: primero los cambios que dejan el repo vulnerable y con la
landing lista; el commit de corrección se hace **durante** la demo.

```bash
git status --short
git diff --stat

git add .gitignore README.md sonar-project.properties docs/GUION_EXPOSICION.md docs/GUIA_DEMO.md docs/prompts
git commit -m "docs: actualiza guion, guía de demo y prompts para repo público"

git add frontend/package.json frontend/package-lock.json frontend/tsconfig.json frontend/index.html frontend/src frontend/.env.example
git commit -m "feat(frontend): añade landing Vite para la demo de secret scanning"

git add .env.example .github/workflows/devsecops.yml docs/demo_local.sh app/requirements.txt docs/referencia
git commit -m "ci: escanea secretos en backend y frontend con ejemplos de entorno"

git add -A
git commit -m "fix(security): externalizar secreto y parametrizar consulta SQL"
git push
```

Antes de cada `git add`, revisa que `.env` y `frontend/.env` **no** aparezcan
en `git status`. Si aparecen, detente: están mal ignorados.

## 7. Checklist final

- [ ] `npm run dev` abre la landing sin errores en consola.
- [ ] La landing muestra "Estado vulnerable" antes del fix y "Estado
      corregido" después.
- [ ] `npm run build` pasa.
- [ ] `npx impeccable detect frontend/src frontend/index.html` sin hallazgos.
- [ ] `bash docs/demo_local.sh` muestra ❌/✅ y restaura el estado vulnerable.
- [ ] `git check-ignore -v .env frontend\.env` confirma que no se suben.
- [ ] El run de GitHub está rojo antes del fix y verde después.
- [ ] Los dos prompts `.md` están en `docs/prompts/`.
- [ ] El ZIP incluye las plantillas `.env.example` y los `.env` locales
      ignorados.
