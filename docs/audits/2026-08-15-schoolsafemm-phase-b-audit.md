# Audit Phase B — SchoolSafe V2 (`medygoo/schoolsafemm`)

Date : 15 août 2026

## Référence vérifiée

- Application réelle : `medygoo/schoolsafemm`
- Branche auditée : `main`
- Commit audité : `c347bef91b3fdbdca0d2a94e185b5914b5360d8e`
- Cerveau : `medygoo/fiche`
- Mode : lecture seule ; aucune mutation de l'application, du VPS, de Supabase, de R2 ou de la production.

## Conclusion exécutive

SchoolSafe V2 possède un frontend/PWA avancé et cohérent, avec une architecture de profils, des parcours pédagogiques et financiers interactifs, des PDF, un mode hors connexion local et des tests Playwright. En revanche, l'application auditée reste une prévisualisation frontend : l'authentification, l'autorité des permissions, les données métier, la synchronisation, le stockage et les opérations sensibles ne sont pas encore raccordés à un backend de production.

La prochaine priorité n'est donc pas de créer davantage d'écrans. La priorité est de construire la **Fondation Production** qui permettra de raccorder progressivement les modules existants sans modifier leur comportement visuel ni affaiblir les règles de sécurité.

## Preuves structurantes

- `app/README.md` indique explicitement : aucune connexion au VPS, à Supabase ou à une base de données ; données du formulaire conservées localement.
- `coordination/STATUS_V2.md` confirme que les étapes PWA et bilingue sont des fondations frontend locales, avec confirmation de synchronisation simulée.
- `app/app.js` utilise un catalogue local de rôles, des jeux de données de démonstration et un formulaire de connexion qui ouvre l'espace de démonstration sans authentification distante.
- `app/offline-sync.js` utilise IndexedDB et un `demoAdapter`; sans adaptateur, le code signale qu'un connecteur serveur est requis.
- `docs/ACCESS_MODEL.md` précise que le frontend ne constitue pas l'autorité de sécurité : permissions et périmètres devront être appliqués côté serveur et base.
- `docs/OFFLINE_SYNC_CONTRACT.md` réserve encore au futur raccordement serveur le chiffrement local, les sessions, l'autorité des permissions et la résolution réelle des conflits.
- `.github/workflows/static.yml` déploie `./app` sur GitHub Pages à chaque push sur `main` sans gate de tests applicatifs préalable.

## Carte officielle — état par domaine

### Terminé au niveau frontend

- Écrans accueil, galerie, authentification visuelle et configuration.
- Shell des profils et navigation métier.
- Catalogue de 15 profils de démonstration.
- Modèle d'accès `Rôle -> Branche -> Groupe métier -> Fonction -> Action -> Vue de données -> Périmètre`.
- PWA, Service Worker, cache applicatif et file IndexedDB.
- Interface français/anglais et préférences locales.
- Génération de plusieurs PDF locaux.
- Tests Playwright couvrant des parcours frontend importants.
- Harmonisation visuelle V3 publiée.

### Partiel — logique frontend avancée mais non persistée côté serveur

- Pédagogie : devoirs, cotations, règles, bulletins, rattrapage.
- Épreuves certificatives : ENAFEP, TENASOSP, EXETAT.
- Finance : structure des frais, caisse, reçus, soldes, rapports.
- Console rôles et permissions.
- Synchronisation hors ligne et audit local.
- Préférence linguistique et documents bilingues.

### Manquant pour une vraie exploitation production

- Authentification réelle et cycle de session.
- Récupération de compte et activation réelle.
- Autorité serveur des rôles, permissions, vues de données et périmètres.
- Schéma PostgreSQL/Supabase de production pour la V2.
- Politiques RLS et tests RLS.
- Données réelles élèves, parents, tuteurs, classes et affectations.
- Connecteur de synchronisation serveur, idempotence et résolution des conflits.
- Chiffrement adapté des données sensibles conservées hors connexion.
- QR/scans réels, entrées, sorties et personnes autorisées.
- R2 réel et métadonnées de documents.
- Notifications Web Push réelles et communication serveur.
- RH, biométrie, santé et cantine réellement raccordés.
- Comptabilité/SYSCOHADA après spécification réglementaire dédiée.
- Staging applicatif et CI applicative bloquante avant production.

## Analyse par agent

### Architecte

**Constat :** le frontend concentre une grande partie des comportements dans `app/app.js`. Cette structure est acceptable pour la prévisualisation, mais le raccordement production ne doit pas introduire des appels serveur dispersés dans ce fichier.

**Recommandation :** introduire des frontières explicites : Auth/Session, Data Access, Sync, Files, Notifications et Audit. Le frontend existant doit consommer des contrats stables, permettant de remplacer progressivement les jeux de données locaux sans refonte globale de l'interface.

**Gate visé :** `architecture-approved` après validation de la conception Fondation Production.

### Sécurité

**Constat :** la connexion actuelle est de démonstration ; le changement de rôle est frontend ; la matrice des permissions n'est pas appliquée par un serveur ; les opérations offline ne disposent pas encore du modèle de session/chiffrement prévu par contrat.

**Risques critiques si raccordement naïf :** exposition de données entre profils, privilèges excessifs, clé privilégiée dans le navigateur, falsification de rôle, reçus/numéros générés côté client, synchronisation rejouée ou dupliquée.

**Exigences :** Supabase Auth pour l'identité, RLS obligatoire, aucune clé `service_role` dans le frontend, contrôles serveur avant réponse, journal d'audit pour actions sensibles, secrets uniquement côté serveur, séparation claire public/privé et tests négatifs de permission.

**Gate visé :** `security-evidence-ready`.

### Base de données / RLS

**Constat :** aucun schéma V2 de production n'est actuellement prouvé par le dépôt applicatif audité.

**Recommandation :** commencer par un schéma minimal de fondation plutôt que par toutes les tables métier : instance école, profils, rôles/grants, périmètres, année scolaire, classes de base, élèves, responsables légaux, rattachements, appareils, journal d'audit, opérations de synchronisation et métadonnées de fichiers. Les tables pédagogiques/finance/QR seront ajoutées par modules après validation de leurs contrats.

**Gate visé :** `migration-review-ready`; aucune migration de production automatique.

### Backend / Supabase

**Constat :** aucun connecteur serveur réel n'est utilisé par `app.js`; `offline-sync.js` fonctionne avec un adaptateur local.

**Recommandation :** utiliser Supabase Auth et PostgreSQL/RLS comme socle, complétés par un service SchoolSafe côté VPS pour les opérations privilégiées ou orchestrées : bootstrap de session, synchronisation par lot, numérotation officielle, notifications, URLs signées R2 et intégrations externes.

**Gate visé :** `backend-contract-ready`.

### Tests

**Constat :** des scénarios Playwright riches existent, mais le workflow Pages déploie directement sur push `main` et l'historique indique qu'une exécution locale complète avait été bloquée par l'absence de navigateur compatible.

**Recommandation :** distinguer quatre niveaux de preuve : tests unitaires/contrats, tests RLS, intégration backend avec données synthétiques, E2E navigateur sur staging. La production ne doit plus être l'endroit où l'on découvre une régression.

**Gate visé :** `test-evidence-ready`.

## Risques prioritaires

1. **Critique — Autorité frontend des rôles** : acceptable en démo, interdite en production.
2. **Critique — Absence de RLS prouvée pour V2** : aucun raccordement de données réelles avant matrice et tests.
3. **Élevé — Synchronisation simulée** : les opérations peuvent sembler confirmées sans serveur réel.
4. **Élevé — Déploiement direct depuis `main`** : absence de gate applicatif avant GitHub Pages.
5. **Élevé — Monolithe frontend** : risque de couplage lors du raccordement de nombreux modules.
6. **Moyen — Données locales sensibles** : chiffrement/session offline à définir avant données réelles.
7. **Moyen — Règles réglementaires non figées** : SYSCOHADA, paie, biométrie et examens doivent rester hors implémentation tant que leurs specs ne sont pas validées.

## Décision d'audit

La Phase B établit que la V2 doit entrer dans une phase **Fondation Production** avant tout développement fonctionnel majeur supplémentaire.

Ordre recommandé :

1. architecture et contrats ;
2. Auth/session ;
3. schéma minimal + RLS ;
4. bootstrap serveur des rôles/périmètres ;
5. sync serveur + idempotence ;
6. élèves/familles/classes ;
7. sécurité QR ;
8. raccordement pédagogie ;
9. raccordement finance ;
10. communication, R2, RH et autres modules ;
11. durcissement final.

Aucune de ces étapes n'autorise implicitement une mutation de `medygoo/schoolsafemm/main`, du VPS, de Supabase ou de la production.