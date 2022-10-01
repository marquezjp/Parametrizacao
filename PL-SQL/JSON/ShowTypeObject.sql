set serveroutput on

declare

  docJSON     JSON_OBJECT_T;
  chavesJSON  JSON_KEY_LIST;
  valorJSON   JSON_ELEMENT_T;
  objetoJSON  JSON_OBJECT_T;
  vetorJSON   JSON_ARRAY_T;

begin
 
  docJSON := JSON_OBJECT_T.parse('
{
  "PONumber" : 1600,
  "Reference" : "ABULL-20140421",
  "Requestor" : "Alexis Bull",
  "User" : "ABULL",
  "CostCenter" : "A50",
  "ShippingInstructions" : {
      "name" : "Alexis Bull",
      "Address" : {
        "street" : "200 Sporting Green",
        "city" : "South San Francisco",
        "state" : "CA",
        "zipCode" : 99236,
        "country" : "United States of America"
      },
      "Phone" : [
        {
          "type" : "Office",
          "number" : "909-555-7307"
        },
        {
          "type" : "Mobile",
          "number" : "415-555-1234"
        }
      ]
  },
  "Special Instructions" : null,
  "AllowPartialShipment" : true,
  "LineItems" : [
    {
      "ItemNumber" : 1,
      "Part" : {
        "Description" : "One Magic Christmas",
        "UnitPrice" : 19.95,
        "UPCCode" : 13131092899
      },
      "Quantity" : 9.0
    },
    {
      "ItemNumber" : 2,
      "Part" : {
        "Description" : "Lethal Weapon",
        "UnitPrice" : 19.95,
        "UPCCode" : 85391628927
      },
      "Quantity" : 5.0
    }
  ],
  "totalQuantity" : 14,
  "totalPrice" : 279.3
}');
                             
  chavesJSON := docJSON.GET_KEYS;
 
  begin
     valorJSON := treat (valorJSON as JSON_OBJECT_T);
     for i in 1 .. chavesJSON.count
     loop
        valorJSON := docJSON.get(chavesJSON(i));

        case
           when valorJSON.IS_NULL
           then
              dbms_output.put_line (chavesJSON(i) || '(NULL) : ' || valorJSON.TO_STRING);

           when valorJSON.IS_BOOLEAN   
           then
              dbms_output.put_line (chavesJSON(i) || '(BOOLEAN) : ' || valorJSON.TO_STRING);

           when valorJSON.IS_NUMBER
           then
              dbms_output.put_line (chavesJSON(i) || '(NUMBER) : ' || valorJSON.TO_STRING);

           when valorJSON.IS_DATE
           then
              dbms_output.put_line (chavesJSON(i) || '(DATE) : ' || valorJSON.TO_STRING);

           when valorJSON.IS_STRING
           then
              dbms_output.put_line (chavesJSON(i) || '(STRING) : ' || valorJSON.TO_STRING);

           when valorJSON.Is_Object
           then
              objetoJSON := TREAT (valorJSON as JSON_OBJECT_T);
              dbms_output.put_line (chavesJSON(i) || '(OBJECT) : ' || objetoJSON.STRINGIFY);

           when valorJSON.Is_Array
           then
              vetorJSON := TREAT (valorJSON as JSON_ARRAY_T);
              dbms_output.put_line (chavesJSON(i) || '(ARRAY de ' || vetorJSON.GET_SIZE || ' elementos) : ' || vetorJSON.STRINGIFY);

           else
              dbms_output.put_line (chavesJSON(i) || '(no match) : ' || valorJSON.TO_STRING);
        end case;

     end loop;    
 
  end;

end;