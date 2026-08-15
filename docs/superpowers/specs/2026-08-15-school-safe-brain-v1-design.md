# SchoolSafe Brain V1 — Design

## Statut
Validé par l’utilisateur le 15 août 2026.

## But
Faire de `medygoo/fiche` le cerveau central d’ingénierie de SchoolSafe V2 et conserver `medygoo/schoolsafemm` comme application réelle. Toute modification importante naît dans le cerveau, passe par conception, agents, tests, sécurité et revue, puis n’est transférée vers l’application qu’après accord humain explicite.

## Architecture à deux dépôts

### Cerveau — `medygoo/fiche`
Responsable de la mémoire durable, des lois, des décisions, du plan maître, des agents spécialisés, des outils externes, des protocoles, des tests de gouvernance et du paquet de transfert.

### Application — `medygoo/schoolsafemm`
Responsable uniquement du code applicatif réel, des branches de staging et de production. Le cerveau ne doit jamais modifier automatiquement `main` de l’application.

## Loi 0 — Continuité de contexte
La continuité ne dépend jamais d’un seul chat. Un nouveau chat commence par `00-CONTEXT.md`, `CONTROL-TOWER.md`, `CURRENT-STATE.md` et `HANDOFF.md`, puis lit seulement les documents détaillés nécessaires. À la fin d’un travail important, ces fichiers de continuité sont actualisés.

## Six lois
1. **Vérité** — l’état GitHub vérifié et les documents maîtres priment sur la mémoire d’une conversation.
2. **Planification** — aucune modification importante sans analyse, spécification et plan.
3. **Protection** — production, données, sécurité, Auth, rôles et fonctions existantes restent hors périmètre sauf autorisation explicite.
4. **Isolation** — chaque changement se fait sur branche/worktree/copie isolée, jamais directement sur la version sûre.
5. **Preuve** — aucun travail n’est déclaré terminé sans tests adaptés, sécurité, revue et critères d’acceptation.
6. **Autorisation humaine** — le cerveau peut analyser, concevoir, construire et corriger ; le transfert vers l’application réelle et la publication nécessitent l’accord explicite de l’utilisateur.

## Cycle obligatoire d’un changement
`Demande → Contexte → Architecture/Spec → Plan → Agents spécialisés → Tests → Sécurité → Performance/Accessibilité → Revue indépendante → Paquet de transfert → Staging → Validation humaine → Application/Production → Mise à jour mémoire`.

## Cerveaux spécialisés
- Context Keeper : continuité et compression de contexte.
- Architect : architecture, dépendances et découpage.
- Product/Workflow : logique métier et critères d’acceptation.
- UI/UX : design system, responsive et cohérence visuelle.
- Frontend : intégration interface et états.
- Backend/Supabase : intégration backend, lecture seule sur production par défaut.
- Database/RLS : schéma, migrations et politiques RLS, sans production automatique.
- Testing : tests unitaires, intégration et E2E.
- Security : secrets, dépendances et scans.
- Performance/Accessibility : performance et accessibilité.
- Reviewer : revue indépendante des changements.
- Integration : consolidation et préparation du transfert ; aucun merge production automatique.

## Outils externes
Les dépôts externes ne sont pas copiés dans le code métier. Ils sont catalogués dans le cerveau, classés `core`, `specialist`, `security` ou `maintenance`, avec URL, référence approuvée, politique de mise à jour et conditions d’activation. Les mises à jour ne sont jamais automatiques vers une nouvelle référence sans revue.

### Noyau agentique retenu
- `obra/superpowers` — méthode de travail, planification, TDD, debugging, revue et vérification.
- `github/spec-kit` — développement guidé par spécification.
- `yamadashy/repomix` — compression structurée du dépôt pour les limites de contexte.
- `stablyai/orca` — orchestration de plusieurs agents/worktrees.

### Agents spécialisés disponibles sur demande
- `OpenHands/OpenHands` — agent logiciel autonome, non activé par défaut.
- `Aider-AI/aider` — édition agentique ciblée, non activée par défaut.

### Sécurité et maintenance
- Semgrep, Trivy, Gitleaks/Safe Chain selon compatibilité.
- Renovate uniquement avec revue humaine et sans auto-merge majeur.

## Mémoire durable
Le cerveau conserve des fichiers courts au sommet :
- `00-CONTEXT.md`
- `CONTROL-TOWER.md`
- `CURRENT-STATE.md`
- `DECISIONS.md`
- `MASTER-PLAN.md`
- `HANDOFF.md`

Les historiques détaillés restent dans `docs/`, les specs, plans, commits et rapports. Les fichiers courts sont des index opérationnels, pas des archives infinies.

## Staging et transfert
Chaque changement approuvé dans le cerveau produit un paquet de transfert comprenant objectif, base Git, fichiers ciblés, tests, risques, rollback et critères d’acceptation. Il arrive d’abord sur une branche de staging de `schoolsafemm`. La production n’est modifiée qu’après validation humaine explicite.

## Versioning et risque
Chaque version stable de l’application et du cerveau est enregistrée avec commit exact. Les outils externes ont une référence approuvée et une fiche de risque. Aucun outil externe n’est supérieur aux Lois SchoolSafe.

## Non-objectifs
- Ne pas dupliquer tous les dépôts externes dans `schoolsafemm`.
- Ne pas autoriser un agent externe à déployer seul.
- Ne pas dépendre d’un historique de chat pour savoir où reprendre.
- Ne pas modifier automatiquement Supabase/VPS/production.
