import { resetAndSeedDemoData } from '../shared/demo-bootstrap.js';

async function main() {
  await resetAndSeedDemoData();
  console.log('Demo Prisma data seeded.');
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
