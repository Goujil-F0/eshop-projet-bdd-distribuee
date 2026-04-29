-- ===================================================
-- 09_MONITORING.SQL - Requete optimale du site 1
-- ===================================================
-- Adapte la solution finale du document Word en version SQL executable.

-- Active l'affichage des commandes SQL
SET ECHO ON;
-- Active les messages de feedback
SET FEEDBACK ON;
-- Définit le nombre de lignes par page d'affichage
SET PAGESIZE 100;

-- ============================================
-- VUE 1: Calcul du CA du fragment site1
-- ============================================
-- Affiche un message de séparation
PROMPT ===== Vue locale sur le site 1 =====
-- Se connecte au site 1
CONNECT app_site1/Eshop123@localhost:1524/FREEPDB1;

-- Crée ou remplace la vue view1
-- Cette vue calcule le CA pour TOUS les produits du fragment site1
CREATE OR REPLACE VIEW view1 AS
SELECT
    p1.idproduit,                              -- ID du produit
    p1.designation,                            -- Désignation du produit
    -- Calcule le chiffre d'affaires: SUM(prix * quantité * (1 - remise%))
    SUM(p1.prixunitaire * lc1.quantite * (1 - lc1.remise / 100)) AS ca
FROM produits1 p1                             -- Table produits du site1
JOIN lignecommandes1 lc1                      -- Jointure avec les lignes
    ON p1.idproduit = lc1.idproduit
GROUP BY p1.idproduit, p1.designation;       -- Groupe par produit

-- ============================================
-- VUE 2: Données complémentaires de la base globale
-- ============================================
-- Affiche un message
PROMPT ===== Vue complementaire sur la base globale =====
-- Se connecte à la base globale
CONNECT app_global/Eshop123@localhost:1523/FREEPDB1;

-- Crée ou remplace la vue view2
-- Cette vue calcule le CA pour les produits catégorie 50 NON fragmentés
-- (ceux qui restent uniquement sur la base globale)
CREATE OR REPLACE VIEW view2 AS
SELECT
    p.idproduit,                              -- ID du produit
    p.designation,                            -- Désignation du produit
    -- Calcule le chiffre d'affaires
    SUM(p.prixunitaire * lc.quantite * (1 - lc.remise / 100)) AS ca
FROM produits p                               -- Table produits globale
JOIN lignecommandes lc                        -- Jointure avec les lignes
    ON p.idproduit = lc.idproduit
WHERE p.idcateg = 50                          -- Filtre: catégorie 50 (Machines)
  AND lc.quantite <= 100                      -- Filtre: quantité <= 100 (non fragmentés)
GROUP BY p.idproduit, p.designation;         -- Groupe par produit

-- ============================================
-- REQUÊTE FINALE: Union des deux vues
-- ============================================
-- Affiche un message
PROMPT ===== Requete finale conforme au document =====
-- Requête de consolidation
SELECT
    idproduit,                                -- ID du produit
    designation,                              -- Désignation
    SUM(ca) AS cat                            -- Total du CA pour ce produit
FROM (
    -- Union ALL combine les données de site1 et du complément global
    SELECT * FROM view1@site1_link            -- Vue site1 (accédée via lien distribué)
    UNION ALL
    SELECT * FROM view2                       -- Vue globale
)
GROUP BY idproduit, designation              -- Consolide par produit
ORDER BY idproduit;                          -- Trie par ID produit

EXPLAIN PLAN FOR
SELECT
    idproduit,
    designation,
    SUM(ca) AS cat
FROM (
    SELECT * FROM view1@site1_link
    UNION ALL
    SELECT * FROM view2
)
GROUP BY idproduit, designation;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);
