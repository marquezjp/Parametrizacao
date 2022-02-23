-- Formatar Data para o formato dd/mm/yyyy
select to_date('01-02-2022', 'dd-mm-yyyy') from dual;

-- Último dia do mês
select last_day(to_date('01-02-2022', 'dd-mm-yyyy')) from dual;

-- Lista de Dias da Semana
select
 lpad(rownum,2,0) as dia,
 to_date('01-02-2022', 'dd-mm-yyyy') + rownum - 1 as dt,
 to_char( last_day(to_date('01-02-2022', 'dd-mm-yyyy')) + rownum - 1, 'DY' ) as dia_semana
from all_objects
where rownum <= last_day(to_date('01-02-2022', 'dd-mm-yyyy')) - to_date('01/02/2022')+1;

-- Total de Dias Uteis
select count(*)
from ( select rownum rnum from all_objects
       where rownum <= last_day(to_date('01-02-2022', 'dd-mm-yyyy')) - to_date('01/02/2022')+1 )
where to_char( last_day(to_date('01-02-2022', 'dd-mm-yyyy')) + rnum - 1, 'DY' ) not in ( 'SAB', 'DOM' );