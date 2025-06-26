/*
epagConsignacao
epagHistConsignacao
epagConsignataria
epagTipoServico
epagHistTipoServico
epagConsignatariaSuspensao
epagConsignatariaTaxaServico
epagContratoServico
*/
WITH
  -- RubricaLista: lista Rubricas
  RubricaLista AS (
  SELECT rubagrp.cdAgrupamento, rubagrp.cdRubricaAgrupamento, rub.cdRubrica,
    LPAD(tprub.nuTipoRubrica,2,0) || '-' || LPAD(rub.nuRubrica,4,0) AS nuRubrica,
    CASE WHEN tprub.nuTipoRubrica IN (1, 5, 9) THEN NULL ELSE tprub.deTipoRubrica || ' ' END ||
      NVL2(UltVigenciaAgrupamento.cdRubricaAgrupamento,UltVigenciaAgrupamento.deRubrica,
        NVL2(UltVigenciaRub.nuRubrica,UltVigenciaRub.deRubrica,NULL)) as deRubrica,
    NVL2(UltVigenciaAgrupamento.cdRubricaAgrupamento,UltVigenciaAgrupamento.nuAnoMesInicioVigencia,
      NVL2(UltVigenciaRub.nuRubrica,UltVigenciaRub.nuAnoMesInicioVigencia,NULL)) as nuAnoMesInicioVigencia,
    NVL2(UltVigenciaAgrupamento.cdRubricaAgrupamento,UltVigenciaAgrupamento.nuAnoMesFimVigencia,
      NVL2(UltVigenciaRub.nuRubrica,UltVigenciaRub.nuAnoMesFimVigencia,NULL)) as nuAnoMesFimVigencia
  FROM epagRubrica rub
  INNER JOIN epagTipoRubrica tprub ON tprub.cdtiporubrica = rub.cdtiporubrica
  INNER JOIN epagRubricaAgrupamento rubagrp ON rubagrp.cdrubrica = rub.cdrubrica
  LEFT JOIN (SELECT cdRubricaAgrupamento, deRubrica, nuAnoMesInicioVigencia, nuAnoMesFimVigencia FROM (
    SELECT cdRubricaAgrupamento, deRubricaAgrupamento as deRubrica,
      LPAD(nuAnoInicioVigencia,4,0) || LPAD(nuMesInicioVigencia,2,0) AS nuAnoMesInicioVigencia,
      CASE WHEN nuAnoFimVigencia IS NULL OR nuMesFimVigencia IS NULL THEN NULL
      ELSE LPAD(nuAnoFimVigencia,4,0) || LPAD(nuMesFimVigencia,2,0) END AS nuAnoMesFimVigencia,
      RANK() OVER (PARTITION BY cdRubricaAgrupamento
        ORDER BY LPAD(nuAnoInicioVigencia,4,0) || LPAD(nuMesInicioVigencia,2,0) DESC,
          CASE WHEN nuAnoFimVigencia IS NULL OR nuMesFimVigencia IS NULL THEN NULL
          ELSE LPAD(nuAnoFimVigencia,4,0) || LPAD(nuMesFimVigencia,2,0)
          END DESC nulls FIRST) AS nuOrder
    FROM epagHistRubricaAgrupamento) WHERE nuOrder = 1
  ) UltVigenciaAgrupamento ON UltVigenciaAgrupamento.cdRubricaAgrupamento = rubagrp.cdRubricaAgrupamento
  LEFT JOIN (SELECT nuRubrica, deRubrica, nuAnoMesInicioVigencia, nuAnoMesFimVigencia FROM (
    SELECT rub.cdRubrica, vigenciarub.deRubrica,
      LPAD(tprub.nuTipoRubrica,2,0) || '-' || LPAD(rub.nuRubrica,4,0) as nuRubrica,
      NVL(LPAD(vigenciarub.nuAnoInicioVigencia,4,0) || LPAD(vigenciarub.nuMesInicioVigencia,2,0), '190101') AS nuAnoMesInicioVigencia,
      CASE WHEN vigenciarub.nuAnoFimVigencia IS NULL OR vigenciarub.nuMesFimVigencia IS NULL THEN NULL
      ELSE LPAD(vigenciarub.nuAnoFimVigencia,4,0) || LPAD(vigenciarub.nuMesFimVigencia,2,0) END AS nuAnoMesFimVigencia,
      RANK() OVER (PARTITION BY rub.cdRubrica
        ORDER BY NVL(LPAD(vigenciarub.nuAnoInicioVigencia,4,0) || LPAD(vigenciarub.nuMesInicioVigencia,2,0),'190101') DESC,
          CASE WHEN vigenciarub.nuAnoFimVigencia IS NULL OR vigenciarub.nuMesFimVigencia IS NULL THEN NULL
          ELSE LPAD(vigenciarub.nuAnoFimVigencia,4,0) || LPAD(vigenciarub.nuMesFimVigencia,2,0)
          END DESC nulls FIRST) AS nuOrder
    FROM epagRubrica rub
    INNER JOIN epagTipoRubrica tprub on tprub.cdTipoRubrica = rub.cdTipoRubrica
    LEFT JOIN epagHistRubrica vigenciarub on vigenciarub.cdRubrica = rub.cdRubrica
    WHERE tprub.nuTipoRubrica IN (1, 5, 9)) WHERE nuOrder = 1
  ) UltVigenciaRub ON UltVigenciaRub.nuRubrica =
      CASE WHEN tprub.nuTipoRubrica IN (1, 2, 3, 8, 10, 12) THEN '01'
           WHEN tprub.nuTipoRubrica IN (5, 6, 7, 4, 11, 13) THEN '05'
           WHEN tprub.nuTipoRubrica = 9 THEN '09'
      END || '-' || LPAD(rub.nuRubrica,4,0)
  )

-- ## Consignação  
-- Consignação  
SELECT cdConsignacao,
cst.nuCodigoConsignataria,
rub.nuRubrica, rub.deRubrica,
tpserv.nmTipoServico,
cdContratoServico AS nuContrato,
TO_CHAR(dtInicioConcessao, 'YYYY-MM-DD') AS dtInicioConcessao,
TO_CHAR(dtFimConcessao, 'YYYY-MM-DD') AS dtFimConcessao,
NULLIF(flGeridaSCConsig,'N') AS flGeridaSCConsig,
NULLIF(flRepasse,'N') AS flRepasse
FROM epagConsignacao csg
LEFT JOIN epagTipoServico tpserv On tpserv.cdTipoServico = csg.cdTipoServico
LEFT JOIN RubricaLista rub ON rub.cdRubrica = csg.cdRubrica
LEFT JOIN epagConsignataria cst ON cst.cdConsignataria = csg.cdConsignataria
;
/

-- Vigência da Consignação
SELECT
cdhistconsignacao,
cdconsignacao,
dtiniciovigencia,
dtfimvigencia,
vlminconsignado,
fllancamentomanual,
fldescontoparcial,
flformulacalculo,
vlmindescontofolha,
numaxparcelas,
flmaisdeumaocorrencia,
vltaxaretencao,
vlretencao,
vltaxair,
vltaxaadministracao,
vltaxaprolabore,
fldescontoeventual,
cddocumento,
cdtipopublicacao,
dtpublicacao,
nupublicacao,
nupaginicial,
cdmeiopublicacao,
deoutromeio,
nucpfcadastrador,
dtinclusao,
dtultalteracao,
vltaxabescor
FROM epagHistConsignacao
;
/

-- ## Consignataria
-- Consignataria
SELECT
cdconsignataria,
nucodigoconsignataria,
nmconsignataria,
sgconsignataria,
deemailinstitucional,
deinstrucoescontato,
flmargemconsignavel,
flimpedida,
cdagencia,
nucontacorrente,
nudvcontacorrente,
cdendereco,
nuddd,
nutelefone,
nuramal,
nudddfax,
nufax,
nuramalfax,
cdtiporepresentacao,
nucnpjrepresentante,
nmrepresentante,
cdenderecorepresentante,
nudddrepresentante,
nutelefonerepresentante,
nuramalrepresentante,
nudddfaxrepresentante,
nufaxrepresentante,
nuramalfaxrepresentante,
cddocumento,
cdmeiopublicacao,
cdtipopublicacao,
dtpublicacao,
nupublicacao,
nupaginicial,
deoutromeio,
nucpfcadastrador,
dtinclusao,
dtultalteracao,
nucnpjconsignataria,
cdmodalidadeconsignataria,
nuprocessosgpe
FROM epagConsignataria
;
/

-- Consignataria Suspensao
SELECT
cdconsignatariasuspensao,
cdconsignataria,
cdconsignacao,
cdtiposervico,
dtiniciosuspensao,
nuhorainiciosuspensao,
dtfimsuspensao,
nuhorafimsuspensao,
demotivosuspensao,
cddocumento,
cdtipopublicacao,
cdmeiopublicacao,
dtpublicacao,
nupublicacao,
nupaginicial,
deoutromeio,
dtultalteracao,
dtinclusao
FROM epagConsignatariaSuspensao
;
/

-- Consignataria Taxa Servico
SELECT
cdconsignatariataxaservico,
cdconsignataria,
cdtiposervico
FROM epagConsignatariaTaxaServico
;
/

-- Contrato Servico
SELECT
cdcontratoservico,
cdagrupamento,
cdorgao,
cdconsignataria,
nucontrato,
dtiniciocontrato,
dtfimcontrato,
dtfimprorrogacao,
cdtiposervico,
deservico,
deobjeto,
desitepublicacao,
nuapolice,
nuregistrosusep,
vltaxaangariamento,
cddocumento,
cdtipopublicacao,
dtpublicacao,
nupublicacao,
nupaginicial,
cdmeiopublicacao,
deoutromeio,
dtultalteracao
FROM epagContratoServico
;
/

-- ## Tipo Servico
-- Tipo Servico
SELECT
cdtiposervico,
cdagrupamento,
nmtiposervico,
dtultalteracao
FROM epagTipoServico
;
/

-- Vigência do Tipo Servico 
SELECT
cdhisttiposervico,
cdtiposervico,
dtiniciovigencia,
dtfimvigencia,
flexigecontrato,
flexigevalorliberado,
flexigevalorreservado,
flioffinanciado,
dtultalteracao,
flexigepedido,
flexigeconsigoutrotipo,
vllimitepercentreservado,
vllimitereservado,
numaxparcelas,
vlminconsignado,
vltaxaretencao,
vlretencao,
vltaxaadministracao,
vltaxaprolabore,
vltaxairrf,
vllimitetac,
flemprestimo,
flseguro,
flcartaocredito,
nuordem,
cdconsigoutrotipo,
fltacfinanciada,
flverificamargemconsig,
vltaxabescor
FROM epagHistTipoServico
;
/
