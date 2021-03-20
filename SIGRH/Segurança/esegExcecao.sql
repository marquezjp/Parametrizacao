select u.nucpf, u.nmapelido, u.nmpessoa,
 m.nmmodulo || '=>' || s.nmsubmodulo || '=>' || upper(fa.nmfuncionalidade) as funcionalidade,
 e.dtexcecao, e.deipcliente, e.demensagem, e.blstacktrace, e.cdexcecao

from esegexcecao e
left join esegusuario u on u.cdusuario = e.cdusuario
inner join esegfuncionalidadeagrupamento fa on fa.cdfuncagrupamento = e.cdfuncagrupamento
inner join esegfuncionalidade f on f.cdfuncionalidade = fa.cdfuncionalidade
inner join esegsubmodulo s on s.cdsubmodulo = f.cdsubmodulo
inner join esegmodulo m on m.cdmodulo = s.cdmodulo

where cdexcecao = 1260177

--where dtexcecao > '15/03/2021' --and u.nucpf = 06477281414
    --and u.nmapelido = 'SERGIO'
    --and m.nmmodulo = 'PAGAMENTOS'