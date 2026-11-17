import "./styles.css";
import { config } from "./config";

const app = document.querySelector<HTMLDivElement>("#app");

if (!app) {
  throw new Error("No se encontró el contenedor #app");
}

const root: HTMLDivElement = app;
const isVulnerable = config.originLabel.startsWith("hardcodeado");
root.dataset.state = isVulnerable ? "vulnerable" : "fixed";

root.innerHTML = `
  <header class="site-header">
    <div class="container header-inner">
      <a class="wordmark" href="#inicio">devsecops<span>/lab</span></a>
      <p class="header-meta">Tema 7 · I.U. Pascual Bravo</p>
    </div>
  </header>

  <main class="container" id="inicio">
    <section class="hero" aria-labelledby="hero-title">
      <h1 id="hero-title">Un pipeline que detiene el código inseguro.</h1>
      <p class="lede">
        En cada push, dos escáneres revisan una API Flask y esta landing. Si
        aparece una credencial o una consulta SQL insegura, el check se pone en
        rojo antes de cualquier despliegue.
      </p>
      <div class="actions">
        <a class="button button-primary" href="#estado">Ver el estado del código</a>
        <a class="button button-quiet" href="#flujo">Cómo funciona</a>
      </div>
    </section>

    <section class="panel" id="estado" aria-labelledby="estado-title">
      <div class="panel-heading">
        <h2 id="estado-title">Estado actual del código</h2>
        <p data-state-label></p>
      </div>
      <dl class="findings">
        <div class="finding">
          <dt>API configurada</dt>
          <dd><code data-api-base></code></dd>
        </div>
        <div class="finding">
          <dt>Secret scanning</dt>
          <dd data-secret-result></dd>
        </div>
        <div class="finding">
          <dt>SAST</dt>
          <dd data-sast-status></dd>
        </div>
        <div class="finding">
          <dt>Clave de pagos</dt>
          <dd data-origin-label></dd>
        </div>
        <div class="finding">
          <dt>Visible en el bundle</dt>
          <dd><code data-bundle-label></code></dd>
        </div>
      </dl>
    </section>

    <section class="flow" id="flujo" aria-labelledby="flujo-title">
      <h2 id="flujo-title">Qué ocurre al hacer push</h2>
      <ol>
        <li>
          <strong>GitHub Actions recibe el cambio.</strong>
          No hay servidor que arrancar ni revisión manual.
        </li>
        <li>
          <strong>detect-secrets lee la API y el frontend.</strong>
          Busca credenciales escritas en el código.
        </li>
        <li>
          <strong>Semgrep analiza la API.</strong>
          Marca la consulta SQL construida con concatenación.
        </li>
        <li>
          <strong>El check queda en rojo o en verde.</strong>
          La regla se cumple antes de cualquier despliegue.
        </li>
      </ol>
    </section>
  </main>

  <footer class="site-footer">
    <div class="container">
      <p>Repositorio público de demostración. Sin credenciales reales.</p>
    </div>
  </footer>
`;

function setText(selector: string, value: string): void {
  const element = root.querySelector<HTMLElement>(selector);

  if (!element) {
    throw new Error(`No se encontró el elemento ${selector}`);
  }

  element.textContent = value;
}

setText("[data-state-label]", isVulnerable ? "Estado vulnerable" : "Estado corregido");
setText("[data-api-base]", config.apiBaseUrl);
setText(
  "[data-secret-result]",
  isVulnerable
    ? "Hallazgo: clave de pagos escrita en el código"
    : "Sin hallazgos",
);
setText("[data-sast-status]", config.sastStatus);
setText("[data-origin-label]", config.originLabel);
setText("[data-bundle-label]", config.bundleLabel);
