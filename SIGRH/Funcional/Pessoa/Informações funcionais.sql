select V.Numatricula || '-' || V.nuDvMatricula || '-' || V.nuSeqMatricula,
       P.Nmpessoa,
       T.NMTIPOLOGRADOURO,
       E.NMLOGRADOURO,
       E.Nunumero,
       E.Decomplemento,
       B.Nmbairro,
       E.NUCEP,
       NmLocalidade
  from ecadVinculo V
 inner join ecadPessoa P
    on P.cdPessoa = V.cdPessoa
 inner join ecadHistCargoCom C
    on C.cdVinculo = V.Cdvinculo
 inner join Ecadendereco E
    on E.cdEndereco = P.cdEndereco
  left join Ecadtipologradouro T
    on T.Cdtipologradouro = E.Cdtipologradouro
  left join ecadBairro B
    on B.cdBairro = E.cdBairro
  left join Ecadlocalidade L
    on L.Cdlocalidade = E.Cdlocalidade
 where C.Cdrelacaotrabalho = 4
   and C.dtFim is null
   and C.flanulado = 'N'
   and C.Fltipoprovimento = 'N'
   and v.dtdesligamento is null

