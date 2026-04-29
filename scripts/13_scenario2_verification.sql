-- ===================================================
-- 13_SCENARIO2_VERIFICATION.SQL
-- Synchronisation et verification du scenario 2
-- ===================================================

SET ECHO ON;
SET FEEDBACK ON;
SET PAGESIZE 100;

PROMPT ===== NETTOYAGE SITE 1 =====
CONNECT app_site1/Eshop123@localhost:1524/FREEPDB1;

DELETE FROM lignecommandes1;
DELETE FROM commandes1;
DELETE FROM produits1;
DELETE FROM clients1;
COMMIT;

PROMPT ===== NETTOYAGE SITE 2 =====
CONNECT app_site2/Eshop123@localhost:1525/FREEPDB1;

DELETE FROM lignecommandes2;
DELETE FROM commandes2;
DELETE FROM produits2;
DELETE FROM clients2;
COMMIT;

PROMPT ===== SYNCHRONISATION DEPUIS LA BASE GLOBALE =====
CONNECT app_global/Eshop123@localhost:1523/FREEPDB1;

INSERT INTO clients1@site1_link (idclient, codeclient, societe, ville, pays, telephone)
SELECT DISTINCT c.idclient, c.codeclient, c.societe, c.ville, c.pays, c.telephone
FROM clients c
JOIN commandes co ON co.idclient = c.idclient
JOIN lignecommandes lc ON lc.idcommande = co.idcommande
WHERE lc.quantite >= 100;

INSERT INTO commandes1@site1_link (idcommande, idemploye, idclient, datecommande, statut)
SELECT DISTINCT co.idcommande, co.idemploye, co.idclient, co.datecommande, co.statut
FROM commandes co
JOIN lignecommandes lc ON lc.idcommande = co.idcommande
WHERE lc.quantite >= 100;

INSERT INTO produits1@site1_link (idproduit, idcateg, designation, prixunitaire)
SELECT DISTINCT p.idproduit, p.idcateg, p.designation, p.prixunitaire
FROM produits p
JOIN lignecommandes lc ON lc.idproduit = p.idproduit
WHERE lc.quantite >= 100;

INSERT INTO lignecommandes1@site1_link (idlignecommande, idcommande, idproduit, quantite, remise)
SELECT idlignecommande, idcommande, idproduit, quantite, remise
FROM lignecommandes
WHERE quantite >= 100;

INSERT INTO clients2@site2_link (idclient, codeclient, societe, ville, pays, telephone)
SELECT DISTINCT c.idclient, c.codeclient, c.societe, c.ville, c.pays, c.telephone
FROM clients c
JOIN commandes co ON co.idclient = c.idclient
JOIN lignecommandes lc ON lc.idcommande = co.idcommande
WHERE lc.quantite < 100;

INSERT INTO commandes2@site2_link (idcommande, idemploye, idclient, datecommande, statut)
SELECT DISTINCT co.idcommande, co.idemploye, co.idclient, co.datecommande, co.statut
FROM commandes co
JOIN lignecommandes lc ON lc.idcommande = co.idcommande
WHERE lc.quantite < 100;

INSERT INTO produits2@site2_link (idproduit, idcateg, designation, prixunitaire)
SELECT DISTINCT p.idproduit, p.idcateg, p.designation, p.prixunitaire
FROM produits p
JOIN lignecommandes lc ON lc.idproduit = p.idproduit
WHERE lc.quantite < 100;

INSERT INTO lignecommandes2@site2_link (idlignecommande, idcommande, idproduit, quantite, remise)
SELECT idlignecommande, idcommande, idproduit, quantite, remise
FROM lignecommandes
WHERE quantite < 100;

COMMIT;

PROMPT ===== VERIFICATION SITE 1 =====
CONNECT app_site1/Eshop123@localhost:1524/FREEPDB1;

SELECT COUNT(*) AS nb_lignes_gros
FROM lignecommandes1;

SELECT MIN(quantite) AS min_qte_site1,
       MAX(quantite) AS max_qte_site1
FROM lignecommandes1;

PROMPT ===== VERIFICATION SITE 2 =====
CONNECT app_site2/Eshop123@localhost:1525/FREEPDB1;

SELECT COUNT(*) AS nb_lignes_detail
FROM lignecommandes2;

SELECT MIN(quantite) AS min_qte_site2,
       MAX(quantite) AS max_qte_site2
FROM lignecommandes2;

PROMPT ===== REPARTITION GLOBALE =====
CONNECT app_global/Eshop123@localhost:1523/FREEPDB1;

SELECT
    CASE
        WHEN quantite >= 100 THEN 'SITE1_GROS'
        ELSE 'SITE2_DETAIL'
    END AS fragment_cible,
    COUNT(*) AS nb_lignes,
    ROUND(SUM(quantite * (1 - remise / 100)), 2) AS volume_pondere
FROM lignecommandes
GROUP BY CASE
    WHEN quantite >= 100 THEN 'SITE1_GROS'
    ELSE 'SITE2_DETAIL'
END
ORDER BY fragment_cible;
