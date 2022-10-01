DECLARE
  jo          JSON_OBJECT_T;
  ja          JSON_ARRAY_T;
  keys        JSON_KEY_LIST;
  keys_string VARCHAR2(100);
BEGIN
  jo := JSON_OBJECT_T.parse('{
			"Campo" : "SGORGAO",
			"Descrição" : "Sigla do órgão da folha de pagamento",
			"Tipo" : "VARCHAR2",
			"Tamanho" : "20",
			"Obrigatório" : "Sim",
			"Padrão" : "",
			"Domínio" : "",
			"SIGRH" : ["ECADORGAO.SGORGAO"]
}');
  ja := new JSON_ARRAY_T;

  keys := jo.get_keys;
  
  DBMS_OUTPUT.put_line (
      'Number of elements in array: ' || jo.get_size ());

  FOR i IN 1..keys.COUNT LOOP
     ja.append(keys(i));
  END LOOP;

  keys_string := ja.to_string;

  DBMS_OUTPUT.put_line(keys_string);

END;