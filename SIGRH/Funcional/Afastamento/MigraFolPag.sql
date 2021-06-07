select * 
  from sigrhtre.ePvdLaudoPericial
 where cdlaudopericial in
       (select t.cdlaudopericial
          from fp.atestado_Tre t
         where cdlaudopericial is not null);

select *
  from sigrhtre.epvdLaudoPericialAvaliacao
 where cdlaudopericialavaliacao in
       (select cdlaudopericialavaliacao
          from fp.atestado_Tre t
         where t.cdlaudopericialavaliacao is not null);

select *
  from sigrhtre.eafaafastamentovinculo
 where cdafastamento in (select cdafastamento
                           from fp.atestado_Tre
                          where cdafastamento is not null);
