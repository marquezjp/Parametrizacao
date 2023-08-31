select distinct sgorgao, numatriculalegado, nucpf, dtinicio, dtfim, dtfimprevisto, fltipoafastamento, demotivoafastamento, nmgrupomotivoafastamento, flremunerado, flremuneracaointegral, flacidentetrabalho, deobservacao from (
select sgorgao, lpad(trim(numatriculalegado),9,0) as numatriculalegado, lpad(trim(nucpf),11,0) as nucpf,
replace(trim(dtinicioafastamento),'NULL','') as dtinicio, replace(trim(dtfimafastamento),'NULL','') as dtfim, replace(trim(dtfimprevistoafastamento),'NULL','') as dtfimprevisto,
fltipoafastamento, demotivoafastamento, nmgrupomotivoafastamento, flremunerado, flremuneracaointegral, flacidentetrabalho, deobservacaoafastamento as deobservacao,  '1-CEF' as origem
from sigrhmig.emigvinculoefetivocsv where replace(dtinicioafastamento,'NULL','') is not null union
select sgorgao, lpad(trim(numatriculalegado),9,0) as numatriculalegado, lpad(trim(nucpf),11,0) as nucpf,
replace(trim(dtinicioafastamento),'NULL','') as dtinicio, replace(trim(dtfimafastamento),'NULL','') as dtfim, replace(trim(dtfimprevistoafastamento),'NULL','') as dtfimprevisto,
fltipoafastamento, demotivoafastamento, nmgrupomotivoafastamento, flremunerado, flremuneracaointegral, flacidentetrabalho, deobservacaoafastamento as deobservacao,  '2-CCO' as origem
from sigrhmig.emigvinculocomissionadocsv where replace(dtinicioafastamento,'NULL','') is not null union
select sgorgao, lpad(trim(numatriculalegado),9,0) as numatriculalegado, lpad(trim(nucpf),11,0) as nucpf,
replace(trim(dtinicioafastamento),'NULL','') as dtinicio, replace(trim(dtfimafastamento),'NULL','') as dtfim, replace(trim(dtfimprevisto),'NULL','') as dtfimprevisto,
fltipoafastamento, demotivoafastamento, nmgrupomotivoafastamento, flremuneradoafastamento, flremuneracaointegral, flacidentetrabalho, deobservacao,  '3-BOL' as origem
from sigrhmig.emigvinculobolsistacsv where replace(dtinicioafastamento,'NULL','') is not null union
select sgorgao, lpad(trim(numatriculalegado),9,0) as numatriculalegado, lpad(trim(nucpf),11,0) as nucpf,
replace(trim(dtinicioafastamento),'NULL','') as dtinicio, replace(trim(dtfimafastamento),'NULL','') as dtfim, replace(trim(dtfimprevistoafastamento),'NULL','') as dtfimprevisto,
fltipoafastamento, demotivoafastamento, nmgrupomotivoafastamento, flremunerado, flremuneracaointegral, flacidentetrabalho, deobservacaoafastamento as deobservacao,  '4-REC' as origem
from sigrhmig.emigvinculorecebidocsv where replace(dtinicioafastamento,'NULL','') is not null union
select sgorgao, lpad(trim(numatriculalegado),9,0) as numatriculalegado, lpad(trim(nucpf),11,0) as nucpf,
replace(trim(dtinicioafastamento),'NULL','') as dtinicio, replace(trim(dtfimafastamento),'NULL','') as dtfim, replace(trim(dtfimprevistoafastamento),'NULL','') as dtfimprevisto,
fltipoafastamento, demotivoafastamento, nmgrupomotivoafastamento, flremunerado, flremuneracaointegral, flacidentetrabalho, deobservacaoafastamento as deobservacao,  '5-CED' as origem
from sigrhmig.emigvinculocedidocsv where replace(dtinicioafastamento,'NULL','') is not null union
select sgorgao, lpad(trim(numatriculalegado),9,0) as numatriculalegado, lpad(trim(nucpf),11,0) as nucpf,
replace(trim(dtinicioafastamento),'NULL','') as dtinicio, replace(trim(dtfimafastamento),'NULL','') as dtfim, replace(trim(dtfimprevisto),'NULL','') as dtfimprevisto,
fltipoafastamento, demotivoafastamento, nmgrupomotivoafastamento, flremunerado, flremuneracaointegral, flacidentetrabalho, deobservacao,  '6-PNP' as origem
from sigrhmig.emigvinculopensaonaoprevcsv where replace(dtinicioafastamento,'NULL','') is not null union
select distinct sgorgao, lpad(trim(numatriculalegado),9,0) as numatriculalegado, lpad(trim(nucpf),11,0) as nucpf,
case when replace(trim(dtinicioafastamento),'NULL','') is not null then substr(trim(dtinicioafastamento),9,2) || '/' || substr(trim(dtinicioafastamento),6,2)  || '/' || substr(trim(dtinicioafastamento),1,4) else null end as dtinicio,
case when replace(trim(dtfimafastamento),'NULL','') is not null then substr(trim(dtfimafastamento),9,2) || '/' || substr(trim(dtfimafastamento),6,2)  || '/' || substr(trim(dtfimafastamento),1,4) else null end as dtfim,
case when replace(trim(dtfimprevistoafastamento),'NULL','') is not null then substr(trim(dtfimprevistoafastamento),9,2) || '/' || substr(trim(dtfimprevistoafastamento),6,2)  || '/' || substr(trim(dtfimprevistoafastamento),1,4) else null end as dtfimprevisto,
fltipoafastamento, demotivoafastamento, nmgrupomotivoafastamento, flremunerado, flremuneracaointegral, flacidentetrabalho, deobservacao,  '9-PAG' as origem
from sigrhmig.emigcapapagamentocsv where replace(trim(dtinicioafastamento),'NULL','') is not null
) order by nucpf, numatriculalegado, dtinicio
;
/
