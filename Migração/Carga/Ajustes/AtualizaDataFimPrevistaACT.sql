--- Relacionar Vinculos
select cdvinculo, cdhistcargoefetivo from ecadhistcargoefetivo cef
where cdrelacaotrabalho = 3 and flanulado = 'N'
  and nucpfcadastrador = 11111111111 and to_char(dtinclusao,'DD/MM/YYYY') = '27/08/2023'
  and to_char(dtfim,'DD/MM/YYYY') = '31/12/2023'

--- For para Update em todos os conceitos
begin
for cef in (
select cdvinculo, cdhistcargoefetivo from ecadhistcargoefetivo cef
where cdrelacaotrabalho = 3 and flanulado = 'N'
  and nucpfcadastrador = 11111111111 and to_char(dtinclusao,'DD/MM/YYYY') = '27/08/2023'
  and to_char(dtfim,'DD/MM/YYYY') = '31/12/2023'
)
loop

  update ecadhistdadosbancariosvinculo
     set dtfimvigencia = null
  where cdvinculo = cef.cdvinculo;

  update ecadhistsitprevvinculo
     set dtfim = to_date('31/12/2024','DD/MM/YYYY')
  where cdvinculo = cef.cdvinculo;

  update ecadhistcargahoraria
     set dtfim = to_date('31/12/2024','DD/MM/YYYY')
  where cdhistcargoefetivo = cef.cdhistcargoefetivo;
  
  update ecadhistnivelrefcef
     set dtfim = to_date('31/12/2024','DD/MM/YYYY'),
         dtfimprevista = null
  where cdhistcargoefetivo = cef.cdhistcargoefetivo;

  update ecadlocaltrabalho
     set dtfim = to_date('31/12/2024','DD/MM/YYYY'),
         dtfimprevisto = to_date('31/12/2024','DD/MM/YYYY')
  where cdhistcargoefetivo = cef.cdhistcargoefetivo;

  update ecadhistjornadatrabalho
     set dtfim = to_date('31/12/2024','DD/MM/YYYY'),
         dtfimprevisto = to_date('31/12/2024','DD/MM/YYYY')
  where cdlocaltrabalho = (select cdlocaltrabalho from ecadlocaltrabalho where cdhistcargoefetivo = cef.cdhistcargoefetivo);

  update ecadvinculo
     set dtdesligamento = to_date('31/12/2024','DD/MM/YYYY'),
         dtdesligamentoprevisto = to_date('31/12/2024','DD/MM/YYYY')
  where cdvinculo = cef.cdvinculo;

  update ecadhistcargoefetivo
     set dtfim = to_date('31/12/2024','DD/MM/YYYY'),
         dtfimprevisto = to_date('31/12/2024','DD/MM/YYYY')
  where cdvinculo = cef.cdvinculo;
  
end loop;
end;

--- Excluir ecadHistFinalCargoEfetivo

--delete ecadhistfinalcargoefetivo
select * from ecadhistfinalcargoefetivo
where to_char(dtinclusao,'DD/MM/YYYY') = '27/08/2023'
  and cdhistcargoefetivo in (select cef.cdhistcargoefetivo from ecadhistcargoefetivo cef
                             where cef.cdrelacaotrabalho = 3 and cef.flanulado = 'N'
                               and cef.nucpfcadastrador = 11111111111 and to_char(cef.dtinclusao,'DD/MM/YYYY') = '27/08/2023'
                               and to_char(cef.dtfim,'DD/MM/YYYY') = '31/12/2024')

--- Verificar os Conceitos Envolvidos pelo cdvinculo
select * from ecadvinculo
where cdvinculo = 73537; 

select cdvinculo, dtadmissao, dtinclusao, dtdesligamento, dtdesligamentoprevisto, dtanulado, flanulado from ecadvinculo
where cdvinculo = 73537; 

select cdhistcargoefetivo, cdvinculo, dtinicio, dtfimprevisto, dtfim from ecadhistcargoefetivo
where cdvinculo = 73537;

select cdhistdadosbancariosvinculo, cdvinculo, dtiniciovigencia, dtfimvigencia from ecadhistdadosbancariosvinculo
where cdvinculo = 73537; -- Não Atualiza a dtfimvigencia

select cdhistcentrocustovinculo, cdvinculo, dtiniciovigencia, dtfimvigencia from ecadhistcentrocustovinculo
where cdvinculo = 73537;

select cdhistsitprevvinculo, cdvinculo, dtinicio, dtfim from ecadhistsitprevvinculo
where cdvinculo = 73537;

select cdhistcargahoraria, cdhistcargoefetivo, dtinicial, dtfim from ecadhistcargahoraria
where cdhistcargoefetivo = (select cdhistcargoefetivo from ecadhistcargoefetivo where cdvinculo = 73537);

select cdhistnivelrefcef, cdhistcargoefetivo, dtinicio, dtfimprevista, dtfim from ecadhistnivelrefcef
where cdhistcargoefetivo = (select cdhistcargoefetivo from ecadhistcargoefetivo where cdvinculo = 73537);  -- Não atualiza a dtfimprevista

select cdlocaltrabalho, cdhistcargoefetivo, dtinicio, dtfimprevisto, dtfim from ecadlocaltrabalho
where cdhistcargoefetivo = (select cdhistcargoefetivo from ecadhistcargoefetivo where cdvinculo = 73537);

select cdhistjornadatrabalho, cdlocaltrabalho, dtinicio, dtfimprevisto, dtfim from ecadhistjornadatrabalho
where cdlocaltrabalho = (select cdlocaltrabalho from ecadlocaltrabalho
                         where cdhistcargoefetivo = (select cdhistcargoefetivo from ecadhistcargoefetivo where cdvinculo = 73537));

-- Não pode existir
select cdhistfinalcargoefetivo, cdhistcargoefetivo, dtfinalizacao from ecadhistfinalcargoefetivo
where cdhistcargoefetivo = (select cdhistcargoefetivo from ecadhistcargoefetivo where cdvinculo = 73537);