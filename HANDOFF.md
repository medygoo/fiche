# HANDOFF — Relais entre conversations

## État au 15 août 2026
Brain V1 est opérationnel sur `medygoo/fiche/main`. L’intégration initiale a été faite via PR #1 ; le protocole Superpowers Skills a été intégré via PR #2. Les branches de construction sont conservées comme archives de travail.

## Ce qui existe maintenant
- Loi 0 de continuité + Six Lois SchoolSafe.
- `00-CONTEXT`, `CONTROL-TOWER`, `CURRENT-STATE`, `DECISIONS`, `MASTER-PLAN`, `HANDOFF`.
- 12 cerveaux spécialisés avec gates.
- Core tools épinglés : Superpowers, Spec Kit, Repomix, Orca.
- Protocole obligatoire `protocols/SUPERPOWERS-SKILLS.md` : brainstorming, planification, isolation, TDD/debug, travail parallèle, revue, vérification et finition de branche selon la tâche.
- Spécialistes manuels : OpenHands, Aider.
- Registre de risque, registre de versions et release gates.
- Cycle cerveau → paquet de transfert → staging → validation humaine → production.
- Bootstrap sûr : aucune dépendance applicative installée par défaut, aucune mise à jour silencieuse d’outil.
- GitHub Actions de validation uniquement, sans déploiement.

## Preuve
- PR #1 : fusionnée ; CI PR PASS ; CI post-fusion PASS.
- PR #2 : fusionnée ; CI PR PASS ; CI post-fusion PASS.
- Jalon Brain V1 : `6dd2ca7c790970e1b88c3e092f327d9de1c8c43c`.
- Jalon Skills : `d7d5b153a32d9cab20dbefbcdff19246be386259`.

## Application
`medygoo/schoolsafemm` n’a pas été modifié pendant ces intégrations. Production de référence : `c347bef91b3fdbdca0d2a94e185b5914b5360d8e`.

## Reprise d’un nouveau chat
Lire `governance/SCHOOLSAFE-LAWS.md` → `00-CONTEXT.md` → `CONTROL-TOWER.md` → `CURRENT-STATE.md` → ce fichier → `protocols/SUPERPOWERS-SKILLS.md`, puis vérifier GitHub et le SHA courant avant toute écriture.

## Prochaine action
Lancer par le cerveau un audit factuel de `schoolsafemm` pour construire la carte : terminé / partiel / manquant / risqué / prochaine priorité.
