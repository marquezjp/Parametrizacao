select D.Nmdependente, GP.NMGRAUPARENTESCO, E.DEGRAUPARENTESCOPREVFIN
  from ecadDependente D
  inner join  Ecadpessoadependente PD
  on D.Cddependente = PD.Cddependente
  inner join Ecadgrauparentesco GP
    on GP.Cdgrauparentesco = PD.CDGRAUPARENTESCO
  inner join Ecadgrauparentescoprevfin E
    on  E.CDGRAUPARENTESCOPREVFIN = PD.Cdgrauparentescoprevfin
  inner  join ecadPessoa P
    on P.cdPessoa = PD.Cdresponsavel