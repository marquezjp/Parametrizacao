--insert into emigmatricula
select --count(1) as qtde
trim(nova.sgorgao) as sgorgao,
lpad(nova.numatriculalegado,9,0) as numatriculalegado,
nova.nucpf,
to_date(nova.dtadmissao, 'dd/mm/yyyy') as dtadmissao,
nova.nmpessoa,
to_char(to_number(nova.numatricula)) as numatricula,
to_char(to_number(nova.nudvmatricula)) as nudvmatricula,
to_char(to_number(nova.nuseqmatricula)) as nuseqmatricula,
nova.cdrelacaotrabalho as cdrelacaotrabalho
from emigmatriculanova nova
left join emigmatricula mig on mig.numatriculalegado = nova.numatriculalegado and mig.dtadmissao = to_date(nova.dtadmissao, 'DD/MM/YYYY')
left join ecadvinculo v on v.numatricula = nova.numatricula and v.nuseqmatricula = nova.nuseqmatricula
where mig.numatriculalegado is null
  and v.numatricula is null
;
/