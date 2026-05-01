import { buildApp } from './app.js';
import { env } from './config/env.js';

const app = buildApp();

app.listen(Number(env.PORT), () => {
  console.log(
    `PakaPakaya backend listening on :${env.PORT} (${env.NODE_ENV}, version=${env.APP_VERSION}, revision=${env.APP_REVISION})`,
  );
});
