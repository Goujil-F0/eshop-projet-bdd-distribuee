-- ===================================================
-- 16_PERF_COMPARISON.SQL - Analyse de Performance
-- ===================================================
SET ECHO ON;
SET FEEDBACK ON;
SET PAGESIZE 100;
SET LINESIZE 200;

-- Se connecte à la base globale
CONNECT app_global/Eshop123@localhost:1523/FREEPDB1;

PROMPT ==========================================================
PROMPT ANALYSE DE PERFORMANCE : AVANT vs APRES INDEXATION
PROMPT ==========================================================

-- ----------------------------------------------------------
-- ETAPE 1 : Simulation d'une base NON optimisée
-- ----------------------------------------------------------
PROMPT [1/4] Nettoyage des index pour le test...
BEGIN 
    EXECUTE IMMEDIATE 'DROP INDEX idx_commandes_date_client'; 
EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN 
    EXECUTE IMMEDIATE 'DROP INDEX idx_produits_categ_prod'; 
EXCEPTION WHEN OTHERS THEN NULL; END;
/

-- On force la mise à jour des statistiques pour que l'optimiseur soit à jour
EXEC DBMS_STATS.GATHER_SCHEMA_STATS('APP_GLOBAL');

PROMPT [2/4] Generation du plan d'execution SANS index...

-- Requête analytique : CA par client pour la catégorie 10 en 2020
EXPLAIN PLAN FOR
SELECT 
    c.societe, 
    SUM(p.prixunitaire * lc.quantite) as ca
FROM clients c
JOIN commandes co ON c.idclient = co.idclient
JOIN lignecommandes lc ON co.idcommande = lc.idcommande
JOIN produits p ON lc.idproduit = p.idproduit
WHERE p.idcateg = 10 
  AND co.datecommande >= DATE '2020-01-01' 
  AND co.datecommande < DATE '2021-01-01'
GROUP BY c.societe;

PROMPT --- PLAN D'EXECUTION (SANS INDEX) ---
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- ----------------------------------------------------------
-- ETAPE 2 : Application de la stratégie d'indexation
-- ----------------------------------------------------------
PROMPT [3/4] Application des index d'optimisation...

-- Index sur la date pour filtrer rapidement les commandes
CREATE INDEX idx_perf_date ON commandes(datecommande);
-- Index sur la catégorie pour filtrer rapidement les produits
CREATE INDEX idx_perf_cat ON produits(idcateg);
-- Index sur la jointure ligne-produit
CREATE INDEX idx_perf_lc_prod ON lignecommandes(idproduit);

-- On remet à jour les statistiques
EXEC DBMS_STATS.GATHER_SCHEMA_STATS('APP_GLOBAL');

-- ----------------------------------------------------------
-- ETAPE 3 : Comparaison finale
-- ----------------------------------------------------------
PROMPT [4/4] Generation du plan d'execution AVEC index...

EXPLAIN PLAN FOR
SELECT 
    c.societe, 
    SUM(p.prixunitaire * lc.quantite) as ca
FROM clients c
JOIN commandes co ON c.idclient = co.idclient
JOIN lignecommandes lc ON co.idcommande = lc.idcommande
JOIN produits p ON lc.idproduit = p.idproduit
WHERE p.idcateg = 10 
  AND co.datecommande >= DATE '2020-01-01' 
  AND co.datecommande < DATE '2021-01-01'
GROUP BY c.societe;

PROMPT --- PLAN D'EXECUTION (AVEC INDEX) ---
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

PROMPT ==========================================================
PROMPT ANALYSE TERMINEE
PROMPT Note : Comparez la colonne "Cost" et les "Operation" 
PROMPT (Cherchez le passage de 'TABLE ACCESS FULL' a 'INDEX RANGE SCAN')
PROMPT ==========================================================