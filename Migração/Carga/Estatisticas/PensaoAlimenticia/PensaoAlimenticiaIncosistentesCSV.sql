with
depara as (
select de, para
from json_table('{"depara":[
{"de":"CASACIVIL", "para":"CASA CIVIL"},
{"de":"CERIM", "para":"CASA CIVIL"},
{"de":"CSAMILITAR", "para":"CASA MILITAR"},
{"de":"BM", "para":"CBM-RR"},
{"de":"COGERR", "para":"COGER"},
{"de":"DEFPUB", "para":"DPE-RR"},
{"de":"IDEFER", "para":"IDEFER-RR"},
{"de":"IPEM", "para":"IPEM-RR"},
{"de":"CONJUCERR", "para":"JUCERR"},
{"de":"OGERR", "para":"OGE-RR"},
{"de":"POLCIVIL", "para":"PC-RR"},
{"de":"PROGE", "para":"PGE-RR"},
{"de":"PM", "para":"PM-RR"},
{"de":"CONCULT", "para":"SECULT"},
{"de":"CONEDUC", "para":"SEED"},
{"de":"PRODEB", "para":"SEED"},
{"de":"CONREFIS", "para":"SEFAZ"},
{"de":"PENSIONIST", "para":"SEGAD"},
{"de":"CONRODE", "para":"SEINF"},
{"de":"CONANTD", "para":"SEJUC"},
{"de":"CONPEN", "para":"SEJUC"},
{"de":"SEEPE", "para":"SEPE"},
{"de":"PLANTONIST", "para":"SESAU"},
{"de":"SEURB", "para":"SEURB-RR"},
{"de":"UNIVIR", "para":"UNIVIRR"},
{"de":"VICE GOV", "para":"VICE-GOV"},
]}', '$.depara[*]'
columns (de, para)
)),
orgaos as (
select upper(trim(sgagrupamento)) as sgagrupamento, upper(trim(sgorgao)) as sgorgao
from emigorgaocsv
),
cad as (
select
-- o.sgagrupamento,
 case o.sgagrupamento
  when 'ADM-DIR' then 'ADM-DIRETA'
  when 'MILITAR' then 'MILITAR'
  else 'ADM-INDIRETA'
 end as Agrupamento,
 o.sgorgao as Orgao,
 lpad(trim(pa.numatriculalegado),10,0) as MatriculaLegado,
 lpad(trim(pa.nucpf),11,0) as CPF,
 lpad(trim(pa.nucpfbeneficiario),11,0) as CPFBeneficiario,
 case when pa.nucpfbeneficiario = pa.nucpfrepresentante then null else lpad(trim(pa.nucpfrepresentante),11,0) end as CPFRepresentante,
 lpad(trim(pa.nurubrica),4,0) as Rubrica,
 case when pa.dtiniciovigencia = 'NULL' then null else to_char(to_date(pa.dtiniciovigencia, 'DD/MM/YYYY'), 'YYYYMM') end AnoMesInicio,
 case when pa.dtfimvigencia = 'NULL' then null else to_char(to_date(pa.dtfimvigencia, 'DD/MM/YYYY'), 'YYYYMM') end AnoMesFim
from emigpensaoalimenticiacsv pa
left join depara on upper(trim(depara.de)) = upper(trim(pa.sgorgao))
left join orgaos o on upper(trim(o.sgorgao)) = nvl(upper(trim(depara.para)),upper(trim(pa.sgorgao)))
),
pag as (
select
-- o.sgagrupamento,
 case o.sgagrupamento
  when 'ADM-DIR' then 'ADM-DIRETA'
  when 'MILITAR' then 'MILITAR'
  else 'ADM-INDIRETA'
 end as Agrupamento,
 o.sgorgao as Orgao,
 lpad(trim(pag.numatriculalegado),10,0) as MatriculaLegado,
 lpad(trim(pag.nucpf),11,0) as CPF,
 case when pag.nucpfbenfpensaoalimento is null or pag.nucpfbenfpensaoalimento = 'NULL' then null
 else lpad(trim(pag.nucpfbenfpensaoalimento),11,0) end as CPFBeneficiario,
 lpad(trim(pag.nurubrica),4,0) as Rubrica,
 min(lpad(trim(pag.nuanoreferencia),4,0) || lpad(trim(pag.numesreferencia),2,0)) as AnoMesInicio,
 max(lpad(trim(pag.nuanoreferencia),4,0) || lpad(trim(pag.numesreferencia),2,0)) as AnoMesFim
from emigcontrachequecsv pag
left join depara on upper(trim(depara.de)) = upper(trim(pag.sgorgao))
left join orgaos o on upper(trim(o.sgorgao)) = nvl(upper(trim(depara.para)),upper(trim(pag.sgorgao)))
where lpad(trim(pag.nurubrica),4,0) in ('0122', '0123', '0124', '0125', '0126', '0127', '0129', '0204', '0208', '0214',
                                    '0258', '0586', '0612', '0712', '0794', '0913', '0922', '1308', '1508', '1586',
                                    '1817', '4131', '4205', '4751', '7710', '9950', '9951', '9952', '9953', '9954',
                                    '9969', '9970', '9971', '9972', '9986', '9988')
group by 
 o.sgagrupamento,
 o.sgorgao,
 lpad(trim(pag.numatriculalegado),10,0),
 lpad(trim(pag.nucpf),11,0),
 case when pag.nucpfbenfpensaoalimento is null or pag.nucpfbenfpensaoalimento = 'NULL' then null
 else lpad(trim(pag.nucpfbenfpensaoalimento),11,0) end,
 lpad(trim(pag.nurubrica),4,0)
)

--- Identificar os Cadastros de Pensão Alimentícia sem Ocorrencia de Pagamentos
select
 cad.Agrupamento,
 cad.CPF,
 cad.Rubrica,
 cad.Orgao,
 cad.MatriculaLegado,
 cad.CPFBeneficiario,
 cad.CPFRepresentante,
 cad.AnoMesInicio,
 cad.AnoMesFim,
 null as AnoMesInicioDif,
 null as AnoMesFimDif,
 'Cadastro de Pensão Alimentícia sem Ocorrencia de Pagamentos' as  obs
from cad
left join pag on pag.CPF = cad.CPF
             and pag.Rubrica = cad.Rubrica
             and pag.Agrupamento = cad.Agrupamento
             and pag.Orgao = cad.Orgao
             and pag.MatriculaLegado = cad.MatriculaLegado
             and pag.CPFBeneficiario = cad.CPFBeneficiario
where pag.CPF is null

union all

--- Indentificar os Cadastros de Pensão Alimentícia com Vigencia Divergente
select
 cad.Agrupamento,
 cad.CPF,
 cad.Rubrica,
 cad.Orgao,
 cad.MatriculaLegado,
 cad.CPFBeneficiario,
 cad.CPFRepresentante,
 cad.AnoMesInicio,
 cad.AnoMesFim,
 pag.AnoMesInicio as AnoMesInicioDif,
 case when pag.AnoMesFim = '202307' then null else pag.AnoMesFim end as AnoMesFimDif,
 'Cadastro de Pensão Alimentícia com Vigencia Divergente' as  obs
from cad
left join pag on pag.CPF = cad.CPF
             and pag.Rubrica = cad.Rubrica
             and pag.Agrupamento = cad.Agrupamento
             and pag.Orgao = cad.Orgao
             and pag.MatriculaLegado = cad.MatriculaLegado
             and pag.CPFBeneficiario = cad.CPFBeneficiario
where pag.CPF is not null
  and (cad.AnoMesInicio != pag.AnoMesInicio or 
       cad.AnoMesFim != case when pag.AnoMesFim = '202307' then null else pag.AnoMesFim end)

union all

select
 pag.Agrupamento,
 pag.CPF,
 pag.Rubrica,
 pag.Orgao,
 pag.MatriculaLegado,
 cad.CPFBeneficiario,
 cad.CPFRepresentante,
 pag.AnoMesInicio,
 case when pag.AnoMesFim = '202307' then null else pag.AnoMesFim end as AnoMesFim,
 null as AnoMesInicioDif,
 null as AnoMesFimDif,
 'Pagamento de Pensão Alimenticia sem Cadastro de Pensão' as  obs
from pag
left join cad on cad.CPF = pag.CPF
             and cad.Rubrica = pag.Rubrica
             and cad.Agrupamento = pag.Agrupamento
             and cad.Orgao = pag.Orgao
             and cad.MatriculaLegado = pag.MatriculaLegado
             and cad.CPFBeneficiario = pag.CPFBeneficiario
where cad.CPF is null

order by 1, 2, 3, 4, 5, 6, 8
;
/
