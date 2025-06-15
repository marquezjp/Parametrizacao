--- Ajustar o Índice da Rubrica HORA AULA INSTRUTOR (MIG: 1200) (01-4200)
-- Listar Contracheques
with
pag as (
select
 lpad(f.nuanoreferencia,4,0) || lpad(f.numesreferencia,2,0) as AnoMes,
 o.sgorgao as Orgao,
 upper(tpf.nmtipofolha) as TipoFolha,
 upper(tpc.nmtipocalculo) as TipoCalculo,
 lpad(f.nusequencialfolha,2,0) as Seq,
 lpad(p.nucpf, 11, 0) as CPF,
 case when m.numatricula is null then '000000000' else lpad(to_number(trim(replace(m.numatriculalegado,'"',''))),9,0) end as MatriculaLegado,
 to_char(v.dtadmissao, 'DD/MM/YYYY') as DataAdmissao,
 lpad(v.numatricula,7,0) || '-' || v.nudvmatricula || '-' || lpad(trim(v.nuseqmatricula),2,0) as Matricula,
 case r.cdtiporubrica
  when  1 then 'PROVENTOS NORMAL'
  when  2 then 'PROVENTOS NORMAL'
  when  4 then 'PROVENTOS NORMAL'
  when 10 then 'PROVENTOS NORMAL'
  when 12 then 'PROVENTOS NORMAL'
  when  5 then 'DESCONTOS NORMAL'
  when  6 then 'DESCONTOS NORMAL'
  when  8 then 'DESCONTOS NORMAL'
  when 11 then 'DESCONTOS NORMAL'
  when 13 then 'DESCONTOS NORMAL'
  when  9 then 'BASE'
  else to_char(r.cdtiporubrica)
 end TipoRubrica,
 case
  when r.cdtiporubrica = 1 and r.nurubrica in (0001, 0002, 0181, 0524, 2040) then 1
  when r.cdtiporubrica = 1 and r.nurubrica in (0029, 0236, 0237, 0238, 0815, 1300, 1505, 4066, 4200, 4853, 4859, 4909, 4910) then 5
  when r.cdtiporubrica = 5 and r.nurubrica in (0003, 0004, 0182) then 2
  when ra.flpensaoalimenticia = 'S' then 3
  when ra.flconsignacao = 'S' then 4
  else 9
 end CodigoGrupoRubrica,
 case
  when r.cdtiporubrica = 1 and r.nurubrica in (0001, 0002, 0181, 0524, 2040) then 'VENCIMENTO'
  when r.cdtiporubrica = 1 and r.nurubrica in (0029, 0236, 0237, 0238, 0815, 1300, 1505, 4066, 4200, 4853, 4859, 4909, 4910) then 'CALCULADOS'
  when r.cdtiporubrica = 5 and r.nurubrica in (0003, 0004, 0182) then 'TRIBUTOS'
  when ra.flpensaoalimenticia = 'S' then 'PENSAO ALIMENTICIA'
  when ra.flconsignacao = 'S' then 'CONSIGNACAO'
  else 'OUTROS'
 end GrupoRubrica,
 case
  when r.cdtiporubrica = 1 and r.nurubrica in (0001, 0002, 0181, 0524, 2040) then trim(replace(rub.derubricaagrupamento, '-',' '))
  when r.cdtiporubrica = 1 and r.nurubrica in (0029, 0236, 0237, 0238, 0815, 1300, 1505, 4066, 4200, 4853, 4859, 4909, 4910) then rub.derubricaagrupamento
  when r.cdtiporubrica = 5 and r.nurubrica in (0003, 0004, 0182) then rub.derubricaagrupamento
  when ra.flconsignacao = 'S' then 'CONSIGNACAO' 
  when ra.flpensaoalimenticia = 'S' then 'PENSAO ALIMENTICIA'
  else 'OUTROS'
 end SubGrupoRubrica,
 lpad(r.nurubrica,4,0) as Rubrica,
 pag.nusufixorubrica as Sufixo,
 rub.derubricaagrupamento as DescricaoRubrica,
 pag.vlindicerubrica as Indice,
 pag.vlpagamento as Valor,
 pag.nuparcela as ParcelaAtual,
 pag.qtparcelas as QtdeParcelas,
 pag.cdhistoricorubricavinculo, pag.cdfolhapagamento, f.cdtipofolhapagamento, f.cdtipocalculo, pag.cdvinculo, pag.cdrubricaagrupamento, r.cdtiporubrica, r.nurubrica
from epaghistoricorubricavinculo pag
inner join epagcapahistrubricavinculo capa on capa.cdfolhapagamento = pag.cdfolhapagamento and capa.cdvinculo = pag.cdvinculo
inner join epagfolhapagamento f on f.cdfolhapagamento = pag.cdfolhapagamento
inner join epagtipofolhapagamento tpfp on tpfp.cdtipofolhapagamento = f.cdtipofolhapagamento
inner join epagtipofolha tpf on tpf.cdtipofolha = tpfp.cdtipofolha
inner join epagtipocalculo tpc on tpc.cdtipocalculo = f.cdtipocalculo
inner join ecadhistorgao o on o.cdorgao = f.cdorgao
inner join ecadvinculo v on v.cdvinculo = pag.cdvinculo
inner join ecadpessoa p on p.cdpessoa = v.cdpessoa
left join emigmatricula m on m.numatricula = v.numatricula and m.nuseqmatricula = v.nuseqmatricula
inner join epaghistrubricaagrupamento rub on rub.cdrubricaagrupamento = pag.cdrubricaagrupamento
inner join epagrubricaagrupamento ra on ra.cdrubricaagrupamento = rub.cdrubricaagrupamento
inner join epagrubrica r on r.cdrubrica = ra.cdrubrica
where f.nuanoreferencia = 2024 and  f.numesreferencia = 11 and f.cdtipocalculo = 1 and f.cdtipofolhapagamento = 983
  and o.cdagrupamento = 19 and r.cdtiporubrica != 9
)

select Orgao, Matricula, Rubrica, Sufixo, DescricaoRubrica, Indice, Valor, ROUND(Valor / 60,1) IndiceNovo, (ROUND(Valor / 60,1) * 60) ValorNovo
from pag
where cdtiporubrica = 1 and nurubrica in (4200)
  and Valor = (ROUND(Valor / 60,1) * 60)
order by TipoRubrica desc, GrupoRubrica, SubGrupoRubrica, Rubrica, DescricaoRubrica
;
/

-- Atualizar o Índice
select count(*) as qtde
--select cdhistoricorubricavinculo, cdvinculo, cdrubricaagrupamento, nusufixorubrica,
-- vlindicerubrica, vlpagamento, round(vlpagamento / 60,1) vlindicerubricanovo, (round(vlpagamento / 60,1) * 60) vlpagamentonovo
from epaghistoricorubricavinculo
--update epaghistoricorubricavinculo set vlindicerubrica = round(vlpagamento / 60,1)
where cdhistoricorubricavinculo in (
    select pag.cdhistoricorubricavinculo from epaghistoricorubricavinculo pag
    inner join epagcapahistrubricavinculo capa on capa.cdfolhapagamento = pag.cdfolhapagamento and capa.cdvinculo = pag.cdvinculo
    inner join epagfolhapagamento f on f.cdfolhapagamento = pag.cdfolhapagamento
    inner join ecadhistorgao o on o.cdorgao = f.cdorgao
    inner join epagrubricaagrupamento ra on ra.cdrubricaagrupamento = pag.cdrubricaagrupamento
    inner join epagrubrica r on r.cdrubrica = ra.cdrubrica
    where f.nuanoreferencia = 2024 and  f.numesreferencia = 11 and f.cdtipocalculo = 1 and f.cdtipofolhapagamento = 983
      and o.cdagrupamento = 19 and r.cdtiporubrica = 1 and r.nurubrica = 4200
      and vlpagamento = (round(pag.vlpagamento / 60,1) * 60)
)
;
/

-- Importar para Lançamentos Financeiros
DECLARE
  -- Parâmetros obrigatórios com valores default
  pAcao          CHAR         := 'I';          -- Default: Inclusão
  pCompetencia   INTEGER      := 202411;       -- Default: Nov/2025
  pAgrupamento   INTEGER      := 19;           -- Default: Agrupamento 19
  
  -- Parâmetros opcionais inicializados como NULL
  pOrgao         INTEGER      := NULL;
  pTpRubrica     CHAR         := 'P';
  pTipoInclusao  CHAR         := 'I';
  pNuSufixoRubrica INTEGER    := NULL;
  pNovoIndice    VARCHAR2(20) := NULL;
  pNovoValor     VARCHAR2(20) := NULL;
  pFixarDiferencas CHAR       := 'N';          -- Default: Não fixar diferenças
  pDescricaoLanc VARCHAR2(100) := NULL;
  pGerarSaida    CHAR         := 'N';          -- Default: Não gerar saída
  
  -- Coleções vazias para listas de rubricas
  pNuRubrica       tRubricas := tRubricas();
  pExcetoNuRubrica tRubricas := tRubricas();

  -- Variável de retorno
  pRetorno       VARCHAR2(4000);

BEGIN
  pCompetencia := 202411; -- Nov/2024
  pAgrupamento := 19;     -- Militares

  -- Excluir os Vencimentos Fixados
  pAcao := 'E';           -- Exclusão
  pTpRubrica := Null;     -- Todos
  pTipoInclusao := Null;  -- Indices e Valores
  pNuRubrica := tRubricas('4200');
  pExcetoNuRubrica := tRubricas();
  pkgpag_paralelo.PAjustarLancamentos(
    pAcao => pAcao,
    pCompetencia => pCompetencia,
    pAgrupamento => pAgrupamento,
    pOrgao => pOrgao,
    pTpRubrica => pTpRubrica,
    pTipoInclusao => pTipoInclusao,
    pNuRubrica => pNuRubrica,
    pExcetoNuRubrica => pExcetoNuRubrica,
    pNuSufixoRubrica => pNuSufixoRubrica,
    pNovoIndice => pNovoIndice,
    pNovoValor => pNovoValor,
    pFixarDiferencas => pFixarDiferencas,
    pDescricaoLanc => pDescricaoLanc,
    pGerarSaida => pGerarSaida,
    pRetorno => pRetorno
  );
  -- Exibe o retorno da procedure
  DBMS_OUTPUT.PUT_LINE('Resultado: ' || pRetorno);

  -- Fixar Vencimentos com Diferenças
  pAcao := 'I';           -- Fixar Diferenças
  pTpRubrica := 'P';      -- Proventos
  pTipoInclusao := 'I';  -- Indices e Valores
  pNuRubrica := tRubricas('4200');
  pExcetoNuRubrica := tRubricas();
  pkgpag_paralelo.PAjustarLancamentos(
    pAcao => pAcao,
    pCompetencia => pCompetencia,
    pAgrupamento => pAgrupamento,
    pOrgao => pOrgao,
    pTpRubrica => pTpRubrica,
    pTipoInclusao => pTipoInclusao,
    pNuRubrica => pNuRubrica,
    pExcetoNuRubrica => pExcetoNuRubrica,
    pNuSufixoRubrica => pNuSufixoRubrica,
    pNovoIndice => pNovoIndice,
    pNovoValor => pNovoValor,
    pFixarDiferencas => pFixarDiferencas,
    pDescricaoLanc => pDescricaoLanc,
    pGerarSaida => pGerarSaida,
    pRetorno => pRetorno
  );
  -- Exibe o retorno da procedure
  DBMS_OUTPUT.PUT_LINE('Resultado: ' || pRetorno);

EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Erro: ' || SQLERRM);
    RAISE;
END;
/

