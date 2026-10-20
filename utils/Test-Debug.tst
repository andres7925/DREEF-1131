PL/SQL Developer Test script 3.0
88

declare
 --
 l_parameter_d       NLS_SESSION_PARAMETERS.VALUE%TYPE;
 l_parameter_n       NLS_SESSION_PARAMETERS.VALUE%TYPE; 
 --
 lv_nom_tar     tron2000.g0200001.nom_tar%TYPE:= '';
 -- 
 lv_tip_tar     tron2000.g0200001.tip_tar    %TYPE:= '2'; 
 lv_mca_directo tron2000.g0200001.mca_directo%TYPE;
 lv_tip_prg     tron2000.g0200001.tip_prg    %TYPE;
 lv_nom_prg     tron2000.g0200001.nom_prg    %TYPE;
 --
BEGIN
   --
   --- dbms_profiler.start_profiler('MENAIG_' || sysdate);
   --
   SELECT VALUE
     INTO l_parameter_d
     FROM NLS_SESSION_PARAMETERS
    WHERE PARAMETER = 'NLS_DATE_FORMAT';
   --
   SELECT VALUE
     INTO l_parameter_n
     FROM NLS_SESSION_PARAMETERS
    WHERE PARAMETER = 'NLS_NUMERIC_CHARACTERS';
   --
   -- realizareiamos la alteracion de los formatos de fecha y numero para que reciba valores
   EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT = ''' || 'dd/MM/yyyy' || '''';  -- HH24:MI:ss
   EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS = ''' || '.,' || '''';
   --
   tron2000.trn_k_global.asigna ('COD_USR' , 'TRONMW01');   --    TRON2000   TRONQA44
   tron2000.trn_k_global.asigna ('COD_USER' , 'TRONMW01'); 
   tron2000.trn_k_global.asigna ('CMP_VAL' , 1);--50);
   -- 
   tron2000.trn_k_global.asigna ('COD_IDIOMA' , 'ES');   
   tron2000.trn_k_global.asigna ('COD_INSTALACION' , 'TRN');
   --
   -- DATOS DE LA TAREA
   tron2000.trn_k_global.asigna('JBCOD_CIA','5');         
   tron2000.trn_k_global.asigna('COD_CIA','5');                
   tron2000.trn_k_global.asigna('JBNUUMA_ORIG','DGOLIVA'); -- Para cod_cia = 5 usar a DGOLIVA, Para cod_cia = 8 usar a DROJASB, Para cod_cia = 7 usar a BEDOYAG
   tron2000.trn_k_global.asigna('JBNUUMA_DEST','GHANDR4');
   tron2000.trn_k_global.asigna('JBNOMBRE','ANDRES'); 
   tron2000.trn_k_global.asigna('JBAPE1','GOMEZ');
   tron2000.trn_k_global.asigna('JBAPE2','HERNANDEZ');
   --
   tron2000.trn_k_global.asigna('JBEMAIL','agomez@inforcol.com');    
   tron2000.trn_k_global.asigna('JBTIP_DOCUM','PAS');  
   tron2000.trn_k_global.asigna('JBCOD_DOCUM','12101000000000000025');  --USUARIO 1 de la cia 50, actividad 001(Asegurado)
   --
   tron2000.trn_k_global.asigna('JBIND_CREA_CAJERO','S');  
   tron2000.trn_k_global.asigna('JBIND_CREA_TRAMITADOR','S');   
   tron2000.trn_k_global.asigna('JBIND_CREA_NWT','S');       
   -- 
   DBMS_OUTPUT.PUT_LINE (''|| CHR(13)); 
   DBMS_OUTPUT.PUT_LINE ('----------  ss_p_copia_usuario_trn     -- '|| CHR(13));    
   DBMS_OUTPUT.PUT_LINE (''||  CHR(13)); 
   --     
   tron2000.trn_k_global.asigna('cod_usr','TRONMW01');
   --
   tron2000.ss_p_copia_usuario_trn;
   --
   -- l_cod_cia              := TO_NUMBER(trn_k_global.devuelve(p_variable => 'jbcod_cia'));
   -- l_cod_usr_origen       := trn_k_global.devuelve(p_variable => 'jbnuuma_orig');
   -- l_cod_usr_destino      := trn_k_global.devuelve(p_variable => 'jbnuuma_dest');
   -- l_nombre_usr           := trn_k_global.devuelve(p_variable => 'jbnombre');
   -- l_ape1_usr             := trn_k_global.devuelve(p_variable => 'jbape1');
   -- l_ape2_usr             := trn_k_global.devuelve(p_variable => 'jbape2');
   -- l_email_usr_cia        := trn_k_global.devuelve(p_variable => 'jbemail');
   -- l_tip_docum            := trn_k_global.devuelve(p_variable => 'jbtip_docum');
   -- l_cod_docum            := trn_k_global.devuelve(p_variable => 'jbcod_docum');
   -- l_mca_crear_cajero     := trn_k_global.devuelve(p_variable => 'jbind_crea_cajero');
   -- l_mca_crear_tramitador := trn_k_global.devuelve(p_variable => 'jbind_crea_tramitador');
   -- l_mca_usuario_newtron  := trn_k_global.devuelve(p_variable => 'jbind_crea_nwt');
   -- l_nom_usr := UPPER( l_nombre_usr ||' '|| l_ape1_usr||' '|| l_ape2_usr);
   --
 EXCEPTION
   WHEN OTHERS
   THEN
      --
      dbms_output.put_line('CODIGO = '||SQLCODE || ', ERROR = '||SQLERRM || CHR(10));
      RAISE;                                 
      --
END;
--
--PASSWORD TRONWEB = mapfre
 
0
0
