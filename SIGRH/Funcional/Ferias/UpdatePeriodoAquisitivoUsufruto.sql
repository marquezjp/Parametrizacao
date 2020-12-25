define Matricula = 11011
define DtIncioPeriodoAquisitivoNovo = '01/03/17'
define DtIncioPeriodoAquisitivoAntigo = '02/01/18'

-- Atualizar o Gozo de Ferias para um Novo Periodo Aquisitivo
update emovferiasfruicaousufruto f
set f.cdperiodoaquisitivoferias = (select pa.cdperiodoaquisitivoferias from emovperiodoaquisitivoferias pa
                                    inner join ecadvinculo v on v.cdvinculo = pa.cdvinculo
                                    where v.numatricula = &Matricula
                                      and pa.dtinicio = &DtIncioPeriodoAquisitivoNovo)
where f.cdferiasprogramacaousufruto = (select fer.cdferiasprogramacaousufruto from emovferiasfruicaousufruto fer
                                        inner join emovperiodoaquisitivoferias pa on pa.cdperiodoaquisitivoferias = fer.cdperiodoaquisitivoferias
                                        inner join ecadvinculo v on v.cdvinculo = pa.cdvinculo
                                        where v.numatricula = &Matricula
                                          and fer.dtinicial = &DtIncioPeriodoAquisitivoAntigo);

-- Atualizar o Pagamento do Gozo das Ferias para um Novo Periodo Aquisitivo
update emovferiasfruicaopagamento
set cdperiodoaquisitivoferias = (select cdperiodoaquisitivoferias from emovperiodoaquisitivoferias
                                  where dtinicio = &DtIncioPeriodoAquisitivoNovo and cdvinculo = (select cdvinculo from ecadvinculo where numatricula = &Matricula))
where cdperiodoaquisitivoferias = (select cdperiodoaquisitivoferias from emovperiodoaquisitivoferias
                                   where dtinicio = &DtIncioPeriodoAquisitivoAntigo and cdvinculo = (select cdvinculo from ecadvinculo where numatricula = &Matricula))
                                   