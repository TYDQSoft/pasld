unit pashash;

interface

const pashash_base:array[1..4] of qword=(13,83,179,431);
      pashash_modulo:array[1..4] of qword=(1000000000-7,100000000000-29,10000000000000-83,
      1000000000000000-181);

function pashash_generate_value(str:string;index:byte):qword;

implementation

function pashash_generate_value(str:string;index:byte):qword;
var i,len:dword;
    value:qword;
begin
 len:=length(str); value:=0;
 value:=0;
 for i:=1 to len do
  begin
   value:=(value*pashash_base[index]+Byte(str[i])) mod pashash_modulo[index];
  end;
 pashash_generate_value:=value;
end;

end.

