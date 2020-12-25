select o.sgorgao Orgao,
       lpad(v.numatricula, 7, 0)||'-'||v.nudvmatricula as Matricula,
       fpag.nuanoreferencia,
       fpag.numesreferencia,
       fer.dtinicial,
       fer.dtfinal,
       pa.dtinicio,
       pa.dtfimprevisto,
       pa.dtfim,

       pa.cdsituacaoperiodoaqferias,
       fer.insituacao,

       fpag.nudiasreceber,
       pa.nudiasferiasconcedido,
       fer.nudias,
       fpag.nudiasdevolvidos,

       fpag.nuparceladevadiantamento,

       fpag.flabono,
       fpag.fladiantamento13,
       fpag.fladiantamentoferias,
       fpag.flpagamentoindenizado,
       fpag.nuanomesdevolucao,
       pa.flajustedpro,
       fer.flpagabonopecuniario,

       --fpag.dtinclusao,
       --pa.dtinclusao,
       --fer.dtinclusao,

       --fpag.flanulado,
       --fpag.dtanulado,
       --fer.flanulado,
       --fer.dtanulado,

       fpag.cdferiasfruicaopagamento as PK_FPAG,
       pa.cdperiodoaquisitivoferias as PK_PA,
       fer.cdferiasprogramacaousufruto as PK_Fer
from emovferiasfruicaopagamento fpag
left join emovperiodoaquisitivoferias pa on pa.cdperiodoaquisitivoferias = fpag.cdperiodoaquisitivoferias
left join emovferiasfruicaousufruto fer on fer.cdperiodoaquisitivoferias = fpag.cdperiodoaquisitivoferias
inner join ecadvinculo v on v.cdvinculo = pa.cdvinculo
inner join vcadorgao o on o.cdorgao = v.cdorgao
where v.numatricula = 0012381
order by pa.dtinicio