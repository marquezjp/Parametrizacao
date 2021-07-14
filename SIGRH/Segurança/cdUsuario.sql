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

delete from eseglogcampo
where cdlogtabela in (select cdlogtabela from eseglogtabela
                       where cdlog in (select cdlog from eseglog
                                        where cdautorizacaoacesso in (select cdautorizacaoacesso from esegautorizacaoacesso
                                                                       where cdusuario = 1000002)));

delete from eseglogtabela
where cdlog in (select cdlog from eseglog
                 where cdautorizacaoacesso in (select cdautorizacaoacesso from esegautorizacaoacesso where cdusuario = 1000002));

delete from eseglog
where cdautorizacaoacesso in (select cdautorizacaoacesso from esegautorizacaoacesso where cdusuario = 1000002);

delete from eseghistsenhaacesso
where cdautorizacaoacesso in (select cdautorizacaoacesso from esegautorizacaoacesso where cdusuario = 1000002);

delete from esegfuncionalidadegestor
where cdautorizacaoacesso in (select cdautorizacaoacesso from esegautorizacaoacesso where cdusuario = 1000002);

delete from esegautorizacaoabrangencia
where cdautorizacaoacesso in (select cdautorizacaoacesso from esegautorizacaoacesso where cdusuario = 1000002);

delete from esegautorizacaoperfil
where cdautorizacaoacesso in (select cdautorizacaoacesso from esegautorizacaoacesso where cdusuario = 1000002);

delete from esegautorizacaoacesso
where cdusuario = 1000002;