# Fondation Production F4 — R2 Files & Web Push Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ajouter un accès sécurisé aux fichiers Cloudflare R2 et une base Web Push rattachée aux profils/appareils, sans exposer de clés privées au frontend.

**Architecture:** PostgreSQL conserve les métadonnées et droits logiques. Le service SchoolSafe contrôle session/permission avant de signer une opération R2 ou de gérer un abonnement Push. Le navigateur ne reçoit que des URLs temporaires et la clé publique VAPID.

**Tech Stack:** Cloudflare R2 S3-compatible API, AWS SDK S3/presigner côté serveur, PostgreSQL/RLS, Web Push, Node.js/TypeScript/Fastify, JavaScript PWA, Vitest, Playwright.

## Global Constraints
- F1–F3 validés.
- Secrets R2 et clé privée VAPID uniquement côté serveur.
- PostgreSQL stocke métadonnées/références, pas le contenu binaire.
- URL signée de courte durée et créée seulement après contrôle de permission.
- Les fichiers publics et privés ont des politiques distinctes.
- Aucun envoi Push vers un abonnement appartenant à un autre profil/périmètre.
- Les notifications d’arrivées/sorties futures utilisent le socle Web Push ; F4 ne construit pas encore tout le module QR.

---

### Task 1: Créer métadonnées de fichiers et RLS

**Files:**
- Create: `supabase/migrations/202608150030_file_objects.sql`
- Create: `tests/rls/file-objects.sql`

**Interfaces:**
- Produces `file_objects` : id, bucket, object_key, owner_type, owner_id, visibility, mime_type, size_bytes, checksum, created_by, created_at, status.
- `object_key` est unique par bucket.

- [ ] Test rouge : Parent A ne peut pas lire métadonnée privée de Parent B.
- [ ] Test rouge : utilisateur sans permission ne peut pas créer métadonnée admin.
- [ ] Implémenter table, contraintes et RLS.
- [ ] Interdire stockage de secrets/URLs signées persistantes dans la table.
- [ ] PASS puis commit.

### Task 2: Configurer le client R2 uniquement côté serveur

**Files:**
- Create: `server/src/files/r2-client.ts`
- Extend: `server/src/config/env.ts`
- Create: `server/tests/r2-client.test.ts`

**Interfaces:**
- `createR2Client(env)` retourne client S3 configuré avec endpoint/account staging/test.
- Aucun module sous `app/` n’importe AWS SDK.

- [ ] Test rouge : configuration R2 incomplète → erreur de démarrage contrôlée lorsque feature activée.
- [ ] Installer dépendances serveur S3/presigner et verrouiller dans lockfile.
- [ ] Implémenter client injectable pour tests.
- [ ] Vérifier que bundle/static `app/` ne contient pas `R2_SECRET_ACCESS_KEY` ni credentials.
- [ ] Commit.

### Task 3: Implémenter signature upload

**Files:**
- Create: `server/src/files/schema.ts`
- Create: `server/src/files/service.ts`
- Create: `server/src/files/routes.ts`
- Modify: `server/src/app.ts`
- Create: `server/tests/files-upload.test.ts`

**Interfaces:**
- `POST /files/sign-upload`
- Entrée : `{owner_type, owner_id, filename, mime_type, size_bytes, visibility}`.
- Sortie : `{file_id, upload_url, expires_at, required_headers}`.

- [ ] Test rouge : fichier hors périmètre → 403.
- [ ] Test rouge : taille supérieure à la limite par catégorie → 400.
- [ ] Test rouge : type non autorisé → 400.
- [ ] Implémenter permission avant création métadonnée/signature.
- [ ] Générer `object_key` serveur ; ne jamais accepter une clé R2 arbitraire du client.
- [ ] Durée signature upload initiale : 10 minutes maximum.
- [ ] PASS puis commit.

### Task 4: Implémenter confirmation d’upload

**Files:**
- Extend: `server/src/files/routes.ts`
- Extend: `server/src/files/service.ts`
- Create: `server/tests/files-confirm.test.ts`

**Interfaces:**
- `POST /files/:id/confirm` vérifie l’existence/metadata objet avant passage `pending -> available`.

- [ ] Test rouge : objet absent → métadonnée reste pending.
- [ ] Test rouge : taille/MIME incohérent → rejet et audit.
- [ ] Implémenter HEAD objet côté R2.
- [ ] Enregistrer checksum lorsque disponible/validé.
- [ ] Commit.

### Task 5: Implémenter signature download

**Files:**
- Extend: `server/src/files/routes.ts`
- Extend: `server/src/files/service.ts`
- Create: `server/tests/files-download.test.ts`

**Interfaces:**
- `POST /files/sign-download` entrée `{file_id}` ; sortie `{download_url, expires_at}`.

- [ ] Test rouge : Parent A demande fichier Parent B → 403 et aucune URL créée.
- [ ] Test rouge : fichier privé supprimé/indisponible → 404 contrôlé.
- [ ] Implémenter contrôle RLS + permission métier.
- [ ] Durée initiale signature download : 5 minutes maximum.
- [ ] PASS puis commit.

### Task 6: Créer `files-client` frontend

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
- [ ] Ne raccorder à un module métier que dans sa future spec ; F4 prouve le client avec fixture staging dédiée.
- [ ] Commit.

### Task 7: Créer les abonnements Web Push

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
- [ ] Implémenter en dérivant `profile_id` de la session.
- [ ] PASS puis commit.

### Task 8: Ajouter client Push et Service Worker

**Files:**
- Create: `app/clients/notification-client.js`
- Modify targeted: `app/sw.js`
- Modify minimally: `app/index.html`
- Create: `app/qa-push.cjs`

**Interfaces:**
- `SchoolSafeNotifications.subscribe()` utilise uniquement `VAPID_PUBLIC_KEY` publique fournie par runtime config.
- Service worker traite `push` et `notificationclick` sans exposer payload sensible sur écran verrouillé au-delà du contenu autorisé.

- [ ] QA rouge : clé privée absente du frontend.
- [ ] QA rouge : permission navigateur refusée ne casse pas l’application.
- [ ] Implémenter abonnement et enregistrement serveur.
- [ ] Bumper cache Service Worker uniquement si nécessaire au déploiement staging ; documenter l’impact.
- [ ] Commit.

### Task 9: Préparer l’envoi serveur sans brancher les métiers

**Files:**
- Create: `server/src/notifications/sender.ts`
- Create: `server/tests/notification-sender.test.ts`

**Interfaces:**
- `sendToProfiles(profileIds, notification)` filtre les abonnements actifs côté serveur.

- [ ] Test rouge : abonnement d’un profil non ciblé n’est jamais envoyé.
- [ ] Test rouge : endpoint expiré/410 est désactivé après échec contrôlé.
- [ ] Implémenter sender injectable ; en tests aucun appel Internet réel.
- [ ] Ne pas encore créer les règles métier entrée/sortie/retard ; elles appartiennent aux specs de modules ultérieurs.
- [ ] Commit.

### Task 10: Gate F4 et gate Fondation

Run:
```bash
npm run typecheck
npm test
npm run test:rls
npm run test:e2e:staging
```
Expected: PASS.

Contrôles obligatoires :
- aucune clé privilégiée dans `app/` ou artifact Pages ;
- R2 autre périmètre refusé avant signature ;
- upload confirmé uniquement si objet conforme ;
- abonnement Push rattaché à session/appareil ;
- aucune notification inter-profil non autorisée ;
- URLs signées expirables ;
- production inchangée.

- [ ] Security review F4.
- [ ] Paquet de transfert F4.
- [ ] Exécuter ensuite le Gate Fondation du plan maître.
- [ ] Arrêter avant production et demander validation humaine.
