-- ===================================================
-- 11_SCENARIO2_PROCEDURES_SITES.SQL
-- Procedures locales du scenario 2
-- ===================================================

SET ECHO ON;
SET FEEDBACK ON;

PROMPT ===== SCENARIO 2 - PROCEDURES SITE 1 =====
CONNECT app_site1/Eshop123@localhost:1524/FREEPDB1;

CREATE OR REPLACE PROCEDURE INSERTligne (
    a IN lignecommandes1.idlignecommande%TYPE,
    b IN lignecommandes1.idcommande%TYPE,
    c IN lignecommandes1.idproduit%TYPE,
    d IN lignecommandes1.quantite%TYPE,
    e IN lignecommandes1.remise%TYPE
)
IS
    nc INTEGER;
    np INTEGER;
BEGIN
    SELECT COUNT(*) INTO nc FROM commandes1 WHERE idcommande = b;
    IF nc = 0 THEN
        RAISE_APPLICATION_ERROR(-20101, 'Commande absente du fragment site1.');
    END IF;

    SELECT COUNT(*) INTO np FROM produits1 WHERE idproduit = c;
    IF np = 0 THEN
        RAISE_APPLICATION_ERROR(-20102, 'Produit absent du fragment site1.');
    END IF;

    INSERT INTO lignecommandes1 (idlignecommande, idcommande, idproduit, quantite, remise)
    VALUES (a, b, c, d, e);
END;
/

CREATE OR REPLACE PROCEDURE DELETEligne (
    a IN lignecommandes1.idlignecommande%TYPE
)
IS
    nc   INTEGER;
    ncl  INTEGER;
    np   INTEGER;
    idc  commandes1.idcommande%TYPE;
    idp  produits1.idproduit%TYPE;
    idcl clients1.idclient%TYPE;
BEGIN
    SELECT idcommande, idproduit INTO idc, idp
    FROM lignecommandes1
    WHERE idlignecommande = a;

    DELETE FROM lignecommandes1 WHERE idlignecommande = a;

    SELECT COUNT(*) INTO nc FROM lignecommandes1 WHERE idcommande = idc;
    IF nc = 0 THEN
        SELECT idclient INTO idcl FROM commandes1 WHERE idcommande = idc;
        DELETE FROM commandes1 WHERE idcommande = idc;

        SELECT COUNT(*) INTO ncl FROM commandes1 WHERE idclient = idcl;
        IF ncl = 0 THEN
            DELETE FROM clients1 WHERE idclient = idcl;
        END IF;
    END IF;

    SELECT COUNT(*) INTO np FROM lignecommandes1 WHERE idproduit = idp;
    IF np = 0 THEN
        DELETE FROM produits1 WHERE idproduit = idp;
    END IF;
END;
/

CREATE OR REPLACE PROCEDURE updateligne (
    a IN NUMBER,
    b IN NUMBER,
    c IN NUMBER,
    d IN NUMBER
)
IS
    n INTEGER;
    x NUMBER;
BEGIN
    SELECT idproduit INTO x
    FROM lignecommandes1
    WHERE idlignecommande = a;

    SELECT COUNT(*) INTO n
    FROM produits1
    WHERE idproduit = b;

    IF n = 0 THEN
        RAISE_APPLICATION_ERROR(-20103, 'Nouveau produit absent du fragment site1.');
    END IF;

    UPDATE lignecommandes1
    SET idproduit = b,
        quantite = c,
        remise = d
    WHERE idlignecommande = a;

    SELECT COUNT(*) INTO n
    FROM lignecommandes1
    WHERE idproduit = x;

    IF n = 0 THEN
        DELETE FROM produits1 WHERE idproduit = x;
    END IF;
END;
/

PROMPT ===== SCENARIO 2 - PROCEDURES SITE 2 =====
CONNECT app_site2/Eshop123@localhost:1525/FREEPDB1;

CREATE OR REPLACE PROCEDURE INSERTligne (
    a IN lignecommandes2.idlignecommande%TYPE,
    b IN lignecommandes2.idcommande%TYPE,
    c IN lignecommandes2.idproduit%TYPE,
    d IN lignecommandes2.quantite%TYPE,
    e IN lignecommandes2.remise%TYPE
)
IS
    nc INTEGER;
    np INTEGER;
BEGIN
    SELECT COUNT(*) INTO nc FROM commandes2 WHERE idcommande = b;
    IF nc = 0 THEN
        RAISE_APPLICATION_ERROR(-20111, 'Commande absente du fragment site2.');
    END IF;

    SELECT COUNT(*) INTO np FROM produits2 WHERE idproduit = c;
    IF np = 0 THEN
        RAISE_APPLICATION_ERROR(-20112, 'Produit absent du fragment site2.');
    END IF;

    INSERT INTO lignecommandes2 (idlignecommande, idcommande, idproduit, quantite, remise)
    VALUES (a, b, c, d, e);
END;
/

CREATE OR REPLACE PROCEDURE DELETEligne (
    a IN lignecommandes2.idlignecommande%TYPE
)
IS
    nc   INTEGER;
    ncl  INTEGER;
    np   INTEGER;
    idc  commandes2.idcommande%TYPE;
    idp  produits2.idproduit%TYPE;
    idcl clients2.idclient%TYPE;
BEGIN
    SELECT idcommande, idproduit INTO idc, idp
    FROM lignecommandes2
    WHERE idlignecommande = a;

    DELETE FROM lignecommandes2 WHERE idlignecommande = a;

    SELECT COUNT(*) INTO nc FROM lignecommandes2 WHERE idcommande = idc;
    IF nc = 0 THEN
        SELECT idclient INTO idcl FROM commandes2 WHERE idcommande = idc;
        DELETE FROM commandes2 WHERE idcommande = idc;

        SELECT COUNT(*) INTO ncl FROM commandes2 WHERE idclient = idcl;
        IF ncl = 0 THEN
            DELETE FROM clients2 WHERE idclient = idcl;
        END IF;
    END IF;

    SELECT COUNT(*) INTO np FROM lignecommandes2 WHERE idproduit = idp;
    IF np = 0 THEN
        DELETE FROM produits2 WHERE idproduit = idp;
    END IF;
END;
/

CREATE OR REPLACE PROCEDURE updateligne (
    a IN NUMBER,
    b IN NUMBER,
    c IN NUMBER,
    d IN NUMBER
)
IS
    n INTEGER;
    x NUMBER;
BEGIN
    SELECT idproduit INTO x
    FROM lignecommandes2
    WHERE idlignecommande = a;

    SELECT COUNT(*) INTO n
    FROM produits2
    WHERE idproduit = b;

    IF n = 0 THEN
        RAISE_APPLICATION_ERROR(-20113, 'Nouveau produit absent du fragment site2.');
    END IF;

    UPDATE lignecommandes2
    SET idproduit = b,
        quantite = c,
        remise = d
    WHERE idlignecommande = a;

    SELECT COUNT(*) INTO n
    FROM lignecommandes2
    WHERE idproduit = x;

    IF n = 0 THEN
        DELETE FROM produits2 WHERE idproduit = x;
    END IF;
END;
/
