SELECT
blocking_session.sid blocker_sid,
blocking_session.serial# blocker_serial,
blocking_session.username blocker_username,
blocking_session.machine blocker_machine,
blocking_session.program blocker_program,
blocking_session.logon_time blocker_logon_time,
blocked_session.sid waiting_sid,
blocked_session.serial# waiting_serial,
blocked_session.username waiting_username,
blocked_session.machine waiting_machine,
blocked_session.program waiting_program,
blocked_session.logon_time waiting_logon_time,
w.wait_class waiting_class,
w.event waiting_event,
w.seconds_in_wait wait_seconds,
sql_text.sql_text blocked_sql
FROM
v$session blocked_session
JOIN v$session blocking_session ON (blocked_session.blocking_session = blocking_session.sid)
JOIN v$session_wait w ON (w.sid = blocked_session.sid)
LEFT JOIN v$sql sql_text ON (sql_text.sql_id = blocked_session.sql_id)
WHERE
blocked_session.blocking_session IS NOT NULL
ORDER BY
w.seconds_in_wait DESC;


SELECT a.sid        "SID"               ,
       a.serial#    "Serial"            ,
       a.inst_id    "ID"                ,
       a.username   "Usuario"           ,
       a.osuser     "Usuario Bloqueador",
       a.status     "Estado"            ,
       b.owner      "Usuario Duenio"    ,
       b.object     "Objeto Bloqueado"  ,
       b.type       "Tipo De Objeto"
  FROM gv$session a,
       gv$access  b
WHERE a.sid              = b.sid
   AND a.inst_id          = b.inst_id
   AND b.type            <> 'NON-EXISTENT'
   AND UPPER(b.object) LIKE UPPER('%GC_K_CARGA_PENDIENTES%')
   AND b.owner         IS NOT NULL
   and b.owner         NOT IN ('SYSTEM','SYS')
ORDER BY a.osuser ,
          a.sid    ,
          a.serial#;
 
