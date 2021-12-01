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