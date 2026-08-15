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

## Fondation Production — F0
- Branche application : `staging/foundation-f0`.
- PR application : `medygoo/schoolsafemm#1`, draft, non fusionnée.
- Base : `c347bef91b3fdbdca0d2a94e185b5914b5360d8e`.
- Head validé techniquement : `2a4d822256aa1122e30867c835693f65f27ebe5e`.
- Implémenté : service Node/TypeScript minimal, `/health`, `/ready`, validation env, contrat d’erreur + `request_id`, catalogue de 12 permissions, Vitest, Playwright verrouillé, CI serveur + QA navigateur + scan secrets.
- GitHub Actions final : run `31900150659`, jobs `server-contracts` PASS et `existing-browser-qa` PASS.
- Diff F0 : aucun fichier `app/` modifié ; `.github/workflows/static.yml` inchangé SHA `e1c7851c35db9921a1d9debcc5b4e12a2e711d04`.
- Paquet de transfert : `transfers/2026-08-15-foundation-f0.md`.

## Autorisation
- F0 est `F0_TECHNICALLY_VALIDATED`.
- Production : NON AUTORISÉE.
- F1 ne démarre qu’après validation humaine explicite de F0.

## Prochain jalon
Après validation humaine, créer `staging/foundation-f1` depuis le head F0 approuvé et exécuter le plan Auth + Access + Bootstrap. Ne pas merger automatiquement F0 dans `schoolsafemm/main`.
