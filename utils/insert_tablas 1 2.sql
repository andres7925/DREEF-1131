DECLARE
   --
   /* ----------
   || CURSORES
   */ ----------
   --
   CURSOR lc_columas (pc_nom_tabla VARCHAR2,
                      pc_esquema   VARCHAR2)
   IS
      SELECT UPPER(atc.column_name) nom_campo,
             UPPER(atc.data_type)   tipo_dato
        FROM all_tab_columns  atc,
             all_col_comments acc,
             all_tab_comments cdt
       WHERE UPPER(acc.table_name) = UPPER(pc_nom_tabla)
         AND atc.table_name        = acc.table_name
         AND atc.column_name       = acc.column_name
         AND cdt.table_name        = atc.table_name
         AND UPPER(atc.owner)      = NVL(UPPER(pc_esquema), UPPER('TRON2000'))
         AND atc.owner             = acc.owner
         AND atc.owner             = cdt.owner
       ORDER BY atc.column_id;
   --
   CURSOR lc_llave_primaria (pc_nom_tabla VARCHAR2,
                             pc_esquema   VARCHAR2)
   IS
      SELECT UPPER(atc.column_name) nom_campo
        FROM all_tab_columns  atc,
             all_col_comments acc,
             all_tab_comments cdt
       WHERE UPPER(acc.table_name) = UPPER(pc_nom_tabla)
         AND atc.table_name        = acc.table_name
         AND atc.column_name       = acc.column_name
         AND cdt.table_name        = atc.table_name
         AND UPPER(atc.owner)      = NVL(UPPER(pc_esquema), UPPER('TRON2000'))
         AND atc.owner             = acc.owner
         AND atc.owner             = cdt.owner
         AND UPPER(atc.column_name) IN (SELECT u1.column_name
                                          FROM all_cons_columns u1,
                                               all_constraints  u2
                                         WHERE u1.constraint_name       = u2.constraint_name
                                           AND UPPER(u2.constraint_type) = UPPER('P')
                                           AND UPPER(u2.table_name)      = UPPER(pc_nom_tabla)
                                           AND UPPER(u2.owner)           = NVL(UPPER(pc_esquema), UPPER('TRON2000'))
                                           AND u2.owner                  = u1.owner
                                           AND u2.status                 = 'ENABLED')
       ORDER BY atc.column_id;
   --
   CURSOR lc_columas_sin_pk (pc_nom_tabla VARCHAR2,
                             pc_esquema   VARCHAR2)
   IS
      SELECT UPPER(atc.column_name) nom_campo
        FROM all_tab_columns  atc,
             all_col_comments acc,
             all_tab_comments cdt
       WHERE UPPER(acc.table_name) = UPPER(pc_nom_tabla)
         AND atc.table_name        = acc.table_name
         AND atc.column_name       = acc.column_name
         AND cdt.table_name        = atc.table_name
         AND UPPER(atc.owner)      = NVL(UPPER(pc_esquema), UPPER('TRON2000'))
         AND atc.owner             = acc.owner
         AND atc.owner             = cdt.owner
         AND UPPER(atc.column_name) NOT IN (SELECT u1.column_name
                                              FROM all_cons_columns u1,
                                                   all_constraints  u2
                                             WHERE u1.constraint_name       = u2.constraint_name
                                               AND UPPER(u2.constraint_type) = UPPER('P')
                                               AND UPPER(u2.table_name)      = UPPER(pc_nom_tabla)
                                               AND UPPER(u2.owner)           = NVL(UPPER(pc_esquema), UPPER('TRON2000'))
                                               AND u2.owner                  = u1.owner
                                               AND u2.status                 = 'ENABLED')
       ORDER BY atc.column_id;
   --
   /* ----------
   || REGISTROS
   */ ----------
   --
   TYPE reg_campos_tabla IS RECORD (nom_campo all_tab_columns.column_name%TYPE,
                                    tipo_dato all_tab_columns.data_type  %TYPE);
   --
   l_reg_campos_tabla   reg_campos_tabla         ;
   --
   TYPE tabla_reg_campos     IS TABLE OF l_reg_campos_tabla%TYPE INDEX BY BINARY_INTEGER;
   TYPE tabla_reg_pk_campos  IS TABLE OF VARCHAR2(00080)         INDEX BY BINARY_INTEGER;
   TYPE tabla_reg_datos      IS TABLE OF VARCHAR2(32000)         INDEX BY BINARY_INTEGER;
   TYPE tabla_reg_length     IS TABLE OF NUMBER                  INDEX BY BINARY_INTEGER;
   --
   l_tbl_reg_campos     tabla_reg_campos         ;
   l_pk_reg_campos      tabla_reg_pk_campos      ;
   l_sin_pk_reg_campos  tabla_reg_pk_campos      ;
   l_tbl_reg_datos      tabla_reg_datos          ;
   l_tbl_reg_length     tabla_reg_length         ;
   --
   l_reg_columas        lc_columas       %ROWTYPE;
   l_pk_columas         lc_llave_primaria%ROWTYPE;
   l_sin_pk_columas     lc_columas_sin_pk%ROWTYPE;
   --
   /* -------------------
   || VARIABLES PARA CLOB
   */ -------------------
   --
   TYPE reg_datos_clob IS RECORD (dato_clob VARCHAR2(3000));
   --
   l_reg_datos_clob     reg_datos_clob           ;
   --
   TYPE tabla_reg_datos_clob IS TABLE OF l_reg_datos_clob  %TYPE INDEX BY BINARY_INTEGER;
   --
   l_tbl_reg_datos_clob tabla_reg_datos_clob     ;
   --
   TYPE reg_all_clobs IS RECORD (es_nulo        BOOLEAN             ,
                                 reg_datos_clob tabla_reg_datos_clob);
   --
   l_reg_all_clobs      reg_all_clobs            ;
   --
   TYPE tabla_reg_all_clobs  IS TABLE OF l_reg_all_clobs   %TYPE INDEX BY all_tab_columns.column_name%TYPE;
   --
   l_tbl_reg_all_clobs  tabla_reg_all_clobs      ;
   --
   /* ----------
   || VARIABLES
   */ ----------
   --
   l_esquema           VARCHAR2(00030);
   l_nom_tabla         VARCHAR2(00030);
   l_alias             VARCHAR2(00002);
   l_sql_select        VARCHAR2(32000);
   l_sql_where         VARCHAR2(32000);
   l_inicio            VARCHAR2(05000);
   l_dato_select       VARCHAR2(32000);
   l_val_columna       VARCHAR2(10000);
   l_val_clob          VARCHAR2(20000);
   l_campos            VARCHAR2(32000);
   l_datos             VARCHAR2(32000);
   l_exception_bloque  VARCHAR2(10000);
   l_update            VARCHAR2(25000);
   l_set               VARCHAR2(20000);
   l_where             VARCHAR2(20000);
   l_fin               VARCHAR2(01000);
   l_dato_clob         VARCHAR2(03000);
   --
   l_campo_max_chr     NUMBER         ;
   l_campo_pk_max_chr  NUMBER         ;
   l_campo_sin_max_chr NUMBER         ;
   l_campo_max_valor   NUMBER         ;
   l_idex_sig_valor    NUMBER         ;
   l_inf_max_chr       NUMBER         ;
   l_inf_max_values    NUMBER         ;
   l_val_para_clob     NUMBER         ;
   l_num_reg           NUMBER         ;
   --
   l_posicion          BINARY_INTEGER ;
   l_pst_columnas      BINARY_INTEGER ;
   l_pst_val           BINARY_INTEGER ;
   l_pst_clob          BINARY_INTEGER ;
   --
   l_es_where          BOOLEAN        ;
   --
   NOM_TABLA_NULL      EXCEPTION      ;
   TABLA_NO_FOUND      EXCEPTION      ;
   TABLA_SIN_PK        EXCEPTION      ;
   TABLA_SIN_S_PK      EXCEPTION      ;
   --
   /* -----------
   || CONSTANTES
   */ -----------
   --
   l_k_vacio  CONSTANT VARCHAR2(01) := '' ;
   l_k_blanco CONSTANT VARCHAR2(01) := ' ';
   --
BEGIN
   --
   -- Implementa para que no ejecute error en la impresion de datos
   --
   DBMS_OUTPUT.ENABLE (10000000000);
   --
   l_esquema := UPPER('tron2000'); --INGRESAR ESQUEMA CON PUNTO, CASO CONTRARIO SIN PUNTO
   --
   l_nom_tabla := UPPER('g2002153'); --INSERTAR TABLA ACA
   --
   IF    l_nom_tabla IS NULL
      OR l_nom_tabla  = l_k_vacio
      OR l_nom_tabla  = l_k_blanco
   THEN
      --
      RAISE NOM_TABLA_NULL;
      --
   END IF;
   --
   l_sql_where := 'cod_cob = 7059'; -- sin where
   --
   IF lc_columas%ISOPEN
   THEN
      --
      CLOSE lc_columas;
      --
   END IF;
   --
   OPEN lc_columas (pc_nom_tabla => l_nom_tabla,
                    pc_esquema   => l_esquema  );
   --
   FETCH lc_columas INTO l_reg_columas;
   --
   IF lc_columas%NOTFOUND
   THEN
      --
      CLOSE lc_columas;
      --
      RAISE TABLA_NO_FOUND;
      --
   END IF;
   --
   l_pst_columnas := 1;
   --
   l_campo_max_chr := 0;
   --
   WHILE lc_columas%FOUND
   LOOP
      --
      l_tbl_reg_campos(l_pst_columnas).nom_campo := l_reg_columas.nom_campo;
      l_tbl_reg_campos(l_pst_columnas).tipo_dato := l_reg_columas.tipo_dato;
      --
      IF LENGTH(l_reg_columas.nom_campo) > l_campo_max_chr
      THEN
         --
         l_campo_max_chr := LENGTH(l_reg_columas.nom_campo);
         --
      END IF;
      --
      l_pst_columnas := l_pst_columnas + 1;
      --
      FETCH lc_columas INTO l_reg_columas;
      --
   END LOOP;
   --
   CLOSE lc_columas;
   --
   IF lc_llave_primaria%ISOPEN
   THEN
      --
      CLOSE lc_llave_primaria;
      --
   END IF;
   --
   OPEN lc_llave_primaria (pc_nom_tabla => l_nom_tabla,
                           pc_esquema   => l_esquema  );
   --
   FETCH lc_llave_primaria INTO l_pk_columas;
   --
   IF lc_llave_primaria%NOTFOUND
   THEN
      --
      CLOSE lc_llave_primaria;
      --
      RAISE TABLA_SIN_PK;
      --
   END IF;
   --
   l_num_reg          := 1;
   l_posicion         := 1;
   l_campo_pk_max_chr := 0;
   --
   WHILE lc_llave_primaria%FOUND
   LOOP
      --
      l_pk_reg_campos(l_posicion) := l_pk_columas.nom_campo;
      --
      IF LENGTH(l_pk_columas.nom_campo) > l_campo_pk_max_chr
      THEN
         --
         l_campo_pk_max_chr := LENGTH(l_pk_columas.nom_campo);
         --
      END IF;
      --
      l_posicion := l_posicion + 1;
      --
      FETCH lc_llave_primaria INTO l_pk_columas;
      --
   END LOOP;
   --
   CLOSE lc_llave_primaria;
   --
   IF lc_columas_sin_pk%ISOPEN
   THEN
      --
      CLOSE lc_columas_sin_pk;
      --
   END IF;
   --
   OPEN lc_columas_sin_pk (pc_nom_tabla => l_nom_tabla,
                           pc_esquema   => l_esquema  );
   --
   FETCH lc_columas_sin_pk INTO l_sin_pk_columas;
   --
   IF lc_columas_sin_pk%NOTFOUND
   THEN
      --
      CLOSE lc_columas_sin_pk;
      --
      RAISE TABLA_SIN_S_PK;
      --
   END IF;
   --
   l_posicion          := 1;
   l_campo_sin_max_chr := 0;
   --
   WHILE lc_columas_sin_pk%FOUND
   LOOP
      --
      l_sin_pk_reg_campos(l_posicion) := l_sin_pk_columas.nom_campo;
      --
      IF LENGTH(l_sin_pk_columas.nom_campo) > l_campo_sin_max_chr
      THEN
         --
         l_campo_sin_max_chr := LENGTH(l_sin_pk_columas.nom_campo);
         --
      END IF;
      --
      l_posicion := l_posicion + 1;
      --
      FETCH lc_columas_sin_pk INTO l_sin_pk_columas;
      --
   END LOOP;
   --
   CLOSE lc_columas_sin_pk;
   --
   l_alias := SUBSTR(LOWER(l_nom_tabla), 1, 1) || '1';
   --
   l_sql_select := 'SELECT ';
   --
   l_posicion  := l_tbl_reg_campos.FIRST;
   --
   WHILE l_posicion IS NOT NULL
   LOOP
      --
      IF l_tbl_reg_campos(l_posicion).tipo_dato = 'CLOB'
      THEN
         --
         l_sql_select := l_sql_select || l_alias || '.' || LOWER(l_tbl_reg_campos(l_posicion).nom_campo);
         --
      ELSE
         --
         l_sql_select := l_sql_select || 'DECODE(' || l_alias || '.' || LOWER(l_tbl_reg_campos(l_posicion).nom_campo)  || ', NULL, ''NULL'', ' || l_alias || '.' || LOWER(l_tbl_reg_campos(l_posicion).nom_campo) || ')';
         --
      END IF;
      --
      IF l_posicion != l_tbl_reg_campos.LAST
      THEN
         --
         l_sql_select := l_sql_select || ' || ''~'' || ';
         --
      END IF;
      --
      l_posicion  := l_tbl_reg_campos.NEXT(l_posicion);
      --
   END LOOP;
   --
   l_sql_select := l_sql_select || ' FROM ' || LOWER(l_esquema) ||'.' ||LOWER(l_nom_tabla) || ' ' || l_alias;
   --
   IF    l_sql_where IS NOT NULL
      OR l_sql_where != l_k_vacio
      OR l_sql_where != l_k_blanco
   THEN
      --
      l_sql_select := l_sql_select || ' WHERE ' || l_sql_where;
      --
   END IF;
   --
   l_sql_select := l_sql_select || ' ORDER BY ';
   --
   l_posicion  := l_pk_reg_campos.FIRST;
   --
   WHILE l_posicion IS NOT NULL
   LOOP
      --
      IF l_posicion != l_pk_reg_campos.LAST
      THEN
         --
         l_sql_select := l_sql_select || l_alias || '.' || LOWER(l_pk_reg_campos(l_posicion)) || ', ';
         --
      ELSE
         --
         l_sql_select := l_sql_select || l_alias || '.' || LOWER(l_pk_reg_campos(l_posicion));
         --
      END IF;
      --
      l_posicion := l_pk_reg_campos.NEXT(l_posicion);
      --
   END LOOP;
   --
   EXECUTE IMMEDIATE l_sql_select BULK COLLECT INTO l_tbl_reg_datos;
   --
   l_pst_val := l_tbl_reg_datos.FIRST;
   --
   WHILE l_pst_val IS NOT NULL
   LOOP
      --
      l_campo_max_valor := 0;
      --
      l_dato_select := l_tbl_reg_datos(l_pst_val);
      --
      l_pst_columnas := l_tbl_reg_campos.FIRST;
      --
      WHILE l_pst_columnas IS NOT NULL
      LOOP
         --
         l_idex_sig_valor := INSTR(l_dato_select, '~', 1);
         --
         IF l_tbl_reg_campos(l_pst_columnas).tipo_dato = 'CLOB'
         THEN
            --
            l_tbl_reg_datos_clob.DELETE;
            --
            l_val_para_clob := 1;
            --
            IF l_idex_sig_valor > 0
            THEN
               --
               l_val_columna := DBMS_LOB.SUBSTR(SUBSTR(l_dato_select, 1, l_idex_sig_valor - 1), 1000, l_val_para_clob);
               --
            ELSE
               --
               l_val_columna := DBMS_LOB.SUBSTR(l_dato_select, 1000, l_val_para_clob);
               --
            END IF;
            --
            l_val_para_clob := 1000;
            --
            l_pst_clob := 0;
            --
            WHILE l_val_columna IS NOT NULL
            LOOP
               --
               l_tbl_reg_datos_clob(l_pst_clob).dato_clob := l_val_columna;
               --
               l_pst_clob := l_pst_clob + 1;
               --
               IF l_idex_sig_valor > 0
               THEN
                  --
                  l_val_columna := DBMS_LOB.SUBSTR(SUBSTR(l_dato_select, 1, l_idex_sig_valor - 1), 1000, l_val_para_clob);
                  --
               ELSE
                  --
                  l_val_columna := DBMS_LOB.SUBSTR(l_dato_select, 1000, l_val_para_clob);
                  --
               END IF;
               --
               l_val_para_clob := l_val_para_clob + 1000;
               --
            END LOOP;
            --
            IF l_tbl_reg_datos_clob.COUNT > 0
            THEN
               --
               l_tbl_reg_all_clobs(l_tbl_reg_campos(l_pst_columnas).nom_campo || l_num_reg).es_nulo        := FALSE               ;
               l_tbl_reg_all_clobs(l_tbl_reg_campos(l_pst_columnas).nom_campo || l_num_reg).reg_datos_clob := l_tbl_reg_datos_clob;
               --
            ELSE
               --
               l_tbl_reg_all_clobs(l_tbl_reg_campos(l_pst_columnas).nom_campo || l_num_reg).es_nulo        := TRUE                ;
               l_tbl_reg_all_clobs(l_tbl_reg_campos(l_pst_columnas).nom_campo || l_num_reg).reg_datos_clob := l_tbl_reg_datos_clob;
               --
            END IF;
            --
            l_num_reg := l_num_reg + 1;
            --
            l_dato_select := SUBSTR(l_dato_select, l_idex_sig_valor + 1, LENGTH(l_dato_select));
            --
         ELSE
            --
            IF l_idex_sig_valor > 0
            THEN
               --
               l_val_columna := SUBSTR(l_dato_select, 1, l_idex_sig_valor - 1);
               --
               l_dato_select := SUBSTR(l_dato_select, l_idex_sig_valor + 1, LENGTH(l_dato_select));
               --
            ELSE
               --
               l_val_columna := l_dato_select;
               --
            END IF;
            --
            IF l_val_columna != 'NULL'
            THEN
               --
               CASE l_tbl_reg_campos(l_pst_columnas).tipo_dato
                  --
                  WHEN 'VARCHAR2'
                  THEN
                     --
                     l_val_columna := CHR(39) || l_val_columna || CHR(39);
                     --
                  WHEN 'DATE'
                  THEN
                     --
                     IF l_tbl_reg_campos(l_pst_columnas).nom_campo = 'FEC_ACTU'
                     THEN
                        --
                        l_val_columna := 'TRUNC(SYSDATE)';
                        --
                     ELSE
                        --
                        l_val_columna := REPLACE(REPLACE(l_val_columna, '-', l_k_vacio), '/', l_k_vacio);
                        --
                        l_val_columna := 'TO_DATE(' || CHR(39) || TO_CHAR(TO_DATE(l_val_columna), 'DDMMYYYY') || CHR(39) || ', '  || CHR(39) || 'DDMMYYYY' || CHR(39) || ')';
                        --
                     END IF;
                     --
                  ELSE
                     --
                     NULL;
                     --
                  --
               END CASE;
               --
            END IF;
            --
            IF LENGTH(l_val_columna) > l_campo_max_valor
            THEN
               --
               l_campo_max_valor := LENGTH(l_val_columna);
               --
            END IF;
            --
         END IF;
         --
         l_pst_columnas := l_tbl_reg_campos.NEXT(l_pst_columnas);
         --
      END LOOP;
      --
      l_tbl_reg_length(l_pst_val) := l_campo_max_valor;
      --
      l_pst_val := l_tbl_reg_datos.NEXT(l_pst_val);
      --
   END LOOP;
   --
   l_inicio := 'DECLARE'  || CHR(13) ||
               '   --'    || CHR(13) ||
               '   /*'    || CHR(13) ||
               '   WHERE UTILIZADO:' || 
                             CHR(13) ||
               '      '   || l_sql_where|| 
                             CHR(13) ||
               '   */'    || CHR(13) ||
               '   --'    || CHR(13) ||
               'BEGIN'                 ;
   --
   DBMS_OUTPUT.PUT_LINE (l_inicio);
   --
   l_num_reg := 1;
   --
   l_pst_val := l_tbl_reg_datos.FIRST;
   --
   WHILE l_pst_val IS NOT NULL
   LOOP
      --
      l_set   := NULL;
      l_where := NULL;
      --
      l_dato_select := l_tbl_reg_datos(l_pst_val);
      --
      l_inf_max_chr := LENGTH('      INSERT INTO ' || LOWER(l_esquema) ||'.'|| LOWER(l_nom_tabla) || ' (');
      --
      l_campos := '   --'              || CHR(13)            ||
                  '   BEGIN'           || CHR(13)            ||
                  '      --'           || CHR(13)            ||
                  '      INSERT INTO ' || LOWER(l_esquema) ||'.'|| LOWER(l_nom_tabla) || ' (';
      --
      l_pst_columnas := l_tbl_reg_campos.FIRST;
      --
      WHILE l_pst_columnas IS NOT NULL
      LOOP
         --
         IF l_pst_columnas != l_tbl_reg_campos.FIRST
         THEN
            --
            l_campos := l_campos || LPAD(l_k_blanco, l_inf_max_chr) || RPAD(LOWER(l_tbl_reg_campos(l_pst_columnas).nom_campo), l_campo_max_chr, l_k_blanco);
            --
         ELSE
            --
            l_campos := l_campos || RPAD(LOWER(l_tbl_reg_campos(l_pst_columnas).nom_campo), l_campo_max_chr, l_k_blanco);
            --
         END IF;
         --
         IF l_pst_columnas != l_tbl_reg_campos.LAST
         THEN
            --
            l_campos := l_campos || ',' || CHR(13);
            --
         ELSE
            --
            l_campos := l_campos || ')';
            --
         END IF;
         --
         l_pst_columnas := l_tbl_reg_campos.NEXT(l_pst_columnas);
         --
      END LOOP;
      --
      DBMS_OUTPUT.PUT_LINE (l_campos);
      --
      l_inf_max_values := LENGTH('      INSERT INTO ' || LOWER(l_esquema) ||'.'|| LOWER(l_nom_tabla) || ' (') - LENGTH('VALUES (');
      --
      l_datos := LPAD(l_k_blanco, l_inf_max_values) || 'VALUES (';
      --
      l_pst_columnas := l_tbl_reg_campos.FIRST;
      --
      WHILE l_pst_columnas IS NOT NULL
      LOOP
         --
         l_idex_sig_valor := INSTR(l_dato_select, '~', 1);
         --
         IF l_tbl_reg_campos(l_pst_columnas).tipo_dato = 'CLOB'
         THEN
            --
            l_dato_select := SUBSTR(l_dato_select, l_idex_sig_valor + 1, LENGTH(l_dato_select));
            --
            IF l_tbl_reg_all_clobs.EXISTS(l_tbl_reg_campos(l_pst_columnas).nom_campo || l_num_reg)
            THEN
               --
               IF NOT l_tbl_reg_all_clobs(l_tbl_reg_campos(l_pst_columnas).nom_campo || l_num_reg).es_nulo
               THEN
                  --
                  l_val_clob := CHR(39);
                  --
                  l_tbl_reg_datos_clob := l_tbl_reg_all_clobs(l_tbl_reg_campos(l_pst_columnas).nom_campo || l_num_reg).reg_datos_clob;
                  --
                  l_pst_clob := l_tbl_reg_datos_clob.FIRST;
                  --
                  WHILE l_pst_clob IS NOT NULL
                  LOOP
                     --
                     l_val_clob := l_val_clob || l_tbl_reg_datos_clob(l_pst_clob).dato_clob;
                     --
                     l_pst_clob := l_tbl_reg_datos_clob.NEXT(l_pst_clob);
                     --
                  END LOOP;
                  --
                  l_val_clob := l_val_clob || CHR(39);
                  --
               ELSE
                  --
                  l_val_clob := 'NULL';
                  --
               END IF;
               --
            ELSE
               --
               l_val_clob := 'NULL';
               --
            END IF;
            --
            IF l_pst_columnas != l_tbl_reg_campos.FIRST
            THEN
               --
               l_datos := l_datos || LPAD(l_k_blanco, l_inf_max_chr) || l_val_clob;
               --
            ELSE
               --
               l_datos := l_datos || l_val_clob;
               --
            END IF;
            --
         ELSE
            --
            IF l_idex_sig_valor > 0
            THEN
               --
               l_val_columna := SUBSTR(l_dato_select, 1, l_idex_sig_valor - 1);
               --
               l_dato_select := SUBSTR(l_dato_select, l_idex_sig_valor + 1, LENGTH(l_dato_select));
               --
            ELSE
               --
               l_val_columna := l_dato_select;
               --
            END IF;
            --
            IF l_val_columna != 'NULL'
            THEN
               --
               CASE l_tbl_reg_campos(l_pst_columnas).tipo_dato
                  --
                  WHEN 'VARCHAR2'
                  THEN
                     --
                     l_val_columna := CHR(39) || l_val_columna || CHR(39);
                     --
                  WHEN 'DATE'
                  THEN
                     --
                     IF l_tbl_reg_campos(l_pst_columnas).nom_campo = 'FEC_ACTU'
                     THEN
                        --
                        l_val_columna := 'TRUNC(SYSDATE)';
                        --
                     ELSE
                        --
                        l_val_columna := REPLACE(REPLACE(l_val_columna, '-', l_k_vacio), '/', l_k_vacio);
                        --
                        l_val_columna := 'TO_DATE(' || CHR(39) || TO_CHAR(TO_DATE(l_val_columna), 'DDMMYYYY') || CHR(39) || ', '  || CHR(39) || 'DDMMYYYY' || CHR(39) || ')';
                        --
                     END IF;
                     --
                  ELSE
                     --
                     NULL;
                     --
                  --
               END CASE;
               --
            END IF;
            --
            IF l_pst_columnas != l_tbl_reg_campos.FIRST
            THEN
               --
               l_datos := l_datos || LPAD(l_k_blanco, l_inf_max_chr) || RPAD(l_val_columna, l_tbl_reg_length(l_pst_val), l_k_blanco);
               --
            ELSE
               --
               l_datos := l_datos || RPAD(l_val_columna, l_tbl_reg_length(l_pst_val), l_k_blanco);
               --
            END IF;
            --
         END IF;
         --
         IF l_pst_columnas != l_tbl_reg_campos.LAST
         THEN
            --
            l_datos := l_datos || ',' || CHR(13);
            --
         ELSE
            --
            l_datos := l_datos || ');';
            --
         END IF;
         --
         l_pst_columnas := l_tbl_reg_campos.NEXT(l_pst_columnas);
         --
      END LOOP;
      --
      DBMS_OUTPUT.PUT_LINE (l_datos);
      --
      l_exception_bloque := '      --'                    || CHR(13) ||
                            '      NULL;'               || CHR(13) ||
                            '      --'                    || CHR(13) ||
                            '   EXCEPTION'                || CHR(13) ||
                            '      --'                    || CHR(13) ||
                            '      WHEN DUP_VAL_ON_INDEX' || CHR(13) ||
                            '      THEN'                  || CHR(13) ||
                            '         --'                              ;
      --
      DBMS_OUTPUT.PUT_LINE (l_exception_bloque);
      --
      l_update := '         UPDATE ' || LOWER(l_esquema) ||'.'|| LOWER(l_nom_tabla) || ' ' || l_alias;
      --
      l_dato_select := l_tbl_reg_datos(l_pst_val);
      --
      l_pst_columnas := l_tbl_reg_campos.FIRST;
      --
      WHILE l_pst_columnas IS NOT NULL
      LOOP
         --
         l_es_where := FALSE;
         --
         l_idex_sig_valor := INSTR(l_dato_select, '~', 1);
         --
         IF l_tbl_reg_campos(l_pst_columnas).tipo_dato = 'CLOB'
         THEN
            --
            l_dato_select := SUBSTR(l_dato_select, l_idex_sig_valor + 1, LENGTH(l_dato_select));
            --
            IF l_tbl_reg_all_clobs.EXISTS(l_tbl_reg_campos(l_pst_columnas).nom_campo || l_num_reg)
            THEN
               --
               IF NOT l_tbl_reg_all_clobs(l_tbl_reg_campos(l_pst_columnas).nom_campo || l_num_reg).es_nulo
               THEN
                  --
                  l_val_clob := CHR(39);
                  --
                  l_tbl_reg_datos_clob := l_tbl_reg_all_clobs(l_tbl_reg_campos(l_pst_columnas).nom_campo || l_num_reg).reg_datos_clob;
                  --
                  l_pst_clob := l_tbl_reg_datos_clob.FIRST;
                  --
                  WHILE l_pst_clob IS NOT NULL
                  LOOP
                     --
                     l_val_clob := l_val_clob || l_tbl_reg_datos_clob(l_pst_clob).dato_clob;
                     --
                     l_pst_clob := l_tbl_reg_datos_clob.NEXT(l_pst_clob);
                     --
                  END LOOP;
                  --
                  l_val_clob := l_val_clob || CHR(39);
                  --
               ELSE
                  --
                  l_val_clob := 'NULL';
                  --
               END IF;
               --
               l_num_reg := l_num_reg + 1;
               --
            ELSE
               --
               l_val_clob := 'NULL';
               --
            END IF;
            --
            l_posicion := l_pk_reg_campos.FIRST;
            --
            WHILE  l_posicion IS NOT NULL
               AND l_es_where = FALSE
            LOOP
               --
               IF l_pk_reg_campos(l_posicion) = l_tbl_reg_campos(l_pst_columnas).nom_campo
               THEN
                  --
                  l_es_where := TRUE;
                  --
               END IF;
               --
               l_posicion := l_pk_reg_campos.NEXT(l_posicion);
               --
            END LOOP;
            --
            IF l_es_where
            THEN
               --
               IF l_where IS NULL
               THEN
                  --
                  l_where := '          WHERE ' || l_alias || '.' || RPAD(LOWER(l_tbl_reg_campos(l_pst_columnas).nom_campo), l_campo_pk_max_chr, l_k_blanco) || ' = ' || l_val_clob;
                  --
               ELSE
                  --
                  l_where := l_where                                                                                                                                                || CHR(13) ||
                             '            AND ' || l_alias || '.' || RPAD(LOWER(l_tbl_reg_campos(l_pst_columnas).nom_campo), l_campo_pk_max_chr, l_k_blanco) || ' = ' || l_val_clob              ;
                  --
               END IF;
               --
            ELSE
               --
               IF l_set IS NULL
               THEN
                  --
                  l_set := '            SET ' || l_alias || '.' || RPAD(LOWER(l_tbl_reg_campos(l_pst_columnas).nom_campo), l_campo_sin_max_chr, l_k_blanco) || ' = ' || l_val_clob;
                  --
               ELSE
                  --
                  l_set := l_set                                                                                                                                                   || CHR(13) ||
                           '                ' || l_alias || '.' || RPAD(LOWER(l_tbl_reg_campos(l_pst_columnas).nom_campo), l_campo_sin_max_chr, l_k_blanco) || ' = ' || l_val_clob              ;
                  --
               END IF;
               --
            END IF;
            --
            IF l_pst_columnas != l_tbl_reg_campos.LAST
            THEN
               --
               IF NOT l_es_where
               THEN
                  --
                  l_set := l_set || ',';
                  --
               END IF;
               --
            ELSE
               --
               l_where := l_where || ';';
               --
            END IF;
            --
         ELSE
            --
            IF l_idex_sig_valor > 0
            THEN
               --
               l_val_columna := SUBSTR(l_dato_select, 1, l_idex_sig_valor - 1);
               --
               l_dato_select := SUBSTR(l_dato_select, l_idex_sig_valor + 1, LENGTH(l_dato_select));
               --
            ELSE
               --
               l_val_columna := l_dato_select;
               --
            END IF;
            --
            IF l_val_columna != 'NULL'
            THEN
               --
               CASE l_tbl_reg_campos(l_pst_columnas).tipo_dato
                  --
                  WHEN 'VARCHAR2'
                  THEN
                     --
                     l_val_columna := CHR(39) || l_val_columna || CHR(39);
                     --
                  WHEN 'DATE'
                  THEN
                     --
                     IF l_tbl_reg_campos(l_pst_columnas).nom_campo = 'FEC_ACTU'
                     THEN
                        --
                        l_val_columna := 'TRUNC(SYSDATE)';
                        --
                     ELSE
                        --
                        l_val_columna := REPLACE(REPLACE(l_val_columna, '-', l_k_vacio), '/', l_k_vacio);
                        --
                        l_val_columna := 'TO_DATE(' || CHR(39) || TO_CHAR(TO_DATE(l_val_columna), 'DDMMYYYY') || CHR(39) || ', '  || CHR(39) || 'DDMMYYYY' || CHR(39) || ')';
                        --
                     END IF;
                     --
                  ELSE
                     --
                     NULL;
                     --
                  --
               END CASE;
               --
            END IF;
            --
            l_posicion := l_pk_reg_campos.FIRST;
            --
            WHILE  l_posicion IS NOT NULL
               AND l_es_where = FALSE
            LOOP
               --
               IF l_pk_reg_campos(l_posicion) = l_tbl_reg_campos(l_pst_columnas).nom_campo
               THEN
                  --
                  l_es_where := TRUE;
                  --
               END IF;
               --
               l_posicion := l_pk_reg_campos.NEXT(l_posicion);
               --
            END LOOP;
            --
            IF l_es_where
            THEN
               --
               IF l_where IS NULL
               THEN
                  --
                  l_where := '          WHERE ' || l_alias || '.' || RPAD(LOWER(l_tbl_reg_campos(l_pst_columnas).nom_campo), l_campo_pk_max_chr, l_k_blanco) || ' = ' || l_val_columna;
                  --
               ELSE
                  --
                  l_where := l_where                                                                                                                                                  || CHR(13) ||
                             '            AND ' || l_alias || '.' || RPAD(LOWER(l_tbl_reg_campos(l_pst_columnas).nom_campo), l_campo_pk_max_chr, l_k_blanco) || ' = ' || l_val_columna              ;
                  --
               END IF;
               --
            ELSE
               --
               IF l_set IS NULL
               THEN
                  --
                  l_set := '            SET ' || l_alias || '.' || RPAD(LOWER(l_tbl_reg_campos(l_pst_columnas).nom_campo), l_campo_sin_max_chr, l_k_blanco) || ' = ' || RPAD(l_val_columna, l_tbl_reg_length(l_pst_val), l_k_blanco);
                  --
               ELSE
                  --
                  l_set := l_set                                                                                                                                                                                          || CHR(13) ||
                           '                ' || l_alias || '.' || RPAD(LOWER(l_tbl_reg_campos(l_pst_columnas).nom_campo), l_campo_sin_max_chr, l_k_blanco) || ' = ' || RPAD(l_val_columna, l_tbl_reg_length(l_pst_val), l_k_blanco)              ;
                  --
               END IF;
               --
            END IF;
            --
            IF l_pst_columnas != l_tbl_reg_campos.LAST
            THEN
               --
               IF NOT l_es_where
               THEN
                  --
                  l_set := l_set || ',';
                  --
               END IF;
               --
            ELSE
               --
               l_where := l_where || ';';
               --
            END IF;
            --
         END IF;
         --
         l_pst_columnas := l_tbl_reg_campos.NEXT(l_pst_columnas);
         --
      END LOOP;
      --
      IF    SUBSTR(l_set, LENGTH(l_set)) = ','
         OR SUBSTR(l_set, LENGTH(l_set)) = ' ,'
         OR SUBSTR(l_set, LENGTH(l_set)) = ' '
      THEN
         --
         l_set := SUBSTR(l_set, 1, LENGTH(l_set) - 1);
         --
      END IF;
      --
      l_update := l_update || CHR(13) ||
                  l_set                 ;
      --
      l_update := l_update || CHR(13) ||
                  l_where               ;
      --
      DBMS_OUTPUT.PUT_LINE (l_update);
      --
      l_exception_bloque := '         --'                                                          || CHR(13) ||
                            '         IF SQL%ROWCOUNT = 1'                                         || CHR(13) ||
                            '         THEN'                                                        || CHR(13) ||
                            '            --'                                                       || CHR(13) ||
                            '            DBMS_OUTPUT.PUT_LINE (''update EXECUTADO COM SUCESSO'');' || CHR(13) ||
                            '            --'                                                       || CHR(13) ||
                            '            NULL;'                                                  || CHR(13) ||
                            '            --'                                                       || CHR(13) ||
                            '         ELSE'                                                        || CHR(13) ||
                            '            --'                                                       || CHR(13) ||
                            '            DBMS_OUTPUT.PUT_LINE (''ERRO ''||SQLERRM);'               || CHR(13) ||
                            '            --'                                                       || CHR(13) ||
                            '         END IF;'                                                     || CHR(13) ||
                            '         --'                                                          || CHR(13) ||
                            '   END;'                                                                           ;
      --
      DBMS_OUTPUT.PUT_LINE (l_exception_bloque);
      --
      l_pst_val := l_tbl_reg_datos.NEXT(l_pst_val);
      --
   END LOOP;
   --
   l_fin := '   --'                                                   || CHR(13) ||
            '   NULL;'                                              || CHR(13) ||
            '   --'                                                   || CHR(13) ||
            'EXCEPTION'                                               || CHR(13) ||
            '   --'                                                   || CHR(13) ||
            '   WHEN OTHERS'                                          || CHR(13) ||
            '   THEN'                                                 || CHR(13) ||
            '      --'                                                || CHR(13) ||
            '      DBMS_OUTPUT.PUT_LINE (''SQLCODE = '' || SQLCODE);' || CHR(13) ||
            '      DBMS_OUTPUT.PUT_LINE (''SQLERRM = '' || SQLERRM);' || CHR(13) ||
            '      --'                                                || CHR(13) ||
            '   --'                                                   || CHR(13) ||
            'END;'                                                    || CHR(13) ||
            '/'                                                                    ;
   --
   DBMS_OUTPUT.PUT_LINE (l_fin);
   --
EXCEPTION
   --
   WHEN NOM_TABLA_NULL
   THEN
      --
      DBMS_OUTPUT.PUT_LINE ('--------------------------------------------'            );
      DBMS_OUTPUT.PUT_LINE ('*********** NOMBRE DE TABLA NULO ***********'            );
      DBMS_OUTPUT.PUT_LINE ('--------------------------------------------' || CHR (13));
      --
      DBMS_OUTPUT.PUT_LINE ('POR FAVOR INGRESE EL NOMBRE DE LA TABLA');
      --
   --
   WHEN TABLA_NO_FOUND
   THEN
      --
      DBMS_OUTPUT.PUT_LINE ('-------------------------------------------'            );
      DBMS_OUTPUT.PUT_LINE ('*********** TABLA NO ENCONTRADA ***********'            );
      DBMS_OUTPUT.PUT_LINE ('-------------------------------------------' || CHR (13));
      --
      DBMS_OUTPUT.PUT_LINE ('LA TABLA "' || l_nom_tabla || '" NO EXISTE, NO SE ENCUENTRA');
      --
   --
   WHEN TABLA_SIN_PK
   THEN
      --
      DBMS_OUTPUT.PUT_LINE ('------------------------------------------------'            );
      DBMS_OUTPUT.PUT_LINE ('*********** TABLA SIN LLAVE PRIMARIA ***********'            );
      DBMS_OUTPUT.PUT_LINE ('------------------------------------------------' || CHR (13));
      --
      DBMS_OUTPUT.PUT_LINE ('LA TABLA "' || l_nom_tabla || '" NO POSEE LLAVE PRIMARIA');
      --
   --
   WHEN TABLA_SIN_S_PK
   THEN
      --
      DBMS_OUTPUT.PUT_LINE ('---------------------------------------------------'            );
      DBMS_OUTPUT.PUT_LINE ('************* TABLA ES LLAVE PRIMARIA *************'            );
      DBMS_OUTPUT.PUT_LINE ('---------------------------------------------------' || CHR (13));
      --
      DBMS_OUTPUT.PUT_LINE ('TODOS LOS CAMPOS DE LA TABLA "' || l_nom_tabla || '" SON LLAVE PRIMARIA');
      --
   --
   WHEN OTHERS
   THEN
      --
      DBMS_OUTPUT.PUT_LINE ('-------------------------------------------------------------'            );
      DBMS_OUTPUT.PUT_LINE ('******************** CONTROL DE ERRORES *********************'            );
      DBMS_OUTPUT.PUT_LINE ('-------------------------------------------------------------' || CHR (13));
      --
      DBMS_OUTPUT.PUT_LINE ('Codigo  Error = ' || SQLCODE            );
      DBMS_OUTPUT.PUT_LINE ('Mensaje Error = ' || SQLERRM || CHR (13));
      --
      DBMS_OUTPUT.PUT_LINE ('----------------------------------------------------------------------------------' || CHR (13));
      --
      DBMS_OUTPUT.PUT_LINE ('Traza Del Error = '               );
      DBMS_OUTPUT.PUT_LINE (DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
      --
      DBMS_OUTPUT.PUT_LINE ('----------------------------------------------------------------------------------'            );
      --
   --
END;
