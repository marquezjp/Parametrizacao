-- insert into ecadpessoactps
select
 rownum,
 t2.cdpessoa,
 t1.nuctps,
 t1.nuseriectps,
 t1.sgestadoctps,
 to_date(t1.dtemissaoctps, 'rrrr-mm-dd') dtemissaoctps
from sigrhmig.emigpessoa t1,
inner join ecadpessoa t2 on t1.nucpf = t2.nucpf
                        and t1.dtnascimento = t2.dtnascimento
                        and t1.flsexo = t2.flsexo
where not exists (select * from sigrh.ecadpessoactps t3
                  where t3.cdpessoa = t2.cdpessoa
                    and t3.nuctps = t1.nuctps
                    and t3.nuseriectps = t1.nuseriectps
                    and t3.sgestadoctps = t1.sgestadoctps
                    and to_char(t3.dtemissaoctps, 'rrrr-mm-dd') = t1.dtemissaoctps)
;