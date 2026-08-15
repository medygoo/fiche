# Fondation Production F2 — School Core Data Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Créer la source de vérité minimale des années, cycles, classes, élèves, responsables légaux, rattachements et personnes autorisées, avec RLS alignée sur les périmètres réels.

**Architecture:** PostgreSQL/RLS filtre les données avant réponse. Le service SchoolSafe fournit des endpoints étroits et `app/clients/data-client.js` remplace uniquement les jeux de données concernés ; l’UI existante reste intacte.

**Tech Stack:** PostgreSQL/RLS, Supabase, Node.js/TypeScript/Fastify/Zod, JavaScript PWA, Vitest, Playwright.

## Global Constraints
- F1 vert et bootstrap serveur opérationnel.
- Aucun montant financier dans les réponses pédagogiques.
- Parent : uniquement enfants explicitement rattachés.
- Enseignant : uniquement classes/matières affectées.
- Personnes autorisées n’obtiennent pas automatiquement un compte SchoolSafe.
- Toute donnée sensible modifiée produit un audit avec avant/après, auteur, rôle, appareil, date et motif lorsque le métier l’exige.

---

### Task 1: Créer année, cycles et classes

**Files:**
- Create: `supabase/migrations/202608150010_school_structure.sql`
- Extend: `supabase/seed.sql`
- Create: `tests/rls/school-structure.sql`

**Interfaces:**
- Produces tables `academic_years`, `cycles`, `classes`, `subjects`, `teacher_assignments`.
- Une seule année `is_active=true` par école via contrainte/index approprié.

- [ ] Écrire tests rouges de contrainte année active et accès non autorisé.
- [ ] Créer tables/FK/indexes.
- [ ] Seed synthétique avec classes et affectations enseignant.
- [ ] Ajouter RLS : admin/direction selon permissions ; enseignant uniquement affectations utiles.
- [ ] Vérifier tests positifs et négatifs.
- [ ] Commit.

### Task 2: Créer élèves et responsables légaux

**Files:**
- Create: `supabase/migrations/202608150011_students_guardians.sql`
- Extend: `supabase/seed.sql`
- Create: `tests/rls/student-guardian-access.sql`

**Interfaces:**
- Produces `students`, `guardians`, `student_guardians`.
- `student_guardians` contient relation, priorité, `is_primary`, droits de consultation et droits de sortie lorsque applicables.

- [ ] Test rouge : deux parents distincts ; Parent A ne peut sélectionner l’enfant de Parent B.
- [ ] Test rouge : un élève ne peut avoir plus d’un parent principal actif.
- [ ] Implémenter tables et contraintes.
- [ ] RLS parent via `student_guardians.guardian_profile_id = current_profile_id()`.
- [ ] Tester parent principal + jusqu’à trois tutelles sans élargissement implicite des droits.
- [ ] Commit.

### Task 3: Créer personnes autorisées à récupérer un élève

**Files:**
- Create: `supabase/migrations/202608150012_authorized_pickups.sql`
- Create: `tests/rls/authorized-pickups.sql`

**Interfaces:**
- Produces `authorized_pickups` avec identité, lien à l’élève, période de validité, statut, informations de vérification nécessaires et audit.
- Aucune FK obligatoire vers `auth.users`.

- [ ] Test rouge : personne autorisée inactive/expirée ne doit pas apparaître comme valide.
- [ ] Test rouge : parent non rattaché ne peut pas créer/voir l’autorisation d’un autre enfant.
- [ ] Implémenter modèle et RLS.
- [ ] Tester Direction/Gardien avec vues minimales adaptées au futur module sécurité.
- [ ] Commit.

### Task 4: Créer le service de lecture scolaire

**Files:**
- Create: `server/src/school/schema.ts`
- Create: `server/src/school/service.ts`
- Create: `server/src/school/routes.ts`
- Modify: `server/src/app.ts`
- Create: `server/tests/school-routes.test.ts`

**Interfaces:**
- `GET /school/classes`
- `GET /school/students?class_id=<uuid>`
- `GET /family/children`
- `GET /students/:id/authorized-pickups`

- [ ] Test rouge : parent appelle `/family/children` et reçoit seulement ses enfants.
- [ ] Test rouge : teacher demande classe non affectée → 403/jeu vide selon contrat choisi ; utiliser 403 pour demande explicite hors scope.
- [ ] Test rouge : pedagogy response ne contient aucune clé `amount`, `paid`, `balance`, `receipt`.
- [ ] Implémenter routes avec session F1 et requêtes respectant RLS.
- [ ] Vérifier schémas Zod des sorties pour empêcher fuite accidentelle de colonnes.
- [ ] Commit.

### Task 5: Créer `data-client` PWA

**Files:**
- Create: `app/clients/data-client.js`
- Modify minimally: `app/index.html`
- Modify targeted sections: `app/app.js`
- Create: `app/qa-school-core.cjs`

**Interfaces:**
- `SchoolSafeData.getClasses()`
- `SchoolSafeData.getStudents(classId)`
- `SchoolSafeData.getFamilyChildren()`
- `SchoolSafeData.getAuthorizedPickups(studentId)`

- [ ] QA rouge : parent staging ne voit jamais un enfant non retourné par `/family/children`.
- [ ] QA rouge : teacher ne peut pas ouvrir une classe hors affectation en modifiant le DOM/paramètre.
- [ ] Implémenter client `fetch` avec Bearer token obtenu d’Auth F1.
- [ ] Adapter seulement les données des écrans concernés ; conserver démo locale sous `APP_MODE=demo`.
- [ ] Vérifier aucune modification des animations/couleurs/photographies.
- [ ] Commit.

### Task 6: Ajouter l’audit des modifications sensibles F2

**Files:**
- Create: `server/src/audit/service.ts`
- Create: `server/tests/audit.test.ts`
- Modify F2 write services lorsque des écritures sont introduites.

**Interfaces:**
- `recordAudit({actorProfileId, action, entityType, entityId, before, after, reason, requestId, deviceId})`.

- [ ] Test rouge : modification d’un rattachement parent sans événement d’audit doit faire échouer le test d’intégration.
- [ ] Implémenter append-only via rôle serveur contrôlé.
- [ ] Vérifier qu’un client applicatif ne peut ni UPDATE ni DELETE `audit_events`.
- [ ] Commit.

### Task 7: Matrice RLS F2

**Files:**
- Create: `tests/rls/f2-role-matrix.sql`

Scénarios obligatoires :
- admin : lecture/gestion selon permissions ;
- school_head : lecture école, pas d’escalade de grants ;
- pedagogy : classes/élèves des cycles attribués, aucun montant financier ;
- teacher : classes affectées uniquement ;
- guard : identité/sortie minimale uniquement lorsque permission correspondante existe ;
- parent : enfants rattachés uniquement ;
- cashier : aucune donnée pédagogique détaillée hors besoin financier futur.

- [ ] Chaque rôle possède au moins un test autorisé et un test interdit.
- [ ] Aucun scénario utilise `service_role` pour simuler un utilisateur final.

### Task 8: Gate F2

Run:
```bash
npm run typecheck
npm test
npm run test:rls
npm run test:e2e:staging
```
Expected: PASS.

Vérifications manuelles :
- parent isolé ;
- teacher isolé ;
- pédagogie sans chiffres financiers ;
- personnes autorisées sans création de compte ;
- audit append-only ;
- interface visuellement préservée.

- [ ] Paquet de transfert F2.
- [ ] Security + Database/RLS review.
- [ ] Staging validé avant F3.
