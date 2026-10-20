/*G1010210 y g1010220*/

SELECT a.*, ROWID FROM TRON2000.G1010210  a WHERE a.cod_cia = 5 AND a.cod_pgm = 'TRNCOPUSR'; --TRNGC00199 
SELECT a.*, ROWID FROM TRON2000.g1010220  a WHERE a.cod_cia = 5 AND a.cod_usr LIKE UPPER('%CPALBE%');  

select t.*, t.rowid from tron2000.g1010200 t WHERE cod_cia = 5 ; --ROLES
select t.*, t.rowid from tron2000.g1010220 t WHERE cod_cia = 5 AND COD_USR='INFQUIMB'; --ROLES DE UN USUARIO  PRUEBASMHN
select t.*, t.rowid from tron2000.g1010210 t WHERE cod_cia = 5 AND cod_pgm='MHNEML0020';         --ROLES PERMITIDOS PARA ACCEDER A UN PROGRAMA
