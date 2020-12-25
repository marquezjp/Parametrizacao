SELECT
	PAGA16.DtCalculo FolhaPagamento_DtCalculo,
	PAGA16.DtUltimoProcessamento FolhaPagamento_DtUltimoProces,
	CASE PAGA16.FlCalculoDefinitivo WHEN 'S' THEN 'Sim' ELSE 'Não' END AS folhadefinitiva,
	NVL(FORMULA.FLVALORHORAMINUTO, 'N') AS FLVALORHORAMINUTO, 
    PAGA16.CdFolhaPagamento FolhaPagamento_CdFolhaPagamen, 
    CASE WHEN PAGA26.NuTipoRubrica IN (1,2,3,4,10,12) THEN 0 
         WHEN PAGA26.NuTipoRubrica IN (5,6,7,8,11,13) THEN 1 ELSE 3 END AS ordem, 
    CASE WHEN PAGA26.NuTipoRubrica IN (1,2,3,4,10,12) THEN 'P' 
         WHEN PAGA26.NuTipoRubrica IN (5,6,7,8,11,13) THEN 'D' ELSE 'T' END AS detiporubrica, 
    (LPAD(PAGA26.NuTipoRubrica,2,'0') || '-' ||
	 LPAD(PAGA29.NuRubrica,4,'0') || '-' ||
	 LPAD(PAGA20.NuSufixoRubrica,2,'0')  || '  ' ||
		(SELECT CASE TR.FlTipoAdjacente
		             WHEN 'S' THEN 
					     CASE WHEN TRA.DeTipoRubricaAgrup IS NULL THEN TR.DeTipoRubrica || ' ' || B.DeRubricaAgrupamento 
							  ELSE TRA.DeTipoRubricaAgrup || ' ' || B.DeRubricaAgrupamento
					     END 
					 ELSE B.DeRubricaAgrupamento
				END
		   FROM EPAGHISTRUBRICAAGRUPAMENTO B
		   INNER JOIN EPAGRUBRICAAGRUPAMENTO RA ON B.CdRubricaAgrupamento = RA.CdRubricaAgrupamento 
		   INNER JOIN EPAGRUBRICA R ON RA.CdRubrica = R.CdRubrica 
		   INNER JOIN EPAGTIPORUBRICA TR ON R.CdTipoRubrica = TR.CdTipoRubrica 
		   INNER JOIN EPAGTIPORUBRICAAGRUP TRA
				   ON TR.CdTipoRubrica = TRA.CdTipoRubrica
				  AND TRA.CdAgrupamento = RA.CdAgrupamento
		   WHERE B.CdRubricaAgrupamento = PAGA20.CdRubricaAgrupamento 
			 AND TO_DATE(B.NuAnoInicioVigencia || B.NuMesInicioVigencia,'YYYYMM') =
			 (SELECT MAX(TO_DATE(B1.NuAnoInicioVigencia || B1.NuMesInicioVigencia,'YYYYMM')) 
				FROM EPAGHISTRUBRICAAGRUPAMENTO B1 
				WHERE B1.CdRubricaAgrupamento = B.CdRubricaAgrupamento)
		)
	) AS Rubrica, 
	PAG219.SgTipoOrigemRubrica || '-' || PAG219.DeTipoOrigemRubrica TipoOrigemRubrica, PAGA34.CdModalidadeRubrica AS CdModalidadeRubrica,   
    (CASE WHEN PAGA20.VlIndiceRubrica IS NOT NULL AND PAGA20.VlIndiceRubrica <> 0 THEN 
		CASE WHEN PAGA20.CdTipoIndice = 3 THEN 
			CASE WHEN CADAA3.NuAnoMesImplantacao IS NOT NULL
			      AND CADAA3.NuAnoMesImplantacao > (TRIM(PAGA16.NuAnoReferencia) || TRIM(LPAD(PAGA16.NuMesReferencia, 2, '0')))
					THEN 
					SUBSTR(LPAD(TO_CHAR(PAGA20.VlIndiceRubrica * 100),GREATEST(4, LENGTH(PAGA20.VlIndiceRubrica * 100)),'0'),1,LENGTH(LPAD(TO_CHAR(PAGA20.VlIndiceRubrica * 100),GREATEST(4, LENGTH(PAGA20.VlIndiceRubrica * 100)),'0')) - 2) || ':' || 
					SUBSTR(LPAD(TO_CHAR(PAGA20.VlIndiceRubrica * 100),GREATEST(4, LENGTH(PAGA20.VlIndiceRubrica * 100)),'0'),LENGTH(LPAD(TO_CHAR(PAGA20.VlIndiceRubrica * 100),GREATEST(4, LENGTH(PAGA20.VlIndiceRubrica * 100)),'0')) - 1)  
				ELSE SUBSTR(LPAD(TO_CHAR(PAGA20.VlIndiceRubrica),GREATEST(4, LENGTH(PAGA20.VlIndiceRubrica)),'0'),1,LENGTH(LPAD(TO_CHAR(PAGA20.VlIndiceRubrica),GREATEST(4, LENGTH(PAGA20.VlIndiceRubrica)),'0')) - 2) || ':' ||
				 SUBSTR(LPAD(TO_CHAR(PAGA20.VlIndiceRubrica),GREATEST(4, LENGTH(PAGA20.VlIndiceRubrica)),'0'),LENGTH(LPAD(TO_CHAR(PAGA20.VlIndiceRubrica),GREATEST(4, LENGTH(PAGA20.VlIndiceRubrica)),'0')) - 1) 
			END 
			WHEN PAGA20.CdTipoIndice = 4 AND PAGA26.NuTipoRubrica <> 8 THEN TO_CHAR(PAGA20.VlIndiceRubrica) || ' dia(s)' 
			WHEN PAGA20.CdTipoIndice = 10 THEN TO_CHAR(PAGA20.VlIndiceRubrica) || ' mes(es)' 
			WHEN PAGA20.CdTipoIndice = 11 THEN TO_CHAR(PAGA20.VlIndiceRubrica) || ' ano(s)'  
			WHEN PAGA20.CdTipoIndice IN (2, 7, 8) THEN TO_CHAR(PAGA20.VlIndiceRubrica) || '%' 
			ELSE TO_CHAR(PAGA20.VlIndiceRubrica) 
		END
	END) AS HistRubrVinc_VlIndiceRubrica,
    (CASE WHEN (PAGA20.DeExpressao IS NOT NULL
	        OR EXISTS (SELECT 1 
					     FROM EPAGHISTORICORUBRICARELVINC PAGA65 
					    WHERE PAGA65.CdRubricaAgrupamento = PAGA20.CdRubricaAgrupamento 
						  AND PAGA65.NuSufixoRubrica = PAGA20.NuSufixoRubrica 
						  AND PAGA65.CdFolhaPagamento = PAGA20.CdFolhaPagamento 
						  AND PAGA65.CdVinculo = PAGA20.CdVinculo 
						  AND PAGA65.DeExpressao IS NOT NULL))
				THEN 'F' ELSE NULL
	END) AS FORMULA,
    (SELECT COUNT(1)
	   FROM EPAGPERIODOACT PAC
	  WHERE PAC.CDVINCULO = PAGA20.CdVinculo
	    AND PAC.NUANOMESREFERENCIA = PAGA16.NuAnoMesReferencia
	) AS TEMPERIODOACT,
	PAGA20.CdRubricaAgrupamento AS CdRubricaAgrupamento, 
	PAGA20.CdVinculo AS CdVinculo, 
	PAGA20.NuSufixoRubrica AS NuSufixo, 
	PAGA20.CdHistoricoRubricaVinculo AS CdHistoricoRubricaVinculo, 
	PAGA20.DtUltAlteracao AS DtUltAlteracao,
	CASE WHEN PAGA20.QtParcelas IS NOT NULL THEN PAGA20.NUPARCELA || '/' || PAGA20.QtParcelas
	     ELSE ''
	END AS Parcela,
	CADAA3.CDORGAO,
	CADAA3.NMORGAO,
	FFormataNumero(PAGA20.VlPagamento,2) AS HistRubrVinc_VlPagamento

  FROM EPAGHISTORICORUBRICAVINCULO PAGA20
	INNER JOIN ECADVINCULO CADA39 ON PAGA20.CdVinculo = CADA39.CdVinculo  
	INNER JOIN EPAGRUBRICAAGRUPAMENTO PAGA34 ON PAGA20.CdRubricaAgrupamento = PAGA34.CdRubricaAgrupamento 
	INNER JOIN EPAGRUBRICA PAGA29 ON PAGA34.CdRubrica = PAGA29.CdRubrica 
	INNER JOIN EPAGTIPORUBRICA PAGA26 ON PAGA29.CdTipoRubrica = PAGA26.CdTipoRubrica 
	INNER JOIN EPAGFOLHAPAGAMENTO PAGA16 ON PAGA20.CdFolhaPagamento = PAGA16.CdFolhaPagamento 
	LEFT  JOIN EPAGLANCAMENTOFINANCEIRO PAGA64 ON PAGA20.CdLancamentoFinanceiro = PAGA64.CdLancamentoFinanceiro 
	LEFT  JOIN EPAGBASECONSIGNACAO PAG149 ON PAGA20.CdBaseConsignacao = PAG149.CdBaseConsignacao 
	LEFT  JOIN EPAGTIPOORIGEMRUBRICA PAG219 ON PAGA20.CdTipoOrigemRubrica = PAG219.CdTipoOrigemRubrica 
	INNER JOIN VCADORGAO CADAA3 ON CADAA3.CdOrgao = PAGA16.CdOrgao
	LEFT  JOIN (SELECT DISTINCT PAGA88.CdRubricaAgrupamento, 
							   PAG115.FlValorHoraMinuto, 
							   PAG116.NuMesInicio, 
							   PAG116.NuMesFim, 
							   PAG116.NuAnoInicio, 
							   PAG116.NuAnoFim 
			     FROM EPAGEXPRESSAOFORMCALC PAG115 
				 INNER JOIN EPAGHISTFORMULACALCULO PAG116 ON PAG115.CdHistFormulaCalculo = PAG116.CdHistFormulaCalculo 
				 INNER JOIN EPAGFORMULAVERSAO PAG112 ON PAG116.CdFormulaVersao = PAG112.CdFormulaVersao AND PAG112.NuFormulaVersao = 1  
				 INNER JOIN EPAGFORMULACALCULO PAGA88
				         ON PAG112.CdFormulaCalculo = PAGA88.CdFormulaCalculo
						AND PAGA88.CdOrgao IS NULL
				) FORMULA
		    ON PAGA20.CdRubricaAgrupamento = FORMULA.CDRUBRICAAGRUPAMENTO
		   AND FORMULA.NUANOINICIO || LPAD(FORMULA.NUMESINICIO, 2, 0) <= (PAGA16.NuAnoReferencia || LPAD(PAGA16.NuMesReferencia, 2, 0))
		   AND (FORMULA.NUANOFIM || LPAD(FORMULA.NUMESFIM, 2, 0) >= (PAGA16.NuAnoReferencia || LPAD(PAGA16.NuMesReferencia, 2, 0))
			    OR FORMULA.NUANOFIM IS NULL)
 WHERE PAGA16.NuMesReferencia = &FolhaPagamento_NuMesReferenci 
   AND PAGA16.NuAnoReferencia = &FolhaPagamento_NuAnoReferenci 
   AND PAGA16.CdTipoFolhaPagamento = &FolhaPagamento_CdTipoFolhPaga 
   AND (PAGA16.CdTipoCalculo = &FolhaPagamento_CdTipoCalculo OR PAGA16.CdTipoCalculo IS NULL)  
   AND PAGA16.NuSequencialFolha = &FolhaPagamento_NuSequencFolha 
   AND PAGA20.CdVinculo = &HistRubrVinc_CdVinculo

 ORDER BY 6, LPAD(PAGA26.NuTipoRubrica,2,'0') || '-' || LPAD(PAGA29.NuRubrica,4,'0') || '-' || LPAD(PAGA20.NuSufixoRubrica,2,'0')

--&FolhaPagamento_NuMesReferenci:8
--&FolhaPagamento_NuAnoReferenci:2020
--&FolhaPagamento_CdTipoFolhPaga:2
--&FolhaPagamento_CdTipoCalculo:1
--&FolhaPagamento_NuSequencFolha:1
--&HistRubrVinc_CdVinculo:3931
