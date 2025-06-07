unit pashash;

{$MODE Objfpc}{$H+}

interface

type natint=SizeInt;
     natuint=SizeUint;
     PPointer=^Pointer;

const pashash_magic_number:array[1..6] of Qword=(
Qword($9DDFEA08EB382D69),Qword($FE5A86EB5127941A),Qword($DADBDAD51C7CDA6C),
Qword($EC0E971978E5E5E4),Qword($A4620EC3FADB8202),Qword($927C6B26E95F60BF));
      pashash_move_number:array[1..6] of byte=(47,53,43,37,23,11);
      pashash_rotate_number:array[1..6] of byte=(27,31,19,13,7,5);

function pashash_generate_value(str:string;index:byte):qword;

implementation

function pashash_string_to_pointer(value:string):Pointer;
begin
 pashash_string_to_pointer:=Pointer(value);
end;
function pashash_rotate(value:Qword;shift:byte):Qword;
begin
 pashash_rotate:=(value shr shift) or (value shl (64-shift));
end;
function pashash_mix(value1,value2:Qword;index:byte):Qword;
var tempnum1,tempnum2:Qword;
begin
 tempnum1:=value1 xor value2;
 tempnum1:=tempnum1*pashash_magic_number[index];
 tempnum1:=tempnum1 xor (tempnum1 shr pashash_move_number[index]);
 tempnum2:=value2 xor tempnum1;
 tempnum2:=tempnum2*pashash_magic_number[index];
 tempnum2:=tempnum2 xor (tempnum2 shr pashash_move_number[index]);
 pashash_mix:=tempnum2*pashash_magic_number[index];
end;
function pashash_hash_0to16(str:string;len:byte;index:byte):Qword;
var q1,q2:qword;
    d1,d2:dword;
    b1,b2,b3:byte;
begin
 if(len>=8) then
  begin
   q1:=Pqword(pashash_string_to_pointer(str))^;
   q2:=Pqword(pashash_string_to_pointer(str)+len-8)^;
   pashash_hash_0to16:=pashash_mix(q1,pashash_rotate(q2+len,len),index) xor q2;
  end
 else if(len>=4) then
  begin
   d1:=Pdword(pashash_string_to_pointer(str))^;
   d2:=Pdword(pashash_string_to_pointer(str)+len-4)^;
   pashash_hash_0to16:=pashash_mix(len+Qword(d1) shl 3,d2,index);
  end
 else if(len>0) then
  begin
   b1:=Pbyte(pashash_string_to_pointer(str))^;
   b2:=Pbyte(pashash_string_to_pointer(str)+len shr 1)^;
   b3:=Pbyte(pashash_string_to_pointer(str)+len-1)^;
   d1:=b1+Dword(b2) shl 8;
   d2:=len+Dword(b3) shl 2;
   pashash_hash_0to16:=pashash_mix(d1,d2,index);
  end
 else pashash_hash_0to16:=pashash_magic_number[index];
end;
function pashash_generate_value(str:string;index:byte):qword;
var i,len,reallen:dword;
    h,g,f,a,b,offset:Qword;
begin
 len:=length(str); reallen:=len;
 if(len<=16) then exit(pashash_hash_0to16(str,len,index));
 h:=len; g:=pashash_magic_number[index]*len; f:=g; offset:=0;
 while(len>=16)do
  begin
   a:=Pqword(pashash_string_to_pointer(str)+offset)^;
   b:=Pqword(pashash_string_to_pointer(str)+offset+8)^;
   h:=h xor pashash_mix(a,b,index);
   h:=pashash_rotate(h,pashash_rotate_number[index])*pashash_magic_number[index]+g;
   dec(len,16);
   inc(offset,16);
  end;
 if(len>0) then
  begin
   h:=h xor pashash_hash_0to16(Copy(str,offset,reallen-offset+1),reallen-offset+1,index);
   h:=h*pashash_magic_number[index];
  end;
 h:=pashash_mix(h,f,index);
 pashash_generate_value:=h;
end;

end.

