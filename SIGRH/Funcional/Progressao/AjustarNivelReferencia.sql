define Matricula = 926896

select cdvinculo, cdmovcargoefetivo, '|' || NUNIVELORIGEM || '|', '|' || NUNIVELDESTINO || '|'
from emovmovcargoefetivo
where cdvinculo = (select cdvinculo from ecadvinculo where numatricula = &Matricula)
order by 1 desc;

select cdvinculo, cdhistcargoefetivo, '|' || NUNIVELPAGAMENTO || '|'
from ecadhistcargoefetivo
where cdvinculo =  (select cdvinculo from ecadvinculo where numatricula = &Matricula)
  and dtfim is null;

select cdhistnivelrefcef, cdhistcargoefetivo, '|' || NUNIVELPAGAMENTO || '|', '|' || NUNIVELENQUADRAMENTO || '|'
from ecadhistnivelrefcef
where flanulado = 'N'
  and cdhistcargoefetivo = (select cdhistcargoefetivo from ecadhistcargoefetivo hce
                             inner join ecadvinculo v on v.cdvinculo = hce.cdvinculo
                             where v.numatricula = &Matricula and hce.dtfim is null)
order by 1 desc;

-- Ajustar os campos NUNIVELORIGEM e NUNIVELDESTINO RETIRANDO O BRANCO 
update emovmovcargoefetivo
set NUNIVELDESTINO = trim(NUNIVELDESTINO),
    NUNIVELORIGEM  = trim(NUNIVELORIGEM)
where cdvinculo = (select cdvinculo from ecadvinculo where numatricula = &Matricula);

-- Ajustar o campo NUNIVELPAGAMENTO RETIRANDO O BRANCO
update ecadhistcargoefetivo
set NUNIVELPAGAMENTO = trim(NUNIVELPAGAMENTO)
where cdvinculo =  (select cdvinculo from ecadvinculo where numatricula = &Matricula)
  and dtfim is null;

-- Ajustar os campos NUNIVELPAGAMENTO e NUNIVELENQUADRAMENTO RETIRANDO O BRANCO
update ecadhistnivelrefcef
set NUNIVELPAGAMENTO = trim(NUNIVELPAGAMENTO),
    NUNIVELENQUADRAMENTO = trim(NUNIVELENQUADRAMENTO)
where flanulado = 'N'
    and cdhistcargoefetivo = (select cdhistcargoefetivo from ecadhistcargoefetivo hce
                               inner join ecadvinculo v on v.cdvinculo = hce.cdvinculo
                               where v.numatricula = &Matricula and hce.dtfim is null);
