SET SERVEROUTPUT ON SIZE UNLIMITED;
BEGIN
FOR rec IN (
SELECT rubagrp.cdRubricaAgrupamento, base.cdBaseCalculo, mod.cdModalidadeRubrica,
js.nuRubrica, js.nmModalidadeRubrica, js.sgBaseCalculo
FROM JSON_TABLE('[
{"nuRubrica":"09-0901","nmModalidadeRubrica":"TOTAL DE PROVENTOS"},
{"nuRubrica":"09-9956","sgBaseCalculo":"BFER"},
{"nuRubrica":"09-9918","sgBaseCalculo":"B9910"},
{"nuRubrica":"09-9000","nmModalidadeRubrica":"DEVOLUÇÃO DE ADIANTAMENTO DO 13O NÃO EFETUADO"},
{"nuRubrica":"09-8001","nmModalidadeRubrica":"TETO DE REMUNERACAO","sgBaseCalculo":"TETO"},
{"nuRubrica":"09-8000","nmModalidadeRubrica":"BASE DO TETO DE REMUNERACAO","sgBaseCalculo":"B8000"},
{"nuRubrica":"09-6005","nmModalidadeRubrica":"PROVENTOS 70%","sgBaseCalculo":"B70BR"},
{"nuRubrica":"09-6003","nmModalidadeRubrica":"MARGEM CONSIG LIQUIDA - C-CRED"},
{"nuRubrica":"09-6002","nmModalidadeRubrica":"MARGEM CONSIGNAVEL BRUTA - CARTAO DE CREDITO","sgBaseCalculo":"BMCC"},
{"nuRubrica":"09-6001","nmModalidadeRubrica":"MARGEM CONSIGNAVEL LIQUIDA"},
{"nuRubrica":"09-4000","nmModalidadeRubrica":"VALOR DE ABATIMENTO DE DEPENDENTE DE IRRF"},
{"nuRubrica":"09-3001","nmModalidadeRubrica":"BASE DE CÁLCULO DO IRRF SOBRE 13 SALÁRIO","sgBaseCalculo":"B3001"},
{"nuRubrica":"09-3000","nmModalidadeRubrica":"BASE DE CALCULO DO IRRF","sgBaseCalculo":"B3000"},
{"nuRubrica":"09-2005","nmModalidadeRubrica":"SALARIO DE CONTRIBUICAO DO IPESC SOBRE 13 SALARIO","sgBaseCalculo":"B2005"},
{"nuRubrica":"09-2000","nmModalidadeRubrica":"SALARIO DE CONTRIBUICAO DO IPESC","sgBaseCalculo":"B2000"},
{"nuRubrica":"09-1940","nmModalidadeRubrica":"SALÁRIO DE CONTRIBUIÇÃO DO INSS PATRONAL - EST","sgBaseCalculo":"PINSS"},
{"nuRubrica":"09-1789","nmModalidadeRubrica":"SALARIO DE CONTRIBUICAO DO IPESC","sgBaseCalculo":"PIPER"},
{"nuRubrica":"09-1031","nmModalidadeRubrica":"VALOR DESCONTO IRRF OUTROS VINCULOS/FOLHAS"},
{"nuRubrica":"09-1030","nmModalidadeRubrica":"BASE IRRF OUTROS VINCULOS/FOLHA"},
{"nuRubrica":"09-1028","nmModalidadeRubrica":"VALOR DO DESCONTO DO INSS VARIOS VINCULOS"},
{"nuRubrica":"09-1027","nmModalidadeRubrica":"VALOR DA BASE DO INSS VARIOS VINCULOS"},
{"nuRubrica":"09-1005","nmModalidadeRubrica":"SALÁRIO DE CONTRIBUIÇÃO DO INSS SOBRE 13 SALÁRIO","sgBaseCalculo":"B1005"},
{"nuRubrica":"09-1000","nmModalidadeRubrica":"SALARIO DE CONTRIBUICAO DO INSS","sgBaseCalculo":"B1000"},
{"nuRubrica":"09-0980","sgBaseCalculo":"BSALF"},
{"nuRubrica":"09-0951","nmModalidadeRubrica":"MARGEM CONSIGNAVEL BRUTA","sgBaseCalculo":"BMAR"},
{"nuRubrica":"09-0913","nmModalidadeRubrica":"BASE DO 13 SALARIO"},
{"nuRubrica":"09-0904","nmModalidadeRubrica":"TOTAL LIQUIDO"},
{"nuRubrica":"09-0902","nmModalidadeRubrica":"TOTAL DE DESCONTOS"}
]', '$[*]' COLUMNS (nuRubrica, nmModalidadeRubrica, sgBaseCalculo)) js
INNER JOIN epagRubrica rub ON LPAD(rub.cdTipoRubrica,2,0) || '-' || LPAD(rub.nuRubrica,4,0) = js.nuRubrica
INNER JOIN epagRubricaAGrupamento rubagrp ON rubagrp.cdRubrica = rub.cdRubrica
INNER JOIN ecadAgrupamento a ON a.cdAgrupamento = rubagrp.cdAgrupamento
LEFT JOIN epagBaseCalculo base on base.sgBaseCalculo = js.sgBaseCalculo AND base.cdAgrupamento = 13
LEFT JOIN epagModalidadeRubrica mod ON mod.nmModalidadeRubrica = js.nmModalidadeRubrica
WHERE a.sgAgrupamento = 'INDIR-IPEM/RR'
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
INNER JOIN epagRubrica rub on rub.cdrubrica = rubagrp.cdRubrica
INNER JOIN ecadAgrupamento a ON a.cdAgrupamento = rubagrp.cdAgrupamento
LEFT JOIN epagBaseCalculo base on base.cdBaseCalculo = rubagrp.cdBaseCalculo AND  base.cdAgrupamento = rubagrp.cdAgrupamento
LEFT JOIN epagModalidadeRubrica mod ON mod.cdModalidadeRubrica = rubagrp.cdModalidadeRubrica
WHERE a.sgAgrupamento = 'INDIR-IPEM/RR'
  AND (rubagrp.cdModalidadeRubrica IS NOT NULL OR rubagrp.cdBaseCalculo IS NOT NULL)
GROUP BY a.sgAgrupamento, a.cdAgrupamento
;