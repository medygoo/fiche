# Fondation Production F1 — Auth, Access & Bootstrap Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remplacer l’identité et les permissions de démonstration par Supabase Auth, un modèle d’accès PostgreSQL/RLS et un bootstrap serveur vérifiable, uniquement dans un environnement de test/staging.

**Architecture:** Supabase Auth prouve l’identité. PostgreSQL conserve profils, rôles, grants et périmètres. Le service SchoolSafe vérifie le JWT et retourne un contexte calculé ; le frontend utilise ce contexte pour afficher l’espace, mais les politiques RLS restent l’autorité finale.

**Tech Stack:** Supabase Auth/PostgreSQL, SQL/RLS, Node.js/TypeScript/Fastify, `@supabase/supabase-js`, Vitest, tests SQL/intégration.

## Global Constraints
- F0 doit être vert avant F1.
- Aucune migration production.
- Aucun rôle reçu du navigateur n’est digne de confiance.
- `service_role` reste uniquement côté serveur.
- Le sélecteur de rôle de démonstration est autorisé uniquement quand `APP_MODE=demo`.
- Les écrans visuels d’authentification restent inchangés sauf branchement comportemental.

---

### Task 1: Créer le schéma identité et accès

**Files:**
- Create: `supabase/migrations/202608150001_foundation_identity_access.sql`
- Modify: `supabase/seed.sql`
- Create: `tests/rls/foundation-access.sql`

**Interfaces:**
- Produces tables: `school`, `school_settings`, `profiles`, `roles`, `permissions`, `profile_roles`, `role_permission_grants`, `scope_assignments`, `audit_events`.
- `profiles.auth_user_id` référence `auth.users(id)` de manière unique.

- [ ] **Step 1: Écrire le test SQL rouge** vérifiant que les tables n’existent pas et que l’accès anonyme est refusé.
- [ ] **Step 2: Exécuter le test sur la base de test** et confirmer l’échec attendu.
- [ ] **Step 3: Écrire la migration** avec UUID, timestamps UTC, contraintes d’unicité et FK explicites. `audit_events` n’autorise aucune UPDATE/DELETE via rôles applicatifs.
- [ ] **Step 4: Seed synthétique** : une école, rôles `admin`, `school_head`, `pedagogy`, `teacher`, `cashier`, `guard`, `parent`, plus permissions du catalogue F0.
- [ ] **Step 5: Rejouer les tests** et confirmer PASS.
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
- Produces politiques RLS pour profil propre, lecture configuration utile, rôles/grants du profil courant et audit autorisé.

- [ ] **Step 1: Tests négatifs rouges** : parent lit profil d’un autre utilisateur → refus ; enseignant modifie grant → refus ; utilisateur forge rôle → refus.
- [ ] **Step 2: Activer RLS sur chaque table exposable.**
- [ ] **Step 3: Ajouter policies minimalistes ; aucune policy `using (true)` générale.**
- [ ] **Step 4: Tests positifs** : chaque profil lit son propre contexte autorisé.
- [ ] **Step 5: Tests négatifs** tous verts.
- [ ] **Step 6: Commit.**

### Task 4: Vérifier le JWT côté service

**Files:**
- Create: `server/src/auth/session.ts`
- Create: `server/src/auth/types.ts`
- Modify: `server/src/app.ts`
- Create: `server/tests/auth-session.test.ts`

**Interfaces:**
- Produces `requireSession(request): Promise<AuthenticatedSession>` avec `{userId,email?,phone?}`.

- [ ] **Step 1: Test rouge** : requête sans Bearer token → HTTP 401 `AUTH_REQUIRED`.
- [ ] **Step 2: Test rouge** : token invalide → 401 sans exposer le token.
- [ ] **Step 3: Implémenter vérification auprès de Supabase Auth/client serveur approprié.**
- [ ] **Step 4: Test token de l’environnement de test → session acceptée.**
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
- [ ] **Step 3: Implémenter lecture serveur depuis `auth_user_id` uniquement.**
- [ ] **Step 4: Tester parent/teacher/admin synthétiques avec résultats distincts.**
- [ ] **Step 5: Commit.**

### Task 6: Créer les clients frontend sans modifier la présentation

**Files:**
- Create: `app/clients/runtime-config.js`
- Create: `app/clients/auth-client.js`
- Create: `app/clients/bootstrap-client.js`
- Modify minimally: `app/index.html`
- Modify minimally: `app/app.js`
- Create: `app/qa-auth.cjs`

**Interfaces:**
- `window.SchoolSafeAuth.signIn(credentials)`
- `window.SchoolSafeAuth.signOut()`
- `window.SchoolSafeAuth.session()`
- `window.SchoolSafeBootstrap.load(accessToken)`

- [ ] **Step 1: Écrire QA rouge** : en mode `production/staging`, `#workspaceRoleSwitch` ne doit pas permettre de changer l’identité effective.
- [ ] **Step 2: Écrire QA rouge** : formulaire de login doit appeler Auth et ne pas ouvrir workspace sur secret invalide.
- [ ] **Step 3: Charger les nouveaux clients avant `app.js` sans changer CSS/images.**
- [ ] **Step 4: Brancher le submit login** : Auth → bootstrap → `renderWorkspace` à partir du rôle serveur autorisé.
- [ ] **Step 5: Conserver le comportement actuel uniquement si `APP_MODE === "demo"`.**
- [ ] **Step 6: Vérifier que splash/guardian/auth DOM et styles n’ont pas changé.**
- [ ] **Step 7: Commit.**

### Task 7: Tests RLS adversariaux obligatoires

**Files:**
- Create: `tests/rls/adversarial-access.sql`

- [ ] Parent A tente profil Parent B → refus.
- [ ] Teacher tente grant admin → refus.
- [ ] Cashier tente modifier `permissions` → refus.
- [ ] Pedagogy tente lecture d’une donnée explicitement hors scope lorsque F2 l’ajoute → test préparé et marqué comme dépendance F2 par nom de scénario, sans test vide.
- [ ] JWT expiré → 401 au service.
- [ ] Aucun test ne requiert une donnée réelle.

### Task 8: Gate F1

Run:
```bash
npm run typecheck
npm test
npm run test:rls
node app/server.mjs
```
Puis QA Auth sur staging.

Expected : tous les tests passent ; un utilisateur ne peut pas choisir son rôle ; `session/bootstrap` provient du serveur ; aucune clé privilégiée n’est présente dans `app/`.

- [ ] Revue Security Agent.
- [ ] Revue Database/RLS Agent.
- [ ] Paquet de transfert F1.
- [ ] Ne pas avancer F2 sans staging F1 validé.
