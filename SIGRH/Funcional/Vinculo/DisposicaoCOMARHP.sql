select o.sgorgao as Orgao,
	   lpad(p.nucpf, 11, 0) CPF,
       lpad(v.numatricula || '-' || nudvmatricula,9,0) as Matricula,
       p.nmpessoa as Nome,
       v.dtadmissao as dtAdmissao,
	   v.dtdesligamento as dtDesligamento

from ecadvinculo v
inner join vcadorgao o on o.cdorgao = v.cdorgao
inner join ecadpessoa p on p.cdpessoa = v.cdpessoa
where v.dtadmissao < last_day(sysdate) + 1
  and (v.dtdesligamento > last_day(sysdate) or v.dtdesligamento is null)
  and o.sgorgao != 'COMARHP'
  and v.cdpessoa in (select v.cdpessoa from ecadvinculo v
                      inner join ecadpessoa p on p.cdpessoa = v.cdpessoa
                      inner join vcadorgao o on o.cdorgao = v.cdorgao
                      where v.dtadmissao < last_day(sysdate) + 1
                        and (v.dtdesligamento > last_day(sysdate) or v.dtdesligamento is null)
                        and o.sgorgao = 'COMARHP')