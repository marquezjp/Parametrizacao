select count(*) from (
select
 lpad(v.numatricula,7,0) || '-' || v.nudvmatricula || '-' || lpad(v.nuseqmatricula,2,0) as Matricula,
 p.nucpf as CPF,
 p.nmpessoa as Nome,
 lpad(rub.cdtiporubrica,2,'0') || '-' || lpad(rub.nurubrica,4,'0') || '-' || lpad(bc.nusufixo,2,0) as Rubrica,
 rub.derubricaagrupamento as DeRubrica,
 cons.flgeridascconsig as GeriadaConsig,
 upper(ori.nmorigemconsignacao) as OrigemConsignacao,
 bc.nuanoreferenciainicial || lpad(bc.numesreferenciainicial,2,0) as ReferenciaInicial,
 bc.nuanoreferenciafinal || lpad(bc.numesreferenciafinal,2,0) as ReferenciaFinal,
 bc.dtiniciodesconto as DataInicio,
 bc.nuparcelas as Parcelas,
 bc.vlmensalcontratado as Valor,
 bc.cdbaseconsignacao as BaseConsignacao
from epagbaseconsignacao bc
inner join ecadvinculo v on v.cdvinculo = bc.cdvinculo
inner join ecadorgao o on o.cdorgao = v.cdorgao
inner join ecadpessoa p on p.cdpessoa = v.cdpessoa
left join epagconsignacao cons on cons.cdconsignacao = bc.cdconsignacao
inner join vpagrubricaagrupamento rub on rub.cdagrupamento = o.cdagrupamento and rub.cdrubrica = cons.cdrubrica
inner join epagorigemconsignacao ori on ori.cdorigemconsignacao = bc.cdorigemconsignacao
where bc.nuanoreferenciafinal is null and bc.numesreferenciafinal is null
  and o.cdagrupamento = 19
order by p.nucpf, v.numatricula, v.nuseqmatricula, rub.cdtiporubrica, rub.nurubrica, bc.nusufixo
)  
;
