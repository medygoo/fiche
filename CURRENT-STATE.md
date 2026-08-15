# État actuel — SchoolSafe

## Application réelle
- Dépôt : `medygoo/schoolsafemm`.
- Branche production : `main`.
- Commit production vérifié : `c347bef91b3fdbdca0d2a94e185b5914b5360d8e`.
- GitHub Pages publie toujours `app/` ; aucun changement F0 n’a été fusionné en production.
- Harmonisation visuelle V3 inchangée.

## Cerveau
- Dépôt : `medygoo/fiche`.
- Brain V1, Loi 0, Six Lois, 12 agents, outils core et protocole Superpowers actifs.
- Audit Phase B + conception Fondation Production + plans maître/F0/F1/F2/F3/F4 intégrés à `main` via PR #4, merge `e3322d20b0ef86b9dfb1b861c032c895fa735b54`.

## Fondation Production — F0 référence finale
- Branche application : `staging/foundation-f0-2026-08-15`.
- PR application : `medygoo/schoolsafemm#2`, draft, non fusionnée.
- Base : `c347bef91b3fdbdca0d2a94e185b5914b5360d8e`.
- Head techniquement validé : `bacb860d3e2c9334604d8332ff0dd3200fceaa0f`.
- La référence préliminaire `staging/foundation-f0` / PR #1 / `2a4d822...` est supersédée et ne doit pas servir de base à F1.
- Implémenté : service Node/TypeScript/Fastify, `/health`, `/ready`, validation env, contrat d’erreur + `request_id`, catalogue de 12 permissions, lockfile, Vitest/typecheck, CI serveur + QA navigateur + audit npm + scan secrets.
- Dépendances de sécurité corrigées : Fastify 5.12.0, Playwright 1.62.1, Vitest 3.2.7.
- Actions GitHub CI épinglées par SHA aux releases checkout v7.0.1 et setup-node v7.0.0.
- GitHub Actions final : run `31901086025`.
- `server-contracts` : PASS — 0 vulnérabilité, audit high/critical PASS, 5 fichiers/7 tests PASS, scan secrets PASS.
- `existing-browser-qa` : PASS — smoke, PWA/offline et i18n.
- Diff F0 : aucun fichier `app/` modifié ; `.github/workflows/static.yml` inchangé SHA `e1c7851c35db9921a1d9debcc5b4e12a2e711d04`.
- Revue PR #2 : `4944443488`, aucun blocage F0.
- Paquet de transfert : `transfers/2026-08-15-foundation-f0.md`.

## Autorisation
- F0 est `F0_TECHNICALLY_VALIDATED`.
- Production : NON AUTORISÉE.
- PR #2 ne doit pas être fusionnée sans validation humaine explicite.
- F1 ne démarre qu’après décision humaine sur ce head F0 final.

## Prochain jalon
Présenter F0 au gate humain. Après validation explicite, utiliser `bacb860d3e2c9334604d8332ff0dd3200fceaa0f` comme base approuvée de F1 sur une nouvelle branche de staging. Ne pas merger automatiquement F0 dans `schoolsafemm/main`.
