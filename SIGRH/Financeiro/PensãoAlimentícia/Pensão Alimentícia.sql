select cv.numatricula, cv.nudvmatricula, pe.nucpf, pe.nmpessoa, p.*
  from epensentencajudicial sj
 inner join epenhistsentencajudicial hsj
    on sj.cdsentencajudicial = hsj.cdsentencajudicial
 inner join epenhistdadosbancarios p
    on p.cdsentencajudicial = sj.cdsentencajudicial
 left  join epenpessoapensao pe on pe.cdpessoapensao = sj.cdpessoapensao
 inner join ecadvinculo cv on cv.cdvinculo = sj.cdvinculo
 where (hsj.dtfimvigencia is null or hsj.dtfimvigencia >= sysdate)
   and (p.dtfimvigencia is null or p.dtfimvigencia >= sysdate)
   and pe.nucpf = 11009602446
