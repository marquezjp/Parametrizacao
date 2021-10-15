select
	c.cdorgao CdOrgao,
	o.sgorgao Orgao,
	c.cdcentrocusto Cd_CC,
	c.nucentrocusto Nu_CC,
	c.nmcentrocusto Nome_CC,
	c.sgarquivocredito
from ecadcentrocusto c
inner join vcadorgao o on o.cdorgao = c.cdorgao
where c.cdorgao = 25
order by c.sgarquivocredito