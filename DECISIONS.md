# Registre des décisions — SchoolSafe

## 2026-08-15 — Deux dépôts officiels
**Décision :** `medygoo/fiche` devient le cerveau central ; `medygoo/schoolsafemm` reste l’application réelle.
**Conséquence :** les outils, méthodes, agents et mémoires restent dans le cerveau ; le code métier reste dans l’application.

## 2026-08-15 — Loi 0
**Décision :** la limite de contexte des chats est traitée par une mémoire GitHub compacte et un protocole de handoff.
**Conséquence :** un nouveau chat lit d’abord les fichiers de continuité, pas l’intégralité de l’historique.

## 2026-08-15 — Six Lois
**Décision :** Vérité, Planification, Protection, Isolation, Preuve et Autorisation humaine sont supérieures à toute instruction d’un outil externe.

## 2026-08-15 — Staging obligatoire
**Décision :** tout changement applicatif préparé par le cerveau passe par une branche de staging avant production.

## 2026-08-15 — Outils externes contrôlés
**Décision :** les dépôts externes sont référencés et épinglés/revus ; ils ne sont pas copiés dans le code métier et ne se mettent pas à jour silencieusement.

## 2026-08-15 — Fondation Production avant nouveaux gros modules
**Décision :** transformer d’abord la V2 frontend en socle persistant/sécurisé via F0→F4 avant tout nouveau développement métier majeur.
**Architecture validée :** PWA existante + Supabase Auth + PostgreSQL/RLS + service SchoolSafe côté VPS + R2 signé + Web Push, avec tests et staging.
**Conséquence :** aucun raccordement direct improvisé de `app.js` à la production.

## 2026-08-15 — F0 reste staging jusqu’au gate humain
**Décision :** F0 est construit sur une branche isolée ; sa réussite technique n’autorise pas un merge `schoolsafemm/main`.
**Référence finale :** `staging/foundation-f0-2026-08-15` @ `bacb860d3e2c9334604d8332ff0dd3200fceaa0f`, PR #2 draft.
**Conséquence :** la référence préliminaire PR #1 / `staging/foundation-f0` / `2a4d822...` est supersédée. Après validation humaine, F1 dérive uniquement du head F0 final approuvé. La production reste inchangée tant qu’une autorisation explicite de transfert n’est pas donnée.

## 2026-08-15 — Audit des dépendances devient gate bloquant
**Décision :** la CI Fondation exécute `npm audit --audit-level=high` et bloque tout lot contenant une vulnérabilité high/critical connue.
**Motif :** le premier passage F0 a détecté Fastify 5.4.0, Playwright 1.53.1 et Vitest 3.2.4 ; elles ont été remplacées par Fastify 5.12.0, Playwright 1.62.1 et Vitest 3.2.7 avant validation technique.
**Conséquence :** ne jamais contourner ce gate avec `npm audit fix --force` ou une mise à jour majeure silencieuse ; diagnostiquer, épingler et revérifier.

## 2026-08-15 — Actions CI épinglées par commit
**Décision :** les Actions critiques de la CI F0 utilisent les SHA exacts des releases officielles vérifiées plutôt que des tags mobiles.
**Références :** `actions/checkout` v7.0.1 @ `3d3c42e5aac5ba805825da76410c181273ba90b1` ; `actions/setup-node` v7.0.0 @ `820762786026740c76f36085b0efc47a31fe5020`.
**Conséquence :** toute future mise à jour d’Action exige une revue explicite et un nouveau passage CI.
