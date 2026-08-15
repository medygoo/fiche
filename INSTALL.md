# Installation — SchoolSafe Brain V1

Cette procédure prépare le cerveau **sans modifier l’application SchoolSafe par défaut**.

## 1. Lire la constitution

Avant toute installation :
1. `governance/SCHOOLSAFE-LAWS.md`
2. `00-CONTEXT.md`
3. `CONTROL-TOWER.md`
4. `config/approved-tools.json`

## 2. Vérifier le projet cible

Dans SchoolSafe V2, contrôler en lecture seule :
- dépôt distant ;
- branche ;
- commit HEAD ;
- `git status --short` ;
- stack/lockfile ;
- AGENTS/instructions ;
- fichiers `.env*` et secrets à exclure des outils de contexte/scans.

Aucune modification existante ne doit être écrasée.

## 3. Cache local

Le cache recommandé reste :

```text
C:\SchoolSafe\AI-TOOLS
```

Les dépôts externes ne sont jamais recopiés dans le code métier. `config/approved-tools.json` définit les références approuvées.

### Noyau par défaut
- Superpowers
- GitHub Spec Kit
- Repomix

### Multi-agent optionnel
- Orca avec `-InstallMultiAgent`

### Spécialistes optionnels
- OpenHands
- Aider

Ils s’activent uniquement avec `-InstallSpecialists` et restent soumis à une tâche bornée, une branche isolée et une revue.

### Sécurité
Semgrep, Trivy, Gitleaks et Safe Chain sont enregistrés comme gates de sécurité. Quand leur entrée demande `stable-release-required`, choisir et enregistrer d’abord une version stable approuvée au lieu de suivre automatiquement la branche principale.

## 4. Dry-run obligatoire recommandé

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\bootstrap-school-safe-v2.ps1 -TargetProject "C:\SchoolSafe\schoolsafe-v2" -DryRun
```

Ce mode doit montrer ce qui serait préparé sans réseau ni mutation de l’application.

## 5. Installation du noyau

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\bootstrap-school-safe-v2.ps1 -TargetProject "C:\SchoolSafe\schoolsafe-v2"
```

Le script réutilise les caches existants. S’il trouve un outil à un commit différent du commit approuvé, il signale **REVIEW NEEDED** et n’effectue pas de mise à jour silencieuse.

## 6. Dépendances applicatives

Les bibliothèques frontend/test listées dans `config/tools-manifest.json` sont **conseillées, pas installées automatiquement**.

`-InstallProjectDependencies` est une option explicite qui modifie les fichiers package de l’application. Elle ne doit être utilisée que sur une branche/worktree applicatif approuvé après analyse de compatibilité.

## 7. Multi-agents

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\bootstrap-school-safe-v2.ps1 -TargetProject "C:\SchoolSafe\schoolsafe-v2" -InstallMultiAgent
```

Lire `docs/MULTI-AGENT-ARCHITECTURE.md` et `agents/` avant d’orchestrer plusieurs agents.

## 8. Validation du cerveau

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\validate-brain.ps1
```

La validation échoue si les documents obligatoires manquent, si les JSON sont invalides, si les outils core ne sont pas épinglés ou si l’approbation humaine de production est désactivée.

## 9. Passage vers l’application

Après travail dans le cerveau :
1. créer le paquet `protocols/TRANSFER-PACKAGE.md` ;
2. créer une branche `staging/<change-id>` dans `medygoo/schoolsafemm` ;
3. appliquer uniquement le changement approuvé ;
4. tester ;
5. présenter l’aperçu ;
6. attendre la validation humaine explicite ;
7. seulement ensuite envisager production.

Aucune installation du cerveau n’autorise à elle seule un déploiement, une migration Supabase ou une mutation VPS/Auth/RLS/Storage.
