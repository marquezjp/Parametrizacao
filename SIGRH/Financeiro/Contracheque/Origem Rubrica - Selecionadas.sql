select 
 o.sgorgao as Orgao,
 f.nuanoreferencia as Ano,
 f.numesreferencia as Mes,
 tf.nmtipofolhapagamento as Folha,
 case f.cdtipofolhapagamento
  when 2 then 'MENSAL'
  when 4 then 'FERIAS'
  when 5 then 'ESTAGIARIO'
  when 6 then '13 SALARIO'
  when 7 then 'ADIANT 13 SALARIO'
  else to_char(f.cdtipofolhapagamento)
 end as TipoFolha,
 case f.cdtipocalculo
  when 1 then 'NORMAL'
  when 5 then 'SUPLEMENTAR'
  else to_char(f.cdtipocalculo)
 end as TipoCalculo,
 f.nusequencialfolha as SeqFolha,
 f.flcalculodefinitivo as Definitivo,

 lpad(v.numatricula, 7, 0)||'-'||v.nudvmatricula as Matricula,
 lpad(p.nucpf, 11, 0) as CPF,
 p.nmpessoa as Nome,

 Case capa.flativo
  when 'S' then 'ATIVO'
  when 'N' then 'INATIVO'
  else ' '
 end Situacao,
 rtr.nmregimetrabalho as RegimeTrabalho,
 rt.nmrelacaotrabalho as RelacaoTrabalho,
 rp.nmregimeprevidenciario RegimePrevidenciario,
 tr.nmtiporegimeproprioprev RegimePrevidenciarioProprio, 

 d.decargocomissionado as CargoComissionado,
 c.deitemcarreira as CargoEfetivo,

 hu.nmunidadeorganizacional as UnidadeOrganizacional,
 cc.nucentrocusto CodigoCentroCusto,
 cc.nmcentrocusto CentroCusto,

 case capa.sgtipocredito
  when 'FI' then 'Fundo Financeiro'
  when 'PR' then 'Fundo Previdenciario'
  when 'GE' then 'Geral - Comissionados'
  when 'GO' then 'Geral - CLT/Outros'
  else ' '
 end Fundo,

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
 rub.flconsignacao Consignacao,
 ori.detipoorigemrubrica as Origem, 
 case when pag.cdexpressaoformcalc  is not null then 'SIM' 
      when pagr.cdexpressaoformcalc is not null then 'SIM' 
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
inner join epagcapahistrubricavinculo capa on capa.cdfolhapagamento = pag.cdfolhapagamento and capa.cdvinculo = pag.cdvinculo
inner join epagfolhapagamento f on f.cdfolhapagamento = pag.cdfolhapagamento and f.flcalculodefinitivo = 'S'
inner join epagtipofolhapagamento tf on tf.cdtipofolhapagamento = f.cdtipofolhapagamento
inner join vcadorgao o on o.cdorgao = f.cdorgao

inner join ecadvinculo v on v.cdvinculo = pag.cdvinculo 
inner join ecadpessoa p on p.cdpessoa = v.cdpessoa

left join ecadregimetrabalho rtr on rtr.cdregimetrabalho = capa.cdregimetrabalho
left join ecadrelacaotrabalho rt on rt.cdrelacaotrabalho = capa.cdrelacaotrabalho
left join ecadregimeprevidenciario rp on rp.cdregimeprevidenciario = v.cdregimeprevidenciario
left join ecadtiporegimeproprioprev tr on tr.cdtiporegimeproprioprev = v.cdtiporegimeproprioprev

inner join ecadUnidadeOrganizacional u on u.cdunidadeorganizacional = capa.cdunidadeorganizacional
inner join ecadHIstUnidadeOrganizacional hu on hu.cdUnidadeOrganizacional = u.cdUnidadeOrganizacional
       and hu.dtInicioVigencia < last_day(sysdate) + 1 and (hu.Dtfimvigencia is null or hu.Dtfimvigencia > last_day(sysdate))

left  join ecadevolucaocargocomissionado d on d.cdcargocomissionado = capa.cdcargocomissionado
left  join ecadestruturacarreira es on es.cdestruturacarreira = capa.cdestruturacarreira
left  join ecaditemcarreira c on c.cditemcarreira = es.cditemcarreira

left join ecadhistcargoefetivo cef on cef.cdvinculo = capa.cdvinculo and cef.flanulado = 'N'
left join epvdhistpensaoprevidenciaria pp on pp.cdvinculo = capa.cdvinculo and pp.flanulado = 'N'
left join epvdhistpensaonaoprev pnp on pnp.cdvinculobeneficiario = capa.cdvinculo and pnp.flanulado = 'N'

inner join ecadcentrocusto cc on cc.cdcentrocusto = capa.cdcentrocusto

inner join vpagrubricaagrupamento rub on rub.cdrubricaagrupamento = pag.cdrubricaagrupamento
left  join epagtipoorigemrubrica ori on ori.cdtipoorigemrubrica = pag.cdtipoorigemrubrica
left  join epaglancamentofinanceiro lf on lf.cdlancamentofinanceiro = pag.cdlancamentofinanceiro

-- contracheque da relação de vínculo de efetivo
left  join epaghistoricorubricarelvinc pagr 
        on pagr.cdfolhapagamento     = pag.cdfolhapagamento 
       and pagr.cdvinculo            = pag.cdvinculo
       and pagr.cdrubricaagrupamento = pag.cdrubricaagrupamento
       and pagr.nusufixorubrica      = pagr.nusufixorubrica
       and pagr.cdhistcargoefetivo is not null

where f.nuanoreferencia = 2020
  --and f.numesreferencia in (3, 4, 5, 6, 7, 8)
  --and f.cdtipofolhapagamento = '2' --- 2-Normal  4-Férias  5-Estagiário  6-13.salário  7-Adiantamento 13.sal
  --and (f.cdtipocalculo = '1' OR f.cdtipocalculo = '5')
  and o.sgorgao = 'SEMGE'