-- Valida uma Data passando o Formato
-- validarData(dtnascimento,'DD/MM/YYYY')
create or replace function validarData(
  pConteudo in varchar2,
  pFormato in varchar2 default 'DD/MM/YYYY'
) return number is

lData date;

begin

    if pData is null
      then return null;
    end if;
    
    lData := to_date(pConteudo, pFormato);
    return 1;

exception
    when others then return null;

end validarData;