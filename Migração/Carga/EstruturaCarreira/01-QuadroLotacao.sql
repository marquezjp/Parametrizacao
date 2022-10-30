--- Criar Quadro de Lotação dos Cargos Efetivos, Temporarios e Comissionados com base nos Layout de Cadastro dos Vinculos
--- Conceitos envolvidos:
--- - Descrição do Quadro de Lotação (emovDescricaoQLP)

-- Excluir os Registros dos Conceitos Envolvidos na Ordem de Filho para Pais
--delete ecadOrgaoCarreira;
--delete ecadOrgaoRegTrabalho;
--delete ecadOrgaoRegPrev;
--delete ecadOrgaoRelTrabalho;
--delete ecadOrgaoNatVinculo;
--delete ecadNatVincRelTrab;
--delete ecadRelTrabRegTrab;

--delete ecadEvolucaoCEFCargaHoraria;
--delete ecadEvolucaoCEFNatVinc;
--delete ecadEvolucaoCEFRelTrab;
--delete ecadEvolucaoCEFRegTrab;
--delete ecadEvolucaoCEFRegPrev;

--delete ecadEvolucaoEstruturaCarreira;

--delete epagValorCarreiraCEFAgrup;
--delete epagHistNivelRefCarrCEFAgrup;
--delete epagHistNivelRefCEFAgrup;
--delete epagNivelRefCEFAgrupVersao;
--delete epagNivelRefCEFAgrup;

--delete ecadEstruturaCarreira;
--delete ecadItemCarreira;

--delete epagValorRefCCOAgrupOrgEspec;
--delete epagHistValorRefCCOAgrupOrgVer;
--delete epagValorRefCCOAgrupOrgVersao;

--delete ecadEvolucaoCCOCargaHoraria;
--delete ecadEvolucaoCCONNatVinc;
--delete ecadEvolucaoCCORelTrab;
--delete ecadEvolucaoCCOValorRef;
--delete ecadEvolucaoCargoComissionado;
--delete ecadCargoComissionado;

--delete ecadGrupoOcupacional;
--delete emovDescricaoQLP;

--- Criar emovDescricaoQLP
insert into emovdescricaoqlp
with vinculos as (
select
 translate(regexp_replace(upper(trim(sgorgao)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as sgorgao,
 matricula_legado as numatriculalegado,
 to_date(dtadmissao, 'YYYY-MM-DD') as dtadmissao,
 to_date(dtdesligamento, 'YYYY-MM-DD') as dtdesligamento,
 null as decarreira,
 translate(regexp_replace(upper(trim(nmgrupoocupacional)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as degrupoocupacional,
 null as decargo,
 null as declasse,
 null as decompetencia,
 null as deespecialidade,
 translate(regexp_replace(upper(trim(nmrelacaotrabalho)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as nmrelacaotrabalho,
 translate(regexp_replace(upper(trim(nmregimetrabalho)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as nmregimetrabalho,
 translate(regexp_replace(upper(trim(nmregimeprevidenciario)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as nmregimeprevidenciario,
 translate(regexp_replace(upper(trim(nmnaturezavinculo)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as nmnaturezavinculo,
 nmtipocargahorariacom as nmtipocargahoraria,
 nucargahoraria as nucargahoraria,
 trim(nunivel) as nunivel,
 nureferencia as nureferencia,
 translate(regexp_replace(upper(trim(nvl(nmopcaoremuneracao,'PELO CARGO COMISSIONADO'))), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as nmopcaoremuneracao
from sigrhmig.emigvinculocomissionado
union
select
 translate(regexp_replace(upper(trim(sgorgao)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as sgorgao,
 matricula_legado as numatriculalegado,
 to_date(dtadmissao, 'YYYY-MM-DD') as dtadmissao,
 to_date(dtdesligamento, 'YYYY-MM-DD') as dtdesligamento,

 translate(regexp_replace(upper(trim(decarreira)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as decarreira,
 translate(regexp_replace(upper(trim(degrupoocupacional)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as degrupoocupacional,
 translate(regexp_replace(upper(trim(decargo)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as decargo,
 translate(regexp_replace(upper(trim(declasse)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as declasse,
 translate(regexp_replace(upper(trim(decompetencia)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as decompetencia,
 translate(regexp_replace(upper(trim(deespecialidade)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as deespecialidade,
 translate(regexp_replace(upper(trim(nmrelacaotrabalho)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as nmrelacaotrabalho,
 translate(regexp_replace(upper(trim(nmregimetrabalho)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as nmregimetrabalho,
 translate(regexp_replace(upper(trim(nmregimeprevidenciario)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as nmregimeprevidenciario,
 translate(regexp_replace(upper(trim(nmnaturezavinculo)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as nmnaturezavinculo,
 nmtipocargahoraria as nmtipocargahoraria,
 nucargahoraria as nucargahoraria,
 nunivelpagamento as nunivel,
 nureferenciapagamento as nureferencia,
 null as nmopcaoremuneracao 
from sigrhmig.emigvinculoefetivo
),
quadros_lotacao as (
select distinct
 nvl2(a.cdagrupamento,a.sgagrupamento,'INDIR-DETRAM/RR') as sgagrupamento
 v.nmrelacaotrabalho,

 'QLP IMPLANTACAO DE ' ||
 case nmrelacaotrabalho
      when 'EFETIVO' then 'CARGOS EFETIVOS'
      when 'ACT - ADMITIDO EM CARATER TEMPORARIO' then 'CONTRATO TEMPORARIO'
      when 'COMISSIONADO' then 'CARGOS COMISSIONADOS'
      else nmrelacaotrabalho
  end || ' ' ||
  sgagrupamento as nmdescricaoqlp

from vinculos v
left join vcadorgao o on o.sgorgao = v.sgorgao
left join ecadagrupamento a on a.cdagrupamento = o.cdagrupamento
where v.nmrelacaotrabalho is not null
order by a.sgagrupamento, v.nmrelacaotrabalho
),
reltrab as (
select
 cdrelacaotrabalho,
 translate(regexp_replace(upper(trim(nmrelacaotrabalho)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as nmrelacaotrabalho

from ecadrelacaotrabalho
),
quadros_lotacao_exitentes as(
select
 cddescricaoqlp,
 cdagrupamento,
 cdrelacaotrabalho,
 nmdescricaoqlp
from emovdescricaoqlp
)
select 
(select nvl(max(cddescricaoqlp),0) from emovdescricaoqlp) + rownum as cddescricaoqlp,
a.cdagrupamento as cdagrupamento,
reltrab.cdrelacaotrabalho,
qlp.nmdescricaoqlp,
'11111111111' as nucpfcadastrador,
trunc(sysdate) asdtincluido,
'N' as flanulado,
null as dtanulado,
systimestamp as dtultalteracao
from quadros_lotacao qlp
inner join reltrab on reltrab.nmrelacaotrabalho = qlp.nmrelacaotrabalho
inner join ecadagrupamento a on a.sgagrupamento = qlp.sgagrupamento
left join quadros_lotacao_exitentes qlpexit on qlpexit.cdagrupamento = a.cdagrupamento and qlp.nmdescricaoqlp = qlpexit.nmdescricaoqlp
where qlpexit.cddescricaoqlp is null
;

-- Listar a Quantidade de Registros Incluidos nos Conceitos Envolvidos
select '1-QLP' as Grupo, '1.1-emovDescricaoQLP' as Conceito, count(*) as Qtde from emovDescricaoQLP
order by 1, 2
;

-- Ajustar a Sequence dos Conceitos Envolvidos para o Total de Registros 
declare cursor c1 is
select 'emovdescricaoqlp'              as Tab, 'SMOVDESCRICAOQLP'              as Seq, nvl(max(cddescricaoqlp),0) as Qtde from emovDescricaoQLP
order by 1, 2;

begin
  for item in c1
    loop
      dbms_output.put_line('Tabname = ' || item.Tab || ' Sequence = ' || item.Seq || ' Qtde = ' || item.Qtde);
    
      execute immediate 'alter sequence ' || item.Seq || ' restart start with ' || case when item.Qtde = 0 then 1 else item.Qtde end;
      execute immediate 'analyze table ' || upper(item.Tab) || ' compute statistics';

    end loop;
end;

-- Listar Valor da Sequence dos Conceitos Envolvidos
select sequence_name, last_number from user_sequences
where sequence_name in (
'SMOVDESCRICAOQLP'
);
