# Protocole officiel — Superpowers Skills

Ce protocole rend les Skills Superpowers obligatoires dans le Cerveau SchoolSafe lorsqu’ils sont disponibles dans l’environnement de l’agent. Les Lois SchoolSafe restent toujours l’autorité supérieure.

## Séquence de sélection

1. **using-superpowers** — au démarrage d’un environnement compatible, vérifier les Skills disponibles avant de travailler.
2. **brainstorming** — obligatoire avant toute création fonctionnelle, modification de comportement, composant ou design non trivial. Clarifier l’intention, les contraintes et faire valider la conception.
3. **writing-plans** — obligatoire pour tout travail multi-étapes après validation de la conception. Le plan est enregistré dans `docs/superpowers/plans/`.
4. **using-git-worktrees** — avant toute implémentation qui nécessite une isolation ; à défaut, utiliser une branche Git dédiée vérifiée.
5. **test-driven-development** — pour toute fonctionnalité ou correction de bug : RED → GREEN → REFACTOR. Les changements purement documentaires/configuration sont validés par les contrôles adaptés au dépôt.
6. **systematic-debugging** — dès qu’un bug, test rouge, CI en échec ou comportement inattendu apparaît. Trouver la cause racine avant de corriger.
7. **dispatching-parallel-agents** ou **subagent-driven-development** — lorsque plusieurs tâches réellement indépendantes peuvent être exécutées en parallèle ; chaque agent conserve son périmètre/branche/worktree.
8. **executing-plans** — lorsqu’un plan écrit doit être exécuté séquentiellement avec checkpoints.
9. **requesting-code-review** — avant intégration d’une modification importante ou après un lot significatif.
10. **receiving-code-review** — avant d’appliquer des retours de revue, vérifier techniquement chaque remarque.
11. **verification-before-completion** — obligatoire avant toute affirmation « terminé », « corrigé », « prêt » ou avant une PR/merge. Preuve fraîche, pas de confiance implicite.
12. **finishing-a-development-branch** — après vérification réussie, pour décider explicitement : PR/merge/conservation de branche. Aucun déploiement applicatif sans validation humaine.

## Règles de contexte

- Ne jamais charger tous les Skills et toute la base de code dans le contexte sans nécessité.
- Le Context Keeper choisit uniquement les Skills nécessaires à la tâche en cours.
- Les documents maîtres restent la mémoire durable ; le chat n’est pas la source de vérité.
- Si le contexte devient trop grand, produire un paquet Repomix ciblé et mettre à jour `HANDOFF.md` avant de changer de conversation.

## Hiérarchie

`Lois SchoolSafe → périmètre validé → protocole de changement → Skills Superpowers → outils/agents externes`.

Aucun Skill, agent ou dépôt externe ne peut contourner la validation humaine de production.
