# School Safe V2 Engineering Pack Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Installer un environnement Codex multi-agents, design, tests, sécurité et performance autour de School Safe V2 sans casser le projet existant.

**Architecture:** Les outils lourds sont mis en cache dans `C:\SchoolSafe\AI-TOOLS`, tandis que les dépendances frontend réellement nécessaires sont ajoutées au projet après détection du gestionnaire de paquets. Les agents travaillent dans des worktrees isolés et passent par tests, sécurité et revue avant intégration.

**Tech Stack:** Codex CLI, Git, PowerShell, React/TypeScript, outils npm, Spec Kit, Superpowers, Repomix, Playwright, Vitest, MSW, axe-core, Semgrep, Trivy, Betterleaks, Safe Chain, Lighthouse CI, Renovate.

## Global Constraints

- Aucun merge dans `main` sans autorisation explicite.
- Aucun force push.
- Aucun déploiement production pendant l’installation.
- Aucune mutation Supabase/VPS de production.
- Réutiliser les téléchargements et installations existants.
- Préserver toutes les modifications locales déjà présentes.

---

### Task 1: Préparer le cache local et le bootstrap

**Files:**
- Use: `scripts/bootstrap-school-safe-v2.ps1`
- Use: `config/tools-manifest.json`

**Interfaces:**
- Consumes: chemin local du projet School Safe V2.
- Produces: cache `C:\SchoolSafe\AI-TOOLS` et dépendances projet compatibles.

- [ ] **Step 1: Vérifier les prérequis**

Run:
```powershell
codex --version
git --version
node --version
npm --version
```
Expected: chaque commande retourne une version.

- [ ] **Step 2: Exécuter le bootstrap**

Run:
```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\bootstrap-school-safe-v2.ps1 -TargetProject "C:\SchoolSafe\schoolsafe-v2"
```
Expected: les dépôts manquants sont clonés une seule fois et les dépendances compatibles sont ajoutées.

- [ ] **Step 3: Vérifier le cache**

Run:
```powershell
Get-ChildItem C:\SchoolSafe\AI-TOOLS
```
Expected: dossiers `spec-kit`, `superpowers`, `repomix`, `agent-orchestrator`, `semgrep`, `trivy`, `betterleaks`, `safe-chain`.

### Task 2: Configurer Codex et les agents

**Files:**
- Use: `codex/MASTER-INSTALL-PROMPT.md`
- Use: `AGENTS.template.md`
- Use: `docs/MULTI-AGENT-ARCHITECTURE.md`

**Interfaces:**
- Consumes: dépôt School Safe V2 existant.
- Produces: `AGENTS.md`, Skills/MCP compatibles et worktrees par rôle.

- [ ] **Step 1: Ouvrir Codex dans le projet**

Run:
```powershell
cd C:\SchoolSafe\schoolsafe-v2
codex
```
Expected: interface Codex ouverte à la racine du projet.

- [ ] **Step 2: Charger le prompt maître**

Instruction:
```text
Lis le fichier codex/MASTER-INSTALL-PROMPT.md du pack School Safe V2 et exécute-le intégralement depuis l’état actuel du projet.
```
Expected: Codex suit les règles de sécurité et évite toute action production.

- [ ] **Step 3: Vérifier l’isolation multi-agents**

Run:
```powershell
git worktree list
```
Expected: les worktrees créés sont distincts lorsqu’un travail parallèle est lancé.

### Task 3: Configurer qualité, tests et sécurité

**Files:**
- Modify only if compatible: project configs for Biome, Vitest, Playwright, Storybook, Lighthouse and CI.

**Interfaces:**
- Consumes: stack réellement détectée.
- Produces: commandes de test et scans reproductibles.

- [ ] **Step 1: Exécuter typecheck/lint**

Run: utiliser les scripts existants du `package.json` lorsque présents.
Expected: aucun nouvel échec introduit par le pack.

- [ ] **Step 2: Exécuter les tests**

Run: utiliser Vitest/Playwright selon la configuration créée.
Expected: smoke tests non destructifs et tests existants exécutés.

- [ ] **Step 3: Exécuter les scans sécurité**

Run: utiliser Semgrep, Trivy et Betterleaks selon les méthodes installées localement.
Expected: rapport sans exposition de secrets réels.

### Task 4: Vérifier et produire le rapport final

**Files:**
- Create in target project: `docs/codex-bootstrap/FINAL-REPORT.md`

**Interfaces:**
- Consumes: résultats des installations/tests/scans.
- Produces: rapport de décision avant intégration.

- [ ] **Step 1: Vérifier Git**

Run:
```powershell
git diff --check
git status --short
```
Expected: aucune erreur de whitespace bloquante et état clair des fichiers modifiés.

- [ ] **Step 2: Générer le rapport**

Le rapport doit contenir outils installés/non installés, versions, erreurs, étapes manuelles et prochaine action.

- [ ] **Step 3: Ne pas merger**

Expected: aucun merge, push ou déploiement sans décision humaine explicite.
