
with
linhas as ( select rownum as ord from all_objects where rownum <= 20000
),
qtdereg as ( select cdArquivoCredito, ceil(length(to_clob(blArquivoCredito))/242) as maxreg from emigArquivoCredito
),
arquivo as (
select arq.nmOrigem, arq.nuAnoMes, arq.cdArquivoCredito, arq.nmGrupoCentroCusto, arq.nmOrgao, arq.tpPagamento, arq.tpBanco,
lin.ord, utl_raw.cast_to_varchar2(dbms_lob.substr(arq.blArquivoCredito,240,((lin.ord - 1)*242)+1)) as registro
from emigArquivoCredito arq
inner join qtdereg on arq.cdArquivoCredito = qtdereg.cdArquivoCredito
inner join linhas lin on lin.ord <= qtdereg.maxreg
where nuanomes = 202309 and nmOrigem != 'SIGRHOLD'
),
Controle as (
--- Arquivo de Credito Contole
select cdArquivoCredito, nmOrigem, nuAnoMes, nmGrupoCentroCusto, nmOrgao, tpPagamento, tpBanco, ord,
substr(registro, 001, 003) as Banco,
substr(registro, 004, 004) as Lote,
substr(registro, 008, 001) as TipoRegistro,
substr(registro, 009, 005) as Sequencial,
substr(registro, 014, 001) as Segmento
from arquivo
),
FileHeader as (
--- Arquivo de Credito Header Arquivo
select cdArquivoCredito, nmOrigem, nuAnoMes, nmGrupoCentroCusto, nmOrgao, tpPagamento, tpBanco, ord,
substr(registro, 001, 003) as Banco,
substr(registro, 004, 004) as Lote,
substr(registro, 008, 001) as TipoRegistro,
substr(registro, 018, 001) as TipoInscricao,
substr(registro, 019, 014) as CNPJConvenio,
substr(registro, 033, 020) as Convenio,
--substr(registro, 033, 003) as Convenio01,
--substr(registro, 036, 006) as Convenio02,
--substr(registro, 042, 003) as Convenio03,
--substr(registro, 045, 006) as Convenio04,
--substr(registro, 051, 001) as Convenio05,
--substr(registro, 052, 001) as Convenio06,
substr(registro, 053, 005) as Agencia,
substr(registro, 058, 001) as AgenciaDV,
substr(registro, 059, 012) as ContaCorrente,
substr(registro, 071, 001) as ContaCorrenteDV,
substr(registro, 072, 001) as AgenciaContaDV,
substr(registro, 073, 030) as NomeOrgao,
substr(registro, 103, 030) as NomeBanco,
substr(registro, 143, 001) as Codigo,
substr(registro, 144, 008) as DataGeracao,
substr(registro, 152, 006) as HoraGeracao,
substr(registro, 158, 006) as Sequencia,
substr(registro, 164, 003) as layout,
substr(registro, 167, 005) as Densidade,
substr(registro, 192, 020) as Empresa
from arquivo
where substr(registro, 008, 001) = '0'
),
BatchHeader as (
--- Arquivo de Credito Header Lote
select cdArquivoCredito, nmOrigem, nuAnoMes, nmGrupoCentroCusto, nmOrgao, tpPagamento, tpBanco, ord,
substr(registro, 001, 003) as Banco,
substr(registro, 004, 004) as Lote,
substr(registro, 008, 001) as TipoRegistro,
substr(registro, 009, 001) as Operacao,
substr(registro, 010, 002) as TipoServico,
substr(registro, 012, 002) as FormaLancamento,
substr(registro, 014, 003) as LAYOUT,
substr(registro, 018, 001) as TipoInscricao,
substr(registro, 019, 014) as CNPJConvenio,
substr(registro, 033, 020) as Convenio,
--substr(registro, 033, 003) as Convenio01,
--substr(registro, 036, 006) as Convenio02,
--substr(registro, 042, 003) as Convenio03,
--substr(registro, 045, 006) as Convenio04,
--substr(registro, 051, 001) as Convenio05,
--substr(registro, 052, 001) as Convenio06,
substr(registro, 053, 005) as Agencia,
substr(registro, 058, 001) as AgenciaDV,
substr(registro, 059, 012) as ContaCorrente,
substr(registro, 071, 001) as ContaCorrenteDV,
substr(registro, 072, 001) as AgenciaContaDV,
substr(registro, 073, 030) as NomeOrgao,
substr(registro, 143, 030) as EnderecoLogradouro,
substr(registro, 173, 005) as EnderecoNumero,
substr(registro, 178, 015) as EnderecoComplemento,
substr(registro, 193, 020) as EnderecoCidade,
substr(registro, 213, 005) as EnderecoCEP,
substr(registro, 218, 003) as EnderecoCEPComplemento,
substr(registro, 221, 002) as EnderecoEstado
from arquivo
where substr(registro, 008, 001) = '1'
),
BatchTrailler as (
--- Arquivo de Credito Trailler Lote
select cdArquivoCredito, nmOrigem, nuAnoMes, nmGrupoCentroCusto, nmOrgao, tpPagamento, tpBanco, ord,
substr(registro, 001, 003) as Banco,
substr(registro, 004, 004) as Lote,
substr(registro, 008, 001) as TipoRegistro,
substr(registro, 018, 006) as Registros,
substr(registro, 024, 018) as Valores
from arquivo
where substr(registro, 008, 001) = '5'
),
FileTrailler as (
--- Arquivo de Credito Trailler Arquivo
select cdArquivoCredito, nmOrigem, nuAnoMes, nmGrupoCentroCusto, nmOrgao, tpPagamento, tpBanco, ord,
substr(registro, 001, 003) as Banco,
substr(registro, 004, 004) as Lote,
substr(registro, 008, 001) as TipoRegistro,
substr(registro, 018, 006) as Lotes,
substr(registro, 024, 006) as Registros
from arquivo
where substr(registro, 008, 001) = '9'
),
DetalheA as (
--- Arquivo de Credito Detalhe A
select cdArquivoCredito, nmOrigem, nuAnoMes, nmGrupoCentroCusto, nmOrgao, tpPagamento, tpBanco, ord,
substr(registro, 001, 003) as Banco,
substr(registro, 004, 004) as Lote,
substr(registro, 008, 001) as TipoRegistro,
substr(registro, 009, 005) as Sequencial,
substr(registro, 014, 001) as Segmento,
substr(registro, 015, 001) as TipoMovimento,
substr(registro, 016, 002) as CodigoMovimento,
substr(registro, 018, 003) as Compensacao,
substr(registro, 021, 003) as BancoCredito,
substr(registro, 024, 005) as Agencia,
substr(registro, 029, 001) as AgenciaDV,
substr(registro, 030, 012) as ContaCorrente,
substr(registro, 042, 001) as ContaCorrenteDV,
substr(registro, 043, 001) as AgenciaContaDV,
substr(registro, 044, 030) as Nome,
substr(registro, 074, 020) as SeuNumero,
substr(registro, 094, 008) as DataCredito,
substr(registro, 102, 003) as TipoMoeda,
substr(registro, 105, 015) as Quantidade,
substr(registro, 120, 015) as Valor,
substr(registro, 135, 020) as NossoNumero,
substr(registro, 155, 008) as DataReal,
substr(registro, 163, 015) as ValorReal,
substr(registro, 178, 040) as Informacao,
substr(registro, 218, 002) as FinalidadeDOC,
substr(registro, 220, 005) as FinalidadeTED,
substr(registro, 225, 002) as FinalidadeComplementar,
substr(registro, 230, 001) as Aviso,
substr(registro, 231, 010) as Ocorrencias
from arquivo
where substr(registro, 008, 001) = '3' and substr(registro, 014, 001) = 'A'
),
DetalheB as (
--- Arquivo de Credito Detalhe B
select cdArquivoCredito, nmOrigem, nuAnoMes, nmGrupoCentroCusto, nmOrgao, tpPagamento, tpBanco, ord,
substr(registro, 001, 003) as Banco,
substr(registro, 004, 004) as Lote,
substr(registro, 008, 001) as TipoRegistro,
case when nmOrigem = 'SIGRHOLD' then lpad(substr(registro, 009, 005) - 1,5,0) else substr(registro, 009, 005) end as Sequencial,
substr(registro, 014, 001) as Segmento,
substr(registro, 018, 001) as TipoInscricao,
substr(registro, 019, 014) as NumeroInscricao,
substr(registro, 033, 030) as EnderecoLogradouro,
substr(registro, 063, 005) as EnderecoNumero,
substr(registro, 068, 015) as EnderecoComplemento,
substr(registro, 083, 015) as EnderecoBairro,
substr(registro, 098, 020) as EnderecoCidade,
substr(registro, 118, 005) as EnderecoCEP,
substr(registro, 123, 003) as EnderecoCEPComplemento,
substr(registro, 126, 002) as EnderecoEstado,
substr(registro, 128, 008) as Vencimento,
substr(registro, 136, 015) as Valor,
substr(registro, 151, 015) as Abatimento,
substr(registro, 166, 015) as Desconto,
substr(registro, 181, 015) as Mora,
substr(registro, 196, 015) as Multa,
substr(registro, 211, 015) as Favorecido,
substr(registro, 226, 001) as Aviso,
substr(registro, 227, 006) as UG
from arquivo
where substr(registro, 008, 001) = '3' and substr(registro, 014, 001) = 'B'
)

/*
--select * from FileHeader
--select * from BatchHeader
--select * from Controle where TipoRegistro != 3
--order by nuAnoMes, tpPagamento, tpBanco, nmGrupoCentroCusto, nmOrigem, nmOrgao, cdArquivoCredito, Ord
--;
*/

--/*
select a.nmOrigem,
b.NumeroInscricao, a.Nome,
a.BancoCredito, a.Agencia, a.AgenciaDV, a.ContaCorrente, a.ContaCorrenteDV,
a.tpPagamento, a.tpBanco,
a.Valor,a.ValorReal,
a.nmGrupoCentroCusto, a.nmOrgao,
a.Informacao, a.FinalidadeDOC, a.FinalidadeTED
from DetalheA a
left join DetalheB b on b.cdArquivoCredito = a.cdArquivoCredito and b.Lote = a.Lote and b.Sequencial = a.Sequencial
order by
b.NumeroInscricao, a.Nome, a.BancoCredito, a.Agencia, a.ContaCorrente,
a.tpPagamento, a.tpBanco, a.nmGrupoCentroCusto, a.nmOrigem, a.nmOrgao
;
--*/

/*
select 
lpad(to_number(trim(b.NumeroInscricao)),11,0) as CPF,
a.Nome,
to_number(a.Valor)/100 as Valor,
a.BancoCredito, a.Agencia, a.ContaCorrente || a.ContaCorrenteDV as ContaCorrente,
a.nmGrupoCentroCusto, a.nmOrgao, a.tpPagamento, a.tpBanco, a.nmOrigem, a.nuanomes, to_char(to_date(a.DataCredito, 'DDMMYYYY'), 'DD/MM/YYYY') as DataCredito
from DetalheA a
where a.nmOrigem = 'SIGRH'
order by b.NumeroInscricao, a.nmGrupoCentroCusto, a.nmOrgao, a.tpPagamento, a.tpBanco, a.nmOrigem, a.nuanomes
;
*/
/