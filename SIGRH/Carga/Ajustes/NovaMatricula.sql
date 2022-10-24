with vinculos as (
select
 ml.sgorgao,
 ml.matricula_legado as numatriculalegado,
 ml.nucpf,
 p.nmpessoa,
 v.dtadmissao
from sigrhmig.emigmatricula ml
inner join ecadvinculo v on v.numatricula = ml.numatricula
inner join ecadpessoa p on p.cdpessoa = v.cdpessoa
),

pessoas as (
select distinct
 ml.nucpf,
 p.nmpessoa
from sigrhmig.emigmatricula ml
inner join ecadvinculo v on v.numatricula = ml.numatricula
inner join ecadpessoa p on p.cdpessoa = v.cdpessoa
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
 p.nmpessoa,
 pv.nucpf
from primeiro_vinculo pv
inner join pessoas p on p.nucpf = pv.nucpf
order by pv.dtadmissao, p.nmpessoa
),

nova_matricula as (
select
 rownum as numatricula,
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
