with
dup as (
select numatriculalegado, dtadmissao from emigmatricula
group by numatriculalegado, dtadmissao having count(1) > 1
)

select
m.sgorgao as Orgao,
lpad(trim(m.numatriculalegado),9,0) as MatriculaLegado,
to_char(m.dtadmissao, 'DD/MM/YYYY') as DataAdmissa,
lpad(trim(m.numatricula),7,0) || '-' || m.nudvmatricula || '-' || lpad(trim(m.nuseqmatricula),2,0) as Matricula,
lpad(trim(m.nucpf),11,0) as CPF,
trim(m.nmpessoa) as Nome
from emigmatricula m
inner join dup on dup.numatriculalegado = m.numatriculalegado
              and dup.dtadmissao = m.dtadmissao
;
/