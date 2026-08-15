# Master Plan — SchoolSafe V2

## Phase A — Cerveau durable
1. Loi 0 + Six Lois.
2. Mémoire compacte et tour de contrôle.
3. Agents spécialisés.
4. Catalogue d’outils approuvés.
5. Protocoles de changement, staging, transfert et rollback.
6. Validation automatique du cerveau.

## Phase B — Audit complet de l’application
1. Inventorier modules réellement présents dans `schoolsafemm`.
2. Cartographier routes, rôles, permissions, données et dépendances.
3. Identifier terminé / partiel / manquant / bloqué.
4. Établir les critères d’acceptation par module.

## Phase C — Construction module par module
Chaque module suit : contexte → spec → plan → branche isolée → agents → tests → sécurité → revue → paquet de transfert → staging → validation humaine → production.

## Phase D — Durcissement
Tests E2E, RLS, sécurité, offline, sauvegardes, performance, accessibilité, reprise incident et observabilité.

## Phase E — Release SchoolSafe V2 stable
Versionner le commit stable, documenter rollback, publier uniquement après validation finale.

## Règle
Ce plan est une trajectoire. `CONTROL-TOWER.md` et `CURRENT-STATE.md` disent toujours quelle étape est réellement active.
