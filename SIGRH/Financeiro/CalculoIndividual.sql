--PARÂMETROS 

-- plog = 0
-- ptrace = 0
-- pflcalculodefinitivo = S
-- pflpagaadiantamento = Null
-- pdtcalculo = '20/05/2021' -- Data Atual
-- pvldiferencavalor = Null
-- pcdvinculo = 29281
-- pcdfolhapagamento = 45968

-- Vinculo
select cdvinculo from ecadvinculo v where v.numatricula = 954777;

-- Folha
select cdfolhapagamento from epagfolhapagamento f 
where f.cdorgao = (select cdorgao from vcadorgao where sgorgao = 'SEMED')
  and f.nuanomesreferencia = 202105
  and f.cdtipofolhapagamento = 2
  and f.cdtipocalculo = 1;

select * from epagcapahistrubricavinculo
where cdvinculo = 29281
  and cdfolhapagamento = 45968;
  
-- Calculo Individual --
declare
  -- Boolean parameters are translated from/to integers: 
  -- 0/1/null <--> false/true/null 
  plog boolean := sys.diutil.int_to_bool(:plog);
  ptrace boolean := sys.diutil.int_to_bool(:ptrace);
  -- Non-scalar parameters require additional processing 
  pcalculoretorno pkgpag_cal.rcalculoretorno;
begin
  -- Call the procedure
  pkgpag_tar.pentrarcalculoindividual(pcdfolhapagamento => :pcdfolhapagamento,
                                      pcdvinculo => :pcdvinculo,
                                      pdtcalculo => :pdtcalculo,
                                      pflcalculodefinitivo => :pflcalculodefinitivo,
                                      pvldiferencavalor => :pvldiferencavalor,
                                      pflpagaadiantamento => :pflpagaadiantamento,
                                      plog => plog,
                                      ptrace => ptrace,
                                      pcalculoretorno => pcalculoretorno);
end;


--- Detalhe do Contra Cheque ---
select 
 o.sgorgao as Orgao,
 f.nuanoreferencia as Ano,
 f.numesreferencia as Mes,
 tf.nmtipofolhapagamento as Folha,
 case f.cdtipocalculo
  when 1 then 'NORMAL'
  when 5 then 'SUPLEMENTAR'
  else to_char(f.cdtipocalculo)
 end as Calculo,
 lpad(f.nusequencialfolha,2,'0') as SeqFolha,
 case f.flcalculodefinitivo when 'N' then 'NÃO' when 'S' then 'SIM' else '' end as Definitivo,

 lpad(v.numatricula, 7, 0)||'-'||v.nudvmatricula as Matricula,
 lpad(p.nucpf, 11, 0) as CPF,
 p.nmpessoa as Nome,

 Case capa.flativo
  when 'S' then 'ATIVO'
  when 'N' then 'INATIVO'
  else ' '
 end Situacao,
 upper(rtr.nmregimetrabalho) as RegimeTrabalho,
 upper(rt.nmrelacaotrabalho) as RelacaoTrabalho,
 upper(rp.nmregimeprevidenciario) RegimePrevidenciario,
 upper(tr.nmtiporegimeproprioprev) RegimePrevidenciarioProprio,

 d.decargocomissionado as CargoComissionado,
 c.deitemcarreira as CargoEfetivo,

 hu.nmunidadeorganizacional as UnidadeOrganizacional,
 cc.nucentrocusto CodigoCentroCusto,
 cc.nmcentrocusto CentroCusto,

 case capa.sgtipocredito
  when 'FI' then 'FUNDO FINANCEIRO'
  when 'PR' then 'FUNDO PREVIDENCIARIO'
  when 'GE' then 'GERAL - COMISSIONADOS'
  when 'GO' then 'GERAL - CLT/OUTROS'
  else ' '
 end Fundo,
 case capa.cdtipogeracaocredito when 1 then 'GERAL' when 2 then 'COMISSIONADOS' else '' end as TipoGeracaoCredito,

 case
  when pp.cdhistpensaoprevidenciaria is not null then 'PENSÃO PREVIDENCIÁRIA'
  when pnp.cdhistpensaonaoprev is not null then 'PENSÃO NÃO PREVIDENCIÁRIA'
  when capa.flativo = 'N' then 'INATIVO-APOSENTADO'
  when capa.cdregimetrabalho = 1 then 'CLT'
  when capa.cdrelacaotrabalho = 4 then 'AGENTE POLÍTICO'
  when cef.cdhistcargoefetivo is not null and capa.cdcargocomissionado is not null then 'EFETIVO + COMISSIONADO'  
  when capa.cdrelacaotrabalho = 3  then 'ACT'
  when capa.cdrelacaotrabalho = 5  then 'EFETIVO'
  when capa.cdrelacaotrabalho = 10 then 'EFETIVO À DISPOSICAO'
  when capa.cdrelacaotrabalho = 6  then 'COMISSIONADO'
  when capa.cdrelacaotrabalho = 2  then 'ESTAGIARIO'
  when cef.cdhistcargoefetivo is not null then 'EFETIVO' 
  else 'W-INDEFINIDO'
 end as Classificacao,

 case
  when rub.cdtiporubrica in (1, 2, 4, 10, 12) then '1-PROVENTO '
  when rub.cdtiporubrica in (5, 6, 8)         then '5-DESCONTO'
  when rub.cdtiporubrica = 9                  then '9-BASE DE CÁLCULO'
  else ' '
 end as GrupoRubrica,
 case rub.cdtiporubrica
  when  1 then '01-PROVENTO'
  when  2 then '02-DIF.PROVENTO'
  when  8 then '08-DEV.PROVENTO'
  when 10 then '10-EXFINDO.PROVENTO'
  when 12 then '12-EXFINDOANT.PROVENTO'
  when  5 then '05-DESCONTO'
  when  6 then '06-DIF.DESCONTO'
  when  4 then '04-DEV.DESCONTO'
  when  9 then '09-BASE'
  else ' '
 end as TipoRubrica,
 lpad(rub.nurubrica,4,'0') as Rubrica,
 lpad(pag.nusufixorubrica,2,'0') as Sufixo,
 rub.derubricaagrupamento as DeRubrica,
 case rub.flconsignacao when 'N' then 'NÃO' when 'S' then 'SIM' else '' end as Consignacao,
 ori.detipoorigemrubrica as Origem, 
 case when pag.cdexpressaoformcalc  is not null then 'SIM' 
      else 'NÃO'
 end as Tem_Formula,
 case when (lf.vlindice is null or lf.vlindice = 0) then 'NÃO'
      else 'SIM'
 end as Tem_Indice,
 case when (lf.vllancamentofinanceiro is null or lf.vllancamentofinanceiro = 0) then 'NÃO'
      else 'SIM'
 end as Valor_Informado,
 pag.nuparcela as Parcela,
 pag.vlindicerubrica as Indice,
 pag.vlpagamento as Valor

from epaghistoricorubricavinculo pag
inner join epagfolhapagamento f on f.cdfolhapagamento = pag.cdfolhapagamento and f.flcalculodefinitivo = 'S'
left join epagcapahistrubricavinculo capa on capa.cdfolhapagamento = pag.cdfolhapagamento and capa.cdvinculo = pag.cdvinculo
left join epagtipofolhapagamento tf on tf.cdtipofolhapagamento = f.cdtipofolhapagamento
left join vcadorgao o on o.cdorgao = f.cdorgao

left join ecadvinculo v on v.cdvinculo = pag.cdvinculo 
left join ecadpessoa p on p.cdpessoa = v.cdpessoa

left join ecadregimetrabalho rtr on rtr.cdregimetrabalho = capa.cdregimetrabalho
left join ecadrelacaotrabalho rt on rt.cdrelacaotrabalho = capa.cdrelacaotrabalho
left join ecadregimeprevidenciario rp on rp.cdregimeprevidenciario = v.cdregimeprevidenciario
left join ecadtiporegimeproprioprev tr on tr.cdtiporegimeproprioprev = v.cdtiporegimeproprioprev

left join ecadUnidadeOrganizacional u on u.cdunidadeorganizacional = capa.cdunidadeorganizacional
left join ecadHIstUnidadeOrganizacional hu on hu.cdUnidadeOrganizacional = u.cdUnidadeOrganizacional
       and hu.dtInicioVigencia <= last_day(sysdate) and (hu.Dtfimvigencia is null or hu.Dtfimvigencia >= last_day(sysdate))

left join ecadevolucaocargocomissionado d on d.cdcargocomissionado = capa.cdcargocomissionado
      and d.flanulado = 'N' and d.dtiniciovigencia <= last_day(sysdate) and (d.dtfimvigencia is null or d.dtfimvigencia >= last_day(sysdate))
left join ecadestruturacarreira es on es.cdestruturacarreira = capa.cdestruturacarreira
left join ecaditemcarreira c on c.cditemcarreira = es.cditemcarreira

left join ecadhistcargoefetivo cef on cef.cdvinculo = capa.cdvinculo and cef.flanulado = 'N' and cef.flprincipal = 'S'
  and cef.dtinicio <= last_day(sysdate) and (cef.dtfim is null or cef.dtfim >= last_day(sysdate))
left join epvdhistpensaoprevidenciaria pp on pp.cdvinculo = capa.cdvinculo and pp.flanulado = 'N'
left join epvdhistpensaonaoprev pnp on pnp.cdvinculobeneficiario = capa.cdvinculo and pnp.flanulado = 'N'

left join ecadcentrocusto cc on cc.cdcentrocusto = capa.cdcentrocusto

left join vpagrubricaagrupamento rub on rub.cdrubricaagrupamento = pag.cdrubricaagrupamento
left join epagtipoorigemrubrica ori on ori.cdtipoorigemrubrica = pag.cdtipoorigemrubrica
left join epaglancamentofinanceiro lf on lf.cdlancamentofinanceiro = pag.cdlancamentofinanceiro

where pag.cdvinculo = 29281
  and pag.cdfolhapagamento = 45968
  
order by rub.cdtiporubrica, rub.nurubrica, pag.nusufixorubrica;

--- Capa do Contra Cheque ---
select 
 o.sgorgao as Orgao,
 f.nuanoreferencia as Ano,
 f.numesreferencia as Mes,
 tf.nmtipofolhapagamento as Folha,
 upper(tc.nmtipocalculo) as Calculo,
 lpad(f.nusequencialfolha,2,'0') as SeqFolha,
 case f.flcalculodefinitivo when 'N' then 'NAO' when 'S' then 'SIM' else '' end as Definitivo,

 lpad(v.numatricula || '-' || v.nudvmatricula,9,0) as Matricula,
 lpad(p.nucpf, 11, 0) as CPF,
 p.nmpessoa as Nome,
 p.dtnascimento as DataNascimento,
 trunc((sysdate - p.dtnascimento) / 365) as Idade,
 p.flsexo as Sexo,
 v.dtadmissao as DataAdmissao,
 v.dtinclusao as DataInclusao,

 Case capa.flativo
  when 'S' then 'ATIVO'
  when 'N' then 'INATIVO'
  else ' '
 end as Situacao,
 upper(rtr.nmregimetrabalho) as RegimeTrabalho,
 upper(rt.nmrelacaotrabalho) as RelacaoTrabalho,
 upper(rp.nmregimeprevidenciario) RegimePrevidenciario,
 upper(tr.nmtiporegimeproprioprev) RegimePrevidenciarioProprio,
 
 hu.nmunidadeorganizacional as UnidadeOrganizacional,
 cc.nucentrocusto CodigoCentroCusto,
 cc.nmcentrocusto CentroCusto,

 cr.deitemcarreira as Carreira,
 c.deitemcarreira as CargoEfetivo,
 capa.nugruposalarial || capa.nunivelcef || capa.nureferenciacef as NivelAtual,
 d.decargocomissionado as CargoComissionado,
 capa.nureferenciacco || capa.nunivelcco as NivelComissionado,

 decode(mdf.demotivoafastdefinitivo, null, mtp.demotivoafasttemporario, mdf.demotivoafastdefinitivo) Afastamento,

 case capa.sgtipocredito
  when 'FI' then 'FUNDO FINANCEIRO'
  when 'PR' then 'FUNDO PREVIDENCIARIO'
  when 'GE' then 'GERAL - COMISSIONADOS'
  when 'GO' then 'GERAL - CLT/OUTROS'
  else ' '
 end Fundo,
 cc.sgarquivocredito as SiglaArquivoCredito,
 case capa.cdtipogeracaocredito when 1 then 'GERAL' when 2 then 'COMISSIONADOS' else '' end as TipoGeracaoCredito,
 capa.nufaixacredito as FaixaCredito,

 case
  when pp.cdhistpensaoprevidenciaria is not null then 'PENSÃO PREVIDENCIÁRIA'
  when pnp.cdhistpensaonaoprev is not null then 'PENSÃO NÃO PREVIDENCIÁRIA'
  when capa.flativo = 'N' then 'INATIVO-APOSENTADO'
  when capa.cdregimetrabalho = 1 then 'CLT'
  when capa.cdrelacaotrabalho = 4 then 'AGENTE POLÍTICO'
  when cef.cdhistcargoefetivo is not null and capa.cdcargocomissionado is not null then 'EFETIVO + COMISSIONADO'  
  when capa.cdrelacaotrabalho = 3  then 'ACT'
  when capa.cdrelacaotrabalho = 5  then 'EFETIVO'
  when capa.cdrelacaotrabalho = 10 then 'EFETIVO À DISPOSICAO'
  when capa.cdrelacaotrabalho = 6  then 'COMISSIONADO'
  when capa.cdrelacaotrabalho = 2  then 'ESTAGIARIO'
  when cef.cdhistcargoefetivo is not null then 'EFETIVO' 
  else 'W-INDEFINIDO'
 end as Classificacao,
 
 capa.vlproventos as Proventos,
 capa.vldescontos as Descontos,
 nvl(capa.vlproventos, 0) - nvl(capa.vldescontos, 0) as Liquido,

 case
  when nvl(v.cdcentrocusto, 0) = 0           then 'Centro de custo nulo no vinculo'
  when nvl(capa.cdcentrocusto, 0) = 0        then 'Centro de custo nulo na capa do pagamento'
  when capa.sgtipocredito is null            then 'Sigla do tipo de credito nula na capa do pagamento'
  when capa.flativo is null                  then 'Nao ha indicativo de ativou ou inativo na capa do pagamento'
  when cc.sgarquivocredito is null           then 'Sigla do arquvio de credito nula na capa do pagamento'
  when nvl(capa.CdTipoGeracaoCredito, 0) = 0 then 'Tipo de geracao de credito nulo na capa do pagamento' 
  when nvl(capa.NuFaixaCredito, 0) = 0       then 'Fixa de credito nula na capa do pagamento' 
  else null
 end Observacao

from epagcapahistrubricavinculo capa
inner join epagfolhapagamento f on f.cdfolhapagamento = capa.cdfolhapagamento and f.flcalculodefinitivo = 'S'
inner join epagtipofolhapagamento tf on tf.cdtipofolhapagamento = f.cdtipofolhapagamento
inner join epagtipocalculo tc on tc.cdtipocalculo = f.cdtipocalculo
inner join vcadorgao o on o.cdorgao = f.cdorgao

inner join ecadvinculo v on v.cdvinculo = capa.cdvinculo
inner join ecadpessoa p on p.cdpessoa = v.cdpessoa

left join ecadregimetrabalho rtr on rtr.cdregimetrabalho = capa.cdregimetrabalho
left join ecadrelacaotrabalho rt on rt.cdrelacaotrabalho = capa.cdrelacaotrabalho
left join ecadregimeprevidenciario rp on rp.cdregimeprevidenciario = v.cdregimeprevidenciario
left join ecadtiporegimeproprioprev tr on tr.cdtiporegimeproprioprev = v.cdtiporegimeproprioprev

inner join ecadunidadeorganizacional u on u.cdunidadeorganizacional = capa.cdunidadeorganizacional
inner join ecadhistunidadeorganizacional hu on hu.cdunidadeorganizacional = u.cdunidadeorganizacional
       and hu.dtiniciovigencia < last_day(sysdate) + 1 and (hu.dtfimvigencia is null or hu.dtfimvigencia > last_day(sysdate))

inner join ecadcentrocusto cc on cc.cdcentrocusto = capa.cdcentrocusto

left join ecadhistcargoefetivo cef on cef.cdvinculo = capa.cdvinculo and cef.flanulado = 'N' and cef.flprincipal = 'S'
      and (cef.dtinicio < last_day(sysdate) + 1) and (cef.dtfim is null or cef.dtfim > last_day(sysdate))
left join ecadestruturacarreira es on es.cdestruturacarreira = cef.cdestruturacarreira
left join ecaditemcarreira c on c.cditemcarreira = es.cditemcarreira
left join ecadestruturacarreira cp on cp.cdestruturacarreira = es.cdestruturacarreirapai
left join ecaditemcarreira cr on cr.cditemcarreira = cp.cditemcarreira

left join ecadevolucaocargocomissionado d on d.cdcargocomissionado = capa.cdcargocomissionado  and d.flanulado = 'N'
      and (d.dtiniciovigencia < last_day(sysdate) + 1) and (d.dtfimvigencia is null or d.dtfimvigencia > last_day(sysdate))
left join ecadestruturacarreira es on es.cdestruturacarreira = capa.cdestruturacarreira
left join ecaditemcarreira c on c.cditemcarreira = es.cditemcarreira

left join epvdhistpensaoprevidenciaria pp on pp.cdvinculo = capa.cdvinculo and pp.flanulado = 'N'
left join epvdhistpensaonaoprev pnp on pnp.cdvinculobeneficiario = capa.cdvinculo and pnp.flanulado = 'N'

left  join eafahistmotivoafastdef mdf on mdf.cdmotivoafastdefinitivo = capa.cdmotivoafastdefinitivo and mdf.dtfimvigencia is null
left  join eafahistmotivoafasttemp mtp on mtp.cdmotivoafasttemporario = capa.cdmotivoafasttemporario and mtp.dtfimvigencia is null

where capa.cdvinculo = 29281
  and capa.cdfolhapagamento = 45968;
