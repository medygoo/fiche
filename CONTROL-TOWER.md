# CONTROL TOWER — SchoolSafe

**Brain:** V1 — ACTIF
**Brain repo:** `medygoo/fiche`
**Fondation plans intégrés:** PR #4, merge `e3322d20b0ef86b9dfb1b861c032c895fa735b54`
**Application repo:** `medygoo/schoolsafemm`
**Production branch:** `main`
**Production commit vérifié:** `c347bef91b3fdbdca0d2a94e185b5914b5360d8e`
**Production état:** GitHub Pages V3 inchangée.

## Travail courant
Fondation Production F0 exécutée et techniquement validée en staging uniquement.

- Branche officielle finale : `staging/foundation-f0-2026-08-15`
- PR : `schoolsafemm#2` — draft / non fusionnée
- Base : `c347bef91b3fdbdca0d2a94e185b5914b5360d8e`
- Head : `bacb860d3e2c9334604d8332ff0dd3200fceaa0f`
- Paquet : `transfers/2026-08-15-foundation-f0.md`
- Statut : `F0_TECHNICALLY_VALIDATED`
- Référence antérieure PR #1 / `staging/foundation-f0` : SUPERSÉDÉE

## Preuves actuelles
- GitHub Actions final `31901086025` : `server-contracts` PASS.
- `npm ci` + `npm audit --audit-level=high` : 0 vulnérabilité.
- Typecheck : PASS.
- Vitest : 5 fichiers / 7 tests PASS.
- Scan de secrets privilégiés : PASS.
- GitHub Actions final `31901086025` : `existing-browser-qa` PASS.
- QA smoke : PASS ; PWA/offline : PASS ; i18n : PASS.
- Revue F0 PR #2 `4944443488` : aucun problème bloquant.
- Diff PR #2 : aucun fichier `app/` modifié.
- Workflow production Pages inchangé SHA `e1c7851c35db9921a1d9debcc5b4e12a2e711d04`.
- Production `main` toujours sur `c347bef91b3fdbdca0d2a94e185b5914b5360d8e`.

## Sécurité dépendances
- Fastify : `5.12.0`.
- Playwright : `1.62.1`.
- Vitest : `3.2.7`.
- Actions GitHub épinglées par SHA : checkout v7.0.1 + setup-node v7.0.0.
- Gate `npm audit --audit-level=high` obligatoire dans la CI F0.

## Gates
- Contexte : PASS
- Audit Phase B : PASS
- Conception Fondation : APPROUVÉE
- Plan F0→F4 : PASS / intégré Brain main
- F0 contrats/service : PASS
- F0 dépendances/security audit : PASS
- F0 typecheck/tests : PASS
- F0 sécurité/secrets : PASS
- F0 QA navigateur : PASS
- F0 revue : PASS
- F0 validation humaine : EN ATTENTE
- F1 : BLOQUÉ jusqu’à validation humaine F0
- Production application : BLOQUÉE / NON AUTORISÉE

## Prochaine priorité
Présenter le head F0 `bacb860d3e2c9334604d8332ff0dd3200fceaa0f` au gate humain. Après validation, créer une branche F1 depuis ce head approuvé et exécuter Auth + Access + Bootstrap. Aucun merge production automatique.

## Règle de fraîcheur
Revérifier toujours les SHAs GitHub avant écriture. Les valeurs ci-dessus sont des jalons de preuve, jamais une permission implicite de déploiement.

## Risque principal
Ne jamais confondre validation technique de staging avec autorisation production.

## Dernier transfert production
Harmonisation visuelle V3 : `c347bef91b3fdbdca0d2a94e185b5914b5360d8e`.
