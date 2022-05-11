select
 'CARLOS ANTÔNIO  DOS SANTOS' as nomeOriginal,
 translate(regexp_replace(upper(trim('CARLOS ANTÔNIO  DOS SANTOS')), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as NomeTranslate
from dual;

select
 nome as nomeOriginal,
 translate(regexp_replace(upper(trim(nome)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as NomeTranslate
from tmpprogressaosemed;

begin
 for o in (select cdhistorgao,
                  translate(regexp_replace(upper(trim(nmorgao)), '[[:space:]]+', chr(32)),
                            'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                            'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as NomeTranslate
           from ecadhistorgao
          ) 
 loop
  update ecadhistorgao set nmorgao = o.NomeTranslate where cdhistorgao = o.cdhistorgao;
 end loop;
end;