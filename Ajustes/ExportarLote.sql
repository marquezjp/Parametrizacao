SET SERVEROUTPUT ON SIZE UNLIMITED;
BEGIN
  DECLARE
    TYPE tabsgConceitos IS TABLE OF VARCHAR2(30);
    vsgConceitos tabsgConceitos := tabsgConceitos('VALORREFERENCIA', 'BASECALCULO', 'RUBRICA');
  BEGIN
    FOR r IN (
      SELECT DISTINCT a.sgAgrupamento FROM ecadOrgao o
      JOIN ecadAgrupamento a ON a.cdAgrupamento = o.cdAgrupamento
      WHERE o.flImplantado = 'S' ORDER BY a.sgAgrupamento
    ) LOOP
      FOR i IN 1 .. vsgConceitos.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE('Exportar Parâmetros ' ||
          'sgAgrupamento: ' || r.sgAgrupamento || ', ' ||
          'sgConceito: ' || vsgConceitos(i)
        );
        PKGMIG_Parametrizacao.pExportar('{"sgAgrupamento": "' || r.sgAgrupamento || '", "sgConceito": "' || vsgConceitos(i) || '"}');
      END LOOP;
    END LOOP;
  END;
END;
/