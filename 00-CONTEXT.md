# SchoolSafe Brain — Contexte minimal

## Autorité
Ce dépôt `medygoo/fiche` est le cerveau central d’ingénierie de SchoolSafe V2. L’application réelle est `medygoo/schoolsafemm`.

## Ordre de lecture obligatoire au début d’un nouveau chat
1. `governance/SCHOOLSAFE-LAWS.md`
2. `CONTROL-TOWER.md`
3. `CURRENT-STATE.md`
4. `HANDOFF.md`
5. `DECISIONS.md` seulement si la tâche dépend d’une décision antérieure.
6. `MASTER-PLAN.md` pour situer la tâche dans la trajectoire globale.

Ne charge ensuite que les specs, plans, agents et fichiers de code nécessaires à la tâche en cours. Utiliser Repomix pour produire un contexte ciblé lorsque le dépôt est trop large.

## Loi 0
La continuité ne dépend jamais d’un seul chat. GitHub et les fichiers de continuité sont la mémoire opérationnelle officielle. À la fin de tout travail important, mettre à jour `CURRENT-STATE.md`, `HANDOFF.md` et, si nécessaire, `DECISIONS.md`.

## Règle de production
Le cerveau peut analyser, concevoir, tester et préparer. Il ne modifie jamais automatiquement `main` de `medygoo/schoolsafemm`. Le transfert et la publication exigent l’accord humain explicite.

## Démarrage rapide
Si une conversation est nouvelle ou si le contexte est incertain : arrêter toute modification, relire les quatre premiers fichiers de l’ordre obligatoire, vérifier GitHub, puis seulement reprendre.
