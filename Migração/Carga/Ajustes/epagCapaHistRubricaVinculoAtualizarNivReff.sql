begin
  for i in (
with
matriculas as (
select
trim(sgorgao) as sgorgao,
lpad(to_number(trim(numatriculalegado)),10,0) as numatriculalegado,
lpad(numatricula,7,0) || '-' || nudvmatricula || '-' || lpad(nuseqmatricula,2,0) as numatricula
from emigmatricula
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

 lpad(capa.nuanoreferencia,4,0) || lpad(capa.numesreferencia,2,0) as nuanomesreferencia,
 capa.nmtipofolha,
 capa.nmtipocalculo,
 lpad(capa.nusequencialfolha,2,0) as nusequencialfolha,

 lpad(to_number(trim(capa.numatriculalegado)),10,0) as numatriculalegado,

 lpad(capa.nucpf, 11, 0) as nucpf,
 capa.nmpessoa as nmpessoa,
 to_date(trim(capa.dtadmissao), 'YYYY-MM-DD HH24:MI:SS') as dtadmissao,

 trim(capa.nunivelcef) as nunivelrefcef,
 case trim(capa.nunivelcef)
  when null  then null
  when '0'   then null
  when '00'  then null
  when '1'   then 'A'
  when '2'   then 'A'
  when '3'   then 'A'
  when '4'   then 'A'
  when '5'   then 'A'
  when '6'   then 'A'
  when '01'  then 'A'
  when '02'  then 'A'
  when '03'  then 'A'
  when '04'  then 'A'
  when '05'  then 'A'
  when '06'  then 'A'
  when '7'   then 'A'
  when '8'   then 'A'
  when '9'   then 'A'
  when '10'  then 'A'
  when '11'  then 'A'
  when '12'  then 'A'
  when '13'  then 'A'
  when '14'  then 'A'
  when '15'  then 'A'
  when '100' then 'A'
  when '101' then 'A'
  when '102' then 'A'
  when '103' then 'A'
  when '104' then 'A'
  when '105' then 'A'
  when '201' then 'B'
  when '202' then 'B'
  when '203' then 'B'
  when '204' then 'B'
  when '205' then 'B'
  when '206' then 'B'
  when '301' then 'C'
  when '302' then 'C'
  when '303' then 'C'
  when '304' then 'C'
  when '305' then 'C'
  when '306' then 'C'
  when 'A'   then 'A'
  when 'B'   then 'B'
  when 'C'   then 'C'
  when 'D'   then 'D'
  when 'E'   then 'E'
  when 'I'   then 'I'
  when 'S'   then 'S'
  else case when trim(TRANSLATE(substr(trim(capa.nunivelcef),1,1), '0123456789 -,.', ' ')) is null
            then substr(trim(capa.nunivelcef),1,2)
            else substr(trim(capa.nunivelcef),1,1)
       end
 end as nunivelcef,
 case trim(capa.nunivelcef)
  when null  then null
  when '0'   then null
  when '00'  then null
  when '1'   then '01'
  when '2'   then '02'
  when '3'   then '03'
  when '4'   then '04'
  when '5'   then '05'
  when '6'   then '06'
  when '01'  then '01'
  when '02'  then '02'
  when '03'  then '03'
  when '04'  then '04'
  when '05'  then '05'
  when '06'  then '06'
  when '7'   then '07'
  when '8'   then '08'
  when '9'   then '09'
  when '10'  then '10'
  when '11'  then '11'
  when '12'  then '12'
  when '13'  then '13'
  when '14'  then '14'
  when '15'  then '15'
  when '100' then '01'
  when '101' then '01'
  when '102' then '02'
  when '103' then '03'
  when '104' then '04'
  when '105' then '05'
  when '201' then '01'
  when '202' then '02'
  when '203' then '03'
  when '204' then '04'
  when '205' then '05'
  when '206' then '06'
  when '301' then '01'
  when '302' then '02'
  when '303' then '03'
  when '304' then '04'
  when '305' then '05'
  when '306' then '06'
  when 'A'   then '01'
  when 'B'   then '01'
  when 'C'   then '01'
  when 'D'   then '01'
  when 'E'   then '01'
  when 'I'   then '01'
  when 'S'   then '01'
  else  case when trim(TRANSLATE(substr(trim(capa.nunivelcef),1,1), '0123456789 -,.', ' ')) is null
             then substr(trim(capa.nunivelcef),3,1)
             else substr(trim(capa.nunivelcef),2,2)
        end
 end as nureferenciacef,

 to_number(nvl(capa.vlproventos, 0)) as vlproventos,
 to_number(nvl(capa.vldescontos, 0)) as vldescontos

from sigrhmig.emigcapapagamento2 capa
where capa.nuanoreferencia = 2022 and capa.numesreferencia = 08
  and trim(capa.nmrelacaotrabalho) in ('EFETIVO', 'ACT - ADMITIDO EM CARATER TEMPORARIO')
),
capa as (
select 
 o.sgorgao as sgorgao,
 f.nuanomesreferencia as nuanomesreferencia,
 tf.nmtipofolhapagamento as nmtipofolha,
 upper(tc.nmtipocalculo) as nmtipocalculo,
 lpad(f.nusequencialfolha,2,'0') as nusequencialfolha,

 lpad(to_number(trim(m.numatriculalegado)),10,0) as numatriculalegado,

 lpad(p.nucpf, 11, 0) as nucpf,
 p.nmpessoa as nmpessoa,
 v.dtadmissao as dtadmissao,

 nvl(capa.vlproventos, 0) as vlproventos,
 nvl(capa.vldescontos, 0) as vldescontos,
 
 capa.cdfolhapagamento,
 capa.cdvinculo

from epagcapahistrubricavinculo capa
inner join epagfolhapagamento f on f.cdfolhapagamento = capa.cdfolhapagamento
                               and f.flcalculodefinitivo = 'S'
inner join epagtipofolhapagamento tf on tf.cdtipofolhapagamento = f.cdtipofolhapagamento
inner join epagtipocalculo tc on tc.cdtipocalculo = f.cdtipocalculo
inner join vcadorgao o on o.cdorgao = f.cdorgao
inner join ecadvinculo v on v.cdvinculo = capa.cdvinculo
inner join emigmatricula m on m.numatricula = v.numatricula and m.nuseqmatricula = v.nuseqmatricula
inner join ecadpessoa p on p.cdpessoa = v.cdpessoa
where f.nuanoreferencia = 2022 and f.numesreferencia = 08
)

select 
capa.cdfolhapagamento,
capa.cdvinculo,
mig.nunivelcef,
mig.nureferenciacef

from mig
left join capa on capa.sgorgao = mig.sgorgao
              and capa.nuanomesreferencia = mig.nuanomesreferencia
              and capa.nmtipofolha = mig.nmtipofolha
              and capa.nmtipocalculo = mig.nmtipocalculo
              and capa.nusequencialfolha = mig.nusequencialfolha
              and capa.numatriculalegado = mig.numatriculalegado
where capa.sgorgao is not null

  ) loop

    update epagcapahistrubricavinculo set nunivelcef = i.nunivelcef, nureferenciacef = i.nureferenciacef
    where cdfolhapagamento = i.cdfolhapagamento and cdvinculo = i.cdvinculo;
    
  end loop;
end;
/