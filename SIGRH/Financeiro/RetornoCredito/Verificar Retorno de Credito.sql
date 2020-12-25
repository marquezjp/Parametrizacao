-- Listar os Arquivos de Retorno
select arq.dtretorno, arq.nusequencia, arq.nmarqcreditoretorno, arq.flprocessado, count(*) QtdRegistros
  from epagarqcreditoretornodetalhe det
  inner join epagarqcreditoretorno arq on arq.cdarqcreditoretorno = det.cdarqcreditoretorno
 group by arq.dtretorno, arq.nusequencia, arq.nmarqcreditoretorno, arq.flprocessado
 order by arq.dtretorno, arq.nusequencia, arq.nmarqcreditoretorno, arq.flprocessado;

select * from epagarqcreditoretorno
where nmarqcreditoretorno = 'SB30050A'
and dtretorno = '30/05/20'
and cdarqcreditoretorno = '685';

-- Listar os Detalhes do Arquivo de Retorno
select det.*
  from epagarqcreditoretornodetalhe det
  inner join epagarqcreditoretorno arq on arq.cdarqcreditoretorno = det.cdarqcreditoretorno
  where arq.nmarqcreditoretorno = 'SB30050A'
    and arq.dtretorno = '30/05/20';

select * from epagarqcreditoretornodetalhe
where cdarqcreditoretorno = '685';

-- Verificar Retorno de Servidor
select capa.*
from epagcapahistrubricavinculo capa
left join ecadvinculo v on v.cdvinculo = capa.cdvinculo
inner join epagfolhapagamento f on f.cdfolhapagamento = capa.cdfolhapagamento
where v.numatricula = '335'
  and f.nuanoreferencia = '2020'
  and f.numesreferencia = '05'
  and f.cdtipofolhapagamento = '2'
  and f.flcalculodefinitivo = 'S'
  and nuretcreditoocor1 = '00'
  and nmarqretorno = 'SB30050A'
  and dtretorno = '30/05/20';
  
select capa.*
from epagcapahistrubricavinculo capa
left join ecadvinculo v on v.cdvinculo = capa.cdvinculo
inner join epagfolhapagamento f on f.cdfolhapagamento = capa.cdfolhapagamento
where v.numatricula = '1185'
  and f.nuanoreferencia = '2020'
  and f.numesreferencia = '05'
  and f.cdtipofolhapagamento = '2'
  and f.flcalculodefinitivo = 'S'
  and nuretcreditoocor1 = '00'
  and nmarqretorno = 'SB30050A'
  and dtretorno = '30/05/20';

-- Verificar Retorno de Pensionista
select ppp.* from epagcapahistpensaoalim ppp
left join ecadvinculo v on v.cdvinculo = ppp.cdvinculo
inner join epagfolhapagamento f on f.cdfolhapagamento = ppp.cdfolhapagamento
where v.numatricula = '335'
  and ppp.nusequencial = 1
  and f.nuanoreferencia = '2020'
  and f.numesreferencia = '05'
  and f.cdtipofolhapagamento = '2'
  and f.flcalculodefinitivo = 'S'
  and ppp.nuretcreditoocor1 = 'NA'
  and ppp.nmarqretorno = 'MANUAL'
  and ppp.dtretorno = '17/06/20';


select ppp.* from epagcapahistpensaoalim ppp
left join ecadvinculo v on v.cdvinculo = ppp.cdvinculo
inner join epagfolhapagamento f on f.cdfolhapagamento = ppp.cdfolhapagamento
where v.numatricula = '1185'
  and ppp.nusequencial = 2
  and f.nuanoreferencia = '2020'
  and f.numesreferencia = '05'
  and f.cdtipofolhapagamento = '2'
  and f.flcalculodefinitivo = 'S'
  and ppp.nuretcreditoocor1 = 'NA'
  and ppp.nmarqretorno = 'MANUAL'
  and ppp.dtretorno = '17/06/20';

select * from epagcapahistpensaoalim ppp
where nmarqretorno = 'MANUAL';

---- INSERIR RETORNO MANUALMENTE – SERVIDOR  -- fixo tipo de folha mensal

update epagcapahistrubricavinculo capa
  set capa.nuretcreditoocor1 = 'NA',
	  capa.dtretorno = &p_dt_retorno_ficticia,
	  capa.nmarqretorno = 'MANUAL'
	where capa.cdfolhapagamento in
		  (select f.cdfolhapagamento from epagfolhapagamento f
			   where f.nuanoreferencia = &p_ano and
					 f.numesreferencia = &p_mes and
					 f.cdtipofolhapagamento = 2 and
					 f.cdtipocalculo = 1 
		   )
		and capa.cdvinculo in
		  (select v.cdvinculo from ecadvinculo v where v.numatricula in &p_numatricula)


---- INSERIR RETORNO MANUALMENTE - PENSÃO ALIMENTÍCIA -- fixo tipo de folha mensal

update epagcapahistpensaoalim capaali
  set capaali.nuretcreditoocor1 = 'NA',
	  capaali.dtretorno = &p_dt_retorno_ficticia,
	  capaali.nmarqretorno = 'MANUAL'
	where capaali.cdfolhapagamento in
		  (select f.cdfolhapagamento from epagfolhapagamento f
			   where f.nuanoreferencia = &p_ano and
					 f.numesreferencia = &p_mes and
					 f.cdtipofolhapagamento = 2 and
					 f.cdtipocalculo = 1 
		   )
		and capaali.cdvinculo in
		  (select v.cdvinculo from ecadvinculo v where v.numatricula in &p_numatricula)
		and capaali.nusequencial = &p_nuseq_pensao;
