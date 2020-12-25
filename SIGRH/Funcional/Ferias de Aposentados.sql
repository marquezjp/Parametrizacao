select
         Orgao,
         Nome,
         Matricula,
         MesNascimento,
         MesAdmissao,
         Inicio_APO,
         Fim_APO,

         Base13sal,
         case when Meses_Ativo = 0 then 0
              when MesNascimento <= to_char(Inicio_APO, 'MM') then 0
                else (Base13sal / 12 * Meses_Ativo) end
                   as  Rescisao13Sal,
         case when Meses_Ativo = 0 then 'Aposentou em Janeiro'
              when MesNascimento <= to_char(Inicio_APO, 'MM') then 'Já fez aniversário'
                else ' ' end
                   as  Critica13Sal,

         BaseFerias,
         case when MesAdmissao <= to_char(Inicio_APO, 'MM') then 0
                else (BaseFerias / 3) end
                   as  RescisaoFérias,
         case when MesAdmissao <= to_char(Inicio_APO, 'MM') then 'Já fez aniversário de admissao'
                else ' ' end
                   as  CriticaFérias

    from
    (
    select
         Orgao,
         Nome,
         Matricula,
         MesNascimento,
         MesAdmissao,
         Inicio_APO,
         Fim_APO,
         Meses_Ativo,
         Ult_AnoMes_Ativo,
         case when nvl(Base_13Sal_SIGRH, 0) > 0 then nvl(Base_13Sal_SIGRH, 0) else nvl(Base_13Sal_FOLPAG, 0) end as Base13sal,
         case when nvl(Base_Ferias_SIGRH, 0) > 0 then nvl(Base_Ferias_SIGRH, 0) else nvl(Base_Ferias_FOLPAG, 0) end as BaseFerias
    from
    (
    select
         Orgao,
         Nome,
         Matricula,
         MesNascimento,
         MesAdmissao,
         Inicio_APO,
         Fim_APO,
         Meses_Ativo,
         Ult_AnoMes_Ativo,

         (select (pag.vlpagamento * 12) from epaghistoricorubricavinculo pag
                inner join epagfolhapagamento f
                        on f.cdfolhapagamento = pag.cdfolhapagamento and
                           f.cdtipofolhapagamento = 2 and
                           f.cdtipocalculo = 1 and
                           f.flcalculodefinitivo = 'S' and
                           f.cdorgao <> 44 -- IPREV
                inner join vpagrubricaagrupamento rub on rub.cdrubricaagrupamento = pag.cdrubricaagrupamento
                  where rub.cdtiporubrica = 9
                   and rub.nurubrica = 889
                   and f.nuanomesreferencia = Ult_AnoMes_Ativo
                   and pag.cdvinculo = Vinculo
          ) as Base_13Sal_FOLPAG,

          (select pag.vlpagamento from epaghistoricorubricavinculo pag
                inner join epagfolhapagamento f
                        on f.cdfolhapagamento = pag.cdfolhapagamento and
                           f.cdtipofolhapagamento = 2 and
                           f.cdtipocalculo = 1 and
                           f.flcalculodefinitivo = 'S' and
                           f.cdorgao <> 44 -- IPREV
                inner join vpagrubricaagrupamento rub on rub.cdrubricaagrupamento = pag.cdrubricaagrupamento
                  where rub.cdtiporubrica = 9
                   and rub.nurubrica = 913
                   and f.nuanomesreferencia = Ult_AnoMes_Ativo
                   and pag.cdvinculo = Vinculo
          ) as Base_13Sal_SIGRH,

          (select (pag.vlpagamento * 12 * 3) from epaghistoricorubricavinculo pag
                inner join epagfolhapagamento f
                        on f.cdfolhapagamento = pag.cdfolhapagamento and
                           f.cdtipofolhapagamento = 2 and
                           f.cdtipocalculo = 1 and
                           f.flcalculodefinitivo = 'S' and
                           f.cdorgao <> 44 -- IPREV
                inner join vpagrubricaagrupamento rub on rub.cdrubricaagrupamento = pag.cdrubricaagrupamento
                  where rub.cdtiporubrica = 9
                   and rub.nurubrica = 890
                   and f.nuanomesreferencia = Ult_AnoMes_Ativo
                   and pag.cdvinculo = Vinculo
          ) as Base_Ferias_FOLPAG,

          (select pag.vlpagamento from epaghistoricorubricavinculo pag
                inner join epagfolhapagamento f
                        on f.cdfolhapagamento = pag.cdfolhapagamento and
                           f.cdtipofolhapagamento = 2 and
                           f.cdtipocalculo = 1 and
                           f.flcalculodefinitivo = 'S' and
                           f.cdorgao <> 44 -- IPREV
                inner join vpagrubricaagrupamento rub on rub.cdrubricaagrupamento = pag.cdrubricaagrupamento
                  where rub.cdtiporubrica = 9
                   and rub.nurubrica = 1133
                   and f.nuanomesreferencia = Ult_AnoMes_Ativo
                   and pag.cdvinculo = Vinculo
          ) as Base_Ferias_SIGRH

    from
    (
    select
        apo.cdvinculo                                                                      as Vinculo,
        o.sgorgao                                                                          as Orgao,
        pe.nmpessoa                                                                        as Nome,
        lpad(v.numatricula, 7, 0)||'-'||v.nudvmatricula||'-'||lpad(v.nuseqmatricula, 2, 0) as Matricula,
        to_char(pe.dtnascimento, 'MM')                                                     as MesNascimento,
        to_char(v.dtadmissao, 'MM')                                                        as MesAdmissao,
        apo.dtinicioaposentadoria                                                          as Inicio_APO,
        apo.dtfimaposentadoria                                                             as Fim_APO,
        Trunc(MONTHS_BETWEEN(apo.dtinicioaposentadoria, TO_DATE('01/01/2020')))            as Meses_Ativo,

        (select max((f.nuanoreferencia * 100) + f.numesreferencia)
                from epagcapahistrubricavinculo capa
                   inner join epagfolhapagamento f
                           on f.cdfolhapagamento = capa.cdfolhapagamento and
                              f.cdtipofolhapagamento = 2 and
                              f.cdtipocalculo = 1 and
                              f.flcalculodefinitivo = 'S' and
                              f.cdorgao <> 44 -- IPREV
                   where capa.cdvinculo = apo.cdvinculo
        ) Ult_AnoMes_Ativo


     from epvdconcessaoaposentadoria apo

        inner join ecadvinculo v on v.cdvinculo = apo.cdvinculo
        inner join ecadpessoa pe on pe.cdpessoa = v.cdpessoa
        inner join ecadhistcargoefetivo cef
                on cef.cdvinculo = v.cdvinculo and
                   cef.flanulado = 'N' and
                   cef.dtfim is not null and
                   (apo.dtinicioaposentadoria - 1) between cef.dtinicio and cef.dtfim
        inner join vcadorgao o on o.cdorgao = cef.cdorgaoexercicio

      where apo.dtinicioaposentadoria >= '01/01/2020'
        and apo.dtfimaposentadoria is null
    )
    )
    )
         order by Inicio_APO, Orgao, Nome
