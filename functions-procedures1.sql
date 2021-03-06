-- *** 1. ***
-- Create a function that indicates the type of transport that has been used during a transfer (land, --train, plane) returns the total calculation of the cost * kms of those transfers that have been made for this type --of transport.
--This function will be called within a stored procedure that will print for the total cost for the type of --transport introduced.
--Finally, this procedure will be called from an anonymous block, which will ask for the type of transport --by screen.

set serveroutput on;

accept transporte char prompt 'Introduce el tipo de transporte para calcular el coste total realizado por dicho tipo';
declare
tipus_transport trasllat_empresatransport.tipus_transport%type := initcap('&transporte'); 
transporte404 exception; -- excepcion para controlar que exista el transporte introducido
begin
if buscartransporte(tipus_transport) = false then -- si no existe el tipo de transporte saltara esta excepcion
raise transporte404;
else  -- si se ha encontrado el tipo de transporte entonces realizara el calculo y lo imprimira
imprimircost(calcularcost(tipus_transport),tipus_transport); 
end if;
exception
when transporte404 then
DBMS_OUTPUT.PUT_LINE('El tipo de transporte ' || tipus_transport || ' no existe en la base de datos');
end;
/

create or replace function buscartransporte(transporte trasllat_empresatransport.tipus_transport%type) -- esta funcion buscara si existe el tipo de transporte
return boolean
is 
tipotransporte trasllat_empresatransport.tipus_transport%type;
condicion boolean := true; -- por defecto sera true, si no se encuentra se cambiara a false
begin
begin
select tipus_transport into tipotransporte 
from trasllat_empresatransport
where tipus_transport = transporte group by tipus_transport;
return condicion;
end;
exception
when no_data_found then
condicion := false;
return condicion;
end buscartransporte;
/


create or replace function calcularcost(tipus_trasllat trasllat_empresatransport.tipus_transport%type) -- esta funcion calculara el coste total de cada tipo de transporte
return number
is
trasllat trasllat_empresatransport.tipus_transport%type := tipus_trasllat;
coste_total number;
begin
select sum(kms*cost) into coste_total from trasllat_empresatransport 
where tipus_transport like trasllat; 
return coste_total;
end calcularcost;
/

create or replace procedure imprimircost(coste_total number, tipus_transport trasllat_empresatransport.tipus_transport%type) -- este procedimiento imprimira el coste total
is
transporte trasllat_empresatransport.tipus_transport%type := tipus_transport;
costetotal number := coste_total;
begin
DBMS_OUTPUT.PUT_LINE('El coste total por el tipo de transporte ' || transporte || ' es de ' || costetotal || ' euros.' );
end imprimircost;
/


-- *** 2. ***
--We need to create a procedure that by giving you a destination code and an entire year (e.g. 2016) we
--indicate the amount of waste that has been moved to that destination during that year.
--To do this exercise I suggest you perform a function, a procedure and finally a block
--anonymous. The latter must be of the type:
   --Look
     --procedure_name (data1, data2)
     --end;

accept anio number prompt 'introduce un año';
accept destinationcode number prompt 'introduce el codigo de destino';
declare
anio number := &anio;
code number := &destinationcode;
codidesti404 exception;
anio404 exception; -- un par de excepctions para controlar que existan los valores introducidos codigo de destino y año
begin
if buscarcoddesti(code) = false then 
raise codidesti404;
elsif buscaraño(anio) = false then
raise anio404;
else -- si no ha saltado ninguna excepcion entonces imprimira el resultado
imprimirresiduos_poraño(residuos_poraño(anio,code), code);
end if;
exception
when codidesti404 then
DBMS_OUTPUT.PUT_LINE('El codigo de destino ' || code || ' no existe en la base de datos');
when anio404 then
DBMS_OUTPUT.PUT_LINE('El año ' || anio || ' no figura en ningun registro de fecha de envio');
end;
/



create or replace function buscaraño(anio number) -- esta funcion buscara si existe el año introducido
return boolean
is
año number;
condicion boolean := true;
begin
begin
select substr(data_enviament, 7, 8) into año from trasllat_empresatransport 
where substr(data_enviament, 7, 8) = substr(anio, 3, 4) group by substr(data_enviament, 7, 8); 
return condicion;
end;
exception
when no_data_found then
condicion := false;
return condicion;
end buscaraño;
/

create or replace function buscarcoddesti(code trasllat_empresatransport.cod_desti%type) -- esta funcion buscara si existe el codigo de destino
return boolean
is 
codigo trasllat_empresatransport.cod_desti%type;
condicion boolean := true;
begin
begin
select cod_desti into codigo
from trasllat_empresatransport
where cod_desti = code group by cod_desti;
return condicion;
end;
exception
when no_data_found then
condicion := false;
return condicion;
end buscarcoddesti;
/


create or replace procedure imprimirresiduos_poraño(cantidadresiduos number, code number) -- este procedimiento imprimira la cantidad de residuos y a que ciudad van (fantasia)
is
 cantidad number := cantidadresiduos;
 ciudad desti.ciutat_desti%type;
begin
select ciutat_desti into ciudad from desti where cod_desti = code;
 dbms_output.put_line('La cantidad de residuos es de ' || cantidad || ' unidades que han sido enviadas a ' || ciudad);
end imprimirresiduos_poraño;
/

create or replace function residuos_poraño(anio number, destinationcode number) -- esta funcion calculara la cantidad de residuos que se envian a una ciudad en un año determinado
return number
is 
cantidad number;
begin
select sum(r.quantitat) into cantidad 
from residu_constituent r, trasllat t,
desti d
where  r.nif_empresa = t.nif_empresa and t.cod_desti = d.cod_desti and 
substr(t.data_enviament, 7, 8) = substr(anio, 3, 4) 
and t.cod_desti = destinationcode;
return cantidad;
end residuos_poraño;
/






-- *** 3. ***
--Perform a procedure called "multiplier" that receives a number and displays its table of
--multiply.
--This procedure will be called from an anonymous blog.

accept numero prompt 'Introduce un numero y te mostrare la tabla de multiplicar'
declare
numero number := &numero;
begin
mostrartabla(numero);
end;
/

create or replace procedure mostrartabla(numero number)
is
begin
  for i in 1..9 loop
    dbms_output.put_line ( numero || ' X ' || i || ' = ' || numero * i );
  end loop;
end mostrartabla;
/


-- *** 4. ***
-- Perform a procedure called "show letters" that shows the first three letters of a word - entered on the screen.
--This procedure will be called from an anonymous blog.
accept palabra CHAR prompt 'Introduce una palabra';
declare
palabrita VARCHAR2(30) := '&palabra'; 
begin
mostrar_3primerasletras(palabrita);
end;
/

create or replace procedure mostrar_3primerasletras(palabrita varchar2)
is
palabra varchar2(30) := palabrita;
begin
    dbms_output.put_line (substr(palabra, 1, 3));
end mostrar_3primerasletras;
/

