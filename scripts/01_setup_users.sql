-- ===================================================
-- 01_SETUP_USERS.SQL - Creation des utilisateurs
-- ===================================================
-- A executer en SYS sur chaque base (globale, site1, site2)

-- Active l'affichage des commandes SQL en cours d'exécution
SET ECHO ON;
-- Active les messages de feedback (nombre de lignes affectées, etc.)
SET FEEDBACK ON;

-- Désactive la vérification C## (prefix Oracle Cloud) pour créer des users simples
ALTER SESSION SET "_ORACLE_SCRIPT" = TRUE;

-- Bloc PL/SQL pour créer l'utilisateur app_global avec gestion d'erreur
BEGIN
    -- Crée l'utilisateur avec mot de passe initial
    EXECUTE IMMEDIATE 'CREATE USER app_global IDENTIFIED BY Eshop123';
EXCEPTION
    -- Gestion des erreurs
    WHEN OTHERS THEN
        -- SQLCODE -1920 = utilisateur existe déjà (erreur attendue si rejeu du script)
        IF SQLCODE != -1920 THEN
            -- Relève l'exception si c'est une autre erreur
            RAISE;
        END IF;
        -- Ignore si l'utilisateur existe déjà
END;
-- / Termine le bloc PL/SQL (caractère de séparation)
/

BEGIN
    EXECUTE IMMEDIATE 'CREATE USER app_site1 IDENTIFIED BY Eshop123';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -1920 THEN
            RAISE;
        END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'CREATE USER app_site2 IDENTIFIED BY Eshop123';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -1920 THEN
            RAISE;
        END IF;
END;
/

-- Accorde les droits nécessaires pour que app_global puisse:
--   CREATE SESSION: Se connecter à la base de données
--   CREATE TABLE: Créer des tables
--   CREATE VIEW: Créer des vues
--   CREATE SEQUENCE: Créer des séquences (générateurs d'ID)
--   CREATE PROCEDURE: Créer des procédures stockées
--   CREATE TRIGGER: Créer des triggers
--   CREATE DATABASE LINK: Créer des liens distribués
GRANT CREATE SESSION, CREATE TABLE, CREATE VIEW, CREATE SEQUENCE,
      CREATE PROCEDURE, CREATE TRIGGER, CREATE DATABASE LINK
TO app_global;

GRANT CREATE SESSION, CREATE TABLE, CREATE VIEW, CREATE SEQUENCE,
      CREATE PROCEDURE, CREATE TRIGGER, CREATE DATABASE LINK
TO app_site1;

GRANT CREATE SESSION, CREATE TABLE, CREATE VIEW, CREATE SEQUENCE,
      CREATE PROCEDURE, CREATE TRIGGER, CREATE DATABASE LINK
TO app_site2;

-- Accorde un quota illimité de stockage pour chaque utilisateur dans le tablespace USERS
-- (évite les erreurs "ORA-01536: space quota exceeded for tablespace USERS")
ALTER USER app_global QUOTA UNLIMITED ON USERS;
ALTER USER app_site1 QUOTA UNLIMITED ON USERS;
ALTER USER app_site2 QUOTA UNLIMITED ON USERS;

-- Valide toutes les opérations du script
COMMIT;
