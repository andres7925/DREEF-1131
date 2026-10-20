--------------------------------------------------------------------------------------------------------------------
--- REEF.Core TRON2000_% Plantilla pdc Lógica ( % = Código iso país de 2 caracteres ) (v1.0)                     ---
--------------------------------------------------------------------------------------------------------------------
--- Nombre de la Lógica:      EM_K_LIS_PRODUCCION_BAC_MHN
--- Propietario/Cedente:      TRON2000_%
--- Beneficiarios:            TRON2000, TRON2000_%_APP, TRC_%_IL 
--- Sinónimos en:             TRON2000_%_APP, TRC_%_IL 
--- Variables a sustituir:    v_logic, v_iso, v_mark_trc_il
--- Fecha realización:        [21-11-2025]
--- Realizado por:            [CPALBE1]
--- Comentario:               Los valores de las variables v_logic, v_iso, v_mark_trc_il deberán sustituirse
--------------------------------------------------------------------------------------------------------------------

DECLARE
  --
  -- Por favor, sustituya los valores de las variables v_logic, v_iso, v_mark_trc_il por sus correspondientes
  -- Si quiere dar privilegios a TRC_%_IL, debe cambiar el valor de la variable v_mark_trc_il a 'S'
  --
  -- Variables a sustituir
  --
  v_logic        VARCHAR2(40) := 'co_k_lista_deta_rmo_mhn'; -- Nombre de la lógica
  v_iso          VARCHAR2(2)  := 'HN'; -- Código ISO del país de 2 caracteres (ej. HN=Honduras, PA=Panamá)
  v_mark_trc_il  VARCHAR2(1)  := 'N'; -- (Cambiar a S si se quiere dar privilegios a TRC_%_IL. Por defecto N)
  --
  -- Otras variables
  --
  v_owner        VARCHAR2(30) := 'TRON2000_' || upper(v_iso);
  v_tron2000     VARCHAR2(30) := 'TRON2000';
  v_owner_app    VARCHAR2(30) := 'TRON2000_' || upper(v_iso) || '_APP';
  v_trc_il       VARCHAR2(30) := 'TRC_' || upper(v_iso) || '_IL';
  v_count        INTEGER;
  v_txt_grant    VARCHAR2(200);
  v_txt_synonym  VARCHAR2(200);
  --
  CURSOR c_cursor_trc_il
  IS
  SELECT COUNT (1)
    FROM dba_users t
   WHERE t.username = v_trc_il;
  --
  -- Si se ha elegido dar privilegios sobre la lógica de TRON2000_% a TRC_%_IL (v_mark_trc_il a 'S') y TRC_%_IL existe:
  --   1) Se otorga privilegio sobre la lógica de TRON2000_% a TRC_%_IL
  --   2) Se crea un sinónimo en TRC_%_IL sobre la sobre la lógica de TRON2000_%
  --
BEGIN
  --
  v_logic       := upper(v_logic);
  v_iso         := upper(v_iso);
  v_mark_trc_il := upper(v_mark_trc_il);
  --
  -- Verificaciones
  --
  -- El valor de la variable v_mark_trc_il tiene que ser S o N.
  --
  if v_mark_trc_il not in ('S', 'N') or v_mark_trc_il is null then
   DBMS_OUTPUT.PUT_LINE(TO_CHAR(SYSDATE,'YYYY/MM/DD HH24:MI:SS')|| ' The value of v_mark_trc_il is not valid. No change has been made');
   raise_application_error(-20999,'The value of v_mark_trct_il is not valid. No change has been made');
  end if;
  --
  if v_logic is null or v_iso is null then
    DBMS_OUTPUT.PUT_LINE(TO_CHAR(SYSTIMESTAMP,'YYYY/MM/DD HH24:MI:SS.FF')||' Logic name or ISO country code (Alpha-2 code) is null. No change has been performed');
    raise_application_error(-20999,'Logic name or ISO country code (Alpha-2 code) is null. No change has been made');
  end if;
  
  if substr(v_logic,(length(v_logic)-3),4) != '_M' || v_iso then
   DBMS_OUTPUT.PUT_LINE(TO_CHAR(SYSDATE,'YYYY/MM/DD HH24:MI:SS')|| ' Logic name suffix does not match ISO code. No change has been made');
   raise_application_error(-20999,'Logic name suffix does not match ISO code. No change has been made');
  end if;
  --
  DBMS_OUTPUT.PUT_LINE(TO_CHAR(SYSDATE,'YYYY/MM/DD HH24:MI:SS') || ' -- Granting privileges logic: ' || v_owner || '.' || v_logic);
  --
  -- Privilegios sobre la lógica de TRON2000_% a TRON2000
  --
  v_txt_grant := 'GRANT EXECUTE ON ' || v_owner || '.' || v_logic || ' TO ' || v_tron2000;
  EXECUTE IMMEDIATE v_txt_grant;
  DBMS_OUTPUT.PUT_LINE(TO_CHAR(SYSDATE,'YYYY/MM/DD HH24:MI:SS') || ' ' || v_txt_grant);
  --
  -- Privilegios y sinónimo sobre la lógica de TRON2000_% a TRON2000_%_APP
  --
  v_txt_grant := 'GRANT EXECUTE ON ' || v_owner || '.' || v_logic || ' TO ' || v_owner_app;
  EXECUTE IMMEDIATE v_txt_grant;
  DBMS_OUTPUT.PUT_LINE(TO_CHAR(SYSDATE,'YYYY/MM/DD HH24:MI:SS') || ' ' || v_txt_grant);
  --
  v_txt_synonym := 'CREATE OR REPLACE SYNONYM '|| v_owner_app || '.' || v_logic || ' FOR ' || v_owner || '.' || v_logic;
  EXECUTE IMMEDIATE v_txt_synonym;
  DBMS_OUTPUT.PUT_LINE(TO_CHAR(SYSDATE,'YYYY/MM/DD HH24:MI:SS') || ' ' || v_txt_synonym);
  --
  -- Privilegios y sinónimo a TRC_%_IL
  -- 
  IF v_mark_trc_il = 'S'
  THEN
    v_count := 0;
    OPEN  c_cursor_trc_il;
    FETCH c_cursor_trc_il INTO v_count;
    CLOSE c_cursor_trc_il;
    --
    IF v_count = 1
    THEN
      v_txt_grant := 'GRANT EXECUTE ON '|| v_owner || '.' || v_logic || ' TO ' || v_trc_il;
      EXECUTE IMMEDIATE v_txt_grant;
      DBMS_OUTPUT.PUT_LINE(TO_CHAR(SYSDATE,'YYYY/MM/DD HH24:MI:SS') || ' ' || v_txt_grant);
      --
      v_txt_synonym := 'CREATE OR REPLACE SYNONYM '|| v_trc_il || '.' || v_logic || ' FOR ' || v_owner || '.' || v_logic;
      EXECUTE IMMEDIATE v_txt_synonym;
      DBMS_OUTPUT.PUT_LINE(TO_CHAR(SYSDATE,'YYYY/MM/DD HH24:MI:SS') || ' ' || v_txt_synonym);
      --
    END IF;
    --
  END IF;
  --
  DBMS_OUTPUT.PUT_LINE(TO_CHAR(SYSDATE,'YYYY/MM/DD HH24:MI:SS') || ' -- Grants succeeded logic: '|| v_owner || '.' || v_logic);
  --
END;
/
