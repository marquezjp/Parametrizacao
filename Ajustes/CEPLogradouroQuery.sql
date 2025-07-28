
SELECT log.tlo_tx AS Tipo, log.log_no AS Logadouro, UPPER(log.log_complemento) AS Complemento,
TRANSLATE(TRIM(UPPER(bai.bai_no)), 'ÁÇÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕ', 'ACEIOUAEIOUAEIOUAO') AS Bairro,
TRANSLATE(TRIM(UPPER(loc.loc_no)), 'ÁÇÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕ', 'ACEIOUAEIOUAEIOUAO') AS Localidade,
loc.ufe_sg AS Estado, log.CEP,
TO_NUMBER(loc.loc_nu) AS loc_nu, TO_NUMBER(bai.bai_nu) AS bai_nu, TO_NUMBER(log.log_nu) AS log_nu
FROM cep_Logradouro log
LEFT JOIN cep_Bairro bai ON TO_NUMBER(bai.bai_nu) = TO_NUMBER(log.bai_nu_ini) AND bai.ufe_sg = log.ufe_sg
LEFT JOIN cep_Localidade loc ON TO_NUMBER(loc.loc_nu) = TO_NUMBER(bai.loc_nu) AND loc.ufe_sg = log.ufe_sg
WHERE log.CEP LIKE REGEXP_REPLACE('57.036-540', '[^0-9]', '') || '%'
  AND UPPER(log.ufe_sg) LIKE TRIM(UPPER('AL' || '%'))
  AND TRANSLATE(TRIM(UPPER(loc.loc_no)), 'ÁÇÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕ', 'ACEIOUAEIOUAEIOUAO') LIKE TRANSLATE(UPPER('%' || REPLACE(TRIM(REPLACE('Maceió', '.', ' ')), ' ', '%') || '%'), 'ÁÇÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕ', 'ACEIOUAEIOUAEIOUAO')
  AND TRANSLATE(TRIM(UPPER(bai.bai_no)), 'ÁÇÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕ', 'ACEIOUAEIOUAEIOUAO') LIKE TRANSLATE(UPPER('%' || REPLACE(TRIM(REPLACE('Jatiúca', '.', ' ')), ' ', '%') || '%'), 'ÁÇÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕ', 'ACEIOUAEIOUAEIOUAO')
  AND TRANSLATE(TRIM(UPPER(log.tlo_tx)), 'ÁÇÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕ', 'ACEIOUAEIOUAEIOUAO') LIKE TRANSLATE(UPPER('%' || TRIM(REPLACE('r.', '.', ' ')) || '%'), 'ÁÇÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕ', 'ACEIOUAEIOUAEIOUAO')
  AND TRANSLATE(TRIM(UPPER(log.log_no)), 'ÁÇÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕ', 'ACEIOUAEIOUAEIOUAO') LIKE TRANSLATE(UPPER('%' || REPLACE(TRIM(REPLACE('Carlos Nogueira', '.', ' ')), ' ', '%') || '%'), 'ÁÇÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕ', 'ACEIOUAEIOUAEIOUAO')
ORDER BY loc.ufe_sg, loc.loc_no, bai_no, log.tlo_tx, log.log_no, log.log_complemento
;

SELECT DISTINCT log.tlo_tx FROM cep_logradouro log
ORDER BY log.tlo_tx
;

SELECT log.tlo_tx AS Tipo, log.log_no AS Logadouro, UPPER(log.log_complemento) AS Complemento,
TRANSLATE(TRIM(UPPER(bai.bai_no)), 'ÁÇÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕ', 'ACEIOUAEIOUAEIOUAO') AS Bairro,
TRANSLATE(TRIM(UPPER(loc.loc_no)), 'ÁÇÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕ', 'ACEIOUAEIOUAEIOUAO') AS Localidade,
loc.ufe_sg AS Estado, log.CEP,
TO_NUMBER(loc.loc_nu) AS loc_nu, TO_NUMBER(bai.bai_nu) AS bai_nu, TO_NUMBER(log.log_nu) AS log_nu
FROM log_Logradouro log
LEFT JOIN log_Bairro bai ON TO_NUMBER(bai.bai_nu) = TO_NUMBER(log.bai_nu_ini) AND bai.ufe_sg = log.ufe_sg
LEFT JOIN log_Localidade loc ON TO_NUMBER(loc.loc_nu) = TO_NUMBER(bai.loc_nu) AND loc.ufe_sg = log.ufe_sg
WHERE log.CEP LIKE REGEXP_REPLACE('57.036-540', '[^0-9]', '') || '%'
  AND UPPER(log.ufe_sg) LIKE TRIM(UPPER('AL' || '%'))
  AND TRANSLATE(TRIM(UPPER(loc.loc_no)), 'ÁÇÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕ', 'ACEIOUAEIOUAEIOUAO') LIKE TRANSLATE(UPPER('%' || REPLACE(TRIM(REPLACE('Maceió', '.', ' ')), ' ', '%') || '%'), 'ÁÇÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕ', 'ACEIOUAEIOUAEIOUAO')
  AND TRANSLATE(TRIM(UPPER(bai.bai_no)), 'ÁÇÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕ', 'ACEIOUAEIOUAEIOUAO') LIKE TRANSLATE(UPPER('%' || REPLACE(TRIM(REPLACE('Jatiúca', '.', ' ')), ' ', '%') || '%'), 'ÁÇÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕ', 'ACEIOUAEIOUAEIOUAO')
  AND TRANSLATE(TRIM(UPPER(log.tlo_tx)), 'ÁÇÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕ', 'ACEIOUAEIOUAEIOUAO') LIKE TRANSLATE(UPPER('%' || TRIM(REPLACE('Av.', '.', ' ')) || '%'), 'ÁÇÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕ', 'ACEIOUAEIOUAEIOUAO')
  AND TRANSLATE(TRIM(UPPER(log.log_no)), 'ÁÇÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕ', 'ACEIOUAEIOUAEIOUAO') LIKE TRANSLATE(UPPER('%' || REPLACE(TRIM(REPLACE('Carlos Nogueira', '.', ' ')), ' ', '%') || '%'), 'ÁÇÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕ', 'ACEIOUAEIOUAEIOUAO')
ORDER BY loc.ufe_sg, loc.loc_no, bai_no, log.tlo_tx, log.log_no, log.log_complemento
;

SELECT DISTINCT log.tlo_tx FROM log_Logradouro log
ORDER BY log.tlo_tx
;
