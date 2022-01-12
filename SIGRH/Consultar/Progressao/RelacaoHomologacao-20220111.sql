define bienio = to_number(2019);

select
 --v.cdvinculo,
 --cef.cdvinculo,
 --nivrefcef.cdhistcargoefetivo,
 o.sgorgao as ORGAO,
 lpad(v.numatricula || '-' || v.nudvmatricula,9,0) as MATRICULA,
 lpad(p.nucpf,11,0) as CPF,
 p.nmpessoa as NOME_COMPLETO,
 v.dtadmissao as DATA_ADMISSAO,
 --v.dtdesligamento as DATA_DESLIGAMENTO,
 itemnv1.deitemcarreira as CARREIRA,
 item.deitemcarreira as CARGO,
 cef.nugruposalarial || nivrefcef.nunivelpagamento || nivrefcef.nureferenciapagamento as NIVEL_REFERENCIA,
 
 case when v.dtadmissao < '05/06/1998' then 2000 else extract(year from v.dtadmissao) end
 + case when v.dtadmissao < '05/06/1998' then 0 else 3 end
 as AnoInicioBienios,
 
 case when mod(&bienio - (  case when v.dtadmissao < '05/06/1998' then 2000 else extract(year from v.dtadmissao) end
                          + case when v.dtadmissao < '05/06/1998' then 0 else 3 end),2) = 0 then 'BIENIO ' || (&bienio - 2) || '-' || &bienio
      else 'SEM DIREITO AO BIENIO ' || (&bienio - 2) || '-' || &bienio
 end as HaptoBienio,

 --case
 --  when trunc((&bienio - (  case when v.dtadmissao < '05/06/1998' then 2000 else extract(year from v.dtadmissao) end
 --                         + case when v.dtadmissao < '05/06/1998' then 0 else 3 end)) / 2) < 0 then 'PERIODO DE MERITO NAO INICIADO'
 --  when trunc((&bienio - (  case when v.dtadmissao < '05/06/1998' then 2000 else extract(year from v.dtadmissao) end
 --                         + case when v.dtadmissao < '05/06/1998' then 0 else 3 end)) / 2) > 5 then 'MERITOS COMPLETOS'
 --  else 'EM PERIODO DE MERITOS'
 --end as DireitoBienio,

 case
   when trunc((&bienio - (  case when v.dtadmissao < '05/06/1998' then 2000 else extract(year from v.dtadmissao) end
                          + case when v.dtadmissao < '05/06/1998' then 0 else 3 end)) / 2) < 0 then 0
   when trunc((&bienio - (  case when v.dtadmissao < '05/06/1998' then 2000 else extract(year from v.dtadmissao) end
                          + case when v.dtadmissao < '05/06/1998' then 0 else 3 end)) / 2) > 5 then 5
   else trunc((&bienio - (  case when v.dtadmissao < '05/06/1998' then 2000 else extract(year from v.dtadmissao) end
                          + case when v.dtadmissao < '05/06/1998' then 0 else 3 end)) / 2)
 end
 as Bienios,
 
 case
   when trunc((&bienio - (  case when v.dtadmissao < '05/06/1998' then 2000 else extract(year from v.dtadmissao) end
                          + case when v.dtadmissao < '05/06/1998' then 0 else 3 end)) / 2) < 0 then 0
   when trunc((&bienio - (  case when v.dtadmissao < '05/06/1998' then 2000 else extract(year from v.dtadmissao) end
                          + case when v.dtadmissao < '05/06/1998' then 0 else 3 end)) / 2) > 5 then 5
   else trunc((&bienio - (  case when v.dtadmissao < '05/06/1998' then 2000 else extract(year from v.dtadmissao) end
                          + case when v.dtadmissao < '05/06/1998' then 0 else 3 end)) / 2)
 end - (nivrefcef.nureferenciapagamento - 1)
 as BieniosPendentes,
 
 case 
   when nivrefcef.nureferenciapagamento = 6 then 'MAXIMO CONCEDIDO'
   when nivrefcef.nureferenciapagamento - 1 <
     case
       when trunc((&bienio - (  case when v.dtadmissao < '05/06/1998' then 2000 else extract(year from v.dtadmissao) end
                              + case when v.dtadmissao < '05/06/1998' then 0 else 3 end)) / 2) < 0 then 0
       when trunc((&bienio - (  case when v.dtadmissao < '05/06/1998' then 2000 else extract(year from v.dtadmissao) end
                              + case when v.dtadmissao < '05/06/1998' then 0 else 3 end)) / 2) > 5 then 5
       else trunc((&bienio - (  case when v.dtadmissao < '05/06/1998' then 2000 else extract(year from v.dtadmissao) end
                              + case when v.dtadmissao < '05/06/1998' then 0 else 3 end)) / 2)
     end
     then 'NAO CONCEDIDO'
   else 'CONCEDIDO'
 end
 as Concedido

from ecadvinculo v
inner join ecadpessoa p on p.cdpessoa = v.cdpessoa
inner join vcadorgao o on o.cdorgao = v.cdorgao

inner join ecadhistcargoefetivo cef on cef.cdvinculo = v.cdvinculo and flprincipal = 'S' 
                                   and cef.dtfim is null and cef.flanulado = 'N'

inner join ecadestruturacarreira estr on estr.cdestruturacarreira = cef.cdestruturacarreira
inner join ecaditemcarreira item on item.cditemcarreira = estr.cditemcarreira

inner join ecadestruturacarreira estrnv1 on estrnv1.cdestruturacarreira = estr.cdestruturacarreirapai
inner join ecaditemcarreira itemnv1 on itemnv1.cditemcarreira = estrnv1.cditemcarreira and itemnv1.deitemcarreira like 'MAGISTERIO%'

inner join ecadhistnivelrefcef nivrefcef on nivrefcef.cdhistcargoefetivo = cef.cdhistcargoefetivo
                                        and nivrefcef.dtfim is null and nivrefcef.flanulado = 'N'

where o.sgorgao = 'SEMED'
  and v.dtdesligamento is null
  --and v.numatricula = 0936919
  
  and mod(&bienio - (  case when v.dtadmissao < '05/06/1998' then 2000 else extract(year from v.dtadmissao) end
                     + case when v.dtadmissao < '05/06/1998' then 0 else 3 end),2) = 0

  and trunc((&bienio - (  case when v.dtadmissao < '05/06/1998' then 2000 else extract(year from v.dtadmissao) end
                        + case when v.dtadmissao < '05/06/1998' then 0 else 3 end)) / 2) > 0

order by
 o.sgorgao,
 p.nucpf,
 v.numatricula