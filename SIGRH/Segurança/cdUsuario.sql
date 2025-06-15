select * from esegusuario
where cdusuario in (2938, 17609, 5775, 28172);

select * from esegautorizacaoacesso
where cdusuario in (2938, 17609, 5775, 28172);

select * from eseghistsenhaacesso
where cdusuario in (2938, 17609, 5775, 28172);

select * from esegusuariohistorico
where cdusuario in (2938, 17609, 5775, 28172);

select * from eseghistusuarioportal
where cdusuario in (2938, 17609, 5775, 28172);

select * from esegexcecao
where cdusuario in (2938, 17609, 5775, 28172);

select * from esegtraceaplicacao
where cdusuariologado in (2938, 17609, 5775, 28172);

-- Excluir --

define usuario = (select cdusuario from esegusuario where nucpf = '51902290259');

select * from esegusuario
where cdusuario = &usuario;

delete from eseglogcampo
where cdlogtabela in (select cdlogtabela from eseglogtabela
                      where cdlog in (select cdlog from eseglog
                                      where cdautorizacaoacesso in (select cdautorizacaoacesso from esegautorizacaoacesso
                                                                    where cdusuario = &usuario)));

delete from eseglogtabela
where cdlog in (select cdlog from eseglog
                 where cdautorizacaoacesso in (select cdautorizacaoacesso from esegautorizacaoacesso where cdusuario = &usuario));

delete from eseglog
where cdautorizacaoacesso in (select cdautorizacaoacesso from esegautorizacaoacesso where cdusuario = &usuario);

delete from eseghistsenhaacesso
where cdautorizacaoacesso in (select cdautorizacaoacesso from esegautorizacaoacesso where cdusuario = &usuario);

delete from esegfuncionalidadegestor
where cdautorizacaoacesso in (select cdautorizacaoacesso from esegautorizacaoacesso where cdusuario = &usuario);

delete from esegautorizacaoabrangencia
where cdautorizacaoacesso in (select cdautorizacaoacesso from esegautorizacaoacesso where cdusuario = &usuario);

delete from esegautorizacaoperfil
where cdautorizacaoacesso in (select cdautorizacaoacesso from esegautorizacaoacesso where cdusuario = &usuario);

delete from eseghistsenhaacesso
where cdusuario = &usuario;

delete from esegusuariohistorico
where cdusuario = &usuario;

delete from esegautorizacaoacesso
where cdusuario = &usuario;

delete from esegusuario
where cdusuario = &usuario;