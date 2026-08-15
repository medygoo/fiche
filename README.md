# SchoolSafe Brain V1 — Engineering Pack

Ce dépôt **`medygoo/fiche` est le cerveau central de SchoolSafe V2**. Il conserve les lois, la mémoire opérationnelle, les décisions, le plan maître, les agents spécialisés, les outils approuvés et les protocoles de transfert.

L’application réelle reste séparée dans **`medygoo/schoolsafemm`**.

## Principe

```text
Demande
→ Cerveau SchoolSafe
→ contexte vérifié
→ spécification
→ plan
→ agents spécialisés
→ tests / sécurité / revue
→ paquet de transfert
→ staging de schoolsafemm
→ validation humaine
→ production
→ mise à jour de la mémoire
```

Aucun outil externe et aucun agent n’est autorisé à contourner `governance/SCHOOLSAFE-LAWS.md`.

## Début obligatoire de toute nouvelle conversation

Lire dans cet ordre :

1. `governance/SCHOOLSAFE-LAWS.md`
2. `00-CONTEXT.md`
3. `CONTROL-TOWER.md`
4. `CURRENT-STATE.md`
5. `HANDOFF.md`

Puis lire seulement les décisions, specs, plans et fichiers utiles à la tâche. Cette règle protège la continuité lorsque la fenêtre de contexte d’un chat devient trop grande.

## Les cerveaux spécialisés

Le catalogue se trouve dans `agents/agent-catalog.json`. Il contient : Context Keeper, Architect, Product/Workflow, UI/UX, Frontend, Backend/Supabase, Database/RLS, Testing, Security, Performance/Accessibility, Reviewer et Integration.

## Outils approuvés

Le registre machine est `config/approved-tools.json`.

### Noyau
- Superpowers — méthode de développement et vérification.
- GitHub Spec Kit — spécifications.
- Repomix — compression ciblée du contexte.
- Orca — orchestration multi-agents/worktrees, activée quand nécessaire.

### Spécialistes manuels
- OpenHands.
- Aider.

### Sécurité / maintenance
- Semgrep.
- Trivy.
- Gitleaks.
- Aikido Safe Chain.
- Renovate avec revue humaine.

Les outils core sont épinglés à un commit approuvé. Aucun changement silencieux de référence n’est autorisé.

## Installation sûre

Le bootstrap ne modifie **aucune dépendance de l’application par défaut**.

Prévisualiser :

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\bootstrap-school-safe-v2.ps1 -TargetProject "C:\SchoolSafe\schoolsafe-v2" -DryRun
```

Installer uniquement le noyau léger :

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\bootstrap-school-safe-v2.ps1 -TargetProject "C:\SchoolSafe\schoolsafe-v2"
```

Ajouter Orca seulement pour le multi-agent :

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\bootstrap-school-safe-v2.ps1 -TargetProject "C:\SchoolSafe\schoolsafe-v2" -InstallMultiAgent
```

`-InstallSpecialists`, `-InstallSecurity` et `-InstallProjectDependencies` sont des options explicites ; elles ne sont jamais activées automatiquement.

## Validation du cerveau

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\validate-brain.ps1
```

Le validateur contrôle notamment les fichiers obligatoires, les JSON, les quatre outils core épinglés et l’obligation de validation humaine avant production.

## Documents de gouvernance

- `governance/SCHOOLSAFE-LAWS.md` — Loi 0 + Six Lois.
- `governance/RELEASE-GATES.md` — gates avant production.
- `governance/VERSION-REGISTRY.md` — commits stables.
- `governance/TOOL-RISK-REGISTER.md` — risques des outils externes.
- `protocols/CHANGE-LIFECYCLE.md` — flux complet d’un changement.
- `protocols/TRANSFER-PACKAGE.md` — contrat de transfert.
- `protocols/STAGING.md` — passage obligatoire par staging.

## Règles absolues

- ne jamais confondre le cerveau et l’application ;
- ne jamais travailler directement sur `main` pour un changement important ;
- ne jamais force-push ou utiliser `git reset --hard` pour écraser du travail ;
- ne jamais commiter de secret ;
- ne jamais muter Supabase/VPS/production sans autorisation explicite ;
- ne jamais déclarer un travail terminé sans preuve ;
- ne jamais publier `schoolsafemm` sans validation humaine explicite.

Voir `INSTALL.md` et `codex/MASTER-INSTALL-PROMPT.md` pour l’utilisation avec Codex/Claude et les environnements locaux.
