select
    '%' || SUBSTR(p.nmpessoa,1,30) || '%' as nome,
    lpad(v.numatricula || '-' || v.nudvmatricula,9,0) as matricula,
    p.nucpf as cpf
from ecadvinculo v
inner join ecadpessoa p on p.cdpessoa = v.cdpessoa
where v.numatricula in (953623, 951607, 953684, 949716)