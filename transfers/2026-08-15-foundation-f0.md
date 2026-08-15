# Transfer Package — FOUNDATION-F0-2026-08-15

**Objectif :** Installer les contrats, tests et gates de Fondation Production F0 sans modifier l’interface SchoolSafe ni la production.
**Application base commit :** `c347bef91b3fdbdca0d2a94e185b5914b5360d8e`
**Application head candidat :** `2a4d822256aa1122e30867c835693f65f27ebe5e`
**Spec :** `docs/superpowers/specs/2026-08-15-fondation-production-design.md`
**Plan :** `docs/superpowers/plans/2026-08-15-fondation-production-f0-contracts-tests.md`
**Branche application candidate :** `staging/foundation-f0`
**PR application :** `medygoo/schoolsafemm#1`

## Fichiers
- Ajoutés : `.env.example`, `.github/workflows/ci.yml`, `package.json`, `package-lock.json`, `server/**`, `shared/permissions.json`.
- Modifiés : aucun fichier visuel existant sous `app/`; aucun workflow de production existant.
- Supprimés : aucun.

## Preuves
- Diff : 17 commits devant `main`, 0 derrière.
- CI : `SchoolSafe CI` run `31900150659` = SUCCESS.
- Job `server-contracts` = SUCCESS.
- Job `existing-browser-qa` = SUCCESS.
- Scan des affectations suivies de `SUPABASE_SERVICE_ROLE_KEY`, `R2_SECRET_ACCESS_KEY`, `VAPID_PRIVATE_KEY` = SUCCESS.
- Revue Backend/Testing/Security ajoutée à la PR #1 : PASS pour F0.

## Risques
- Les dépendances Node sont nouvelles dans le dépôt ; leur évolution future doit rester contrôlée par lockfile et revue.
- F0 ne prouve encore aucune Auth, RLS ou connexion Supabase réelle : ces capacités appartiennent à F1.
- Le workflow Pages actuel n’est pas encore bloqué par cette CI ; cette séparation est intentionnelle à F0 et la politique de release reste contrôlée par validation humaine.

## Rollback
- Ne pas merger la PR #1 : rollback immédiat = conserver `main` au SHA de base.
- Si F0 est ultérieurement intégré puis refusé, créer un commit de rollback qui retire uniquement les fichiers ajoutés par F0 ; ne pas utiliser `reset --hard` ni force push.

## Critères d’acceptation
- Service `/health` et `/ready` testés.
- Configuration rejetant les variables obligatoires manquantes.
- Format d’erreur stable sans stack publique.
- Catalogue de permissions stable et validé.
- CI serveur et QA navigateur vertes.
- Aucun fichier visuel protégé modifié.
- Aucun secret réel ni mutation de production.

## Staging
**Branche :** `staging/foundation-f0`
**PR :** `medygoo/schoolsafemm#1`
**Statut :** prêt pour gate humain F0 ; PR conservée en draft.

## Autorisation production
**Statut :** NON AUTORISÉ.
**Validation humaine explicite :** requise avant tout merge vers `schoolsafemm/main`.
