# Fondation Production F0 — Contracts & Test Harness Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Installer dans `medygoo/schoolsafemm` les contrats, conventions d’erreur, configuration, service minimal et chaîne de tests nécessaires avant toute Auth ou donnée réelle.

**Architecture:** F0 crée un service TypeScript indépendant de l’UI, une configuration validée et une CI PR. Il n’accède à aucune donnée métier de production et n’altère pas les écrans SchoolSafe.

**Tech Stack:** Node.js, TypeScript, Fastify, Zod, Vitest, GitHub Actions.

## Global Constraints
- Branche/worktree isolé depuis le SHA de production vérifié.
- Aucune connexion à Supabase/VPS/R2 de production.
- Aucun secret dans Git.
- Aucun changement visuel dans `app/`.
- Le test doit échouer avant l’implémentation correspondante.

---

### Task 1: Créer le workspace Node et les scripts de preuve

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
- Produces: `buildApp(): FastifyInstance`, `GET /health -> {status:"ok"}`.

- [ ] **Step 1: Écrire le test rouge de health**

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

- [ ] **Step 2: Installer les dépendances et vérifier RED**

Run:
```bash
npm install -D typescript vitest @types/node
npm install --workspace server fastify zod
npm run test --workspace server -- health.test.ts
```
Expected: FAIL car `buildApp` n’existe pas.

- [ ] **Step 3: Implémenter `buildApp` minimal**

```ts
import Fastify from "fastify";

export function buildApp() {
  const app = Fastify({ logger: false });
  app.get("/health", async () => ({ status: "ok" as const }));
  return app;
}
```

`server/src/index.ts` démarre `buildApp()` sur `HOST`/`PORT` validés plus tard et n’est jamais importé par les tests.

- [ ] **Step 4: Vérifier GREEN**

Run:
```bash
npm run test --workspace server -- health.test.ts
```
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add package.json package-lock.json server
git commit -m "chore: scaffold SchoolSafe production service"
```

### Task 2: Valider la configuration sans exposer de secrets

**Files:**
- Create: `.env.example`
- Create: `server/src/config/env.ts`
- Create: `server/tests/env.test.ts`

**Interfaces:**
- Produces: `parseEnv(input: NodeJS.ProcessEnv): AppEnv`.
- `AppEnv` contient uniquement les variables nécessaires au service ; les valeurs privées restent côté serveur.

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

- [ ] **Step 3: Implémenter avec Zod**

Schéma requis : `NODE_ENV`, `HOST`, `PORT`, `SUPABASE_URL`, `SUPABASE_ANON_KEY`; variables privées optionnelles dans F0 mais validées lorsqu’elles existent : `SUPABASE_SERVICE_ROLE_KEY`, `R2_ENDPOINT`, `R2_ACCESS_KEY_ID`, `R2_SECRET_ACCESS_KEY`, `VAPID_PRIVATE_KEY`.

`.env.example` contient uniquement les noms et exemples non secrets :
```dotenv
NODE_ENV=development
HOST=127.0.0.1
PORT=8787
SUPABASE_URL=http://127.0.0.1:54321
SUPABASE_ANON_KEY=local-test-public-key
```

- [ ] **Step 4: Vérifier GREEN**

Run: `npm run test --workspace server -- env.test.ts`
Expected: PASS.

- [ ] **Step 5: Vérifier Git ignore**

Run:
```bash
git check-ignore .env .env.local
```
Expected: les deux chemins sont ignorés.

- [ ] **Step 6: Commit**

```bash
git add .env.example server/src/config server/tests/env.test.ts
git commit -m "feat: validate server runtime configuration"
```

### Task 3: Créer le contrat d’erreur et request_id

**Files:**
- Create: `server/src/http/errors.ts`
- Create: `server/src/http/request-id.ts`
- Modify: `server/src/app.ts`
- Create: `server/tests/errors.test.ts`

**Interfaces:**
- Produces: `ApiErrorCode`, `ApiErrorBody`, `SchoolSafeError`, `requestIdPlugin`.
- Format public exact : `{code,message,request_id,retryable}`.

- [ ] **Step 1: Test rouge du format**

```ts
it("retourne un format d’erreur stable sans stack publique", async () => {
  const app = buildApp({ testRoutes: true });
  const response = await app.inject({ method: "GET", url: "/__test/error" });
  const body = response.json();
  expect(body).toMatchObject({ code: "VALIDATION_INVALID", retryable: false });
  expect(body.request_id).toMatch(/^[A-Za-z0-9_-]+$/);
  expect(JSON.stringify(body)).not.toContain("stack");
});
```

- [ ] **Step 2: Vérifier RED**, puis implémenter les codes : `AUTH_REQUIRED`, `PERMISSION_DENIED`, `VALIDATION_INVALID`, `VERSION_CONFLICT`, `IDEMPOTENCY_DUPLICATE`, `DEPENDENCY_UNAVAILABLE`, `INTERNAL_ERROR`.

- [ ] **Step 3: Vérifier GREEN**

Run: `npm run test --workspace server -- errors.test.ts`
Expected: PASS.

- [ ] **Step 4: Commit**

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
- Produces: IDs machine indépendants des libellés, exemple `school.student.read`, `finance.payment.record`, `pedagogy.grade.publish`, `security.exit.authorize`.

- [ ] **Step 1: Test rouge** — charger le JSON et vérifier unicité, format `^[a-z][a-z0-9.-]+$`, présence des permissions minimales de F1/F2.
- [ ] **Step 2: Vérifier RED**.
- [ ] **Step 3: Créer le catalogue initial** couvrant bootstrap, profils, classes, élèves, responsables, personnes autorisées, lecture de statut financier sans montant, sync, fichiers et notifications.
- [ ] **Step 4: Vérifier GREEN**.
- [ ] **Step 5: Commit**.

### Task 5: Ajouter readiness distinct de health

**Files:**
- Create: `server/src/health/readiness.ts`
- Modify: `server/src/app.ts`
- Create: `server/tests/readiness.test.ts`

**Interfaces:**
- Produces: `ReadinessProbe` injectable et `GET /ready`.

- [ ] **Step 1: Test rouge** : une dépendance indisponible doit produire HTTP 503 et `DEPENDENCY_UNAVAILABLE`.
- [ ] **Step 2: Implémenter un probe injectable ; en F0 le probe de test est simulé, aucune connexion production.
- [ ] **Step 3: Vérifier tests 200/503**.
- [ ] **Step 4: Commit**.

### Task 6: Installer la CI PR sans toucher au déploiement Pages

**Files:**
- Create: `.github/workflows/ci.yml`
- Do not modify yet: `.github/workflows/static.yml`

**Interfaces:**
- Produces: gate PR `SchoolSafe CI` exécutant install, typecheck, tests et vérification secrets basique.

- [ ] **Step 1: Ajouter scripts racine**

```json
{
  "scripts": {
    "typecheck": "npm run typecheck --workspace server",
    "test": "npm run test --workspace server",
    "ci": "npm run typecheck && npm test"
  }
}
```

- [ ] **Step 2: Créer workflow PR** avec `npm ci` puis `npm run ci`. Aucun `pages: write`, aucun déploiement.
- [ ] **Step 3: Ajouter une vérification qui échoue si des chaînes `SUPABASE_SERVICE_ROLE_KEY=` ou `R2_SECRET_ACCESS_KEY=` avec valeur non vide sont trouvées dans les fichiers suivis.
- [ ] **Step 4: Ouvrir PR F0 et attendre CI**.
- [ ] **Step 5: Commit**.

### Task 7: Gate F0

- [ ] Exécuter `npm ci && npm run ci` avec exit 0.
- [ ] Vérifier le diff : aucun changement dans `app/index.html`, `app/styles.css`, `app/styles-original.css`, `app/v3-theme.css`, images ou animations.
- [ ] Vérifier `.github/workflows/static.yml` byte-for-byte inchangé.
- [ ] Produire paquet de transfert avec SHA base/head, tests et risques.
- [ ] Staging technique seulement ; ne pas fusionner `schoolsafemm/main` sans validation humaine.
