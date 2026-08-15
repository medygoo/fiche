# Registre des versions

## Application SchoolSafe V2
| Date | État | Commit | Description |
|---|---|---|---|
| 2026-08-15 | Production vérifiée | `c347bef91b3fdbdca0d2a94e185b5914b5360d8e` | Harmonisation visuelle V3 publiée |

## Cerveau SchoolSafe
| Date | Version | Référence | État |
|---|---|---|---|
| 2026-08-15 | Brain V1 | `6dd2ca7c790970e1b88c3e092f327d9de1c8c43c` | intégré sur `main`, CI post-fusion PASS |
| 2026-08-15 | Brain V1 construction | branche `brain-v1-governance-2026-08-15` | conservée comme archive de construction |
| 2026-08-15 | Brain V1 Skills protocol | branche `brain-v1-skills-protocol-2026-08-15` | protocole Skills et mémoire post-intégration en validation |

Le commit de production applicative reste enregistré séparément : cerveau et application ne partagent jamais une version implicite. Toute évolution du cerveau suit sa propre branche, CI et validation avant intégration.
