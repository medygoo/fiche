# School Safe V2 — Architecture multi-agents

## Principe

Codex reste le moteur principal. Les tâches sont découpées par métier et exécutées dans des branches/worktrees isolés afin d’éviter les collisions.

## Rôles

### Architect Agent
- analyse l’architecture ;
- découpe les tâches ;
- définit interfaces et dépendances ;
- ne réalise pas les modifications UI métier à la place des autres agents.

### UI/UX Agent
- design system ;
- responsive ;
- composants ;
- cohérence visuelle ;
- accessibilité visuelle.

### Frontend Agent
- React/TypeScript ;
- formulaires ;
- états ;
- intégration des composants ;
- performances frontend.

### Backend/Supabase Agent
- intégration Supabase côté application ;
- appels API ;
- Auth côté code ;
- aucune modification production sans autorisation explicite.

### Database/RLS Agent
- schémas et politiques à analyser/proposer ;
- travaille d’abord sur migrations locales ou plans ;
- aucune migration production automatique.

### Testing Agent
- Vitest ;
- Playwright ;
- MSW ;
- tests unitaires/intégration/e2e.

### Security Agent
- Semgrep ;
- Trivy ;
- Betterleaks ;
- Safe Chain ;
- revue secrets et dépendances.

### Performance Agent
- Lighthouse CI ;
- poids bundles ;
- lenteurs UI ;
- régressions de performance.

### Accessibility Agent
- axe-core ;
- clavier ;
- contrastes ;
- labels ;
- parcours essentiels.

### Code Review Agent
- relit les diffs ;
- vérifie tests, sécurité, architecture ;
- bloque l’intégration si les critères ne sont pas satisfaits.

### Documentation Agent
- maintient docs techniques, procédures et rapports.

### Integration Agent
- réconcilie les branches approuvées ;
- résout les conflits ;
- prépare la PR finale ;
- ne merge pas sans autorisation humaine.

## Flux recommandé

```text
Architect Agent
      |
      v
Découpage des tâches
      |
      +-------------------+-------------------+
      |                   |                   |
      v                   v                   v
 UI/UX Agent       Frontend Agent      Backend/DB Agent
 worktree-ui       worktree-front      worktree-data
      |                   |                   |
      +-------------------+-------------------+
                          |
                          v
                    Testing Agent
                          |
                          v
                    Security Agent
                          |
                          v
                   Performance/A11y
                          |
                          v
                    Review Agent
                          |
                          v
                  Integration Agent
                          |
                          v
                    Pull Request
```

## Règles de concurrence

1. Un agent = un worktree/une branche.
2. Deux agents ne modifient pas le même fichier simultanément sans coordination.
3. Les contrats/interfaces sont décidés avant le travail parallèle.
4. Les tests des branches sont exécutés avant intégration.
5. Le Reviewer ne modifie pas silencieusement le travail qu’il évalue : il signale ou crée une correction séparée.
6. Aucune branche n’est fusionnée automatiquement vers `main`.
