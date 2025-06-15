select * from v$nls_parameters
where parameter in ('NLS_CHARACTERSET', 'NLS_NCHAR_CHARACTERSET');
/