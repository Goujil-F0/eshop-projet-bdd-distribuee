Projet de base de donnees distribuee EShop.

Scenario 1 deja present :
- site1 : categorie 50 et quantite > 100
- site2 : categorie 35 et quantite > 50

Scenario 2 ajoute :
- site1 : quantite >= 100
- site2 : quantite < 100

Execution scenario 1 :
1. sqlplus "sys/Eshop123@localhost:1523/FREEPDB1 as sysdba" @scripts\01_setup_users.sql
2. sqlplus "sys/Eshop123@localhost:1524/FREEPDB1 as sysdba" @scripts\01_setup_users.sql
3. sqlplus "sys/Eshop123@localhost:1525/FREEPDB1 as sysdba" @scripts\01_setup_users.sql
4. sqlplus /nolog @scripts\02_tables_global.sql
5. sqlplus /nolog @scripts\03_tables_sites.sql
6. sqlplus /nolog @scripts\04_database_links.sql
7. sqlplus /nolog @scripts\05_procedures_sites.sql
8. sqlplus /nolog @scripts\06_triggers_global.sql
9. sqlplus /nolog @scripts\07_test_data.sql
10. sqlplus /nolog @scripts\08_queries_opti.sql
11. sqlplus /nolog @scripts\09_monitoring.sql

Execution scenario 2 :
1. Rejouer 02_tables_global.sql, 04_database_links.sql et 07_test_data.sql si besoin d'une base propre
2. sqlplus /nolog @scripts\10_scenario2_tables_sites.sql
3. sqlplus /nolog @scripts\11_scenario2_procedures_sites.sql
4. sqlplus /nolog @scripts\12_scenario2_triggers_global.sql
5. sqlplus /nolog @scripts\13_scenario2_verification.sql

Important :
- Les triggers globaux 06 et 12 portent les memes noms.
- Activer un scenario remplace le routage actif par celui de ce scenario.
