select HO.* from ecadOrgao O
inner join ecadHIstOrgao HO
  on O.cdOrgao = HO.cdOrgao
where HO.dtInicioVigencia <=sysdate and (HO.Dtfimvigencia >=sysdate or HO.Dtfimvigencia is null)

select HU.* from ecadUnidadeOrganizacional U
inner join ecadHIstUnidadeOrganizacional HU
  on U.cdUnidadeOrganizacional = HU.cdUnidadeOrganizacional
where HU.dtInicioVigencia <=sysdate and (HU.Dtfimvigencia >=sysdate or HU.Dtfimvigencia is null)
