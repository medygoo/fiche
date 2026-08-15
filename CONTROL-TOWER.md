# CONTROL TOWER — SchoolSafe

**Brain:** V1 — ACTIF
**Brain repo:** `medygoo/fiche`
**Fondation plans intégrés:** PR #4, merge `e3322d20b0ef86b9dfb1b861c032c895fa735b54`
**Application repo:** `medygoo/schoolsafemm`
**Production branch:** `main`
**Production commit vérifié:** `c347bef91b3fdbdca0d2a94e185b5914b5360d8e`
**Production état:** GitHub Pages V3 inchangée.

## Travail courant
Fondation Production F0 exécutée en staging uniquement.

- Branche : `staging/foundation-f0`
- PR : `schoolsafemm#1` — draft / non fusionnée
- Head : `2a4d822256aa1122e30867c835693f65f27ebe5e`
- Paquet : `transfers/2026-08-15-foundation-f0.md`
- Statut : `F0_TECHNICALLY_VALIDATED`

## Preuves actuelles
- TDD RED→GREEN appliqué aux contrats health, env, errors, permissions et readiness.
- GitHub Actions `31900150659` : `server-contracts` PASS.
- GitHub Actions `31900150659` : `existing-browser-qa` PASS.
- Scan de secrets privilégiés : PASS.
- Revue F0 : aucun Critical/Important.
- Diff base→F0 : aucun fichier `app/` modifié.
- Workflow production Pages base/staging : même SHA `e1c7851c35db9921a1d9debcc5b4e12a2e711d04`.

## Gates
- Contexte : PASS
- Audit Phase B : PASS
- Conception Fondation : APPROUVÉE
- Plan F0→F4 : PASS / intégré Brain main
- F0 contrats/service : PASS
- F0 typecheck/tests : PASS
- F0 sécurité/secrets : PASS
- F0 QA navigateur : PASS
- F0 revue : PASS
- F0 validation humaine : EN ATTENTE
- F1 : BLOQUÉ jusqu’à validation humaine F0
- Production application : BLOQUÉE / NON AUTORISÉE

## Prochaine priorité
Après validation humaine de F0, créer `staging/foundation-f1` depuis le head F0 approuvé et exécuter Auth + Access + Bootstrap sans toucher à `schoolsafemm/main`.

## Règle de fraîcheur
Revérifier toujours les SHAs GitHub avant écriture. Les valeurs ci-dessus sont des jalons de preuve, pas une permission implicite de déploiement.

## Risque principal
Ne jamais confondre validation technique de staging avec autorisation production.

## Dernier transfert production
Harmonisation visuelle V3 : `c347bef91b3fdbdca0d2a94e185b5914b5360d8e`.
