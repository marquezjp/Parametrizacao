select nv.cdhistnivelrefcef, nv.dtinicio, nv.dtfim
    from ecadhistnivelrefcef nv 
    where nv.cdhistcargoefetivo in
        (select cef.cdhistcargoefetivo from ecadhistcargoefetivo cef
            inner join ecadvinculo v on v.cdvinculo = cef.cdvinculo
                where v.numatricula = 1024
        )
     and nv.flanulado = 'N'
    Order by nv.dtinicio;
        
select *
    from ecadhistnivelrefcef nv 
    where nv.cdhistcargoefetivo in
        (select cef.cdhistcargoefetivo from ecadhistcargoefetivo cef
            inner join ecadvinculo v on v.cdvinculo = cef.cdvinculo
                where v.numatricula = 1024
        )
      and nv.flanulado = 'N'
    Order by nv.dtinicio;
        
select nv.cdhistnivelrefcef, nv.dtfim
    from ecadhistnivelrefcef nv 
    where nv.cdhistnivelrefcef = 29087 ;
      
update ecadhistnivelrefcef nv
    set   nv.dtfim = '31/10/2006'
    where nv.cdhistnivelrefcef = 29079 ;
      
update ecadhistnivelrefcef nv
    set   nv.dtfim = null
    where nv.cdhistnivelrefcef = 29087 ;

commit;

select * from emovmovcargoefetivo h 
    where h.flanulado = 'N'
      and h.cdvinculo in
        (select v.cdvinculo from ecadvinculo v
            where v.numatricula = 929476
        )
    Order by h.dtevento;
    
select dtevento, h.nunivelorigem, h.nureferenciaorigem, h.nuniveldestino, h.nureferenciadestino
  from emovmovcargoefetivo h 
    where h.cdmovcargoefetivo = 114

update emovmovcargoefetivo h
    set   h.nureferenciaorigem = '02'
    where h.cdmovcargoefetivo = 114 ;

commit;