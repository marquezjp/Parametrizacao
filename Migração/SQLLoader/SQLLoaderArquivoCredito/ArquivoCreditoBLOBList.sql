with
linhas as ( select rownum as ord from all_objects where rownum <= 20000
),
qtdereg as ( select cdArquivoCredito, ceil(length(to_clob(blArquivoCredito))/242) as maxreg from emigArquivoCredito
),
arquivo as (
select arq.cdArquivoCredito, arq.nmGrupoCentroCuto, arq.tpPagamento, arq.tpBanco,
lin.ord, utl_raw.cast_to_varchar2(dbms_lob.substr(arq.blArquivoCredito,240,((lin.ord - 1)*242)+1)) as registro
from emigArquivoCredito arq
inner join qtdereg on arq.cdArquivoCredito = qtdereg.cdArquivoCredito
inner join linhas lin on lin.ord <= qtdereg.maxreg
where arq.cdArquivoCredito in (8, 9)
)

--- Arquivo de Credito Detalhe A
select nmGrupoCentroCuto, tpPagamento, tpBanco, ord,
substr(registro, 001, 003) as banco,
substr(registro, 004, 004) as lote,
substr(registro, 008, 001) as tiporeg,
substr(registro, 009, 005) as sequencial,
substr(registro, 014, 001) as segmento,
substr(registro, 015, 002) as tipomovimento
from arquivo
where substr(registro, 008, 001) = '3' and substr(registro, 014, 001) = 'A'
order by cdArquivoCredito, ord
;
/

