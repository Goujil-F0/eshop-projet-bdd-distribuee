-- ===================================================
-- 12_SCENARIO2_TRIGGERS_GLOBAL.SQL
-- Routage par volume de vente
-- Site1 : Quantite >= 100
-- Site2 : Quantite < 100
-- ===================================================

SET ECHO ON;
SET FEEDBACK ON;

CONNECT app_global/Eshop123@localhost:1523/FREEPDB1;

CREATE OR REPLACE TRIGGER syc_insert_ligne
BEFORE INSERT ON lignecommandes
FOR EACH ROW
BEGIN
    IF :NEW.quantite >= 100 THEN
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
            INSERT INTO produits1@site1_link (idproduit, idcateg, designation, prixunitaire)
            SELECT idproduit, idcateg, designation, prixunitaire
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
    ELSE
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
            INSERT INTO produits2@site2_link (idproduit, idcateg, designation, prixunitaire)
            SELECT idproduit, idcateg, designation, prixunitaire
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
BEGIN
    IF :OLD.quantite >= 100 THEN
        DELETEligne@site1_link(:OLD.idlignecommande);
    ELSE
        DELETEligne@site2_link(:OLD.idlignecommande);
    END IF;
END;
/

CREATE OR REPLACE TRIGGER syc_update_ligne
BEFORE UPDATE ON lignecommandes
FOR EACH ROW
BEGIN
    IF :OLD.quantite >= 100 AND :NEW.quantite >= 100 THEN
        BEGIN
            INSERT INTO produits1@site1_link (idproduit, idcateg, designation, prixunitaire)
            SELECT idproduit, idcateg, designation, prixunitaire
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
    ELSIF :OLD.quantite < 100 AND :NEW.quantite < 100 THEN
        BEGIN
            INSERT INTO produits2@site2_link (idproduit, idcateg, designation, prixunitaire)
            SELECT idproduit, idcateg, designation, prixunitaire
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
    ELSIF :OLD.quantite >= 100 AND :NEW.quantite < 100 THEN
        DELETEligne@site1_link(:OLD.idlignecommande);

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
            INSERT INTO produits2@site2_link (idproduit, idcateg, designation, prixunitaire)
            SELECT idproduit, idcateg, designation, prixunitaire
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
    ELSE
        DELETEligne@site2_link(:OLD.idlignecommande);

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
            INSERT INTO produits1@site1_link (idproduit, idcateg, designation, prixunitaire)
            SELECT idproduit, idcateg, designation, prixunitaire
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
END;
/
