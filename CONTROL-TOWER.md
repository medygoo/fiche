# CONTROL TOWER — SchoolSafe

**Brain:** V1 — ACTIF
**Brain repo:** `medygoo/fiche`
**Application repo:** `medygoo/schoolsafemm`
**Production branch:** `main`
**Production commit vérifié:** `c347bef91b3fdbdca0d2a94e185b5914b5360d8e`
**Fondation Production:** F0 exécuté sur staging, attente gate humain.

## Travail courant
La branche cerveau `brain-audit-fondation-production-2026-08-15` contient l’audit Phase B, la conception Fondation Production validée, les plans F0 → F4 et le paquet de transfert F0.

Côté application, F0 existe sur `staging/foundation-f0`, head `2a4d822256aa1122e30867c835693f65f27ebe5e`, PR #1 en draft. Production non modifiée.

## Preuves actuelles
- F0 : 17 commits devant `main`, 0 derrière.
- CI `SchoolSafe CI` run `31900150659` : SUCCESS.
- Job `server-contracts` : SUCCESS.
- Job `existing-browser-qa` : SUCCESS.
- Scan affectations de secrets privilégiés suivis : SUCCESS.
- Aucun fichier visuel existant `app/` modifié.
- Workflow Pages de production inchangé.
- Revue Backend/Testing/Security : PASS F0.
- Transfer package : `transfers/2026-08-15-foundation-f0.md`.

## Prochaine priorité
Gate humain F0. Après validation : préparer F1 Auth + RLS + bootstrap sur une nouvelle branche isolée. Ne pas fusionner automatiquement F0 vers `schoolsafemm/main`.

## Gates
- Contexte : PASS
- Audit Phase B : PASS
- Conception Fondation : VALIDÉE
- Plans F0 → F4 : PASS
- F0 code/contrats : PASS
- F0 tests serveur : PASS
- F0 QA navigateur : PASS
- F0 sécurité basique : PASS
- F0 revue : PASS
- F0 gate humain : EN ATTENTE
- F1 : BLOQUÉ jusqu’au gate humain F0
- Production : BLOQUÉE sans validation explicite

## Règle de fraîcheur
Toujours revérifier les SHA GitHub avant toute écriture. Ce fichier indique des jalons, pas une supposition sur une tête de branche future.

## Risque principal
Confondre staging et production ou interpréter un CI vert comme autorisation de merge. Une preuve technique ne remplace jamais la validation humaine requise.

## Dernier transfert production
Harmonisation visuelle V3 : `c347bef91b3fdbdca0d2a94e185b5914b5360d8e`.
