create or replace function nivel_referencia
(nivref in varchar2,
progresso in number)
return string
is

grupo varchar2(4);
nivelAtual number;
refAtual number;
nivelNovo number;
refNovo number;
padroes number;
nivrefNovo varchar2(8);

begin

grupo := substr( nivref, 1 , 4 );
nivelAtual := ascii(substr( nivref, 5 , 1 )) - 64;
refAtual   := to_number(substr( nivref, 6 , 2 ));

padroes := (nivelAtual * 6 ) + refAtual + progresso;

if padroes > 30 then
  padroes := 30;
elsif padroes < 1 then
  padroes := 1;
end if;

nivelNovo := trunc((padroes - 1) / 6);
refNovo   := padroes - (nivelNovo * 6);

if grupo = '0000' then
  nivrefNovo := nivref;
else
  nivrefNovo := grupo || chr(nivelNovo + 64) || lpad(refNovo,2,0);
end if;

return nivrefNovo;

end;

--set serveroutput on;
--begin  
--   dbms_output.put_line(' Teste: ' || nivel_referencia('MG01C02', 5));  
--end; 