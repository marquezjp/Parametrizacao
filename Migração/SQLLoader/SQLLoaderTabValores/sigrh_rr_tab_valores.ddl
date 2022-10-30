drop table sigrh_rr_tab_valores;

create table sigrh_rr_tab_valores (
nmtabelavalorgeralcef  varchar2(128),
sgtabelavalorgeralcef  varchar2(128),
decarreira  varchar2(128),
degrupoocupacional  varchar2(128),
declasse  varchar2(128),
nunivel  varchar2(128),
nureferencia  varchar2(128),
vlfixo number(12,2)
)
;

select * from sigrh_rr_tab_valores;

select count(*) from sigrh_rr_tab_valores;
