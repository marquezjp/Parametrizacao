--PARÂMETROS 

-- plog = 0
-- ptrace = 0
-- pflcalculodefinitivo = S
-- pflpagaadiantamento = Null
-- pdtcalculo = '01/05/2021' -- Data Atual
-- pvldiferencavalor = Null
-- pcdvinculo = 49142
-- pcdfolhapagamento = 45968

-- Vinculo
--select cdvinculo from ecadvinculo v where v.numatricula = 954777;

-- Folha
--select cdfolhapagamento from epagfolhapagamento f 
--where f.cdorgao = (select cdorgao from vcadorgao where sgorgao = 'SEMED')
--  and f.nuanomesreferencia = 202105
--  and f.cdtipofolhapagamento = 2
--  and f.cdtipocalculo = 1;

-- Calculo Individual --
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
