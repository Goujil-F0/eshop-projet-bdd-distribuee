Implémentation d’un Système de Base de Données Distribuée (BDD-D) — Projet EShop

Oracle Docker Academic

Ce dépôt contient les travaux de conception et d’implémentation d'une infrastructure de base de données distribuée pour une plateforme d'e-commerce (EShop). Le projet met l'accent sur la transparence de localisation, la fragmentation horizontale et la synchronisation transactionnelle.

======================================================================

1. INFORMATIONS GÉNÉRALES
   ======================================================================

* Auteurs : GOUJIL Fatima Ezzahrae & HAIMEUR Nisrine
* Institution : Université Hassan I, Faculté des Sciences et Techniques, Settat
* Module : Bases de Données Avancées (Master / Cycle Ingénieur)
* Encadrant : M. BAHAJ
* Année Universitaire : 2025 – 2026

======================================================================
2. RÉSUMÉ DE L'ARCHITECTURE
===========================

Le système repose sur une architecture à trois nœuds isolés via Docker, simulant un environnement multi-sites réel.

Topologie du Réseau

* Nœud Coordinateur (db_global) :
  Héberge le schéma global complet et les déclencheurs de routage.

* Nœud Site 1 (db_site1) :
  Fragment dédié aux commandes de gros volume (Grossistes).

* Nœud Site 2 (db_site2) :
  Fragment dédié aux commandes de détail.

Stratégie de Fragmentation

Nous avons implémenté une fragmentation horizontale dérivée sur la table LigneCommandes :

* Fragment R_1 :
  σ(quantite ≥ 100) (LigneCommandes)
  Hébergé sur db_site1.

* Fragment R_2 :
  σ(quantite < 100) (LigneCommandes)
  Hébergé sur db_site2.

======================================================================
3. STACK TECHNIQUE
==================

* SGBD : Oracle Database 21c Express Edition (XE)
* Orchestration : Docker Compose v3.8
* Réseautage : Docker Bridge (réseau eshop-net)
* Logique Applicative : PL/SQL (Procédures stockées, Triggers Distribués)
* Outils de Diagnostic :

  * SQL*Plus
  * SQL Developer
  * iputils (ping/hostname)

======================================================================
4. GUIDE DE DÉPLOIEMENT
=======================

Prérequis

* Docker Desktop installé
* Docker Compose installé
* Client SQL (SQL Developer ou SQL*Plus)

Étape 1 : Initialisation de l'Infrastructure

Clonez le dépôt puis lancez les conteneurs :

docker-compose up -d --build

Note :
Attendez environ 2 à 3 minutes afin que les instances Oracle deviennent totalement opérationnelles (statut "Healthy").

Étape 2 : Ordonnancement des Scripts SQL

Pour garantir l'intégrité référentielle distribuée, les scripts doivent être exécutés dans l'ordre suivant :

Phase I
Script : 01_setup_users.sql
Cible : Tous les sites
Description :
Création des utilisateurs app_global, app_site1 et app_site2.

Phase II
Script : 02_tables_global.sql
Cible : db_global
Description :
Définition du schéma global maître.

Phase III
Script : 04_database_links.sql
Cible : Tous les sites
Description :
Établissement des liens bidirectionnels (Database Links).

Phase IV
Script : 07_test_data.sql
Cible : db_global
Description :
Injection du jeu de données initial.

Phase V
Script : 10_scenario2_tables_sites.sql
Cible : Site 1 et Site 2
Description :
Création des fragments physiques locaux.

Phase VI
Script : 11_scenario2_proc_sites.sql
Cible : Site 1 et Site 2
Description :
Logique CRUD locale et nettoyage en cascade.

Phase VII
Script : 12_scenario2_trig_global.sql
Cible : db_global
Description :
Cœur du système : Triggers de routage et migration des données.

======================================================================
5. PROTOCOLES DE VALIDATION ACADÉMIQUE
======================================

A. Test de Connectivité Distribuée

Exécutez :

15_connectivity_tests.sql

Ce script vérifie :

* La résolution DNS Docker
* La validité des Database Links
* La communication entre les trois instances Oracle

Succès attendu :

SUCCESS: site1_link est OPERATIONNEL.

---

B. Validation de la Réplication et Migration

Exécutez :

14_demo_replication.sql

Cycle de vie observé :

1. Insertion
   Une ligne avec quantite = 150 est insérée sur le schéma global puis routée vers le Site 1.

2. Migration
   La quantité est modifiée à 50.
   Le trigger global supprime automatiquement la ligne du Site 1 et la recrée sur le Site 2.

3. Suppression
   Une suppression effectuée sur le schéma global entraîne automatiquement la suppression du fragment distant concerné.

---

C. Analyse de Performance (Optimisation)

Exécutez :

16_perf_comparison.sql

Comparaison des plans d'exécution :

* Sans index :
  Full Table Scan
  Coût élevé.

* Avec index composite :
  Index Range Scan
  Réduction d'environ 80 % des E/S disque.

======================================================================
6. STRUCTURE DU PROJET
======================

.
├── docker-compose.yml
│   └── Orchestration des trois sites
│
├── Dockerfile
│   └── Image Oracle étendue avec outils réseau
│
├── scripts/
│   ├── 01_setup_users.sql
│   │   └── Initialisation sécurité
│   │
│   ├── 04_database_links.sql
│   │   └── Maillage réseau BDD
│   │
│   ├── 12_scenario2_...
│   │   └── Logique de fragmentation optimale
│   │
│   └── 16_perf_comparison.sql
│       └── Benchmarking
│
└── support/
└── Documentation et captures d'écran

======================================================================
7. CONCEPTS THÉORIQUES APPLIQUÉS
================================

1. Théorème CAP

Le système privilégie :

* Cohérence (Consistency)
* Tolérance au fractionnement réseau (Partition Tolerance)

au détriment de la disponibilité immédiate en cas de panne réseau.

Le modèle adopté est donc :

CP (Consistency + Partition Tolerance)

---

2. Transparence de Localisation

L'utilisateur final interagit exclusivement avec le schéma global db_global sans avoir connaissance de l'emplacement physique réel des données.

---

3. Two-Phase Commit (2PC)

Le protocole natif Oracle Two-Phase Commit est utilisé afin de garantir :

* l'atomicité,
* la cohérence,
* et la fiabilité

des transactions distribuées.

======================================================================
CONCLUSION
==========

Ce projet a été réalisé à des fins pédagogiques afin de démontrer la puissance, les mécanismes internes et la complexité des systèmes de bases de données distribuées modernes.
