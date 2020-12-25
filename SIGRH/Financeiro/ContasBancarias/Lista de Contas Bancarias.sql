select nuMAtricula||'-'|| NuDvMatricula || '-'||nuSeqMAtricula, P.NUCPF, P.NmPessoa, B.Nubanco, A.NUAGENCIA, A.Nmagencia, H.Nucontacredito, H.Nudvcontacredito,
'ALTERADO', H.NUCONTACREDITO, H.Nudvcontacredito
  from ecadVinculo V
 inner join ecadPessoa P
    on P.cdPessoa = V.cdPessoa
 inner join Ecadhistdadosbancariosvinculo H
   on H.Cdvinculo = V.Cdvinculo  AND H.Dtfimvigencia is null
 inner join ecadAgencia A
   on A.Cdagencia = H.Cdagenciacredito
 inner join ecadBanco b
   on B.cdbanco = A.cdBanco
where V.cdVinculo IN (select cdVinculo from (
select cdVinculo,count(*) from Ecadhistdadosbancariosvinculo where cdVInculo IN (
select cdVinculo from Ecadhistdadosbancariosvinculo a where a.dtiniciovigencia >= '01/03/2020' and NUCPFCadastrador = '11111111111')
group by cdVinculo having count(*)>1))
union
select nuMAtricula||'-'|| NuDvMatricula || '-'||nuSeqMAtricula, P.NUCPF, P.NmPessoa, B.Nubanco, A.NUAGENCIA, A.Nmagencia, H.Nucontacredito, H.Nudvcontacredito,
'INCLUIDO', H.NUCONTACREDITO, H.Nudvcontacredito
  from ecadVinculo V
 inner join ecadPessoa P
    on P.cdPessoa = V.cdPessoa
 inner join Ecadhistdadosbancariosvinculo H
   on H.Cdvinculo = V.Cdvinculo  AND H.Dtfimvigencia is null
 inner join ecadAgencia A
   on A.Cdagencia = H.Cdagenciacredito
 inner join ecadBanco b
   on B.cdbanco = A.cdBanco
where V.cdVinculo IN (select cdVinculo from (
select cdVinculo,count(*) from Ecadhistdadosbancariosvinculo where cdVInculo IN (
select cdVinculo from Ecadhistdadosbancariosvinculo a where a.dtiniciovigencia >= '01/03/2020' and NUCPFCadastrador = '11111111111')
group by cdVinculo having count(*)=1))

