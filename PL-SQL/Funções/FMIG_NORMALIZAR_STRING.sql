create or replace function FMIG_NORMALIZAR_STRING(pTexto varchar2)
 return varchar2
is  
begin  
 return translate(regexp_replace(upper(trim(pTexto)), '[[:space:]]+', chr(32)),
         'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
         'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz');
end FMIG_NORMALIZAR_STRING;