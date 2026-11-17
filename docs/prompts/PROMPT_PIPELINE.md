# Prompt 1 — Explicación del pipeline

Copia y pega el siguiente bloque en un agente de IA antes de la sustentación.

```text
Actúa como un ingeniero DevSecOps senior y explica, en español, el pipeline
de este repositorio a un compañero de pregrado que nunca ha visto GitHub
Actions. No asumas conocimientos previos SAST.

Contexto que debes usar como fuente de verdad:
- Repositorio público: Pipe-C/lab-pipeline.
- Workflow: .github/workflows/devsecops.yml.
- Se ejecuta en cada push a cualquier rama y en pull requests a main.
- Jobs: secret-scan (detect-secrets), sast-scan (Semgrep con la regla propia
  .semgrep/sql-injection.yml y el registro p/owasp-top-ten) y un job opcional
  de SonarQube Cloud.
- El escaneo de secretos cubre app/ y frontend/src/.
- El repo es público y eso es seguro en este caso: el secreto de ejemplo es
  genérico, no una credencial real ni un formato reconocido por proveedores.
  El push protection de GitHub no interfiere; quien debe fallar es nuestro
  pipeline.

Estructura obligatoria de la respuesta:
1. Una frase que defina qué es un pipeline CI/CD con una analogía sencilla.
2. Un recorrido del evento `git push` hasta el check rojo o verde, nombrando
   los tres jobs y qué revisa cada uno.
3. La diferencia concreta entre secret scanning y SAST, con los dos hallazgos
   reales de este repo: clave harcodeada en app/app.py y en
   frontend/src/config.ts; inyección SQL en app/app.py.
4. Por qué el job de secretos escanea también el frontend y por qué las
   variables VITE_* son públicas.
5. Qué significa un check rojo y qué significa uno verde, y qué debería hacer
   un desarrollador en cada caso.
6. Una nota de seguridad: si una credencial real llega al historial de Git,
   borrarla del código no basta; hay que rotarla.

Restricciones:
- Español claro, máximo 700 palabras.
- Sin marketing, sin lugar comunes y sin datos inventados.
- Cita rutas de archivo exactas cuando hables de código.
- No incluyas el valor del secreto de ejemplo.
- Termina con tres preguntas de control para verificar que el compañero
  entendió el flujo.
```

Guarda la respuesta del agente como `docs/explicacion_pipeline.md` si quieres
tenerla a mano el día de la exposición.
