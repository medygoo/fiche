# Installation — School Safe V2 Codex Engineering Pack

Cette procédure est conçue pour être suivie par Codex depuis le dépôt local de **School Safe V2**.

## 1. Préconditions

Codex doit vérifier avant toute modification :
- `git status` ;
- la branche actuelle ;
- les modifications locales non commitées ;
- `package.json` et le lockfile existant ;
- les fichiers `AGENTS.md`, `.env*`, configurations MCP et workflows GitHub Actions ;
- les outils déjà installés.

Aucune modification locale existante ne doit être écrasée.

## 2. Copie locale hors OneDrive

Si School Safe V2 se trouve dans OneDrive et que les scans sont lents, créer une copie de travail hors OneDrive, par exemple :

```text
C:\SchoolSafe\schoolsafe-v2
```

Conserver l’original intact jusqu’à validation finale.

## 3. Cache local des outils

Créer :

```text
C:\SchoolSafe\AI-TOOLS
```

Les dépôts externes doivent être téléchargés une seule fois, en clone superficiel lorsque possible, puis réutilisés :

- `github/spec-kit`
- `obra/superpowers`
- `yamadashy/repomix`
- `Untrivial-ai/agent-orchestrator`
- `semgrep/semgrep`
- `aquasecurity/trivy`
- `betterleaks/betterleaks`
- `AikidoSec/safe-chain`

Ne pas recopier leur code dans School Safe V2. Ils restent des outils externes.

## 4. Dépendances projet

Après détection du gestionnaire de paquets existant, Codex peut ajouter uniquement les dépendances compatibles réellement utiles :

### Runtime
- `@tanstack/react-query`
- `zod`
- `react-hook-form`

### Dev / qualité
- `@biomejs/biome`
- `@playwright/test`
- `vitest`
- `msw`
- `axe-core`
- `@lhci/cli`

Storybook, shadcn/ui et Magic UI doivent être configurés après analyse du frontend existant afin de ne pas écraser le design actuel.

## 5. Sécurité

Configurer progressivement :
- Semgrep pour l’analyse statique ;
- Trivy pour vulnérabilités, conteneurs et configurations ;
- Betterleaks pour les secrets ;
- Safe Chain pour protéger les installations de paquets.

Les scanners ne doivent jamais écrire un secret réel dans un fichier commité.

## 6. Multi-agents

Les rôles cibles sont :
- Architecte ;
- UI/UX ;
- Frontend ;
- Backend/Supabase ;
- Database/RLS ;
- Tests ;
- Sécurité ;
- Performance ;
- Accessibilité ;
- Reviewer ;
- Documentation ;
- Intégration.

Chaque agent travaille dans une branche/worktree isolé. Le Reviewer vérifie avant intégration.

## 7. Vérifications finales

Exécuter selon ce qui existe dans le projet :
- typecheck ;
- lint ;
- tests unitaires ;
- build ;
- Playwright smoke tests ;
- accessibilité ;
- scans sécurité ;
- Lighthouse CI.

Ne masquer aucun test rouge et ne supprimer aucun test pour obtenir artificiellement un résultat vert.

## 8. Interdictions

Pendant cette installation :
- aucun merge dans `main` ;
- aucun push distant sans autorisation ;
- aucun déploiement ;
- aucune migration Supabase de production ;
- aucune modification du VPS ;
- aucun changement destructif Auth/RLS/Storage.

## 9. Lancement

Depuis PowerShell :

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\bootstrap-school-safe-v2.ps1 -TargetProject "C:\SchoolSafe\schoolsafe-v2"
```

Puis ouvrir Codex dans le projet et lui faire lire :

```text
codex/MASTER-INSTALL-PROMPT.md
```
