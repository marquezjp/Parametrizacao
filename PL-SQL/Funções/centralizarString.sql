create or replace
function centralizarString(pTexto varchar2, pTamanho number)
 return varchar2
is  
begin  
 return lpad(rpad(pTexto,length(pTexto) + (pTamanho - length(pTexto) - 1) / 2,' '),pTamanho,' ');
end centralizarString;