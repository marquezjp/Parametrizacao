with
niv as (select rownum, chr(rownum + 64) as nuniv from all_objects where rownum <= 26),
ref as (select rownum, lpad(rownum,2,0) as nuref from all_objects where rownum <= 99),
nivrefpadrao as (select nuniv, nuref from niv join ref on nuref is not null)

select nuniv, nuref from nivrefpadrao
where nuniv between 'A' and 'B'
  and nuref between '01' and '06' 
order by nuniv, nuref