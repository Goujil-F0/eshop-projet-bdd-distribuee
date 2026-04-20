-- ===================================================
-- 02_TABLES_GLOBAL.SQL - Schema EShop global
-- ===================================================
-- A executer sur la base globale

-- Active l'affichage des commandes SQL
SET ECHO ON;
-- Active les messages de feedback
SET FEEDBACK ON;

-- Se connecte à l'utilisateur app_global sur le serveur local (port 1523)
CONNECT app_global/Eshop123@localhost:1523/FREEPDB1;

-- Supprime les tables s'il elles existent (CASCADE CONSTRAINTS pour respecter les contraintes FK)
-- Les blocs BEGIN/EXCEPTION/END ignorent les erreurs si les tables n'existent pas
BEGIN EXECUTE IMMEDIATE 'DROP TABLE lignecommandes CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE commandes CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE clients CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE produits CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE categories CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_categories'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_produits'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_clients'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_commandes'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_lignecommandes'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

-- Table CATEGORIES: Référentiel des catégories de produits
CREATE TABLE categories (
    idcateg      NUMBER PRIMARY KEY,          -- Identifiant unique de la catégorie
    nomcateg     VARCHAR2(100) NOT NULL,      -- Nom de la catégorie (obligatoire)
    description  VARCHAR2(400)                -- Description optionnelle (null accepté)
);

-- Table PRODUITS: Catalogue des produits avec références aux catégories
CREATE TABLE produits (
    idproduit     NUMBER PRIMARY KEY,         -- Identifiant unique du produit
    idcateg       NUMBER NOT NULL,            -- Référence à la catégorie (obligatoire)
    designation   VARCHAR2(200) NOT NULL,    -- Nom/description du produit
    prixunitaire  NUMBER(10,2) NOT NULL,     -- Prix avec 2 décimales (format monétaire)
    stock         NUMBER DEFAULT 0,          -- Quantité en stock (défaut: 0)
    -- Contrainte de clé étrangère: chaque produit doit avoir une catégorie existante
    CONSTRAINT fk_produits_categories
        FOREIGN KEY (idcateg) REFERENCES categories(idcateg)
);

-- Table CLIENTS: Référentiel centralisé des clients
CREATE TABLE clients (
    idclient     NUMBER PRIMARY KEY,          -- Identifiant unique du client
    codeclient   VARCHAR2(20) NOT NULL UNIQUE,-- Code client unique (ex: CLI001)
    societe      VARCHAR2(150) NOT NULL,     -- Raison sociale (obligatoire)
    ville        VARCHAR2(100),              -- Ville (optionnelle)
    pays         VARCHAR2(100),              -- Pays (optionnelle)
    telephone    VARCHAR2(30)                -- Numéro de téléphone (optionnel)
);

-- Table COMMANDES: Enregistrements des commandes clients
CREATE TABLE commandes (
    idcommande      NUMBER PRIMARY KEY,       -- Identifiant unique de la commande
    idemploye       NUMBER,                  -- Référence à l'employé (optionnel)
    idclient        NUMBER NOT NULL,         -- Client obligatoire
    datecommande    DATE NOT NULL,           -- Date de la commande (obligatoire)
    statut          VARCHAR2(30) DEFAULT 'EN_COURS', -- État: EN_COURS, LIVREE, etc.
    -- Clé étrangère: chaque commande doit référencer un client existant
    CONSTRAINT fk_commandes_clients
        FOREIGN KEY (idclient) REFERENCES clients(idclient)
);

-- Table LIGNECOMMANDES: Détail des articles dans chaque commande
CREATE TABLE lignecommandes (
    idlignecommande  NUMBER PRIMARY KEY,     -- Identifiant unique de la ligne
    idcommande       NUMBER NOT NULL,        -- Référence à la commande
    idproduit        NUMBER NOT NULL,        -- Référence au produit commandé
    quantite         NUMBER NOT NULL,        -- Quantité commandée (obligatoire)
    remise           NUMBER(5,2) DEFAULT 0, -- Remise en pourcentage (max 99.99%)
    -- Clé étrangère: ligne doit référencer une commande existante
    CONSTRAINT fk_ligne_commandes
        FOREIGN KEY (idcommande) REFERENCES commandes(idcommande),
    -- Clé étrangère: produit doit exister dans le catalogue
    CONSTRAINT fk_ligne_produits
        FOREIGN KEY (idproduit) REFERENCES produits(idproduit)
);

-- Crée les séquences pour générer automatiquement les identifiants (clés primaires)
-- START WITH 1: Commence à 1
-- INCREMENT BY 1: Augmente de 1 à chaque utilisation
-- Utilisation: INSERT INTO table VALUES(seq_nom.NEXTVAL, ...)
CREATE SEQUENCE seq_categories START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_produits START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_clients START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_commandes START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_lignecommandes START WITH 1 INCREMENT BY 1;

-- Valide toutes les opérations de création du schéma
COMMIT;
