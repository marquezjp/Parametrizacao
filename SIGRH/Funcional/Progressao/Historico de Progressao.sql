select count(cdhistcargoefetivo) from ecadhistcargoefetivo;

select count(cdhistnivelrefcef) from ecadhistnivelrefcef;

select count(cdmovcargoefetivo) from emovmovcargoefetivo;

select * from emovmovcargoefetivo;

select h.*
  from ecadhistnivelrefcef h
  join emovmovcargoefetivo m
    on m.cdmovcargoefetivo = h.cdmovcargoefetivo