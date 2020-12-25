define MESANO = '01-03-2020'

select  '202003'                                                                           MesAno,
        o.sgorgao                                                                          OrgaoFolha,
        p.nmpessoa                                                                         Nome,
        lpad(v.numatricula, 7, 0)||'-'||v.nudvmatricula                                    Matricula,
        p.nucpf                                                                            CPF

from ecadvinculo v
inner join ecadpessoa p on p.cdpessoa = v.cdpessoa
inner join vcadorgao o on o.cdorgao = v.cdorgao 
inner join (
    select p.nucpf as nucpf, count(*) as vinculos
    from ecadvinculo v
    inner join ecadpessoa p on p.cdpessoa = v.cdpessoa
    where v.flanulado = 'N'
      and (v.dtadmissao < '&MESANO')
      and (v.dtdesligamento is null or v.dtdesligamento > last_day('&MESANO'))
    group by p.nucpf
    having count(*) > 1
) d on d.nucpf = p.nucpf
order by p.nucpf
;