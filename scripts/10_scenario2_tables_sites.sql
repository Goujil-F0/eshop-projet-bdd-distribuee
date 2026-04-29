-- ===================================================
-- 10_SCENARIO2_TABLES_SITES.SQL
-- Fragmentation par volume de vente
-- Site1 : Quantite >= 100
-- Site2 : Quantite < 100
-- ===================================================

SET ECHO ON;
SET FEEDBACK ON;

PROMPT ===== SCENARIO 2 - SITE 1 =====
CONNECT app_site1/Eshop123@localhost:1524/FREEPDB1;

BEGIN EXECUTE IMMEDIATE 'DROP TABLE lignecommandes1 CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE commandes1 CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE clients1 CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE produits1 CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

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
    CONSTRAINT fk_s2_commandes1_clients1
        FOREIGN KEY (idclient) REFERENCES clients1(idclient)
);

CREATE TABLE produits1 (
    idproduit     NUMBER PRIMARY KEY,
    idcateg       NUMBER NOT NULL,
    designation   VARCHAR2(200) NOT NULL,
    prixunitaire  NUMBER(10,2) NOT NULL
);

CREATE TABLE lignecommandes1 (
    idlignecommande  NUMBER PRIMARY KEY,
    idcommande       NUMBER NOT NULL,
    idproduit        NUMBER NOT NULL,
    quantite         NUMBER NOT NULL CHECK (quantite >= 100),
    remise           NUMBER(5,2) DEFAULT 0,
    CONSTRAINT fk_s2_ligne1_commandes1
        FOREIGN KEY (idcommande) REFERENCES commandes1(idcommande) ON DELETE CASCADE,
    CONSTRAINT fk_s2_ligne1_produits1
        FOREIGN KEY (idproduit) REFERENCES produits1(idproduit) ON DELETE CASCADE
);

CREATE INDEX idx_s2_ligne1_quantite ON lignecommandes1(quantite, idproduit);
CREATE INDEX idx_s2_commandes1_client ON commandes1(idclient, datecommande);

COMMIT;

PROMPT ===== SCENARIO 2 - SITE 2 =====
CONNECT app_site2/Eshop123@localhost:1525/FREEPDB1;

BEGIN EXECUTE IMMEDIATE 'DROP TABLE lignecommandes2 CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE commandes2 CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE clients2 CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE produits2 CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

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
    CONSTRAINT fk_s2_commandes2_clients2
        FOREIGN KEY (idclient) REFERENCES clients2(idclient)
);

CREATE TABLE produits2 (
    idproduit     NUMBER PRIMARY KEY,
    idcateg       NUMBER NOT NULL,
    designation   VARCHAR2(200) NOT NULL,
    prixunitaire  NUMBER(10,2) NOT NULL
);

CREATE TABLE lignecommandes2 (
    idlignecommande  NUMBER PRIMARY KEY,
    idcommande       NUMBER NOT NULL,
    idproduit        NUMBER NOT NULL,
    quantite         NUMBER NOT NULL CHECK (quantite < 100),
    remise           NUMBER(5,2) DEFAULT 0,
    CONSTRAINT fk_s2_ligne2_commandes2
        FOREIGN KEY (idcommande) REFERENCES commandes2(idcommande) ON DELETE CASCADE,
    CONSTRAINT fk_s2_ligne2_produits2
        FOREIGN KEY (idproduit) REFERENCES produits2(idproduit) ON DELETE CASCADE
);

CREATE INDEX idx_s2_ligne2_quantite ON lignecommandes2(quantite, idproduit);
CREATE INDEX idx_s2_commandes2_client ON commandes2(idclient, datecommande);

COMMIT;
