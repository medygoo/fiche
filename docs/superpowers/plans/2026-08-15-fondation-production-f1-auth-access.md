# Fondation Production F1 — Auth, Access & Bootstrap Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remplacer l’identité et les permissions de démonstration par Supabase Auth, un modèle d’accès PostgreSQL/RLS et un bootstrap serveur vérifiable, uniquement dans un environnement de test/staging.

**Architecture:** Supabase Auth prouve l’identité. PostgreSQL conserve profils, rôles, grants et périmètres. Le service SchoolSafe valide le JWT avec le client Supabase public puis interroge la base sous le JWT de l’utilisateur afin que RLS reste active. Le frontend statique utilise un bundle local de `@supabase/supabase-js` construit par esbuild ; aucune dépendance CDN et aucune clé privilégiée ne sont nécessaires dans le navigateur.

**Tech Stack:** Supabase Auth/PostgreSQL local de test, SQL/RLS, Node.js/TypeScript/Fastify, `@supabase/supabase-js`, esbuild, Vitest, SQL d’intégration.

## Global Constraints
- F0 doit être vert avant F1.
- Aucune migration production.
- Aucun rôle reçu du navigateur n’est digne de confiance.
- `service_role` reste uniquement côté serveur et n’est pas utilisé pour simuler un utilisateur final dans les tests RLS.
- Le sélecteur de rôle de démonstration est autorisé uniquement quand `appMode === "demo"`.
- Les écrans visuels d’authentification restent inchangés sauf branchement comportemental.
- Le SDK Supabase navigateur est bundlé localement ; aucun script CDN.

---

### Task 0: Installer le harness Supabase/RLS de test

**Files:**
- Create: `supabase/config.toml` via Supabase CLI local.
- Create: `supabase/seed.sql`
- Create: `scripts/run-rls-tests.mjs`
- Modify: `package.json`
- Modify: `package-lock.json`
- Modify: `.github/workflows/ci.yml`

**Interfaces:**
- Produces: `npm run supabase:start`, `npm run supabase:reset`, `npm run test:rls`.
- Base locale de test : `TEST_DATABASE_URL`, fournie explicitement par CI/dev ; aucune URL production.

- [ ] **Step 1: Installer les outils au workspace racine**

Run:
```bash
npm install -D -W supabase pg
npm pkg set 'scripts.supabase:start=supabase start'
npm pkg set 'scripts.supabase:reset=supabase db reset'
npm pkg set 'scripts.test:rls=node scripts/run-rls-tests.mjs'
```
Expected: lockfile mis à jour.

- [ ] **Step 2: Initialiser Supabase local**

Run:
```bash
npx supabase init
```
Expected: `supabase/config.toml` créé. Ne renseigner aucun identifiant de production.

- [ ] **Step 3: Créer le runner SQL**

`scripts/run-rls-tests.mjs` :
```js
import fs from "node:fs/promises";
import path from "node:path";
import pg from "pg";

const databaseUrl = process.env.TEST_DATABASE_URL;
if (!databaseUrl) throw new Error("TEST_DATABASE_URL is required");

const directory = path.resolve("tests/rls");
const files = (await fs.readdir(directory)).filter((name) => name.endsWith(".sql")).sort();
const client = new pg.Client({ connectionString: databaseUrl });
await client.connect();
try {
  for (const file of files) {
    const sql = await fs.readFile(path.join(directory, file), "utf8");
    await client.query(sql);
    console.log(`PASS ${file}`);
  }
} finally {
  await client.end();
}
```

Chaque fichier SQL utilise `BEGIN`, assertions SQL explicites/`DO $$ ... RAISE EXCEPTION ... $$`, puis `ROLLBACK` lorsque le scénario ne doit pas persister.

- [ ] **Step 4: Ajouter Supabase local à la CI F1**

Avant `npm run test:rls` :
```bash
npx supabase start
npx supabase db reset
```
Définir `TEST_DATABASE_URL` sur l’URL PostgreSQL locale produite par la configuration de test. Ne jamais utiliser un secret GitHub pointant vers production pour cette suite.

- [ ] **Step 5: Commit**

```bash
git add package.json package-lock.json supabase scripts/run-rls-tests.mjs .github/workflows/ci.yml
git commit -m "test: add isolated Supabase RLS harness"
```

### Task 1: Créer le schéma identité et accès

**Files:**
- Create: `supabase/migrations/202608150001_foundation_identity_access.sql`
- Modify: `supabase/seed.sql`
- Create: `tests/rls/foundation-access.sql`

**Interfaces:**
- Produces tables: `school`, `school_settings`, `profiles`, `devices`, `roles`, `permissions`, `profile_roles`, `role_permission_grants`, `scope_assignments`, `audit_events`.
- `profiles.auth_user_id` référence `auth.users(id)` de manière unique.
- `devices.profile_id` référence le propriétaire et contient `device_key`, `kind`, `is_school_managed`, `last_seen_at`, `revoked_at`.

- [ ] **Step 1: Écrire le test SQL rouge** vérifiant absence des tables et accès anonyme refusé après création attendue.
- [ ] **Step 2: Lancer `npx supabase db reset` puis `npm run test:rls`** et confirmer l’échec attendu avant migration.
- [ ] **Step 3: Écrire la migration** avec UUID, timestamps UTC, contraintes d’unicité et FK explicites. `audit_events` n’autorise aucune UPDATE/DELETE via rôles applicatifs.
- [ ] **Step 4: Seed synthétique** : une école, utilisateurs Auth de test, profils et rôles `admin`, `school_head`, `pedagogy`, `teacher`, `cashier`, `guard`, `parent`, plus permissions du catalogue F0.
- [ ] **Step 5: Rejouer reset + tests** et confirmer PASS.
- [ ] **Step 6: Commit**.

### Task 2: Construire les fonctions PostgreSQL de contexte d’accès

**Files:**
- Create: `supabase/migrations/202608150002_access_functions.sql`
- Extend: `tests/rls/foundation-access.sql`

**Interfaces:**
- Produces SQL functions : `current_profile_id()`, `has_permission(permission_code text)`, `has_scope(scope_type text, scope_id uuid)`.

- [ ] **Step 1: Test rouge** : utilisateur sans grant → `has_permission('school.student.read') = false` ; enseignant avec grant → true.
- [ ] **Step 2: Implémenter les fonctions en `security definer` uniquement lorsque nécessaire, avec `search_path` fixé explicitement.**
- [ ] **Step 3: Tester qu’un utilisateur ne peut pas fournir un autre `profile_id` pour gagner un droit.**
- [ ] **Step 4: PASS puis commit.**

### Task 3: Activer les politiques RLS de fondation

**Files:**
- Create: `supabase/migrations/202608150003_foundation_rls.sql`
- Extend: `tests/rls/foundation-access.sql`

**Interfaces:**
- Produces politiques RLS pour profil/appareils propres, lecture configuration utile, rôles/grants du profil courant et audit autorisé.

- [ ] **Step 1: Tests négatifs rouges** : parent lit profil d’un autre utilisateur → refus ; enseignant modifie grant → refus ; utilisateur forge rôle → refus ; utilisateur lit appareil d’un autre profil → refus.
- [ ] **Step 2: Activer RLS sur chaque table exposable.**
- [ ] **Step 3: Ajouter policies minimalistes ; aucune policy générale `using (true)`.**
- [ ] **Step 4: Tests positifs** : chaque profil lit son propre contexte autorisé.
- [ ] **Step 5: Tests négatifs** tous verts.
- [ ] **Step 6: Commit.**

### Task 4: Vérifier le JWT côté service sous contexte utilisateur

**Files:**
- Create: `server/src/auth/supabase.ts`
- Create: `server/src/auth/session.ts`
- Create: `server/src/auth/types.ts`
- Modify: `server/src/app.ts`
- Modify: `server/package.json`
- Create: `server/tests/auth-session.test.ts`

**Interfaces:**
- Produces `requireSession(request): Promise<AuthenticatedSession>` avec `{userId,email?,phone?,accessToken}`.
- Produces `createUserSupabaseClient(accessToken)` utilisant `SUPABASE_ANON_KEY` + header `Authorization: Bearer <JWT>` ; RLS reste active.

- [ ] **Step 1: Installer SDK serveur**

Run:
```bash
npm install --workspace server @supabase/supabase-js
```

- [ ] **Step 2: Tests rouges** : sans Bearer → 401 `AUTH_REQUIRED`; token invalide → 401 et le token n’apparaît pas dans réponse/log.

- [ ] **Step 3: Implémenter**

`createAuthClient()` utilise `createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {auth:{persistSession:false,autoRefreshToken:false}})`.
`requireSession` extrait Bearer puis appelle `auth.getUser(token)` ; il ne lit aucun rôle dans le body/header personnalisé.

- [ ] **Step 4: Test token local Supabase valide → session acceptée.**
- [ ] **Step 5: Commit.**

### Task 5: Implémenter `POST /session/bootstrap`

**Files:**
- Create: `server/src/bootstrap/service.ts`
- Create: `server/src/bootstrap/routes.ts`
- Create: `server/src/bootstrap/schema.ts`
- Modify: `server/src/app.ts`
- Create: `server/tests/bootstrap.test.ts`

**Interfaces:**
- Produces `BootstrapResponse` :
```ts
{
  contract_version: "1",
  profile: { id: string, display_name: string },
  roles: string[],
  permissions: string[],
  scopes: Array<{ type: string, id: string | null, label: string | null }>,
  school: { id: string, name: string },
  academic_year: null | { id: string, label: string },
  features: string[],
  offline_policy: { max_offline_hours: number }
}
```

- [ ] **Step 1: Test rouge** : body contenant `{role:"admin"}` ne change jamais le rôle calculé.
- [ ] **Step 2: Test rouge** : utilisateur sans profil applicatif → erreur contrôlée.
- [ ] **Step 3: Implémenter avec `createUserSupabaseClient(accessToken)`** ; rechercher profil/grants/scopes à partir de `auth_user_id` courant.
- [ ] **Step 4: Tester parent/teacher/admin synthétiques avec résultats distincts.**
- [ ] **Step 5: Commit.**

### Task 6: Bundler le SDK Auth pour la PWA statique

**Files:**
- Create: `frontend/vendor/supabase-entry.js`
- Create generated artifact: `app/vendor/supabase-sdk.js`
- Modify: `package.json`
- Modify: `package-lock.json`

**Interfaces:**
- Produces global `window.SchoolSafeSupabaseSDK.createClient`.

- [ ] **Step 1: Installer dépendances frontend au workspace racine**

Run:
```bash
npm install -W @supabase/supabase-js
npm install -D -W esbuild
npm pkg set 'scripts.build:auth-sdk=esbuild frontend/vendor/supabase-entry.js --bundle --format=iife --global-name=SchoolSafeSupabaseSDK --outfile=app/vendor/supabase-sdk.js'
```

- [ ] **Step 2: Créer entry**

```js
export { createClient } from "@supabase/supabase-js";
```

- [ ] **Step 3: Générer bundle**

Run:
```bash
npm run build:auth-sdk
```
Expected: `app/vendor/supabase-sdk.js` existe ; aucune clé/config n’est incluse dans le bundle.

- [ ] **Step 4: Commit source, lockfile et artifact** afin que la PWA reste auto-contenue/offline. Une mise à jour du SDK exige reconstruction et revue du diff.

### Task 7: Créer runtime config et clients frontend sans modifier la présentation

**Files:**
- Create: `app/runtime-config.js`
- Create: `app/clients/runtime-config.js`
- Create: `app/clients/auth-client.js`
- Create: `app/clients/bootstrap-client.js`
- Modify minimally: `app/index.html`
- Modify minimally: `app/app.js`
- Create: `app/qa-auth.cjs`

**Interfaces:**

`app/runtime-config.js` commité avec valeurs démo non sensibles :
```js
window.__SCHOOLSAFE_RUNTIME__ = Object.freeze({
  appMode: "demo",
  apiBaseUrl: "",
  supabaseUrl: "",
  supabaseAnonKey: "",
  vapidPublicKey: ""
});
```

En staging, le workflow construit une copie d’artifact et remplace ce fichier dans l’artifact avec `appMode:"staging"`, URL API staging, URL Supabase staging et clé anon/publishable staging. Ces valeurs ne sont pas des clés privilégiées.

APIs :
- `window.SchoolSafeRuntime.get()`
- `window.SchoolSafeAuth.signIn({mode,identifier,password})`
- `window.SchoolSafeAuth.signOut()`
- `window.SchoolSafeAuth.session()`
- `window.SchoolSafeBootstrap.load(accessToken)`

- [ ] **Step 1: QA rouge** : en staging, `#workspaceRoleSwitch` ne change jamais l’identité/permissions effectives.
- [ ] **Step 2: QA rouge** : secret invalide → workspace ne s’ouvre pas.
- [ ] **Step 3: Charger `runtime-config.js`, vendor SDK, runtime/auth/bootstrap clients avant `app.js`; aucun CSS/image modifié.**
- [ ] **Step 4: `auth-client` initialise Supabase seulement hors démo, avec `persistSession:true`, `autoRefreshToken:true`, `detectSessionInUrl:true`.**
- [ ] **Step 5: Brancher submit login** : Auth → access token → bootstrap → `renderWorkspace` à partir du contexte serveur.
- [ ] **Step 6: Mode `demo` conserve exactement le comportement actuel ; staging/production interdit le switch de rôle comme autorité.**
- [ ] **Step 7: Vérifier splash/guardian/auth DOM et styles inchangés par comparaison Git ciblée.**
- [ ] **Step 8: Commit.**

### Task 8: Tests RLS adversariaux obligatoires

**Files:**
- Create: `tests/rls/adversarial-access.sql`

- [ ] Parent A tente profil Parent B → refus.
- [ ] Teacher tente grant admin → refus.
- [ ] Cashier tente modifier `permissions` → refus.
- [ ] Utilisateur tente modifier son `profile_roles` → refus.
- [ ] JWT expiré → 401 au service.
- [ ] Aucun test ne requiert une donnée réelle.

### Task 9: Gate F1

Run:
```bash
npm ci
npm run build:auth-sdk
npm run typecheck
npm test
npm run supabase:start
npm run supabase:reset
npm run test:rls
```
Puis QA Auth sur staging.

Expected : tous les tests passent ; rôle/périmètre proviennent du serveur ; un rôle forgé échoue ; le sélecteur démo n’est pas autorité en staging ; aucune clé privilégiée n’est présente dans `app/`.

- [ ] Revue Security Agent.
- [ ] Revue Database/RLS Agent.
- [ ] Paquet de transfert F1.
- [ ] Ne pas avancer F2 sans staging F1 validé.
