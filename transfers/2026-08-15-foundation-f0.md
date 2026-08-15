# Transfer Package — FOUNDATION-F0-2026-08-15

**Statut :** `F0_TECHNICALLY_VALIDATED` — staging uniquement, validation humaine de transfert en attente.

## Référence officielle finale

- **Application :** `medygoo/schoolsafemm`
- **Production base :** `c347bef91b3fdbdca0d2a94e185b5914b5360d8e`
- **Branche F0 finale :** `staging/foundation-f0-2026-08-15`
- **PR application :** `medygoo/schoolsafemm#2` — draft, non fusionnée
- **Head F0 final vérifié :** `bacb860d3e2c9334604d8332ff0dd3200fceaa0f`
- **CI finale :** GitHub Actions run `31901086025`
- **Spec :** `docs/superpowers/specs/2026-08-15-fondation-production-design.md`
- **Plan :** `docs/superpowers/plans/2026-08-15-fondation-production-f0-contracts-tests.md`

> La référence préliminaire `staging/foundation-f0` / PR #1 / head `2a4d822...` enregistrée auparavant est **supersédée** par la référence finale ci-dessus. Elle ne doit plus être utilisée comme base du lot suivant.

## Objectif réalisé

Installer le socle technique F0 sans raccordement production : service Node/TypeScript, contrats health/readiness/erreurs, validation de configuration, catalogue de permissions, dépendances verrouillées et CI bloquante avec régression navigateur.

## Fichiers du diff final

La PR #2 contient 20 chemins :

- `.env.example`
- `.github/workflows/ci.yml`
- `package.json`
- `package-lock.json`
- `server/package.json`
- `server/src/access/permission-catalog.ts`
- `server/src/app.ts`
- `server/src/config/env.ts`
- `server/src/health/readiness.ts`
- `server/src/http/errors.ts`
- `server/src/http/request-id.ts`
- `server/src/index.ts`
- `server/tests/env.test.ts`
- `server/tests/errors.test.ts`
- `server/tests/health.test.ts`
- `server/tests/permission-catalog.test.ts`
- `server/tests/readiness.test.ts`
- `server/tsconfig.json`
- `server/vitest.config.ts`
- `shared/permissions.json`

**Aucun fichier `app/` n'est modifié.**

Le workflow production Pages `.github/workflows/static.yml` reste inchangé au SHA `e1c7851c35db9921a1d9debcc5b4e12a2e711d04`.

## Ce que F0 fournit

- workspace Node.js 22 + TypeScript strict ;
- service Fastify minimal ;
- `GET /health -> {status:"ok"}` ;
- `GET /ready` avec probe injectable et 503 `DEPENDENCY_UNAVAILABLE` ;
- validation Zod des variables d'environnement ;
- `.env.example` sans secret privilégié ;
- format public d'erreur `{code,message,request_id,retryable}` sans stack ;
- catalogue de 12 permissions machine stables ;
- Vitest + typecheck ;
- QA existantes `smoke`, `PWA/offline` et `i18n` rendues bloquantes ;
- CI PR read-only Linux + Windows ;
- scan d'affectations de secrets privilégiés ;
- audit npm bloquant à partir du niveau `high` ;
- GitHub Actions officielles épinglées par SHA : checkout v7.0.1 `3d3c42e5aac5ba805825da76410c181273ba90b1`, setup-node v7.0.0 `820762786026740c76f36085b0efc47a31fe5020`.

## Sécurité des dépendances

Le premier audit a correctement bloqué trois dépendances vulnérables : Fastify 5.4.0, Playwright 1.53.1 et Vitest 3.2.4.

Corrections finales épinglées :

- Fastify `5.12.0` ;
- Playwright `1.62.1` ;
- Vitest `3.2.7`.

Le lockfile a été régénéré sur la branche F0 puis le workflow temporaire de génération a été supprimé avant la validation finale.

## Preuves fraîches — head `bacb860...`

### Job `server-contracts` — PASS

Run `31901086025` :

- `npm ci` : **0 vulnérabilité** ;
- `npm audit --audit-level=high` : **0 vulnérabilité** ;
- TypeScript typecheck : PASS ;
- Vitest : **5 fichiers / 7 tests PASS** ;
- scan des affectations `SUPABASE_SERVICE_ROLE_KEY`, `R2_SECRET_ACCESS_KEY`, `VAPID_PRIVATE_KEY` : PASS.

### Job `existing-browser-qa` — PASS

Run `31901086025` sous Windows + Chrome :

- `qa-smoke.cjs` : `ok: true` ;
- `qa-pwa.cjs` : `ok: true` ;
- `qa-i18n.cjs` : `ok: true` ;
- sorties de preuve générées : dashboards, finance, EXETAT, PDFs, PWA offline/sync et interfaces anglaises desktop/mobile.

### Revue

PR #2 review `4944443488` : Security / Testing / Integration, aucun problème bloquant détecté dans le périmètre F0.

## Critères F0

- [x] isolation depuis le SHA production vérifié ;
- [x] `/health` ;
- [x] configuration validée ;
- [x] contrat d'erreur stable + `request_id` ;
- [x] catalogue de permissions ;
- [x] `/ready` ;
- [x] lockfile commité ;
- [x] typecheck et tests serveur ;
- [x] audit dépendances high/critical ;
- [x] scan secrets ;
- [x] QA navigateur existantes ;
- [x] aucun fichier `app/` modifié ;
- [x] workflow Pages production inchangé ;
- [x] revue Security/Testing/Integration ;
- [x] application `main` toujours sur `c347bef91b3fdbdca0d2a94e185b5914b5360d8e`.

## Risques résiduels

- F0 ne connecte ni Auth, ni PostgreSQL/RLS, ni VPS, ni R2 : c'est volontaire et couvert par F1→F4.
- Le service exige `SUPABASE_URL` et `SUPABASE_ANON_KEY` lors de son démarrage réel ; aucun environnement de production n'a été utilisé pour F0.
- F0 n'est pas un changement visuel : il n'existe donc pas de preview UI différente à approuver.

## Rollback

Tant que la PR #2 reste non fusionnée : fermer la PR et conserver/supprimer la branche F0. Aucun rollback production n'est requis puisque `schoolsafemm/main` n'a pas changé.

## Autorisation

**Production : NON AUTORISÉE.**

Le head `bacb860d3e2c9334604d8332ff0dd3200fceaa0f` est le candidat F0 à présenter au gate humain. Ne pas merger PR #2 et ne pas démarrer F1 avant décision humaine explicite.
