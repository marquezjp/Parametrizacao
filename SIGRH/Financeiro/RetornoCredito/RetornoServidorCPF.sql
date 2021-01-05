
select 
           f.cdfolhapagamento          ChaveFolha,
           v.cdvinculo                 ChaveVinculo,
           f.nuanomesreferencia        AnoMes,
           tfo.nmtipofolhapagamento    TipoFolha,
           tc.nmtipocalculo            TipoCalculo,
           o.SGorgao                   Orgao,
           pe.nmpessoa                 Nome,
           pe.nucpf                    CPF,
           lpad(v.numatricula, 7, 0)||'-'||v.nudvmatricula||'-'||lpad(v.nuseqmatricula, 2, 0) as Matricula,  
           (nvl(capa.vlproventos, 0) - nvl(capa.vldescontos, 0)) as Liquido,
           banco.nubanco NuBanco,
           capa.NmArqRetorno  Arq_Retorno,
           capa.nuretcreditoocor1||'-'||oc1.deocorrenciabancobrasil Desc_Erro1,
           capa.nuretcreditoocor2||'-'||oc2.deocorrenciabancobrasil Desc_Erro2,
           capa.nuretcreditoocor3||'-'||oc3.deocorrenciabancobrasil Desc_Erro3,
           capa.nuretcreditoocor4||'-'||oc4.deocorrenciabancobrasil Desc_Erro4,
           capa.nuretcreditoocor5||'-'||oc5.deocorrenciabancobrasil Desc_Erro5
           
       from epagcapahistrubricavinculo capa
       
          inner join ecadvinculo v on v.cdvinculo = capa.cdvinculo
          inner join ecadpessoa pe on pe.cdpessoa = v.cdpessoa
          inner join epagfolhapagamento f
                  on f.cdfolhapagamento = capa.cdfolhapagamento and
                     f.flcalculodefinitivo = 'S'
          inner join epagtipofolhapagamento tfo on tfo.cdtipofolhapagamento = f.cdtipofolhapagamento
          inner join epagtipocalculo tc on tc.cdtipocalculo = f.cdtipocalculo
          inner join vcadorgao o on o.cdorgao = f.cdorgao
          left  join epagocorrenciabancobrasil oc1 on oc1.cdocorrenciabancobrasil = capa.nuretcreditoocor1
          left  join epagocorrenciabancobrasil oc2 on oc2.cdocorrenciabancobrasil = capa.nuretcreditoocor2
          left  join epagocorrenciabancobrasil oc3 on oc3.cdocorrenciabancobrasil = capa.nuretcreditoocor3
          left  join epagocorrenciabancobrasil oc4 on oc4.cdocorrenciabancobrasil = capa.nuretcreditoocor4
          left  join epagocorrenciabancobrasil oc5 on oc5.cdocorrenciabancobrasil = capa.nuretcreditoocor5
          left  join ecadagencia ag on ag.cdagencia = capa.cdagenciacredito 
          left  join ecadbanco banco on banco.cdbanco = ag.cdbanco
          left  join ecadhistdadosbancariosvinculo db on db.cdvinculo = capa.cdvinculo and db.dtfimvigencia is null
          left  join ecadagencia agn on agn.cdagencia = db.cdagenciacredito 
          left  join ecadbanco bancon on bancon.cdbanco = agn.cdbanco
           
             where f.nuanomesreferencia >= 202003 and            
                  (nvl(capa.vlproventos, 0) - nvl(capa.vldescontos, 0)) > 0 and
                  pe.nucpf = '00948712481'
          
       order by f.nuanomesreferencia, capa.nuretcreditoocor1, oc1.deocorrenciabancobrasil, banco.nubanco
