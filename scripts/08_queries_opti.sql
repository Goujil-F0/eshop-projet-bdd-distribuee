-- ===================================================
-- 08_QUERIES_OPTI.SQL - Requetes optimisees du scenario
-- ===================================================
-- 1. Nombre de commandes par client en 2020
-- 2. Chiffre d'affaire par client pour la categorie 10 en 2020
-- 3. Plans d'execution

-- Active l'affichage des commandes SQL
SET ECHO ON;
-- Active les messages de feedback
SET FEEDBACK ON;
-- Définit le nombre de lignes par page d'affichage
SET PAGESIZE 100;

-- Se connecte à la base globale
CONNECT app_global/Eshop123@localhost:1523/FREEPDB1;

-- ============================================
-- CREATION DES INDEX D'OPTIMISATION
-- ============================================
-- Index 1: Accélère le filtrage par date et jointure avec client
CREATE INDEX idx_commandes_date_client ON commandes(datecommande, idclient);
-- Index 2: Optimise la jointure entre commandes et produits via lignes
CREATE INDEX idx_lignecommandes_commande_prod ON lignecommandes(idcommande, idproduit);
-- Index 3: Accélère le filtrage par produit et quantité (important pour fragmentation)
CREATE INDEX idx_lignecommandes_prod_quantite ON lignecommandes(idproduit, quantite);
-- Index 4: Optimise le filtrage par catégorie
CREATE INDEX idx_produits_categ_prod ON produits(idcateg, idproduit);

-- ============================================
-- COLLECTE DE STATISTIQUES
-- ============================================
-- Bloc PL/SQL pour collecter les statistiques de toutes les tables
-- Cela permet à l'optimiseur Oracle de générer les meilleurs plans d'exécution
BEGIN
    -- Collecte les statistiques de la table CLIENTS
    DBMS_STATS.GATHER_TABLE_STATS(USER, 'CLIENTS');
    -- Collecte les statistiques de la table COMMANDES
    DBMS_STATS.GATHER_TABLE_STATS(USER, 'COMMANDES');
    -- Collecte les statistiques de la table PRODUITS
    DBMS_STATS.GATHER_TABLE_STATS(USER, 'PRODUITS');
    -- Collecte les statistiques de la table LIGNECOMMANDES
    DBMS_STATS.GATHER_TABLE_STATS(USER, 'LIGNECOMMANDES');
END;
-- / Termine le bloc PL/SQL
/

-- ============================================
-- REQUÊTE 1: Nombre de commandes par client en 2020
-- ============================================
-- Affiche un titre dans la console
PROMPT ===== Nombre de commandes par client en 2020 =====
-- Exécute la requête
SELECT
    c.idclient,                           -- ID du client
    c.codeclient,                         -- Code unique du client
    c.societe,                            -- Raison sociale
    COUNT(co.idcommande) AS nb_commandes_2020  -- Nombre de commandes en 2020
FROM clients c
JOIN commandes co                        -- Jointure avec les commandes
    ON co.idclient = c.idclient
WHERE co.datecommande >= DATE '2020-01-01'  -- Filtre: date >= 1er janvier 2020
  AND co.datecommande < DATE '2021-01-01'   -- Filtre: date < 1er janvier 2021
GROUP BY c.idclient, c.codeclient, c.societe  -- Groupe par client
ORDER BY c.idclient;                    -- Trie par ID client

EXPLAIN PLAN FOR
SELECT
    c.idclient,
    c.codeclient,
    c.societe,
    COUNT(co.idcommande) AS nb_commandes_2020
FROM clients c
JOIN commandes co
    ON co.idclient = c.idclient
WHERE co.datecommande >= DATE '2020-01-01'
  AND co.datecommande < DATE '2021-01-01'
GROUP BY c.idclient, c.codeclient, c.societe;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- ============================================
-- REQUÊTE 2: Chiffre d'affaire par client, catégorie 10 (Boissons), année 2020
-- ============================================
-- Affiche un titre
PROMPT ===== Chiffre d'affaire par client, categorie 10, annee 2020 =====
-- Exécute la requête
SELECT
    c.idclient,                      -- ID client
    c.codeclient,                    -- Code client
    c.societe,                       -- Raison sociale
    -- Calcule le chiffre d'affaires: SUM(prix * quantité * (1 - remise%))
    ROUND(SUM(p.prixunitaire * lc.quantite * (1 - lc.remise / 100)), 2) AS chiffre_affaire
FROM clients c
JOIN commandes co                    -- Jointure: clients -> commandes
    ON co.idclient = c.idclient
JOIN lignecommandes lc              -- Jointure: commandes -> lignes
    ON lc.idcommande = co.idcommande
JOIN produits p                     -- Jointure: lignes -> produits
    ON p.idproduit = lc.idproduit
WHERE co.datecommande >= DATE '2020-01-01'  -- Filtre: année 2020
  AND co.datecommande < DATE '2021-01-01'
  AND p.idcateg = 10                -- Filtre: catégorie 10 (Boissons)
GROUP BY c.idclient, c.codeclient, c.societe  -- Groupe par client
ORDER BY chiffre_affaire DESC;      -- Trie par CA décroissant

EXPLAIN PLAN FOR
SELECT
    c.idclient,
    c.codeclient,
    c.societe,
    ROUND(SUM(p.prixunitaire * lc.quantite * (1 - lc.remise / 100)), 2) AS chiffre_affaire
FROM clients c
JOIN commandes co
    ON co.idclient = c.idclient
JOIN lignecommandes lc
    ON lc.idcommande = co.idcommande
JOIN produits p
    ON p.idproduit = lc.idproduit
WHERE co.datecommande >= DATE '2020-01-01'
  AND co.datecommande < DATE '2021-01-01'
  AND p.idcateg = 10
GROUP BY c.idclient, c.codeclient, c.societe;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);
