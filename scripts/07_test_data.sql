-- ===================================================
-- 07_TEST_DATA.SQL - Jeu de donnees coherent
-- ===================================================
-- Ce script alimente surtout la base globale.
-- Les triggers recopient automatiquement les lignes vers site1/site2.

-- Active l'affichage des commandes SQL
SET ECHO ON;
-- Active les messages de feedback
SET FEEDBACK ON;

-- Se connecte à la base globale
CONNECT app_global/Eshop123@localhost:1523/FREEPDB1;

-- ============================================
-- INSERTION DES CATEGORIES
-- ============================================
-- Catégorie 10: Boissons (hors fragmentation, utile pour requîte CA 2020)
INSERT INTO categories (idcateg, nomcateg, description) VALUES (10, 'Boissons', 'Categorie pour la requete CA 2020');
-- Catégorie 35: Composants (fragmentée sur site2 si quantité > 50)
INSERT INTO categories (idcateg, nomcateg, description) VALUES (35, 'Composants', 'Fragment site2');
-- Catégorie 50: Machines (fragmentée sur site1 si quantité > 100)
INSERT INTO categories (idcateg, nomcateg, description) VALUES (50, 'Machines', 'Fragment site1');
-- Catégorie 70: Bureautique (hors fragmentation)
INSERT INTO categories (idcateg, nomcateg, description) VALUES (70, 'Bureautique', 'Categorie hors fragmentation');

-- ============================================
-- INSERTION DES PRODUITS
-- ============================================
-- Catégorie 10 (Boissons): 2 produits pour test requîte CA
INSERT INTO produits (idproduit, idcateg, designation, prixunitaire, stock) VALUES (1001, 10, 'Cafe Arabica', 12.50, 500);
INSERT INTO produits (idproduit, idcateg, designation, prixunitaire, stock) VALUES (1002, 10, 'The Vert', 9.00, 400);
-- Catégorie 35 (Composants): 2 produits pour fragmentée site2
INSERT INTO produits (idproduit, idcateg, designation, prixunitaire, stock) VALUES (3501, 35, 'Carte reseau', 180.00, 120);
INSERT INTO produits (idproduit, idcateg, designation, prixunitaire, stock) VALUES (3502, 35, 'SSD 1 To', 620.00, 90);
-- Catégorie 50 (Machines): 2 produits pour fragmentée site1
INSERT INTO produits (idproduit, idcateg, designation, prixunitaire, stock) VALUES (5001, 50, 'Serveur rack', 2500.00, 40);
INSERT INTO produits (idproduit, idcateg, designation, prixunitaire, stock) VALUES (5002, 50, 'Station de calcul', 3200.00, 30);
-- Catégorie 70 (Bureautique): 1 produit hors fragmentation
INSERT INTO produits (idproduit, idcateg, designation, prixunitaire, stock) VALUES (7001, 70, 'Imprimante laser', 450.00, 60);

-- ============================================
-- INSERTION DES CLIENTS
-- ============================================
-- 3 clients marocains avec codes et coordonnées
INSERT INTO clients (idclient, codeclient, societe, ville, pays, telephone) VALUES (1, 'CLI001', 'Atlas Services', 'Casablanca', 'Maroc', '+212600000001');
INSERT INTO clients (idclient, codeclient, societe, ville, pays, telephone) VALUES (2, 'CLI002', 'Nord Textile', 'Rabat', 'Maroc', '+212600000002');
INSERT INTO clients (idclient, codeclient, societe, ville, pays, telephone) VALUES (3, 'CLI003', 'Medina Foods', 'Fes', 'Maroc', '+212600000003');

-- ============================================
-- INSERTION DES COMMANDES
-- ============================================
-- 4 commandes : 2 en 2020, 1 en 2021 (toutes en état LIVREE)
INSERT INTO commandes (idcommande, idemploye, idclient, datecommande, statut) VALUES (101, 11, 1, DATE '2020-01-15', 'LIVREE');
INSERT INTO commandes (idcommande, idemploye, idclient, datecommande, statut) VALUES (102, 12, 1, DATE '2020-05-20', 'LIVREE');
INSERT INTO commandes (idcommande, idemploye, idclient, datecommande, statut) VALUES (103, 13, 2, DATE '2020-09-02', 'LIVREE');
INSERT INTO commandes (idcommande, idemploye, idclient, datecommande, statut) VALUES (104, 14, 3, DATE '2021-02-10', 'LIVREE');

-- ============================================
-- INSERTION DES LIGNES DE COMMANDE
-- ============================================
-- Ces insertions déclenchent automatiquement les triggers de synchronisation
-- Ligne 1: Produit catégorie 10, quantité 20 -> Reste global (hors fragmentation)
INSERT INTO lignecommandes (idlignecommande, idcommande, idproduit, quantite, remise) VALUES (10001, 101, 1001, 20, 5);
-- Ligne 2: Produit catégorie 35, quantité 80 -> Reste global (80 > 50, mais filtré autrement)
INSERT INTO lignecommandes (idlignecommande, idcommande, idproduit, quantite, remise) VALUES (10002, 101, 3501, 80, 3);
-- Ligne 3: Produit catégorie 50, quantité 150 -> Fragmenté site1 (150 > 100, cat=50) TRIGGER ACTIF
INSERT INTO lignecommandes (idlignecommande, idcommande, idproduit, quantite, remise) VALUES (10003, 102, 5001, 150, 8);
-- Ligne 4: Produit catégorie 10, quantité 30 -> Reste global
INSERT INTO lignecommandes (idlignecommande, idcommande, idproduit, quantite, remise) VALUES (10004, 102, 1002, 30, 0);
-- Ligne 5: Produit catégorie 35, quantité 65 -> Fragmenté site2 (65 > 50, cat=35) TRIGGER ACTIF
INSERT INTO lignecommandes (idlignecommande, idcommande, idproduit, quantite, remise) VALUES (10005, 103, 3502, 65, 4);
-- Ligne 6: Produit catégorie 50, quantité 90 -> Reste global (90 <= 100)
INSERT INTO lignecommandes (idlignecommande, idcommande, idproduit, quantite, remise) VALUES (10006, 103, 5002, 90, 2);
-- Ligne 7: Produit catégorie 35, quantité 120 -> Fragmenté site2 (120 > 50, cat=35) TRIGGER ACTIF
INSERT INTO lignecommandes (idlignecommande, idcommande, idproduit, quantite, remise) VALUES (10007, 104, 3501, 120, 1);

-- Valide toutes les insertions et synchronisations des triggers
COMMIT;
