select lpad(v.numatricula || '-' || v.nudvmatricula, 9, 0) as Matricula,
       p.nmpessoa,
       a.dtinicio as DataInicioAfastamento,
       a.dtfim as DataFimAfastamento,
       case a.fltipoafastamento
         when 'D' then 'DEFINITIVO'
         when 'T' then 'TEMPORARIO'
         else ''
       end as TipoAfastamento,
       case a.fltipoafastamento
         when 'D' then hd.demotivoafastdefinitivo
         when 'T' then ht.demotivoafasttemporario
         else ''
       end as MotivoAfastamento,
       case ht.flremunerado
         when 'N' then 'NAO'
         when 'S' then 'SIM'
         else ''
       end as AfastamentoRemunerado

from eafaafastamentovinculo a
inner join ecadvinculo v on v.cdvinculo = a.cdvinculo
inner join ecadpessoa p on p.cdpessoa = v.cdpessoa

left join eafamotivoafastdefinitivo d on d.cdmotivoafastdefinitivo = a.cdmotivoafastdefinitivo
left join eafahistmotivoafastdef hd on hd.cdmotivoafastdefinitivo = d.cdmotivoafastdefinitivo

left join eafamotivoafasttemporario t on t.cdmotivoafasttemporario = a.cdmotivoafasttemporario
left join eafahistmotivoafasttemp ht on ht.cdmotivoafasttemporario = t.cdmotivoafasttemporario

where a.flanulado = 'N'
  and a.dtinicio < last_day(sysdate) + 1
  and (a.dtfim is null or a.dtfim > last_day(sysdate))