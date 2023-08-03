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
vinculos as (
select distinct o.sgagrupamento, v.numatriculalegado, v.dtadmissao, v.nucpf, o.sgorgao, v.origem from (
select distinct sgorgao, lpad(trim(numatriculalegado),10,0) as numatriculalegado, lpad(trim(nucpf),11,0) as nucpf, to_char(to_date(dtadmissao,'YYYY-MM-DD HH24:MI:SS'), 'DD/MM/YYYY') as dtadmissao, '1-CEF' as origem
from emigvinculoefetivocsv union
select distinct sgorgao, lpad(trim(numatriculalegado),10,0) as numatriculalegado, lpad(trim(nucpf),11,0) as nucpf, to_char(to_date(dtadmissao,'YYYY-MM-DD HH24:MI:SS'), 'DD/MM/YYYY') as dtadmissao, '2-CCO' as origem
from emigvinculocomissionadocsv union
select distinct sgorgao, lpad(trim(numatriculalegado),10,0) as numatriculalegado, lpad(trim(nucpf),11,0) as nucpf, to_char(to_date(dtadmissao,'YYYY-MM-DD HH24:MI:SS'), 'DD/MM/YYYY') as dtadmissao, '3-BOL' as origem
from emigvinculobolsistacsv union
select distinct sgorgao, lpad(trim(numatriculalegado),10,0) as numatriculalegado, lpad(trim(nucpf),11,0) as nucpf, to_char(to_date(dtadmissao,'YYYY-MM-DD HH24:MI:SS'), 'DD/MM/YYYY') as dtadmissao, '4-REC' as origem
from emigvinculorecebidocsv union
select distinct sgorgao, lpad(trim(numatriculalegado),10,0) as numatriculalegado, lpad(trim(nucpf),11,0) as nucpf, to_char(to_date(dtadmissao,'YYYY-MM-DD HH24:MI:SS'), 'DD/MM/YYYY') as dtadmissao, '5-CED' as origem
from emigvinculocedidocsv union
select distinct sgorgao, lpad(trim(numatriculalegado),10,0) as numatriculalegado, lpad(trim(nucpf),11,0) as nucpf, to_char(to_date(dtadmissao,'YYYY-MM-DD HH24:MI:SS'), 'DD/MM/YYYY') as dtadmissao, '6-PNP' as origem
from emigvinculopensaonaoprevcsv
) v
left join depara on upper(trim(depara.de)) = upper(trim(v.sgorgao))
left join orgaos o on upper(trim(o.sgorgao)) = nvl(upper(trim(depara.para)),upper(trim(v.sgorgao)))
--where o.sgagrupamento = 'AGRU-ADM-DIR'
),
capa as (
select distinct o.sgagrupamento, lpad(trim(capa.numatriculalegado),10,0) as numatriculalegado, to_char(to_date(trim(capa.dtadmissao), 'YYYY-MM-DD HH24:MI:SS'), 'DD/MM/YYYY') as dtadmissao, lpad(trim(capa.nucpf),11,0) as nucpf, o.sgorgao, '9-PAG' as origem
from emigcapapagamentocsv capa
left join depara on upper(trim(depara.de)) = upper(trim(capa.sgorgao))
left join orgaos o on upper(trim(o.sgorgao)) = nvl(upper(trim(depara.para)),upper(trim(capa.sgorgao)))
--where o.sgagrupamento = 'AGRU-ADM-DIR'
),
matriculasdup as (
select sgagrupamento, numatriculalegado from (
select distinct sgagrupamento, numatriculalegado, dtadmissao, nucpf from vinculos union
select distinct sgagrupamento, numatriculalegado, dtadmissao, nucpf from capa
)
group by sgagrupamento, numatriculalegado
having count(1) > 1
order by sgagrupamento, numatriculalegado
)

--select obs, count(1) as qtde from (
select v.sgagrupamento, v.numatriculalegado, v.dtadmissao, v.nucpf, v.sgorgao, v.origem, 'Matriculas Inconsistentes' as obs from (
select * from vinculos union all
select * from capa
) v
left join matriculasdup d on d.sgagrupamento = v.sgagrupamento
                         and d.numatriculalegado = v.numatriculalegado
where d.sgagrupamento is not null

union all

select capa.sgagrupamento, capa.numatriculalegado, capa.dtadmissao, capa.nucpf, capa.sgorgao, capa.origem, 'Vinculo Inexistente' as obs
from capa
left join vinculos v on v.sgagrupamento = capa.sgagrupamento
                    and v.numatriculalegado = capa.numatriculalegado
                    and v.dtadmissao =capa.dtadmissao
                    and v.nucpf =capa.nucpf
where v.sgagrupamento is null

--) group by obs
order by 1, 2, 3, 4, 6, 5
;
/
