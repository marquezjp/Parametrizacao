declare
  -- Boolean parameters are translated from/to integers: 
  -- 0/1/null <--> false/true/null 
  plog boolean := sys.diutil.int_to_bool(:plog);
  ptrace boolean := sys.diutil.int_to_bool(:ptrace);
  -- Non-scalar parameters require additional processing 
  pcalculoretorno pkgpag_cal.rcalculoretorno;
begin
  -- Call the procedure
  pkgpag_tar.pentrarcalculoindividual(pcdfolhapagamento => :pcdfolhapagamento,
                                      pcdvinculo => :pcdvinculo,
                                      pdtcalculo => :pdtcalculo,
                                      pflcalculodefinitivo => :pflcalculodefinitivo,
                                      pvldiferencavalor => :pvldiferencavalor,
                                      pflpagaadiantamento => :pflpagaadiantamento,
                                      plog => plog,
                                      ptrace => ptrace,
                                      pcalculoretorno => pcalculoretorno);
end;


--PARÂMETROS 


--FOLHA
  select o.sgorgao, o.cdorgao from vcadorgao o
  
  select * from epagfolhapagamento f 
     where f.cdorgao = 24
       and f.nuanomesreferencia = 202103
       and f.cdtipofolhapagamento = 2
       and f.cdtipocalculo = 1 
       --- 44275


--VÍNCULO

   select * from ecadvinculo v where v.numatricula = 954472 -- 48830
