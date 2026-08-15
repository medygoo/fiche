# MASTER PROMPT — SchoolSafe Brain V1

Tu travailles avec **deux dépôts distincts** :
- cerveau : `medygoo/fiche` ;
- application réelle : `medygoo/schoolsafemm`.

## Étape 0 — Autorité et continuité

Avant toute autre action, lis entièrement :
1. `governance/SCHOOLSAFE-LAWS.md`
2. `00-CONTEXT.md`
3. `CONTROL-TOWER.md`
4. `CURRENT-STATE.md`
5. `HANDOFF.md`
6. `config/approved-tools.json`
7. `agents/agent-catalog.json`

Si l’état Git réel contredit ces documents, **GitHub vérifié prime** et tu mets les documents de continuité à jour avant de continuer.

## Étape 1 — Préflight sans mutation

Dans le projet cible :
- vérifie le dépôt distant ;
- branche actuelle ;
- commit HEAD ;
- `git status --short` ;
- stack et gestionnaire de paquets ;
- fichiers AGENTS/instructions existants ;
- secrets/configurations à ne jamais exposer.

Ne modifie rien pendant ce préflight.

## Étape 2 — Cerveau d’abord

Toute nouvelle modification importante doit d’abord avoir :
- contexte vérifié ;
- spec ;
- critères d’acceptation ;
- plan ;
- branche/worktree isolée ;
- agents responsables ;
- stratégie de test et rollback.

Utilise Superpowers et Spec Kit selon leur rôle. Utilise Repomix uniquement pour créer un contexte ciblé, en excluant secrets et données sensibles.

## Étape 3 — Outils approuvés

`config/approved-tools.json` est la source de vérité. Les outils core sont épinglés à des commits approuvés. Ne remplace jamais une référence silencieusement.

Pour préparer l’environnement, commence par :

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\bootstrap-school-safe-v2.ps1 -TargetProject "C:\SchoolSafe\schoolsafe-v2" -DryRun
```

Puis, après lecture du plan :

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\bootstrap-school-safe-v2.ps1 -TargetProject "C:\SchoolSafe\schoolsafe-v2"
```

Le mode par défaut ne modifie aucune dépendance du projet. Orca s’active avec `-InstallMultiAgent`. OpenHands/Aider sont manuels. Les outils de sécurité marqués `stable-release-required` nécessitent une revue de version avant installation.

## Étape 4 — Agents

Flux recommandé :

`Context Keeper → Architect → Product/Workflow → spécialistes → Testing → Security → Performance/Accessibility → Reviewer → Integration`.

Un agent = une branche/worktree lorsqu’il écrit. Deux agents ne modifient pas simultanément le même fichier sans contrat explicite.

## Étape 5 — Application réelle

Ne travaille jamais directement sur `main` de `medygoo/schoolsafemm` pour un changement important.

Un changement approuvé par le cerveau produit le paquet défini dans `protocols/TRANSFER-PACKAGE.md`, puis suit `protocols/STAGING.md`.

**Sans validation humaine explicite :**
- aucun merge vers production ;
- aucun déploiement ;
- aucune migration Supabase production ;
- aucune mutation VPS/Auth/RLS/Storage production.

## Étape 6 — Preuve

Avant de déclarer une tâche terminée :
- vérifier le diff réel ;
- exécuter les tests applicables ;
- effectuer la revue sécurité/qualité selon l’impact ;
- faire relire par Reviewer ;
- vérifier `git diff --check` et l’état Git ;
- préparer rollback et paquet de transfert.

## Étape 7 — Handoff

À chaque jalon important, mettre à jour :
- `CURRENT-STATE.md` ;
- `HANDOFF.md` ;
- `DECISIONS.md` si une décision durable a changé ;
- `CONTROL-TOWER.md` si version, risque ou priorité change.

Le but est qu’un nouveau chat puisse reprendre correctement sans relire tout l’historique.
