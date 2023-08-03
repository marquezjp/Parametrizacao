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
select o.sgagrupamento, o.sgorgao, trim(numatriculalegado, nucpf, nmpessoa, dtadmissao from (
select sgorgao, numatriculalegado, nucpf, nmpessoa, dtadmissao from emigvinculoefetivocsv union
select sgorgao, numatriculalegado, nucpf, nmpessoa, dtadmissao from emigvinculocomissionadocsv union
select sgorgao, numatriculalegado, nucpf, nmpessoa, dtadmissao from emigvinculobolsistacsv union
select sgorgao, numatriculalegado, nucpf, nmpessoa, dtadmissao from emigvinculorecebidocsv union
select sgorgao, numatriculalegado, nucpf, nmpessoa, dtadmissao from emigvinculocedidocsv union
select sgorgao, numatriculalegado, nucpf, nmpessoa, dtadmissao from emigvinculopensaonaoprevcsv
) v
left join depara on upper(trim(depara.de)) = upper(trim(v.sgorgao))
left join orgaos o on upper(trim(o.sgorgao)) = nvl(upper(trim(depara.para)),upper(trim(v.sgorgao)))
),

primeiro_vinculo as (
select
 v.nucpf,
 min(v.dtadmissao) as dtadmissao
from vinculos v
group by v.nucpf
),

ordem_matriculas as (
select
 pv.dtadmissao,
 pv.nucpf
from primeiro_vinculo pv
order by pv.dtadmissao
),

nova_matricula as (
select
 rownum + 100000 as numatricula,
 mod(
     mod(
         (to_number(substr(lpad(rownum,7,0),1,1))*8 +
          to_number(substr(lpad(rownum,7,0),2,1))*7 +
          to_number(substr(lpad(rownum,7,0),3,1))*6 +
          to_number(substr(lpad(rownum,7,0),4,1))*5 +
          to_number(substr(lpad(rownum,7,0),5,1))*4 +
          to_number(substr(lpad(rownum,7,0),6,1))*3 +
          to_number(substr(lpad(rownum,7,0),7,1))*2
         ) * 10,
         11),
     10) as nudvmatricula,
 nucpf
from ordem_matriculas 
)

select
-- v.sgagrupamento,
 v.sgorgao,
 v.numatriculalegado,
 v.nucpf,
 v.dtadmissao,
 v.nmpessoa,
 lpad(nm.numatricula,7,0) as numatricula,
 nm.nudvmatricula,
 lpad(rank() over (partition by nm.numatricula order by nm.numatricula, v.dtadmissao, v.numatriculalegado),2,0) as nuseqmatricula
from vinculos v
inner join nova_matricula nm on nm.nucpf = v.nucpf

order by nm.numatricula, v.dtadmissao, v.numatriculalegado
