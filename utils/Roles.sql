DECLARE
   --
   -- 1. Ejecutar el script para darle permisos a COD_USR en DEBUG
   -- 2. Crear a COD_USR como tramitador, desde la rutina de terceros con PAS = 1044224 (cod_docum)
   --
   g_cod_cia tron2000.g1010220.cod_cia%TYPE := 8        ;
   g_cod_usr tron2000.g1010220.cod_usr%TYPE := 'WGGONZL';
   --
   c_cod_rol  CONSTANT tron2000.g2000260.cod_rol%TYPE := 'TRON2000'; -- TRON2000 (Controles tecnicos de emisión)
   c_fec_actu CONSTANT DATE                           := SYSDATE   ;
   --
BEGIN
   --
   tron2000.trn_k_global.asigna('cod_usr', g_cod_usr);
   tron2000.trn_k_global.asigna('cod_cia', g_cod_cia);
   --
   /* ---------------------------------------------------------
   || a5020014 (Cuentas simplificadas por cajero)
   || PK: (cod_cia, cod_cajero, cod_cta_simp)
   */ ---------------------------------------------------------
   --
   INSERT INTO tron2000.a5020014 (cod_cia     ,
                                  cod_cajero  ,
                                  cod_cta_simp,
                                  tip_cta_simp,
                                  cod_mon     ,
                                  tip_caja_bco,
                                  cod_usr     ,
                                  fec_actu    )
   SELECT g_cod_cia,
          g_cod_usr,
          r.cod_cta_simp,
          r.tip_cta_simp,
          r.cod_mon,
          r.tip_caja_bco,
          g_cod_usr,
          TRUNC(SYSDATE)
     FROM (SELECT 'ANT01' cod_cta_simp, 'AN' tip_cta_simp, 99 cod_mon, 'G' tip_caja_bco FROM dual UNION ALL
           SELECT 'BACA1' cod_cta_simp, 'BA' tip_cta_simp, 1  cod_mon, 'B' tip_caja_bco FROM dual UNION ALL
           SELECT 'BACC1' cod_cta_simp, 'BA' tip_cta_simp, 1  cod_mon, 'B' tip_caja_bco FROM dual UNION ALL
           SELECT 'BACC2' cod_cta_simp, 'BA' tip_cta_simp, 1  cod_mon, 'B' tip_caja_bco FROM dual UNION ALL
           SELECT 'BACC3' cod_cta_simp, 'BA' tip_cta_simp, 1  cod_mon, 'B' tip_caja_bco FROM dual UNION ALL
           SELECT 'BADA1' cod_cta_simp, 'BA' tip_cta_simp, 1  cod_mon, 'B' tip_caja_bco FROM dual UNION ALL
           SELECT 'BAGC1' cod_cta_simp, 'BA' tip_cta_simp, 1  cod_mon, 'B' tip_caja_bco FROM dual UNION ALL
           SELECT 'BANC1' cod_cta_simp, 'BA' tip_cta_simp, 1  cod_mon, 'B' tip_caja_bco FROM dual UNION ALL
           SELECT 'BANC2' cod_cta_simp, 'BA' tip_cta_simp, 1  cod_mon, 'B' tip_caja_bco FROM dual UNION ALL
           SELECT 'BNPC1' cod_cta_simp, 'BA' tip_cta_simp, 1  cod_mon, 'B' tip_caja_bco FROM dual UNION ALL
           SELECT 'CA001' cod_cta_simp, 'CA' tip_cta_simp, 99 cod_mon, 'G' tip_caja_bco FROM dual UNION ALL
           SELECT 'CCA01' cod_cta_simp, 'CC' tip_cta_simp, 99 cod_mon, 'G' tip_caja_bco FROM dual UNION ALL
           SELECT 'CH01'  cod_cta_simp, 'CH' tip_cta_simp, 99 cod_mon, 'C' tip_caja_bco FROM dual UNION ALL
           SELECT 'CHC01' cod_cta_simp, 'CQ' tip_cta_simp, 99 cod_mon, 'G' tip_caja_bco FROM dual UNION ALL
           SELECT 'CHC02' cod_cta_simp, 'CS' tip_cta_simp, 99 cod_mon, 'G' tip_caja_bco FROM dual UNION ALL
           SELECT 'CITA1' cod_cta_simp, 'BA' tip_cta_simp, 1  cod_mon, 'B' tip_caja_bco FROM dual UNION ALL
           SELECT 'CITC1' cod_cta_simp, 'BA' tip_cta_simp, 1  cod_mon, 'B' tip_caja_bco FROM dual UNION ALL
           SELECT 'CMCA'  cod_cta_simp, 'CM' tip_cta_simp, 99 cod_mon, 'G' tip_caja_bco FROM dual UNION ALL
           SELECT 'CMT01' cod_cta_simp, 'CT' tip_cta_simp, 99 cod_mon, 'G' tip_caja_bco FROM dual UNION ALL
           SELECT 'CNCA'  cod_cta_simp, 'CN' tip_cta_simp, 99 cod_mon, 'G' tip_caja_bco FROM dual UNION ALL
           SELECT 'CPEA1' cod_cta_simp, 'BA' tip_cta_simp, 1  cod_mon, 'B' tip_caja_bco FROM dual UNION ALL
           SELECT 'CREC1' cod_cta_simp, 'BA' tip_cta_simp, 1  cod_mon, 'B' tip_caja_bco FROM dual UNION ALL
           SELECT 'CTC'   cod_cta_simp, 'TA' tip_cta_simp, 99 cod_mon, 'C' tip_caja_bco FROM dual UNION ALL
           SELECT 'DC01'  cod_cta_simp, 'DC' tip_cta_simp, 99 cod_mon, 'G' tip_caja_bco FROM dual UNION ALL
           SELECT 'EDIA1' cod_cta_simp, 'BA' tip_cta_simp, 1  cod_mon, 'B' tip_caja_bco FROM dual UNION ALL
           SELECT 'EFE01' cod_cta_simp, 'EF' tip_cta_simp, 99 cod_mon, 'C' tip_caja_bco FROM dual UNION ALL
           SELECT 'FF01'  cod_cta_simp, 'FF' tip_cta_simp, 99 cod_mon, 'C' tip_caja_bco FROM dual UNION ALL
           SELECT 'GCD01' cod_cta_simp, 'GR' tip_cta_simp, 99 cod_mon, 'G' tip_caja_bco FROM dual UNION ALL
           SELECT 'GLBA1' cod_cta_simp, 'BA' tip_cta_simp, 1  cod_mon, 'B' tip_caja_bco FROM dual UNION ALL
           SELECT 'GLBC1' cod_cta_simp, 'BA' tip_cta_simp, 1  cod_mon, 'B' tip_caja_bco FROM dual UNION ALL
           SELECT 'GLBC2' cod_cta_simp, 'BA' tip_cta_simp, 1  cod_mon, 'B' tip_caja_bco FROM dual UNION ALL
           SELECT 'GLBC3' cod_cta_simp, 'BA' tip_cta_simp, 1  cod_mon, 'B' tip_caja_bco FROM dual UNION ALL
           SELECT 'GS001' cod_cta_simp, 'GS' tip_cta_simp, 1  cod_mon, 'G' tip_caja_bco FROM dual UNION ALL
           SELECT 'INC01' cod_cta_simp, 'IN' tip_cta_simp, 99 cod_mon, 'G' tip_caja_bco FROM dual UNION ALL
           SELECT 'IPR01' cod_cta_simp, 'IR' tip_cta_simp, 99 cod_mon, 'G' tip_caja_bco FROM dual UNION ALL
           SELECT 'IPR02' cod_cta_simp, 'IR' tip_cta_simp, 99 cod_mon, 'G' tip_caja_bco FROM dual UNION ALL
           SELECT 'IPR03' cod_cta_simp, 'IR' tip_cta_simp, 99 cod_mon, 'G' tip_caja_bco FROM dual UNION ALL
           SELECT 'LC01'  cod_cta_simp, 'IR' tip_cta_simp, 99 cod_mon, 'G' tip_caja_bco FROM dual UNION ALL
           SELECT 'NC01'  cod_cta_simp, 'IR' tip_cta_simp, 99 cod_mon, 'G' tip_caja_bco FROM dual UNION ALL
           SELECT 'PAG'   cod_cta_simp, 'CP' tip_cta_simp, 99 cod_mon, 'G' tip_caja_bco FROM dual UNION ALL
           SELECT 'PRIA1' cod_cta_simp, 'BA' tip_cta_simp, 1  cod_mon, 'B' tip_caja_bco FROM dual UNION ALL
           SELECT 'RCD01' cod_cta_simp, 'CD' tip_cta_simp, 99 cod_mon, 'G' tip_caja_bco FROM dual UNION ALL
           SELECT 'SAGC1' cod_cta_simp, 'BA' tip_cta_simp, 1  cod_mon, 'B' tip_caja_bco FROM dual UNION ALL
           SELECT 'TTCA'  cod_cta_simp, 'TT' tip_cta_simp, 99 cod_mon, 'G' tip_caja_bco FROM dual) r
    WHERE NOT EXISTS (SELECT 1
                        FROM tron2000.a5020014 x
                       WHERE x.cod_cia      = g_cod_cia
                         AND x.cod_cajero   = g_cod_usr
                         AND x.cod_cta_simp = r.cod_cta_simp);
   --
   /* ---------------------------------------------------------
   || a5020037 (Cajeros de la compania)
   || PK: (cod_cia, cod_cajero)
   */ ---------------------------------------------------------
   --
   INSERT INTO tron2000.a5020037 (cod_cia,
                                  cod_cajero,
                                  nom_cajero,
                                  tip_cajero,
                                  mca_activo,
                                  tip_reempla,
                                  mca_ultimo,
                                  mca_cuadrado,
                                  mca_ppal_nivel2,
                                  num_entorno,
                                  ult_num_recibo,
                                  ult_ord_pago,
                                  ult_num_giro,
                                  ult_num_anu,
                                  mca_entorno1,
                                  mca_entorno2,
                                  mca_entorno3,
                                  mca_entorno4,
                                  cod_usr,
                                  fec_actu,
                                  mca_fec_valor,
                                  mca_cajero_central,
                                  mca_pago_directo,
                                  mca_ve_op,
                                  cod_nivel3,
                                  mca_tt_caja_bco,
                                  mca_rec_pdtes_ant,
                                  mca_ext,
                                  mca_inh,
                                  fec_alta_cajero,
                                  fec_baja_cajero,
                                  obs_cajero)
   SELECT g_cod_cia,
          g_cod_usr,
          g_cod_usr,
          'S',
          'N',
          'R',
          'N',
          'S',
          'N',
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          'S',
          'S',
          'S',
          'S',
          g_cod_usr,
          c_fec_actu,
          'S',
          'S',
          'S',
          'S',
          1101,
          'S',
          'N',
          'N',
          'N',
          TO_DATE('16-06-2021', 'dd-mm-yyyy'),
          NULL,
          NULL
     FROM dual
    WHERE NOT EXISTS (SELECT 1
                        FROM tron2000.a5020037 x
                       WHERE x.cod_cia    = g_cod_cia
                         AND x.cod_cajero = g_cod_usr);
   --   
   /* ---------------------------------------------------------
   || g2000260 (Roles de control tecnico por usuario)
   || PK: (cod_usr_cia, cod_cia)
   */ ---------------------------------------------------------
   --
   INSERT INTO tron2000.g2000260 (cod_rol,
                                  cod_usr_cia,
                                  cod_usr,
                                  fec_actu,
                                  cod_cia)
   SELECT c_cod_rol,
          g_cod_usr,
          g_cod_usr,
          c_fec_actu,
          g_cod_cia
     FROM dual
    WHERE NOT EXISTS (SELECT 1
                        FROM tron2000.g2000260 x
                       WHERE x.cod_usr_cia = g_cod_usr
                         AND x.cod_cia     = g_cod_cia);
   --
   /* ---------------------------------------------------------
   || g1010220 (Roles de un usuario)
   || PK: (cod_usr, cod_rol, cod_cia)
   */ ---------------------------------------------------------
   --
   INSERT INTO tron2000.g1010220 (cod_cia,
                                 cod_usr,
                                 cod_rol,
                                 fec_actu)
   SELECT g_cod_cia,
          g_cod_usr,
          r.cod_rol,
          c_fec_actu
     FROM (SELECT column_value cod_rol
             FROM TABLE(sys.odcivarchar2list('ACTUARIO',
                                             'ADMFIN5',
                                             'ADMFIN6',
                                             'ADM_REASEG',
                                             'APADEA',
                                             'ASES_COMER',
                                             'ASIENTOS',
                                             'ATC1',
                                             'ATC1CAJA',
                                             'CAJAACH',
                                             'CAJADM',
                                             'CAJPRE1',
                                             'CAJSUP',
                                             'CCMAWDY1',
                                             'CIBER_SEG',
                                             'CLASCAU',
                                             'COMER_USR',
                                             'COMER_VIDA',
                                             'CONSULT',
                                             'CORDI_TRAM',
                                             'CTRL_AUDIT',
                                             'CUMPLIMIE1',
                                             'DATOSTHPND',
                                             'DIR_COMER',
                                             'DIR_GENER',
                                             'DIR_OPER',
                                             'DIR_OPERAC',
                                             'DIR_TECNI',
                                             'EJE_COMER',
                                             'EMISION_VI',
                                             'EMISION1',
                                             'EMISION2',
                                             'FRAUDESINI',
                                             'GERENTE',
                                             'GERENTE_OD',
                                             'GEST_ATC',
                                             'GEST_COBRO',
                                             'GEST_CONS',
                                             'GEST_EMI',
                                             'GESTOR_VID',
                                             'GESTUSR',
                                             'IMPAGO',
                                             'IMPAGOS',
                                             'INFOCAU',
                                             'INSPECCION',
                                             'INTERME',
                                             'IQRF_SINI',
                                             'JEF_ATC',
                                             'JEF_COBROS',
                                             'JEF_COMER',
                                             'JEF_CONS',
                                             'JEF_EMI',
                                             'LEGAL_USR',
                                             'LIM_DIRECC',
                                             'LIM_SUBDIR',
                                             'LIM_SUBDI2',
                                             'LIM_TRAMI1',
                                             'LIM_TRAMI2',
                                             'LZD_TAREAS',
                                             'MANT_SINI',
                                             'MPA_10',
                                             'MPA_11',
                                             'MPA_17',
                                             'MPA_20',
                                             'MPA_21',
                                             'MPA_21_CON',
                                             'MPA_21_TEC',
                                             'MPA_27',
                                             'MPA_31',
                                             'MPA_34',
                                             'MPA_42',
                                             'MPA_47',
                                             'MPA_49',
                                             'MPA_51',
                                             'MPA_52',
                                             'MPA_61',
                                             'OPERACION',
                                             'OPERCOBX',
                                             'OPERCOB1',
                                             'OPERCOB1A',
                                             'OPERCOB1B',
                                             'ORION',
                                             'PERITO',
                                             'PREST_JEFE',
                                             'PREST_SUP',
                                             'PREST_TRAM',
                                             'PROVSINI',
                                             'PROVTOT',
                                             'REPR_COB',
                                             'RESP_TRAMI',
                                             'RESTRICTED',
                                             'ROL_GDC',
                                             'ROL_GDC2',
                                             'SERVFNX',
                                             'SRVCB',
                                             'SUB_ATC',
                                             'SUB_COBRO',
                                             'SUB_COMER',
                                             'SUB_CONS',
                                             'SUB_EMI',
                                             'SUPERINT',
                                             'SUPER_VIDA',
                                             'SUP_PERITO',
                                             'SUSCRIP',
                                             'SUSCRIP_VI',
                                             'TARIFAIN',
                                             'TARIFAUP',
                                             'TEC_FRAUDE',
                                             'TECN_AUTO',
                                             'TECNICA_RG',
                                             'TECNICA1',
                                             'TECNICA2',
                                             'TEC_VIDA1',
                                             'TESORE1',
                                             'TESORE2',
                                             'TESORE3',
                                             'TESORE4',
                                             'THP_MDF',
                                             'TRAMI_ESP',
                                             'TRAMI_GEN',
                                             'TSMASIVOS',
                                             '1',
                                             '2',
                                             '3',
                                             '4',
                                             '5',
                                             '6',
                                             '7',
                                             '8',
                                             '9',
                                             '10',
                                             '11',
                                             '12',
                                             '13',
                                             '14',
                                             '15',
                                             '16',
                                             '17',
                                             '18',
                                             '19',
                                             '20',
                                             '21',
                                             '22',
                                             '23',
                                             '24',
                                             '25',
                                             '26',
                                             '27',
                                             '28',
                                             '29',
                                             '30',
                                             '31',
                                             '32',
                                             '33',
                                             '34',
                                             '35',
                                             '36',
                                             '37',
                                             '38',
                                             '39',
                                             '40',
                                             '41',
                                             '42',
                                             '43',
                                             '44',
                                             '45',
                                             '46',
                                             '47',
                                             '48',
                                             '49',
                                             '50',
                                             '51',
                                             '52',
                                             '53',
                                             '54',
                                             '55',
                                             '56',
                                             '57',
                                             '59',
                                             '60',
                                             '3234554543'))) r
    WHERE NOT EXISTS (SELECT 1
                       FROM tron2000.g1010220 x
                      WHERE x.cod_usr = g_cod_usr
                        AND x.cod_rol = r.cod_rol
                        AND x.cod_cia = g_cod_cia);
   --
   /* ---------------------------------------------------------
   || g1010125 (Acceso a actividades por usuario)
   || PK: (cod_usr, cod_act_tercero, cod_cia)
   */ ---------------------------------------------------------
   --
   INSERT INTO tron2000.g1010125 (cod_usr,
                                  cod_act_tercero,
                                  fec_actu,
                                  cod_cia)
   SELECT g_cod_usr,
          a.cod_act_tercero,
          c_fec_actu,
          g_cod_cia
     FROM (SELECT column_value cod_act_tercero
             FROM TABLE(sys.odcinumberlist(9, 13, 14, 16, 999, 1))) a
    WHERE NOT EXISTS (SELECT 1
                        FROM tron2000.g1010125 x
                       WHERE x.cod_usr         = g_cod_usr
                         AND x.cod_act_tercero = a.cod_act_tercero
                         AND x.cod_cia         = g_cod_cia);
   --
   /* ---------------------------------------------------------
   || tsctrl001 (Control tecnico importes por usuarios)
   || PK: (cod_cia, cod_tratamiento, cod_ramo, tip_exp,
   ||      cod_usr_tramitador, tip_docto, cod_cto_rva,
   ||      cod_rol, tip_imp_limite)
   */ ---------------------------------------------------------
   --
   INSERT INTO tron2000.tsctrl001 (cod_cia,
                                  cod_tratamiento,
                                  cod_usr_tramitador,
                                  tip_docto,
                                  imp_maximo,
                                  fec_actu,
                                  cod_cto_rva,
                                  cod_ramo,
                                  tip_exp,
                                  cod_rol,
                                  tip_imp_limite)
   SELECT g_cod_cia,
          r.cod_tratamiento,
          g_cod_usr,
          r.tip_docto,
          r.imp_maximo,
          c_fec_actu,
          r.cod_cto_rva,
          r.cod_ramo,
          r.tip_exp,
          r.cod_rol,
          r.tip_imp_limite
     FROM (SELECT 'A' cod_tratamiento, 'ZZ' tip_docto, 1500 imp_maximo, 99 cod_cto_rva, 300 cod_ramo, '999' tip_exp, 'ZZZZZZZZZZ' cod_rol, '3' tip_imp_limite FROM dual UNION ALL
           SELECT 'A' cod_tratamiento, 'ZZ' tip_docto, 1500 imp_maximo, 99 cod_cto_rva, 300 cod_ramo, 'DED' tip_exp, 'ZZZZZZZZZZ' cod_rol, '3' tip_imp_limite FROM dual UNION ALL
           SELECT 'A' cod_tratamiento, 'ZZ' tip_docto, 1500 imp_maximo, 99 cod_cto_rva, 300 cod_ramo, 'REC' tip_exp, 'ZZZZZZZZZZ' cod_rol, '3' tip_imp_limite FROM dual UNION ALL
           SELECT 'A' cod_tratamiento, 'ZZ' tip_docto, 1500 imp_maximo, 99 cod_cto_rva, 300 cod_ramo, 'SAL' tip_exp, 'ZZZZZZZZZZ' cod_rol, '3' tip_imp_limite FROM dual) r
    WHERE NOT EXISTS (SELECT 1
                        FROM tron2000.tsctrl001 x
                       WHERE x.cod_cia            = g_cod_cia
                         AND x.cod_tratamiento    = r.cod_tratamiento
                         AND x.cod_ramo           = r.cod_ramo
                         AND x.tip_exp            = r.tip_exp
                         AND x.cod_usr_tramitador = g_cod_usr
                         AND x.tip_docto          = r.tip_docto
                         AND x.cod_cto_rva        = r.cod_cto_rva
                         AND x.cod_rol            = r.cod_rol
                         AND x.tip_imp_limite     = r.tip_imp_limite);
   --
   /* ---------------------------------------------------------
   || g2000230 (Niveles de autorización de control
   ||           tecnico por rol)
   ||
   || Descripción: Se pasan los niveles del cod_rol = DIRECTOR
   ||              al cod_rol = TRON2000, para que autorice
   ||              controles tecnicos de siniestros
   ||
   || PK: (cod_cia, cod_sistema, cod_sector, cod_subsector,
   ||      cod_ramo, cod_nivel_salto, cod_nivel1, cod_nivel2,
   ||      cod_nivel3, cod_rol, cod_sist_aut)
   */ ---------------------------------------------------------
   --
   INSERT INTO TRON2000.g2000230(cod_cia,
                                 cod_sistema,
                                 cod_sector,
                                 cod_subsector,
                                 cod_ramo,
                                 cod_nivel_salto,
                                 cod_nivel1,
                                 cod_nivel2,
                                 cod_nivel3,
                                 cod_rol,
                                 cod_sist_aut,
                                 cod_nivel_autorizacion,
                                 cod_usr,
                                 fec_actu)
   SELECT src.cod_cia,
          src.cod_sistema,
          src.cod_sector,
          src.cod_subsector,
          src.cod_ramo,
          src.cod_nivel_salto,
          src.cod_nivel1,
          src.cod_nivel2,
          src.cod_nivel3,
          'TRON2000',
          src.cod_sist_aut,
          src.cod_nivel_autorizacion,
          g_cod_usr,
          TRUNC(SYSDATE)
     FROM TRON2000.g2000230 src
    WHERE src.cod_rol = 'DIRECTOR'
      AND src.cod_cia = g_cod_cia
      AND NOT EXISTS (SELECT 1
                       FROM TRON2000.g2000230 dst
                       WHERE dst.cod_cia         = src.cod_cia
                         AND dst.cod_sistema     = src.cod_sistema
                         AND dst.cod_sector      = src.cod_sector
                         AND dst.cod_subsector   = src.cod_subsector
                         AND dst.cod_ramo        = src.cod_ramo
                         AND dst.cod_nivel_salto = src.cod_nivel_salto
                         AND dst.cod_nivel1      = src.cod_nivel1
                         AND dst.cod_nivel2      = src.cod_nivel2
                         AND dst.cod_nivel3      = src.cod_nivel3
                         AND dst.cod_rol         = 'TRON2000'
                         AND dst.cod_sist_aut    = src.cod_sist_aut);   
   --
   COMMIT;
   --
EXCEPTION
   WHEN OTHERS
   THEN
      --
      ROLLBACK;
      --
      dbms_output.put_line('CODIGO = '||SQLCODE || ', ERROR = '||SQLERRM || CHR(10));
      --
      RAISE;
      --
END;
/
