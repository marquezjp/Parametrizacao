 select  o.sgorgao Orgao,
		 p.nmpessoa Nome,
		 pkgutil.FFORMATAMATRICULA (v.numatricula, v.nudvmatricula, v.nuseqmatricula) Matricula,
		 lpad(rub.cdtiporubrica, 2, 0)||'-'||lpad(rub.nurubrica, 4, 0) Rubrica,
		 fin.nusufixorubrica Sufixo,
		 fin.dtiniciodireito Inicio,
		 fin.dtfimdireito    Fim,
		 fin.vlindice Indice,
		 fin.vllancamentofinanceiro Valor
	 
  from epaglancamentofinanceiro fin
	  
	 inner join ecadvinculo v on v.cdvinculo = fin.cdvinculo
	 inner join ecadpessoa p on p.cdpessoa = v.cdpessoa
	 inner join vcadorgao o on o.cdorgao = v.cdorgao
	 inner join vpagrubricaagrupamento rub on rub.cdrubricaagrupamento = fin.cdrubricaagrupamento             
	 
 where rub.cdtiporubrica = 1
	 and rub.nurubrica = 10
	 --and rub.nurubrica in (681, 682)
	 --and fin.dtiniciodireito >= '01/08/2020'
	 and nvl(fin.dtfimdireito, '31/12/2099') >= '01/09/2020' 
	 
	order by nome