--- Atualizar as Parametrizações dos Órgãos com base nos Layout de Cadastro dos Vinculos
--- Conceitos envolvidos:
--- - Lista de Opcao de Remuneracao por Relacao de Trabalho Permitidas para o Orgao (ecadRelTrabOpcaoRemuneracao)

-- Excluir os Registros dos Conceitos Envolvidos na Ordem de Filho para Pais
--delete ecadRelTrabOpcaoRemuneracao;

--- Criar a Lista de Opcao de Remuneracao por Relacao de Trabalho Permitidas para o Orgao
insert into ecadreltrabopcaoremuneracao
with oreltrab as (
select distinct
 nvl2(o.cdorgao,o.sgorgao,'DETRAN') as sgorgao,
 translate(regexp_replace(upper(trim(v.nmrelacaotrabalho)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as nmrelacaotrabalho,
 translate(regexp_replace(upper(trim(nvl(v.nmopcaoremuneracao,'PELO CARGO COMISSIONADO'))), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as nmopcaoremuneracao 
from sigrhmig.emigvinculocomissionado v
left join vcadorgao o on o.sgorgao = v.sgorgao
),
reltrab as (
select
 cdrelacaotrabalho,
 translate(regexp_replace(upper(trim(nmrelacaotrabalho)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as nmrelacaotrabalho

from ecadrelacaotrabalho
),
oprem as (
select
 cdopcaoremuneracao,
 translate(regexp_replace(upper(trim(nmopcaoremuneracao)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as nmopcaoremuneracao
from ecadopcaoremuneracao
),
oreltrab_existe as (
select distinct
 cdorgao,
 cdrelacaotrabalho
from ecadreltrabopcaoremuneracao
)
select
 (select max(cdreltrabopcaoremuneracao) from ecadreltrabopcaoremuneracao) + rownum as cdreltrabopcaoremuneracao,
 oprem.cdopcaoremuneracao as cdopcaoremuneracao,
 reltrab.cdrelacaotrabalho as cdrelacaotrabalho,
 o.cdorgao as cdorgao
from oreltrab ort
inner join vcadorgao o on o.sgorgao = ort.sgorgao
inner join reltrab on reltrab.nmrelacaotrabalho = ort.nmrelacaotrabalho
inner join oprem on oprem.nmopcaoremuneracao = ort.nmopcaoremuneracao
left join oreltrab_existe on oreltrab_existe.cdorgao = o.cdorgao
                         and oreltrab_existe.cdrelacaotrabalho = reltrab.cdrelacaotrabalho
where oreltrab_existe.cdorgao is null