DECLARE 
  l_data CLOB; 
  l_json json_object_t; 
  l_text CLOB := EMPTY_CLOB(); 
BEGIN 
  dbms_lob.createtemporary(l_data,true);
  l_data := '{"text": "';
  for i in 1 .. 50 loop
    l_data := l_data || lpad('x', 32767, 'x'); 
  end loop;
  l_data := l_data || '"}'; 
  l_json := json_object_t.parse(l_data); 
  dbms_lob.freetemporary(l_data);
  l_text := l_json.get_clob('text'); 
  dbms_output.put_line('got ' || dbms_lob.getlength(l_text) || ' chars'); 
END;