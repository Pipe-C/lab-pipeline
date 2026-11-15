# Guion de exposición — Tema 7: DevSecOps en pipelines CI/CD

20 minutos totales. Mapeado 1:1 a la rúbrica (dominio conceptual 20%,
demo práctica 50%, remediación 15%, participación y tiempo 15%).

## Antes de entrar a clase

- [ ] Repositorio creado en GitHub **como privado** (ver README § Opción A,
      paso 0 — así el push protection nativo de GitHub no te bloquea el
      `git push` antes de que tu propio pipeline tenga oportunidad de
      fallar, que es el punto de la demo), con este contenido subido y el
      workflow ya corriendo al menos una vez (para que no haya sorpresas de
      permisos el día de la demo).
- [ ] `app/app.py` en su estado **vulnerable** (el que trae por defecto).
- [ ] `bash docs/demo_local.sh` probado al menos una vez en tu máquina.
- [ ] El deck de 7 diapositivas abierto y probado.
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
   - Marca **Private** (no Public) — por la razón explicada arriba.
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

Para resolver tu duda concreta: con el repo en **privado** y el secreto en
**formato genérico** (como ya quedó en este proyecto), el `git push` **no
va a mostrarte ningún error en la terminal** — sube sin problema, en menos
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

1. **(1 min)** Abre `app/app.py` en el editor y en GitHub en el navegador,
   lado a lado. Señala la línea del secreto y la línea de la consulta SQL
   concatenada.
2. **(1 min)** Abre la pestaña **Actions** de tu repositorio: ahí está el
   run que ya falló antes de clase. Click en él.
3. **(3–4 min)** Entra al job **"Escaneo de secretos (detect-secrets)"**,
   expande el paso "Escanear en busca de secretos harcodeados" y lee en
   voz alta lo que el log reporta (tipo de secreto, archivo, línea). Repite
   con el job **"Análisis estático (Semgrep)"** y lee el mensaje sobre la
   inyección SQL. Explica: "esto lo encontró el pipeline solo, sin que
   nadie lo ejecutara a mano, antes de que el código llegara a producción."
4. **(1 min)** En tu terminal, con la clase viendo tu pantalla, corrige el
   código:
   ```bash
   cp docs/referencia/app_corregida.py app/app.py
   ```
5. **(1 min)** Sube la corrección:
   ```bash
   git add -A
   git commit -m "fix(security): leer el secreto por variable de entorno y parametrizar la consulta SQL"
   git push
   ```
6. **(2–3 min)** Vuelve al navegador, pestaña Actions: espera 20–40
   segundos y refresca — aparece un nuevo run, esta vez con ✅ verde en los
   dos jobs. Señala el contraste: "mismo repositorio, mismo pipeline, el
   único cambio fue el código."
7. **Si algo falla en vivo** (red del salón, GitHub lento): corre
   `bash docs/demo_local.sh` en tu terminal — hace exactamente lo mismo,
   sin depender de internet, y muestra ❌/✅ en segundos.

## Bloque 1 — Fundamento técnico (máx. 5 min)

Diapositivas: `cover`, `fundamento`, `flujo`.

Guion:
1. (30 s) Portada: nombrar el tema y las 3 herramientas.
2. (2 min) "¿Qué es SAST? ¿Qué es secret scanning?" — usar la diapositiva
   `fundamento`, explicar con tus palabras, sin leer.
3. (1.5 min) Diapositiva `flujo`: señalar cada caja mientras hablas —
   "cuando hacemos push, GitHub Actions dispara el pipeline, que corre los
   dos escáneres, y según el resultado el pipeline queda en verde o en
   rojo — sin que nadie tenga que revisarlo a mano".
4. (1 min) Impacto real: una credencial filtrada (de AWS, de una
   pasarela de pagos, de cualquier servicio) permite a cualquiera usarla
   en nombre de la empresa; una inyección SQL permite leer o borrar toda
   la base de datos.

## Bloque 2 — Demo práctica en vivo (10–12 min)

Diapositivas de apoyo: `demo`, `hallazgos` (se usan rápido, el protagonista
es el navegador con GitHub abierto). El guion comando a comando de este
bloque es la sección **C** de arriba ("En clase, el momento de la demo") —
ya asume que hiciste la preparación de la sección **A** antes de llegar.
Resumen de tiempos: 1 min mostrando el código, 1 min abriendo el run que ya
falló, 3–4 min leyendo los hallazgos en los logs, 1 min corrigiendo, 1 min
con el push de la corrección, 2–3 min mostrando el run en verde.

## Bloque 3 — Remediación y mitigación (3 min)

Diapositivas: `remediacion`.

1. (1 min) Secreto → variable de entorno: nunca en el código, nunca en el
   historial de Git (si ya se filtró, hay que rotar la credencial, no solo
   borrarla del código — el historial de Git la conserva).
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
