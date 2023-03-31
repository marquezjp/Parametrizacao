--- Atualização da Estrutura de Carreira da Relação de Vinculo do Efetivo com base na Capa de Pagamento
begin
  for i in (
select cef.cdhistcargoefetivo, capa.cdestruturacarreira from ecadHistCargoEfetivo cef
inner join ( select cdvinculo, max(dtinicio) as dtinicio from ecadHistCargoEfetivo group by cdvinculo
) ultimocef on cef.cdvinculo = ultimocef.cdvinculo and cef.dtinicio = ultimocef.dtinicio
inner join epagfolhapagamento f on f.flcalculodefinitivo = 'S' and f.cdtipofolhapagamento = 2 and cdtipocalculo = 1
                               and f.nuanoreferencia = 2022 and f.numesreferencia = 08
inner join epagcapahistrubricavinculo capa on capa.cdfolhapagamento = f.cdfolhapagamento and capa.cdvinculo = cef.cdvinculo
where cef.cdestruturacarreira != capa.cdestruturacarreira
  ) loop

    update ecadHistCargoEfetivo set cdestruturacarreira = i.cdestruturacarreira
    where cdhistcargoefetivo = i.cdhistcargoefetivo;
    
  end loop;
end;
/

--- Atualização da Estrutura de Carreira da Capa de Pagamento com base nas informações do Arquivo de Migração da Capa de Pagamento
begin
  for i in (

with
carreira as (
select
 e.cdagrupamento,
 e.cdestruturacarreira,
 icar.deitemcarreira as decarreira,
 ic.deitemcarreira as decargo
from ecadestruturacarreira e 
inner join ecaditemcarreira ic on ic.cdagrupamento = e.cdagrupamento and ic.cdtipoitemcarreira = 3 and ic.cditemcarreira = e.cditemcarreira
inner join ecadestruturacarreira ecar on ecar.cdagrupamento = e.cdagrupamento and ecar.cdestruturacarreira = e.cdestruturacarreiracarreira
inner join ecaditemcarreira icar on icar.cdagrupamento = ecar.cdagrupamento and icar.cdtipoitemcarreira = 1 and icar.cditemcarreira = ecar.cditemcarreira
),
mig as (
select
 case trim(capa.sgorgao)
 	when 'CASACIVIL'   then 'CASA CIVIL'
	when 'CERIM'       then 'CASA CIVIL'
	when 'COGERR'      then 'CGE/RR'
	when 'CONANTD'     then 'SEJUC'
	when 'CONCULT'     then 'SECULT'
	when 'CONEDUC'     then 'SEED'
	when 'CONPEN'      then 'SEJUC'
	when 'CONREFIS'    then 'SEFAZ'
	when 'CONRODE'     then 'SEINF'
	when 'CSAMILITAR'  then 'CASA MILITAR'
	when 'CASAMILITAR' then 'CASA MILITAR'
	when 'IPEM'        then 'IPEM/RR'
	when 'OGERR'       then 'OGE/RR'
	when 'PENSIONIST'  then 'SEGAD'
	when 'POLCIVIL'    then 'PC/RR'
	when 'PROGE'       then 'PGE/RR'
	when 'CERR'        then 'CER'
	when 'CGERR'       then 'CGE/RR'
	when 'CM'          then 'CBM/RR'
	when 'CBM'         then 'CBM/RR'
	when 'CBM AD RV'   then 'CBM/RR'
	when 'CBMRR'       then 'CBM/RR'
	when 'DEFPUB'      then 'DPE/RR'
	when 'PM'          then 'PM/RR'
	when 'VICE GOV'    then 'VICEGOV'
	when 'UNIVIR'      then 'UNIVIRR'

	when 'CON SEJURR'  then 'CONSEJURR' -- Revisar
	when 'CON TRANS'   then 'CONTRANS'  -- Revisar

	else trim(capa.sgorgao)
 end as sgorgao,

 capa.nuanoreferencia,
 capa.numesreferencia,
 capa.nmtipofolha,
 capa.nmtipocalculo,
 lpad(capa.nusequencialfolha,2,0) as nusequencialfolha,

 lpad(to_number(trim(capa.numatriculalegado)),10,0) as numatriculalegado,

 trim(capa.decarreira) as decarreira,
 trim(capa.decargo) as decargo

from sigrhmig.emigcapapagamento2 capa
where capa.nuanoreferencia = 2022 and capa.numesreferencia = 08 and capa.nusequencialfolha = 01
  and nmtipofolha = 'FOLHA NORMAL' and nmtipocalculo = 'NORMAL'
  and trim(capa.nmrelacaotrabalho) in ('EFETIVO', 'ACT - ADMITIDO EM CARATER TEMPORARIO')
),
migajustado as (
select f.cdfolhapagamento, v.cdvinculo, c.cdestruturacarreira from mig
inner join ecadhistorgao o on o.sgorgao = mig.sgorgao
inner join epagtipofolhapagamento tf on tf.nmtipofolhapagamento = mig.nmtipofolha
inner join epagtipocalculo tc on upper(tc.nmtipocalculo) = mig.nmtipocalculo
inner join epagfolhapagamento f on f.nuanoreferencia = mig.nuanoreferencia
                               and f.numesreferencia = mig.numesreferencia
                               and f.cdorgao = o.cdorgao
                               and f.cdtipofolhapagamento = tf.cdtipofolhapagamento
                               and f.cdtipocalculo = tc.cdtipocalculo
                               and f.nusequencialfolha = mig.nusequencialfolha
inner join emigmatricula m on lpad(trim(m.numatriculalegado),10,0) = mig.numatriculalegado
inner join ecadvinculo v on v.numatricula = m.numatricula and v.nuseqmatricula = m.nuseqmatricula
left join carreira c on c.cdagrupamento = o.cdagrupamento and c.decarreira = mig.decarreira and c.decargo = mig.decargo
)

select mig.cdfolhapagamento, mig.cdvinculo, mig.cdestruturacarreira from migajustado mig
left join epagcapahistrubricavinculo capa on capa.cdfolhapagamento = mig.cdfolhapagamento and capa.cdvinculo = mig.cdvinculo
where capa.cdfolhapagamento is not null
  and mig.cdestruturacarreira != capa.cdestruturacarreira

  ) loop

    update epagcapahistrubricavinculo set cdestruturacarreira = i.cdestruturacarreira
    where cdfolhapagamento = i.cdfolhapagamento and cdvinculo = i.cdvinculo;
    
  end loop;
end;
/

--- Atualização da Estrutura de Carreira da Relação de Vinculo do Efetivo com base na Capa de Pagamento
begin
  for i in (
select cef.cdhistcargoefetivo, capa.cdestruturacarreira from ecadHistCargoEfetivo cef
inner join ( select cdvinculo, max(dtinicio) as dtinicio from ecadHistCargoEfetivo group by cdvinculo
) ultimocef on cef.cdvinculo = ultimocef.cdvinculo and cef.dtinicio = ultimocef.dtinicio
inner join epagfolhapagamento f on f.flcalculodefinitivo = 'S' and f.cdtipofolhapagamento = 2 and cdtipocalculo = 1
                               and f.nuanoreferencia = 2022 and f.numesreferencia = 08
inner join epagcapahistrubricavinculo capa on capa.cdfolhapagamento = f.cdfolhapagamento and capa.cdvinculo = cef.cdvinculo
where cef.cdestruturacarreira != capa.cdestruturacarreira
  ) loop

    update ecadHistCargoEfetivo set cdestruturacarreira = i.cdestruturacarreira
    where cdhistcargoefetivo = i.cdhistcargoefetivo;
    
  end loop;
end;
/