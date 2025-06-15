select Orgao, CodRubrica, Rubrica, count(*) as qtde from (
select
 o.sgorgao Orgao,
 p.nmpessoa Nome,
 p.nucpf CPF,
 pkgutil.FFORMATAMATRICULA (v.numatricula, v.nudvmatricula, v.nuseqmatricula) Matricula,
 rub.derubricaagrupamento Rubrica,
 lpad(rub.cdtiporubrica, 2, 0)||'-'||lpad(rub.nurubrica, 4, 0) CodRubrica,
 fin.nusufixorubrica Sufixo,
 fin.dtiniciodireito Inicio,
 fin.dtfimdireito Fim,
 fin.dtinclusao Inclusao,
 fin.vlindice Indice,
 fin.vllancamentofinanceiro Valor
from epaglancamentofinanceiro fin
inner join ecadvinculo v on v.cdvinculo = fin.cdvinculo
inner join ecadpessoa p on p.cdpessoa = v.cdpessoa
inner join vcadorgao o on o.cdorgao = v.cdorgao
inner join vpagrubricaagrupamento rub on rub.cdrubricaagrupamento = fin.cdrubricaagrupamento             
where o.cdagrupamento = 19
  and rub.cdtiporubrica in (1, 2, 8, 10, 12)
  and rub.nurubrica in ('0524', '2040')
order by o.sgorgao, p.nucpf, v.numatricula, v.nuseqmatricula, rub.cdtiporubrica, rub.nurubrica, fin.nusufixorubrica
)
group by Orgao, CodRubrica, Rubrica
order by Orgao, CodRubrica, Rubrica
;
/

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
  pNuRubrica := tRubricas('0524', '2040');
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
  pTipoInclusao := Null;  -- Indices e Valores
  pFixarDiferencas := 'S'; -- Fixar Diferenças
  pNuRubrica := tRubricas('0524', '2040');
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