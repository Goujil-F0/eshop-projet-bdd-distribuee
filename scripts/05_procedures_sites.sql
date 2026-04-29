-- ===================================================
-- 05_PROCEDURES_SITES.SQL - Procedures de fragments
-- ===================================================
-- Procedures demandees par le scenario :
--   INSERTligne
--   DELETEligne
--   updateligne

-- Active l'affichage des commandes SQL
SET ECHO ON;
-- Active les messages de feedback
SET FEEDBACK ON;

-- Section 1: Création des procédures du site 1
PROMPT ===== Procedures du site 1 =====
-- Se connecte au site 1
CONNECT app_site1/Eshop123@localhost:1524/FREEPDB1;

-- Procédure d'insertion de ligne de commande
-- Paramètres: a=id_ligne, b=id_commande, c=id_produit, d=quantite, e=remise
CREATE OR REPLACE PROCEDURE INSERTligne (
    a IN lignecommandes1.idlignecommande%TYPE,  -- ID unique de la ligne
    b IN lignecommandes1.idcommande%TYPE,       -- ID de la commande parent
    c IN lignecommandes1.idproduit%TYPE,        -- ID du produit commandé
    d IN lignecommandes1.quantite%TYPE,         -- Quantité commandée
    e IN lignecommandes1.remise%TYPE            -- Remise appliquée
)
IS
    -- Variables locales pour compter les enregistrements
    nc   INTEGER;  -- Nombre de commandes trouvées
    np   INTEGER;  -- Nombre de produits trouvés
BEGIN
    -- Vérifie que la commande existe dans le fragment
    SELECT COUNT(*) INTO nc
    FROM commandes1
    WHERE idcommande = b;

    -- Si aucune commande trouvée, lève une exception
    IF nc = 0 THEN
        -- Code erreur personnalisé -20001 + message explicite
        RAISE_APPLICATION_ERROR(-20001, 'Commande inexistante dans le fragment site1.');
    END IF;

    -- Vérifie que le produit existe dans le fragment
    SELECT COUNT(*) INTO np
    FROM produits1
    WHERE idproduit = c;

    -- Si aucun produit trouvé, lève une exception
    IF np = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Produit inexistant dans le fragment site1.');
    END IF;

    -- Si les validations passent, insère la ligne
    INSERT INTO lignecommandes1 (idlignecommande, idcommande, idproduit, quantite, remise)
    VALUES (a, b, c, d, e);
END;
/

-- Procédure de suppression de ligne avec nettoyage des données orphelines
-- Paramétre: a=id_ligne à supprimer
CREATE OR REPLACE PROCEDURE DELETEligne (
    a IN lignecommandes1.idlignecommande%TYPE
)
IS
    nc   INTEGER;              -- Nombre de lignes restantes pour une commande
    ncl  INTEGER;              -- Nombre de commandes restantes pour un client
    np   INTEGER;              -- Nombre de lignes pour un produit
    idc  commandes1.idcommande%TYPE;  -- ID de la commande à nettoyer
    idp  produits1.idproduit%TYPE;    -- ID du produit à nettoyer
    idcl clients1.idclient%TYPE;      -- ID du client à nettoyer
BEGIN
    -- Récupére les IDs de la commande et du produit associés à cette ligne
    SELECT idcommande, idproduit
    INTO idc, idp
    FROM lignecommandes1
    WHERE idlignecommande = a;

    -- Supprime la ligne
    DELETE FROM lignecommandes1
    WHERE idlignecommande = a;

    -- Vérifie s'il reste d'autres lignes pour cette commande
    SELECT COUNT(*) INTO nc
    FROM lignecommandes1
    WHERE idcommande = idc;

    -- Si la commande n'a plus de lignes, la supprime aussi
    IF nc = 0 THEN
        SELECT idclient
        INTO idcl
        FROM commandes1
        WHERE idcommande = idc;

        DELETE FROM commandes1
        WHERE idcommande = idc;

        -- Vérifie s'il reste d'autres commandes pour ce client
        SELECT COUNT(*) INTO ncl
        FROM commandes1
        WHERE idclient = idcl;

        -- Si le client n'a plus de commandes, le supprime aussi
        IF ncl = 0 THEN
            DELETE FROM clients1
            WHERE idclient = idcl;
        END IF;
    END IF;

    -- Vérifie s'il reste d'autres lignes pour ce produit
    SELECT COUNT(*) INTO np
    FROM lignecommandes1
    WHERE idproduit = idp;

    -- Si le produit n'est plus référencé, le supprime aussi
    IF np = 0 THEN
        DELETE FROM produits1
        WHERE idproduit = idp;
    END IF;
END;
/

-- Procédure de mise à jour de ligne de commande
-- Paramétres: a=id_ligne, b=nouveau_id_produit, c=nouvelle_quantite, d=nouvelle_remise
CREATE OR REPLACE PROCEDURE updateligne (
    a IN lignecommandes1.idlignecommande%TYPE,
    b IN lignecommandes1.idproduit%TYPE,
    c IN lignecommandes1.quantite%TYPE,
    d IN lignecommandes1.remise%TYPE
)
IS
    n   INTEGER;              -- Compteur pour vérifier l'existence du produit
    x   produits1.idproduit%TYPE;  -- Ancien ID produit pour nettoyage
BEGIN
    -- Récupére l'ancien ID produit pour vérification ultérieure
    SELECT idproduit
    INTO x
    FROM lignecommandes1
    WHERE idlignecommande = a;

    -- Vérifie que le nouveau produit existe dans le fragment
    SELECT COUNT(*) INTO n
    FROM produits1
    WHERE idproduit = b;

    IF n = 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Nouveau produit absent du fragment site1.');
    END IF;

    -- Met à jour la ligne avec le nouveau produit, quantité et remise
    UPDATE lignecommandes1
    SET idproduit = b,
        quantite = c,
        remise = d
    WHERE idlignecommande = a;

    -- Vérifie s'il reste des lignes pour l'ancien produit
    SELECT COUNT(*) INTO n
    FROM lignecommandes1
    WHERE idproduit = x;

    -- Si l'ancien produit n'est plus référencé, le supprime (nettoyage)
    IF n = 0 THEN
        DELETE FROM produits1
        WHERE idproduit = x;
    END IF;
END;
/

PROMPT ===== Procedures du site 2 =====
CONNECT app_site2/Eshop123@localhost:1525/FREEPDB1;

CREATE OR REPLACE PROCEDURE INSERTligne (
    a IN lignecommandes2.idlignecommande%TYPE,
    b IN lignecommandes2.idcommande%TYPE,
    c IN lignecommandes2.idproduit%TYPE,
    d IN lignecommandes2.quantite%TYPE,
    e IN lignecommandes2.remise%TYPE
)
IS
    nc   INTEGER;
    np   INTEGER;
BEGIN
    SELECT COUNT(*) INTO nc
    FROM commandes2
    WHERE idcommande = b;

    IF nc = 0 THEN
        RAISE_APPLICATION_ERROR(-20011, 'Commande inexistante dans le fragment site2.');
    END IF;

    SELECT COUNT(*) INTO np
    FROM produits2
    WHERE idproduit = c;

    IF np = 0 THEN
        RAISE_APPLICATION_ERROR(-20012, 'Produit inexistant dans le fragment site2.');
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
    SELECT idcommande, idproduit
    INTO idc, idp
    FROM lignecommandes2
    WHERE idlignecommande = a;

    DELETE FROM lignecommandes2
    WHERE idlignecommande = a;

    SELECT COUNT(*) INTO nc
    FROM lignecommandes2
    WHERE idcommande = idc;

    IF nc = 0 THEN
        SELECT idclient
        INTO idcl
        FROM commandes2
        WHERE idcommande = idc;

        DELETE FROM commandes2
        WHERE idcommande = idc;

        SELECT COUNT(*) INTO ncl
        FROM commandes2
        WHERE idclient = idcl;

        IF ncl = 0 THEN
            DELETE FROM clients2
            WHERE idclient = idcl;
        END IF;
    END IF;

    SELECT COUNT(*) INTO np
    FROM lignecommandes2
    WHERE idproduit = idp;

    IF np = 0 THEN
        DELETE FROM produits2
        WHERE idproduit = idp;
    END IF;
END;
/

CREATE OR REPLACE PROCEDURE updateligne (
    a IN lignecommandes2.idlignecommande%TYPE,
    b IN lignecommandes2.idproduit%TYPE,
    c IN lignecommandes2.quantite%TYPE,
    d IN lignecommandes2.remise%TYPE
)
IS
    n   INTEGER;
    x   produits2.idproduit%TYPE;
BEGIN
    SELECT idproduit
    INTO x
    FROM lignecommandes2
    WHERE idlignecommande = a;

    SELECT COUNT(*) INTO n
    FROM produits2
    WHERE idproduit = b;

    IF n = 0 THEN
        RAISE_APPLICATION_ERROR(-20013, 'Nouveau produit absent du fragment site2.');
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
        DELETE FROM produits2
        WHERE idproduit = x;
    END IF;
END;
/
