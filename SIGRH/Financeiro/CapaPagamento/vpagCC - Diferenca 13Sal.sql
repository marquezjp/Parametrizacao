select distinct
    nuAnoMEsReferencia as REFERENCIA,
    nmOrgao as ORGAO,
    lpad(a.numatricula||'-'||a.nudvmatricula,9,'0') as MATRICULA,
    a.nmpessoa as NOME
	
 from vpagCC a
 
Where cdRubricaAgrupamento IN (1266)
 and cdFolhaPAgamento in (select cdFolhaPagamento
						    from Epagfolhapagamento
						   where nuANoReferencia = 2020
						     and nuMesReferencia > 2
							 and cdtipofolhapagamento = 6
							 and flcalculodefinitivo = 'S' 
							 and cdorgao <> 49)
 and vlIndiceRubrica < 12 and  exists (select 1
										from vpagCC b
									   where a.cdVinculo = b.cdVinculo
										 and a.cdFolhaPagamento = b.cdFOlhaPagamento
										 and b.cdRubricaAgrupamento IN (2144,2150))
										 
order by nuAnoMEsReferencia, nmOrgao