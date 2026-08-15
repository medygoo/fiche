# SchoolSafe V2 Fondation Production — Master Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Construire dans `medygoo/schoolsafemm` un socle production sécurisé et testable permettant de remplacer progressivement les données de démonstration par Auth, PostgreSQL/RLS, synchronisation serveur, R2 et Web Push, sans refondre l’interface validée.

**Architecture:** La PWA statique existante reste la couche de présentation. Un service SchoolSafe Node.js/TypeScript expose des contrats HTTP étroits et utilise Supabase Auth/PostgreSQL comme autorité d’identité et de données. Les lots F0 à F4 sont indépendamment testables et sont exécutés séquentiellement afin que chaque lot fournisse les interfaces du suivant.

**Tech Stack:** HTML/CSS/JavaScript existants, Node.js, TypeScript, Fastify, Zod, Supabase Auth/PostgreSQL/RLS, Cloudflare R2 S3 API, Web Push, Vitest, Playwright, GitHub Actions, Docker/Supabase local ou environnement de test isolé.

## Global Constraints

- Source applicative : `medygoo/schoolsafemm`; base de conception auditée : `c347bef91b3fdbdca0d2a94e185b5914b5360d8e`.
- Le cerveau `medygoo/fiche` contient la spec et les plans ; il ne remplace pas le dépôt applicatif.
- Ne jamais travailler directement sur `schoolsafemm/main` ; utiliser une branche/worktree de staging dédiée.
- Ne jamais muter Supabase/VPS/R2 de production sans analyse d’impact et autorisation humaine explicite.
- Aucun `service_role`, secret R2, clé privée VAPID ou secret SMTP dans le navigateur ou dans Git.
- L’interface, les photos, textes, animations, splash, galerie, authentification visuelle et thème V3 restent protégés sauf nécessité explicitement validée.
- Le frontend n’est jamais l’autorité des rôles, permissions ou périmètres.
- Une instance SchoolSafe correspond à une école ; aucun sélecteur multi-écoles dans l’application.
- Les tests utilisent uniquement des données synthétiques.
- Les dépendances installées sont épinglées par le lockfile ; pas de mise à jour majeure silencieuse.
- TDD obligatoire pour code fonctionnel : test rouge → implémentation minimale → test vert → refactorisation sûre.
- Aucun lot n’est déclaré prêt sans preuves fraîches de tests, sécurité et diff.
- Production reste bloquée après staging jusqu’à validation humaine explicite.

---

## Découpage obligatoire

Cette Fondation couvre plusieurs sous-systèmes. Elle ne doit pas être implémentée comme un seul gros chantier. Utiliser les plans suivants dans cet ordre :

1. `2026-08-15-fondation-production-f0-contracts-tests.md`
2. `2026-08-15-fondation-production-f1-auth-access.md`
3. `2026-08-15-fondation-production-f2-school-core.md`
4. `2026-08-15-fondation-production-f3-sync.md`
5. `2026-08-15-fondation-production-f4-files-notifications.md`

Chaque lot a son propre gate, ses propres tests et son propre paquet de transfert. Ne commencer le lot suivant qu’après validation du lot précédent dans staging.

**Important :** ce document est un plan d’exécution, pas une autorisation d’exécution. Le passage de la branche Cerveau vers une branche de `schoolsafemm` intervient seulement après choix explicite du mode d’exécution et création d’un workspace isolé conformément aux Lois SchoolSafe.

## Carte de fichiers cible

### Racine applicative

- `package.json` — scripts communs de validation, test et E2E.
- `package-lock.json` — versions exactes des dépendances.
- `.env.example` — noms de variables sans aucune valeur secrète.
- `.github/workflows/ci.yml` — validation PR sans déploiement production.
- `.github/workflows/staging.yml` — futur transport du candidat validé vers un environnement staging séparé, uniquement après approbation de sa cible d’infrastructure.

### Service SchoolSafe

- `server/package.json` — dépendances du service.
- `server/tsconfig.json` — compilation TypeScript stricte.
- `server/src/app.ts` — construction de l’application Fastify.
- `server/src/index.ts` — démarrage du processus.
- `server/src/config/env.ts` — validation des variables d’environnement.
- `server/src/http/errors.ts` — format d’erreur stable.
- `server/src/http/request-id.ts` — corrélation des requêtes.
- `server/src/auth/` — vérification session et contexte d’utilisateur.
- `server/src/bootstrap/` — endpoint `POST /session/bootstrap`.
- `server/src/school/` — données scolaires fondamentales F2.
- `server/src/sync/` — idempotence et conflits F3.
- `server/src/files/` — métadonnées et URLs R2 signées F4.
- `server/src/notifications/` — abonnements Web Push F4.
- `server/tests/` — tests unitaires et intégration.

### Base

- `supabase/config.toml` — configuration locale/test.
- `supabase/migrations/` — migrations ordonnées ; rollback de production uniquement par migration compensatoire validée.
- `supabase/seed.sql` — données synthétiques déterministes de test.
- `tests/rls/` — scénarios d’accès autorisé et refusé exécutés sur Supabase local.

### PWA

- `app/runtime-config.js` — valeurs publiques de runtime, démo par défaut dans Git.
- `app/clients/runtime-config.js` — lecture de configuration publique.
- `app/clients/auth-client.js` — session frontend.
- `app/clients/bootstrap-client.js` — contexte serveur.
- `app/clients/data-client.js` — données scolaires.
- `app/clients/sync-client.js` — adaptateur serveur de la file offline.
- `app/clients/files-client.js` — appels de signature de fichiers.
- `app/clients/notification-client.js` — abonnement Web Push.

`app/app.js` reste orchestrateur UI pendant la Fondation ; ne pas le découper globalement. Modifier uniquement les points de raccordement nécessaires et protéger les comportements existants par tests.

---

### Task 1: Préparer l’isolation applicative avant F0

**Files:** aucun fichier métier au démarrage.

**Interfaces:**
- Consumes: `schoolsafemm/main` vérifié au moment de l’exécution.
- Produces: branche/worktree `staging/foundation-f0` ou nom équivalent, avec SHA de base enregistré dans le paquet de transfert.

- [ ] **Step 1: Vérifier la branche production**

Run:
```bash
git fetch origin
git rev-parse origin/main
git status --short
```
Expected: SHA connu, workspace propre.

- [ ] **Step 2: Créer l’isolation**

Run selon `superpowers:using-git-worktrees` :
```bash
git worktree add .worktrees/foundation-f0 -b staging/foundation-f0 origin/main
```
Expected: nouveau worktree sans modification de `main`.

- [ ] **Step 3: Vérifier le baseline frontend**

Run:
```bash
node app/server.mjs
```
Puis exécuter les QA existantes selon le plan F0. Si le baseline échoue, arrêter et diagnostiquer avant F0.

### Task 2: Exécuter F0 — contrats et preuve automatisée

**Files:** voir plan F0.

**Interfaces:**
- Consumes: frontend V2 intact.
- Produces: format d’erreur, permission IDs, environnement de test, CI PR, service minimal `/health` et `/ready`, scripts E2E existants rendus bloquants.

- [ ] Exécuter entièrement le plan F0 avec TDD.
- [ ] Produire le paquet de transfert F0.
- [ ] Exécuter tests unitaires, typecheck, QA navigateur existante et scan secrets.
- [ ] Revue indépendante du diff F0.
- [ ] Staging technique F0 ; aucun merge production.

### Task 3: Exécuter F1 — Auth, RLS et bootstrap

**Files:** voir plan F1.

**Interfaces:**
- Consumes: contrats F0.
- Produces: Supabase local de test, identité réelle de test, rôle/permissions/scopes côté serveur, RLS de fondation et `POST /session/bootstrap`.

- [ ] Exécuter entièrement le plan F1 avec TDD et tests RLS négatifs.
- [ ] Prouver qu’un rôle forgé par le navigateur n’accorde aucun droit.
- [ ] Prouver que le sélecteur de rôle est inactif comme autorité hors mode démo.
- [ ] Staging F1 et revue humaine avant F2.

### Task 4: Exécuter F2 — élèves, familles, classes et personnes autorisées

**Files:** voir plan F2.

**Interfaces:**
- Consumes: session/bootstrap F1.
- Produces: source de vérité scolaire minimale et lectures filtrées par périmètre.

- [ ] Exécuter le plan F2.
- [ ] Prouver qu’un parent ne lit que ses enfants.
- [ ] Prouver qu’un enseignant ne lit que ses classes affectées.
- [ ] Prouver que le profil pédagogique ne reçoit aucun montant financier.
- [ ] Staging F2 et revue humaine avant F3.

### Task 5: Exécuter F3 — synchronisation réelle

**Files:** voir plan F3.

**Interfaces:**
- Consumes: identité et données F1/F2.
- Produces: `POST /sync/batch`, idempotence, conflits, reprise et adaptateur PWA non-démo.

- [ ] Exécuter le plan F3.
- [ ] Rejouer la même opération et prouver l’absence de doublon.
- [ ] Provoquer un conflit de version et prouver qu’aucune donnée n’est écrasée silencieusement.
- [ ] Vérifier offline → reconnexion → confirmation serveur.
- [ ] Staging F3 et revue humaine avant F4.

### Task 6: Exécuter F4 — R2 et Web Push de base

**Files:** voir plan F4.

**Interfaces:**
- Consumes: session, permissions et audit.
- Produces: signatures R2 autorisées, métadonnées de fichiers et abonnements Web Push.

- [ ] Exécuter le plan F4.
- [ ] Prouver qu’une URL de fichier d’un autre périmètre n’est jamais signée.
- [ ] Prouver qu’aucune clé privée n’apparaît dans l’artifact frontend.
- [ ] Prouver qu’un abonnement Push appartient au profil/appareil authentifié.
- [ ] Staging F4 et revue humaine.

### Task 7: Gate Fondation Production

**Files:**
- Modify only after evidence: documentation de statut et paquet de transfert.

**Interfaces:**
- Consumes: preuves F0–F4.
- Produces: décision `foundation-ready-for-module-integration` ou liste explicite de blocages.

- [ ] **Step 1: Lancer la suite serveur et RLS**

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
Expected: exit code 0 pour chaque commande.

- [ ] **Step 2: Lancer la preuve navigateur**

Régression locale :
```bash
npm run test:e2e:existing
```

Candidat staging réellement déployé : définir `SCHOOLSAFE_URL` vers l’URL staging puis exécuter :
```bash
npm run test:e2e:staging
```
Expected: exit 0. Si aucune cible staging en ligne n’a encore été autorisée/provisionnée, le gate reste bloqué ici ; un artifact CI n’est pas présenté comme un staging en ligne.

- [ ] **Step 3: Vérifier sécurité**

Exécuter les scanners approuvés du Cerveau et vérifier manuellement l’absence de `service_role`, secret R2, clé privée VAPID et données réelles dans les artifacts/logs.

- [ ] **Step 4: Vérifier les critères de la spec**

Checklist obligatoire : authentification réelle de test, rôles serveur, refus RLS, parent isolé, pédagogie sans montants, idempotence, conflit préservé, R2 signé, Push rattaché, staging distinct de production.

- [ ] **Step 5: Produire le paquet de transfert**

Inclure base SHA, head SHA, fichiers, migrations, résultats de tests, risques, rollback et captures de staging utiles.

- [ ] **Step 6: Arrêter au gate humain**

Ne pas merger/déployer en production. Présenter le staging et attendre l’autorisation explicite.

---

## Règle de continuité entre chats

À la fin de chaque lot, le Cerveau met à jour `CURRENT-STATE.md`, `HANDOFF.md`, `CONTROL-TOWER.md` et `DECISIONS.md` si une décision a changé. Un nouveau chat ne charge que le plan du lot actif, la spec, les Lois et les fichiers applicatifs ciblés ; il ne recharge pas automatiquement tous les plans F0–F4.
