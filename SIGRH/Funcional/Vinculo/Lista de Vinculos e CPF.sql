select v.cdvinculo,
       substr(o.cdorgaosirh, 1, 4) Orgao,
          lpad(v.numatricula, 7, 0)||'-'||v.nudvmatricula as Matricula,
          lpad(p.nucpf, 11, 0) CPF,
          p.nmpessoa Nome
  from ecadvinculo v
  inner join vcadorgao o on o.cdorgao = v.cdorgao
  inner join ecadpessoa p on p.cdpessoa = v.cdpessoa
  where v.dtdesligamento is null
