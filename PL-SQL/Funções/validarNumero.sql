-- Valida se é Numero
-- validarNumero(nucpf)
function validarNumero(pConteudo in varchar2) return boolean is
begin
    if pConteudo is null then return FALSE ;
    end if;
    
    if trim(TRANSLATE(pConteudo, '0123456789 -,.', ' ')) is null
      then return TRUE ;
    else
      return FALSE ;
    end if;
end validarNumero;