select * from ecadtiporegimeproprioprev
--where cdtiporegimeproprioprev = 1

--select nupercpatronal from ecadtiporegimeproprioprev
update ecadtiporegimeproprioprev
set nupercpatronal = 14
where cdtiporegimeproprioprev = 2;

--select * from ecadtiporegimeproprioprev;

commit;