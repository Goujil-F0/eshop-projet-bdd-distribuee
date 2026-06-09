-- ===================================================
-- 03_TABLES_SITES.SQL - Fragments des sites
-- ===================================================
-- Site1 implemente R1 : idcateg = 50 AND quantite > 100
-- Site2 implemente R2 : idcateg = 35 AND quantite > 50

-- Active l'affichage des commandes SQL
SET ECHO ON;
-- Active les messages de feedback
SET FEEDBACK ON;

-- Affiche un message dans la console
PROMPT ===== SITE 1 =====
-- Se connecte au site 1 (port 1524)
CONNECT app_site1/Eshop123@localhost:1524/FREEPDB1;

BEGIN EXECUTE IMMEDIATE 'DROP TABLE lignecommandes1 CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE commandes1 CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE clients1 CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE produits1 CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

-- Table PRODUITS1: Fragment des produits de catégorie 50 (Machines) pour site1
CREATE TABLE produits1 (
    idproduit     NUMBER PRIMARY KEY,         -- ID produit (identique au catalogue global)
    idcateg       NUMBER NOT NULL,            -- Catégorie (doit être 50 pour ce fragment)
    designation   VARCHAR2(200) NOT NULL,    -- Description du produit
    prixunitaire  NUMBER(10,2) NOT NULL,     -- Prix unitaire
    stock         NUMBER DEFAULT 0           -- Stock disponible sur le site
);

CREATE TABLE clients1 (
    idclient     NUMBER PRIMARY KEY,
    codeclient   VARCHAR2(20) NOT NULL UNIQUE,
    societe      VARCHAR2(150) NOT NULL,
    ville        VARCHAR2(100),
    pays         VARCHAR2(100),
    telephone    VARCHAR2(30)
);

CREATE TABLE commandes1 (
    idcommande      NUMBER PRIMARY KEY,
    idemploye       NUMBER,
    idclient        NUMBER NOT NULL,
    datecommande    DATE NOT NULL,
    statut          VARCHAR2(30),
    CONSTRAINT fk_commandes1_clients1
        FOREIGN KEY (idclient) REFERENCES clients1(idclient)
);

-- Table LIGNECOMMANDES1: Lignes de commandes fragmentées (R1: idcateg=50 et quantite>100)
CREATE TABLE lignecommandes1 (
    idlignecommande  NUMBER PRIMARY KEY,     -- ID de la ligne (identique au global)
    idcommande       NUMBER NOT NULL,        -- Référence à la commande
    idproduit        NUMBER NOT NULL,        -- Produit du fragment
    quantite         NUMBER NOT NULL,        -- Quantité (doit être > 100 pour R1)
    remise           NUMBER(5,2) DEFAULT 0, -- Remise appliquée
    -- Clé étrangère avec suppression en cascade:
    -- Si commande est supprimée, ses lignes le sont aussi
    CONSTRAINT fk_ligne1_commandes1
        FOREIGN KEY (idcommande) REFERENCES commandes1(idcommande) ON DELETE CASCADE,
    CONSTRAINT fk_ligne1_produits1
        FOREIGN KEY (idproduit) REFERENCES produits1(idproduit) ON DELETE CASCADE
);

-- Index 1: Accélére le filtrage par catégorie et produit
CREATE INDEX idx_produits1_categ ON produits1(idcateg, idproduit);
-- Index 2: Optimise les jointures produit-ligne par id produit et filtrage quantité
CREATE INDEX idx_lignecommandes1_prod_qte ON lignecommandes1(idproduit, quantite);
-- Index 3: Accélére la recherche par client et date de commande
CREATE INDEX idx_commandes1_client_date ON commandes1(idclient, datecommande);

-- Valide toutes les tables et index du site 1
COMMIT;

-- Affiche un message de séparation
PROMPT ===== SITE 2 =====
-- Se connecte au site 2 (port 1525)
CONNECT app_site2/Eshop123@localhost:1525/FREEPDB1;

BEGIN EXECUTE IMMEDIATE 'DROP TABLE lignecommandes2 CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE commandes2 CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE clients2 CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE produits2 CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

CREATE TABLE produits2 (
    idproduit     NUMBER PRIMARY KEY,
    idcateg       NUMBER NOT NULL,
    designation   VARCHAR2(200) NOT NULL,
    prixunitaire  NUMBER(10,2) NOT NULL,
    stock         NUMBER DEFAULT 0
);

CREATE TABLE clients2 (
    idclient     NUMBER PRIMARY KEY,
    codeclient   VARCHAR2(20) NOT NULL UNIQUE,
    societe      VARCHAR2(150) NOT NULL,
    ville        VARCHAR2(100),
    pays         VARCHAR2(100),
    telephone    VARCHAR2(30)
);

CREATE TABLE commandes2 (
    idcommande      NUMBER PRIMARY KEY,
    idemploye       NUMBER,
    idclient        NUMBER NOT NULL,
    datecommande    DATE NOT NULL,
    statut          VARCHAR2(30),
    CONSTRAINT fk_commandes2_clients2
        FOREIGN KEY (idclient) REFERENCES clients2(idclient)
);

CREATE TABLE lignecommandes2 (
    idlignecommande  NUMBER PRIMARY KEY,
    idcommande       NUMBER NOT NULL,
    idproduit        NUMBER NOT NULL,
    quantite         NUMBER NOT NULL,
    remise           NUMBER(5,2) DEFAULT 0,
    CONSTRAINT fk_ligne2_commandes2
        FOREIGN KEY (idcommande) REFERENCES commandes2(idcommande) ON DELETE CASCADE,
    CONSTRAINT fk_ligne2_produits2
        FOREIGN KEY (idproduit) REFERENCES produits2(idproduit) ON DELETE CASCADE
);

CREATE INDEX idx_produits2_categ ON produits2(idcateg, idproduit);
CREATE INDEX idx_lignecommandes2_prod_qte ON lignecommandes2(idproduit, quantite);
CREATE INDEX idx_commandes2_client_date ON commandes2(idclient, datecommande);

COMMIT;