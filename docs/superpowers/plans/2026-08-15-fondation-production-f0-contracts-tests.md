# Fondation Production F0 — Contracts & Test Harness Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Installer dans `medygoo/schoolsafemm` les contrats, conventions d’erreur, configuration, service minimal et chaîne de tests nécessaires avant toute Auth ou donnée réelle.

**Architecture:** F0 crée un service TypeScript indépendant de l’UI, une configuration validée et une CI PR. Les tests serveur tournent sur Linux ; les QA Playwright déjà présentes sont rendues bloquantes dans un job Windows qui dispose du chemin Chrome attendu par les scripts existants. F0 n’accède à aucune donnée métier de production et n’altère pas les écrans SchoolSafe.

**Tech Stack:** Node.js, TypeScript, Fastify, Zod, Vitest, Playwright existant, GitHub Actions.

## Global Constraints
- Branche/worktree isolé depuis le SHA de production vérifié.
- Aucune connexion à Supabase/VPS/R2 de production.
- Aucun secret dans Git.
- Aucun changement visuel dans `app/`.
- Le test doit échouer avant l’implémentation correspondante.
- Le lockfile doit être commité après toute installation de dépendance.
- `app/qa-smoke.cjs`, `app/qa-pwa.cjs` et `app/qa-i18n.cjs` restent les preuves de régression frontend initiales ; ne pas affaiblir leurs assertions pour obtenir du vert.

---

### Task 1: Créer le workspace Node et le premier test rouge

**Files:**
- Create: `package.json`
- Create: `server/package.json`
- Create: `server/tsconfig.json`
- Create: `server/vitest.config.ts`
- Create: `server/src/index.ts`
- Create: `server/src/app.ts`
- Create: `server/tests/health.test.ts`

**Interfaces:**
- Consumes: aucun service externe.
- Produces: `buildApp(options?: BuildAppOptions): FastifyInstance`, `GET /health -> {status:"ok"}`.

- [ ] **Step 1: Créer le workspace racine**

`package.json` exact :
```json
{
  "name": "schoolsafe-v2",
  "private": true,
  "workspaces": ["server"],
  "scripts": {
    "typecheck": "npm run typecheck --workspace server",
    "test": "npm run test --workspace server",
    "ci": "npm run typecheck && npm test"
  }
}
```

`server/package.json` initial exact :
```json
{
  "name": "schoolsafe-server",
  "private": true,
  "type": "module",
  "scripts": {
    "typecheck": "tsc -p tsconfig.json --noEmit",
    "test": "vitest run",
    "dev": "tsx src/index.ts",
    "build": "tsc -p tsconfig.json",
    "start": "node dist/src/index.js"
  },
  "engines": {
    "node": ">=22"
  }
}
```

`server/tsconfig.json` exact :
```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": false,
    "outDir": "dist",
    "rootDir": ".",
    "types": ["node"]
  },
  "include": ["src/**/*.ts", "tests/**/*.ts", "vitest.config.ts"]
}
```

`server/vitest.config.ts` exact :
```ts
import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    environment: "node",
    include: ["tests/**/*.test.ts"]
  }
});
```

- [ ] **Step 2: Installer les dépendances exactes du lot**

Run:
```bash
npm install --workspace server fastify zod
npm install -D --workspace server typescript vitest @types/node tsx
```
Expected: `package-lock.json` créé et `server/package.json` enrichi avec les versions résolues.

- [ ] **Step 3: Écrire le test rouge de health**

`server/tests/health.test.ts` :
```ts
import { describe, expect, it } from "vitest";
import { buildApp } from "../src/app.js";

describe("GET /health", () => {
  it("retourne un état de processus sans dépendance externe", async () => {
    const app = buildApp();
    const response = await app.inject({ method: "GET", url: "/health" });
    expect(response.statusCode).toBe(200);
    expect(response.json()).toEqual({ status: "ok" });
    await app.close();
  });
});
```

- [ ] **Step 4: Vérifier RED**

Run:
```bash
npm run test --workspace server -- health.test.ts
```
Expected: FAIL car `server/src/app.ts`/`buildApp` n’existe pas encore.

- [ ] **Step 5: Implémenter le minimum**

`server/src/app.ts` :
```ts
import Fastify, { type FastifyInstance } from "fastify";

export type BuildAppOptions = {
  testRoutes?: boolean;
};

export function buildApp(_options: BuildAppOptions = {}): FastifyInstance {
  const app = Fastify({ logger: false });
  app.get("/health", async () => ({ status: "ok" as const }));
  return app;
}
```

`server/src/index.ts` :
```ts
import { buildApp } from "./app.js";

const host = process.env.HOST ?? "127.0.0.1";
const port = Number(process.env.PORT ?? "8787");
const app = buildApp();

await app.listen({ host, port });
```

- [ ] **Step 6: Vérifier GREEN et typecheck**

Run:
```bash
npm run test --workspace server -- health.test.ts
npm run typecheck --workspace server
```
Expected: deux commandes exit 0.

- [ ] **Step 7: Commit**

```bash
git add package.json package-lock.json server
git commit -m "chore: scaffold SchoolSafe production service"
```

### Task 2: Valider la configuration sans exposer de secrets

**Files:**
- Create: `.env.example`
- Create: `server/src/config/env.ts`
- Create: `server/tests/env.test.ts`
- Modify: `server/src/index.ts`

**Interfaces:**
- Produces: `parseEnv(input: NodeJS.ProcessEnv): AppEnv`.
- `AppEnv` contient les valeurs validées nécessaires au service ; les valeurs privées restent côté serveur.

- [ ] **Step 1: Test rouge**

```ts
import { expect, it } from "vitest";
import { parseEnv } from "../src/config/env.js";

it("refuse une configuration serveur sans URL Supabase", () => {
  expect(() => parseEnv({ NODE_ENV: "test" })).toThrow(/SUPABASE_URL/);
});
```

- [ ] **Step 2: Vérifier RED**

Run: `npm run test --workspace server -- env.test.ts`
Expected: FAIL car `parseEnv` n’existe pas.

- [ ] **Step 3: Implémenter `parseEnv` avec Zod**

Le schéma accepte exactement :
- `NODE_ENV`: `development | test | staging | production` ;
- `HOST`: string, défaut `127.0.0.1` ;
- `PORT`: entier 1..65535, défaut `8787` ;
- `SUPABASE_URL`: URL obligatoire ;
- `SUPABASE_ANON_KEY`: string non vide obligatoire ;
- privées optionnelles en F0 mais non exposées : `SUPABASE_SERVICE_ROLE_KEY`, `R2_ENDPOINT`, `R2_ACCESS_KEY_ID`, `R2_SECRET_ACCESS_KEY`, `VAPID_PRIVATE_KEY`.

`.env.example` exact :
```dotenv
NODE_ENV=development
HOST=127.0.0.1
PORT=8787
SUPABASE_URL=http://127.0.0.1:54321
SUPABASE_ANON_KEY=local-test-public-key
```

Modifier `server/src/index.ts` pour appeler `parseEnv(process.env)` puis utiliser `env.HOST` et `env.PORT`.

- [ ] **Step 4: Vérifier GREEN**

Run:
```bash
npm run test --workspace server -- env.test.ts
npm run typecheck --workspace server
```
Expected: PASS.

- [ ] **Step 5: Vérifier Git ignore**

Run:
```bash
git check-ignore .env .env.local
```
Expected: les deux chemins sont ignorés.

- [ ] **Step 6: Commit**

```bash
git add .env.example server/src/config server/src/index.ts server/tests/env.test.ts
git commit -m "feat: validate server runtime configuration"
```

### Task 3: Créer le contrat d’erreur et `request_id`

**Files:**
- Create: `server/src/http/errors.ts`
- Create: `server/src/http/request-id.ts`
- Modify: `server/src/app.ts`
- Create: `server/tests/errors.test.ts`

**Interfaces:**
- Produces: `ApiErrorCode`, `ApiErrorBody`, `SchoolSafeError`.
- Format public exact : `{code,message,request_id,retryable}`.

- [ ] **Step 1: Test rouge du format**

```ts
import { expect, it } from "vitest";
import { buildApp } from "../src/app.js";

it("retourne un format d’erreur stable sans stack publique", async () => {
  const app = buildApp({ testRoutes: true });
  const response = await app.inject({ method: "GET", url: "/__test/error" });
  const body = response.json();
  expect(body).toMatchObject({ code: "VALIDATION_INVALID", retryable: false });
  expect(body.request_id).toMatch(/^[A-Za-z0-9_-]+$/);
  expect(JSON.stringify(body)).not.toContain("stack");
  await app.close();
});
```

- [ ] **Step 2: Vérifier RED**

Run: `npm run test --workspace server -- errors.test.ts`
Expected: FAIL car la route/gestion d’erreur n’existe pas.

- [ ] **Step 3: Implémenter**

Créer les codes exacts : `AUTH_REQUIRED`, `PERMISSION_DENIED`, `VALIDATION_INVALID`, `VERSION_CONFLICT`, `IDEMPOTENCY_DUPLICATE`, `DEPENDENCY_UNAVAILABLE`, `INTERNAL_ERROR`.

`SchoolSafeError` porte `statusCode`, `code`, `publicMessage`, `retryable`. Le handler Fastify génère `request_id` via `crypto.randomUUID()` et n’inclut jamais `stack` dans la réponse.

Quand `options.testRoutes === true`, `buildApp` enregistre `/__test/error` qui lève un `SchoolSafeError(400, "VALIDATION_INVALID", "Donnée invalide", false)`.

- [ ] **Step 4: Vérifier GREEN**

Run:
```bash
npm run test --workspace server -- errors.test.ts
npm run typecheck --workspace server
```
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add server/src/http server/src/app.ts server/tests/errors.test.ts
git commit -m "feat: add stable API error contract"
```

### Task 4: Définir les identifiants de permissions stables

**Files:**
- Create: `shared/permissions.json`
- Create: `server/src/access/permission-catalog.ts`
- Create: `server/tests/permission-catalog.test.ts`

**Interfaces:**
- Produces: catalogue JSON d’IDs indépendants des libellés.

Le catalogue initial contient au minimum :
```json
[
  "session.bootstrap",
  "school.class.read",
  "school.student.read",
  "school.guardian.read",
  "school.guardian.manage",
  "security.pickup.read",
  "security.pickup.manage",
  "finance.status.read",
  "sync.submit",
  "file.upload",
  "file.download",
  "notification.subscribe"
]
```

- [ ] **Step 1: Test rouge** : charger le JSON et vérifier unicité, format `^[a-z][a-z0-9.-]+$` et liste minimale ci-dessus.
- [ ] **Step 2: Vérifier RED** car le catalogue n’existe pas.
- [ ] **Step 3: Créer le catalogue et `loadPermissionCatalog()` qui retourne un `ReadonlySet<string>`.**
- [ ] **Step 4: Vérifier GREEN** avec test + typecheck.
- [ ] **Step 5: Commit**.

### Task 5: Ajouter readiness distinct de health

**Files:**
- Create: `server/src/health/readiness.ts`
- Modify: `server/src/app.ts`
- Create: `server/tests/readiness.test.ts`

**Interfaces:**
```ts
export type ReadinessProbe = () => Promise<{ ready: boolean; dependency?: string }>;
```
`BuildAppOptions` est étendu avec `readinessProbe?: ReadinessProbe`.

- [ ] **Step 1: Test rouge** : probe `{ready:false,dependency:"postgres"}` → HTTP 503 et `DEPENDENCY_UNAVAILABLE`.
- [ ] **Step 2: Implémenter `/ready`** ; le probe par défaut de F0 retourne `{ready:true}` et ne contacte aucune production.
- [ ] **Step 3: Vérifier tests 200/503 + typecheck**.
- [ ] **Step 4: Commit**.

### Task 6: Transformer les QA navigateur existantes en gate exécutable

**Files:**
- Modify: `package.json`
- Modify: `package-lock.json`
- Do not weaken: `app/qa-smoke.cjs`, `app/qa-pwa.cjs`, `app/qa-i18n.cjs`

**Interfaces:**
- Produces `npm run test:e2e:existing` et `npm run test:e2e:staging`.

- [ ] **Step 1: Installer Playwright au workspace racine**

Run:
```bash
npm install -D -W playwright
npm pkg set 'scripts.test:e2e:existing=node app/qa-smoke.cjs && node app/qa-pwa.cjs && node app/qa-i18n.cjs'
npm pkg set 'scripts.test:e2e:staging=npm run test:e2e:existing'
```

- [ ] **Step 2: Vérifier localement sur Windows si disponible**

Démarrer :
```powershell
Start-Process node -ArgumentList "app/server.mjs"
$env:SCHOOLSAFE_URL="http://127.0.0.1:4175/"
npm run test:e2e:existing
```
Expected: les QA existantes utilisent le Chrome installé au chemin déjà prévu par les scripts.

- [ ] **Step 3: Ne pas modifier une assertion pour masquer une régression.** Si un test rouge apparaît, utiliser `systematic-debugging` et déterminer s’il s’agit du baseline ou de l’environnement.

- [ ] **Step 4: Commit**

```bash
git add package.json package-lock.json
git commit -m "test: make existing SchoolSafe browser QA a required suite"
```

### Task 7: Installer la CI PR sans toucher au déploiement Pages

**Files:**
- Create: `.github/workflows/ci.yml`
- Do not modify: `.github/workflows/static.yml`

**Interfaces:**
- Produces deux jobs : `server-contracts` sur Ubuntu et `existing-browser-qa` sur Windows.

- [ ] **Step 1: Job Linux `server-contracts`**

Étapes : checkout → setup Node → `npm ci` → `npm run ci` → contrôle secrets. Aucun `pages: write`.

- [ ] **Step 2: Contrôle secrets**

Faire échouer si un fichier suivi contient une affectation non vide de `SUPABASE_SERVICE_ROLE_KEY`, `R2_SECRET_ACCESS_KEY` ou `VAPID_PRIVATE_KEY`. `.env.example` n’en contient pas.

- [ ] **Step 3: Job Windows `existing-browser-qa`**

Étapes PowerShell :
```powershell
npm ci
Start-Process node -ArgumentList "app/server.mjs"
Start-Sleep -Seconds 2
$env:SCHOOLSAFE_URL="http://127.0.0.1:4175/"
npm run test:e2e:existing
```
Le job utilise Google Chrome fourni par `windows-latest`, conforme au chemin attendu dans les QA existantes.

- [ ] **Step 4: Vérifier que le workflow ne contient** ni `actions/deploy-pages`, ni `pages: write`, ni secret production.

- [ ] **Step 5: Commit**

```bash
git add .github/workflows/ci.yml
git commit -m "ci: validate SchoolSafe before staging"
```

- [ ] **Step 6: Ouvrir PR F0 et attendre les deux jobs verts.**

### Task 8: Gate F0

- [ ] Exécuter `npm ci && npm run ci` avec exit 0.
- [ ] Exécuter `npm run test:e2e:existing` sur environnement Windows/CI avec exit 0.
- [ ] Vérifier le diff : aucun changement dans `app/index.html`, `app/styles.css`, `app/styles-original.css`, `app/v3-theme.css`, images ou animations.
- [ ] Vérifier `.github/workflows/static.yml` byte-for-byte inchangé.
- [ ] Vérifier qu’aucune clé privée n’est suivie par Git.
- [ ] Produire paquet de transfert avec SHA base/head, tests et risques.
- [ ] Staging technique seulement ; ne pas fusionner `schoolsafemm/main` sans validation humaine.
