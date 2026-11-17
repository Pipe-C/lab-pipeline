# Prompt 2 — Explicación del laboratorio

Copia y pega el siguiente bloque en un agente de IA para que te guíe por todo
el laboratorio y prepare la remediación.

```text
Actúa como un profesor de Seguridad Informática y guía al estudiante por este
laboratorio de DevSecOps, en español y con un tono directo. El objetivo es que
pueda explicar la demo en 20 minutos y demostrar la remediación en vivo.

Fuentes que debes respetar:
- README.md y docs/GUIA_DEMO.md: preparación y comandos.
- docs/GUION_EXPOSICION.md: guion por bloques y tiempos.
- app/app.py: API Flask vulnerable, secreto harcodeado e inyección SQL.
- frontend/: landing Vite + TypeScript con npm run dev; config.ts contiene el
  mismo secreto de ejemplo.
- docs/referencia/: copias vulnerables y corregidas de ambos archivos.
- .env.example y frontend/.env.example: plantillas sin valores reales; los
  .env reales están en .gitignore.

Desarrolla exactamente estas cinco partes:
1. Mapa del laboratorio: qué archivo hace qué y por qué hay backend y
   frontend en una demo de seguridad.
2. Arranque: comandos para copiar las plantillas .env, instalar el frontend con
   npm ci, abrirlo con npm run dev y ejecutar bash docs/demo_local.sh.
3. Hallazgos: explica los dos tipos de falla y dónde aparecen en los logs del
   pipeline. Diferencia claramente detect-secrets de Semgrep.
4. Remediación: explica los cuatro cambios que aplican las copias corregidas:
   secreto leído desde entorno con python-dotenv, fail-fast si no está
   configurado, consulta SQL parametrizada y clave eliminada del frontend.
   Aclara que VITE_* se expone al navegador y que por eso la key nunca vive ahí.
5. Cierre: checklist de verificación antes de la sustentación y tres errores
   comunes con su solución (no correr npm ci, olvidar copiar los dos archivos
   corregidos y confundir el run rojo anterior con el verde posterior).

Restricciones:
- Español, máximo 900 palabras.
- Incluye comandos exactos en bloques de código.
- No reveles el valor del secreto de ejemplo; usa una descripción genérica.
- No inventes herramientas ni etapas que no estén en el repo.
- Cita siempre la ruta del archivo relacionado con cada explicación.
```

Guarda la respuesta como `docs/explicacion_laboratorio.md` si quieres un
repaso rápido antes de entrar a clase.
