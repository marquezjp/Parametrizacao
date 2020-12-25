select
    aa.cdautorizacaoacesso,
    aa.cdagrupamento,
    aa.cdorgao,
    u.nucpf,
    u.nmapelido,
    u.nmpessoa
from esegautorizacaoacesso aa
inner join esegusuario u on u.cdusuario = aa.cdusuario