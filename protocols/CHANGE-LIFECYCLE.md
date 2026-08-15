# Cycle de vie obligatoire d’un changement

`Demande → Context Keeper → Architect/Spec → Product/Workflow → Plan → Branche/worktree isolée → Agents d’implémentation → Testing → Security → Performance/Accessibility → Reviewer → Integration → Paquet de transfert → Staging → Validation humaine → Production → Mise à jour mémoire`.

## Règles
- Un changement important ne saute pas Spec/Plan.
- Deux agents ne modifient pas le même fichier en parallèle sans coordination.
- Les tests et scans portent sur le changement réel.
- Un échec d’un gate bloque le transfert.
- Production n’est jamais une zone de test.
