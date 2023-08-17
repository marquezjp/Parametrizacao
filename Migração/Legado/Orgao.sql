--- Formata Layout do Arquivo de Migracao Orgao
with
lotacoes as (
select CdLotacao, Sigla, NmLotacao from RH_GOV.dbo.TLotacoes t union
select CdLotacao, Sigla, NmLotacao from RH_PM.dbo.TLotacoes t union
select CdLotacao, Sigla, NmLotacao from RH_BM.dbo.TLotacoes t where Sigla is not null union
select CdLotacao, Sigla, NmLotacao from RH_CER.dbo.TLotacoes t union
select CdLotacao, Sigla, NmLotacao from RH_ITE.dbo.TLotacoes t union
select CdLotacao, Sigla, NmLotacao from RH_RADIO.dbo.TLotacoes t
),
depara as (
select upper(trim(de)) as de, upper(trim(para)) as para
from OpenJson('{"depara":[
{"de":"CASACIVIL", "para":"CASA CIVIL"}, {"de":"CERIM", "para":"CASA CIVIL"}, {"de":"COGERR", "para":"COGER"}, {"de":"CONANTD", "para":"SEJUC"}, {"de":"CONCULT", "para":"SECULT"},
{"de":"CONEDUC", "para":"SEED"}, {"de":"CONPEN", "para":"SEJUC"}, {"de":"CONREFIS", "para":"SEFAZ"}, {"de":"CONRODE", "para":"SEINF"}, {"de":"CSAMILITAR", "para":"CASA MILITAR"}, {"de":"IPEM", "para":"IPEM-RR"},
{"de":"OGERR", "para":"OGE-RR"}, {"de":"PENSIONIST", "para":"SEGAD"}, {"de":"POLCIVIL", "para":"PC-RR"}, {"de":"PROGE", "para":"PGE-RR"}, {"de":"VICE GOV", "para":"VICE-GOV"}, {"de":"CASAMILITAR", "para":"CASA MILITAR"},
{"de":"CERR", "para":"CER"}, {"de":"CGERR", "para":"COGER"}, {"de":"CM", "para":"CBM-RR"}, {"de":"CBM", "para":"CBM-RR"}, {"de":"CBM AD RV", "para":"CBM-RR"}, {"de":"CBMRR", "para":"CBM-RR"},
{"de":"DEFPUB", "para":"DPE-RR"}, {"de":"PM", "para":"PM-RR"}, {"de":"UNIVIR", "para":"UNIVIRR"}, {"de":"SEURB", "para":"SEURB-RR"}, {"de":"PRODEB", "para":"SEED"}, {"de":"IDEFER", "para":"IDEFER-RR"},
{"de":"PLANTONIST", "para":"SESAU"}, {"de":"SEEPE", "para":"SEPE"}, {"de":"C.E.M.A.I", "para":"PM-RR"}, {"de":"CON SEJURR", "para":"SEJUC"}, {"de":"CON TRANS", "para":"SEINF"}, {"de":"INA/PENS", "para":"PM-RR"},
{"de":"CVPMBMI", "para":"PM-RR"}, {"de":"CEIB", "para":"CBM-RR"}, {"de":"CONJUCERR", "para":"JUCERR"}, {"de":"BM", "para":"CBM-RR"}, {"de":"CETI", "para":"SEFAZ"}, {"de":"AFASTADOS", "para":"CER"},
{"de":"CON EDU", "para":"SEED"}, {"de":"PMRR", "para":"PM-RR"}, {"de":"BMRR", "para":"CBM-RR"}, {"de":"SELC", "para":"CPL"}, {"de":"C.E.M.A.I.", "para":"PM-RR"}, {"de":"POL MIL ES", "para":"PM-RR"},
{"de":"PENS UNI", "para":"PM-RR"}, {"de":"POL MIL UN", "para":"PM-RR"}, {"de":"INAT UNI", "para":"PM-RR"}, {"de":"OUVGE", "para":"OGE-RR"}, {"de":"SEAMPU", "para":"CER"}
]}', '$.depara') with (de varchar(200), para varchar(200))
),
orgaos as (
select upper(trim(sgag)) as sgagrupamento, upper(trim(sgorgao)) as sgorgao
from OpenJson('{"orgaos":[
{"sgag":"ADM-DIR", "sgorgao":"GOVERNADOR"}, 
{"sgag":"ADM-DIR", "sgorgao":"VICE-GOV"}, {"sgag":"ADM-DIR", "sgorgao":"SEFAZ"}, {"sgag":"ADM-DIR", "sgorgao":"SESAU"}, {"sgag":"ADM-DIR", "sgorgao":"SESP"}, {"sgag":"ADM-DIR", "sgorgao":"SETRABES"}, {"sgag":"ADM-DIR", "sgorgao":"PGE-RR"},
{"sgag":"ADM-DIR", "sgorgao":"DPE-RR"}, {"sgag":"ADM-DIR", "sgorgao":"SEDE"}, {"sgag":"ADM-DIR", "sgorgao":"SEERI"}, {"sgag":"ADM-DIR", "sgorgao":"CASA CIVIL"}, {"sgag":"ADM-DIR", "sgorgao":"CASA MILITAR"}, {"sgag":"ADM-DIR", "sgorgao":"COGER"},
{"sgag":"ADM-DIR", "sgorgao":"CPL"}, {"sgag":"ADM-DIR", "sgorgao":"OGE-RR"}, {"sgag":"ADM-DIR", "sgorgao":"PC-RR"}, {"sgag":"ADM-DIR", "sgorgao":"SEAPA"}, {"sgag":"ADM-DIR", "sgorgao":"SEGAD"}, {"sgag":"ADM-DIR", "sgorgao":"SEI"},
{"sgag":"ADM-DIR", "sgorgao":"SEINF"}, {"sgag":"ADM-DIR", "sgorgao":"SEJUC"}, {"sgag":"ADM-DIR", "sgorgao":"SERI"}, {"sgag":"ADM-DIR", "sgorgao":"SETI"}, {"sgag":"ADM-DIR", "sgorgao":"SEPE"}, {"sgag":"ADM-DIR", "sgorgao":"SEAI"},
{"sgag":"ADM-DIR", "sgorgao":"SEPHD"}, {"sgag":"ADM-DIR", "sgorgao":"SEAE"}, {"sgag":"ADM-DIR", "sgorgao":"SEURB-RR"}, {"sgag":"ADM-DIR", "sgorgao":"SECOM"}, {"sgag":"ADM-DIR", "sgorgao":"SEAPI"}, {"sgag":"ADM-DIR", "sgorgao":"SEAGI"},
{"sgag":"ADM-DIR", "sgorgao":"SEPES"}, {"sgag":"ADM-DIR", "sgorgao":"SERBRAS"}, {"sgag":"ADM-DIR", "sgorgao":"SEED"}, {"sgag":"ADM-DIR", "sgorgao":"SEPAQ"}, {"sgag":"ADM-DIR", "sgorgao":"SEPM"}, {"sgag":"ADM-DIR", "sgorgao":"SEPIN"},
{"sgag":"ADM-DIR", "sgorgao":"SEEGI"}, {"sgag":"ADM-DIR", "sgorgao":"SEGABI"}, {"sgag":"ADM-DIR", "sgorgao":"SEEPI"}, {"sgag":"ADM-DIR", "sgorgao":"SEEDIS"}, {"sgag":"ADM-DIR", "sgorgao":"SEEGD"}, {"sgag":"ADM-DIR", "sgorgao":"SEERF"},
{"sgag":"ADM-DIR", "sgorgao":"SECIDADES"}, {"sgag":"ADM-DIR", "sgorgao":"SECULT"}, {"sgag":"ADM-DIR", "sgorgao":"SEPLAN"}, {"sgag":"ADM-DIR", "sgorgao":"SEADI"}, {"sgag":"ADM-DIR", "sgorgao":"SEEAI"}, {"sgag":"ADM-DIR", "sgorgao":"SEEDHS"},
{"sgag":"IND-ADERR", "sgorgao":"ADERR"}, {"sgag":"IND-AFERR", "sgorgao":"AFERR"}, {"sgag":"IND-CAER", "sgorgao":"CAER"} , {"sgag":"IND-CER", "sgorgao":"CER"}, {"sgag":"IND-CODESAIM", "sgorgao":"CODESAIMA"}, {"sgag":"IND-DER", "sgorgao":"DER"},
{"sgag":"IND-DESENVOL", "sgorgao":"DESENVOLVE-RR"}, {"sgag":"IND-DETRAN", "sgorgao":"DETRAN-RR"}, {"sgag":"IND-FAPERR", "sgorgao":"FAPERR"}, {"sgag":"IND-FEMARH", "sgorgao":"FEMARH"}, {"sgag":"IND-IACTI", "sgorgao":"IACTI-RR"},
{"sgag":"IND-IATER", "sgorgao":"IATER"}, {"sgag":"IND-IDEFER", "sgorgao":"IDEFER-RR"}, {"sgag":"IND-IERR", "sgorgao":"IERR"}, {"sgag":"IND-IPEM", "sgorgao":"IPEM-RR"}, {"sgag":"IND-IPER", "sgorgao":"IPER"}, {"sgag":"IND-ITERAIMA", "sgorgao":"ITERAIMA"},
{"sgag":"IND-JUCERR", "sgorgao":"JUCERR"}, {"sgag":"IND-RADIO", "sgorgao":"RADIORAIMA"}, {"sgag":"IND-UERR", "sgorgao":"UERR"}, {"sgag":"IND-UNIVIRR", "sgorgao":"UNIVIRR"},
{"sgag":"MILITAR", "sgorgao":"CBM-RR"}, {"sgag":"MILITAR", "sgorgao":"PM-RR"}
]}', '$.orgaos') with (sgag varchar(200), sgorgao varchar(200))
)
--- Formata Layout do Arquivo de Migracao Orgao
select
-- Identificacao do Orgao
'PE' as sgPoder,
null as nmPoder,
o.sgagrupamento as sgAgrupamento,
null as nmAgrupamento,
case when depara.de is null then upper(trim(lot.Sigla)) else depara.para end as sgOrgao,
upper(trim(lot.Sigla)) as sgOrgaoOriginal,
upper(trim(lot.NmLotacao)) as nmOrgao,
trim(lot.CdLotacao) as cdOrgao,
-- Informacoes Principais do Orgao
null as dtInicioVigencia,
null as dtFimVigencia,
null as nuCNPJ,
null as nuCNPJFonterenda,
null as nuInscEstadual,
null as nuInscricaoMunic,
case o.sgagrupamento
  when 'ADM-DIR'  then 'ADMINISTRAÇÃO DIRETA'
  when 'MILITAR'  then 'ADMINISTRAÇÃO DIRETA'
  when 'RH_BM'    then 'ADMINISTRAÇÃO DIRETA'
  else 'ADMINISTRAÇÃO INDIRETA'
end as nmTipoOrgao,
case o.sgagrupamento
  when 'ADM-DIR'  then 'ADMINISTRAÇÃO DIRETA'
  when 'MILITAR'  then 'ADMINISTRAÇÃO DIRETA'
  when 'RH_BM'    then 'ADMINISTRAÇÃO DIRETA'
  else 'ADMINISTRAÇÃO INDIRETA'
end as cdNaturezaJuridicarais,
-- Endereço do Orgao
null as nuCEP,
null as nmTipoLogradouro,
null as nmLogradouro,
null as nunNumero,
null as deComplemento,
null as nmUnidade,
null as nucaixapostal,
null as nmBairro,
null as nmLocalidade,
null as sgEstado,
-- Telefones do Orgao
null as nuDDD,
null as nuTelefone,
null as nuRamal,
null as nuDDDFax,
null as nuFax,
null as nuRamalFax,
-- Parametros do Orgao
case when o.sgagrupamento = 'MILITAR' then 'S' else 'N' end as flMilitar,
'N' as flgestor,
'N' as flinerenteeducacao
from lotacoes lot
left join depara on depara.de = upper(trim(lot.Sigla))
left join orgaos o on o.sgorgao = isnull(depara.para, upper(trim(lot.Sigla)))
;
/
