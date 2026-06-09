-- ===================================================
-- 15_CONNECTIVITY_TESTS.SQL - Audit des liens distribués
-- ===================================================
SET ECHO ON;
SET FEEDBACK ON;
SET PAGESIZE 100;

PROMPT ==========================================================
PROMPT DEBUT DU TEST DE CONNECTIVITE DISTRIBUEE
PROMPT ==========================================================

-- ----------------------------------------------------------
-- TEST 1 : Depuis la base globale vers les sites distants
-- ----------------------------------------------------------
PROMPT [TEST 1] Verification Global -> Site 1 et Site 2...
CONNECT app_global/Eshop123@localhost:1523/FREEPDB1;

BEGIN
    EXECUTE IMMEDIATE 'SELECT count(*) FROM dual@site1_link';
    DBMS_OUTPUT.PUT_LINE('SUCCESS: Lien site1_link est OPERATIONNEL');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: Lien site1_link est HORS SERVICE : ' || SQLERRM);
END;
/

BEGIN
    EXECUTE IMMEDIATE 'SELECT count(*) FROM dual@site2_link';
    DBMS_OUTPUT.PUT_LINE('SUCCESS: Lien site2_link est OPERATIONNEL');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: Lien site2_link est HORS SERVICE : ' || SQLERRM);
END;
/

-- ----------------------------------------------------------
-- TEST 2 : Depuis le Site 1 vers la base globale
-- ----------------------------------------------------------
PROMPT [TEST 2] Verification Site 1 -> Global...
CONNECT app_site1/Eshop123@localhost:1524/FREEPDB1;

BEGIN
    EXECUTE IMMEDIATE 'SELECT count(*) FROM dual@global_link';
    DBMS_OUTPUT.PUT_LINE('SUCCESS: Lien global_link (depuis Site 1) est OPERATIONNEL');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: Lien global_link (depuis Site 1) est HORS SERVICE : ' || SQLERRM);
END;
/

-- ----------------------------------------------------------
-- TEST 3 : Depuis le Site 2 vers la base globale
-- ----------------------------------------------------------
PROMPT [TEST 3] Verification Site 2 -> Global...
CONNECT app_site2/Eshop123@localhost:1525/FREEPDB1;

BEGIN
    EXECUTE IMMEDIATE 'SELECT count(*) FROM dual@global_link';
    DBMS_OUTPUT.PUT_LINE('SUCCESS: Lien global_link (depuis Site 2) est OPERATIONNEL');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: Lien global_link (depuis Site 2) est HORS SERVICE : ' || SQLERRM);
END;
/

PROMPT ==========================================================
PROMPT AUDIT DE CONNECTIVITE TERMINE
PROMPT ==========================================================