select c.mat,
       c.dg,
       v.dtadmissao,
       v.dtdesligamento,
       c.empfil,
       c.codlot,
       p.nmpessoa ,
       o.sgorgao,
       uoAtual.NMUNIDADEORGANIZACIONAL UOAtual,
       uoNova.NMUNIDADEORGANIZACIONAL UONOva,
       v.cdorgao,
       c.cdunidadeorganizacionalvinculo,
       c.cdunidadeorganizacionalnova
       --, v.cdunidadeorganizacional, p.cdpessoa
  from fp.pmactbcad c,
       ecadvinculo v,
       sigrhhml.vcadorgaoultimavigencia o,
       ecadpessoa p,
       sigrhhml.vcaduoultimavigencia uoNova,
       sigrhhml.vcaduoultimavigencia uoAtual
 where --mat in (11425,952810,   4348,945433,947734)and
       c.cdvinculo = v.cdvinculo
       and v.cdorgao = o.cdorgao (+)
       and c.cdunidadeorganizacionalvinculo = uoAtual.cdunidadeorganizacional  (+)
       and c.cdunidadeorganizacionalnova = uoNova.cdunidadeorganizacional (+)
       and v.cdpessoa = p.cdpessoa
--       and v.cdpessoa in (27831,21704,18369)
       and (
                (
                    (V.dtdesligamento is null or v.DtDesligamento > sysdate)
                        or uoNova.CDUNIDADEORGANIZACIONAL is not null
                )
                and uoAtual.NMUNIDADEORGANIZACIONAL is not null
            )
        and O.cdOrgao = 22

 order by nmpessoa, mat
