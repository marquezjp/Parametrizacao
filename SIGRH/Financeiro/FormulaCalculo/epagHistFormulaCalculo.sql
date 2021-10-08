select
 ag.sgagrupamento as Agrupamento,
 nvl2(fcalc.cdorgao, o.sgorgao, 'AGRUPAMENTO') as Orgao,
 lpad(rub.cdtiporubrica,2,0) || '-' || lpad(rub.nurubrica,4,0) as Rubrica,
 vfcalc.nuformulaversao as Versao,
 hfcalc.nuanoinicio || lpad(hfcalc.numesinicio,2,0) as AnoMesInicio,
 hfcalc.nuanofim || lpad(hfcalc.numesfim,2,0) as AnoMesFim,
 rub.derubricaagrupamento as DescricaoRubrica,
 fcalc.sgformulacalculo as SiglaFormulaCalculo,
 fcalc.deformulacalculo as DescricaoFormulaCalculo,

 expfcalc.flexpgeral,
 expfcalc.nuformulaespecifica,
 expfcalc.deexpressao,
 expfcalc.deformulaespecifica,
 expfcalc.deformulaexpressao,
 expfcalc.deindiceexpressao,

 expfcalc.fldesprezapropchorubrica,
 expfcalc.flexigeindice,
 expfcalc.flvalorhoraminuto,
 
 vrliminfparcial.sgvalorreferencia,
 expfcalc.nuqtdeliminfparcial,

 vrliminffinal.sgvalorreferencia,
 expfcalc.nuqtdelimiteinffinal,

 vrlimsupparcial.sgvalorreferencia,
 expfcalc.nuqtdelimitesupparcial,

 vrlimsupfinal.sgvalorreferencia,
 expfcalc.nuqtdelimitesupfinal,

 expfcalc.vlindiceliminferiormensal,
 expfcalc.vlindicelimsuperiormensal,
 expfcalc.vlindicelimsuperiorsemestral,
 expfcalc.vlindicelimsuperioranual,
 
 expfcalc.cdexpressaoformcalc
 
from epagexpressaoformcalc expfcalc
left join epaghistformulacalculo hfcalc on hfcalc.cdhistformulacalculo = expfcalc.cdhistformulacalculo
left join epagformulaversao vfcalc on vfcalc.cdformulaversao = hfcalc.cdformulaversao
left join epagformulacalculo fcalc on fcalc.cdformulacalculo = vfcalc.cdformulacalculo
left join ecadagrupamento ag on ag.cdagrupamento = fcalc.cdagrupamento
left join vpagrubricaagrupamento rub on rub.cdrubricaagrupamento = fcalc.cdrubricaagrupamento
left join vcadorgao o on o.cdorgao = fcalc.cdorgao

--- Dominio ---
left join epagvalorreferencia vrliminfparcial on vrliminfparcial.cdvalorreferencia = expfcalc.cdvalorrefliminfparcial
left join epagvalorreferencia vrliminffinal on vrliminffinal.cdvalorreferencia = expfcalc.cdvalorrefliminffinal
left join epagvalorreferencia vrlimsupparcial on vrlimsupparcial.cdvalorreferencia = expfcalc.cdvalorreflimsupparcial
left join epagvalorreferencia vrlimsupfinal on vrlimsupfinal.cdvalorreferencia = expfcalc.cdvalorreflimsupfinal
