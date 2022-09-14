-- Valida uma Data passando o Formato
-- FMIG_VALIDA_DATA(dtnascimento,'DD/MM/YYYY')
create or replace function FMIG_VALIDA_DATA (
  pData in varchar2,
  pFormato in varchar2
) return number is

lData date;

begin

    if pData is null
      then return null;
    end if;
    
    lData := to_date(pData, pFormato);
    return 1;

exception
    when others then return null;

end FMIG_VALIDA_DATA;