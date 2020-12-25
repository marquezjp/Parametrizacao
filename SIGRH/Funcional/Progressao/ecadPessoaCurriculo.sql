select cv.*
from ecadpessoacurriculo cv
inner join ecadpessoa p on p.cdpessoa = cv.cdpessoa
where p.nucpf = 99495023491
  and cv.flanulado = 'S'
  order by cv.cdcurriculo

--delete from ecadpessoacurriculo
--where cdcurriculo in (select cv.*
--                        from ecadpessoacurriculo cv
--                        inner join ecadpessoa p on p.cdpessoa = cv.cdpessoa
--                        where p.nucpf = 99495023491 and cv.flanulado = 'S')