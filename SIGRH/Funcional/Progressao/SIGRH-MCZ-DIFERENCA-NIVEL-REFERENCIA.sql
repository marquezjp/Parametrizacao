select
 o.sgorgao as Orgao,
 lpad(v.numatricula,7,0) || '-' || v.nudvmatricula as Matricula,
 --pagatu.cdorgao,
 --pagatu.cdvinculo,
 pagatu.NivelReferencia as PagAtuNivelReferencia,
 pagant.NivelReferencia as PagAntNivelReferencia,
 --((ascii(substr(pagatu.NivelReferencia,5,1)) - 64 - 1) * 6) + to_number(substr(pagatu.NivelReferencia,6,2)) as PagAtuNivel,
 --((ascii(substr(pagant.NivelReferencia,5,1)) - 64 - 1) * 6) + to_number(substr(pagant.NivelReferencia,6,2)) as PagAntNivel,
   (((ascii(substr(pagatu.NivelReferencia,5,1)) - 64 - 1) * 6) + to_number(substr(pagatu.NivelReferencia,6,2)))
 - (((ascii(substr(nvl(pagant.NivelReferencia,'    A01'),5,1)) - 64 - 1) * 6) + to_number(substr(nvl(pagant.NivelReferencia,'    A01'),6,2))) as NiveisProgressao,
       
 nvl2(pagant.cdvinculo, '', 'SEM PAGAMENTO ANTERIOR') as Observacao
from (
select
 f.cdorgao,
 pag.cdvinculo,
 pag.nugruposalarial || pag.nunivelcef || pag.nureferenciacef as NivelReferencia
 
from epagcapahistrubricavinculo pag
inner join epagfolhapagamento f on f.cdfolhapagamento = pag.cdfolhapagamento
                               and f.nuanomesreferencia = '202111' and f.flcalculodefinitivo = 'S'
                               and f.cdtipofolhapagamento = 2 and f.cdtipocalculo = 1
where 
      pag.nugruposalarial is not null and pag.nugruposalarial != '0000' and pag.nugruposalarial != '0'
  and pag.nunivelcef      is not null and pag.nunivelcef      != '0'
  and pag.nureferenciacef is not null and pag.nureferenciacef != 0
) pagatu
left join (
select
 f.cdorgao,
 pag.cdvinculo,
 pag.nugruposalarial || pag.nunivelcef || pag.nureferenciacef as NivelReferencia
 
from epagcapahistrubricavinculo pag
inner join epagfolhapagamento f on f.cdfolhapagamento = pag.cdfolhapagamento
                               and f.nuanomesreferencia = '202109' and f.flcalculodefinitivo = 'S'
                               and f.cdtipofolhapagamento = 2 and f.cdtipocalculo = 1
where 
      pag.nugruposalarial is not null and pag.nugruposalarial != '0000' and pag.nugruposalarial != '0'
  and pag.nunivelcef      is not null and pag.nunivelcef      != '0'
  and pag.nureferenciacef is not null and pag.nureferenciacef != 0
) pagant on pagant.cdorgao =  pagatu.cdorgao
        and pagant.cdvinculo =  pagatu.cdvinculo

inner join ecadvinculo v on v.cdvinculo = pagatu.cdvinculo
inner join vcadorgao o on o.cdorgao = v.cdorgao
        
--where pagatu.NivelReferencia != pagant.NivelReferencia
--  and pagatu.cdorgao = 40
where (((ascii(substr(pagatu.NivelReferencia,5,1)) - 64 - 1) * 6) + to_number(substr(pagatu.NivelReferencia,6,2))) !=
      (((ascii(substr(nvl(pagant.NivelReferencia,'    A01'),5,1)) - 64 - 1) * 6) + to_number(substr(nvl(pagant.NivelReferencia,'    A01'),6,2)))
  --and ((((ascii(substr(pagatu.NivelReferencia,5,1)) - 64 - 1) * 6) + to_number(substr(pagatu.NivelReferencia,6,2)) - 1) !=
  --    (((ascii(substr(pagant.NivelReferencia,5,1)) - 64 - 1) * 6) + to_number(substr(pagant.NivelReferencia,6,2)))
  --    and pagatu.cdorgao = 40)
  --and pagant.cdvinculo is not null
  --and pagatu.cdorgao != 40
      
order by o.sgorgao, v.numatricula