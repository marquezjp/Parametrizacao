declare
  pproprietario varchar2(200);
  pnometabela varchar2(200);
  resultado types.ref_cursor;

begin
  pproprietario := 'sigrhmig';
  pnometabela := 'emigdependente';

  pmigestatisticasdescritivas(
    pproprietario => pproprietario,
    pnometabela => pnometabela,
    resultado => resultado
  );
  
  resultado :=resultado;
end;