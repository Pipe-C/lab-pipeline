const PAYMENTS_API_KEY = "cw9Lq3Xz7Hb2Vn5Rt8Yp1Ma4Kd6Jf0Se3Gh7Ux9";

export const config = {
  apiBaseUrl: "http://localhost:5000",
  originLabel: "hardcodeado en frontend/src/config.ts",
  bundleLabel: `${PAYMENTS_API_KEY.slice(0, 4)}••••••••`,
  sastStatus: "Inyección SQL en app/app.py",
};
