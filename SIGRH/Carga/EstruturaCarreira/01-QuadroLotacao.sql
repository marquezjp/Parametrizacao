--- Criar Quadro de Lotação dos Cargos Efetivos, Temporarios e Comissionados com base nos Layout de Cadastro dos Vinculos
--- Conceitos envolvidos:
--- - Descrição do Quadro de Lotação (emovDescricaoQLP)

-- Excluir os Registros dos Conceitos Envolvidos na Ordem de Filho para Pais
--delete ecadOrgaoCarreira;
--delete ecadOrgaoRegTrabalho;
--delete ecadOrgaoRegPrev;
--delete ecadOrgaoRelTrabalho;
--delete ecadOrgaoNatVinculo;

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

--delete ecadevolucaoccocargahoraria;
--delete ecadevolucaocconatvinc;
--delete ecadevolucaoccoreltrab;
--delete ecadevolucaoccovalorref;
--delete ecadcargocomissionado;

--delete ecadgrupoocupacional;
--delete emovDescricaoQLP;

--- Criar emovDescricaoQLP
insert into emovdescricaoqlp
with quadros_lotacao as (
select distinct
 a.sgagrupamento as sgagrupamento,
 v.nmrelacaotrabalho,

 'QUADRO DE ' ||
 case nmrelacaotrabalho
      when 'EFETIVO' then 'CARGOS EFETIVOS'
      when 'ACT - ADMITIDO EM CARATER TEMPORARIO' then 'CONTRATO TEMPORARIO'
      when 'COMISSIONADO' then 'CARGOS COMISSIONADOS'
      else nmrelacaotrabalho
  end || ' ' ||
  sgagrupamento as nmdescricaoqlp

from sigrh_rr_vinculos v
left join vcadorgao o on o.sgorgao = v.sgorgao
left join ecadagrupamento a on a.cdagrupamento = o.cdagrupamento
where o.cdorgao is not null
  and v.nmrelacaotrabalho is not null
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
