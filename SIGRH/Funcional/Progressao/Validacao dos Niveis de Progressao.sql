select h.cdorgao,
       h.cdvinculo,
       h.dtevento,
       h.nunivelorigem,
       h.nureferenciaorigem,
       h.nuniveldestino,
       h.nureferenciadestino,
       h.dtinclusao
 from emovmovcargoefetivo h 
 where h.flanulado = 'N'
   and h.dtinclusao > '01/04/2020'
 order by
      h.cdorgao,
      h.cdvinculo,
      h.dtevento;
    
select count(h.cdmovcargoefetivo) from emovmovcargoefetivo h 
 where h.flanulado = 'N'
 order by h.dtevento;
 
select * from (
select h.cdvinculo, count(*) qtde
 from emovmovcargoefetivo h
 where h.flanulado = 'N'
   and h.dtinclusao > '01/04/2020'
 group by h.cdvinculo
) where qtde > 1

;