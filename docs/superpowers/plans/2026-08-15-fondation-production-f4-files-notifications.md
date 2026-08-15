# Fondation Production F4 — R2 Files & Web Push Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ajouter un accès sécurisé aux fichiers Cloudflare R2 et une base Web Push rattachée aux profils/appareils, sans exposer de clés privées au frontend.

**Architecture:** PostgreSQL conserve les métadonnées et droits logiques. Le service SchoolSafe contrôle session/permission avant de signer une opération R2 ou de gérer un abonnement Push. Le navigateur ne reçoit que des URLs temporaires et la clé publique VAPID. La Fondation ne généralise pas encore l’upload de documents potentiellement actifs : seul un profil de fichier de staging à faible risque est activé tant qu’un scanner antivirus de documents n’a pas sa propre spec validée.

**Tech Stack:** Cloudflare R2 S3-compatible API, AWS SDK S3/presigner côté serveur, PostgreSQL/RLS, `web-push`, Node.js/TypeScript/Fastify, JavaScript PWA, Vitest, Playwright.

## Global Constraints
- F1–F3 validés.
- Secrets R2 et clé privée VAPID uniquement côté serveur.
- PostgreSQL stocke métadonnées/références, pas le contenu binaire.
- URL signée de courte durée et créée seulement après contrôle de permission.
- Les fichiers publics et privés ont des politiques distinctes.
- Aucun envoi Push vers un abonnement appartenant à un autre profil/périmètre.
- Les notifications d’arrivées/sorties futures utilisent le socle Web Push ; F4 ne construit pas encore tout le module QR.
- F4 active en staging le purpose `foundation-test-image` uniquement, MIME `image/png` et `image/jpeg`, maximum 10 MiB. PDF, Office, archives et exécutables restent refusés jusqu’à validation d’une politique de scan documentaire.

---

### Task 1: Créer métadonnées de fichiers et RLS

**Files:**
- Create: `supabase/migrations/202608150030_file_objects.sql`
- Create: `tests/rls/file-objects.sql`

**Interfaces:**
- Produces `file_objects` : id, bucket, object_key, purpose, owner_type, owner_id, visibility, mime_type, size_bytes, checksum, created_by, created_at, status.
- `object_key` est unique par bucket.
- États F4 : `pending`, `available`, `rejected`, `deleted`.

- [ ] Test rouge : Parent A ne peut pas lire métadonnée privée de Parent B.
- [ ] Test rouge : utilisateur sans permission ne peut pas créer métadonnée admin.
- [ ] Implémenter table, contraintes et RLS.
- [ ] Interdire stockage de secrets/URLs signées persistantes dans la table.
- [ ] PASS puis commit.

### Task 2: Installer et configurer le client R2 uniquement côté serveur

**Files:**
- Create: `server/src/files/r2-client.ts`
- Extend: `server/src/config/env.ts`
- Modify: `server/package.json`
- Modify: `package-lock.json`
- Create: `server/tests/r2-client.test.ts`

**Interfaces:**
- `createR2Client(env)` retourne un `S3Client` configuré avec endpoint staging/test.
- Aucun module sous `app/` n’importe AWS SDK.

- [ ] **Step 1: Installer les dépendances exactes**

Run:
```bash
npm install --workspace server @aws-sdk/client-s3 @aws-sdk/s3-request-presigner web-push
npm install -D --workspace server @types/web-push
```
Expected: lockfile mis à jour.

- [ ] **Step 2: Étendre `AppEnv`**

Variables serveur requises quand la feature fichiers est activée : `R2_ENDPOINT`, `R2_REGION` (défaut `auto`), `R2_BUCKET_PRIVATE`, `R2_ACCESS_KEY_ID`, `R2_SECRET_ACCESS_KEY`. Variables Push : `VAPID_PUBLIC_KEY`, `VAPID_PRIVATE_KEY`, `VAPID_SUBJECT`.

- [ ] **Step 3: Test rouge** : configuration R2 incomplète → erreur contrôlée lorsque feature activée.
- [ ] **Step 4: Implémenter client injectable** pour tests ; aucun appel R2 réel dans tests unitaires.
- [ ] **Step 5: Vérifier** que `app/` ne contient ni `R2_SECRET_ACCESS_KEY`, ni access key, ni `VAPID_PRIVATE_KEY`.
- [ ] **Step 6: Commit**.

### Task 3: Implémenter la politique de fichiers F4

**Files:**
- Create: `server/src/files/policy.ts`
- Create: `server/tests/file-policy.test.ts`

**Interfaces:**
```ts
type FilePurposePolicy = {
  purpose: string;
  allowedMimeTypes: readonly string[];
  maxBytes: number;
};
```
Politique initiale unique :
```ts
{
  purpose: "foundation-test-image",
  allowedMimeTypes: ["image/png", "image/jpeg"],
  maxBytes: 10 * 1024 * 1024
}
```

- [ ] Test rouge : `application/pdf`, ZIP, EXE et MIME vide sont refusés en F4.
- [ ] Test rouge : image >10 MiB refusée.
- [ ] Implémenter `getFilePolicy(purpose)` et `assertFileAllowed(input)`.
- [ ] PASS puis commit.

### Task 4: Implémenter signature upload

**Files:**
- Create: `server/src/files/schema.ts`
- Create: `server/src/files/service.ts`
- Create: `server/src/files/routes.ts`
- Modify: `server/src/app.ts`
- Create: `server/tests/files-upload.test.ts`

**Interfaces:**
- `POST /files/sign-upload`
- Entrée : `{purpose, owner_type, owner_id, filename, mime_type, size_bytes, visibility}`.
- Sortie : `{file_id, upload_url, expires_at, required_headers}`.

- [ ] Test rouge : owner hors périmètre → 403.
- [ ] Test rouge : purpose inconnu → 400.
- [ ] Test rouge : PDF ou taille > limite → 400.
- [ ] Implémenter permission puis `assertFileAllowed` avant création métadonnée/signature.
- [ ] Générer `object_key` serveur avec UUID ; ne jamais accepter une clé R2 arbitraire du client.
- [ ] Durée signature upload : maximum 10 minutes.
- [ ] PASS puis commit.

### Task 5: Implémenter confirmation d’upload

**Files:**
- Extend: `server/src/files/routes.ts`
- Extend: `server/src/files/service.ts`
- Create: `server/tests/files-confirm.test.ts`

**Interfaces:**
- `POST /files/:id/confirm` vérifie l’objet avant passage `pending -> available`.

- [ ] Test rouge : objet absent → métadonnée reste `pending`.
- [ ] Test rouge : taille/MIME incohérent → `rejected` + audit.
- [ ] Implémenter `HeadObjectCommand` injecté pour tests.
- [ ] Enregistrer checksum/ETag seulement comme métadonnée de contrôle ; ne pas l’interpréter comme preuve antivirus.
- [ ] Commit.

### Task 6: Implémenter signature download

**Files:**
- Extend: `server/src/files/routes.ts`
- Extend: `server/src/files/service.ts`
- Create: `server/tests/files-download.test.ts`

**Interfaces:**
- `POST /files/sign-download` entrée `{file_id}` ; sortie `{download_url, expires_at}`.

- [ ] Test rouge : Parent A demande fichier Parent B → 403 et aucune URL créée.
- [ ] Test rouge : fichier `pending/rejected/deleted` → aucune URL.
- [ ] Implémenter contrôle RLS + permission métier.
- [ ] Durée signature download : maximum 5 minutes.
- [ ] PASS puis commit.

### Task 7: Créer `files-client` frontend

**Files:**
- Create: `app/clients/files-client.js`
- Modify minimally: `app/index.html`
- Create: `app/qa-files.cjs`

**Interfaces:**
- `SchoolSafeFiles.requestUpload(meta)`
- `SchoolSafeFiles.confirmUpload(fileId)`
- `SchoolSafeFiles.requestDownload(fileId)`

- [ ] QA rouge : aucune clé AWS/R2 dans `window`, source HTML ou fichiers JS publics.
- [ ] Implémenter client Bearer token.
- [ ] F4 ne raccorde le client qu’à une fixture staging technique `foundation-test-image`; aucun document élève réel.
- [ ] Commit.

### Task 8: Créer les abonnements Web Push

**Files:**
- Create: `supabase/migrations/202608150031_notification_subscriptions.sql`
- Create: `tests/rls/notification-subscriptions.sql`
- Create: `server/src/notifications/schema.ts`
- Create: `server/src/notifications/service.ts`
- Create: `server/src/notifications/routes.ts`
- Create: `server/tests/notifications.test.ts`

**Interfaces:**
- Table `notification_subscriptions` rattachée à `profile_id` + `device_id`, endpoint unique, statut actif, timestamps.
- `POST /notifications/subscriptions` upsert pour l’utilisateur courant.
- `DELETE /notifications/subscriptions/:id` uniquement propriétaire/autorité admin contrôlée.

- [ ] Test rouge : utilisateur ne peut créer abonnement pour un autre `profile_id` fourni dans body.
- [ ] Test rouge : suppression abonnement autre profil → 403.
- [ ] Implémenter en dérivant `profile_id` de la session et en validant `device_id` du profil.
- [ ] PASS puis commit.

### Task 9: Ajouter client Push et Service Worker

**Files:**
- Create: `app/clients/notification-client.js`
- Modify targeted: `app/sw.js`
- Modify minimally: `app/index.html`
- Create: `app/qa-push.cjs`

**Interfaces:**
- `SchoolSafeNotifications.subscribe()` utilise uniquement `vapidPublicKey` fournie par `SchoolSafeRuntime`.
- Service worker traite `push` et `notificationclick` sans afficher de donnée sensible non nécessaire sur écran verrouillé.

- [ ] QA rouge : clé privée absente du frontend.
- [ ] QA rouge : permission navigateur refusée ne casse pas l’application.
- [ ] Implémenter abonnement et enregistrement serveur.
- [ ] Bumper cache Service Worker uniquement si nécessaire au staging ; vérifier la régression PWA existante.
- [ ] Commit.

### Task 10: Préparer l’envoi serveur sans brancher les métiers

**Files:**
- Create: `server/src/notifications/sender.ts`
- Create: `server/tests/notification-sender.test.ts`

**Interfaces:**
- `sendToProfiles(profileIds, notification)` filtre les abonnements actifs côté serveur et utilise `web-push` configuré avec VAPID serveur.

- [ ] Test rouge : abonnement d’un profil non ciblé n’est jamais envoyé.
- [ ] Test rouge : endpoint expiré/HTTP 410 est désactivé après échec contrôlé.
- [ ] Implémenter sender avec transport injectable ; tests sans Internet réel.
- [ ] Ne pas créer les règles métier entrée/sortie/retard ; elles appartiennent aux specs de modules ultérieurs.
- [ ] Commit.

### Task 11: Gate F4 et Gate Fondation

Run:
```bash
npm ci
npm run build:auth-sdk
npm run typecheck
npm test
npm run supabase:start
npm run supabase:reset
npm run test:rls
npm run test:e2e:staging
```
Expected: PASS.

Contrôles obligatoires :
- aucune clé privilégiée dans `app/` ou artifact frontend ;
- R2 autre périmètre refusé avant signature ;
- upload confirmé uniquement si objet conforme ;
- PDF/archives/exécutables refusés par la Fondation ;
- abonnement Push rattaché à session/appareil ;
- aucune notification inter-profil non autorisée ;
- URLs signées expirables ;
- production inchangée.

- [ ] Security review F4.
- [ ] Paquet de transfert F4.
- [ ] Exécuter ensuite le Gate Fondation du plan maître.
- [ ] Arrêter avant production et demander validation humaine.
