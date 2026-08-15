# SchoolSafe Brain V1 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Transformer `medygoo/fiche` en cerveau central durable, agentique et contrôlé pour SchoolSafe V2, sans toucher à la production de `medygoo/schoolsafemm` pendant cette implémentation.

**Architecture:** Le cerveau contient une mémoire compacte, les Lois SchoolSafe, les agents spécialisés, un catalogue d’outils externes épinglés/revus et les protocoles de changement, staging, transfert, versioning et risque. L’application réelle reste séparée et n’accepte un transfert qu’après validation humaine.

**Tech Stack:** GitHub, Markdown, JSON, PowerShell, Git branches/worktrees, outils agentiques catalogués.

## Global Constraints
- Loi 0 de continuité obligatoire.
- Six Lois SchoolSafe supérieures à tout outil externe.
- Aucun changement automatique dans `medygoo/schoolsafemm`.
- Aucun déploiement production.
- Aucun secret dans le dépôt.
- Les dépôts externes sont référencés, pas vendoriés.
- Chaque transfert vers l’application exige une validation humaine explicite.

---

### Task 1: Mémoire opérationnelle et Lois

**Files:**
- Create: `00-CONTEXT.md`
- Create: `CONTROL-TOWER.md`
- Create: `CURRENT-STATE.md`
- Create: `DECISIONS.md`
- Create: `MASTER-PLAN.md`
- Create: `HANDOFF.md`
- Create: `governance/SCHOOLSAFE-LAWS.md`

**Produces:** une source courte et stable à relire au début de chaque nouveau chat.

- [ ] Écrire la Loi 0 et les Six Lois dans `governance/SCHOOLSAFE-LAWS.md`.
- [ ] Créer les six fichiers mémoire avec état réel de production `schoolsafemm` au commit `c347bef91b3fdbdca0d2a94e185b5914b5360d8e`.
- [ ] Vérifier que `00-CONTEXT.md` donne l’ordre de lecture de démarrage et de clôture.
- [ ] Commit.

### Task 2: Agents spécialisés

**Files:**
- Create: `agents/README.md`
- Create: `agents/agent-catalog.json`
- Create: `agents/CONTEXT-KEEPER.md`
- Create: `agents/ARCHITECT.md`
- Create: `agents/PRODUCT-WORKFLOW.md`
- Create: `agents/UI-UX.md`
- Create: `agents/FRONTEND.md`
- Create: `agents/BACKEND-SUPABASE.md`
- Create: `agents/DATABASE-RLS.md`
- Create: `agents/TESTING.md`
- Create: `agents/SECURITY.md`
- Create: `agents/PERFORMANCE-ACCESSIBILITY.md`
- Create: `agents/REVIEWER.md`
- Create: `agents/INTEGRATION.md`

**Produces:** responsabilités, entrées, sorties et interdictions explicites par agent.

- [ ] Définir le Context Keeper comme gardien de la limite de contexte.
- [ ] Définir chaque agent avec mission, entrées, sorties, limites et gate de sortie.
- [ ] Créer un catalogue JSON machine-readable.
- [ ] Commit.

### Task 3: Catalogue des outils et politique de versions

**Files:**
- Modify: `config/tools-manifest.json`
- Create: `config/approved-tools.json`
- Create: `governance/TOOL-RISK-REGISTER.md`

**Produces:** sélection contrôlée de dépôts externes avec références approuvées et niveaux d’activation.

- [ ] Inscrire le noyau agentique : Superpowers, Spec Kit, Repomix, Orca.
- [ ] Inscrire OpenHands et Aider en spécialistes non activés par défaut.
- [ ] Conserver les scanners sécurité existants et imposer l’installation par version/release stable lorsque préférable.
- [ ] Interdire les mises à jour silencieuses et l’auto-merge majeur.
- [ ] Commit.

### Task 4: Protocoles de changement, staging et transfert

**Files:**
- Create: `protocols/START-CHAT.md`
- Create: `protocols/END-CHAT.md`
- Create: `protocols/CHANGE-LIFECYCLE.md`
- Create: `protocols/TRANSFER-PACKAGE.md`
- Create: `protocols/STAGING.md`
- Create: `templates/TRANSFER-PACKAGE.template.md`

**Produces:** flux unique de l’idée jusqu’à la production avec validation humaine.

- [ ] Définir le démarrage d’un nouveau chat à contexte minimal.
- [ ] Définir la clôture et la mise à jour de HANDOFF/CURRENT-STATE/DECISIONS.
- [ ] Définir le cycle obligatoire : spec → plan → agents → tests → sécurité → revue → transfert → staging → accord humain.
- [ ] Définir le paquet de transfert et le rollback.
- [ ] Commit.

### Task 5: Registres de versions et contrôle central

**Files:**
- Create: `governance/VERSION-REGISTRY.md`
- Create: `governance/RELEASE-GATES.md`
- Modify: `CONTROL-TOWER.md`

**Produces:** connaissance immédiate de la version du cerveau, de la production et du prochain jalon.

- [ ] Enregistrer la production SchoolSafe V2 actuelle et la version Brain V1.
- [ ] Définir les gates de staging et production.
- [ ] Ajouter les champs tests, risques, prochaine priorité et dernier transfert dans CONTROL-TOWER.
- [ ] Commit.

### Task 6: Validation automatique du cerveau

**Files:**
- Create: `scripts/validate-brain.ps1`
- Create: `config/brain-required-files.json`

**Produces:** validation locale/CI de la présence des lois, fichiers mémoire, agents et configuration JSON.

- [ ] Faire échouer le script si un fichier obligatoire manque.
- [ ] Valider la syntaxe JSON des catalogues.
- [ ] Faire échouer si `approved-tools.json` contient une entrée core sans référence approuvée.
- [ ] Vérifier que la règle `humanApprovalRequiredForProduction` vaut `true`.
- [ ] Commit.

### Task 7: Documentation d’entrée et compatibilité avec l’existant

**Files:**
- Modify: `README.md`
- Modify: `AGENTS.template.md`
- Modify: `codex/MASTER-INSTALL-PROMPT.md`

**Produces:** tout Codex/Claude/agent entrant sait lire le cerveau avant d’agir.

- [ ] Mettre `00-CONTEXT.md` et `CONTROL-TOWER.md` en première lecture.
- [ ] Faire des Lois SchoolSafe l’autorité supérieure.
- [ ] Conserver les règles existantes de branches/worktrees, secrets et production.
- [ ] Commit.

### Task 8: Vérification et intégration du cerveau

**Files:** aucune nouvelle exigence.

- [ ] Comparer la branche au `main` de `medygoo/fiche`.
- [ ] Vérifier tous les JSON et invariants.
- [ ] Vérifier qu’aucun fichier de `medygoo/schoolsafemm` n’a été modifié.
- [ ] Mettre à jour `HANDOFF.md` avec le résultat.
- [ ] Après validation, intégrer le Brain V1 dans `main` du dépôt cerveau uniquement ; ne pas toucher à l’application.
