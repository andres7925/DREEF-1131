DECLARE
   --
   /* ----------
   || CURSORES
   */ ----------
   --
   CURSOR lc_columas (pc_nom_tabla VARCHAR2)
   IS
      SELECT UPPER(acc.table_name)          nom_tabla  ,
             UPPER(cdt.comments)            comen_tabla,
             UPPER(atc.column_name)         nom_campo  ,
             UPPER(atc.data_type)           tip_dato   ,
             DECODE (atc.data_type     ,
                     'NUMBER'          ,
                     atc.data_precision,
                     'VARCHAR2'        ,
                     atc.char_length   ,
                     'DATE'            ,
                     8                 )   tamanio    ,
             NVL(UPPER(atc.nullable), 'S') nulable    ,
             UPPER(acc.comments)           comen_colum
        FROM all_tab_columns  atc,
             all_col_comments acc,
             all_tab_comments cdt
       WHERE UPPER(acc.table_name) = UPPER(pc_nom_tabla)
         AND atc.table_name        = acc.table_name
         AND atc.column_name       = acc.column_name
         AND cdt.table_name        = atc.table_name
         AND UPPER(atc.owner)      = UPPER('TRON2000')
         AND atc.owner             = acc.owner
         AND atc.owner             = cdt.owner
       ORDER BY atc.column_id;
   --
   CURSOR lc_llave_primaria (pc_nom_tabla VARCHAR2)
   IS 
      SELECT ac.constraint_name llave_primaria,
             acc.column_name    nom_columna
        FROM all_constraints ac 
        JOIN all_cons_columns acc ON ac.owner = acc.owner 
         AND ac.constraint_name = acc.constraint_name
       WHERE ac.constraint_type = 'P'
         AND ac.table_name = UPPER(pc_nom_tabla)   
         AND ac.owner = 'TRON2000'
         AND ac.status = 'ENABLED' 
    ORDER BY acc.position;   
   --
   CURSOR lc_indices (pc_nom_tabla VARCHAR2,
                      pc_indice_pk VARCHAR2)
   IS
      SELECT a.index_name nombre_indice
        FROM all_indexes a
       WHERE UPPER(a.table_name)  = UPPER(pc_nom_tabla)
         AND UPPER(a.index_name) != UPPER(pc_indice_pk)
         AND UPPER(a.owner)       = UPPER('TRON2000')
       ORDER BY a.index_name;
   --
   CURSOR lc_colum_indice (pc_nom_indice VARCHAR2)
   IS
      SELECT a.column_name
        FROM all_ind_columns a
       WHERE a.index_name = UPPER(pc_nom_indice)
       ORDER BY a.column_position;
   --
   /* ----------
   || REGISTROS
   */ ----------
   --
   TYPE reg_campos_tabla IS RECORD (nom_campo   VARCHAR2(0030),
                                    tip_dato    VARCHAR2(0008),
                                    tamanio     NUMBER        ,
                                    nulable     VARCHAR2(0002),
                                    comen_colum VARCHAR2(5000));
   --
   l_reg_campos_tabla    reg_campos_tabla;
   --
   TYPE tabla_reg_campos IS TABLE OF l_reg_campos_tabla%TYPE INDEX BY BINARY_INTEGER;
   TYPE pk_reg_campos    IS TABLE OF VARCHAR2(30)            INDEX BY BINARY_INTEGER;
   TYPE in_reg_campos    IS TABLE OF VARCHAR2(30)            INDEX BY BINARY_INTEGER;
   --
   l_tb_reg_campos       tabla_reg_campos;
   l_pk_reg_campos       pk_reg_campos   ;
   l_in_reg_campos       pk_reg_campos   ;
   --
   l_reg_columas         lc_columas       %ROWTYPE;
   l_pk_columas          lc_llave_primaria%ROWTYPE;
   l_in_columas          lc_indices       %ROWTYPE;
   l_col_indice          lc_colum_indice  %ROWTYPE;
   --
   /* ----------
   || VARIABLES
   */ ----------
   --
   l_nom_tabla    VARCHAR2(00030)   ;
   l_nom_pk       VARCHAR2(00030)   ;
   l_comen_tabla  VARCHAR2(05000)   ;
   l_comen_campo  VARCHAR2(05000)   ;
   l_numero_pst   VARCHAR2(00003)   ;
   l_parametro    VARCHAR2(05000)   ;
   --
   l_sql_declare  VARCHAR2(32000)   ;
   l_sql_scripts  VARCHAR2(32000)   ;
   l_sql_execute  VARCHAR2(32000)   ;
   --
   l_sql_create   VARCHAR2(32000)   ;
   l_sql_pk       VARCHAR2(32000)   ;
   l_sql_commen   VARCHAR2(32000)   ;
   l_sql_indice   VARCHAR2(32000)   ;
   --
   l_posicion     BINARY_INTEGER    ;
   --
   l_ini_max_ch1  NUMBER            ;
   l_ini_max_ch2  NUMBER            ;
   l_fin_max_chr  NUMBER            ;
   l_tip_max_chr  NUMBER            ;
   l_tam_max_chr  NUMBER            ;
   l_pk_max_chr   NUMBER            ;
   l_pki_max_ch1  NUMBER            ;
   l_pki_max_ch2  NUMBER            ;
   l_com_max_chr  NUMBER            ;
   l_ind_max_chr  NUMBER            ;
   --
   NOM_TABLA_NULL EXCEPTION         ;
   TABLA_NO_FOUND EXCEPTION         ;
   TABLA_SIN_PK   EXCEPTION         ;
   --
   /* -----------
   || CONSTANTES
   */ -----------
   --
   l_k_vacio  CONSTANT VARCHAR2(1) := '' ;
   l_k_blanco CONSTANT VARCHAR2(1) := ' ';
   l_k_cero   CONSTANT VARCHAR2(1) := '0';
   --
BEGIN
   --
   -- Implementa para que no ejecute error en la impresion de datos
   --
   DBMS_OUTPUT.ENABLE (10000000000);
   --
   l_nom_tabla := UPPER('G0200002');
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
   IF lc_columas%ISOPEN
   THEN
      --
      CLOSE lc_columas;
      --
   END IF;
   --
   OPEN lc_columas (pc_nom_tabla => l_nom_tabla);
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
   l_nom_tabla   := l_reg_columas.nom_tabla  ;
   l_comen_tabla := l_reg_columas.comen_tabla;
   --
   l_posicion := 1;
   --
   l_fin_max_chr := 0;
   l_tip_max_chr := 0;
   l_tam_max_chr := 0;
   l_com_max_chr := 0;
   --
   WHILE lc_columas%FOUND
   LOOP
      --
      l_tb_reg_campos(l_posicion).nom_campo   := l_reg_columas.nom_campo  ;
      l_tb_reg_campos(l_posicion).tip_dato    := l_reg_columas.tip_dato   ;
      l_tb_reg_campos(l_posicion).tamanio     := l_reg_columas.tamanio    ;
      l_tb_reg_campos(l_posicion).nulable     := l_reg_columas.nulable    ;
      l_tb_reg_campos(l_posicion).comen_colum := l_reg_columas.comen_colum;
      --
      IF LENGTH(l_reg_columas.nom_campo) > l_fin_max_chr
      THEN
         --
         l_fin_max_chr := LENGTH(l_reg_columas.nom_campo);
         --
      END IF;
      --
      IF LENGTH(l_tb_reg_campos(l_posicion).tip_dato) > l_tip_max_chr
      THEN
         --
         l_tip_max_chr := LENGTH(l_reg_columas.tip_dato);
         --
      END IF;
      --
      IF LENGTH(l_tb_reg_campos(l_posicion).tamanio) > l_tam_max_chr
      THEN
         --
         l_tam_max_chr := LENGTH(l_reg_columas.tamanio);
         --
      END IF;
      --
      l_comen_campo := l_tb_reg_campos(l_posicion).comen_colum || '''''''';
      --
      IF LENGTH(l_comen_campo) > l_com_max_chr
      THEN
         --
         l_com_max_chr := LENGTH(l_comen_campo);
         --
      END IF;
      --
      l_posicion := l_posicion + 1;
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
   OPEN lc_llave_primaria (pc_nom_tabla => l_nom_tabla);
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
   l_nom_pk := l_pk_columas.llave_primaria;
   --
   l_posicion   := 1;
   l_pk_max_chr := 0;
   --
   WHILE lc_llave_primaria%FOUND
   LOOP
      --
      l_pk_reg_campos(l_posicion) := l_pk_columas.nom_columna;
      --
      IF LENGTH(l_pk_columas.nom_columna) > l_pk_max_chr
      THEN
         --
         l_pk_max_chr := LENGTH(l_pk_columas.nom_columna);
         --
      END IF;
      --
      l_posicion := l_posicion + 1;
      --
      FETCH lc_llave_primaria INTO l_pk_columas;
      --
   END LOOP;
   --
   IF lc_indices%ISOPEN
   THEN
      --
      CLOSE lc_indices;
      --
   END IF;
   --
   OPEN lc_indices (pc_nom_tabla => l_nom_tabla,
                    pc_indice_pk => l_nom_pk   );
   --
   FETCH lc_indices INTO l_in_columas;
   --
   l_posicion    := 1;
   l_ind_max_chr := 0;
   --
   WHILE lc_indices%FOUND
   LOOP
      --
      l_in_reg_campos(l_posicion) := l_in_columas.nombre_indice;
      --
      IF LENGTH(l_in_columas.nombre_indice) > l_ind_max_chr
      THEN
         --
         l_ind_max_chr := LENGTH(l_in_columas.nombre_indice);
         --
      END IF;
      --
      l_posicion := l_posicion + 1;
      --
      FETCH lc_indices INTO l_in_columas;
      --
   END LOOP;
   --
   l_sql_declare := 'DECLARE'                                                              || CHR(13) ||
                    '   --'                                                                || CHR(13) ||
                    '   CURSOR c_cursor_t'                                                 || CHR(13) ||
                    '   IS'                                                                || CHR(13) ||
                    '      SELECT COUNT (*)'                                               || CHR(13) ||
                    '        FROM all_tab_columns t'                                       || CHR(13) ||
                    '       WHERE UPPER(t.table_name) = UPPER(''' || l_nom_tabla || ''');' || CHR(13) ||
                    '   --'                                                                || CHR(13) ||
                    '   CURSOR c_cursor_i'                                                 || CHR(13) ||
                    '   IS'                                                                || CHR(13) ||
                    '      SELECT COUNT (*)'                                               || CHR(13) ||
                    '        FROM all_indexes t'                                           || CHR(13) ||
                    '       WHERE UPPER(t.index_name) = UPPER(''' || l_nom_tabla || ''');' || CHR(13) ||
                    '   --'                                                                || CHR(13) ||
                    '   l_count             NUMBER        ;'                               || CHR(13) ||
                    '   l_hacer             BOOLEAN       ;'                               || CHR(13) ||
                    '   --'                                                                || CHR(13) ||
                    '   l_drop_table        VARCHAR2(0030);'                               || CHR(13) ||
                    '   l_create_table      VARCHAR2(6000);'                               || CHR(13) ||
                    '   l_alter_pk          VARCHAR2(2000);'                               || CHR(13) ||
                    '   --'                                                                || CHR(13) ||
                    '   l_comentario_tabla  VARCHAR2(2000);'                                            ;
   --
   l_posicion := l_tb_reg_campos.FIRST;
   --
   WHILE l_posicion IS NOT NULL
   LOOP
      --
      IF l_posicion < 10
      THEN
         --
         l_numero_pst := '00' || TO_CHAR(l_posicion);
         --
      ELSIF l_posicion BETWEEN 10
                           AND 99
      THEN
         --
         l_numero_pst := '0' || TO_CHAR(l_posicion);
         --
      ELSE
         --
         l_numero_pst := TO_CHAR(l_posicion);
         --
      END IF;
      --
      l_sql_declare := l_sql_declare                                               || CHR(13) ||
                       '   l_comentario_col' || l_numero_pst || ' VARCHAR2(2000);'              ;
      --
      l_posicion := l_tb_reg_campos.NEXT(l_posicion);
      --
   END LOOP;
   --
   l_sql_declare := l_sql_declare                            || CHR(13) ||
                    '   --'                                  || CHR(13) ||
                    '   l_drop_index        VARCHAR2(2000);' || CHR(13) ||
                    '   --'                                               ;
   --
   IF l_in_reg_campos.COUNT > 0
   THEN
      --
      l_posicion := l_in_reg_campos.FIRST;
      --
      WHILE l_posicion IS NOT NULL
      LOOP
         --
         IF l_posicion < 10
         THEN
            --
            l_numero_pst := '0' || TO_CHAR(l_posicion);
            --
         ELSE
            --
            l_numero_pst := TO_CHAR(l_posicion);
            --
         END IF;
         --
         l_sql_declare := l_sql_declare                                                || CHR(13) ||
                          '   l_create_index' || l_numero_pst || '    VARCHAR2(2000);'              ;
         --
         l_posicion := l_in_reg_campos.NEXT(l_posicion);
         --
      END LOOP;
      --
      l_sql_declare := l_sql_declare || CHR(13) ||
                       '   --'                    ;
      --
   END IF;
   --
   l_sql_scripts := 'BEGIN'                                                    || CHR(13) ||
                    '   --'                                                    || CHR(13) ||
                    '   -- Crear los scripts para la tablas'                   || CHR(13) ||
                    '   --'                                                    || CHR(13) ||
                    '   l_drop_table := ''DROP TABLE ' || l_nom_tabla || ''';' || CHR(13) ||
                    '   l_drop_index := ''DROP INDEX ' || l_nom_tabla || ''';' || CHR(13) ||
                    '   --'                                                                 ;
   --
   l_sql_create := '   l_create_table := ''CREATE TABLE ' || l_nom_tabla || ' (';
   --
   l_ini_max_ch1 := LENGTH('   l_create_table := ');
   l_ini_max_ch2 := LENGTH('CREATE TABLE ' || l_nom_tabla || ' (');
   --
   l_posicion := l_tb_reg_campos.FIRST;
   --
   WHILE l_posicion IS NOT NULL
   LOOP
      --
      l_parametro := RPAD(UPPER(l_tb_reg_campos(l_posicion).nom_campo), l_fin_max_chr, l_k_blanco) || l_k_blanco;
      --
      IF l_posicion != l_tb_reg_campos.FIRST
      THEN
         --
         l_parametro := LPAD(l_k_blanco, l_ini_max_ch1) || '''' || LPAD(l_k_blanco, l_ini_max_ch2) || l_parametro;
         --
      END IF;
      --
      l_parametro := l_parametro || RPAD(UPPER(l_tb_reg_campos(l_posicion).tip_dato), l_tip_max_chr, l_k_blanco);
      --
      IF     l_tb_reg_campos(l_posicion).tamanio IS NOT NULL
         AND l_tb_reg_campos(l_posicion).tip_dato != 'DATE'
      THEN
         --
         l_parametro := l_parametro || '(' || LPAD(UPPER(TO_CHAR(l_tb_reg_campos(l_posicion).tamanio)), l_tam_max_chr, l_k_cero) || ')' || l_k_blanco;
         --
      ELSE
         --
         l_parametro := l_parametro || RPAD(l_k_blanco, l_tam_max_chr) || l_k_blanco || l_k_blanco || l_k_blanco;
         --
      END IF;
      --
      IF l_tb_reg_campos(l_posicion).nulable = 'N'
      THEN
         --
         l_parametro := l_parametro || 'NOT NULL';
         --
      ELSE
         --
         l_parametro := l_parametro || RPAD(l_k_blanco, 8);
         --
      END IF;
      --
      IF l_posicion != l_tb_reg_campos.LAST
      THEN
         --
         l_sql_create := l_sql_create || l_parametro || ','' || CHR (13) ||' || CHR(13);
         --
      ELSE
         --
         l_sql_create := l_sql_create || l_parametro || ')''               ;';
         --
      END IF;
      --
      l_posicion := l_tb_reg_campos.NEXT(l_posicion);
      --
   END LOOP;
   --
   l_sql_scripts := l_sql_scripts || CHR(13) ||
                    l_sql_create  || CHR(13) ||
                    '   --'                    ;
   --
   l_sql_pk := '   l_alter_pk := ''ALTER TABLE ' || l_nom_tabla || ' ADD PRIMARY KEY (';
   --
   l_pki_max_ch1 := LENGTH('   l_alter_pk := ');
   l_pki_max_ch2 := LENGTH('ALTER TABLE ' || l_nom_tabla || ' ADD PRIMARY KEY (');
   --
   l_posicion := l_pk_reg_campos.FIRST;
   --
   WHILE l_posicion IS NOT NULL
   LOOP
      --
      l_parametro := RPAD(UPPER(l_pk_reg_campos(l_posicion)), l_pk_max_chr, l_k_blanco);
      --
      IF l_posicion != l_pk_reg_campos.FIRST
      THEN
         --
         l_parametro := LPAD(l_k_blanco, l_pki_max_ch1) || '''' || LPAD(l_k_blanco, l_pki_max_ch2) || l_parametro;
         --
      END IF;
      --
      IF l_posicion != l_pk_reg_campos.LAST
      THEN
         --
         l_sql_pk := l_sql_pk || l_parametro || ','' || CHR (13) ||' || CHR(13);
         --
      ELSE
         --
         l_sql_pk := l_sql_pk || l_parametro || ')''               ;';
         --
      END IF;
      --
      l_posicion := l_pk_reg_campos.NEXT(l_posicion);
      --
   END LOOP;
   --
   l_sql_scripts := l_sql_scripts || CHR(13) ||
                    l_sql_pk      || CHR(13) ||
                    '   --'                    ;
   --
   IF l_in_reg_campos.COUNT > 0
   THEN
      --
      l_posicion := l_in_reg_campos.FIRST;
      --
      WHILE l_posicion IS NOT NULL
      LOOP
         --
         IF l_posicion < 10
         THEN
            --
            l_numero_pst := '0' || TO_CHAR(l_posicion);
            --
         ELSE
            --
            l_numero_pst := TO_CHAR(l_posicion);
            --
         END IF;
         --
         l_parametro := '   l_create_index' || l_numero_pst || ' := ''CREATE INDEX ' || RPAD(UPPER(l_in_reg_campos(l_posicion)), l_ind_max_chr, l_k_blanco) || ' ON ' || l_nom_tabla || ' (';
         --
         FOR l_reg_colum IN lc_colum_indice (pc_nom_indice => l_in_reg_campos(l_posicion))
         LOOP
            --
            l_parametro := l_parametro || l_reg_colum.column_name || ', ';
            --
         END LOOP;
         --
         l_parametro := l_parametro || ')'';';
         --
         l_parametro := REPLACE(l_parametro, ', )'';', ')'';');
         --
         IF l_posicion = l_in_reg_campos.FIRST
         THEN
            --
            l_sql_indice := l_parametro;
            --
         ELSE
            --
            l_sql_indice := l_sql_indice || CHR(13) ||
                            l_parametro               ;
            --
         END IF;
         --
         l_posicion := l_in_reg_campos.NEXT(l_posicion);
         --
      END LOOP;
      --
      l_sql_scripts := l_sql_scripts || CHR(13) ||
                       l_sql_indice  || CHR(13) ||
                       '   --'                    ;
      --
   END IF;
   --
   l_sql_commen := '   l_comentario_tabla := ''COMMENT ON TABLE ' || l_nom_tabla || ' IS ''''' || l_comen_tabla || ''''''';' || CHR(13) ||
                   '   --'                                                                                                                ;
   --
   l_posicion := l_tb_reg_campos.FIRST;
   --
   WHILE l_posicion IS NOT NULL
   LOOP
      --
      IF l_posicion < 10
      THEN
         --
         l_numero_pst := '00' || TO_CHAR(l_posicion);
         --
      ELSIF l_posicion BETWEEN 10
                           AND 99
      THEN
         --
         l_numero_pst := '0' || TO_CHAR(l_posicion);
         --
      ELSE
         --
         l_numero_pst := TO_CHAR(l_posicion);
         --
      END IF;
      --
      l_comen_campo := l_tb_reg_campos(l_posicion).comen_colum || '''''''';
      --
      l_parametro := '   l_comentario_col' || l_numero_pst || ' := ''COMMENT ON COLUMN ' || l_nom_tabla || '.' || RPAD(UPPER(l_tb_reg_campos(l_posicion).nom_campo), l_fin_max_chr, l_k_blanco) ||
                     ' IS ''''' || RPAD(UPPER(l_comen_campo), l_com_max_chr, l_k_blanco) || ';';
      --
      l_sql_commen := l_sql_commen || CHR(13) ||
                      l_parametro               ;
      --
      l_posicion := l_tb_reg_campos.NEXT(l_posicion);
      --
   END LOOP;
   --
   l_sql_scripts := l_sql_scripts || CHR(13) ||
                    l_sql_commen  || CHR(13) ||
                    '   --'                    ;
   --
   l_sql_execute := '   IF c_cursor_t%ISOPEN'                   || CHR(13) ||
                    '   THEN'                                   || CHR(13) ||
                    '      --'                                  || CHR(13) ||
                    '      CLOSE c_cursor_t;'                   || CHR(13) ||
                    '      --'                                  || CHR(13) ||
                    '   END IF;'                                || CHR(13) ||
                    '   --'                                     || CHR(13) ||
                    '   l_hacer := TRUE;'                       || CHR(13) ||
                    '   --'                                     || CHR(13) ||
                    '   WHILE l_hacer'                          || CHR(13) ||
                    '   LOOP'                                   || CHR(13) ||
                    '      --'                                  || CHR(13) ||
                    '      OPEN c_cursor_t;'                    || CHR(13) ||
                    '      --'                                  || CHR(13) ||
                    '      FETCH c_cursor_t INTO l_count;'      || CHR(13) ||
                    '      --'                                  || CHR(13) ||
                    '      CLOSE c_cursor_t;'                   || CHR(13) ||
                    '      --'                                  || CHR(13) ||
                    '      IF l_count != 0'                     || CHR(13) ||
                    '      THEN'                                || CHR(13) ||
                    '         --'                               || CHR(13) ||
                    '         EXECUTE IMMEDIATE l_drop_table;'  || CHR(13) ||
                    '         --'                               || CHR(13) ||
                    '      ELSE'                                || CHR(13) ||
                    '         --'                               || CHR(13) ||
                    '         l_hacer := FALSE;'                || CHR(13) ||
                    '         --'                               || CHR(13) ||
                    '      END IF;'                             || CHR(13) ||
                    '      --'                                  || CHR(13) ||
                    '   END LOOP;'                              || CHR(13) ||
                    '   --'                                     || CHR(13) ||
                    '   EXECUTE IMMEDIATE l_create_table     ;' || CHR(13) ||
                    '   --'                                     || CHR(13) ||
                    '   EXECUTE IMMEDIATE l_alter_pk         ;' || CHR(13) ||
                    '   --'                                                  ;
   --
   IF l_in_reg_campos.COUNT > 0
   THEN
      --
      l_posicion := l_in_reg_campos.FIRST;
      --
      WHILE l_posicion IS NOT NULL
      LOOP
         --
         IF l_posicion < 10
         THEN
            --
            l_numero_pst := '0' || TO_CHAR(l_posicion);
            --
         ELSE
            --
            l_numero_pst := TO_CHAR(l_posicion);
            --
         END IF;
         --
         l_parametro := '   EXECUTE IMMEDIATE l_create_index' || l_numero_pst || '   ;';
         --
         IF l_posicion = l_in_reg_campos.FIRST
         THEN
            --
            l_sql_indice := l_parametro;
            --
         ELSE
            --
            l_sql_indice := l_sql_indice || CHR(13) ||
                            l_parametro               ;
            --
         END IF;
         --
         l_posicion := l_in_reg_campos.NEXT(l_posicion);
         --
      END LOOP;
      --
      l_sql_execute := l_sql_execute || CHR(13) ||
                       l_sql_indice  || CHR(13) ||
                       '   --'                    ;
      --
   END IF;
   --
   l_sql_execute := l_sql_execute                               || CHR(13) ||
                    '   EXECUTE IMMEDIATE l_comentario_tabla ;' || CHR(13) ||
                    '   --'                                                  ;
   --
   l_posicion := l_tb_reg_campos.FIRST;
   --
   WHILE l_posicion IS NOT NULL
   LOOP
      --
      IF l_posicion < 10
      THEN
         --
         l_numero_pst := '00' || TO_CHAR(l_posicion);
         --
      ELSIF l_posicion BETWEEN 10
                           AND 99
      THEN
         --
         l_numero_pst := '0' || TO_CHAR(l_posicion);
         --
      ELSE
         --
         l_numero_pst := TO_CHAR(l_posicion);
         --
      END IF;
      --
      l_sql_execute := l_sql_execute || CHR(13) ||
                       '   EXECUTE IMMEDIATE l_comentario_col' || l_numero_pst || ';';
      --
      l_posicion := l_tb_reg_campos.NEXT(l_posicion);
      --
   END LOOP;
   --
   l_sql_execute := l_sql_execute                           || CHR(13) ||
                    '   --'                                 || CHR(13) ||
                    '   OPEN c_cursor_i;'                   || CHR(13) ||
                    '   --'                                 || CHR(13) ||
                    '   FETCH c_cursor_i INTO l_count;'     || CHR(13) ||
                    '   --'                                 || CHR(13) ||
                    '   CLOSE c_cursor_i;'                  || CHR(13) ||
                    '   --'                                 || CHR(13) ||
                    '   IF l_count != 0'                    || CHR(13) ||
                    '   THEN'                               || CHR(13) ||
                    '      --'                              || CHR(13) ||
                    '      EXECUTE IMMEDIATE l_drop_index;' || CHR(13) ||
                    '      --'                              || CHR(13) ||
                    '   END IF;'                            || CHR(13) ||
                    '   --'                                 || CHR(13) ||
                    'END;'                                  || CHR(13) ||
                    '/'                                     || CHR(13) ||
                    'EXIT'                                                   ;
   --
   DBMS_OUTPUT.PUT_LINE (l_sql_declare);
   DBMS_OUTPUT.PUT_LINE (l_sql_scripts);
   DBMS_OUTPUT.PUT_LINE (l_sql_execute);
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
 
