select distinct
 case trim(sgorgao)
	when 'CONANTD'     then 'SEJUC'
	when 'CONCULT'     then 'SECULT'
	when 'CONEDUC'     then 'SEED'
	when 'PRODEB'      then 'SEED'
	when 'CONPEN'      then 'SEJUC'
	when 'CONREFIS'    then 'SEFAZ'
	when 'CONRODE'     then 'SEINF'

	when 'PENSIONIST'  then 'SEGAD'
	when 'PLANTONIST'  then 'SESAU'

	when 'VICE GOV'    then 'VICE-GOV'
 	when 'CASACIVIL'   then 'CASA CIVIL'
	when 'CERIM'       then 'CASA CIVIL'
	when 'CSAMILITAR'  then 'CASA MILITAR'
	when 'POLCIVIL'    then 'PC-RR'
	when 'SEURB'       then 'SEURB-RR'
	when 'SEEPE'       then 'SEPE'
	when 'COGERR'      then 'COGER'
	when 'OGERR'       then 'OGE-RR'

	when 'BM'          then 'CBM-RR'
	when 'PM'          then 'PM-RR'

	when 'PROGE'       then 'PGE-RR'
	when 'DEFPUB'      then 'DPE-RR'

	when 'IPEM'        then 'IPEM-RR'
	when 'UNIVIR'      then 'UNIVIRR'
	when 'IDEFER'      then 'IDEFER-RR'

	else trim(sgorgao)
 end as sgorgao,
 upper(trim(decentrocusto)) as decentrocusto
from sigrhmig.emigcapapagamento2
order by 1, 2
;
/