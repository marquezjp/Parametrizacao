--- Atualizar o Sequencial da Matricula mais recente com o Maior Sequencial, tanto no ecadVinculo, como no emigMatricula
begin
for maiorSeq in (
with
ultimoVinculo as (
select numatricula, max(dtadmissao) as dtadmissao from ecadvinculo
where flanulado = 'N'
group by numatricula order by numatricula
),
maiorSequencialUltimoVinculo as (
select v.numatricula, max(v.nuseqmatricula) as nuseqmatricula from ecadvinculo v
inner join ultimoVinculo u on u.numatricula = v.numatricula and u.dtadmissao = v.dtadmissao
where v.flanulado = 'N'
group by v.numatricula
),
maiorSequencialMatricula as (
select numatricula, max(nuseqmatricula) as nuseqmatriculamaior from (
select numatricula, to_number(nuseqmatricula) as nuseqmatricula from emigmatricula union
select numatricula, nuseqmatricula from ecadvinculo where flanulado = 'N' 
) group by numatricula having max(nuseqmatricula) > 1 order by numatricula
)

--select count(1) from (
select v.numatricula, v.dtadmissao, v.nuseqmatricula, maior.nuseqmatriculamaior + 1 as nuseqmatriculanovo from ecadvinculo v
inner join maiorSequencialUltimoVinculo ult on ult.numatricula = v.numatricula and ult.nuseqmatricula = v.nuseqmatricula
inner join maiorSequencialMatricula maior on maior.numatricula = v.numatricula
inner join emigmatricula m on m.numatricula = v.numatricula and m.nuseqmatricula = v.nuseqmatricula
where v.flanulado = 'N' and v.nuseqmatricula != maior.nuseqmatriculamaior and v.dtadmissao = m.dtadmissao
--) -- 725
)
loop

  update ecadvinculo v set v.nuseqmatricula = maiorSeq.nuseqmatriculanovo
  where v.numatricula = maiorSeq.numatricula and v.nuseqmatricula = maiorSeq.nuseqmatricula;

  update emigmatricula m set nuseqmatricula = maiorSeq.nuseqmatriculanovo
  where m.numatricula = maiorSeq.numatricula and m.nuseqmatricula = maiorSeq.nuseqmatricula;
  
end loop;
end;