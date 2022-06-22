delete from esegfuncionalidadeagrupamento
where cdfuncionalidade in (select cdfuncionalidade from esegfuncionalidade
where nmpagina = '../SEG/PaginaConstrucao.htm');

delete from ehlpprocedimentocomp
where cdfuncionalidade in (select cdfuncionalidade from esegfuncionalidade
where nmpagina = '../SEG/PaginaConstrucao.htm');

delete from esegfuncionalidade
where nmpagina = '../SEG/PaginaConstrucao.htm';