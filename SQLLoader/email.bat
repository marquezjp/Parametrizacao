sqlplus 'SIGRH/sigrh@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=10.48.1.68)(PORT=1521))(CONNECT_DATA=(SERVICE_NAME=sigrhrrtst)))'

sqlldr control=email.ctl log=email.log data=email.dat 'SIGRH/sigrh@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=10.48.1.68)(PORT=1521))(CONNECT_DATA=(SERVICE_NAME=sigrhrrtst)))'

sqlldr 'SIGRH/sigrh@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=10.48.1.68)(PORT=1521))(CONNECT_DATA=(SERVICE_NAME=sigrhrrtst)))' control=email.ctl log=email.log data=email.dat

sqlldr parfile=email.par
