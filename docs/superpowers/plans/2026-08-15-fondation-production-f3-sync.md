# Fondation Production F3 — Real Offline Sync Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remplacer le `demoAdapter` de synchronisation par un contrat serveur idempotent, versionné et auditable, tout en conservant la file IndexedDB et le comportement offline existants.

**Architecture:** La PWA crée des opérations immuables locales. `POST /sync/batch` authentifie l’utilisateur, contrôle permission/périmètre, applique l’idempotence, détecte les conflits de version et retourne un résultat individuel par opération. Aucune opération n’est déclarée confirmée avant réponse serveur.

**Tech Stack:** IndexedDB existant, JavaScript PWA, Node.js/TypeScript/Fastify/Zod, PostgreSQL, Vitest, Playwright.

## Global Constraints
- F1/F2 validés.
- Priorité actuelle des files préservée : sécurité, urgent, devoirs, présences, pédagogie, finance/RH/administration.
- Pas d’écrasement silencieux en conflit.
- Une même `idempotency_key` ne crée jamais deux effets métier.
- Une session offline expirée conserve la file mais exige une nouvelle authentification en ligne.
- Aucun reçu officiel généré avant confirmation serveur.

---

### Task 1: Créer le registre serveur des opérations sync

**Files:**
- Create: `supabase/migrations/202608150020_sync_operations.sql`
- Create: `tests/rls/sync-operations.sql`

**Interfaces:**
- Produces `sync_operations` : `id`, `idempotency_key`, `profile_id`, `device_id`, `operation_type`, `entity_type`, `entity_id`, `expected_version`, `payload_hash`, `status`, `server_version`, `result`, `created_at`, `processed_at`.
- Unique : `(profile_id, idempotency_key)`.

- [ ] Test rouge : insertion de même clé deux fois ne produit pas deux lignes métier.
- [ ] Test rouge : utilisateur ne lit pas les opérations d’un autre profil.
- [ ] Implémenter migration, index et RLS.
- [ ] PASS puis commit.

### Task 2: Définir le contrat TypeScript du batch

**Files:**
- Create: `server/src/sync/schema.ts`
- Create: `server/src/sync/types.ts`
- Create: `server/tests/sync-schema.test.ts`

**Interfaces:**
```ts
type SyncOperationInput = {
  id: string;
  idempotency_key: string;
  type: string;
  entity_type: string;
  entity_id?: string;
  expected_version?: number;
  device_id: string;
  created_at: string;
  payload: unknown;
};

type SyncOperationResult = {
  id: string;
  status: "accepted" | "rejected" | "conflict" | "retryable_error";
  server_version?: number;
  official_id?: string;
  code?: string;
};
```

- [ ] Tests rouges : clé vide, date invalide, payload hors limite, batch trop grand.
- [ ] Implémenter Zod avec taille maximale explicite et batch maximum 50 opérations.
- [ ] PASS puis commit.

### Task 3: Implémenter idempotence avant effet métier

**Files:**
- Create: `server/src/sync/idempotency.ts`
- Create: `server/tests/sync-idempotency.test.ts`

**Interfaces:**
- `reserveOperation(session, input)` retourne `new | replay`.
- Un replay retourne le résultat enregistré sans réexécuter l’effet.

- [ ] Test rouge : même batch soumis deux fois → handler métier appelé exactement une fois.
- [ ] Implémenter réservation transactionnelle.
- [ ] Test concurrence avec deux requêtes simultanées même clé.
- [ ] PASS puis commit.

### Task 4: Implémenter la détection de conflits de version

**Files:**
- Create: `server/src/sync/versioning.ts`
- Create: `server/tests/sync-conflict.test.ts`

**Interfaces:**
- `assertExpectedVersion(expected, actual)` produit `VERSION_CONFLICT` sans écriture si différent.

- [ ] Test rouge : client version 3, serveur version 4 → `conflict` et valeur serveur inchangée.
- [ ] Test rouge : version correcte → accepted + version incrémentée.
- [ ] Implémenter contrôle transactionnel.
- [ ] PASS puis commit.

### Task 5: Implémenter `POST /sync/batch`

**Files:**
- Create: `server/src/sync/service.ts`
- Create: `server/src/sync/routes.ts`
- Modify: `server/src/app.ts`
- Create: `server/tests/sync-route.test.ts`

**Interfaces:**
- Auth F1 obligatoire.
- Réponse `{request_id, results: SyncOperationResult[]}` dans le même ordre que les entrées.

- [ ] Test rouge sans session → 401.
- [ ] Test rouge opération sans permission → `rejected/PERMISSION_DENIED`.
- [ ] Test rouge mélange accepted/conflict/retryable → chaque résultat indépendant.
- [ ] Implémenter route, dispatcher par type et audit.
- [ ] Les types F3 initiaux supportent au minimum les écritures F2 prévues ; les types pédagogie/finance restent rejetés proprement tant que leurs handlers de production n’existent pas.
- [ ] PASS puis commit.

### Task 6: Remplacer le demoAdapter seulement hors démo

**Files:**
- Create: `app/clients/sync-client.js`
- Modify targeted: `app/offline-sync.js`
- Modify targeted: `app/app.js`
- Create: `app/qa-sync-server.cjs`

**Interfaces:**
- `SchoolSafeSyncServer.sendBatch(operations, accessToken)`.
- `demoAdapter` demeure disponible uniquement pour `APP_MODE=demo`.

- [ ] QA rouge : mode staging ne doit jamais produire `demo-synced` sans appel serveur.
- [ ] QA rouge : erreur réseau laisse opération `pending/retryable`.
- [ ] Adapter `offline-sync.js` pour envoyer lot et appliquer les résultats serveur.
- [ ] Ne pas changer les libellés/animations de l’interface de sync existante.
- [ ] PASS puis commit.

### Task 7: Appliquer les règles de session offline

**Files:**
- Create: `app/clients/offline-session.js`
- Create: `app/qa-offline-session.cjs`
- Modify targeted: `app/app.js`

**Interfaces:**
- Politique reçue du bootstrap F1.
- `canOperateOffline(lastOnlineAuthAt, policy, role)` retourne booléen et n’efface jamais la file.

- [ ] Tests : administration/caisse/RH 24h ; enseignants/personnel 72h ; parent 7 jours ; garde 7 jours sur appareil scolaire autorisé.
- [ ] Après expiration : lecture locale autorisée selon politique, nouvelles actions sensibles bloquées et reconnexion exigée ; file existante conservée.
- [ ] Commit.

### Task 8: Observabilité sync sans données sensibles

**Files:**
- Create: `server/src/sync/metrics.ts`
- Create: `server/tests/sync-logging.test.ts`

- [ ] Logs incluent `request_id`, operation id, type, status, durée ; excluent secrets, mots de passe et payload sensible complet.
- [ ] Test recherche qu’un payload contenant `secret-marker-123` n’apparaît pas dans le logger capturé.
- [ ] Commit.

### Task 9: Gate F3

Scénarios E2E staging obligatoires :
1. online → action → accepted ;
2. offline → action conservée → reconnexion → accepted ;
3. replay même opération → aucune duplication ;
4. conflit de version → aucune écriture silencieuse ;
5. session offline expirée → file conservée, action sensible bloquée ;
6. serveur indisponible → `retryable_error`, reprise ultérieure.

Run:
```bash
npm run typecheck
npm test
npm run test:rls
npm run test:e2e:staging
```
Expected: PASS.

- [ ] Security review.
- [ ] Vérifier absence de `demo-synced` en staging réel.
- [ ] Paquet de transfert F3.
- [ ] Validation staging avant F4.
