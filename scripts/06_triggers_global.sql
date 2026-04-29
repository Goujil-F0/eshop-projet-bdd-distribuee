-- ===================================================
-- 06_TRIGGERS_GLOBAL.SQL - Triggers de synchronisation
-- ===================================================

-- Active l'affichage des commandes SQL
SET ECHO ON;
-- Active les messages de feedback
SET FEEDBACK ON;

-- Se connecte à la base globale
CONNECT app_global/Eshop123@localhost:1523/FREEPDB1;

-- TRIGGER 1: Déclenché automatiquement AVANT chaque INSERT sur lignecommandes
-- Ce trigger synchronise les modifications vers les fragments des sites
CREATE OR REPLACE TRIGGER syc_insert_ligne
BEFORE INSERT ON lignecommandes      -- Déclencheur AVANT l'insertion
FOR EACH ROW                         -- Exécuté pour chaque nouvelle ligne
DECLARE
    cat categories.idcateg%TYPE;    -- Variable: catégorie du produit
    nq  lignecommandes.quantite%TYPE := :NEW.quantite; -- Nouvelle quantité
BEGIN
    -- Récupère la catégorie du produit inséré
    SELECT idcateg
    INTO cat
    FROM produits
    WHERE idproduit = :NEW.idproduit;  -- :NEW représente les valeurs insérées

    -- Teste si c'est un produit du fragment site1 (catégorie 50, quantité > 100)
    IF cat = 50 AND nq > 100 THEN
        -- Copie les données du client vers site1 (@site1_link = lien distribué)
        BEGIN
            INSERT INTO clients1@site1_link (idclient, codeclient, societe, ville, pays, telephone)
            SELECT c.idclient, c.codeclient, c.societe, c.ville, c.pays, c.telephone
            FROM clients c
            JOIN commandes co ON co.idclient = c.idclient
            WHERE co.idcommande = :NEW.idcommande;
        EXCEPTION
            -- Ignore si le client existe déjà sur le site (clé primaire dupliquée)
            WHEN DUP_VAL_ON_INDEX THEN NULL;
        END;

        -- Copie la commande vers site1
        BEGIN
            INSERT INTO commandes1@site1_link (idcommande, idemploye, idclient, datecommande, statut)
            SELECT idcommande, idemploye, idclient, datecommande, statut
            FROM commandes
            WHERE idcommande = :NEW.idcommande;
        EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN NULL;
        END;

        -- Copie le produit vers site1
        BEGIN
            INSERT INTO produits1@site1_link (idproduit, idcateg, designation, prixunitaire, stock)
            SELECT idproduit, idcateg, designation, prixunitaire, stock
            FROM produits
            WHERE idproduit = :NEW.idproduit;
        EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN NULL;
        END;

        -- Appelle la procédure INSERTligne du site1 pour insérer la ligne
        INSERTligne@site1_link(
            :NEW.idlignecommande,
            :NEW.idcommande,
            :NEW.idproduit,
            :NEW.quantite,
            :NEW.remise
        );
    -- Teste si c'est un produit du fragment site2 (catégorie 35, quantité > 50)
    ELSIF cat = 35 AND nq > 50 THEN
        BEGIN
            INSERT INTO clients2@site2_link (idclient, codeclient, societe, ville, pays, telephone)
            SELECT c.idclient, c.codeclient, c.societe, c.ville, c.pays, c.telephone
            FROM clients c
            JOIN commandes co ON co.idclient = c.idclient
            WHERE co.idcommande = :NEW.idcommande;
        EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN NULL;
        END;

        BEGIN
            INSERT INTO commandes2@site2_link (idcommande, idemploye, idclient, datecommande, statut)
            SELECT idcommande, idemploye, idclient, datecommande, statut
            FROM commandes
            WHERE idcommande = :NEW.idcommande;
        EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN NULL;
        END;

        BEGIN
            INSERT INTO produits2@site2_link (idproduit, idcateg, designation, prixunitaire, stock)
            SELECT idproduit, idcateg, designation, prixunitaire, stock
            FROM produits
            WHERE idproduit = :NEW.idproduit;
        EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN NULL;
        END;

        INSERTligne@site2_link(
            :NEW.idlignecommande,
            :NEW.idcommande,
            :NEW.idproduit,
            :NEW.quantite,
            :NEW.remise
        );
    END IF;
END;
/

CREATE OR REPLACE TRIGGER syc_delete_ligne
BEFORE DELETE ON lignecommandes
FOR EACH ROW
DECLARE
    cat categories.idcateg%TYPE;
    oq  lignecommandes.quantite%TYPE := :OLD.quantite;
BEGIN
    SELECT idcateg
    INTO cat
    FROM produits
    WHERE idproduit = :OLD.idproduit;

    IF cat = 50 AND oq > 100 THEN
        DELETEligne@site1_link(:OLD.idlignecommande);
    ELSIF cat = 35 AND oq > 50 THEN
        DELETEligne@site2_link(:OLD.idlignecommande);
    END IF;
END;
/

CREATE OR REPLACE TRIGGER syc_update_ligne
BEFORE UPDATE ON lignecommandes
FOR EACH ROW
DECLARE
    op    produits.idproduit%TYPE := :OLD.idproduit;
    np    produits.idproduit%TYPE := :NEW.idproduit;
    oq    lignecommandes.quantite%TYPE := :OLD.quantite;
    nq    lignecommandes.quantite%TYPE := :NEW.quantite;
    ocat  produits.idcateg%TYPE;
    ncat  produits.idcateg%TYPE;
BEGIN
    SELECT idcateg INTO ocat FROM produits WHERE idproduit = op;
    SELECT idcateg INTO ncat FROM produits WHERE idproduit = np;

    IF ocat = 50 AND oq > 100 THEN
        IF ncat = 50 AND nq > 100 THEN
            BEGIN
                INSERT INTO produits1@site1_link (idproduit, idcateg, designation, prixunitaire, stock)
                SELECT idproduit, idcateg, designation, prixunitaire, stock
                FROM produits
                WHERE idproduit = :NEW.idproduit;
            EXCEPTION
                WHEN DUP_VAL_ON_INDEX THEN NULL;
            END;

            updateligne@site1_link(
                :NEW.idlignecommande,
                :NEW.idproduit,
                :NEW.quantite,
                :NEW.remise
            );
        ELSE
            DELETEligne@site1_link(:OLD.idlignecommande);

            IF ncat = 35 AND nq > 50 THEN
                BEGIN
                    INSERT INTO clients2@site2_link (idclient, codeclient, societe, ville, pays, telephone)
                    SELECT c.idclient, c.codeclient, c.societe, c.ville, c.pays, c.telephone
                    FROM clients c
                    JOIN commandes co ON co.idclient = c.idclient
                    WHERE co.idcommande = :NEW.idcommande;
                EXCEPTION
                    WHEN DUP_VAL_ON_INDEX THEN NULL;
                END;

                BEGIN
                    INSERT INTO commandes2@site2_link (idcommande, idemploye, idclient, datecommande, statut)
                    SELECT idcommande, idemploye, idclient, datecommande, statut
                    FROM commandes
                    WHERE idcommande = :NEW.idcommande;
                EXCEPTION
                    WHEN DUP_VAL_ON_INDEX THEN NULL;
                END;

                BEGIN
                    INSERT INTO produits2@site2_link (idproduit, idcateg, designation, prixunitaire, stock)
                    SELECT idproduit, idcateg, designation, prixunitaire, stock
                    FROM produits
                    WHERE idproduit = :NEW.idproduit;
                EXCEPTION
                    WHEN DUP_VAL_ON_INDEX THEN NULL;
                END;

                INSERTligne@site2_link(
                    :NEW.idlignecommande,
                    :NEW.idcommande,
                    :NEW.idproduit,
                    :NEW.quantite,
                    :NEW.remise
                );
            END IF;
        END IF;
    ELSIF ocat = 35 AND oq > 50 THEN
        IF ncat = 35 AND nq > 50 THEN
            BEGIN
                INSERT INTO produits2@site2_link (idproduit, idcateg, designation, prixunitaire, stock)
                SELECT idproduit, idcateg, designation, prixunitaire, stock
                FROM produits
                WHERE idproduit = :NEW.idproduit;
            EXCEPTION
                WHEN DUP_VAL_ON_INDEX THEN NULL;
            END;

            updateligne@site2_link(
                :NEW.idlignecommande,
                :NEW.idproduit,
                :NEW.quantite,
                :NEW.remise
            );
        ELSE
            DELETEligne@site2_link(:OLD.idlignecommande);

            IF ncat = 50 AND nq > 100 THEN
                BEGIN
                    INSERT INTO clients1@site1_link (idclient, codeclient, societe, ville, pays, telephone)
                    SELECT c.idclient, c.codeclient, c.societe, c.ville, c.pays, c.telephone
                    FROM clients c
                    JOIN commandes co ON co.idclient = c.idclient
                    WHERE co.idcommande = :NEW.idcommande;
                EXCEPTION
                    WHEN DUP_VAL_ON_INDEX THEN NULL;
                END;

                BEGIN
                    INSERT INTO commandes1@site1_link (idcommande, idemploye, idclient, datecommande, statut)
                    SELECT idcommande, idemploye, idclient, datecommande, statut
                    FROM commandes
                    WHERE idcommande = :NEW.idcommande;
                EXCEPTION
                    WHEN DUP_VAL_ON_INDEX THEN NULL;
                END;

                BEGIN
                    INSERT INTO produits1@site1_link (idproduit, idcateg, designation, prixunitaire, stock)
                    SELECT idproduit, idcateg, designation, prixunitaire, stock
                    FROM produits
                    WHERE idproduit = :NEW.idproduit;
                EXCEPTION
                    WHEN DUP_VAL_ON_INDEX THEN NULL;
                END;

                INSERTligne@site1_link(
                    :NEW.idlignecommande,
                    :NEW.idcommande,
                    :NEW.idproduit,
                    :NEW.quantite,
                    :NEW.remise
                );
            END IF;
        END IF;
    ELSIF ncat = 50 AND nq > 100 THEN
        BEGIN
            INSERT INTO clients1@site1_link (idclient, codeclient, societe, ville, pays, telephone)
            SELECT c.idclient, c.codeclient, c.societe, c.ville, c.pays, c.telephone
            FROM clients c
            JOIN commandes co ON co.idclient = c.idclient
            WHERE co.idcommande = :NEW.idcommande;
        EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN NULL;
        END;

        BEGIN
            INSERT INTO commandes1@site1_link (idcommande, idemploye, idclient, datecommande, statut)
            SELECT idcommande, idemploye, idclient, datecommande, statut
            FROM commandes
            WHERE idcommande = :NEW.idcommande;
        EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN NULL;
        END;

        BEGIN
            INSERT INTO produits1@site1_link (idproduit, idcateg, designation, prixunitaire, stock)
            SELECT idproduit, idcateg, designation, prixunitaire, stock
            FROM produits
            WHERE idproduit = :NEW.idproduit;
        EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN NULL;
        END;

        INSERTligne@site1_link(
            :NEW.idlignecommande,
            :NEW.idcommande,
            :NEW.idproduit,
            :NEW.quantite,
            :NEW.remise
        );
    ELSIF ncat = 35 AND nq > 50 THEN
        BEGIN
            INSERT INTO clients2@site2_link (idclient, codeclient, societe, ville, pays, telephone)
            SELECT c.idclient, c.codeclient, c.societe, c.ville, c.pays, c.telephone
            FROM clients c
            JOIN commandes co ON co.idclient = c.idclient
            WHERE co.idcommande = :NEW.idcommande;
        EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN NULL;
        END;

        BEGIN
            INSERT INTO commandes2@site2_link (idcommande, idemploye, idclient, datecommande, statut)
            SELECT idcommande, idemploye, idclient, datecommande, statut
            FROM commandes
            WHERE idcommande = :NEW.idcommande;
        EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN NULL;
        END;

        BEGIN
            INSERT INTO produits2@site2_link (idproduit, idcateg, designation, prixunitaire, stock)
            SELECT idproduit, idcateg, designation, prixunitaire, stock
            FROM produits
            WHERE idproduit = :NEW.idproduit;
        EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN NULL;
        END;

        INSERTligne@site2_link(
            :NEW.idlignecommande,
            :NEW.idcommande,
            :NEW.idproduit,
            :NEW.quantite,
            :NEW.remise
        );
    END IF;
END;
/
