select rownum from all_objects
where rownum <= 12;

select level from dual
connect by level <= 12;
