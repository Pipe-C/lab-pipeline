# Guion de exposición — Tema 7: DevSecOps en pipelines CI/CD

20 minutos totales. Mapeado 1:1 a la rúbrica (dominio conceptual 20%,
demo práctica 50%, remediación 15%, participación y tiempo 15%).

## Antes de entrar a clase

- [ ] Repositorio creado en GitHub (idealmente privado; si terminas en
      público —como pasó con `Pipe-C/lab-pipeline`, porque SonarQube no
      dejaba dar acceso selectivo a un repo privado, sigue siendo seguro:
      ver nota en la sección A, paso 2), con este contenido subido y el
      workflow ya corriendo al menos una vez (para que no haya sorpresas de
      permisos el día de la demo).
- [ ] `app/app.py` en su estado **vulnerable** (el que trae por defecto).
- [ ] `bash docs/demo_local.sh` probado al menos una vez en tu máquina.
- [ ] `cd frontend && npm ci && npm run dev` probado: la landing abre y
      muestra "Estado vulnerable" con la clave enmascarada.
- [ ] El deck de 7 diapositivas abierto y probado, y el deck introductorio
      de 5 diapositivas sobre "qué es un pipeline" (sección E) también
      generado y revisado.
- [ ] Video corto de respaldo grabado (tú mismo ejecutando la demo),
      por si falla la red del salón — la guía lo pide explícitamente.
- [ ] Asignar quién habla en cada bloque (participación equitativa = 15%
      de la nota).

## Preparación detallada, con comandos exactos

### A. La noche anterior o esa misma mañana, en tu casa

1. **Crear el repositorio en GitHub** (en el navegador):
   - Entra a github.com → botón **"+"** arriba a la derecha → **"New
     repository"**.
   - Nombre: `devsecops-lab` (o el que prefieras).
   - Marca **Private** si puedes. Si vas a conectar SonarQube Cloud y no
     te deja dar acceso selectivo a un repo privado (pasa con algunas
     cuentas), pasarlo a **Public** es seguro en este proyecto puntual:
     el secreto de ejemplo usa un formato genérico, no uno de un proveedor
     real, así que el push protection de GitHub (que solo bloquea
     formatos reconocidos como AWS/Stripe/etc. en repos públicos) no
     interfiere, y tampoco borra nada de lo que ya subiste. Lo único que
     cambia es que el código queda visible para cualquiera — sin problema
     aquí porque no hay secretos ni datos reales, solo no repitas el mismo
     secreto o estructura en un proyecto tuyo de verdad.
   - Deja todo lo demás sin marcar (sin README, sin .gitignore, sin
     licencia — ya los traes en la carpeta).
   - Click **"Create repository"**. GitHub te muestra una URL como
     `https://github.com/TU-USUARIO/devsecops-lab.git` — cópiala.

2. **Subir el contenido por primera vez** (en tu terminal, dentro de la
   carpeta `devsecops-lab` que descomprimiste):
   ```bash
   cd ruta/a/devsecops-lab
   git init
   git branch -M main
   git remote add origin https://github.com/TU-USUARIO/devsecops-lab.git
   git add -A
   git commit -m "estado inicial: app con secreto harcodeado e inyeccion SQL"
   git push -u origin main
   ```
   La primera vez, `git push` te va a pedir usuario y contraseña — pero
   **GitHub ya no acepta tu contraseña normal por este medio**. Dos
   formas simples de resolverlo, elige una:
   - **GitHub CLI (más fácil):** instala `gh` (https://cli.github.com/),
     corre `gh auth login` una vez, sigue las instrucciones en pantalla
     (abre el navegador, confirmas), y después `git push` ya funciona
     solo.
   - **Token de acceso personal:** en GitHub, ve a tu foto de perfil →
     **Settings** → **Developer settings** → **Personal access tokens**
     → **Tokens (classic)** → **Generate new token (classic)** → marca el
     permiso **repo** → **Generate token** → copia el token (solo se
     muestra una vez). Cuando `git push` te pida "Password", pega ahí el
     token (no tu contraseña de GitHub).

3. **Confirmar que el pipeline corrió y falló** (en el navegador): entra a
   tu repositorio → pestaña **Actions**. La primera vez puede aparecer un
   botón **"I understand my workflows, go ahead and enable them"** —
   dale click (así no pierdes ese paso en vivo frente al profesor).
   Espera 20–40 segundos y refresca: debe aparecer un run con una ❌ roja.
   Entra a ese run, abre los dos jobs ("Escaneo de secretos" y "Análisis
   estático") y confirma que cada uno señala exactamente el hallazgo
   esperado (la API key y la inyección SQL).

4. **No corrijas el código todavía** — deja el repositorio tal cual, en
   este estado vulnerable con su primer run ya en rojo. Ese ❌ ya generado
   es justo lo que vas a mostrar en clase.

5. Ten a mano, ya revisado, el contenido de `docs/referencia/app_corregida.py`
   (ábrelo en una pestaña o en tu editor) para no perder tiempo en clase.

### B. ¿Qué pasa exactamente cuando hagas `git push` del código vulnerable?

Para resolver tu duda concreta: con el repo en privado, o en público con
el secreto en **formato genérico** (como ya quedó en este proyecto), el
`git push` **no va a mostrarte ningún error en la terminal** — sube sin problema, en menos
de un segundo. El "error" que vas a mostrar no aparece en la terminal:
aparece como la ❌ roja en la pestaña **Actions** del navegador, 20–40
segundos después del push, porque ahí es donde corre tu propio pipeline
(no una protección de GitHub).

El único error de terminal que sí podrías ver —y que no tiene nada que ver
con el laboratorio— es de autenticación, si el token o `gh auth login` no
quedaron bien configurados. El mensaje se ve así:
```
remote: Support for password authentication was removed...
fatal: Authentication failed for 'https://github.com/...'
```
Si ves eso, el problema es el paso 2 de arriba (token/gh CLI), no las
vulnerabilidades.

### C. En clase, el momento de la demo (ya con el repo listo del paso A)

1. **(1 min)** Abre la landing (`cd frontend && npm run dev`) y señala el
   panel "Estado actual del código": la clave aparece enmascarada y el
   origen dice "hardcodeado en frontend/src/config.ts". Es el gancho visual.
2. **(1 min)** Abre `app/app.py` y `frontend/src/config.ts` en el editor,
   lado a lado con GitHub en el navegador. Señala la clave en ambos y la
   consulta SQL concatenada en la API.
3. **(1 min)** Abre la pestaña **Actions** de tu repositorio: ahí está el
   run que ya falló antes de clase. Click en él.
4. **(3–4 min)** Entra al job **"Escaneo de secretos (detect-secrets)"**,
   expande el paso "Escanear en busca de secretos harcodeados" y lee en
   voz alta lo que el log reporta: dos archivos, tipo de secreto y línea.
   Repite con el job **"Análisis estático (Semgrep)"** y lee el mensaje sobre
   la inyección SQL. Explica: "esto lo encontró el pipeline solo, sin que
   nadie lo ejecutara a mano, antes de que el código llegara a producción."
5. **(1 min)** En tu terminal, con la clase viendo tu pantalla, corrige el
   código:
   ```bash
   cp docs/referencia/app_corregida.py app/app.py
   cp docs/referencia/config_corregido.ts frontend/src/config.ts
   ```
6. **(1 min)** Sube la corrección:
   ```bash
   git add -A
   git commit -m "fix(security): externalizar secreto y parametrizar consulta SQL"
   git push
   ```
7. **(2–3 min)** Vuelve al navegador, pestaña Actions: espera 20–40
   segundos y refresca — aparece un nuevo run, esta vez con ✅ verde en los
   dos jobs. Muestra también la landing recargada: ahora dice "Estado
   corregido" y "no disponible en el bundle".
8. **Si algo falla en vivo** (red del salón, GitHub lento): corre
   `bash docs/demo_local.sh` en tu terminal — hace exactamente lo mismo,
   sin depender de internet, y muestra ❌/✅ en segundos. Al terminar deja el
   estado vulnerable restaurado.

## D. Añadir SonarQube Cloud como tercer escáner (opcional, no bloqueante)

La guía del tema sugiere SonarQube como una de las herramientas posibles.
El workflow (`devsecops.yml`) ya trae el tercer job listo
(`sonarqube-scan`), pero está marcado como **opcional y no bloqueante**: si
no hay `SONAR_TOKEN` o la organización no está configurada, el job se omite
o falla sin poner rojo el pipeline. Los dos escáneres que sí deciden el
resultado son detect-secrets y Semgrep.
Importante: el nombre cambió hace poco (antes
"SonarCloud"), y la Action vieja (`sonarcloud-github-action`) está
deprecada — el workflow ya usa la correcta (`SonarSource/sonarqube-scan-action`).

1. Ve a **https://sonarqube.com** (o directamente **sonarcloud.io**, que
   redirige ahí) → **"Sign up"** → elige **"With GitHub"** → autoriza.
2. Te va a pedir importar una organización: elige **Pipe-C** (tu cuenta de
   GitHub) → cuando te pregunte a qué repositorios dar acceso, elige
   **"Only select repositories"** y marca solo `lab-pipeline` (no le des
   acceso a todos tus repos).
3. Selecciona el repositorio para analizar. Cuando te pregunte el método
   de análisis, elige **"With GitHub Actions"** (no "Automatic Analysis"
   — quieres que corra dentro de tu propio pipeline, no por fuera).
4. SonarQube Cloud te muestra en pantalla tres cosas — cópialas:
   - Un **token** (secreto, solo se muestra una vez).
   - Tu **Project Key** (algo como `Pipe-C_lab-pipeline`).
   - Tu **Organization Key** (algo como `pipe-c`).
5. Guarda el token como secreto en GitHub: en tu repositorio →
   **Settings** → **Secrets and variables** → **Actions** → **"New
   repository secret"** → Name: `SONAR_TOKEN` → Value: pega el token →
   **"Add secret"**.
6. Abre `sonar-project.properties` (en la raíz del repo) y reemplaza
   `<TU_PROJECT_KEY>` y `<TU_ORGANIZACION>` por los valores del paso 4.
7. Haz commit y push de ese archivo:
   ```bash
   git add sonar-project.properties
   git commit -m "ci: agregar analisis de SonarQube Cloud"
   git push
   ```
8. Entra de nuevo a la pestaña **Actions**: ahora deberías ver **3 jobs**
   corriendo (secret-scan, sast-scan, sonarqube-scan). El de SonarQube
   tarda un poco más (incluye subir el reporte a la nube). Si el Quality
   Gate de SonarQube marca "Failed" (por el mismo secreto y la misma
   inyección SQL — SonarQube también los detecta con sus propias reglas,
   `python:S2068` y `python:S2077`), el job queda en rojo igual que los
   otros dos.

**Nota de honestidad:** esto no lo pude probar yo mismo de punta a punta
—SonarQube Cloud exige una cuenta y un token propios, que no tengo—, así
que pruébalo tú una vez, igual que hiciste con el resto, **antes** de la
clase. Si algo no calza (nombre de job, versión de la Action), el enlace
oficial de la Action es https://github.com/SonarSource/sonarqube-scan-action
y ahí está la versión más reciente.

**¿Vale la pena para la demo en vivo?** Si ya tienes GitHub Actions
funcionando con los otros dos escáneres, SonarQube sí suma —especialmente
para el 20% de "dominio conceptual" (mostrar que distintas herramientas
convergen en los mismos hallazgos con reglas propias). Para los 10-12 min
del Bloque 2, considera si prefieres gastar ese tiempo en 2 herramientas
bien explicadas o 3 más rápido — con 3 jobs corriendo, la corrida completa
tarda más (SonarQube sube datos a la nube), así que practica el tiempo.

## E. Deck introductorio — "¿Qué es un pipeline?" (5 diapositivas, antes del Bloque 1)

Para que el Bloque 1 no empiece directo en SAST/secret scanning sin dar
contexto, agrega un mini-deck de 5 diapositivas genéricas sobre pipelines
CI/CD (qué son, para qué sirven, qué beneficios dan), generado con una IA
de diapositivas. Prompt listo para pegar:

```
Crea una presentación de exactamente 5 diapositivas, en español, para una
exposición universitaria de Seguridad Informática (nivel pregrado). El
público ya conoce qué es un pipeline de CI/CD; estas diapositivas son el
complemento introductorio antes de entrar en detalle, así que deben
explicar el concepto en general sin profundizar aún en seguridad.

Tema: "¿Qué es un pipeline de CI/CD, para qué sirve y qué beneficios
ofrece?"

Estructura exacta:

1. Portada: título "Pipelines CI/CD: la línea de ensamblaje del software",
   con un subtítulo breve.

2. "¿Qué es un pipeline?" — definición en una sola frase (una secuencia
   automatizada de pasos que lleva el código desde que un desarrollador lo
   escribe hasta que llega a producción) + un diagrama de flujo simple con
   estas etapas en cajas conectadas por flechas: Commit → Build → Test →
   Scan → Deploy. Nada de párrafos largos.

3. "Pipelines reales que existen hoy" — una tabla o tarjetas comparando 4
   herramientas reales con una frase corta cada una sobre su caso de uso
   típico: Jenkins (self-hosted, el más veterano y configurable), GitHub
   Actions (integrado nativamente en GitHub, el más usado en proyectos
   open source), GitLab CI/CD (integrado en GitLab, fuerte en empresas que
   ya usan esa plataforma), Azure Pipelines / CircleCI (alternativas en la
   nube, buena integración con otros servicios de nube).

4. "¿Para qué sirve en la práctica?" — 3 o 4 bullets cortos (máximo 6
   palabras cada uno): evita errores humanos repetitivos, detecta fallas
   antes de que lleguen al usuario final, acelera el ciclo de entrega,
   deja un registro auditable de cada cambio.

5. "Beneficios clave" — cierre con 3 beneficios concretos y medibles:
   menos tiempo entre escribir código y que esté en producción, bugs
   detectados en minutos en vez de días, y la posibilidad de automatizar
   controles de calidad y seguridad (gancho para conectar con la siguiente
   parte de la exposición, que sí entra en SAST y secret scanning).

Estilo visual: tema oscuro, estética técnica/profesional (no corporativo
genérico ni colorido), tipografía sans-serif limpia, máximo 1 diagrama o
tabla por diapositiva, nada de texto en párrafos largos ni viñetas de más
de una línea, nada de imágenes decorativas sin relación con el contenido.
```

**Dónde encaja en el tiempo:** la guía del laboratorio limita el Bloque 1
completo (fundamento técnico) a **máximo 5 minutos**, y ya lo teníamos
lleno con las 3 diapositivas propias (`cover`, `fundamento`, `flujo`). Si
sumas estas 5 más sin ajustar nada, el Bloque 1 se estira a 8 diapositivas
en 5 minutos (~37 s cada una) — posible, pero exige ir rápido. Dos formas
de resolverlo, elige una:

- **Opción recomendada — fusionar, no sumar tiempo:** usa las 5
  diapositivas nuevas como reemplazo de la diapositiva `cover` propia (que
  ya decías rápido), pasando por ellas en ~15 s cada una (es contenido que
  el público ya conoce en términos generales, así que no te detengas a
  explicar cada tarjeta de la diapositiva 3, solo nómbralas). Eso deja los
  mismos 5 minutos repartidos así: ~1.5 min para las 5 nuevas (repaso
  rápido) + ~2 min en `fundamento` (SAST/secret scanning, lo nuevo de
  verdad) + ~1.5 min en `flujo`.
- **Alternativa:** pide explícitamente al docente si el Bloque 1 puede
  extenderse un poco a costa del cierre/preguntas, ya que es contenido de
  base que facilita entender el resto — pero no asumas que te lo van a
  dar; prepárate para la Opción recomendada de todas formas.

## Bloque 1 — Fundamento técnico (máx. 5 min)

Diapositivas: deck introductorio de la sección E (repaso rápido) →
`cover`, `fundamento`, `flujo`.

Guion:
1. (1–1.5 min) Deck introductorio (sección E): repaso rápido de qué es un
   pipeline, mencionar las herramientas reales (Jenkins, GitHub Actions,
   GitLab CI, etc.) y los beneficios generales — sin detenerte, es
   contexto, no el contenido nuevo.
2. (15 s) Portada propia (`cover`): nombrar el tema específico y las 3
   herramientas que SÍ vas a usar en la demo (detect-secrets, Semgrep,
   SonarQube Cloud).
3. (2 min) "¿Qué es SAST? ¿Qué es secret scanning?" — usar la diapositiva
   `fundamento`, explicar con tus palabras, sin leer.
4. (1.5 min) Diapositiva `flujo`: señalar cada caja mientras hablas —
   "cuando hacemos push, GitHub Actions dispara el pipeline, que corre los
   escáneres, y según el resultado el pipeline queda en verde o en
   rojo — sin que nadie tenga que revisarlo a mano".
5. (1 min) Impacto real: una credencial filtrada (de AWS, de una
   pasarela de pagos, de cualquier servicio) permite a cualquiera usarla
   en nombre de la empresa; una inyección SQL permite leer o borrar toda
   la base de datos.

## Bloque 2 — Demo práctica en vivo (10–12 min)

Diapositivas de apoyo: `demo`, `hallazgos` (se usan rápido, el protagonista
es el navegador con GitHub abierto). El guion comando a comando de este
bloque es la sección **C** de arriba ("En clase, el momento de la demo") —
ya asume que hiciste la preparación de la sección **A** antes de llegar.
Resumen de tiempos: 1 min mostrando la landing vulnerable, 1 min mostrando
el código, 1 min abriendo el run que ya falló, 3–4 min leyendo los hallazgos
en los logs, 1 min corrigiendo, 1 min con el push de la corrección, 2–3 min
mostrando el run en verde y la landing corregida.

## Bloque 3 — Remediación y mitigación (3 min)

Diapositivas: `remediacion`.

1. (1 min) Secreto → variable de entorno: muestra `.env.example` y
   `frontend/.env.example` como plantillas sin valores reales, y recuerda que
   `.env` está en `.gitignore`. Nunca en el código, nunca en el historial de
   Git (si ya se filtró, hay que rotar la credencial, no solo borrarla del
   código). Aclara que las variables `VITE_*` son públicas: la clave de pagos
   solo la lee el backend.
2. (1 min) SQL → consulta parametrizada: el motor de base de datos trata el
   valor como dato, nunca como parte de la sentencia SQL.
3. (1 min) A nivel de arquitectura: "branch protection rules" en GitHub
   para que nadie pueda hacer merge a `main` si el pipeline no pasa — así
   la regla no depende de que un humano se acuerde de revisarla.

## Cierre y preguntas

Diapositiva `cierre`. Deja 2–3 minutos del tiempo total para preguntas del
docente — practica explicar la diferencia entre SAST (analiza el código,
sin ejecutarlo) y DAST (ataca la aplicación corriendo, como hicieron con
OWASP ZAP en el laboratorio anterior) por si la preguntan para conectar
ambos temas.

## Recursos incluidos en el repo

- `docs/GUIA_DEMO.md`: preparación paso a paso, comandos exactos y plan de
  contingencia.
- `docs/prompts/PROMPT_PIPELINE.md`: prompt para que un agente explique el
  pipeline a otro compañero.
- `docs/prompts/PROMPT_LABORATORIO.md`: prompt para que un agente explique el
  laboratorio completo y la remediación.
- `.env.example` y `frontend/.env.example`: plantillas sin secretos reales.

---

## Alternativa con Jenkins (si el docente lo pide específicamente)

Este mismo par de escáneres se puede correr en un pipeline de Jenkins en
vez de GitHub Actions. La lógica es idéntica; lo único que cambia es dónde
vive el pipeline:

1. Instala Jenkins localmente (requiere Java 17+):
   `docker run -p 8080:8080 jenkins/jenkins:lts` es la forma más rápida —
   un contenedor, sin instalar Jenkins en el sistema operativo.
2. Crea un **Pipeline** nuevo (no "Freestyle") y pégale este
   `Jenkinsfile` en la raíz del repo:

   ```groovy
   pipeline {
     agent any
     stages {
       stage('Instalar herramientas') {
         steps {
           sh 'pip install detect-secrets semgrep'
         }
       }
       stage('Secret scanning') {
         steps {
           sh '''
             detect-secrets scan --all-files app/ > secrets.json
             python3 -c "import json,sys; d=json.load(open('secrets.json')); sys.exit(1 if d['results'] else 0)"
           '''
         }
       }
       stage('SAST (Semgrep)') {
         steps {
           sh 'semgrep --config=.semgrep/sql-injection.yml app/app.py --error'
         }
       }
     }
   }
   ```
3. Conecta el repositorio de GitHub al job de Jenkins (plugin "GitHub" +
   un webhook, o simplemente "Poll SCM" para la demo).
4. El resultado se ve igual de claro: el build queda en rojo (❌) o verde
   (✅) en el dashboard de Jenkins.

**Para la demo en vivo, sigue prefiriendo GitHub Actions**: Jenkins suma un
servidor que levantar y un webhook que configurar — dos cosas más que
pueden fallar frente al profesor. Úsalo solo si el docente pide
explícitamente ver Jenkins.
