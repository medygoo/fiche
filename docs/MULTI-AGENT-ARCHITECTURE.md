# SchoolSafe Brain V1 — Architecture multi-agents

## Principe

Les agents sont des **cerveaux spécialisés**, pas des autorités indépendantes. Tous obéissent à `governance/SCHOOLSAFE-LAWS.md` et travaillent à partir d’un contexte vérifié.

Le cerveau peut être piloté par Codex, Claude Code ou un autre environnement compatible. Orca est l’orchestrateur multi-agent privilégié lorsqu’un travail parallèle est réellement utile ; Superpowers et Spec Kit structurent la méthode ; Repomix aide à contrôler la taille du contexte.

## Flux

```text
Context Keeper
      |
      v
Architect + Product/Workflow
      |
      v
Spec + critères d’acceptation + plan
      |
      +----------------------+----------------------+----------------------+
      |                      |                      |                      |
      v                      v                      v                      v
   UI/UX                 Frontend              Backend/API           Database/RLS
 worktree-ui          worktree-front          worktree-back          worktree-data
      |                      |                      |                      |
      +----------------------+----------------------+----------------------+
                                     |
                                     v
                                  Testing
                                     |
                                     v
                                  Security
                                     |
                                     v
                         Performance / Accessibility
                                     |
                                     v
                              Reviewer indépendant
                                     |
                                     v
                               Integration Agent
                                     |
                                     v
                             Paquet de transfert
                                     |
                                     v
                            staging/<change-id>
                                     |
                                     v
                            Validation humaine
                                     |
                                     v
                                  Production
```

## Rôles canoniques

Les fichiers détaillés se trouvent dans `agents/` :
- Context Keeper — continuité de contexte et sélection des sources.
- Architect — architecture, dépendances, interfaces et découpage.
- Product/Workflow — logique métier et critères d’acceptation.
- UI/UX — cohérence visuelle, responsive et accessibilité visuelle.
- Frontend — interface et états applicatifs.
- Backend/Supabase — contrats backend et intégrations ; production en lecture seule par défaut.
- Database/RLS — schéma, migrations et politiques ; aucune migration production automatique.
- Testing — preuves unitaires/intégration/E2E.
- Security — secrets, dépendances, Auth/RLS et supply chain.
- Performance/Accessibility — régressions de qualité.
- Reviewer — revue indépendante.
- Integration — consolidation et paquet de transfert.

## Quand utiliser le parallèle

Utiliser plusieurs agents seulement si les tâches sont réellement indépendantes et que leurs fichiers/contrats sont séparables. Sinon, travailler séquentiellement réduit le risque de collisions et de contexte contradictoire.

Orca peut gérer les worktrees parallèles lorsque `-InstallMultiAgent` a été explicitement choisi. OpenHands et Aider restent des spécialistes manuels pour des tâches bornées ; ils ne remplacent pas le pipeline de revue.

## Règles de concurrence

1. Un agent qui écrit = une branche/worktree isolée.
2. Deux agents ne modifient pas le même fichier simultanément sans coordination explicite.
3. Les interfaces sont décidées avant le travail parallèle.
4. Chaque branche passe ses tests avant consolidation.
5. Le Reviewer ne corrige pas silencieusement le travail qu’il évalue.
6. L’Integration Agent ne merge pas `schoolsafemm/main` sans autorisation humaine.
7. Un échec de Testing, Security ou Reviewer bloque le transfert.
8. Le Context Keeper met fin au travail si le dépôt/branche/base ne sont pas certains.

## Gestion de la limite de contexte

Un agent ne reçoit pas tout l’historique. Il reçoit :
- les Lois ;
- le contexte minimal ;
- la spec/plan de sa tâche ;
- les interfaces dont il dépend ;
- les fichiers ciblés.

Repomix peut produire un paquet de contexte ciblé. Les `.env`, secrets, credentials, données personnelles et artefacts sensibles doivent être exclus avant paquetage.

## Fin d’un travail parallèle

Integration rassemble uniquement les branches approuvées, vérifie les conflits, prépare le paquet de transfert et remet le contrôle à l’utilisateur avant tout passage en production.
