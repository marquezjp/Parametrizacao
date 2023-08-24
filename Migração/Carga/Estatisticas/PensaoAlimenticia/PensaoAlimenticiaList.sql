select --count(1) as qtde
--/*
 a.sgagrupamento as Agrupamento,
 o.sgorgao as Orgao,
 lpad(v.numatricula,7,0) || '-' || v.nudvmatricula || '-' || lpad(v.nuseqmatricula,2,0) as Matricula,
 lpad(m.numatriculalegado,9,0) as MatriculaLegado,
 lpad(p.nucpf, 11, 0) as CPF,
 p.nmpessoa as Nome,
 lpad(pben.nucpf, 11, 0) as CPFBeneficiario,
 pben.nmpessoa as NomeBeneficiario,
 lpad(prep.nucpf, 11, 0) as CPFRepresentante,
 prep.nmpessoa as NomeRepresentante,
 lpad(pa.nusequencial,2,0) as nusequencial,
 tprec.nmtiporecebedor,
 pahist.dtiniciovigencia as InicioVigencia,
 pahist.dtfimvigencia as FimVigencia,
 case when rub.nurubrica is null then null else lpad(rub.cdtiporubrica,2,0) || '-' || lpad(rub.nurubrica,4,0) end as Rubrica,
-- tppa.nmtipopensaoalimenticia,
-- tpparub.nmtipopensaoalimenticia as TipoPensaoAlimenticia,
 parub.vlpercentpensao as IndicePensao,
 parub.vlfixo as ValorPensao
--*/
from epensentencajudicial pa
left join epenhistsentencajudicial pahist on pahist.cdsentencajudicial = pa.cdsentencajudicial
left join epensentencarubrica parub on parub.cdhistsentencajudicial = pahist.cdhistsentencajudicial
left join epenhisttipopensaorubrica tpparubh on tpparubh.cdhisttipopensaorubrica = parub.cdhisttipopensaorubrica
inner join ecadvinculo v on v.cdvinculo = pa.cdvinculo
left join emigmatricula m on m.numatricula = v.numatricula and m.nuseqmatricula = v.nuseqmatricula
inner join vcadorgao o on o.cdorgao = v.cdorgao
inner join ecadagrupamento a on a.cdagrupamento = o.cdagrupamento
inner join ecadpessoa p on p.cdpessoa = v.cdpessoa
left join ecadpessoa pben on pben.cdpessoa = pa.cdpessoa
left join epenpessoapensao prep on prep.cdpessoapensao = pa.cdpessoapensao
left join epentiporecebedor tprec on tprec.cdtiporecebedor = pa.cdtiporecebedor
left join epentipopensaoalimenticia tppa on tppa.cdagrupamento = o.cdagrupamento and tppa.cdtipopensaoalimenticia = pa.cdtipopensaoalimenticia
left join epagrubricaagrupamento rubagrup on rubagrup.cdrubricaagrupamento = tpparubh.cdrubricaagrupamento
left join epagrubrica rub on rub.cdrubrica = rubagrup.cdrubrica
left join epenhisttipopensao tppahist on tppahist.cdhisttipopensao = tpparubh.cdhisttipopensao
left join epentipopensaoalimenticia tpparub on tpparub.cdagrupamento = o.cdagrupamento and tpparub.cdtipopensaoalimenticia = tppahist.cdtipopensaoalimenticia
where o.cdagrupamento = 1
--  and p.nucpf = pben.nucpf
--  and lpad(m.numatriculalegado,9,0) = 020090060
--  and lpad(p.nucpf, 11, 0) = 03669980210
--  and rub.nurubrica is null
;
/
