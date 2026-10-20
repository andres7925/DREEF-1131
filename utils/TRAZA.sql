trn_k_ptd.p_habilita_traza('GHANDR4');
--trn_k_ptd.p_gen_traza_parametro('f_definicion_columnas' , 'g_cod_cia' , g_cod_cia); 
trn_k_ptd.p_gen_traza_comentario(g_k_nom_prg , 'AQUI SI' || g_cod_cob ); 
trn_k_ptd.p_deshabilita_traza;         

dl_trn_dbg.p_enb('GHANDR4'); 
dl_trn_dbg.p_set_cmt (c_pgm_nam, 'fin mvto_batch => '|| lv_btc_mvm_typ_val); 
dl_trn_dbg.p_dsb;

SELECT * FROM TRON2000.T_TRN_TRN_R_DBG WHERE DBG_IDN = 'GHANDR4' ORDER BY TIM_INV DESC;
DELETE FROM TRON2000.T_TRN_TRN_R_DBG WHERE DBG_IDN = 'GHANDR4';  
