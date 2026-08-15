# SchoolSafe V2 — Conception Fondation Production

Date : 15 août 2026

## Statut

Conception proposée à partir de l'audit Phase B de `medygoo/schoolsafemm` au commit `c347bef91b3fdbdca0d2a94e185b5914b5360d8e`.

Ce document ne constitue ni une migration, ni un raccordement Supabase, ni une autorisation de déploiement. Il prépare la prochaine phase de planification après validation humaine.

## Objectif

Transformer progressivement la prévisualisation frontend SchoolSafe V2 en application de production persistante, sécurisée et synchronisable, **sans refondre l'interface existante et sans changer les comportements visuels validés**.

Le premier lot ne construit pas tous les modules métier. Il crée le socle commun dont dépendent Auth, permissions, élèves/familles, QR, pédagogie, finance, documents et synchronisation.

## Contraintes non négociables

- Une instance SchoolSafe appartient à une seule école.
- Aucun sélecteur multi-écoles dans l'application.
- Le frontend n'est jamais l'autorité de sécurité.
- Aucun rôle ou périmètre ne peut être choisi par l'utilisateur en production.
- Aucune clé privilégiée Supabase ou R2 dans le navigateur.
- Auth, RLS, données, migrations, secrets et production restent protégés par analyse d'impact et autorisation humaine.
- L'interface actuelle, les écrans d'accueil, photos, textes, animations et parcours visibles sont préservés pendant la Fondation Production.
- Les données de test sont synthétiques ; aucune donnée réelle de production n'est utilisée pour les tests destructifs.
- Aucun reçu officiel ni numéro métier sensible ne devient définitif uniquement côté client.

## Approches considérées

### A — Raccordement direct du frontend à Supabase

Avantage : rapide pour obtenir de la persistance.

Inconvénients : risque élevé de disperser les appels et règles de sécurité dans `app.js`, de figer trop tôt le schéma et de confondre visibilité frontend avec autorisation réelle.

**Rejetée comme stratégie principale.**

### B — Raccordement complet module par module

Avantage : valeur fonctionnelle visible rapidement sur un premier module.

Inconvénient : chaque module devrait résoudre séparément session, permissions, synchronisation, audit, fichiers et erreurs ; duplication importante et risque d'incohérence.

**Acceptable seulement après création du socle commun.**

### C — Fondation Production puis raccordement progressif

Créer d'abord les contrats communs, le modèle d'identité, l'autorité des permissions, le schéma minimal, le sync et la couche d'accès serveur. Ensuite remplacer progressivement les jeux de données locaux par des adaptateurs réels.

**Approche recommandée.** Elle minimise les changements frontend et évite qu'un module métier impose seul une architecture à toute l'application.

## Architecture cible

### 1. Frontend PWA

Le frontend existant reste la couche de présentation.

Il ne doit plus connaître directement les détails des tables. Il appelle des modules clients dédiés :

- `auth-client` : session et état d'authentification ;
- `bootstrap-client` : contexte utilisateur au démarrage ;
- `data-client` : lectures/écritures métier autorisées ;
- `sync-client` : file locale et synchronisation ;
- `files-client` : demandes d'upload/download signés ;
- `notification-client` : enregistrement Web Push et préférences ;
- `audit-context` : corrélation des actions sans exposer les journaux privilégiés.

Ces frontières peuvent être introduites progressivement sans déplacer immédiatement toute la logique UI de `app.js`.

### 2. Supabase Auth

Supabase Auth devient l'autorité d'identité :

- connexion e-mail ;
- connexion téléphone si le canal retenu est disponible/configuré ;
- activation initiale ;
- récupération de compte ;
- renouvellement de session ;
- déconnexion ;
- invalidation de session.

Le frontend reçoit une session utilisateur, jamais une capacité privilégiée.

### 3. PostgreSQL + RLS

PostgreSQL devient la source de vérité métier.

Les politiques RLS doivent appliquer les mêmes dimensions que le modèle frontend :

`Utilisateur -> Rôle -> Permission -> Action -> Vue de données -> Périmètre`

La règle essentielle est que le filtrage des données soit effectué **avant** qu'une réponse ne soit renvoyée au navigateur.

### 4. Service SchoolSafe côté VPS

Un service applicatif léger complète Supabase pour les opérations qui ne doivent pas être confiées au navigateur ou qui impliquent plusieurs systèmes.

Responsabilités initiales :

- `session/bootstrap` ;
- synchronisation par lots ;
- idempotence et détection de conflits ;
- opérations nécessitant privilège contrôlé ;
- numérotation officielle de documents/reçus ;
- génération ou préparation de notifications ;
- création d'URLs signées R2 ;
- webhooks et intégrations externes futures ;
- health/readiness endpoints.

Ce service n'est pas une seconde base de données. PostgreSQL reste la source de vérité.

### 5. Cloudflare R2

R2 reste le stockage des fichiers privés et publics selon la politique SchoolSafe.

Le navigateur ne reçoit pas de secret R2. Le backend fournit des URLs signées de durée courte après contrôle de permission. PostgreSQL conserve uniquement les métadonnées et références nécessaires.

## Schéma minimal Fondation Production

Le premier schéma doit être volontairement réduit.

### Identité et instance

- `school` — singleton logique de l'instance ;
- `school_settings` — configuration validée ;
- `profiles` — profil applicatif lié à `auth.users` ;
- `devices` — appareils enregistrés pour session/offline lorsque requis.

### Accès

- `roles` ;
- `permissions` ;
- `profile_roles` ;
- `role_permission_grants` ;
- `scope_assignments` — classe, cycle, service, portail, enfant ou période selon le rôle.

Les valeurs de permission sont des identifiants stables, distincts des libellés FR/EN.

### Scolarité de base

- `academic_years` ;
- `cycles` ;
- `classes` ;
- `subjects` lorsque nécessaire au bootstrap pédagogique ;
- `students` ;
- `guardians` ;
- `student_guardians` ;
- `authorized_pickups`.

### Plateforme

- `audit_events` — append-only côté usage normal ;
- `sync_operations` — opération, état, idempotency key, version, auteur, appareil ;
- `file_objects` — métadonnées R2, visibilité et propriétaire logique ;
- `notification_subscriptions` — abonnements Web Push lorsque cette étape sera activée.

Les tables détaillées pédagogie, finance, QR, RH, santé, cantine et comptabilité ne font pas partie du premier lot Fondation sauf dépendance indispensable explicitement justifiée.

## Contrats serveur initiaux

### `POST /session/bootstrap`

Entrée : session authentifiée.

Sortie minimale :

- profil ;
- rôles actifs ;
- permissions effectives ;
- périmètres ;
- configuration école utile ;
- année scolaire active ;
- fonctionnalités activées ;
- politique offline/session ;
- version des contrats.

Le serveur ne fait jamais confiance à un rôle transmis par le navigateur.

### `POST /sync/batch`

Entrée : lot ordonné d'opérations locales avec identifiants uniques et version attendue.

Sortie par opération :

- `accepted` ;
- `rejected` ;
- `conflict` ;
- `retryable_error` ;
- version serveur résultante ;
- identifiant officiel éventuel.

Une même `idempotency_key` ne doit jamais créer deux opérations métier.

### `POST /files/sign-upload`

Contrôle d'abord rôle, permission, type de fichier, taille, destination logique et visibilité. Retourne ensuite une autorisation signée courte durée.

### `POST /files/sign-download`

Vérifie que l'utilisateur possède l'accès au fichier demandé avant de produire une URL signée.

### `GET /health` et `GET /ready`

Séparent disponibilité du processus et capacité réelle à servir les dépendances requises.

## Parcours d'authentification

1. L'utilisateur fournit son identifiant et son secret au flux Auth.
2. Supabase Auth émet une session valide.
3. Le frontend appelle `session/bootstrap`.
4. Le backend calcule rôles, permissions et périmètres depuis la base.
5. Le frontend construit l'espace visible à partir de ce résultat.
6. Chaque opération ultérieure est contrôlée à nouveau côté serveur/RLS ; la visibilité UI n'est jamais considérée comme une preuve d'autorisation.

Le sélecteur de rôle de démonstration reste uniquement dans les environnements de démonstration/test et doit être impossible en production.

## Synchronisation hors connexion

La file IndexedDB existante reste un prototype utile, mais le contrat réel impose :

- identifiant d'opération immuable ;
- clé d'idempotence ;
- auteur et appareil ;
- horodatage local + serveur ;
- version métier attendue ;
- état explicite ;
- réponse serveur conservée ;
- conflit sans écrasement silencieux ;
- règles d'expiration de session ;
- protection locale proportionnée à la sensibilité des données.

Les opérations critiques de sécurité conservent leur priorité mais ne peuvent être déclarées définitivement confirmées qu'après réponse du serveur.

## Sécurité

### Contrôles obligatoires

- RLS activée sur toute table exposée au client.
- Tests positifs **et négatifs** de RLS.
- `service_role` uniquement dans des processus serveur protégés.
- Rotation et gestion des secrets hors dépôt.
- Validation serveur des entrées.
- Limitation de débit sur Auth et endpoints sensibles.
- Audit append-only des actions sensibles.
- Corrélation requête/opération pour investigation.
- CORS limité aux origines attendues lorsque applicable.
- Aucun détail sensible dans les messages d'erreur publics.
- URLs R2 signées à durée courte.
- Contrôle de type/taille des fichiers et stratégie anti-malware à définir avant documents à risque.
- En production, suppression/désactivation des modes de démonstration permettant le changement libre de profil.

### Menaces à couvrir par tests

- utilisateur forgeant un autre rôle ;
- parent tentant de lire un enfant non rattaché ;
- enseignant lisant une classe non affectée ;
- responsable pédagogique tentant d'obtenir des montants financiers ;
- caisse modifiant paramètres globaux ;
- double soumission d'une opération offline ;
- accès direct à une URL R2 expirée ou appartenant à un autre périmètre ;
- rejeu d'une session expirée ;
- tentative d'appel à un endpoint privilégié depuis un client non autorisé.

## Gestion des erreurs

Les contrats utilisent un format stable :

- `code` machine ;
- `message` utilisateur non sensible ;
- `request_id` ;
- `retryable` ;
- détails internes uniquement dans les logs serveur.

Catégories minimales : authentification requise, permission refusée, validation invalide, conflit de version, doublon/idempotence, dépendance indisponible et erreur interne.

Les erreurs de synchronisation ne doivent jamais transformer silencieusement une opération en succès.

## Stratégie de tests

### Niveau 1 — Unitaires/contrats

- validation de payloads ;
- calcul de permissions effectives ;
- idempotence ;
- traduction des erreurs ;
- règles de sync indépendantes de l'UI.

### Niveau 2 — Base/RLS

Matrice de tests par rôle et périmètre, incluant systématiquement des refus attendus.

### Niveau 3 — Intégration

Environnement Supabase/PostgreSQL de test avec données synthétiques : Auth -> bootstrap -> lecture/écriture -> audit -> sync.

### Niveau 4 — E2E staging

Les parcours Playwright existants deviennent une base à compléter : vraie connexion de test, profils, parent, enseignant, caisse, offline/reconnexion, permissions refusées, PDF et mobile.

### Niveau 5 — Sécurité et livraison

- scan dépendances/secrets ;
- vérification absence de clé privilégiée dans l'artifact frontend ;
- tests de headers/configuration ;
- build/smoke staging ;
- production bloquée si gate requis rouge.

## CI/CD cible

Le workflow de production ne doit plus signifier `push main -> déploiement immédiat` sans preuve applicative.

Flux cible :

`branche isolée -> PR -> validation contexte/spec -> tests -> sécurité -> revue -> paquet de transfert -> staging -> validation humaine -> merge/release -> production -> smoke post-déploiement`

La mise en œuvre de ce changement CI/CD est une tâche applicative séparée ; ce document ne modifie pas le workflow actuel.

## Ordre d'implémentation recommandé

### Lot F0 — Contrats et environnement de test

- conventions d'erreurs ;
- identifiants stables de permissions ;
- configuration d'environnement ;
- Supabase/PostgreSQL de test ;
- données synthétiques.

### Lot F1 — Auth + bootstrap + accès

- Supabase Auth ;
- profils ;
- rôles/grants/scopes ;
- RLS de fondation ;
- endpoint bootstrap ;
- tests de sécurité.

### Lot F2 — Élèves/familles/classes

- données fondamentales ;
- rattachements parent-enfant ;
- périmètres enseignant/classes ;
- personnes autorisées ;
- audits.

### Lot F3 — Synchronisation réelle

- opérations idempotentes ;
- gestion des versions/conflits ;
- session offline ;
- reprise ;
- observabilité.

### Lot F4 — Fichiers/R2 et notifications de base

- métadonnées ;
- URLs signées ;
- règles public/privé ;
- préparation Web Push.

Après F0-F4, chaque module métier suit son propre cycle spec -> plan -> implémentation -> sécurité -> tests -> staging -> validation.

## Critères d'acceptation de la Fondation

La Fondation Production n'est pas considérée prête tant que les preuves suivantes ne sont pas disponibles :

1. un utilisateur de test s'authentifie réellement ;
2. son rôle et son périmètre proviennent du serveur et non de l'UI ;
3. un accès autorisé réussit et le même accès depuis un rôle interdit échoue ;
4. un parent ne peut jamais lire un enfant non rattaché ;
5. un profil pédagogique ne reçoit aucun montant financier interdit ;
6. une opération sync rejouée n'est pas dupliquée ;
7. un conflit conserve les deux états nécessaires à la résolution ;
8. un fichier privé n'est accessible qu'après contrôle serveur ;
9. aucune clé privilégiée n'est présente dans le frontend ;
10. la suite d'intégration et les tests RLS passent sur environnement synthétique ;
11. les parcours frontend protégés existants restent fonctionnels ;
12. aucun déploiement production n'a lieu sans Gate 8 — autorisation humaine.

## Rollback conceptuel

Pendant la construction, l'application publiée actuelle reste inchangée. Les premiers lots vivent en environnement de test/staging isolé.

Lors du futur raccordement frontend, chaque adaptateur réel doit pouvoir être désactivé au profit du comportement précédent tant que le module n'a pas franchi ses gates. Les migrations futures devront être réversibles ou accompagnées d'un plan de restauration documenté.

## Gates

- Gate 0 — contexte : satisfait pour la conception, références Git vérifiées.
- Gate 1 — conception : **en attente de revue humaine de ce document**.
- `architecture-approved` : en attente de validation humaine.
- `backend-contract-ready` : non atteint ; nécessite le plan puis les contrats implémentés/testés.
- `migration-review-ready` : non atteint.
- `security-evidence-ready` : non atteint.
- `test-evidence-ready` : non atteint.

## Frontière d'autorisation

La validation de ce design autorisera uniquement la rédaction du plan détaillé Fondation Production. Elle n'autorise pas à elle seule :

- une mutation de `medygoo/schoolsafemm/main` ;
- un déploiement ;
- une migration Supabase de production ;
- une modification VPS/R2 ;
- l'utilisation de secrets de production.