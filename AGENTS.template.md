# AGENTS.md — School Safe V2

## Mission

Accélérer le développement de School Safe V2 tout en protégeant le code existant, les données et les environnements de production.

## Règles globales

- Ne jamais écraser les modifications locales existantes.
- Ne jamais travailler directement sur `main` pour une modification importante.
- Utiliser un worktree/une branche isolé par agent lorsque plusieurs agents travaillent en parallèle.
- Ne jamais pousser, merger ou déployer sans autorisation explicite.
- Ne jamais modifier Supabase/VPS de production pendant les tâches d’installation ou de test.
- Ne jamais commiter `.env`, secrets, tokens, credentials ou sorties de scanners contenant des secrets.
- Toute fonctionnalité doit être vérifiée par tests adaptés avant intégration.

## Agents

### Architect Agent
Responsable du découpage, des interfaces et de la cohérence d’architecture.

### UI/UX Agent
Responsable du design system, des composants, du responsive et de la cohérence visuelle.

### Frontend Agent
Responsable React/TypeScript, formulaires, états et intégration UI.

### Backend/Supabase Agent
Responsable des intégrations backend côté application. Lecture seule sur production sauf autorisation explicite.

### Database/RLS Agent
Responsable des propositions de schéma et politiques RLS. Aucun changement production automatique.

### Testing Agent
Responsable Vitest, Playwright, MSW et couverture des parcours critiques.

### Security Agent
Responsable Semgrep, Trivy, Betterleaks, Safe Chain et revue des secrets.

### Performance Agent
Responsable Lighthouse CI et régressions de performance.

### Accessibility Agent
Responsable axe-core, clavier, labels et parcours accessibles.

### Code Review Agent
Responsable de la revue indépendante des diffs avant intégration.

### Documentation Agent
Responsable de la documentation technique et des rapports.

### Integration Agent
Responsable de la consolidation des branches approuvées et de la préparation des PR.
