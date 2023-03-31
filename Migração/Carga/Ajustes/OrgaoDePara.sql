with
orgaos as (
select 'VICE-GOV' as sgorgao from dual union
select 'CASA CIVIL' as sgorgao from dual union
select 'CASA MILITAR' as sgorgao from dual union
select 'SECOM' as sgorgao from dual union
select 'PGE-RR' as sgorgao from dual union
select 'COGER' as sgorgao from dual union
select 'CPL' as sgorgao from dual union
select 'SEPLAN' as sgorgao from dual union
select 'SEFAZ' as sgorgao from dual union
select 'SEGAD' as sgorgao from dual union
select 'SEINF' as sgorgao from dual union
select 'SEADI' as sgorgao from dual union
select 'SETRABES' as sgorgao from dual union
select 'SEED' as sgorgao from dual union
select 'SECULT' as sgorgao from dual union
select 'SESAU' as sgorgao from dual union
select 'SESP' as sgorgao from dual union
select 'SEJUC' as sgorgao from dual union
select 'SEI' as sgorgao from dual union
select 'SECIDADES' as sgorgao from dual union
select 'DPE-RR' as sgorgao from dual union
select 'PM-RR' as sgorgao from dual union
select 'CBM-RR' as sgorgao from dual union
select 'PC-RR' as sgorgao from dual union
select 'OGE-RR' as sgorgao from dual union
select 'SERBRAS' as sgorgao from dual union
select 'SEEDIS' as sgorgao from dual union
select 'SEEGD' as sgorgao from dual union
select 'SEERF' as sgorgao from dual union
select 'ADERR' as sgorgao from dual union
select 'DETRAN-RR' as sgorgao from dual union
select 'IATER' as sgorgao from dual union
select 'IPEM-RR' as sgorgao from dual union
select 'IPER' as sgorgao from dual union
select 'JUCERR' as sgorgao from dual union
select 'UERR' as sgorgao from dual union
select 'RADIORAIMA' as sgorgao from dual union
select 'DESENVOLVE-RR' as sgorgao from dual union
select 'CAER' as sgorgao from dual union
select 'CER' as sgorgao from dual union
select 'CODESAIMA' as sgorgao from dual union
select 'FEMARH' as sgorgao from dual union
select 'IERR' as sgorgao from dual union
select 'ITERAIMA' as sgorgao from dual union
select 'DER' as sgorgao from dual union
select 'FAPERR' as sgorgao from dual union
select 'AFERR' as sgorgao from dual union
select 'IDEFER-RR' as sgorgao from dual union
select 'IACTI-RR' as sgorgao from dual union
select 'SEURB-RR' as sgorgao from dual union
select 'UNIVIRR' as sgorgao from dual union
select 'SEGABI' as sgorgao from dual union
select 'SEPIN' as sgorgao from dual union
select 'SEEGI' as sgorgao from dual union
select 'SEEPI' as sgorgao from dual union
select 'SEAPI' as sgorgao from dual union
select 'SEPAQ' as sgorgao from dual union
select 'SEAGI' as sgorgao from dual union
select 'SETI' as sgorgao from dual union
select 'SERI' as sgorgao from dual union
select 'SEPHD' as sgorgao from dual union
select 'SEAE' as sgorgao from dual union
select 'SEAI' as sgorgao from dual union
select 'SEDE' as sgorgao from dual union
select 'SEERI' as sgorgao from dual union
select 'SEPES' as sgorgao from dual union
select 'SEPE' as sgorgao from dual union
select 'SEPM' as sgorgao from dual
)
select * from (
select distinct
 case trim(sgorgao)
	when 'CONANTD'     then 'SEJUC'
	when 'CONCULT'     then 'SECULT'
	when 'CONEDUC'     then 'SEED'
	when 'CONPEN'      then 'SEJUC'
	when 'CONREFIS'    then 'SEFAZ'
	when 'CONRODE'     then 'SEINF'
	when 'PENSIONIST'  then 'SEGAD'
	when 'PLANTONIST'  then 'SESAU'
	when 'PROGE'       then 'PGE-RR'
	when 'COGERR'      then 'COGER'
	when 'IPEM'        then 'IPEM-RR'
	when 'OGERR'       then 'OGE-RR'
	when 'DEFPUB'      then 'DPE-RR'
	when 'VICE GOV'    then 'VICE-GOV'
	when 'UNIVIR'      then 'UNIVIRR'
	when 'IDEFER'      then 'IDEFER-RR'
	when 'SEURB'       then 'SEURB-RR'
	when 'SEEPE'       then 'SEPE'
 	when 'CASACIVIL'   then 'CASA CIVIL'
	when 'CERIM'       then 'CASA CIVIL'
	when 'CSAMILITAR'  then 'CASA MILITAR'
	when 'POLCIVIL'    then 'PC-RR'
	when 'BM'          then 'CBM-RR'
	when 'PM'          then 'PM-RR'
	when 'PRODEB'      then 'SEED'
	else trim(sgorgao)
 end as sgorgao
from sigrhmig.emigcapapagamento2
)
where sgorgao not in (select sgorgao from orgaos)
;
/

set serveroutput on

declare

function deparaOrgao(pOrgao varchar2) return varchar2 is
begin
 return
   case trim(pOrgao)
    when 'CONANTD'     then 'SEJUC'
    when 'CONCULT'     then 'SECULT'
    when 'CONEDUC'     then 'SEED'
    when 'CONPEN'      then 'SEJUC'
    when 'CONREFIS'    then 'SEFAZ'
    when 'CONRODE'     then 'SEINF'
    when 'PENSIONIST'  then 'SEGAD'
    when 'PLANTONIST'  then 'SESAU'
    when 'PROGE'       then 'PGE-RR'
    when 'COGERR'      then 'COGER'
    when 'IPEM'        then 'IPEM-RR'
    when 'OGERR'       then 'OGE-RR'
    when 'DEFPUB'      then 'DPE-RR'
    when 'VICE GOV'    then 'VICE-GOV'
    when 'UNIVIR'      then 'UNIVIRR'
    when 'IDEFER'      then 'IDEFER-RR'
    when 'SEURB'       then 'SEURB-RR'
    when 'CASACIVIL'   then 'CASA CIVIL'
    when 'CERIM'       then 'CASA CIVIL'
    when 'CSAMILITAR'  then 'CASA MILITAR'
    when 'POLCIVIL'    then 'PC-RR'
    when 'BM'          then 'CBM-RR'
    when 'PM'          then 'PM-RR'
    when 'PRODEB'      then 'SEED'
    else trim(pOrgao)
   end
  ;
end deparaOrgao;

begin

  select distinct
   deparaOrgao(sgorgao) as sgorgao,
   upper(trim(decentrocusto)) as decentrocusto
  from sigrhmig.emigcapapagamento2
  order by 1, 2;

end;
/