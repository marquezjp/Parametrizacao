with
depara as (
select upper(trim(de)) as de, upper(trim(para)) as para
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
from sigrhmig.emigorgaocsv
),
vinculos as (
select
o.sgagrupamento,
o.sgorgao,
lpad(trim(numatriculalegado),9,0) as numatriculalegado,
lpad(trim(nucpf),11,0) as nucpf,
translate(
    regexp_replace(
      upper(trim(replace(nmpessoa, '''', ''))),
      '[[:space:]]+', chr(32)
    ),
    'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
    'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz'
  ) as nmpessoa,
to_char(to_date(dtadmissao,'DD/MM/YYYY'),'DD/MM/YYYY') as dtadmissao
from (
select upper(trim(sgorgao)) as sgorgao, numatriculalegado, nucpf, nmpessoa, dtadmissao from sigrhmig.emigvinculoefetivocsv union
select upper(trim(sgorgao)) as sgorgao, numatriculalegado, nucpf, nmpessoa, dtadmissao from sigrhmig.emigvinculocomissionadocsv union
select upper(trim(sgorgao)) as sgorgao, numatriculalegado, nucpf, nmpessoa, dtadmissao from sigrhmig.emigvinculobolsistacsv union
select upper(trim(sgorgao)) as sgorgao, numatriculalegado, nucpf, nmpessoa, dtadmissao from sigrhmig.emigvinculorecebidocsv union
select upper(trim(sgorgao)) as sgorgao, numatriculalegado, nucpf, nmpessoa, dtadmissao from sigrhmig.emigvinculocedidocsv union
select upper(trim(sgorgao)) as sgorgao, numatriculalegado, nucpf, nmpessoa, dtadmissao from sigrhmig.emigvinculopensaonaoprevcsv
) v
left join depara on depara.de = v.sgorgao
left join orgaos o on o.sgorgao = nvl(depara.para, v.sgorgao)
where to_number(trim(numatriculalegado)) != 0
   and to_number(trim(nucpf)) != 0
   and to_number(replace(trim(dtadmissao),'/','')) != 0
   and to_date(trim(dtadmissao),'DD/MM/YYYY') >= '01/01/1900'
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
         (to_number(substr(lpad(rownum + 100000,7,0),1,1))*8 +
          to_number(substr(lpad(rownum + 100000,7,0),2,1))*7 +
          to_number(substr(lpad(rownum + 100000,7,0),3,1))*6 +
          to_number(substr(lpad(rownum + 100000,7,0),4,1))*5 +
          to_number(substr(lpad(rownum + 100000,7,0),5,1))*4 +
          to_number(substr(lpad(rownum + 100000,7,0),6,1))*3 +
          to_number(substr(lpad(rownum + 100000,7,0),7,1))*2
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
 lpad(rank() over (partition by nm.numatricula order by nm.numatricula, v.dtadmissao, v.sgagrupamento, v.numatriculalegado),2,0) as nuseqmatricula
from vinculos v
inner join nova_matricula nm on nm.nucpf = v.nucpf

order by nm.numatricula, v.dtadmissao, v.numatriculalegado
