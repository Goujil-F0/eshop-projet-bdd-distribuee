-- ===================================================
-- 04_DATABASE_LINKS.SQL - Liens distribues
-- ===================================================

-- Active l'affichage des commandes SQL
SET ECHO ON;
-- Active les messages de feedback
SET FEEDBACK ON;

-- Section 1: Création des liens depuis la base globale vers les sites
PROMPT ===== Liens depuis la base globale =====
-- Se connecte à la base globale
CONNECT app_global/Eshop123@localhost:1523/FREEPDB1;

-- Supprime les liens s'ils existent déjà
BEGIN EXECUTE IMMEDIATE 'DROP DATABASE LINK site1_link'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP DATABASE LINK site2_link'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

-- Crée un lien de base de données nommé 'site1_link'
-- Permet d'accéder aux tables du site 1 avec la syntaxe: SELECT * FROM table@site1_link
CREATE DATABASE LINK site1_link
    -- Se connecte en tant qu'utilisateur app_site1 avec ce mot de passe
    CONNECT TO app_site1 IDENTIFIED BY Eshop123
    -- Adresse réseau du site 1 (db_site1 = hostname, 1521 = port Oracle, FREEPDB1 = SID)
    USING '//db_site1:1521/FREEPDB1';

-- Crée un lien de base de données nommé 'site2_link' pour accéder au site 2
CREATE DATABASE LINK site2_link
    CONNECT TO app_site2 IDENTIFIED BY Eshop123
    USING '//db_site2:1521/FREEPDB1';

-- Section 2: Création du lien site1 -> base globale
PROMPT ===== Lien site1 -> global =====
-- Se connecte au site 1
CONNECT app_site1/Eshop123@localhost:1524/FREEPDB1;

-- Supprime le lien s'il existe déjà
BEGIN EXECUTE IMMEDIATE 'DROP DATABASE LINK global_link'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

-- Crée un lien de base de données pour que site1 puisse accéder à la base globale
CREATE DATABASE LINK global_link
    CONNECT TO app_global IDENTIFIED BY Eshop123
    -- db_global = hostname du serveur global
    USING '//db_global:1521/FREEPDB1';

-- Section 3: Création du lien site2 -> base globale
PROMPT ===== Lien site2 -> global =====
-- Se connecte au site 2
CONNECT app_site2/Eshop123@localhost:1525/FREEPDB1;

-- Supprime le lien s'il existe déjà
BEGIN EXECUTE IMMEDIATE 'DROP DATABASE LINK global_link'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

-- Crée un lien de base de données pour que site2 puisse accéder à la base globale
CREATE DATABASE LINK global_link
    CONNECT TO app_global IDENTIFIED BY Eshop123
    USING '//db_global:1521/FREEPDB1';

-- Valide la création de tous les liens distribués
COMMIT;
