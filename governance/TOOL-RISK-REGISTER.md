# Registre de risque — Outils externes

| Outil | Niveau | Rôle | Activation | Risque principal | Contrôle |
|---|---|---|---|---|---|
| Superpowers | Core | Méthode | défaut | consignes externes évolutives | commit approuvé + Lois supérieures |
| Spec Kit | Core | Spécification | défaut | workflow incompatible avec existant | adapter sans réinitialiser le projet |
| Repomix | Core | Contexte | défaut | exposition involontaire de secrets | exclusions obligatoires avant paquetage |
| Orca | Core | Multi-agents | multi-agent | collisions / consommation | worktrees isolés + périmètres distincts |
| OpenHands | Spécialiste | Agent autonome | manuel | autonomie trop large | tâche bornée + branche isolée |
| Aider | Spécialiste | Édition agentique | manuel | modification trop directe | diff obligatoire + tests + revue |
| Semgrep | Sécurité | SAST | gate | faux positifs / sorties sensibles | règles ciblées + pas de secrets |
| Trivy | Sécurité | vulnérabilités | gate | bruit / réseau | scan ciblé, version stable |
| Gitleaks | Sécurité | secrets | gate | secrets dans logs | sorties protégées, aucun commit de rapport sensible |
| Safe Chain | Sécurité | supply chain | gate | incompatibilité dépendances | activation après vérification |
| Renovate | Maintenance | dépendances | revue | upgrade cassant | aucun auto-merge majeur |

Toute référence d’outil core change uniquement après revue humaine et mise à jour de `config/approved-tools.json`.
