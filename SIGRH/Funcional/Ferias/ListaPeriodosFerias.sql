define Matricula = 11011

select 
       o.sgorgao Orgao,
       lpad(v.numatricula, 7, 0)||'-'||v.nudvmatricula as Matricula,
       pa.cdperiodoaquisitivoferias as PK_PA,
       pa.dtinicio as Inicio_Pa,
       PA.DTFIM    as Fim_PA,
       f.cdferiasprogramacaousufruto as PK_Fer,
       f.dtinicial as Inicio_Fer,
       f.dtfinal   as Fim_fer,
       fpag.nuanoreferencia,
       fpag.numesreferencia,
       fpag.nudiasreceber
       
from ecadvinculo v
inner join ecadpessoa pe on pe.cdpessoa = v.cdpessoa
inner join vcadorgao o on o.cdorgao = v.cdorgao
inner join emovperiodoaquisitivoferias pa on pa.cdvinculo = v.cdvinculo
left  join emovferiasfruicaousufruto f on f.cdperiodoaquisitivoferias = pa.cdperiodoaquisitivoferias
left  join emovferiasfruicaopagamento fpag on fpag.cdperiodoaquisitivoferias = pa.cdperiodoaquisitivoferias

where v.numatricula = &Matricula

order by pa.dtinicio;