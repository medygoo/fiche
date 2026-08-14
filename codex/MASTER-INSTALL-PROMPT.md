# MASTER INSTALL PROMPT — School Safe V2

Tu travailles sur le dépôt local **School Safe V2**.

Ta mission est d’installer et configurer le **School Safe V2 Codex Engineering Pack** sans casser le projet existant.

## Règles de sécurité obligatoires

1. Ne jamais travailler directement sur `main`/`master` si une modification est nécessaire.
2. Ne jamais supprimer les modifications locales existantes.
3. Ne jamais utiliser `git reset --hard`.
4. Ne jamais forcer un push.
5. Ne jamais déployer automatiquement.
6. Ne jamais modifier Supabase de production, le VPS, Auth, RLS ou Storage pendant l’installation.
7. Réutiliser les outils déjà présents ; ne pas installer en double.
8. Préférer les versions stables et les méthodes d’installation actuellement recommandées par les dépôts officiels.
9. Si une installation échoue à cause du réseau, conserver l’état, noter l’étape et reprendre sans recommencer les téléchargements déjà réussis.
10. Ne pas copier intégralement les dépôts externes dans le code métier School Safe V2.

## Étape A — État du projet

Effectue un contrôle court :
- `git status --short` ;
- branche actuelle ;
- gestionnaire de paquets ;
- stack détectée ;
- outils/Skills/MCP déjà présents.

Évite les scans récursifs inutiles ou répétés qui ralentissent OneDrive. Si le dépôt est encore dans OneDrive et que les accès sont très lents, recommande la copie locale `C:\SchoolSafe\schoolsafe-v2` mais ne supprime jamais l’original.

## Étape B — Protection Git

Si le dépôt est propre ou si les modifications locales peuvent être préservées sans conflit :
- créer une branche de travail `chore/school-safe-v2-engineering-pack` ou un nom horodaté ;
- préférer un worktree isolé pour les changements d’outillage.

Ne commit pas les modifications métier antérieures de l’utilisateur avec celles du pack.

## Étape C — Cache local des outils

Utilise `C:\SchoolSafe\AI-TOOLS` comme cache persistant. Clone en `--depth 1` les dépôts manquants uniquement :

- https://github.com/github/spec-kit
- https://github.com/obra/superpowers
- https://github.com/yamadashy/repomix
- https://github.com/Untrivial-ai/agent-orchestrator
- https://github.com/semgrep/semgrep
- https://github.com/aquasecurity/trivy
- https://github.com/betterleaks/betterleaks
- https://github.com/AikidoSec/safe-chain

Si un dossier existe déjà, vérifie-le et réutilise-le au lieu de recloner.

## Étape D — Méthode et contexte Codex

Configurer ou intégrer :
- Superpowers ;
- GitHub Spec Kit avec intégration Codex/Skills si supportée par la version actuelle ;
- Repomix / repomix-explorer ;
- AGENTS.md de School Safe V2.

Les agents cibles :
- Architect Agent
- UI/UX Agent
- Frontend Agent
- Backend/Supabase Agent
- Database/RLS Agent
- Testing Agent
- Security Agent
- Performance Agent
- Accessibility Agent
- Code Review Agent
- Documentation Agent
- Integration Agent

Chaque agent doit travailler dans une branche/worktree isolé lorsqu’il modifie du code en parallèle.

## Étape E — Design et frontend

Analyser l’existant avant toute initialisation.

Configurer uniquement si compatible et sans remplacer le design School Safe V2 :
- shadcn/ui ;
- Magic UI ;
- Storybook ;
- `@tanstack/react-query` ;
- `zod` ;
- `react-hook-form` ;
- Biome.

Ne réécris pas les formulaires ou composants existants uniquement pour adopter une nouvelle bibliothèque.

Créer/maintenir `docs/design/DESIGN-SYSTEM.md` avec règles de composants, tableaux, formulaires, responsive et accessibilité.

## Étape F — Tests

Configurer selon la stack existante :
- Playwright ;
- Vitest ;
- MSW ;
- axe-core ;
- Storybook tests si pertinent.

Organisation cible :

```text
tests/
  unit/
  integration/
  e2e/
  accessibility/
```

Créer des smoke tests non destructifs. Ne jamais utiliser les données réelles de production.

## Étape G — Sécurité

Configurer progressivement :
- Semgrep ;
- Trivy ;
- Betterleaks ;
- Aikido Safe Chain.

Avant d’exécuter un scanner, exclure `.env`, credentials, caches et sorties pouvant exposer des secrets. Aucun secret réel ne doit être commité.

## Étape H — Performance et maintenance

Configurer :
- Lighthouse CI ;
- Renovate avec mises à jour majeures jamais auto-fusionnées.

## Étape I — Agent Orchestrator

Lire le README local cloné avant installation. Utiliser la méthode actuelle recommandée par le projet pour Windows. Ne pas utiliser un ancien paquet legacy si le dépôt le déconseille.

Si une confirmation graphique Windows est nécessaire, préparer l’étape puis attendre l’utilisateur au lieu de contourner la confirmation.

## Étape J — CI

Créer/améliorer la CI sans déploiement production automatique :

```text
install
→ typecheck
→ lint
→ unit tests
→ build
→ security scans
→ e2e smoke
→ accessibility
→ lighthouse
```

Ne remplace pas brutalement les workflows existants ; fusionne les contrôles proprement.

## Étape K — Vérification finale

Exécute les contrôles disponibles :
- typecheck ;
- lint ;
- tests ;
- build ;
- Playwright smoke ;
- sécurité ;
- `git diff --check` ;
- `git status --short`.

Corrige seulement les erreurs introduites par le pack.

## Rapport final

Créer `docs/codex-bootstrap/FINAL-REPORT.md` avec :
- outil ;
- statut installé/non installé ;
- version ;
- méthode ;
- fichiers ajoutés/modifiés ;
- vérifications réussies/échouées ;
- étapes manuelles restantes ;
- risques ;
- prochaine commande recommandée.

À l’écran, termine uniquement par :

```text
INSTALLÉ
NON INSTALLÉ
ERREURS
MULTI-AGENTS
PRÊT À UTILISER
PROCHAINE ACTION
```
