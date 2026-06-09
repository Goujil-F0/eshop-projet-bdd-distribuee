-- ===================================================
-- 14_DEMO_REPLICATION.SQL - Demonstration en direct
-- ===================================================
SET ECHO ON;
SET FEEDBACK ON;
SET PAGESIZE 100;

-- Se connecte à la base globale
CONNECT app_global/Eshop123@localhost:1523/FREEPDB1;

PROMPT ----------------------------------------------------------
PROMPT TEST 1 : INSERTION AUTOMATIQUE
PROMPT ----------------------------------------------------------
-- On insère une ligne avec quantité = 150 (doit aller sur SITE 1)
INSERT INTO lignecommandes (idlignecommande, idcommande, idproduit, quantite, remise) 
VALUES (99901, 101, 5001, 150, 0);
COMMIT;

PROMPT Verification sur SITE 1 :
SELECT * FROM lignecommandes1@site1_link WHERE idlignecommande = 99901;

PROMPT Verification sur SITE 2 (doit être vide) :
SELECT * FROM lignecommandes2@site2_link WHERE idlignecommande = 99901;


PROMPT ----------------------------------------------------------
PROMPT TEST 2 : MIGRATION ENTRE SITES (UPDATE)
PROMPT ----------------------------------------------------------
-- On change la quantité de 150 à 50 (doit migrer de SITE 1 vers SITE 2)
UPDATE lignecommandes 
SET quantite = 50 
WHERE idlignecommande = 99901;
COMMIT;

PROMPT Verification sur SITE 1 (doit avoir disparu) :
SELECT * FROM lignecommandes1@site1_link WHERE idlignecommande = 99901;

PROMPT Verification sur SITE 2 (doit être apparu) :
SELECT * FROM lignecommandes2@site2_link WHERE idlignecommande = 99901;


PROMPT ----------------------------------------------------------
PROMPT TEST 3 : SUPPRESSION PROPAGÉE
PROMPT ----------------------------------------------------------
-- On supprime la ligne du Global
DELETE FROM lignecommandes WHERE idlignecommande = 99901;
COMMIT;

PROMPT Verification sur SITE 2 (doit avoir disparu) :
SELECT * FROM lignecommandes2@site2_link WHERE idlignecommande = 99901;

PROMPT ----------------------------------------------------------
PROMPT DEMONSTRATION TERMINEE AVEC SUCCES
PROMPT ----------------------------------------------------------