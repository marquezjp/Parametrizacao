select cdpessoapensao from epenpessoapensao
where nmpessoa = 'SIMONE PEIXOTO DA SILVA';

update epenpessoapensao
set nucpf = 0
where cdpessoapensao = (select cdpessoapensao from epenpessoapensao
                         where nmpessoa = 'SIMONE PEIXOTO DA SILVA');
                         
select * from epenpessoapensao
where nmpessoa = 'SIMONE PEIXOTO DA SILVA';