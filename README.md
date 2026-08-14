# School Safe V2 — Codex Engineering Pack

Ce dépôt prépare et automatise l’environnement de développement **School Safe V2** autour de Codex.

Objectifs :
- accélérer le développement avec Codex ;
- organiser plusieurs agents spécialisés en parallèle ;
- conserver le code School Safe V2 existant ;
- ajouter design system, tests, sécurité, performance et revue de code ;
- éviter les installations répétitives sur une connexion lente ;
- centraliser les instructions d’installation dans un seul dépôt.

## Démarrage rapide

Depuis le dossier local de School Safe V2, demande à Codex :

```text
Clone le dépôt https://github.com/medygoo/fiche dans C:\SchoolSafe\AI-TOOLS\School-Safe-V2-Pack si nécessaire, lis INSTALL.md puis codex/MASTER-INSTALL-PROMPT.md, et exécute la procédure complète en respectant toutes les règles de sécurité. Ne merge rien dans main, ne push rien et ne déploie rien sans autorisation explicite.
```

Le script PowerShell principal se trouve dans :

```text
scripts/bootstrap-school-safe-v2.ps1
```

## Outils couverts

### Agents / méthode
- OpenAI Codex
- GitHub Spec Kit
- Superpowers
- Repomix
- Agent Orchestrator

### Design / Frontend
- shadcn/ui
- Magic UI
- Storybook
- TanStack Query
- Zod
- React Hook Form
- Biome

### Tests
- Playwright
- Vitest
- MSW
- axe-core

### Sécurité
- Semgrep
- Trivy
- Betterleaks
- Aikido Safe Chain

### Performance / maintenance
- Lighthouse CI
- Renovate

## Règles absolues

- ne jamais écraser les modifications locales existantes ;
- ne jamais utiliser `git reset --hard` ;
- ne jamais forcer un push ;
- ne jamais déployer automatiquement ;
- ne jamais toucher à Supabase/VPS de production pendant l’installation ;
- utiliser des branches/worktrees isolés pour les agents parallèles ;
- vérifier chaque installation avant de continuer ;
- réutiliser les outils déjà présents au lieu de les installer deux fois.

Voir `INSTALL.md` pour la procédure complète.