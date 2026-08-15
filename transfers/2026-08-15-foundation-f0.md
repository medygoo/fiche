# Transfer Package — FOUNDATION-F0-2026-08-15

**Objectif :** Installer le socle technique F0 de la Fondation Production : service Node/TypeScript minimal, contrats health/readiness/erreurs, validation de configuration, catalogue de permissions et CI bloquante, sans raccordement production.
**Application base commit :** `c347bef91b3fdbdca0d2a94e185b5914b5360d8e`
**Application candidate commit :** `2a4d822256aa1122e30867c835693f65f27ebe5e`
**Spec :** `docs/superpowers/specs/2026-08-15-fondation-production-design.md`
**Plan :** `docs/superpowers/plans/2026-08-15-fondation-production-f0-contracts-tests.md`
**Branche application candidate :** `staging/foundation-f0`
**PR application :** `medygoo/schoolsafemm#1` — draft, non fusionnée.

## Fichiers
- Ajoutés : `.env.example`, `.github/workflows/ci.yml`, `package.json`, `package-lock.json`, `server/**`, `shared/permissions.json`.
- Modifiés dans `app/` : aucun.
- Supprimés : aucun.
- Workflow Pages `.github/workflows/static.yml` : inchangé, SHA base = SHA staging = `e1c7851c35db9921a1d9debcc5b4e12a2e711d04`.

## Preuves
- TDD Task 1 : RED confirmé sur absence de `buildApp`, puis GREEN `/health`.
- TDD Task 2 : RED confirmé sur absence de `parseEnv`, puis GREEN configuration.
- TDD Task 3 : RED comportemental 404 sur `/__test/error`, puis GREEN contrat d’erreur stable + `request_id`.
- TDD Task 4 : RED sur absence du catalogue, puis GREEN 12 permissions stables/uniques.
- TDD Task 5 : RED 404 sur `/ready`, puis GREEN 200/503 selon probe.
- GitHub Actions final : run `31900150659`.
- Job `server-contracts` : PASS — `npm ci`, typecheck, tous les tests serveur, scan de secrets.
- Job `existing-browser-qa` : PASS — QA existantes smoke/PWA/i18n sur Windows + Chrome.
- Sécurité : aucune affectation suivie de `SUPABASE_SERVICE_ROLE_KEY`, `R2_SECRET_ACCESS_KEY` ou `VAPID_PRIVATE_KEY` ; aucune clé privilégiée ajoutée au frontend.
- Revue diff-only : PR #1 review `4944411252`, aucun problème Critical/Important détecté.
- Diff : 20 fichiers ajoutés, aucun fichier `app/` modifié.

## Risques
- F0 ne connecte encore ni Auth, ni PostgreSQL/RLS, ni VPS, ni R2 : ce sont les lots suivants.
- Le nouveau service exige `SUPABASE_URL` et `SUPABASE_ANON_KEY` lorsqu’il est démarré ; `.env.example` utilise uniquement des valeurs locales non secrètes.
- Les actions GitHub v4 affichent un avertissement de runtime interne Node, sans échec ; le runtime applicatif testé reste Node 22.
- Aucun aperçu UI séparé n’est nécessaire pour F0 car le patrimoine visuel est byte-for-byte hors diff ; la validation navigateur a été faite par CI.

## Rollback
Fermer la PR `medygoo/schoolsafemm#1` et supprimer/conserver la branche `staging/foundation-f0`. Comme `schoolsafemm/main` n’a pas été modifié, aucun rollback production n’est requis.

## Critères d’acceptation
- [x] `GET /health` répond `{status:"ok"}`.
- [x] Configuration invalide refusée sans secret dans Git.
- [x] Erreurs publiques au format `{code,message,request_id,retryable}` sans stack.
- [x] 12 identifiants de permissions stables et validés.
- [x] `GET /ready` distingue processus sain et dépendance indisponible.
- [x] Typecheck et tests serveur PASS.
- [x] QA navigateur existantes PASS.
- [x] Scan de secrets PASS.
- [x] Aucun fichier visuel/app modifié.
- [x] Workflow Pages inchangé.

## Staging
**Branche :** `staging/foundation-f0`
**Head :** `2a4d822256aa1122e30867c835693f65f27ebe5e`
**Aperçu :** staging technique via PR + GitHub Actions ; aucun changement UI à prévisualiser.
**Statut :** `F0_TECHNICALLY_VALIDATED`.

## Autorisation production
**Statut :** NON AUTORISÉ.
**Validation humaine explicite :** en attente.

## Gate suivant
Après validation humaine de F0, créer `staging/foundation-f1` depuis le head F0 approuvé et exécuter F1 Auth + Access + Bootstrap. Ne pas fusionner automatiquement F0 dans `schoolsafemm/main`.
