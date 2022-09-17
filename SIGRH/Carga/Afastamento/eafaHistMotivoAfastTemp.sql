declare cursor c1 is
select 'eafagrupomotivoafastamento' as Tab, 'SAFAGRUPOMOTIVOAFASTAMENTO' as Seq, nvl(max(cdgrupomotivoafastamento),0) as Qtde from eafagrupomotivoafastamento union
select 'eafamotivoafasttemporario'  as Tab, 'SAFAMOTIVOAFASTTEMPORARIO'  as Seq, nvl(max(cdmotivoafasttemporario),0)  as Qtde from eafamotivoafasttemporario  union
select 'eafahistmotivoafasttemp'    as Tab, 'SAFAHISTMOTIVOAFASTTEMP'    as Seq, nvl(max(cdhistmotivoafasttemp),0)    as Qtde from eafahistmotivoafasttemp
order by 1, 2;

begin
  for item in c1
    loop
      dbms_output.put_line('Tabname = ' || item.Tab || ' Sequence = ' || item.Seq || ' Qtde = ' || item.Qtde);
    
      execute immediate 'alter sequence ' || item.Seq || ' restart start with ' || case when item.Qtde = 0 then 1 else item.Qtde end;
      execute immediate 'analyze table ' || upper(item.Tab) || ' compute statistics';

    end loop;
end;


select
 afamotdef.cdmotivoafastdefinitivo as cdmotivoafastamento,
 afamotdefhist.cdhistmotivoafastdef as cdhistmotivoafastamento,
 a.sgagrupamento,
 upper('definitivo') as tpafastamento,
 afagrumot.nmgrupomotivoafastamento,
 afamotdefhist.demotivoafastdefinitivo,
 gmafag.degrupomotivoafastgeral,
 upper(tpafa.detipoafastamento) as detipoafastamento,
 upper(regprev.nmregimeprevidenciario) as nmregimeprevidenciario,
 upper(tpfunc.nmtipofuncionalidade) as nmtipofuncionalidade,
 afamotdefhist.dtiniciovigencia,
 afamotdefhist.dtfimvigencia,
 json_object(upper('definitivo') VALUE json_object(
   upper('flacidentetrabalho') value afamotdefhist.flacidentetrabalho,
   upper('flact') value afamotdefhist.flact,
   upper('flacumulacaocco') value afamotdefhist.flacumulacaocco,
   upper('flacumulacaocef') value afamotdefhist.flacumulacaocef,
   upper('flafastdefinitivo') value afamotdefhist.flafastdefinitivo,
   upper('flanulado') value afamotdefhist.flanulado,
   upper('flatolegal') value afamotdefhist.flatolegal,
   upper('flbolsista') value afamotdefhist.flbolsista,
   upper('flcancelareclusaocomp') value afamotdefhist.flcancelareclusaocomp,
   upper('flcancelareclusaoobito') value afamotdefhist.flcancelareclusaoobito,
   upper('flcessabeneficioreadaptacao') value afamotdefhist.flcessabeneficioreadaptacao,
   upper('flcomprovdepeconomica') value afamotdefhist.flcomprovdepeconomica,
   upper('fldescdiasnaotrab') value afamotdefhist.fldescdiasnaotrab,
   upper('fldevolucaoajudacusto') value afamotdefhist.fldevolucaoajudacusto,
   upper('flfinalizacaoact') value afamotdefhist.flfinalizacaoact,
   upper('flincompatibilidade') value afamotdefhist.flincompatibilidade,
   upper('fljustificativa') value afamotdefhist.fljustificativa,
   upper('flpensao') value afamotdefhist.flpensao,
   upper('flpensionista') value afamotdefhist.flpensionista,
   upper('flplanosaude') value afamotdefhist.flplanosaude,
   upper('flrecadastramento') value afamotdefhist.flrecadastramento,
   upper('flreclusao') value afamotdefhist.flreclusao,
   upper('flreintegracao') value afamotdefhist.flreintegracao,
   upper('flrelvincsecundaria') value afamotdefhist.flrelvincsecundaria,
   upper('flremuneracaointegral') value afamotdefhist.flremuneracaointegral,
   upper('flremunerado') value afamotdefhist.flremunerado,
   upper('flrestritogestor') value afamotdefhist.flrestritogestor,
   upper('flsubstituicao') value afamotdefhist.flsubstituicao,
   upper('fltempoadmdireta') value afamotdefhist.fltempoadmdireta,
   upper('fltempocargo') value afamotdefhist.fltempocargo,
   upper('fltempocarreira') value afamotdefhist.fltempocarreira,
   upper('fltempoemppublica') value afamotdefhist.fltempoemppublica,
   upper('fltempoficticio') value afamotdefhist.fltempoficticio,
   upper('fltempomagisterio') value afamotdefhist.fltempomagisterio,
   upper('fltempopolicial') value afamotdefhist.fltempopolicial,
   upper('fltemporisco') value afamotdefhist.fltemporisco,
   upper('fltemposaude') value afamotdefhist.fltemposaude,
   upper('fltipovinculacao') value afamotdefhist.fltipovinculacao,
   upper('flverifprocessojuddisc') value afamotdefhist.flverifprocessojuddisc)
 ) as parametros

from eafahistmotivoafastdef afamotdefhist
inner join eafamotivoafastdefinitivo afamotdef on afamotdef.cdmotivoafastdefinitivo = afamotdefhist.cdmotivoafastdefinitivo
inner join eafagrupomotivoafastamento afagrumot on afagrumot.cdgrupomotivoafastamento = afamotdefhist.cdgrupomotivoafastamento
inner join ecadagrupamento a on a.cdagrupamento = afagrumot.cdagrupamento
left join eafatipoafastamento tpafa on tpafa.cdtipoafastamento = afamotdef.cdtipoafastamento
left join ecadregimeprevidenciario regprev on regprev.cdregimeprevidenciario = afamotdefhist.cdregimeprevidenciario
left join eafatipofuncionalidade tpfunc on tpfunc.cdtipofuncionalidade = afamotdefhist.cdtipofuncionalidade

left join eafagrupomotivoafastgeral gmafag on gmafag.cdgrupomotivoafastgeral = afagrumot.cdgrupomotivoafastgeral

union

select
 afamottemp.cdmotivoafasttemporario as cdmotivoafastamento,
 afamottemphist.cdhistmotivoafasttemp as cdhistmotivoafastamento,
 a.sgagrupamento,
 upper('temporario') as tpafastamento,
 afagrumot.nmgrupomotivoafastamento,
 afamottemphist.demotivoafasttemporario,
 gmafag.degrupomotivoafastgeral,
 upper(tpafa.detipoafastamento) as detipoafastamento,
 regprev.nmregimeprevidenciario as nmregimeprevidenciario,
 upper(tpfunc.nmtipofuncionalidade) as nmtipofuncionalidade,
 afamottemphist.dtiniciovigencia,
 afamottemphist.dtfimvigencia,
 json_object(upper('temporario') VALUE json_object(
   upper('flabatediasvaletransp') value afamottemphist.flabatediasvaletransp,
   upper('flacidentetrabalho') value afamottemphist.flacidentetrabalho,
   upper('flafastparcialenturmacao') value afamottemphist.flafastparcialenturmacao,
   upper('flatestadomedico') value afamottemphist.flatestadomedico,
   upper('flatolegal') value afamottemphist.flatolegal,
   upper('flauxiliodoenca') value afamottemphist.flauxiliodoenca,
   upper('flauxilioreclusao') value afamottemphist.flauxilioreclusao,
   upper('flaverbaafastamento') value afamottemphist.flaverbaafastamento,
   upper('flcancelapedidovaletransp') value afamottemphist.flcancelapedidovaletransp,
   upper('flcargocomissao') value afamottemphist.flcargocomissao,
   upper('flcargoefetivo') value afamottemphist.flcargoefetivo,
   upper('flcessabeneficioreadaptacao') value afamottemphist.flcessabeneficioreadaptacao,
   upper('flchminimaaplicavel') value afamottemphist.flchminimaaplicavel,
   upper('flconfirmageracaosegafast') value afamottemphist.flconfirmageracaosegafast,
   upper('flconfirmaretorno') value afamottemphist.flconfirmaretorno,
   upper('fldatafim') value afamottemphist.fldatafim,
   upper('fldependente') value afamottemphist.fldependente,
   upper('fldependenteobrigatorio') value afamottemphist.fldependenteobrigatorio,
   upper('fldescdiasnaotrab') value afamottemphist.fldescdiasnaotrab,
   upper('fldescentralizado') value afamottemphist.fldescentralizado,
   upper('fldesconsiderarafastfrequencia') value afamottemphist.fldesconsiderarafastfrequencia,
   upper('fldescontahoraadicional') value afamottemphist.fldescontahoraadicional,
   upper('fldireitogratativespecial') value afamottemphist.fldireitogratativespecial,
   upper('fldireitoregenciaclasse') value afamottemphist.fldireitoregenciaclasse,
   upper('flestabilidadetemporaria') value afamottemphist.flestabilidadetemporaria,
   upper('flestagio') value afamottemphist.flestagio,
   upper('flexigedeclaracaobens') value afamottemphist.flexigedeclaracaobens,
   upper('flferias') value afamottemphist.flferias,
   upper('flfrequencia') value afamottemphist.flfrequencia,
   upper('flfuncaochefia') value afamottemphist.flfuncaochefia,
   upper('flgeraagregacao') value afamottemphist.flgeraagregacao,
   upper('flgravidez') value afamottemphist.flgravidez,
   upper('fljustificativa') value afamottemphist.fljustificativa,
   upper('fllicencapremio') value afamottemphist.fllicencapremio,
   upper('flmensagem') value afamottemphist.flmensagem,
   upper('flmotivoafastdef') value afamottemphist.flmotivoafastdef,
   upper('flmotivopremioassiduidade') value afamottemphist.flmotivopremioassiduidade,
   upper('flnaoestavel') value afamottemphist.flnaoestavel,
   upper('flnovoperiodoaqferias') value afamottemphist.flnovoperiodoaqferias,
   upper('flpartejornada') value afamottemphist.flpartejornada,
   upper('flperdelotacao') value afamottemphist.flperdelotacao,
   upper('flpermiteagendamentopericia') value afamottemphist.flpermiteagendamentopericia,
   upper('flpermiteaumentoch') value afamottemphist.flpermiteaumentoch,
   upper('flpermitehomologarprocessodig') value afamottemphist.flpermitehomologarprocessodig,
   upper('flpermitelancfuturo') value afamottemphist.flpermitelancfuturo,
   upper('flpermitepedidolpportal') value afamottemphist.flpermitepedidolpportal,
   upper('flpermiterecebimentodiaria') value afamottemphist.flpermiterecebimentodiaria,
   upper('flpermitereducaoch') value afamottemphist.flpermitereducaoch,
   upper('flpermiteunidadeorgandestino') value afamottemphist.flpermiteunidadeorgandestino,
   upper('flplanosaude') value afamottemphist.flplanosaude,
   upper('flprocessanaopaga') value afamottemphist.flprocessanaopaga,
   upper('flprocessoapo') value afamottemphist.flprocessoapo,
   upper('flprorrogacontrato') value afamottemphist.flprorrogacontrato,
   upper('flprorrogatransito') value afamottemphist.flprorrogatransito,
   upper('flreadaptacao') value afamottemphist.flreadaptacao,
   upper('flreativaautorizacao') value afamottemphist.flreativaautorizacao,
   upper('flremuneracaointegral') value afamottemphist.flremuneracaointegral,
   upper('flremunerado') value afamottemphist.flremunerado,
   upper('flrestricaoidade') value afamottemphist.flrestricaoidade,
   upper('flrestritogestor') value afamottemphist.flrestritogestor,
   upper('flretiraescala') value afamottemphist.flretiraescala,
   upper('flsolicitacao') value afamottemphist.flsolicitacao,
   upper('flsubstenturmacao') value afamottemphist.flsubstenturmacao,
   upper('flsubstituto') value afamottemphist.flsubstituto,
   upper('flsuspendeautorizacao') value afamottemphist.flsuspendeautorizacao,
   upper('fltempoadmdireta') value afamottemphist.fltempoadmdireta,
   upper('fltempocargo') value afamottemphist.fltempocargo,
   upper('fltempocarreira') value afamottemphist.fltempocarreira,
   upper('fltempoefetivo') value afamottemphist.fltempoefetivo,
   upper('fltempoemppublica') value afamottemphist.fltempoemppublica,
   upper('fltempoficticio') value afamottemphist.fltempoficticio,
   upper('fltempomagisterio') value afamottemphist.fltempomagisterio,
   upper('fltempopolicial') value afamottemphist.fltempopolicial,
   upper('fltemporisco') value afamottemphist.fltemporisco,
   upper('fltemposaude') value afamottemphist.fltemposaude,
   upper('fltipovinculacao') value afamottemphist.fltipovinculacao,
   upper('flultlancamento') value afamottemphist.flultlancamento)
 ) as parametros

from eafahistmotivoafasttemp afamottemphist
inner join eafamotivoafasttemporario afamottemp on afamottemp.cdmotivoafasttemporario = afamottemphist.cdmotivoafasttemporario
inner join eafagrupomotivoafastamento afagrumot on afagrumot.cdgrupomotivoafastamento = afamottemphist.cdgrupomotivoafastamento
inner join ecadagrupamento a on a.cdagrupamento = afagrumot.cdagrupamento
left join eafagrupomotivoafastgeral gmafag on gmafag.cdgrupomotivoafastgeral = afagrumot.cdgrupomotivoafastgeral
left join eafatipoafastamento tpafa on tpafa.cdtipoafastamento = afamottemp.cdtipoafastamento
left join ecadregimeprevidenciario regprev on regprev.cdregimeprevidenciario = afamottemphist.cdregimeprevidenciario
left join eafatipofuncionalidade tpfunc on tpfunc.cdtipofuncionalidade = afamottemphist.cdtipofuncionalidade

order by 3, 4, 5, 6
;


--insert into eafagrupomotivoafastamento
with
novo_grupo_motivo_afastamento as (
select
 sgagrupamento,
 'TEMPORARIO SEM REMUNERACAO - CALCULO PARALELO' as nmgrupomotivoafastamento,
 'LICENCA SEM VENCIMENTO' as degrupomotivoafastgeral,
 'N' as flmotivodoenca,
 'N' as flmotivofalta
from ecadagrupamento
where sgagrupamento = 'ADM-DIR'
order by sgagrupamento
),
existe as (
select
 a.sgagrupamento,
 gmafa.nmgrupomotivoafastamento,
 gmafag.degrupomotivoafastgeral,
 gmafa.nugrupomotivo
from eafagrupomotivoafastamento gmafa
inner join ecadagrupamento a on a.cdagrupamento = gmafa.cdagrupamento
left join eafagrupomotivoafastgeral gmafag on gmafag.cdgrupomotivoafastgeral = gmafa.cdgrupomotivoafastgeral
order by
 a.sgagrupamento,
 gmafa.nmgrupomotivoafastamento,
 gmafag.degrupomotivoafastgeral
)

select
(select nvl(max(cdgrupomotivoafastamento),0) from eafagrupomotivoafastamento) + rownum as cdgrupomotivoafastamento,
a.cdagrupamento as cdagrupamento,
gma.nmgrupomotivoafastamento as nmgrupomotivoafastamento,
null as dtlimitevigencia,
'11111111111' as nucpfcadastrador,
trunc(sysdate) as dtinclusao,
systimestamp as dtultalteracao,
gma.flmotivodoenca as flmotivodoenca,
(select nvl(max(nugrupomotivo),0) from eafagrupomotivoafastamento) + rownum as nugrupomotivo,
gma.flmotivofalta as flmotivofalta,
gmageral.cdgrupomotivoafastgeral as cdgrupomotivoafastgeral
from novo_grupo_motivo_afastamento gma
inner join ecadagrupamento a on a.sgagrupamento = gma.sgagrupamento
left join eafagrupomotivoafastgeral gmageral on gmageral.degrupomotivoafastgeral = gma.degrupomotivoafastgeral
left join existe on existe.sgagrupamento = gma.sgagrupamento
                and existe.nmgrupomotivoafastamento = gma.nmgrupomotivoafastamento
where existe.sgagrupamento is null
;

select
(select nvl(max(cdgrupomotivoafastamento),0) from eafagrupomotivoafastamento) + rownum as cdgrupomotivoafastamento,
a.cdagrupamento as cdagrupamento,
gma.nmgrupomotivoafastamento as nmgrupomotivoafastamento,
null as dtlimitevigencia,
'11111111111' as nucpfcadastrador,
trunc(sysdate) as dtinclusao,
systimestamp as dtultalteracao,
gma.flmotivodoenca as flmotivodoenca,
(select nvl(max(nugrupomotivo),0) from eafagrupomotivoafastamento) + rownum as nugrupomotivo,
gma.flmotivofalta as flmotivofalta,
gmageral.cdgrupomotivoafastgeral as cdgrupomotivoafastgeral
from novo_grupo_motivo_afastamento gma
inner join ecadagrupamento a on a.sgagrupamento = gma.sgagrupamento
left join eafagrupomotivoafastgeral gmageral on gmageral.degrupomotivoafastgeral = gma.degrupomotivoafastgeral
left join existe on existe.sgagrupamento = gma.sgagrupamento
                and existe.nmgrupomotivoafastamento = gma.nmgrupomotivoafastamento
where existe.sgagrupamento is null
;

--insert into eafamotivoafasttemporario
--insert into eafahistmotivoafasttemp
/*
insert all
into eafamotivoafasttemporario values(
cdmotivoafasttemporario,
cdagrupamento,
flgfip,
inmotivoesfinge,
cdsituacaofuncionalsirh,
cdtipoafastamento,
cdmotivoafastesocial
)

into eafahistmotivoafasttemp values(
cdhistmotivoafasttemp,
cdmotivoafasttemporario,
cdmotivooutroregime,
cdmotivogerado,
demotivoafasttemporario,
cdgrupomotivoafastamento,
dtiniciovigencia,
dtfimvigencia,
fldependente,
flatolegal,
fljustificativa,
flconfirmaretorno,
flacidentetrabalho,
flgravidez,
fltipovinculacao,
flrestritogestor,
flremunerado,
flremuneracaointegral,
cddocumento,
cdtipopublicacao,
dtpublicacao,
nupublicacao,
nupaginicial,
cdmeiopublicacao,
deoutromeio,
flmotivoafastdef,
flcargocomissao,
flauxilioreclusao,
flfuncaochefia,
flsubstituto,
flcargoefetivo,
flestagio,
flnaoestavel,
flreadaptacao,
cdregimeprevidenciario,
qtminlancamentoano,
qtminlancamentomes,
qtminlancamentodia,
qtmaxlancamentoano,
qtmaxlancamentomes,
qtmaxlancamentodia,
qtmaxperiodoano,
qtmaxperiodomes,
qtmaxperiododia,
nuperiodoverificacaoano,
nuperiodoverificacaomes,
nuperiodoverificacaodia,
flultlancamento,
qtmaxvinculoano,
qtmaxvinculomes,
qtmaxvinculodia,
flferias,
fllicencapremio,
flprorrogacontrato,
nutempoprorrogacao,
flprorrogatransito,
flatestadomedico,
flplanosaude,
flmensagem,
flsolicitacao,
flfrequencia,
flsuspendeautorizacao,
fltempoadmdireta,
fltempoemppublica,
fltempocargo,
fltempocarreira,
fltempoficticio,
fltempomagisterio,
fltempopolicial,
fltemporisco,
fltemposaude,
flabatediasvaletransp,
flcancelapedidovaletransp,
nucpfcadastrador,
dtinclusao,
flanulado,
dtanulado,
dtultalteracao,
cdtipofuncionalidade,
flretiraescala,
fldescontahoraadicional,
flauxiliodoenca,
nuprazodevajudacusto,
vlpercentajudacusto,
flafastparcialenturmacao,
flreativaautorizacao,
flmotivopremioassiduidade,
fldescdiasnaotrab,
fldireitoregenciaclasse,
fldireitogratativespecial,
cdhisttiposirh,
cdhisttipoespecsirh,
flpartejornada,
flaverbaafastamento,
flpermitelancfuturo,
nuperiodocarenciadia,
nuperiodocarenciames,
nuperiodocarenciaano,
fldatafim,
flrestricaoidade,
nuidaderestricao,
flprocessoapo,
vlpercentreducaoauxalim,
inmovimentacao,
flnovoperiodoaqferias,
flsubstenturmacao,
flestabilidadetemporaria,
flconfirmageracaosegafast,
flcessabeneficioreadaptacao,
flchminimaaplicavel,
nuchminimaaplicavel,
flpermiteaumentoch,
flprocessanaopaga,
flperdelotacao,
numesesparaperdalotacao,
fltempoefetivo,
numesesagregacao,
flgeraagregacao,
nudiascarenciatempoefetivo,
flpermiteunidadeorgandestino,
flpermiterecebimentodiaria,
fldesconsiderarafastfrequencia,
cdmotivoafastesocial,
fldescentralizado,
flpermitepedidolpportal,
fldependenteobrigatorio,
vlpercentreducaoiresa,
flpermitereducaoch,
cdtempoefeitocontagem,
flpermiteagendamentopericia,
flexigedeclaracaobens,
flpermitehomologarprocessodig
)
*/

with novo_motivo_afastamento_temporario as (
select
sgagrupamento,
'PARALELO DA FOLHA SEM REMUNERACAO' as demotivoafasttemporario,
'TEMPORARIO SEM REMUNERACAO - CALCULO PARALELO' as nmgrupomotivoafastamento
from ecadagrupamento
where sgagrupamento = 'ADM-DIR'
order by sgagrupamento
),
existe as (
select
 a.sgagrupamento,
 afagrumot.nmgrupomotivoafastamento,
 afamottemphist.demotivoafasttemporario
from eafahistmotivoafasttemp afamottemphist
inner join eafamotivoafasttemporario afamottemp on afamottemp.cdmotivoafasttemporario = afamottemphist.cdmotivoafasttemporario
inner join eafagrupomotivoafastamento afagrumot on afagrumot.cdgrupomotivoafastamento = afamottemphist.cdgrupomotivoafastamento
inner join ecadagrupamento a on a.cdagrupamento = afagrumot.cdagrupamento
)

select
(select nvl(max(cdmotivoafasttemporario),0) from eafamotivoafasttemporario) + rownum as cdmotivoafasttemporario,
a.cdagrupamento as cdagrupamento,
'S' as flgfip,
null as inmotivoesfinge,
null as cdsituacaofuncionalsirh,
null as cdtipoafastamento,
null as cdmotivoafastesocial,

(select nvl(max(cdhistmotivoafasttemp),0) from eafahistmotivoafasttemp) + rownum as cdhistmotivoafasttemp,
null as cdmotivooutroregime,
null as cdmotivogerado,
afatemp.demotivoafasttemporario as demotivoafasttemporario,
gruafa.cdgrupomotivoafastamento as cdgrupomotivoafastamento,
to_date('01/01/1901','DD/MM/YYYY') as dtiniciovigencia,
null as dtfimvigencia,
'N' as fldependente,
'N' as flatolegal,
'N' as fljustificativa,
'N' as flconfirmaretorno,
'N' as flacidentetrabalho,
'N' as flgravidez,
'V' as fltipovinculacao,
'N' as flrestritogestor,
'N' as flremunerado,
'N' as flremuneracaointegral,
null as cddocumento,
null as cdtipopublicacao,
null as dtpublicacao,
null as nupublicacao,
null as nupaginicial,
null as cdmeiopublicacao,
null as deoutromeio,
'S' as flmotivoafastdef,
'S' as flcargocomissao,
'N' as flauxilioreclusao,
'N' as flfuncaochefia,
'N' as flsubstituto,
'S' as flcargoefetivo,
'N' as flestagio,
'N' as flnaoestavel,
'N' as flreadaptacao,
null as cdregimeprevidenciario,
null as qtminlancamentoano,
null as qtminlancamentomes,
null as qtminlancamentodia,
null as qtmaxlancamentoano,
null as qtmaxlancamentomes,
null as qtmaxlancamentodia,
null as qtmaxperiodoano,
null as qtmaxperiodomes,
null as qtmaxperiododia,
null as nuperiodoverificacaoano,
null as nuperiodoverificacaomes,
null as nuperiodoverificacaodia,
'N' as flultlancamento,
null as qtmaxvinculoano,
null as qtmaxvinculomes,
null as qtmaxvinculodia,
'N' as flferias,
'N' as fllicencapremio,
'N' as flprorrogacontrato,
null as nutempoprorrogacao,
'N' as flprorrogatransito,
'N' as flatestadomedico,
'N' as flplanosaude,
'N' as flmensagem,
'S' as flsolicitacao,
'S' as flfrequencia,
'S' as flsuspendeautorizacao,
'S' as fltempoadmdireta,
'S' as fltempoemppublica,
'S' as fltempocargo,
'S' as fltempocarreira,
'S' as fltempoficticio,
'S' as fltempomagisterio,
'S' as fltempopolicial,
'S' as fltemporisco,
'S' as fltemposaude,
'S' as flabatediasvaletransp,
'S' as flcancelapedidovaletransp,
null as cdtipofuncionalidade,
'N' as flretiraescala,
'N' as fldescontahoraadicional,
'N' as flauxiliodoenca,
null as nuprazodevajudacusto,
null as vlpercentajudacusto,
'N' as flafastparcialenturmacao,
'N' as flreativaautorizacao,
'N' as flmotivopremioassiduidade,
'N' as fldescdiasnaotrab,
'N' as fldireitoregenciaclasse,
'N' as fldireitogratativespecial,
null as cdhisttiposirh,
null as cdhisttipoespecsirh,
'N' as flpartejornada,
'N' as flaverbaafastamento,
'S' as flpermitelancfuturo,
null as nuperiodocarenciadia,
null as nuperiodocarenciames,
null as nuperiodocarenciaano,
'N' as fldatafim,
'N' as flrestricaoidade,
null as nuidaderestricao,
'N' as flprocessoapo,
null as vlpercentreducaoauxalim,
null as inmovimentacao,
'N' as flnovoperiodoaqferias,
'N' as flsubstenturmacao,
'N' as flestabilidadetemporaria,
'N' as flconfirmageracaosegafast,
'N' as flcessabeneficioreadaptacao,
'N' as flchminimaaplicavel,
null as nuchminimaaplicavel,
'N' as flpermiteaumentoch,
'N' as flprocessanaopaga,
'N' as flperdelotacao,
null as numesesparaperdalotacao,
'N' as fltempoefetivo,
null as numesesagregacao,
'N' as flgeraagregacao,
'0' as nudiascarenciatempoefetivo,
'N' as flpermiteunidadeorgandestino,
'N' as flpermiterecebimentodiaria,
'N' as fldesconsiderarafastfrequencia,
'N' as fldescentralizado,
'S' as flpermitepedidolpportal,
'N' as fldependenteobrigatorio,
'0' as vlpercentreducaoiresa,
'N' as flpermitereducaoch,
null as cdtempoefeitocontagem,
'S' as flpermiteagendamentopericia,
'N' as flexigedeclaracaobens,
'N' as flpermitehomologarprocessodig,

'11111111111' as nucpfcadastrador,
trunc(sysdate) as dtinclusao,
'N' as flanulado,
null as dtanulado,
systimestamp as dtultalteracao

from novo_motivo_afastamento_temporario afatemp
inner join ecadagrupamento a on a.sgagrupamento = afatemp.sgagrupamento
inner join eafagrupomotivoafastamento gruafa on gruafa.nmgrupomotivoafastamento = afatemp.nmgrupomotivoafastamento
                                            and gruafa.cdagrupamento = a.cdagrupamento
left join existe on existe.sgagrupamento = afatemp.sgagrupamento
                and existe.demotivoafasttemporario = afatemp.demotivoafasttemporario
                and existe.nmgrupomotivoafastamento = afatemp.nmgrupomotivoafastamento
where existe.sgagrupamento is null
;