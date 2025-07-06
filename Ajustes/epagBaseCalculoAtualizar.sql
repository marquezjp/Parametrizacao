SET SERVEROUTPUT ON SIZE UNLIMITED;
BEGIN
FOR rec IN (
SELECT rubagrp.cdRubricaAgrupamento, base.cdBaseCalculo, mod.cdModalidadeRubrica,
js.nuRubrica, js.nmModalidadeRubrica, js.sgBaseCalculo
FROM JSON_TABLE('[
{"nuRubrica":"09-0500","sgBaseCalculo":"BIRRF","nmModalidadeRubrica":"BASE DE CALCULO DO IRRF"},
{"nuRubrica":"09-0680","sgBaseCalculo":"BINSS","nmModalidadeRubrica":"SALARIO DE CONTRIBUICAO DO INSS"},
{"nuRubrica":"09-0800","sgBaseCalculo":"B0800"},
{"nuRubrica":"09-0901","nmModalidadeRubrica":"TOTAL DE PROVENTOS"},
{"nuRubrica":"09-0902","nmModalidadeRubrica":"TOTAL DE DESCONTOS"},
{"nuRubrica":"09-0904","nmModalidadeRubrica":"TOTAL LIQUIDO"},
{"nuRubrica":"09-0913","sgBaseCalculo":"B13SA","nmModalidadeRubrica":"BASE DO 13 SALARIO"},
{"nuRubrica":"09-0951","sgBaseCalculo":"BMAR","nmModalidadeRubrica":"MARGEM CONSIGNAVEL BRUTA"},
{"nuRubrica":"09-0952","nmModalidadeRubrica":"TOTAL DE DESCONTOS FACULTATIVOS/CONSIGNACOES"},
{"nuRubrica":"09-1000","nmModalidadeRubrica":"SALARIO DE CONTRIBUICAO DO INSS"},
{"nuRubrica":"09-1005","sgBaseCalculo":"B1005","nmModalidadeRubrica":"SALÁRIO DE CONTRIBUIÇÃO DO INSS SOBRE 13 SALÁRIO"},
{"nuRubrica":"09-1027","nmModalidadeRubrica":"VALOR DA BASE DO INSS VARIOS VINCULOS"},
{"nuRubrica":"09-1028","nmModalidadeRubrica":"VALOR DO DESCONTO DO INSS VARIOS VINCULOS"},
{"nuRubrica":"09-1030","nmModalidadeRubrica":"BASE IRRF OUTROS VINCULOS/FOLHA"},
{"nuRubrica":"09-1031","nmModalidadeRubrica":"VALOR DESCONTO IRRF OUTROS VINCULOS/FOLHAS"},
{"nuRubrica":"09-1789","sgBaseCalculo":"PIPER","nmModalidadeRubrica":"PATRONAL IPREV - FF"},
{"nuRubrica":"09-2000","sgBaseCalculo":"BIPER","nmModalidadeRubrica":"SALARIO DE CONTRIBUICAO DO IPESC"},
{"nuRubrica":"09-2005","sgBaseCalculo":"B2005","nmModalidadeRubrica":"SALARIO DE CONTRIBUICAO DO IPESC SOBRE 13 SALARIO"},
{"nuRubrica":"09-3000","nmModalidadeRubrica":"BASE DE CALCULO DO IRRF"},
{"nuRubrica":"09-3001","sgBaseCalculo":"B3001","nmModalidadeRubrica":"BASE DE CÁLCULO DO IRRF SOBRE 13 SALÁRIO"},
{"nuRubrica":"09-4000","nmModalidadeRubrica":"VALOR DE ABATIMENTO DE DEPENDENTE DE IRRF"},
{"nuRubrica":"09-5000","sgBaseCalculo":"BCPSM"},
{"nuRubrica":"09-6000","sgBaseCalculo":"B6000"},
{"nuRubrica":"09-6001","nmModalidadeRubrica":"MARGEM CONSIGNAVEL LIQUIDA"},
{"nuRubrica":"09-6005","sgBaseCalculo":"B70BR","nmModalidadeRubrica":"PROVENTOS 70%"},
{"nuRubrica":"09-8000","sgBaseCalculo":"B8000","nmModalidadeRubrica":"BASE DO TETO DE REMUNERACAO"},
{"nuRubrica":"09-8001","sgBaseCalculo":"TETO","nmModalidadeRubrica":"TETO DE REMUNERACAO"},
{"nuRubrica":"09-9956","sgBaseCalculo":"BFER"}
]', '$[*]' COLUMNS (nuRubrica, nmModalidadeRubrica, sgBaseCalculo)) js
INNER JOIN epagRubrica rub ON LPAD(rub.cdTipoRubrica,2,0) || '-' || LPAD(rub.nuRubrica,4,0) = js.nuRubrica
INNER JOIN epagRubricaAGrupamento rubagrp ON rubagrp.cdRubrica = rub.cdRubrica
INNER JOIN ecadAgrupamento a ON a.cdAgrupamento = rubagrp.cdAgrupamento
LEFT JOIN epagBaseCalculo base on base.sgBaseCalculo = js.sgBaseCalculo AND base.cdAgrupamento = rubagrp.cdAgrupamento
LEFT JOIN epagModalidadeRubrica mod ON mod.nmModalidadeRubrica = js.nmModalidadeRubrica
WHERE a.sgAgrupamento = 'MILITAR'
) LOOP
UPDATE epagRubricaAGrupamento
SET cdBaseCalculo = rec.cdBaseCalculo,
    cdModalidadeRubrica = rec.cdModalidadeRubrica
WHERE cdRubricaAgrupamento = rec.cdRubricaAgrupamento;

DBMS_OUTPUT.PUT_LINE(
'Rubrica ' || rec.nuRubrica || '=' || rec.cdRubricaAgrupamento || ', ' || CHR(13) || CHR(10) ||
'Modalidade ' || rec.nmModalidadeRubrica || '=' || rec.cdModalidadeRubrica || ', ' || CHR(13) || CHR(10) ||
'Base ' || rec.sgBaseCalculo  || '=' ||rec.cdBaseCalculo || CHR(13) || CHR(10));

END LOOP;
END;

==========================================================================================

SELECT a.sgAgrupamento, a.cdAgrupamento,
JSON_ARRAYAGG(JSON_OBJECT(
  'nuRubrica'           VALUE LPAD(rub.cdTipoRubrica,2,0) || '-' || LPAD(rub.nuRubrica,4,0),
  'nmModalidadeRubrica' VALUE mod.nmModalidadeRubrica,
  'sgBaseCalculo'       VALUE base.sgBaseCalculo
ABSENT ON NULL)) AS BaseCalculo
FROM epagRubricaAgrupamento rubagrp
INNER JOIN epagRubrica rub ON rub.cdrubrica = rubagrp.cdRubrica
INNER JOIN ecadAgrupamento a ON a.cdAgrupamento = rubagrp.cdAgrupamento
LEFT JOIN epagBaseCalculo base on base.cdBaseCalculo = rubagrp.cdBaseCalculo AND  base.cdAgrupamento = rubagrp.cdAgrupamento
LEFT JOIN epagModalidadeRubrica mod ON mod.cdModalidadeRubrica = rubagrp.cdModalidadeRubrica
WHERE a.sgAgrupamento = 'MILITAR'
  AND (rubagrp.cdModalidadeRubrica IS NOT NULL OR rubagrp.cdBaseCalculo IS NOT NULL)
GROUP BY a.sgAgrupamento, a.cdAgrupamento
;

==========================================================================================

SELECT hr.derubricaagrupamento, r.*
FROM   epagrubricaagrupamento r
       INNER JOIN epaghistrubricaagrupamento hr ON hr.cdrubricaagrupamento = r.cdrubricaagrupamento AND hr.nuanofimvigencia IS NULL
WHERE  cdmodalidaderubrica IS NOT NULL 
AND    cdagrupamento = 19