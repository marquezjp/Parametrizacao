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
 end Situacao,
 rtr.nmregimetrabalho as RegimeTrabalho,
 rt.nmrelacaotrabalho as RelacaoTrabalho,
 rp.nmregimeprevidenciario RegimePrevidenciario,
 tr.nmtiporegimeproprioprev RegimePrevidenciarioProprio,
 
 hu.nmunidadeorganizacional as UnidadeOrganizacional,
 cc.nucentrocusto CodigoCentroCusto,
 cc.nmcentrocusto CentroCusto,

 d.decargocomissionado as CargoComissionado,
 capa.nureferenciacco || capa.nunivelcco as NivelComissionado,
 c.deitemcarreira as CargoEfetivo,
 capa.nugruposalarial || capa.nunivelcef || capa.nureferenciacef as NivelAtual,

 decode(mdf.demotivoafastdefinitivo, null, mtp.demotivoafasttemporario, mdf.demotivoafastdefinitivo) Afastamento,

 case capa.sgtipocredito
  when 'FI' then 'Fundo Financeiro'
  when 'PR' then 'Fundo Previdenciario'
  when 'GE' then 'Geral - Comissionados'
  when 'GO' then 'Geral - CLT/Outros'
  else ' '
 end Fundo,
 cc.sgarquivocredito as SiglaCredito,
 capa.CdTipoGeracaoCredito as TipoGeracaoCredito,
 capa.NuFaixaCredito as FaixaCredito,

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

left join ecadevolucaocargocomissionado d on d.cdcargocomissionado = capa.cdcargocomissionado
left join ecadestruturacarreira es on es.cdestruturacarreira = capa.cdestruturacarreira
left join ecaditemcarreira c on c.cditemcarreira = es.cditemcarreira

left join ecadhistcargoefetivo cef on cef.cdvinculo = capa.cdvinculo and cef.flanulado = 'N'
left join epvdhistpensaoprevidenciaria pp on pp.cdvinculo = capa.cdvinculo and pp.flanulado = 'N'
left join epvdhistpensaonaoprev pnp on pnp.cdvinculobeneficiario = capa.cdvinculo and pnp.flanulado = 'N'

left  join eafahistmotivoafastdef mdf on mdf.cdmotivoafastdefinitivo = capa.cdmotivoafastdefinitivo and mdf.dtfimvigencia is null
left  join eafahistmotivoafasttemp mtp on mtp.cdmotivoafasttemporario = capa.cdmotivoafasttemporario and mtp.dtfimvigencia is null

where nvl(capa.vlproventos, 0) > 0
  and f.nuanoreferencia = 2020
  and o.sgorgao = 'SEMGE'

order by 3, 2, 1