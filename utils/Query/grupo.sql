-- ------------------------------------------------------------------------------------------------------------------- 
-- General Definitions: Group Policies & Contracts 

-- Pólizas Grupo (AP200051)
SELECT * FROM tron2000.g2990017 WHERE cod_cia = 8 AND num_poliza IN ('0830024CCC002'); -- PARAMETRIZA POLIZA GRUPO

-- Contratos (AP200007)
SELECT * FROM tron2000.g2990001 WHERE cod_cia = 8 AND num_contrato IN (202); -- PARAMETRIZA CONTRATOS

-- SubContratos (AP200088)
SELECT * FROM tron2000.g2990018 WHERE cod_cia = 8 AND num_subcontrato IN (202);

-- Contratos asociados a poliza grupo 
SELECT * FROM tron2000.a2000010 WHERE cod_cia = 8 AND num_poliza LIKE '%0830024CCC002%' AND num_contrato LIKE '%%';

-- a2000010: TIP_POLIZA
SELECT * FROM tron2000.g1010031 WHERE cod_cia = 8 AND cod_campo LIKE UPPER('tip_poliza') AND cod_idioma = 'ES' ORDER BY num_orden; 

-- ------------------------------------------------------------------------------------------------------------------- 
-- Line of Business: Group Policies & Contracts

-- Contratos por Ramo (AP200096/97 )
SELECT * from tron2000.g2990027 WHERE cod_cia = 8 and num_contrato IN (202);

-- Datos Fijos de Contratos (AP200006)
SELECT * FROM tron2000.g2990000 WHERE cod_cia = 8 AND num_contrato IN (202);

-- Datos Variables de Contratos (AP200091)
SELECT * FROM tron2000.g2990019 WHERE cod_cia = 8 AND num_contrato IN (202) ORDER BY num_contrato;

-- Coberturas de Contratos (AP200092)
SELECT * FROM tron2000.g2990026 WHERE cod_cia = 8 AND num_contrato IN (202);

-- Sub-Contratos por Ramo y Contrato (AP200089)
SELECT * FROM tron2000.g2990021 WHERE cod_cia = 8 AND num_contrato IN (202);

-- Datos Fijos de Sub-Contratos (AP200093)
SELECT * FROM tron2000.g2990022 WHERE cod_cia = 8 AND num_contrato IN (202);

-- Datos Variables de Sub-Contratos (AP200094)
SELECT * FROM tron2000.g2990023 WHERE cod_cia = 8 AND num_contrato IN (202);

-- Coberturas de Sub-Contratos (AP200095)
SELECT * FROM tron2000.g2990024 WHERE cod_cia = 8 AND num_contrato IN (202);

-- Datos Variables de Póliza Grupo
SELECT * FROM tron2000.g2990028 WHERE cod_cia = 8 AND num_poliza IN ('0830024CCC002');

-- Planes de pago por Acuerdo/Subacuerdo
-- OJO: Se debe dejar la fec_validez del ramo
SELECT * FROM tron2000.df_psf_nwt_xx_psf_pms_sbl a WHERE a.cmp_val = 8 AND a.del_val IN (202);

-- Tipos de Tercero que intervienen por Ramo, Acuerdo, Subacuerdo
SELECT * FROM tron2000.df_pid_nwt_xx_itd_vld a WHERE cmp_val = 8 AND a.del_val IN (202);

-- Tipos de Tercero que intervienen por Ramo, Acuerdo, Subacuerdo
SELECT * FROM tron2000.df_pid_nwt_xx_itd_mdf a WHERE cmp_val = 8 AND a.del_val IN (202);

-- Cláusula de la Póliza Grupo
SELECT * FROM trp_pa_dl.df_ply_nwt_xx_cla_gpp a WHERE cmp_val = 8 AND a.del_val IN (202);