select p.nucpf, o.sgorgao, posse.dtposse, posse.dtlimiteefetivacao --, doc.nuanodocumento, doc.cdtipodocumento, doc.dtdocumento, doc.nmarquivodocumento, arq.nmarquivo --arq.*
from ecadpossevinculo posse
inner join ecadpessoa p on p.cdpessoa = posse.cdpessoa
inner join vcadorgao o on o.cdorgao = posse.cdorgao
--left join eatodocumento doc on doc.cddocumento = posse.cddocumento
--left join eatodocumentoarquivo arq on arq.cddocumento = posse.cddocumento
where p.nucpf = 01364725401;