select DISTINCT 
       lpad(p.nucpf, 11, 0) CPF,
       p.nmpessoa Nome,
       p.dtnascimento DtNascimento
  from ecadvinculo v
  inner join vcadorgao o on o.cdorgao = v.cdorgao
  inner join ecadpessoa p on p.cdpessoa = v.cdpessoa
where v.dtadmissao < '01/05/2020'
   and (v.dtdesligamento > '01/05/2020' or
        v.dtdesligamento is null)
order by p.nmpessoa