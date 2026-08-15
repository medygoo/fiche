# HANDOFF — Relais entre conversations

## État au 15 août 2026
Brain V1 est opérationnel. L’audit Phase B, la conception Fondation Production validée et les plans F0→F4 sont intégrés à `medygoo/fiche/main` via PR #4 (`e3322d20b0ef86b9dfb1b861c032c895fa735b54`).

## F0 exécuté en staging
- Application : `medygoo/schoolsafemm`.
- Production toujours : `main` @ `c347bef91b3fdbdca0d2a94e185b5914b5360d8e`.
- Branche F0 : `staging/foundation-f0`.
- PR : `schoolsafemm#1`, draft, non fusionnée.
- Head F0 techniquement validé : `2a4d822256aa1122e30867c835693f65f27ebe5e`.
- GitHub Actions run `31900150659` : `server-contracts` PASS + `existing-browser-qa` PASS.
- Scan de secrets : PASS.
- Aucun fichier `app/` modifié.
- Workflow Pages identique base/staging : SHA `e1c7851c35db9921a1d9debcc5b4e12a2e711d04`.
- Revue diff-only PR #1 : aucun Critical/Important.
- Paquet : `transfers/2026-08-15-foundation-f0.md`.

## Ce que F0 fournit
- workspace Node/TypeScript/Fastify/Vitest ;
- `/health` et `/ready` ;
- configuration validée par Zod ;
- format d’erreur stable + `request_id` ;
- 12 identifiants de permissions stables ;
- Playwright verrouillé pour les QA existantes ;
- CI PR read-only avec typecheck, tests, scan secrets et QA navigateur Windows.

## Autorisation
F0 est techniquement validé mais **non autorisé en production**. Aucun merge `schoolsafemm/main` ne doit être effectué automatiquement.

## Reprise d’un nouveau chat
Lire `governance/SCHOOLSAFE-LAWS.md` → `00-CONTEXT.md` → `CONTROL-TOWER.md` → `CURRENT-STATE.md` → ce fichier → `protocols/SUPERPOWERS-SKILLS.md` → paquet F0, puis vérifier les SHAs GitHub courants.

## Prochaine action
Attendre validation humaine de F0. Après validation : créer `staging/foundation-f1` depuis `2a4d822256aa1122e30867c835693f65f27ebe5e` et exécuter F1 Auth + Access + Bootstrap avec TDD/RLS. Ne pas merger F0 en production par défaut.
