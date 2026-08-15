# Protocole de staging — `schoolsafemm`

1. Vérifier que `main` de l’application correspond à la base du paquet ou rebaser/recalculer l’impact.
2. Créer une branche `staging/<change-id>` depuis cette base.
3. Appliquer uniquement les commits/fichiers listés dans le paquet.
4. Exécuter les tests, build, sécurité et smoke tests applicables.
5. Fournir un aperçu en ligne séparé de la production si disponible.
6. L’utilisateur examine et valide ou refuse.
7. Sans validation explicite : ne pas merger et ne pas déployer `main`.
8. Après production : vérifier le déploiement et enregistrer commit/version dans `VERSION-REGISTRY.md`.
