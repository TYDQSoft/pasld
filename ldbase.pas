unit ldbase;

interface

{$MODE Objfpc}{$H+}

uses binbase,sysutils,classes,convmem;

type natuint=SizeUint;
     natint=SizeInt;
     Pnatuint=^natuint;
     Pnatint=^natint;
     dynqwordarray=array of Natuint;
     dynwordarray=array of word;
     dynstrarray=array of string;
     dynNatuintarray=array of Natuint;
     ld_string=packed record
               item:array of string;
               count:Natuint;
               end;
     ld_formula=packed record
                item:ld_string;
                bit:byte;
                mask:Natuint;
                ispaged:boolean;
                isgotoffset:boolean;
                isgotbase:boolean;
                isrelative:boolean;
                end;
     ld_map=packed record
            name:array of string;
            value:array of string;
            count:byte;
            end;
     ld_stack=packed record
              left,right:array of Natuint;
              count:byte;
              end;
     ld_file=packed record
             Content:Pbyte;
             Size:Natuint;
             end;
     ld_file_offset=packed record
                    filename:string;
                    offset:Natuint;
                    Size:Natuint;
                    end;
     ld_object_file=packed record
                    Content:Pbyte;
                    Fn:string;
                    Ptr:elf_object_file;
                    Size:Natuint;
                    end;
     ld_object_file_list=packed record
                         bit:0..4;
                         item:array of ld_object_file;
                         Count:Natuint;
                         end;
     ld_object_file_symbol_table=packed record
                                 SymbolVaildForLink:Pboolean;
                                 SymbolSection:array of string;
                                 SymbolName:array of string;
                                 SymbolNameHash:array of Natuint;
                                 SymbolBinding:array of byte;
                                 SymbolType:array of byte;
                                 SymbolSize:array of Natuint;
                                 SymbolIndex:array of word;
                                 SymbolValue:array of Natuint;
                                 SymbolVisible:array of byte;
                                 SymbolCount:Natuint;
                                 end;
     ld_object_file_rel_table=packed record
                              SymSecName:string;
                              SymSecHash:Natuint;
                              SymName:array of string;
                              SymHash:array of Natuint;
                              SymOffset:array of Natuint;
                              Symbol:array of Natuint;
                              SymType:array of Natuint;
                              SymCount:Natuint;
                              end;
     ld_object_file_rela_table=packed record
                               SymSecName:string;
                               SymSecHash:Natuint;
                               SymName:array of string;
                               SymHash:array of Natuint;
                               SymOffset:array of Natuint;
                               Symbol:array of Natuint;
                               SymType:array of Natuint;
                               SymAddend:array of Natint;
                               SymCount:Natuint;
                               end;
     ld_object_hash_table=packed record
                          BucketCount:Natuint;
                          BucketItem:array of Natuint;
                          BucketUsed:array of boolean;
                          ChainCount:Natuint;
                          ChainItem:array of Natuint;
                          ChainUsed:array of boolean;
                          end;
     ld_object_hash_table_adjust=packed record
                                 BucketCount:Natuint;
                                 BucketItem:array of Natuint;
                                 BucketUsed:array of boolean;
                                 ChainCount:Natuint;
                                 ChainItem:array of Natuint;
                                 ChainUsed:array of boolean;
                                 AdjustIndex:array of Natuint;
                                 AdjustStatus:array of byte;
                                 end;
     ld_object_file_item=packed record
                         SecUsed:array of boolean;
                         SecName:array of string;
                         SecContent:array of Pointer;
                         SecSize:array of Natuint;
                         SecType:array of byte;
                         SecNowPos:array of Natuint;
                         SecNowIndex:array of word;
                         SecCount:Natuint;
                         SecRel:array of ld_object_file_rel_table;
                         SecRelCount:Natuint;
                         SecRela:array of ld_object_file_rela_table;
                         SecRelaCount:Natuint;
                         SymTable:ld_object_file_symbol_table;
                         end;
     ld_object_file_stage_1=packed record
                            ObjFile:array of ld_object_file_item;
                            SecFlag:Dword;
                            Count:Natuint;
                            end;
     ld_object_file_adjust=packed record
                           SrcIndex:Pword;
                           SrcOffset:PDword;
                           DestIndex:Pword;
                           DestOffset:PDword;
                           AdjustName:array of string;
                           AdjustHash:array of Natuint;
                           AdjustFunc:array of boolean;
                           AdjustType:array of Natuint;
                           AdjustRelax:array of boolean;
                           AdjustUsed:array of boolean;
                           Addend:PNatint;
                           Formula:array of ld_formula;
                           Count:Natuint;
                           end;
     ld_object_file_section=packed record
                            SecName:array of Natuint;
                            SecOffset:PNatuint;
                            SecContent:Pointer;
                            SecCount:Natuint;
                            end;
     ld_object_file_temp_symbol_table=packed record
                                      SymbolQuotedByMain:Pboolean;
                                      SymbolFileIndex:PNatuint;
                                      SymbolIndex:Pword;
                                      SymbolSymIndex:PNatuint;
                                      SymbolSection:array of string;
                                      SymbolSectionHash:array of Natuint;
                                      SymbolName:array of string;
                                      SymbolNameHash:array of Natuint;
                                      SymbolCount:Natuint;
                                      end;
     ld_object_file_temporary=packed record
                              SecRel:array of ld_object_file_rel_table;
                              SecRelHash:array of Natuint;
                              SecRelCount:Natuint;
                              SecRela:array of ld_object_file_rela_table;
                              SecRelaHash:array of Natuint;
                              SecRelaCount:Natuint;
                              SymTable:ld_object_file_temp_symbol_table;
                              end;
     ld_object_file_stage_2=packed record
                            SecFlag:natuint;
                            EntryIndex:word;
                            EntryOffset:Dword;
                            SecName:array of string;
                            SecContent:array of ld_object_file_section;
                            SecSize:Pdword;
                            SecCount:Natuint;
                            SecRel:array of ld_object_file_rel_table;
                            SecRelCount:Natuint;
                            SecRela:array of ld_object_file_rela_table;
                            SecRelaCount:Natuint;
                            Adjust:ld_object_file_adjust;
                            AdjustHashTable:ld_object_hash_table_adjust;
                            SymTable:ld_object_file_symbol_table;
                            end;
     ld_hash=packed record
             BucketCount:dword;
             Bucket:array of dword;
             ChainCount:dword;
             Chain:array of dword;
             end;
     ld_object_file_final=packed record
                          SecFlag:natuint;
                          EntryAddress:Dword;
                          SecIndex:array of word;
                          SecAddress:array of Natint;
                          SecName:array of string;
                          SecContent:array of Pointer;
                          SecSize:array of Natint;
                          SecCount:word;
                          {Can be used in ELF or EFI File}
                          GotTable:array of Natuint;
                          GotSymbol:array of Natuint;
                          GotCount:Natuint;
                          Rela:ld_object_file_rela_table;
                          {For ELF Files Only}
                          GotPltTable:array of Natuint;
                          GotPltSymbol:array of Natuint;
                          GotPltCount:Natuint;
                          DynSym:ld_object_file_symbol_table;
                          Dynamic32:array of elf32_dynamic_entry;
                          Dynamic64:array of elf64_dynamic_entry;
                          Hash:ld_hash;
                          end;
     ld_elf_writer_32=packed record
                      Header:elf32_header;
                      ProgramHeader:array of elf32_program_header;
                      Content:array of Pointer;
                      SectionHeader:array of elf32_section_header;
                      end;
     ld_elf_writer_64=packed record
                      Header:elf64_header;
                      ProgramHeader:array of elf64_program_header;
                      Content:array of Pointer;
                      SectionHeader:array of elf64_section_header;
                      end;
     ld_pe_relocation_table=packed record
                            Block:pe_image_base_relocation_block;
                            item:array of pe_image_base_relocation_item;
                            end;
     ld_pe_writer=packed record
                  DosHeader:pe_dos_header;
                  DosStub:array[1..64] of byte;
                  PeHeader:pe_image_header;
                  DataHeader:array of pe_data_directory;
                  SectionHeader:array of pe_image_section_header;
                  RelocationTable:array of ld_pe_relocation_table;
                  end;
     ld_aarch64_add_or_sub_immediate=bitpacked record
                                     Rn:0..31;
                                     Rd:0..31;
                                     Imm12:0..4095;
                                     Shift:0..1;
                                     FixedValue:0..63;
                                     ClearStatus:boolean;
                                     Opcode:boolean;
                                     Is64bit:boolean;
                                     end;
     Pld_aarch64_add_or_sub_immediate=^ld_aarch64_add_or_sub_immediate;
     ld_aarch64_ld_or_st_immediate_12=bitpacked record
                                      Rn:0..31;
                                      Rd:0..31;
                                      Imm12:0..4095;
                                      Opcode:0..3;
                                      Unsigned:0..1;
                                      Reserved1:0..1;
                                      VR:0..1;
                                      Reserved2:0..7;
                                      Size:0..3;
                                      end;
     Pld_aarch64_ld_or_st_immediate_12=^ld_aarch64_ld_or_st_immediate_12;
     ld_aarch64_ld_or_st_immediate_9=bitpacked record
                                     Rn:0..31;
                                     Rd:0..31;
                                     PostOrPre:0..3;
                                     Imm9:0..511;
                                     Reserved1:0..1;
                                     Opcode:0..3;
                                     Reserved2:0..3;
                                     VR:0..1;
                                     Reserved3:0..7;
                                     Size:0..3;
                                     end;
     Pld_aarch64_ld_or_st_immediate_9=^ld_aarch64_ld_or_st_immediate_9;
     ld_riscv_i_type=bitpacked record
                     Operandcode:0..127;
                     DestinationRegister:0..31;
                     Function3:0..7;
                     SourceRegister:0..31;
                     ImmdiateNumber:0..$FFF;
                     end;
     Pld_riscv_i_type=^ld_riscv_i_type;
     ld_riscv_u_type=bitpacked record
                     Operandcode:0..127;
                     DestinationRegister:0..31;
                     ImmdiateNumber:0..$FFFFF;
                     end;
     Pld_riscv_u_type=^ld_riscv_u_type;
     ld_riscv_ci_type=bitpacked record
                      Compress0:0..3;
                      DestinationRegister:0..7;
                      ImmdiateNumber6_7:0..3;
                      SourceRegister:0..7;
                      ImmdiateNumber5_3:0..7;
                      CompressOpcode:0..7;
                      end;
     Pld_riscv_ci_type=^ld_riscv_ci_type;
     ld_loongarch_pcaddi=bitpacked record
                         DestinationRegister:0..31;
                         SignedImmediateNumber20bit:0..$FFFFF;
                         Opcode:0..127;
                         end;
     Pld_loongarch_pcaddi=^ld_loongarch_pcaddi;
     ld_dynamic_library_string=packed record
                               Name:array of string;
                               NamePosition:array of Natuint;
                               NameLength:array of Natuint;
                               Count:Natuint;
                               StringTotalLength:Natuint;
                               end;

var ldArch:word=0;
    ldBit:byte=0;
    ldGotCount:Natuint=0;
    ldDynamicLibrary:ld_dynamic_library_string;

const ld_format_none=0;
      ld_format_static_library=1;
      ld_format_dynamic_library=2;
      ld_format_executable_pie=4;
      ld_format_efi_application=6;
      ld_format_efi_boot_driver=8;
      ld_format_efi_runtime_driver=10;
      ld_format_efi_rom=12;
      ld_aarch64_add_or_sub_fixed_value=$22;
      ld_aarch64_ld_or_st_immediate_9_post_index=1;
      ld_aarch64_ld_or_st_immediate_9_pre_index=3;
      ld_loongarch_pcaddi_opcode=12;
      ld_loongarch_pcalau12i_opcode=13;
      ld_loongarch_pcaddu12i_opcode=14;
      ld_loongarch_pcaddu18i_opcode=15;
      ld_adjust_got=1;
      ld_adjust_got_plt=2;
      ld_adjust_other=3;

procedure ld_handle_dynamic_library(fn:dynstrarray);
function ld_generate_file_list(fn:dynstrarray):ld_object_file_list;
function ld_link_file(var objlist:ld_object_file_list;EntryName:string;SmartLinking:boolean):ld_object_file_stage_2;
procedure ld_handle_elf_file(fn:string;var ldfile:ld_object_file_stage_2;align:dword;debugframe:boolean;
format:byte;nodefaultlibrary:boolean;stripsymbol:boolean;dynamiclinker:string;
signature:string);
procedure ld_handle_elf_file_to_efi_file(fn:string;var ldfile:ld_object_file_stage_2;align:dword;
debugframe:boolean;format:byte;stripsymbol:boolean);
procedure ld_free_object_file_list(var filelist:ld_object_file_list);

implementation

function int_to_hash(num:Natuint):string;
const str:string='ILZAR+K)SCXJ'#39'6H$f4d8[&Q.c7eB#M"D';
var tempnum:Natuint;
begin
 Result:=''; tempnum:=num;
 if(tempnum=0) then exit('I');
 while(tempnum>0)do
  begin
   Result:=Result+str[tempnum mod 32+1];
   tempnum:=tempnum div 32;
  end;
end;
function generate_hash_from_string(str:string;section:boolean=false):Natuint;
var value,len:Natuint;
    count:Natuint;
    rest:byte;
    d:Pdword;
    {$IFDEF CPU32}
    w:Pword;
    {$ENDIF}
    i:Natuint;
    res:Natuint;
label label1;
begin
 value:=0; len:=length(str); if(len=0) then exit(0);
 {$IFDEF CPU64}
 count:=len div 4; rest:=len mod 4;
 d:=Pdword(str)+count;
 if(rest>0) then
  begin
   value:=value+d^ shl ((4-rest)*8) shr ((4-rest)*8);
  end;
 dec(d);
 if(count=0) then goto label1;
 i:=count;
 while(i>0)do
  begin
   value:=value+d^;
   dec(d); dec(i);
  end;
 {$ELSE CPU64}
 count:=len div 2; rest:=len mod 2;
 w:=Pword(str)+count;
 if(rest>0) then
  begin
   value:=value+w^ shl ((2-rest)*8) shr ((2-rest)*8)); dec(w);
  end;
 dec(w);
 if(count=0) then goto label1;
 i:=count;
 while(i>0)do
  begin
   value:=value+w^;
   dec(w); dec(i);
  end;
 {$ENDIF CPU64}
 label1:
 res:=value+len;
 if(section=false) then
 generate_hash_from_string:=res
 else
 generate_hash_from_string:=not res;
end;
function ld_search_for_index(var table:ld_object_hash_table;var symtab:dynnatuintarray;value:Natuint):Natuint;
var index:Natuint;
begin
 index:=table.BucketItem[value mod table.BucketCount];
 if(symtab[index]=value) then exit(index+1)
 else if(table.BucketUsed[value mod table.BucketCount]=false) then exit(0);
 while(True)do
  begin
   index:=table.ChainItem[index];
   if(symtab[index]=value) then exit(index+1)
   else if(table.ChainUsed[index]=false) then exit(0)
   else if(index=table.ChainItem[index]) then exit(0);
  end;
end;
function ld_search_for_index_array(var table:ld_object_hash_table;var symtab:dynnatuintarray;value:Natuint):dynnatuintarray;
var index:Natuint;
    len,i:Natuint;
begin
 {Get the length}
 index:=table.BucketItem[value mod table.BucketCount]; len:=1;
 if(table.BucketUsed[value mod table.BucketCount]=false) then
  begin
   SetLength(Result,0); exit(Result);
  end;
 while(True)do
  begin
   index:=table.ChainItem[index];
   inc(len);
   if(table.ChainUsed[index]=false) then break
   else if(index=table.ChainItem[index]) then break;
  end;
 {Set the Item}
 SetLength(Result,len);
 i:=1; index:=table.BucketItem[value mod table.BucketCount]; Result[i-1]:=index+1;
 while(i<len)do
  begin
   inc(i); index:=table.ChainItem[index]; Result[i-1]:=index+1;
  end;
end;
function ld_adjust_search_for_index(var table:ld_object_hash_table_adjust;
var symtab:dynnatuintarray;value:Natuint;inputindex:Natuint=0;adjtype:byte=0):Natuint;
var index:Natuint;
begin
 index:=table.BucketItem[value mod table.BucketCount];
 if(symtab[index]=value) then
  begin
   if(inputindex=0) or (table.AdjustIndex[index]<>adjtype) then
    begin
     exit(index+1);
    end
   else if(table.AdjustIndex[index]=0) and (table.AdjustIndex[index]=adjtype) then
    begin
     table.AdjustIndex[index]:=inputindex; table.AdjustIndex[index]:=adjtype;
     exit(0);
    end;
   exit(index+1);
  end
 else if(table.BucketUsed[value mod table.BucketCount]=false) then exit(0);
 while(True)do
  begin
   index:=table.ChainItem[index];
   if(symtab[index]=value) then
    begin
     if(inputindex=0) or (table.AdjustIndex[index]<>adjtype) then
      begin
       exit(index+1);
      end
     else if(table.AdjustIndex[index]=0) and (table.AdjustIndex[index]=adjtype) then
      begin
       table.AdjustIndex[index]:=inputindex; table.AdjustIndex[index]:=adjtype;
       exit(0);
      end;
     exit(index+1);
    end
   else if(table.ChainUsed[index]=false) then exit(0)
   else if(index=table.ChainItem[index]) then exit(0);
  end;
 ld_adjust_search_for_index:=0;
end;
function faststrcomp(str1,str2:string):boolean;
var len1,len2,count,i,mid,mid2:SizeUint;
    q1,q2:Pqword;
    {$IFDEF CPU32}
    d1,d2:Pdword;
    {$ENDIF}
    compnum1,compnum2:SizeUint;
    step:byte;
begin
 len1:=length(str1); len2:=length(str2);
 if(len1<>len2) then exit(false);
 if(len1=0) then exit(true);
 if(len1 mod sizeof(SizeUint)>0) then
  begin
   step:=(sizeof(SizeUint)-len1 mod 8)*8;
   compnum1:=(PSizeUint(str1)+len1 div sizeof(SizeUint))^ shl step;
   compnum2:=(PSizeUint(str2)+len1 div sizeof(SizeUint))^ shl step;
   if(compnum1<>compnum2) then exit(false);
  end;
 count:=len1 div sizeof(SizeUint);
 if(count=0) then exit(true);
 {$IFDEF CPU64}
 q1:=Pqword(str1); q2:=Pqword(str2); mid:=count div 2; mid2:=mid div 2; i:=1;
 if(count and $1=1) then if((q1+mid)^<>(q2+mid)^) then exit(false);
 if(mid and $1=1) then
  begin
   if((q1+mid2)^<>(q2+mid2)^) then exit(false);
   if((q1+mid+mid2)^<>(q2+mid+mid2)^) then exit(false);
  end;
 while(i<=mid2)do
  begin
   if((q1+i-1)^<>(q2+i-1)^) then exit(false);
   if((q1+mid-i)^<>(q2+mid-i)^) then exit(false);
   if((q1+mid+i-1)^<>(q2+mid+i-1)^) then exit(false);
   if((q1+count-i)^<>(q2+count-i)^) then exit(false);
   inc(i);
  end;
 faststrcomp:=true;
 {$ELSE}
 d1:=Pdword(str1); d2:=Pqword(str2); mid:=count div 2; mid2:=mid div 2; i:=1;
 if(count and $1=1) then if((d1+mid)^<>(d2+mid)^) then exit(false);
 if(mid and $1=1) then
  begin
   if((d1+mid2)^<>(d2+mid2)^) then exit(false);
   if((d1+mid+mid2)^<>(d2+mid+mid2)^) then exit(false);
  end;
 while(i<=mid2)do
  begin
   if((d1+i-1)^<>(d2+i-1)^) then exit(false);
   if((d1+mid-i)^<>(d2+mid-i)^) then exit(false);
   if((d1+mid+i-1)^<>(d2+mid+i-1)^) then exit(false);
   if((d1+count-i)^<>(d2+count-i)^) then exit(false);
   inc(i);
  end;
 faststrcomp:=true;
 {$ENDIF}
end;
function faststrcomp_segment(str1:string;startx,endx:Sizeuint;str2:string):boolean;
var len1,len2,count,i,mid,mid2:SizeUint;
    q1,q2:Pqword;
    {$IFDEF CPU32}
    d1,d2:Pdword;
    {$ENDIF}
    compnum1,compnum2:SizeUint;
    step:byte;
begin
 len1:=endx-startx+1; len2:=length(str2);
 if(len1>length(str1)) or (len1<>len2) then exit(false);
 if(len1=0) then exit(true);
 if(len1 mod sizeof(SizeUint)>0) then
  begin
   step:=(sizeof(SizeUint)-len1 mod sizeof(SizeUint))*8;
   compnum1:=(PSizeUint(@str1[startx])+len1 div sizeof(SizeUint))^ shl step;
   compnum2:=(PSizeUint(str2)+len1 div sizeof(SizeUint))^ shl step;
   if(compnum1<>compnum2) then exit(false);
  end;
 count:=len1 div sizeof(SizeUint);
 if(count=0) then exit(true);
 {$IFDEF CPU64}
 q1:=Pqword(@str1[startx]); q2:=Pqword(str2); mid:=count div 2; mid2:=mid div 2; i:=1;
 if(count and $1=1) then if((q1+mid)^<>(q2+mid)^) then exit(false);
 if(mid and $1=1) then
  begin
   if((q1+mid2)^<>(q2+mid2)^) then exit(false);
   if((q1+mid+mid2)^<>(q2+mid+mid2)^) then exit(false);
  end;
 while(i<=mid2)do
  begin
   if((q1+i-1)^<>(q2+i-1)^) then exit(false);
   if((q1+mid-i)^<>(q2+mid-i)^) then exit(false);
   if((q1+mid+i-1)^<>(q2+mid+i-1)^) then exit(false);
   if((q1+count-i)^<>(q2+count-i)^) then exit(false);
   inc(i);
  end;
 faststrcomp_segment:=true;
 {$ELSE}
 d1:=Pdword(@str1[startx]); d2:=Pqword(str2); mid:=count div 2; mid2:=mid div 2; i:=1;
 if(count and $1=1) then if((d1+mid)^<>(d2+mid)^) then exit(false);
 if(mid and $1=1) then
  begin
   if((d1+mid2)^<>(d2+mid2)^) then exit(false);
   if((d1+mid+mid2)^<>(d2+mid+mid2)^) then exit(false);
  end;
 while(i<=mid2)do
  begin
   if((d1+i-1)^<>(d2+i-1)^) then exit(false);
   if((d1+mid-i)^<>(d2+mid-i)^) then exit(false);
   if((d1+mid+i-1)^<>(d2+mid+i-1)^) then exit(false);
   if((d1+count-i)^<>(d2+count-i)^) then exit(false);
   inc(i);
  end;
 faststrcomp_segment:=true;
 {$ENDIF}
end;
function ld_create_name(i:SizeUint):string;
begin
 Result:='.'+Int_To_Hash(i);
end;
function ld_align(value:Natuint;align:Natuint):Natuint;
begin
 ld_align:=(value+align-1) and (not (align-1));
end;
function ld_align_floor(value:Natuint;align:Natuint):Natuint;
begin
 ld_align_floor:=value and (not (align-1));
end;
function ld_elf_hash(name:string):Dword;
var hash,x,pos,len:dword;
begin
 hash:=0; x:=0; pos:=1; len:=length(name);
 while(pos<=len)do
  begin
   hash:=hash shl 4+Byte(name[pos]);
   x:=hash and $F0000000;
   if(x<>0) then
    begin
     hash:=hash xor (x shr 24);
     hash:=hash and (not x);
    end;
   inc(pos);
  end;
 ld_elf_hash:=hash and $7FFFFFFF;
end;
function ld_calc_comple(value:Natint;bit:byte;signed:boolean=true):Natuint;
var i:byte;
    mask:Natuint;
    tempnum:Natuint;
begin
 if(value>=0) then exit(Natuint(value));
 if(signed) then
  begin
   mask:=0; for i:=1 to bit-1 do mask:=mask shl 1+1;
   tempnum:=not ((-value) and mask) and mask+1;
   if(tempnum>mask) then tempnum:=tempnum and mask;
   if(bit=64) then
   ld_calc_comple:=Natuint($8000000000000000)+tempnum
   else if(bit=32) then
   ld_calc_comple:=Natuint($80000000)+tempnum
   else
   ld_calc_comple:=1 shl (bit-1)+tempnum;
  end
 else exit(Natuint(-value));
end;
function ld_generate_formula(formula:array of string;bit:byte;mask:Natuint=0):ld_formula;
var i,len:Natuint;
    bool:boolean;
    OrgFormula:string;
    tempstr:string;
begin
 Result.isgotbase:=false; Result.isgotoffset:=false;
 Result.ispaged:=false; Result.isrelative:=false;
 if(length(formula)=0) then
  begin
   Result.item.count:=0; Result.bit:=0; Result.mask:=0; exit(Result);
  end;
 len:=length(formula); OrgFormula:=formula[0];
 for i:=2 to len do OrgFormula:=OrgFormula+formula[i-1];
 {Parse the formula}
 len:=length(orgformula); Result.item.count:=0; bool:=false;
 SetLength(Result.item.item,len); tempstr:='';
 for i:=1 to len do
  begin
   if(OrgFormula[i]='(') or (OrgFormula[i]=')') or (OrgFormula[i]='+')
   or(OrgFormula[i]='-') or (OrgFormula[i]='|') or (OrgFormula[i]=',') then
    begin
     if(bool) then
      begin
       if(Result.isgotbase=false) and (tempstr='G') and (OrgFormula[i]='(') then Result.isgotbase:=true
       else if(Result.isgotoffset=false) and (tempstr='G') then Result.isgotoffset:=true
       else if(Result.isgotbase=false) and ((tempstr='GOT')or(tempstr='GP'))and (OrgFormula[i]<>'(')
       then Result.isgotbase:=true
       else if(Result.isrelative=false) and
       ((tempstr='P')or(tempstr='PLT')or(tempstr='PC')or(tempstr='L'))
       then Result.isrelative:=true
       else if(Result.ispaged=false) and (tempstr='Page')
       then Result.ispaged:=true;
       Result.item.item[Result.item.count-1]:=tempstr;
      end;
     inc(Result.item.count);
     Result.item.item[Result.item.count-1]:=OrgFormula[i];
     bool:=false;
    end
   else if(bool=false) then
    begin
     inc(Result.item.count); tempstr:=OrgFormula[i]; bool:=true;
    end
   else
    begin
     tempstr:=tempstr+OrgFormula[i];
    end;
  end;
 if(bool) then
  begin
   if(Result.isgotbase=false) and (tempstr='G') then Result.isgotoffset:=true
   else if(Result.isgotoffset=false) and ((tempstr='GOT') or (tempstr='GP'))then Result.isgotbase:=true
   else if(Result.isrelative=false) and ((tempstr='P') or (tempstr='PLT')or(tempstr='PC')or(tempstr='L'))
   then Result.isrelative:=true
   else if(Result.ispaged=false) and (tempstr='Page') then Result.ispaged:=true;
   Result.item.item[Result.item.count-1]:=tempstr;
  end;
 {If the got exists,then add the value of global got count variable}
 if(Result.isgotbase) or (Result.isgotoffset) then inc(ldGotCount);
 {Set the mask and bit width}
 Result.bit:=bit; Result.mask:=mask;
end;
function ld_formula_check_got(formula:ld_formula):boolean;
begin
 ld_formula_check_got:=formula.isgotoffset or formula.isgotbase;
end;
procedure ld_formula_copy(const source:ld_formula;var dest:ld_formula);
var i:Natuint;
begin
 dest.bit:=source.bit; dest.mask:=source.mask; i:=1;
 SetLength(dest.item.item,source.item.count);
 while(i<=source.item.count)do
  begin
   dest.item.item[i-1]:=source.item.item[i-1]; inc(i);
  end;
 dest.item.count:=source.item.count;
end;
procedure ld_write_formula(formula:ld_formula);
var i:Natuint;
begin
 for i:=1 to formula.item.count do write(formula.item.item[i-1]); writeln;
end;
function ld_calculate_formula(formula:ld_formula;expression:array of string):Natint;
var map:ld_map;
    stack:ld_stack;
    i,j,k,len,len2:Natuint;
    tempstr:string;
    tempformula:ld_formula;
    tempresult,tempresult2:Natint;
    ps,pe:Natuint;
    funcname:string;
    funcvalue:Natint;
begin
 if(formula.item.count=0) then exit(0);
 len:=length(expression); map.count:=0;
 {Parse the expression}
 map.count:=0; SetLength(map.name,len); SetLength(map.value,len);
 for i:=1 to len do
  begin
   tempstr:=expression[i-1];
   len2:=length(tempstr); j:=1;
   while(j<=len2)do
    begin
     if(tempstr[j]='=') then break;
     inc(j);
    end;
   inc(map.count);
   map.name[map.count-1]:=Copy(tempstr,1,j-1);
   map.value[map.count-1]:=Copy(tempstr,j+1,len2-j);
   k:=1;
   while(k<=formula.item.count div 2+1)do
    begin
     if(map.name[map.count-1]=formula.item.item[k-1]) then break;
     if(map.name[map.count-1]=formula.item.item[formula.item.count-k]) then break;
     inc(k);
    end;
   if(k>formula.item.count div 2+1) then dec(map.count);
  end;
 {Stick the expression value to formula}
 tempformula:=formula;
 for i:=1 to tempformula.item.count do
  begin
   j:=1;
   while(j<=map.count)do
    begin
     if(i<tempformula.item.count) and (tempformula.item.item[i-1]=map.name[j-1])
     and (tempformula.item.item[i]<>'(') then
      begin
       tempformula.item.item[i-1]:=map.value[j-1];
      end
     else if(i=tempformula.item.count) and (tempformula.item.item[i-1]=map.name[j-1]) then
      begin
       tempformula.item.item[i-1]:=map.value[j-1];
      end;
     inc(j);
    end;
  end;
 {Generate the stack table}
 stack.count:=0;
 for i:=1 to tempformula.item.count do
  begin
   if(tempformula.item.item[i-1]='(') then
    begin
     inc(stack.count);
     SetLength(stack.left,stack.count);
     stack.left[stack.count-1]:=i;
     SetLength(stack.right,stack.count);
     stack.right[stack.count-1]:=0;
    end
   else if(tempformula.item.item[i-1]=')') then
    begin
     j:=stack.count;
     while(j>0)do
      begin
       if(stack.right[j-1]=0) then
        begin
         stack.right[j-1]:=i; break;
        end;
       dec(j);
      end;
     if(j=0) then exit(0);
    end;
  end;
 {Calculate the item inside bracket}
 while(stack.count>0)do
  begin
   ps:=stack.left[stack.count-1]+1; pe:=stack.right[stack.count-1]-1;
   if(ps>2) and (tempformula.item.item[ps-3]<>'(') and (tempformula.item.item[ps-3]<>')')
   and (tempformula.item.item[ps-3]<>'+') and (tempformula.item.item[ps-3]<>'-')
   and (tempformula.item.item[ps-3]<>'|') and (tempformula.item.item[ps-3]<>',')
   then
    begin
     funcname:=tempformula.item.item[ps-3]; funcvalue:=0;
     j:=1;
     while(j<=map.count)do
      begin
       if(funcname=map.name[j-1]) then break;
       inc(j);
      end;
     if(j<=map.count) then funcvalue:=StrToInt(map.value[j-1]);
    end
   else
    begin
     funcname:=''; funcvalue:=0;
    end;
   j:=ps; tempresult:=StrToInt(tempformula.item.item[ps-1]);
   while(j<pe)do
    begin
     if(tempformula.item.item[j+1]='0') then
      begin
       inc(j,2); continue;
      end;
     if(tempformula.item.item[j]='+') then
      begin
       tempresult:=tempresult+StrToInt(tempformula.item.item[j+1]);
      end
     else if(tempformula.item.item[j]='-') then
      begin
       tempresult:=tempresult-StrToInt(tempformula.item.item[j+1]);
      end
     else if(tempformula.item.item[j]=',') then
      begin
       tempresult:=tempresult+StrToInt(tempformula.item.item[j+1]);
      end
     else if(tempformula.item.item[j]='|') then
      begin
       tempresult2:=StrToInt(tempformula.item.item[j-1]);
       while(j<pe) and (tempformula.item.item[j+2]='|') do
        begin
         tempresult2:=tempresult2 or StrToInt(tempformula.item.item[j+1]);
         inc(j,2);
        end;
       tempresult:=tempresult+tempresult2;
       continue;
      end;
     inc(j,2);
    end;
   if(funcname='GDAT') then
    begin
     Delete(tempformula.item.item,ps-3,pe-ps+4);
     dec(tempformula.item.count,pe-ps+3);
     Insert(IntToStr(funcvalue),tempformula.item.item,ps-3);
    end
   else if(funcname='GOT') or
   (funcname='G') or (funcname='B') or (funcname='GTLSIDX') or (funcname='PLT')
   or(funcname='Delta') then
    begin
     Delete(tempformula.item.item,ps-3,pe-ps+4);
     dec(tempformula.item.count,pe-ps+3);
     Insert(IntToStr(funcvalue+tempresult),tempformula.item.item,ps-3);
    end
   else if(funcname='Indirect') or (faststrcomp(funcname,'IFUNC_RESOLVER'))
   or (faststrcomp(funcname,'ifunc_resolver')) or (funcname='GLDM')
   or (funcname='DTPREL') or (funcname='TPREL') then
    begin
     Delete(tempformula.item.item,ps-3,pe-ps+4);
     dec(tempformula.item.count,pe-ps+3);
     Insert(IntToStr(tempresult+funcvalue),tempformula.item.item,ps-3);
    end
   else if(funcname='Page') then
    begin
     Delete(tempformula.item.item,ps-3,pe-ps+4);
     dec(tempformula.item.count,pe-ps+3);
     Insert(IntToStr(ld_align_floor(tempresult,$1000)),tempformula.item.item,ps-3);
    end
   else if(funcname='Alignmax') then
    begin
     Delete(tempformula.item.item,ps-3,pe-ps+4);
     dec(tempformula.item.count,pe-ps+3);
     Insert(IntToStr(ld_align_floor(tempresult,$100000000)),tempformula.item.item,ps-3);
    end
   else if(funcname='') then
    begin
     Delete(tempformula.item.item,pe-1,1);
     Delete(tempformula.item.item,ps-3,2);
     dec(tempformula.item.count,3);
     Insert(IntToStr(tempresult),tempformula.item.item,ps-3);
    end;
   stack.count:=0;
   for j:=1 to tempformula.item.count do
    begin
     if(tempformula.item.item[j-1]='(') then
      begin
       inc(stack.count);
       SetLength(stack.left,stack.count);
       stack.left[stack.count-1]:=j;
       SetLength(stack.right,stack.count);
       stack.right[stack.count-1]:=0;
      end
     else if(tempformula.item.item[j-1]=')') then
      begin
       k:=stack.count;
       while(k>0)do
        begin
         if(stack.right[k-1]=0) then
          begin
           stack.right[k-1]:=j; break;
          end;
         dec(k);
        end;
       if(k=0) then exit(0);
      end;
    end;
  end;
 {Calculate the rest}
 j:=1; pe:=length(tempformula.item.item);
 if(pe=0) then exit(0);
 tempresult:=StrToInt(tempformula.item.item[0]);
 if(pe=1) then exit(tempresult);
 while(j<pe)do
  begin
   if(tempformula.item.item[j]='+') then
    begin
     tempresult:=tempresult+StrToInt(tempformula.item.item[j+1]);
    end
   else if(tempformula.item.item[j]='-') then
    begin
     tempresult:=tempresult-StrToInt(tempformula.item.item[j+1]);
    end
   else if(tempformula.item.item[j]='|') then
    begin
     tempresult2:=StrToInt(tempformula.item.item[j-1]);
     while(j<pe) and (tempformula.item.item[j+2]='|') do
      begin
       tempresult2:=tempresult2 or StrToInt(tempformula.item.item[j+1]);
       inc(j,2);
      end;
     tempresult:=tempresult+tempresult2;
     continue;
    end;
   inc(j,2);
  end;
 Result:=tempresult;
end;
procedure ld_io_read(fn:string;pos:natuint;var buf;bufsize:natuint);
var fs:TFileStream;
begin
 fs:=TFileStream.Create(fn,fmOpenRead);
 fs.Seek(pos-1,0);
 fs.Read(buf,bufsize);
 fs.Free;
end;
procedure ld_io_write(fn:String;pos:natuint;const buf;bufsize:natuint);
var fs:TFileStream;
begin
 if(FileExists(fn)) then fs:=TFileStream.Create(fn,fmOpenWrite)
 else fs:=TFileStream.Create(fn,fmCreate);
 fs.Seek(pos-1,0);
 fs.Write(buf,bufsize);
 fs.Free;
end;
function ld_io_get_size(fn:string):dword;
var fs:TFileStream;
begin
 fs:=TFileStream.Create(fn,fmOpenRead);
 ld_io_get_size:=fs.Size;
 fs.Free;
end;
function ld_read_file(fn:string):ld_file;
begin
 Result.Size:=ld_io_get_size(fn);
 Result.Content:=tydq_getmem(Result.Size);
 ld_io_read(fn,1,Result.Content^,Result.Size);
end;
function ld_cutout_memory(source:Pointer;memstart,memend:Natuint):Pointer;
begin
 Result:=tydq_getmem(memend-memstart+1);
 tydq_move(source,Result,memend-memstart+1);
end;
procedure ld_write_file(fn:string;ldf:ld_file);
begin
 ld_io_write(fn,1,ldf.Content^,ldf.Size);
end;
function ld_get_archive_file_offset(content:Pointer;totalsize:Natuint;index:Natuint):ld_file_offset;
var offset,i,j,k:Natuint;
    ArchiveHeader:elf_archive_file_header;
    tempstr:string;
    tempsize:Natuint;
begin
 offset:=8; Result.offset:=0; Result.Size:=0; i:=1;
 while(i<=index)do
  begin
   ArchiveHeader:=Pelf_archive_file_header(content+offset)^;
   {Analyze the File Name}
   tempstr:='';
   for j:=1 to 16 do
    begin
     tempstr:=tempstr+ArchiveHeader.ArchiveName[j];
     if(ArchiveHeader.ArchiveName[j]='/') and (j<16) and (ArchiveHeader.ArchiveName[j+1]=' ') then break;
     if(ArchiveHeader.ArchiveName[j]='/') and (j=16) then break;
    end;
   tempsize:=0;
   for j:=1 to 10 do
    begin
     if(ArchiveHeader.ArchiveSize[j-1]=' ') then break;
     tempsize:=tempsize*10+Byte(ArchiveHeader.ArchiveSize[j-1])-Byte('0');
    end;
   if(tempstr='/') then
    begin
     inc(offset,sizeof(ArchiveHeader)+tempsize); continue;
    end
   else if(Copy(tempstr,1,1)='/') then
    begin
     tempstr:=Trim(tempstr);
     k:=StrToInt(Copy(tempstr,2,length(tempstr)-1));
     inc(offset,k); tempstr:='';
     while(PChar(content+offset)^<>'/') do
      begin
       tempstr:=tempstr+PChar(content+offset)^; inc(offset);
      end;
    end;
   if(offset>=totalsize) then exit(Result);
   inc(i);
  end;
 Result.filename:=tempstr; Result.offset:=offset; Result.Size:=totalsize;
end;
function ld_aarch64_stub_add(rd:byte;imm12:dword;sh:boolean;sf:boolean):dword;
var c1,c2,c3,c4:dword;
begin
 c1:=rd and $1F; c2:=imm12 and $FFF;
 if(sh) then c3:=1 shl 22 else c3:=0;
 if(sf) then c4:=1 shl 31 else c4:=0;
 ld_aarch64_stub_add:=c1+c1 shl 5+c2 shl 10+c3+c4+1 shl 24+1 shl 28;
end;
function ld_aarch64_stub_sub(rd:byte;imm12:dword;sh:boolean;sf:boolean):dword;
var c1,c2,c3,c4:dword;
begin
 c1:=rd and $1F; c2:=imm12 and $FFF;
 if(sh) then c3:=1 shl 22 else c3:=0;
 if(sf) then c4:=1 shl 31 else c4:=0;
 ld_aarch64_stub_sub:=c1+c1 shl 5+c2 shl 10+c3+c4+1 shl 24+1 shl 28+1 shl 30;
end;
function ld_riscv_check_addi(command:dword):boolean;
begin
 if(Pld_riscv_i_type(@command)^.Operandcode=$13) or
 (Pld_riscv_i_type(@command)^.Function3=0) then exit(true);
 ld_riscv_check_addi:=false;
end;
function ld_riscv_check_ld(command:dword):boolean;
begin
 if(Pld_riscv_i_type(@command)^.Operandcode=$03) then exit(true);
 ld_riscv_check_ld:=false;
end;
function ld_riscv_check_jalr(command:dword):boolean;
begin
 if(Pld_riscv_i_type(@command)^.Operandcode=$67) and (Pld_riscv_i_type(@command)^.Function3=$0)
 then exit(true);
 ld_riscv_check_jalr:=false;
end;
function ld_riscv_check_cld(command:word):boolean;
begin
 if(Pld_riscv_ci_type(@command)^.CompressOpcode=3) and
 (Pld_riscv_ci_type(@command)^.Compress0=0) then exit(true);
 ld_riscv_check_cld:=false;
end;
function ld_riscv_stub_addi(rd,rs:byte;imm12:smallint):dword;
var instruction:ld_riscv_i_type;
begin
 instruction.Operandcode:=$13;
 instruction.SourceRegister:=rd and $1F;
 instruction.DestinationRegister:=rs and $1F;
 instruction.Function3:=0;
 if(Imm12<0) then
 instruction.ImmdiateNumber:=ld_calc_comple(Imm12,12,true)
 else
 instruction.ImmdiateNumber:=Imm12;
 ld_riscv_stub_addi:=Pdword(@instruction)^;
end;
function ld_loongarch_check_pcaddi(Command:dword):byte;
begin
 ld_loongarch_check_pcaddi:=Pld_loongarch_pcaddi(@Command)^.Opcode-ld_loongarch_pcaddi_opcode;
end;
procedure ld_calculate_behind(var Address:dynqwordarray;
Index:dynwordarray;firstindex:word;distance:Int64);
var i,len:Natuint;
begin
 i:=1; len:=length(index);
 while(i<=len)do
  begin
   if(Index[i-1]>=firstindex) then Address[i-1]:=Address[i-1]+distance;
   inc(i);
  end;
end;
procedure ld_handle_dynamic_library(fn:dynstrarray);
var i:Natuint;
begin
 i:=1;
 LdDynamicLibrary.Count:=length(fn);
 LdDynamicLibrary.StringTotalLength:=0;
 SetLength(ldDynamicLibrary.Name,length(fn));
 SetLength(ldDynamicLibrary.NameLength,length(fn));
 SetLength(ldDynamicLibrary.NamePosition,length(fn));
 while(i<=length(fn))do
  begin
   LdDynamicLibrary.Name[i-1]:=fn[i-1];
   LdDynamicLibrary.NameLength[i-1]:=length(fn[i-1]);
   LdDynamicLibrary.NamePosition[i-1]:=LdDynamicLibrary.StringTotalLength;
   LdDynamicLibrary.StringTotalLength:=LdDynamicLibrary.StringTotalLength+length(fn[i-1])+1;
   inc(i);
  end;
end;
function ld_generate_file_list(fn:dynstrarray):ld_object_file_list;
var i,j,len:natuint;
    ldf,ldf2:ld_file;
    objptr:elf_object_file;
    isarchive:boolean;
    fileoffset:ld_file_offset;
    temptype:dword;
    tempsize:dword;
label label1,label3,label4,label5;
begin
 {Handle the original file}
 len:=length(fn); Result.Count:=0; Result.bit:=0; isarchive:=false;
 for i:=1 to len do
  begin
   isarchive:=false;
   if(FileExists(fn[i-1])=false) then continue;
   ldf:=ld_read_file(fn[i-1]);
   label1:
   {Initialize the object file}
   objptr.strtabptr:=nil; objptr.shstrtabptr:=nil; objptr.symptr.sym32:=nil;
   {Read the object file}
   if(elf_check_archive_signature(PChar(ldf.Content))) and (isarchive=false) then
    begin
     isarchive:=true; j:=0;
    end;
   if(isarchive) then
    begin
     inc(j);
     fileoffset:=ld_get_archive_file_offset(ldf.Content,ldf.Size,j);
     if(fileoffset.offset=0) then continue;
     ldf2.Content:=ld_cutout_memory(ldf.Content,fileoffset.offset,fileoffset.Size);
     ldf2.Size:=fileoffset.Size;
     goto label4;
    end;
   label3:
   inc(Result.count);
   SetLength(Result.item,Result.count);
   Result.item[Result.count-1].Content:=ldf.Content;
   Result.item[Result.count-1].Size:=ldf.Size;
   Result.item[Result.count-1].Fn:=fn[i-1];
   objptr.HdrPtr.hdr32:=Pointer(ldf.content);
   {Check the signature is ELF file}
   if(elf_check_signature(objptr.HdrPtr.hdr32^.elf_id)=false) then
    begin
     writeln('ERROR:File is not ELF.');
     readln;
     abort;
    end;
   {Check the bit is 32bit or 64bit}
   objptr.bit:=elf_get_class(objptr.HdrPtr.hdr32^.elf_id);
   if(Result.bit<>0) and (objptr.bit+1<>Result.bit) then
    begin
     writeln('ERROR:File bits is not same.');
     readln;
     abort;
    end
   else if(Result.bit=0) then Result.bit:=objptr.bit+1;
   {Execute two sort of code}
   objptr.relcount:=0; objptr.relacount:=0;
   if(objptr.bit=1) then
    begin
     ldarch:=objptr.HdrPtr.hdr32^.elf_machine;
     ldbit:=elf_get_class(objptr.HdrPtr.hdr32^.elf_id);
     if(objptr.HdrPtr.hdr32^.elf_type<>1) then
      begin
       writeln('ERROR:File is not object or relocatable file.');
       readln;
       abort;
      end;
     objptr.SecPtr.sec32ptr:=Pointer(ldf.content+objptr.HdrPtr.hdr32^.elf_section_header_offset);
     objptr.CntPtr:=tydq_getmem(sizeof(Pointer)*objptr.HdrPtr.hdr32^.elf_section_header_number);
     for j:=1 to objptr.HdrPtr.hdr32^.elf_section_header_number do
      begin
       temptype:=Pelf32_section_header(objptr.SecPtr.sec32ptr+j-1)^.section_header_type;
       tempsize:=Pelf32_section_header(objptr.SecPtr.sec32ptr+j-1)^.section_header_size;
       if(temptype=elf_section_type_null)or(tempsize=0) then
        begin
         (objptr.CntPtr+j-1)^.b:=nil;
        end
       else
        begin
         (objptr.CntPtr+j-1)^.b:=
         ldf.content+Pelf32_section_header(objptr.SecPtr.sec32ptr+j-1)^.section_header_offset;
        end;
       if(temptype=elf_section_type_strtab)and(objptr.strtabptr=nil) then
        begin
         objptr.strtabptr:=
         Pointer(ldf.content+Pelf32_section_header(objptr.SecPtr.sec32ptr+j-1)^.section_header_offset);
        end
       else if(temptype=elf_section_type_strtab)and(objptr.shstrtabptr=nil) then
        begin
         objptr.shstrtabptr:=
         Pointer(ldf.content+Pelf32_section_header(objptr.SecPtr.sec32ptr+j-1)^.section_header_offset);
        end
       else if(temptype=elf_section_type_symtab)and(objptr.symptr.sym32=nil) then
        begin
         objptr.symptr.sym32:=
         Pointer(ldf.content+Pelf32_section_header(objptr.SecPtr.sec32ptr+j-1)^.section_header_offset);
         objptr.symcount:=Pelf32_section_header(objptr.SecPtr.sec32ptr+j-1)^.section_header_size
         div sizeof(elf32_symbol_table_entry);
        end
       else if(temptype=elf_section_type_reloc) then
        begin
         inc(objptr.relcount);
        end
       else if(temptype=elf_section_type_rela) then
        begin
         inc(objptr.relacount);
        end;
      end;
    end
   else if(objptr.bit=2) then
    begin
     ldarch:=objptr.HdrPtr.hdr64^.elf_machine;
     ldbit:=elf_get_class(objptr.HdrPtr.hdr64^.elf_id);
     if(objptr.HdrPtr.hdr64^.elf_type>=elf_type_executable) then
      begin
       writeln('ERROR:File is not object or relocatable file.');
       readln;
       abort;
      end;
     objptr.SecPtr.sec64ptr:=Pointer(ldf.content+objptr.HdrPtr.hdr64^.elf_section_header_offset);
     objptr.CntPtr:=tydq_getmem(sizeof(Pointer)*objptr.HdrPtr.hdr64^.elf_section_header_number);
     for j:=1 to objptr.HdrPtr.hdr64^.elf_section_header_number do
      begin
       temptype:=Pelf64_section_header(objptr.SecPtr.sec64ptr+j-1)^.section_header_type;
       tempsize:=Pelf64_section_header(objptr.SecPtr.sec64ptr+j-1)^.section_header_size;
       if(temptype=elf_section_type_null)or(tempsize=0) then
        begin
         (objptr.CntPtr+j-1)^.b:=nil;
        end
       else
        begin
         (objptr.CntPtr+j-1)^.b:=
         ldf.content+Pelf64_section_header(objptr.SecPtr.sec64ptr+j-1)^.section_header_offset;
        end;
       if(temptype=elf_section_type_strtab)and(objptr.strtabptr=nil) then
        begin
         objptr.strtabptr:=
         Pointer(ldf.content+Pelf64_section_header(objptr.SecPtr.sec64ptr+j-1)^.section_header_offset);
        end
       else if(temptype=elf_section_type_strtab)and(objptr.shstrtabptr=nil) then
        begin
         objptr.shstrtabptr:=
         Pointer(ldf.content+Pelf64_section_header(objptr.SecPtr.sec64ptr+j-1)^.section_header_offset);
        end
       else if(temptype=elf_section_type_symtab)and(objptr.symptr.sym64=nil) then
        begin
         objptr.symptr.sym64:=
         Pointer(ldf.content+Pelf64_section_header(objptr.SecPtr.sec64ptr+j-1)^.section_header_offset);
         objptr.symcount:=Pelf64_section_header(objptr.SecPtr.sec64ptr+j-1)^.section_header_size
         div sizeof(elf64_symbol_table_entry);
        end
       else if(temptype=elf_section_type_reloc) then
        begin
         inc(objptr.relcount);
        end
       else if(temptype=elf_section_type_rela) then
        begin
         inc(objptr.relacount);
        end;
      end;
    end;
   if(isarchive=false) then goto label5;
   {Parse the object file in Archive file}
   label4:
   inc(Result.count);
   SetLength(Result.item,Result.count);
   Result.item[Result.count-1].Content:=ldf2.Content;
   Result.item[Result.count-1].Size:=ldf2.Size;
   Result.item[Result.count-1].Fn:=fileoffset.filename;
   objptr.HdrPtr.hdr32:=Pointer(ldf2.content);
   {Check the signature is ELF file}
   if(elf_check_signature(objptr.HdrPtr.hdr32^.elf_id)=false) then
    begin
     writeln('ERROR:File is not ELF.');
     readln;
     abort;
    end;
   {Check the bit is 32bit or 64bit}
   objptr.bit:=elf_get_class(objptr.HdrPtr.hdr32^.elf_id);
   if(Result.bit<>0) and (objptr.bit+1<>Result.bit) then
    begin
     writeln('ERROR:File bits is not same.');
     readln;
     abort;
    end
   else if(Result.bit=0) then Result.bit:=objptr.bit+1;
   {Execute two sort of code}
   if(objptr.bit=1) then
    begin
     ldarch:=objptr.HdrPtr.hdr32^.elf_machine;
     ldbit:=elf_get_class(objptr.HdrPtr.hdr32^.elf_id);
     if(objptr.HdrPtr.hdr32^.elf_type>=elf_type_executable) then
      begin
       writeln('ERROR:File is not object or relocatable file.');
       readln;
       abort;
      end;
     objptr.SecPtr.sec32ptr:=Pointer(ldf.content+objptr.HdrPtr.hdr32^.elf_section_header_offset);
     objptr.CntPtr:=tydq_getmem(sizeof(Pointer)*objptr.HdrPtr.hdr32^.elf_section_header_number);
     for j:=1 to objptr.HdrPtr.hdr32^.elf_section_header_number do
      begin
       temptype:=Pelf32_section_header(objptr.SecPtr.sec32ptr+j-1)^.section_header_type;
       tempsize:=Pelf32_section_header(objptr.SecPtr.sec32ptr+j-1)^.section_header_size;
       if(temptype=elf_section_type_null)or(tempsize=0) then
        begin
         (objptr.CntPtr+j-1)^.b:=nil;
        end
       else
        begin
         (objptr.CntPtr+j-1)^.b:=
         ldf.content+Pelf32_section_header(objptr.SecPtr.sec32ptr+j-1)^.section_header_offset;
        end;
       if(temptype=elf_section_type_strtab)and(objptr.strtabptr=nil) then
        begin
         objptr.strtabptr:=
         Pointer(ldf.content+Pelf32_section_header(objptr.SecPtr.sec32ptr+j-1)^.section_header_offset);
        end
       else if(temptype=elf_section_type_strtab)and(objptr.shstrtabptr=nil) then
        begin
         objptr.shstrtabptr:=
         Pointer(ldf.content+Pelf32_section_header(objptr.SecPtr.sec32ptr+j-1)^.section_header_offset);
        end
       else if(temptype=elf_section_type_symtab)and(objptr.symptr.sym32=nil) then
        begin
         objptr.symptr.sym32:=
         Pointer(ldf.content+Pelf32_section_header(objptr.SecPtr.sec32ptr+j-1)^.section_header_offset);
         objptr.symcount:=Pelf32_section_header(objptr.SecPtr.sec32ptr+j-1)^.section_header_size
         div sizeof(elf32_symbol_table_entry);
        end
       else if(temptype=elf_section_type_reloc) then
        begin
         inc(objptr.relcount);
        end
       else if(temptype=elf_section_type_rela) then
        begin
         inc(objptr.relacount);
        end;
      end;
    end
   else if(objptr.bit=2) then
    begin
     ldarch:=objptr.HdrPtr.hdr64^.elf_machine;
     ldbit:=elf_get_class(objptr.HdrPtr.hdr64^.elf_id);
     if(objptr.HdrPtr.hdr64^.elf_type>=elf_type_executable) then
      begin
       writeln('ERROR:File is not object or relocatable file.');
       readln;
       abort;
      end;
     objptr.SecPtr.sec64ptr:=Pointer(ldf.content+objptr.HdrPtr.hdr64^.elf_section_header_offset);
     objptr.CntPtr:=tydq_getmem(sizeof(Pointer)*objptr.HdrPtr.hdr64^.elf_section_header_number);
     for j:=1 to objptr.HdrPtr.hdr64^.elf_section_header_number do
      begin
       temptype:=Pelf64_section_header(objptr.SecPtr.sec64ptr+j-1)^.section_header_type;
       tempsize:=Pelf64_section_header(objptr.SecPtr.sec64ptr+j-1)^.section_header_size;
       if(temptype=elf_section_type_null)or(tempsize=0) then
        begin
         (objptr.CntPtr+j-1)^.b:=nil;
        end
       else
        begin
         (objptr.CntPtr+j-1)^.b:=
         ldf.content+Pelf64_section_header(objptr.SecPtr.sec64ptr+j-1)^.section_header_offset;
        end;
       if(temptype=elf_section_type_strtab)and(objptr.strtabptr=nil) then
        begin
         objptr.strtabptr:=
         Pointer(ldf.content+Pelf64_section_header(objptr.SecPtr.sec64ptr+j-1)^.section_header_offset);
        end
       else if(temptype=elf_section_type_strtab)and(objptr.shstrtabptr=nil) then
        begin
         objptr.shstrtabptr:=
         Pointer(ldf.content+Pelf64_section_header(objptr.SecPtr.sec64ptr+j-1)^.section_header_offset);
        end
       else if(temptype=elf_section_type_symtab)and(objptr.symptr.sym64=nil) then
        begin
         objptr.symptr.sym64:=
         Pointer(ldf.content+Pelf64_section_header(objptr.SecPtr.sec64ptr+j-1)^.section_header_offset);
         objptr.symcount:=Pelf64_section_header(objptr.SecPtr.sec64ptr+j-1)^.section_header_size
         div sizeof(elf64_symbol_table_entry);
        end
       else if(temptype=elf_section_type_reloc) then
        begin
         inc(objptr.relcount);
        end
       else if(temptype=elf_section_type_rela) then
        begin
         inc(objptr.relacount);
        end;
      end;
    end;
   label5:
   Result.item[Result.count-1].Ptr:=objptr;
   if(isarchive) then goto label1;
  end;
end;
procedure ld_free_object_file_list(var filelist:ld_object_file_list);
var i:Natuint;
begin
 for i:=1 to filelist.Count do
  begin
   tydq_FreeMem(filelist.item[i-1].Content);
  end;
 SetLength(filelist.item,0);
 filelist.Count:=0;
end;
procedure ld_handle_symbol_table(var middlelist:ld_object_file_temporary;EntryHash:Natuint;
SmartLinking:boolean;var symtable:ld_object_hash_table;var symsectable:ld_object_hash_table;
const relcount:Natuint;var reltable:ld_object_hash_table;
const relacount:Natuint;var relatable:ld_object_hash_table);
var i,j,k:Natuint;
    secarray:dynnatuintarray;
begin
 i:=ld_search_for_index(symtable,dynnatuintarray(middlelist.SymTable.SymbolNameHash),EntryHash);
 if(i<>0) and (middlelist.symTable.SymbolQuotedByMain[i-1]=false) then
  begin
   middlelist.symTable.SymbolQuotedByMain[i-1]:=true;
   secarray:=ld_search_for_index_array(symsectable,
   dynnatuintarray(middlelist.SymTable.SymbolSectionHash),middlelist.SymTable.SymbolSectionHash[i-1]);
   if(length(secarray)>1) then
    begin
     for j:=1 to length(secarray) do
      begin
       if(middlelist.SymTable.SymbolNameHash[i-1]<>middlelist.SymTable.SymbolNameHash[secarray[j-1]-1])
       and(middlelist.SymTable.SymbolSectionHash[i-1]=middlelist.SymTable.SymbolSectionHash[secarray[j-1]-1])
       and(middlelist.SymTable.SymbolQuotedByMain[secarray[j-1]-1]=false) then
        begin
         middlelist.SymTable.SymbolQuotedByMain[secarray[j-1]-1]:=true;
        end;
      end;
    end;
   if(relcount>0) then
   j:=ld_search_for_index(reltable,dynnatuintarray(middlelist.SecRelHash),
   middlelist.SymTable.SymbolSectionHash[i-1]) else j:=0;
   if(j<>0) then
    begin
     for k:=1 to middlelist.SecRel[j-1].SymCount do
      begin
       if(middlelist.SecRel[j-1].SymHash[k-1]<>0) then
       ld_handle_symbol_table(middlelist,middlelist.SecRel[j-1].SymHash[k-1],SmartLinking,symtable,
       symsectable,relcount,reltable,relacount,relatable);
      end;
    end;
   if(relacount>0) then
   j:=ld_search_for_index(relatable,dynnatuintarray(middlelist.SecRelaHash),
   middlelist.SymTable.SymbolSectionHash[i-1]) else j:=0;
   if(j<>0) then
    begin
     for k:=1 to middlelist.SecRela[j-1].SymCount do
      begin
       if(middlelist.SecRela[j-1].SymHash[k-1]<>0) then
       ld_handle_symbol_table(middlelist,middlelist.SecRela[j-1].SymHash[k-1],SmartLinking,symtable,
       symsectable,relcount,reltable,relacount,relatable);
      end;
    end;
  end;
end;
function ld_link_file(var objlist:ld_object_file_list;EntryName:string;
SmartLinking:boolean):ld_object_file_stage_2;
var i,j,k,m,n,a,b,c,d:natuint;
    tempptr:Pointer;
    offset:natuint;
    bool:boolean;
    {For Hashing Table}
    hashtable,hashtable2,hashtable3,hashtable4:ld_object_hash_table;
    tempvalue,tempvalue2:Natuint;
    EntryHash:Natuint;
    {For Creating Basic Section}
    Order:array of string;
    NeedSize:array of Natuint;
    NeedCount:array of Natuint;
    {For Stage 1 Only}
    templist1:ld_object_file_stage_1;
    ptr:elf_section_header_ptr;
    count:Natuint;
    size:Natuint;
    startaddr:Pointer;
    totalsymcount:Natuint;
    {For Stage 2 Only}
    middlelist:ld_object_file_temporary;
    templist2:ld_object_file_stage_2;
    partoffset,tempcount:Natuint;
    Value:Natuint;
    relcount,relacount,seccount:Natuint;
label label1;
begin
 Order:=['.text','.init_array','.init','.fini_array','.fini','.rodata','.data','.bss','.tdata','.tbss',
 '.debug_frame','.preinit_array'];
 EntryHash:=generate_hash_from_string(EntryName);
 SetLength(NeedSize,12); SetLength(NeedCount,12);
 {Generate the Object List to Stage 1}
 templist1.Count:=objlist.count; templist1.SecFlag:=0;
 SetLength(templist1.ObjFile,objlist.count); totalsymcount:=0;
 relcount:=0; relacount:=0; seccount:=0;
 for i:=1 to objlist.Count do
  begin
   ptr:=objlist.item[i-1].Ptr.SecPtr;
   templist1.ObjFile[i-1].SecRelCount:=0; templist1.ObjFile[i-1].SecRelaCount:=0;
   SetLength(templist1.ObjFile[i-1].SecRel,objlist.item[i-1].Ptr.relcount);
   SetLength(templist1.ObjFile[i-1].SecRela,objlist.item[i-1].Ptr.relacount);
   if(objlist.bit-1=1) then
    begin
     count:=objlist.item[i-1].Ptr.HdrPtr.hdr32^.elf_section_header_number;
     templist1.SecFlag:=templist1.SecFlag or objlist.item[i-1].Ptr.HdrPtr.hdr32^.elf_flags;
     {Handle the Symbol Table First}
     startaddr:=objlist.item[i-1].Ptr.symptr.sym32;
     tempptr:=startaddr+sizeof(elf32_symbol_table_entry); offset:=0;
     templist1.ObjFile[i-1].SymTable.SymbolCount:=objlist.item[i-1].Ptr.symcount-1;
     TempList1.ObjFile[i-1].SymTable.SymbolVaildForLink:=tydq_getmem(objlist.item[i-1].Ptr.symcount-1);
     SetLength(TempList1.ObjFile[i-1].SymTable.SymbolIndex,objlist.item[i-1].Ptr.symcount-1);
     SetLength(TempList1.ObjFile[i-1].SymTable.SymbolSection,objlist.item[i-1].Ptr.symcount-1);
     SetLength(TempList1.ObjFile[i-1].SymTable.SymbolName,objlist.item[i-1].Ptr.symcount-1);
     SetLength(TempList1.ObjFile[i-1].SymTable.SymbolBinding,objlist.item[i-1].Ptr.symcount-1);
     SetLength(TempList1.ObjFile[i-1].SymTable.SymbolSize,objlist.item[i-1].Ptr.symcount-1);
     SetLength(TempList1.ObjFile[i-1].SymTable.SymbolType,objlist.item[i-1].Ptr.symcount-1);
     SetLength(TempList1.ObjFile[i-1].SymTable.SymbolValue,objlist.item[i-1].Ptr.symcount-1);
     SetLength(TempList1.ObjFile[i-1].SymTable.SymbolVisible,objlist.item[i-1].Ptr.symcount-1);
     for k:=1 to objlist.item[i-1].Ptr.symcount-1 do
      begin
       TempList1.ObjFile[i-1].SymTable.SymbolType[k-1]:=
       elf_symbol_type_type(Pelf32_symbol_table_entry(tempptr+offset)^.symbol_info);
       TempList1.ObjFile[i-1].SymTable.SymbolIndex[k-1]:=
       Pelf32_symbol_table_entry(tempptr+offset)^.symbol_section_index;
       if(TempList1.ObjFile[i-1].SymTable.SymbolIndex[k-1]<>0)
       and(TempList1.ObjFile[i-1].SymTable.SymbolIndex[k-1]<=Word($FFF0)) then
        begin
         TempList1.ObjFile[i-1].SymTable.SymbolSection[k-1]:=
         elf_get_name(objlist.item[i-1].Ptr.shstrtabptr,
         Pelf32_section_header(ptr.sec32ptr+
         Pelf32_symbol_table_entry(tempptr+offset)^.symbol_section_index)^.section_header_name);
         TempList1.ObjFile[i-1].SymTable.SymbolSection[k-1]:=
         TempList1.ObjFile[i-1].SymTable.SymbolSection[k-1]+ld_create_name(i);
        end
       else
        begin
         TempList1.ObjFile[i-1].SymTable.SymbolSection[k-1]:='';
        end;
       if(TempList1.ObjFile[i-1].SymTable.SymbolType[k-1]<>elf_symbol_type_section) then
        begin
         TempList1.ObjFile[i-1].SymTable.SymbolName[k-1]:=
         elf_get_name(objlist.item[i-1].Ptr.strtabptr,
         Pelf32_symbol_table_entry(tempptr+offset)^.symbol_name);
         if(Copy(TempList1.ObjFile[i-1].SymTable.SymbolName[k-1],1,1)='.') then
          begin
           TempList1.ObjFile[i-1].SymTable.SymbolName[k-1]:=
           TempList1.ObjFile[i-1].SymTable.SymbolName[k-1]+ld_create_name(totalsymcount+k);
          end;
        end
       else
        begin
         TempList1.ObjFile[i-1].SymTable.SymbolName[k-1]:=
         TempList1.ObjFile[i-1].SymTable.SymbolSection[k-1];
        end;
       TempList1.ObjFile[i-1].SymTable.SymbolVaildForLink[k-1]:=
       ((TempList1.ObjFile[i-1].SymTable.SymbolType[k-1]>0)
       or(TempList1.ObjFile[i-1].SymTable.SymbolIndex[k-1]<>0))
       and(TempList1.ObjFile[i-1].SymTable.SymbolIndex[k-1]<=Word($FFF0));
       if(TempList1.ObjFile[i-1].SymTable.SymbolVaildForLink[k-1]=false) then
        begin
         inc(offset,sizeof(elf32_symbol_table_entry)); continue;
        end;
       TempList1.ObjFile[i-1].SymTable.SymbolBinding[k-1]:=
       elf_symbol_type_bind(Pelf32_symbol_table_entry(tempptr+offset)^.symbol_info);
       TempList1.ObjFile[i-1].SymTable.SymbolSize[k-1]:=
       Pelf32_symbol_table_entry(tempptr+offset)^.symbol_size;
       TempList1.ObjFile[i-1].SymTable.SymbolVisible[k-1]:=
       elf_symbol_type_visibility(Pelf32_symbol_table_entry(tempptr+offset)^.symbol_other);
       TempList1.ObjFile[i-1].SymTable.SymbolValue[k-1]:=
       Pelf32_symbol_table_entry(tempptr+offset)^.symbol_value;
       inc(offset,sizeof(elf32_symbol_table_entry));
      end;
     inc(totalsymcount,objlist.item[i-1].Ptr.symcount);
     TempList1.ObjFile[i-1].SecCount:=count;
     SetLength(TempList1.ObjFile[i-1].SecUsed,count);
     SetLength(TempList1.ObjFile[i-1].SecName,count);
     SetLength(TempList1.ObjFile[i-1].SecSize,count);
     SetLength(TempList1.ObjFile[i-1].SecContent,count);
     SetLength(TempList1.ObjFile[i-1].SecNowIndex,count);
     SetLength(TempList1.ObjFile[i-1].SecNowPos,count);
     for j:=1 to count do
      begin
       Templist1.ObjFile[i-1].SecUsed[j-1]:=false;
       size:=Pelf32_section_header(ptr.sec32ptr+j-1)^.section_header_size;
       if(size=0) then continue;
       startaddr:=(objlist.item[i-1].Ptr.CntPtr+j-1)^.b;
       TempList1.ObjFile[i-1].SecName[j-1]:=elf_get_name(
       objlist.item[i-1].Ptr.shstrtabptr,Pelf32_section_header(ptr.sec32ptr+j-1)^.section_header_name);
       TempList1.ObjFile[i-1].SecName[j-1]:=TempList1.ObjFile[i-1].SecName[j-1]+ld_create_name(i);
       for k:=1 to length(Order) do
        begin
         if(faststrcomp_segment(TempList1.ObjFile[i-1].SecName[j-1],1,length(Order[k-1]),
         Order[k-1])) then
          begin
           inc(NeedSize[k-1],size); inc(NeedCount[k-1],1);
           TempList1.ObjFile[i-1].SecType[j-1]:=k;
           break;
          end;
        end;
       TempList1.ObjFile[i-1].SecSize[j-1]:=size;
       if(startaddr=nil) then continue;
       if(startaddr<>nil) and
       (Pelf32_section_header(ptr.sec32ptr+j-1)^.section_header_type=elf_section_type_progbit) then
        begin
         TempList1.ObjFile[i-1].SecContent[j-1]:=startaddr; inc(seccount); continue;
        end
       else
        begin
         if(Pelf32_section_header(ptr.sec32ptr+j-1)^.section_header_type=elf_section_type_nobit) then
         inc(seccount);
         TempList1.ObjFile[i-1].SecContent[j-1]:=nil;
        end;
       if(Pelf32_section_header(ptr.sec32ptr+j-1)^.section_header_type=elf_section_type_reloc) then
        begin
         tempptr:=startaddr; offset:=0;
         inc(templist1.ObjFile[i-1].SecRelCount);
         templist1.ObjFile[i-1].SecRel[templist1.ObjFile[i-1].SecRelCount-1].SymSecName:=
         elf_get_name(objlist.item[i-1].Ptr.shstrtabptr,
         Pelf32_section_header(ptr.sec32ptr+
         Pelf32_section_header(ptr.sec32ptr+j-1)^.section_header_info-1)^.section_header_name);
         templist1.ObjFile[i-1].SecRel[templist1.ObjFile[i-1].SecRelCount-1].SymSecName:=
         templist1.ObjFile[i-1].SecRel[templist1.ObjFile[i-1].SecRelCount-1].SymSecName
         +ld_create_name(i);
         SetLength(templist1.ObjFile[i-1].SecRel[templist1.ObjFile[i-1].SecRelCount-1].Symbol,
         TempList1.ObjFile[i-1].SecSize[j-1] shr 3);
         SetLength(templist1.ObjFile[i-1].SecRel[templist1.ObjFile[i-1].SecRelCount-1].SymType,
         TempList1.ObjFile[i-1].SecSize[j-1] shr 3);
         SetLength(templist1.ObjFile[i-1].SecRel[templist1.ObjFile[i-1].SecRelCount-1].SymOffset,
         TempList1.ObjFile[i-1].SecSize[j-1] shr 3);
         templist1.ObjFile[i-1].SecRel[templist1.ObjFile[i-1].SecRelCount-1].SymCount:=
         TempList1.ObjFile[i-1].SecSize[j-1] shr 3;
         for k:=1 to TempList1.ObjFile[i-1].SecSize[j-1] shr 3 do
          begin
           templist1.ObjFile[i-1].SecRel[templist1.ObjFile[i-1].SecRelCount-1].Symbol[k-1]:=
           elf32_reloc_symbol(Pelf32_rel(tempptr+offset)^.Info);
           templist1.ObjFile[i-1].SecRel[templist1.ObjFile[i-1].SecRelCount-1].SymType[k-1]:=
           elf32_reloc_type(Pelf32_rel(tempptr+offset)^.Info);
           templist1.ObjFile[i-1].SecRel[templist1.ObjFile[i-1].SecRelCount-1].SymOffset[k-1]:=
           Pelf32_rel(tempptr+offset)^.Offset;
           inc(offset,8);
          end;
         inc(relcount);
        end
       else if(Pelf32_section_header(ptr.sec32ptr+j-1)^.section_header_type=elf_section_type_rela) then
        begin
         tempptr:=startaddr; offset:=0;
         inc(templist1.ObjFile[i-1].SecRelaCount);
         templist1.ObjFile[i-1].SecRela[templist1.ObjFile[i-1].SecRelaCount-1].SymSecName:=
         elf_get_name(objlist.item[i-1].Ptr.shstrtabptr,
         Pelf32_section_header(ptr.sec32ptr+
         Pelf32_section_header(ptr.sec32ptr+j-1)^.section_header_info)^.section_header_name);
         templist1.ObjFile[i-1].SecRela[templist1.ObjFile[i-1].SecRelaCount-1].SymSecName:=
         templist1.ObjFile[i-1].SecRela[templist1.ObjFile[i-1].SecRelaCount-1].SymSecName+
         ld_create_name(i);
         SetLength(templist1.ObjFile[i-1].SecRela[templist1.ObjFile[i-1].SecRelaCount-1].Symbol,
         TempList1.ObjFile[i-1].SecSize[j-1] div 12);
         SetLength(templist1.ObjFile[i-1].SecRela[templist1.ObjFile[i-1].SecRelaCount-1].SymType,
         TempList1.ObjFile[i-1].SecSize[j-1] div 12);
         SetLength(templist1.ObjFile[i-1].SecRela[templist1.ObjFile[i-1].SecRelaCount-1].SymOffset,
         TempList1.ObjFile[i-1].SecSize[j-1] div 12);
         templist1.ObjFile[i-1].SecRela[templist1.ObjFile[i-1].SecRelaCount-1].SymCount:=
         TempList1.ObjFile[i-1].SecSize[j-1] div 12;
         SetLength(templist1.ObjFile[i-1].SecRela[templist1.ObjFile[i-1].SecRelaCount-1].SymAddend,
         TempList1.ObjFile[i-1].SecSize[j-1] div 12);
         for k:=1 to TempList1.ObjFile[i-1].SecSize[j-1] div 12 do
          begin
           templist1.ObjFile[i-1].SecRela[templist1.ObjFile[i-1].SecRelaCount-1].Symbol[k-1]:=
           elf32_reloc_symbol(Pelf32_rela(tempptr+offset)^.Info);
           templist1.ObjFile[i-1].SecRela[templist1.ObjFile[i-1].SecRelaCount-1].SymType[k-1]:=
           elf32_reloc_type(Pelf32_rela(tempptr+offset)^.Info);
           templist1.ObjFile[i-1].SecRela[templist1.ObjFile[i-1].SecRelaCount-1].SymOffset[k-1]:=
           Pelf32_rela(tempptr+offset)^.Offset;
           templist1.ObjFile[i-1].SecRela[templist1.ObjFile[i-1].SecRelaCount-1].SymAddend[k-1]:=
           Pelf32_rela(tempptr+offset)^.Addend;
           inc(offset,12);
          end;
         inc(relacount);
        end;
      end;
    end
   else if(objlist.bit-1=2) then
    begin
     count:=objlist.item[i-1].Ptr.HdrPtr.hdr64^.elf_section_header_number;
     templist1.SecFlag:=templist1.SecFlag or objlist.item[i-1].Ptr.HdrPtr.hdr64^.elf_flags;
     {Handle the Symbol Table First}
     startaddr:=objlist.item[i-1].Ptr.symptr.sym64;
     tempptr:=startaddr+sizeof(elf64_symbol_table_entry); offset:=0;
     templist1.ObjFile[i-1].SymTable.SymbolCount:=objlist.item[i-1].Ptr.symcount-1;
     TempList1.ObjFile[i-1].SymTable.SymbolVaildForLink:=tydq_getmem(objlist.item[i-1].Ptr.symcount-1);
     SetLength(TempList1.ObjFile[i-1].SymTable.SymbolIndex,objlist.item[i-1].Ptr.symcount-1);
     SetLength(TempList1.ObjFile[i-1].SymTable.SymbolSection,objlist.item[i-1].Ptr.symcount-1);
     SetLength(TempList1.ObjFile[i-1].SymTable.SymbolName,objlist.item[i-1].Ptr.symcount-1);
     SetLength(TempList1.ObjFile[i-1].SymTable.SymbolBinding,objlist.item[i-1].Ptr.symcount-1);
     SetLength(TempList1.ObjFile[i-1].SymTable.SymbolSize,objlist.item[i-1].Ptr.symcount-1);
     SetLength(TempList1.ObjFile[i-1].SymTable.SymbolType,objlist.item[i-1].Ptr.symcount-1);
     SetLength(TempList1.ObjFile[i-1].SymTable.SymbolValue,objlist.item[i-1].Ptr.symcount-1);
     SetLength(TempList1.ObjFile[i-1].SymTable.SymbolVisible,objlist.item[i-1].Ptr.symcount-1);
     for k:=1 to objlist.item[i-1].Ptr.symcount-1 do
      begin
       TempList1.ObjFile[i-1].SymTable.SymbolType[k-1]:=
       elf_symbol_type_type(Pelf64_symbol_table_entry(tempptr+offset)^.symbol_info);
       TempList1.ObjFile[i-1].SymTable.SymbolIndex[k-1]:=
       Pelf64_symbol_table_entry(tempptr+offset)^.symbol_section_index;
       if(TempList1.ObjFile[i-1].SymTable.SymbolIndex[k-1]<>0)
       and(TempList1.ObjFile[i-1].SymTable.SymbolIndex[k-1]<=Word($FFF0)) then
        begin
         TempList1.ObjFile[i-1].SymTable.SymbolSection[k-1]:=
         elf_get_name(objlist.item[i-1].Ptr.shstrtabptr,
         Pelf64_section_header(ptr.sec64ptr+
         Pelf64_symbol_table_entry(tempptr+offset)^.symbol_section_index)^.section_header_name);
         TempList1.ObjFile[i-1].SymTable.SymbolSection[k-1]:=
         TempList1.ObjFile[i-1].SymTable.SymbolSection[k-1]+ld_create_name(i);
        end
       else
        begin
         TempList1.ObjFile[i-1].SymTable.SymbolSection[k-1]:='';
        end;
       if(TempList1.ObjFile[i-1].SymTable.SymbolType[k-1]<>elf_symbol_type_section) then
        begin
         TempList1.ObjFile[i-1].SymTable.SymbolName[k-1]:=
         elf_get_name(objlist.item[i-1].Ptr.strtabptr,
         Pelf64_symbol_table_entry(tempptr+offset)^.symbol_name);
         if(Copy(TempList1.ObjFile[i-1].SymTable.SymbolName[k-1],1,1)='.') then
          begin
           TempList1.ObjFile[i-1].SymTable.SymbolName[k-1]:=
           TempList1.ObjFile[i-1].SymTable.SymbolName[k-1]+ld_create_name(totalsymcount+k);
          end;
        end
       else
        begin
         TempList1.ObjFile[i-1].SymTable.SymbolName[k-1]:=
         TempList1.ObjFile[i-1].SymTable.SymbolSection[k-1];
        end;
       TempList1.ObjFile[i-1].SymTable.SymbolVaildForLink[k-1]:=
       ((TempList1.ObjFile[i-1].SymTable.SymbolType[k-1]>0)
       or(TempList1.ObjFile[i-1].SymTable.SymbolIndex[k-1]>0))
       and(TempList1.ObjFile[i-1].SymTable.SymbolIndex[k-1]<=Word($FFF0));
       if(TempList1.ObjFile[i-1].SymTable.SymbolVaildForLink[k-1]=false) then
        begin
         inc(offset,sizeof(elf64_symbol_table_entry)); continue;
        end;
       TempList1.ObjFile[i-1].SymTable.SymbolBinding[k-1]:=
       elf_symbol_type_bind(Pelf64_symbol_table_entry(tempptr+offset)^.symbol_info);
       TempList1.ObjFile[i-1].SymTable.SymbolSize[k-1]:=
       Pelf64_symbol_table_entry(tempptr+offset)^.symbol_size;
       TempList1.ObjFile[i-1].SymTable.SymbolVisible[k-1]:=
       elf_symbol_type_visibility(Pelf64_symbol_table_entry(tempptr+offset)^.symbol_other);
       TempList1.ObjFile[i-1].SymTable.SymbolValue[k-1]:=
       Pelf64_symbol_table_entry(tempptr+offset)^.symbol_value;
       inc(offset,sizeof(elf64_symbol_table_entry));
      end;
     inc(totalsymcount,objlist.item[i-1].Ptr.symcount);
     TempList1.ObjFile[i-1].SecCount:=count;
     SetLength(TempList1.ObjFile[i-1].SecUsed,count);
     SetLength(TempList1.ObjFile[i-1].SecName,count);
     SetLength(TempList1.ObjFile[i-1].SecSize,count);
     SetLength(TempList1.ObjFile[i-1].SecType,count);
     SetLength(TempList1.ObjFile[i-1].SecContent,count);
     SetLength(TempList1.ObjFile[i-1].SecNowIndex,count);
     SetLength(TempList1.ObjFile[i-1].SecNowPos,count);
     for j:=1 to count do
      begin
       Templist1.ObjFile[i-1].SecUsed[j-1]:=false;
       size:=Pelf64_section_header(ptr.sec64ptr+j-1)^.section_header_size;
       if(size=0) then continue;
       startaddr:=(objlist.item[i-1].Ptr.CntPtr+j-1)^.b;
       TempList1.ObjFile[i-1].SecName[j-1]:=elf_get_name(
       objlist.item[i-1].Ptr.shstrtabptr,Pelf64_section_header(ptr.sec64ptr+j-1)^.section_header_name);
       TempList1.ObjFile[i-1].SecName[j-1]:=TempList1.ObjFile[i-1].SecName[j-1]+ld_create_name(i);
       Templist1.ObjFile[i-1].SecSize[j-1]:=size;
       for k:=1 to length(Order) do
        begin
         if(faststrcomp_segment(TempList1.ObjFile[i-1].SecName[j-1],1,length(Order[k-1]),
         Order[k-1])) then
          begin
           inc(NeedSize[k-1],size); inc(NeedCount[k-1],1);
           TempList1.ObjFile[i-1].SecType[j-1]:=k;
           break;
          end;
        end;
       if(startaddr=nil) then continue;
       if(startaddr<>nil) and
       (Pelf64_section_header(ptr.sec64ptr+j-1)^.section_header_type=elf_section_type_progbit) then
        begin
         TempList1.ObjFile[i-1].SecContent[j-1]:=startaddr; inc(seccount); continue;
        end
       else
        begin
         if(Pelf64_section_header(ptr.sec64ptr+j-1)^.section_header_type=elf_section_type_nobit) then
         inc(seccount);
         TempList1.ObjFile[i-1].SecContent[j-1]:=nil;
        end;
       if(Pelf64_section_header(ptr.sec64ptr+j-1)^.section_header_type=elf_section_type_reloc) then
        begin
         tempptr:=startaddr; offset:=0;
         inc(templist1.ObjFile[i-1].SecRelCount);
         templist1.ObjFile[i-1].SecRel[templist1.ObjFile[i-1].SecRelCount-1].SymSecName:=
         elf_get_name(objlist.item[i-1].Ptr.shstrtabptr,
         Pelf64_section_header(ptr.sec64ptr+
         Pelf64_section_header(ptr.sec64ptr+j-1)^.section_header_info)^.section_header_name);
         templist1.ObjFile[i-1].SecRel[templist1.ObjFile[i-1].SecRelCount-1].SymSecName:=
         templist1.ObjFile[i-1].SecRel[templist1.ObjFile[i-1].SecRelCount-1].SymSecName+
         ld_create_name(i);
         SetLength(templist1.ObjFile[i-1].SecRel[templist1.ObjFile[i-1].SecRelCount-1].Symbol,
         TempList1.ObjFile[i-1].SecSize[j-1] shr 4);
         SetLength(templist1.ObjFile[i-1].SecRel[templist1.ObjFile[i-1].SecRelCount-1].SymType,
         TempList1.ObjFile[i-1].SecSize[j-1] shr 4);
         SetLength(templist1.ObjFile[i-1].SecRel[templist1.ObjFile[i-1].SecRelCount-1].SymOffset,
         TempList1.ObjFile[i-1].SecSize[j-1] shr 4);
         templist1.ObjFile[i-1].SecRel[templist1.ObjFile[i-1].SecRelCount-1].SymCount:=
         TempList1.ObjFile[i-1].SecSize[j-1] shr 4;
         for k:=1 to TempList1.ObjFile[i-1].SecSize[j-1] shr 4 do
          begin
           templist1.ObjFile[i-1].SecRel[templist1.ObjFile[i-1].SecRelCount-1].Symbol[k-1]:=
           elf64_reloc_symbol(Pelf64_rel(tempptr+offset)^.Info);
           templist1.ObjFile[i-1].SecRel[templist1.ObjFile[i-1].SecRelCount-1].SymType[k-1]:=
           elf64_reloc_type(Pelf64_rel(tempptr+offset)^.Info);
           templist1.ObjFile[i-1].SecRel[templist1.ObjFile[i-1].SecRelCount-1].SymOffset[k-1]:=
           Pelf64_rel(tempptr+offset)^.Offset;
           inc(offset,16);
          end;
         inc(relcount);
        end
       else if(Pelf64_section_header(ptr.sec64ptr+j-1)^.section_header_type=elf_section_type_rela) then
        begin
         tempptr:=startaddr; offset:=0;
         inc(templist1.ObjFile[i-1].SecRelaCount);
         templist1.ObjFile[i-1].SecRela[templist1.ObjFile[i-1].SecRelaCount-1].SymSecName:=
         elf_get_name(objlist.item[i-1].Ptr.shstrtabptr,
         Pelf64_section_header(ptr.sec64ptr+
         Pelf64_section_header(ptr.sec64ptr+j-1)^.section_header_info)^.section_header_name);
         templist1.ObjFile[i-1].SecRela[templist1.ObjFile[i-1].SecRelaCount-1].SymSecName:=
         templist1.ObjFile[i-1].SecRela[templist1.ObjFile[i-1].SecRelaCount-1].SymSecName+
         ld_create_name(i);
         SetLength(templist1.ObjFile[i-1].SecRela[templist1.ObjFile[i-1].SecRelaCount-1].Symbol,
         TempList1.ObjFile[i-1].SecSize[j-1] div 24);
         SetLength(templist1.ObjFile[i-1].SecRela[templist1.ObjFile[i-1].SecRelaCount-1].SymType,
         TempList1.ObjFile[i-1].SecSize[j-1] div 24);
         SetLength(templist1.ObjFile[i-1].SecRela[templist1.ObjFile[i-1].SecRelaCount-1].SymOffset,
         TempList1.ObjFile[i-1].SecSize[j-1] div 24);
         SetLength(templist1.ObjFile[i-1].SecRela[templist1.ObjFile[i-1].SecRelaCount-1].SymAddend,
         TempList1.ObjFile[i-1].SecSize[j-1] div 24);
         templist1.ObjFile[i-1].SecRela[templist1.ObjFile[i-1].SecRelaCount-1].SymCount:=
         TempList1.ObjFile[i-1].SecSize[j-1] div 24;
         for k:=1 to TempList1.ObjFile[i-1].SecSize[j-1] div 24 do
          begin
           templist1.ObjFile[i-1].SecRela[templist1.ObjFile[i-1].SecRelaCount-1].Symbol[k-1]:=
           elf64_reloc_symbol(Pelf64_rela(tempptr+offset)^.Info);
           templist1.ObjFile[i-1].SecRela[templist1.ObjFile[i-1].SecRelaCount-1].SymType[k-1]:=
           elf64_reloc_type(Pelf64_rela(tempptr+offset)^.Info);
           templist1.ObjFile[i-1].SecRela[templist1.ObjFile[i-1].SecRelaCount-1].SymOffset[k-1]:=
           Pelf64_rela(tempptr+offset)^.Offset;
           templist1.ObjFile[i-1].SecRela[templist1.ObjFile[i-1].SecRelaCount-1].SymAddend[k-1]:=
           Pelf64_rela(tempptr+offset)^.Addend;
           inc(offset,24);
          end;
         inc(relacount);
        end;
      end;
    end;
  end;
 {Generate the temporary Symbol Table}
 middlelist.SymTable.SymbolCount:=0;
 middlelist.SymTable.SymbolQuotedByMain:=tydq_getmem(totalsymcount);
 SetLength(middlelist.SymTable.SymbolName,totalsymcount);
 SetLength(middlelist.SymTable.SymbolNameHash,totalsymcount);
 SetLength(middlelist.SymTable.SymbolSectionHash,totalsymcount);
 middlelist.SymTable.SymbolFileIndex:=tydq_getmem(totalsymcount*sizeof(Natuint));
 middlelist.SymTable.SymbolIndex:=tydq_getmem(totalsymcount*sizeof(word));
 middlelist.SymTable.SymbolSymIndex:=tydq_getmem(totalsymcount*sizeof(Natuint));
 for i:=1 to templist1.Count do
  begin
   for j:=1 to templist1.ObjFile[i-1].SymTable.SymbolCount do
    begin
     if(TempList1.ObjFile[i-1].SymTable.SymbolVaildForLink[j-1]=false) then continue;
     inc(middlelist.SymTable.SymbolCount);
     middlelist.SymTable.SymbolQuotedByMain[middlelist.SymTable.SymbolCount-1]:=false;
     middlelist.SymTable.SymbolName[middlelist.SymTable.SymbolCount-1]:=
     templist1.ObjFile[i-1].SymTable.SymbolName[j-1];
     middlelist.SymTable.SymbolNameHash[middlelist.SymTable.SymbolCount-1]:=
     generate_hash_from_string(templist1.ObjFile[i-1].SymTable.SymbolName[j-1]);
     middlelist.SymTable.SymbolSymIndex[middlelist.SymTable.SymbolCount-1]:=j;
     middlelist.SymTable.SymbolSectionHash[middlelist.SymTable.SymbolCount-1]:=
     generate_hash_from_string(templist1.ObjFile[i-1].SymTable.SymbolSection[j-1],true);
     middlelist.SymTable.SymbolFileIndex[middlelist.SymTable.SymbolCount-1]:=i;
     middlelist.SymTable.SymbolIndex[middlelist.SymTable.SymbolCount-1]:=
     templist1.ObjFile[i-1].SymTable.SymbolIndex[j-1];
    end;
  end;
 {Generate the hash table for linking}
 hashtable.BucketCount:=middlelist.SymTable.SymbolCount div 3*4+1;
 hashtable.ChainCount:=middlelist.SymTable.SymbolCount;
 SetLength(hashtable.BucketItem,hashtable.BucketCount);
 SetLength(hashtable.ChainItem,hashtable.ChainCount);
 SetLength(hashtable.BucketUsed,hashtable.BucketCount);
 SetLength(hashtable.ChainUsed,hashtable.ChainCount);
 hashtable2.BucketCount:=middlelist.SymTable.SymbolCount div 3*4+1;
 hashtable2.ChainCount:=middlelist.SymTable.SymbolCount;
 SetLength(hashtable2.BucketItem,hashtable2.BucketCount);
 SetLength(hashtable2.ChainItem,hashtable2.ChainCount);
 SetLength(hashtable2.BucketUsed,hashtable2.BucketCount);
 SetLength(hashtable2.ChainUsed,hashtable2.ChainCount);
 for i:=1 to middlelist.SymTable.SymbolCount do
  begin
   tempvalue:=middlelist.SymTable.SymbolNameHash[i-1];
   if(hashtable.BucketItem[tempvalue mod hashtable.BucketCount]=0) then
    begin
     hashtable.BucketItem[tempvalue mod hashtable.BucketCount]:=i-1;
     hashtable.BucketUsed[tempvalue mod hashtable.BucketCount]:=true;
    end
   else
    begin
     tempvalue2:=hashtable.BucketItem[tempvalue mod hashtable.BucketCount];
     while(hashtable.ChainUsed[tempvalue2])do
      begin
       tempvalue2:=hashtable.ChainItem[tempvalue2];
      end;
     hashtable.ChainItem[tempvalue2]:=i-1;
     hashtable.ChainUsed[tempvalue2]:=true;
    end;
   tempvalue:=middlelist.SymTable.SymbolSectionHash[i-1];
   if(hashtable2.BucketItem[tempvalue mod hashtable2.BucketCount]=0) then
    begin
     hashtable2.BucketItem[tempvalue mod hashtable2.BucketCount]:=i-1;
     hashtable2.BucketUsed[tempvalue mod hashtable2.BucketCount]:=true;
    end
   else
    begin
     tempvalue2:=hashtable2.BucketItem[tempvalue mod hashtable2.BucketCount];
     while(hashtable2.ChainUsed[tempvalue2])do
      begin
       tempvalue2:=hashtable2.ChainItem[tempvalue2];
      end;
     hashtable2.ChainItem[tempvalue2]:=i-1;
     hashtable2.ChainUsed[tempvalue2]:=true;
    end;
  end;
 {Generate the relocation and relative adjust for sections}
 middlelist.SecRelCount:=0; middlelist.SecRelaCount:=0;
 {Generate the relocation}
 if(relcount>0) then
  begin
   SetLength(middlelist.SecRel,relcount);
   SetLength(middlelist.SecRelHash,relcount);
   relcount:=0;
  end;
 for i:=1 to templist1.Count do
  begin
   for j:=1 to templist1.ObjFile[i-1].SecRelCount do
    begin
     inc(middlelist.SecRelCount);
     middlelist.SecRelHash[middlelist.SecRelCount-1]:=
     generate_hash_from_string(templist1.ObjFile[i-1].SecRel[j-1].SymSecName,true);
     middlelist.SecRel[middlelist.SecRelCount-1].SymCount:=0;
     SetLength(middlelist.SecRel[middlelist.SecRelCount-1].SymOffset,
     templist1.ObjFile[i-1].SecRel[j-1].SymCount);
     SetLength(middlelist.SecRel[middlelist.SecRelCount-1].SymType,
     templist1.ObjFile[i-1].SecRel[j-1].SymCount);
     SetLength(middlelist.SecRel[middlelist.SecRelCount-1].SymHash,
     templist1.ObjFile[i-1].SecRel[j-1].SymCount);
     count:=0;
     for k:=1 to templist1.ObjFile[i-1].SecRel[j-1].SymCount do
      begin
       inc(middlelist.SecRel[middlelist.SecRelaCount-1].SymCount);
       count:=middlelist.SecRel[middlelist.SecRelaCount-1].SymCount;
       middlelist.SecRel[middlelist.SecRelCount-1].SymOffset[count-1]:=
       templist1.ObjFile[i-1].SecRel[j-1].SymOffset[k-1];
       if(templist1.ObjFile[i-1].SecRel[j-1].Symbol[k-1]=0) then
       middlelist.SecRel[middlelist.SecRelCount-1].SymHash[count-1]:=0
       else
       middlelist.SecRel[middlelist.SecRelCount-1].SymHash[count-1]:=
       generate_hash_from_string(
       TempList1.ObjFile[i-1].SymTable.SymbolName[templist1.ObjFile[i-1].SecRel[j-1].Symbol[k-1]-1]);
       middlelist.SecRel[middlelist.SecRelCount-1].SymType[count-1]:=
       templist1.ObjFile[i-1].SecRel[j-1].SymType[k-1];
       inc(relcount);
      end;
    end;
  end;
 {Generate the temporary relative}
 if(relacount>0) then
  begin
   SetLength(middlelist.SecRela,relacount);
   SetLength(middlelist.SecRelaHash,relacount);
   relacount:=0;
  end;
 for i:=1 to templist1.Count do
  begin
   for j:=1 to templist1.ObjFile[i-1].SecRelaCount do
    begin
     inc(middlelist.SecRelaCount);
     middlelist.SecRelaHash[middlelist.SecRelaCount-1]:=
     generate_hash_from_string(templist1.ObjFile[i-1].SecRela[j-1].SymSecName,true);
     middlelist.SecRela[middlelist.SecRelaCount-1].SymCount:=0;
     SetLength(middlelist.SecRela[middlelist.SecRelaCount-1].SymOffset,
     templist1.ObjFile[i-1].SecRela[j-1].SymCount);
     SetLength(middlelist.SecRela[middlelist.SecRelaCount-1].SymType,
     templist1.ObjFile[i-1].SecRela[j-1].SymCount);
     SetLength(middlelist.SecRela[middlelist.SecRelaCount-1].SymHash,
     templist1.ObjFile[i-1].SecRela[j-1].SymCount);
     {SetLength(middlelist.SecRela[middlelist.SecRelaCount-1].SymName,
     templist1.ObjFile[i-1].SecRela[j-1].SymCount);}
     SetLength(middlelist.SecRela[middlelist.SecRelaCount-1].SymAddend,
     templist1.ObjFile[i-1].SecRela[j-1].SymCount);
     count:=0;
     for k:=1 to templist1.ObjFile[i-1].SecRela[j-1].SymCount do
      begin
       inc(middlelist.SecRela[middlelist.SecRelaCount-1].SymCount);
       count:=middlelist.SecRela[middlelist.SecRelaCount-1].SymCount;
       middlelist.SecRela[middlelist.SecRelaCount-1].SymOffset[count-1]:=
       templist1.ObjFile[i-1].SecRela[j-1].SymOffset[k-1];
       {if(templist1.ObjFile[i-1].SecRela[j-1].Symbol[k-1]=0) then
       middlelist.SecRela[middlelist.SecRelaCount-1].SymName[count-1]:=''
       else
       middlelist.SecRela[middlelist.SecRelaCount-1].SymName[count-1]:=
       TempList1.ObjFile[i-1].SymTable.SymbolName[templist1.ObjFile[i-1].SecRela[j-1].Symbol[k-1]-1];}
       if(templist1.ObjFile[i-1].SecRela[j-1].Symbol[k-1]=0) then
       middlelist.SecRela[middlelist.SecRelaCount-1].SymHash[count-1]:=0
       else
       middlelist.SecRela[middlelist.SecRelaCount-1].SymHash[count-1]:=
       generate_hash_from_string(
       TempList1.ObjFile[i-1].SymTable.SymbolName[templist1.ObjFile[i-1].SecRela[j-1].Symbol[k-1]-1]);
       middlelist.SecRela[middlelist.SecRelaCount-1].SymType[count-1]:=
       templist1.ObjFile[i-1].SecRela[j-1].SymType[k-1];
       middlelist.SecRela[middlelist.SecRelaCount-1].SymAddend[count-1]:=
       templist1.ObjFile[i-1].SecRela[j-1].SymAddend[k-1];
       inc(relacount);
      end;
    end;
  end;
 {Generate the relocation hash table and relative hash table}
 if(middlelist.SecRelCount>0) then
  begin
   hashtable3.BucketCount:=middlelist.SecRelCount div 3*4+1;
   hashtable3.ChainCount:=middlelist.SecRelCount;
   SetLength(hashtable3.BucketItem,hashtable3.BucketCount);
   SetLength(hashtable3.ChainItem,hashtable3.ChainCount);
   SetLength(hashtable3.BucketUsed,hashtable3.BucketCount);
   SetLength(hashtable3.ChainUsed,hashtable3.ChainCount);
   for i:=1 to middlelist.SecRelCount do
    begin
     tempvalue:=middlelist.SecRelHash[i-1];
     if(hashtable3.BucketItem[tempvalue mod hashtable3.BucketCount]=0) then
      begin
       hashtable3.BucketItem[tempvalue mod hashtable3.BucketCount]:=i-1;
       hashtable3.BucketUsed[tempvalue mod hashtable3.BucketCount]:=true;
      end
     else
      begin
       tempvalue2:=hashtable3.BucketItem[tempvalue mod hashtable3.BucketCount];
       while(hashtable3.ChainUsed[tempvalue2])do
        begin
         tempvalue2:=hashtable3.ChainItem[tempvalue2];
        end;
       hashtable3.ChainItem[tempvalue2]:=i;
       hashtable3.ChainUsed[tempvalue2]:=true;
      end;
    end;
  end;
 if(middlelist.SecRelaCount>0) then
  begin
   hashtable4.BucketCount:=middlelist.SecRelaCount div 3*4+1;
   hashtable4.ChainCount:=middlelist.SecRelaCount;
   SetLength(hashtable4.BucketItem,hashtable4.BucketCount);
   SetLength(hashtable4.ChainItem,hashtable4.ChainCount);
   SetLength(hashtable4.BucketUsed,hashtable4.BucketCount);
   SetLength(hashtable4.ChainUsed,hashtable4.ChainCount);
   for i:=1 to middlelist.SecRelaCount do
    begin
     tempvalue:=middlelist.SecRelaHash[i-1];
     if(hashtable4.BucketItem[tempvalue mod hashtable4.BucketCount]=0) then
      begin
       hashtable4.BucketItem[tempvalue mod hashtable4.BucketCount]:=i-1;
       hashtable4.BucketUsed[tempvalue mod hashtable4.BucketCount]:=true;
      end
     else
      begin
       tempvalue2:=hashtable4.BucketItem[tempvalue mod hashtable4.BucketCount];
       while(hashtable4.ChainUsed[tempvalue2])do
        begin
         tempvalue2:=hashtable4.ChainItem[tempvalue2];
        end;
       hashtable4.ChainItem[tempvalue2]:=i-1;
       hashtable4.ChainUsed[tempvalue2]:=true;
      end;
    end;
  end;
 {SmartLink the sections}
 if(SmartLinking) then
  begin
   ld_handle_symbol_table(middlelist,EntryHash,SmartLinking,hashtable,hashtable2,
   relcount,hashtable3,relacount,hashtable4);
   for i:=1 to middlelist.SymTable.SymbolCount do
    begin
     if(middlelist.SymTable.SymbolQuotedByMain[i-1])then
      begin
       j:=middlelist.SymTable.SymbolFileIndex[i-1]; k:=middlelist.SymTable.SymbolIndex[i-1]+1;
       templist1.ObjFile[j-1].SecUsed[k-1]:=true;
      end;
    end;
  end;
 {Convert the Stage 1 List to List 2}
 templist2.SecCount:=0; templist2.SymTable.SymbolCount:=0; templist2.SecFlag:=templist1.SecFlag;
 {Create the basic section}
 SetLength(templist2.SecName,12);
 templist2.SecSize:=tydq_getmem(sizeof(Dword)*12);
 SetLength(templist2.SecContent,12);
 for i:=1 to length(order) do
  begin
   if(NeedSize[i-1]=0) then continue;
   inc(templist2.SecCount);
   templist2.SecName[templist2.SecCount-1]:=Order[i-1];
   templist2.SecSize[templist2.SecCount-1]:=0;
   if(i<>8) and (i<>10) then
   templist2.SecContent[templist2.SecCount-1].SecContent:=tydq_getmem(NeedSize[i-1])
   else
   templist2.SecContent[templist2.SecCount-1].SecContent:=nil;
   partoffset:=0;
   SetLength(templist2.SecContent[templist2.SecCount-1].SecName,NeedCount[i-1]);
   templist2.SecContent[templist2.SecCount-1].SecOffset:=tydq_getmem(NeedCount[i-1]*sizeof(natuint));
   for j:=1 to templist1.Count do
    begin
     for k:=1 to templist1.ObjFile[j-1].SecCount do
      begin
       if(templist1.ObjFile[j-1].SecType[k-1]<>i) then continue;
       if(templist1.ObjFile[j-1].SecSize[k-1]=0) then continue;
       if(templist1.ObjFile[j-1].SecUsed[k-1]<>SmartLinking) then continue;
       if(i<>8) and (i<>10) and (templist1.ObjFile[j-1].SecContent[k-1]=nil) then continue;
       inc(templist2.SecContent[templist2.SecCount-1].SecCount);
       templist1.ObjFile[j-1].SecNowIndex[k-1]:=templist2.SecCount;
       templist1.ObjFile[j-1].SecNowPos[k-1]:=templist2.SecContent[templist2.SecCount-1].SecCount;
       tempcount:=templist2.SecContent[templist2.SecCount-1].SecCount;
       templist2.SecContent[templist2.SecCount-1].SecName[tempcount-1]:=
       generate_hash_from_string(templist1.ObjFile[j-1].SecName[k-1],true);
       templist2.SecContent[templist2.SecCount-1].SecOffset[tempcount-1]:=partoffset;
       if(i<>8) and (i<>10) then
        begin
         tydq_move(templist1.ObjFile[j-1].SecContent[k-1]^,
         (templist2.SecContent[templist2.SecCount-1].SecContent+partoffset)^,
         templist1.ObjFile[j-1].SecSize[k-1]);
        end;
       inc(partoffset,templist1.ObjFile[j-1].SecSize[k-1]);
      end;
    end;
   templist2.SecSize[templist2.SecCount-1]:=partoffset;
   if(partoffset=0) then dec(templist2.SecCount);
  end;
 {Generate the symbol table}
 templist2.EntryIndex:=0; templist2.EntryOffset:=0;
 templist2.SymTable.SymbolCount:=0;
 SetLength(templist2.SymTable.SymbolName,middlelist.SymTable.SymbolCount);
 SetLength(templist2.SymTable.SymbolNameHash,middlelist.SymTable.SymbolCount);
 SetLength(templist2.SymTable.SymbolBinding,middlelist.SymTable.SymbolCount);
 SetLength(templist2.SymTable.SymbolSize,middlelist.SymTable.SymbolCount);
 SetLength(templist2.SymTable.SymbolType,middlelist.SymTable.SymbolCount);
 SetLength(templist2.SymTable.SymbolIndex,middlelist.SymTable.SymbolCount);
 SetLength(templist2.SymTable.SymbolValue,middlelist.SymTable.SymbolCount);
 SetLength(templist2.SymTable.SymbolVisible,middlelist.SymTable.SymbolCount);
 for i:=1 to middlelist.SymTable.SymbolCount do
  begin
   if(middlelist.SymTable.SymbolQuotedByMain[i-1]=SmartLinking)
   or(middlelist.SymTable.SymbolNameHash[i-1]<>0) then
    begin
     if(middlelist.SymTable.SymbolName[i-1][1]='.')
     or(middlelist.SymTable.SymbolName[i-1][1]='$')
     or(faststrcomp_segment(middlelist.SymTable.SymbolName[i-1],1,6,'RTTI_$'))
     or(faststrcomp_segment(middlelist.SymTable.SymbolName[i-1],1,6,'INIT_$')) then continue;
     m:=middlelist.SymTable.SymbolFileIndex[i-1]; n:=middlelist.SymTable.SymbolSymIndex[i-1];
     if(templist1.ObjFile[m-1].SymTable.SymbolType[n-1]<>elf_symbol_type_function)
     and(templist1.ObjFile[m-1].SymTable.SymbolType[n-1]<>elf_symbol_type_object) then continue;
     inc(templist2.SymTable.SymbolCount);
     templist2.SymTable.SymbolBinding[templist2.SymTable.SymbolCount-1]:=
     templist1.ObjFile[m-1].SymTable.SymbolBinding[n-1];
     templist2.SymTable.SymbolName[templist2.SymTable.SymbolCount-1]:=
     templist1.ObjFile[m-1].SymTable.SymbolName[n-1];
     templist2.SymTable.SymbolNameHash[templist2.SymTable.SymbolCount-1]:=
     middlelist.SymTable.SymbolNameHash[i-1];
     templist2.SymTable.SymbolVisible[templist2.SymTable.SymbolCount-1]:=
     templist1.ObjFile[m-1].SymTable.SymbolVisible[n-1];
     templist2.SymTable.SymbolType[templist2.SymTable.SymbolCount-1]:=
     templist1.ObjFile[m-1].SymTable.SymbolType[n-1];
     templist2.SymTable.SymbolSize[templist2.SymTable.SymbolCount-1]:=
     templist1.ObjFile[m-1].SymTable.SymbolSize[n-1];
     {Get the Index and Value of the Section}
     if(templist1.ObjFile[m-1].SymTable.SymbolIndex[n-1]=0) then goto label1;
     a:=templist1.ObjFile[m-1].SymTable.SymbolIndex[n-1];
     j:=templist1.ObjFile[m-1].SecNowIndex[a]; k:=templist1.ObjFile[m-1].SecNowPos[a];
     bool:=(j<>0) and (k<>0);
     label1:
     if(bool) and (middlelist.SymTable.SymbolSectionHash[i-1]<>0) then
      begin
       templist2.SymTable.SymbolIndex[templist2.SymTable.SymbolCount-1]:=j;
       templist2.SymTable.SymbolValue[templist2.SymTable.SymbolCount-1]:=
       templist2.SecContent[j-1].SecOffset[k-1]+templist1.ObjFile[m-1].SymTable.SymbolValue[n-1];
       if(templist2.EntryIndex=0) and (middlelist.SymTable.SymbolNameHash[i]=EntryHash) then
        begin
         templist2.EntryIndex:=j;
         templist2.EntryOffset:=
         templist2.SecContent[j-1].SecOffset[k-1]+templist1.ObjFile[m-1].SymTable.SymbolValue[n-1];
        end;
      end
     else if(templist1.ObjFile[m-1].SymTable.SymbolType[n-1]>0)
     and (middlelist.SymTable.SymbolSectionHash[i-1]=0) then
      begin
       templist2.SymTable.SymbolIndex[templist2.SymTable.SymbolCount-1]:=0;
       templist2.SymTable.SymbolValue[templist2.SymTable.SymbolCount-1]:=0;
      end
     else dec(templist2.SymTable.SymbolCount);
    end;
  end;
 {Initialize the adjustment}
 templist2.Adjust.Count:=0;
 templist2.Adjust.SrcIndex:=tydq_getmem(sizeof(word)*(relcount+relacount));
 templist2.Adjust.SrcOffset:=tydq_getmem(sizeof(dword)*(relcount+relacount));
 templist2.Adjust.DestIndex:=tydq_getmem(sizeof(word)*(relcount+relacount));
 templist2.Adjust.DestOffset:=tydq_getmem(sizeof(dword)*(relcount+relacount));
 templist2.Adjust.Addend:=tydq_getmem(sizeof(Natint)*(relcount+relacount));
 SetLength(templist2.Adjust.AdjustFunc,relcount+relacount);
 SetLength(templist2.Adjust.AdjustHash,relcount+relacount);
 SetLength(templist2.Adjust.AdjustName,relcount+relacount);
 SetLength(templist2.Adjust.AdjustRelax,relcount+relacount);
 SetLength(templist2.Adjust.AdjustType,relcount+relacount);
 SetLength(templist2.Adjust.Formula,relcount+relacount);
 {Initialize the adjustment using relocations}
 for i:=1 to middlelist.SecRelCount do
  begin
   if(middlelist.SecRelHash[i-1]=0) then continue;
   c:=ld_search_for_index(hashtable2,dynnatuintarray(middlelist.SymTable.SymbolSectionHash),
   middlelist.SecRelHash[i-1]);
   if(c=0) then continue;
   k:=templist1.ObjFile[middlelist.SymTable.SymbolFileIndex[c-1]-1].
   SecNowIndex[middlelist.SymTable.SymbolIndex[c-1]];
   m:=templist1.ObjFile[middlelist.SymTable.SymbolFileIndex[c-1]-1].
   SecNowPos[middlelist.SymTable.SymbolIndex[c-1]];
   if(k=0) or (m=0) then continue;
   for j:=1 to middlelist.SecRel[i-1].SymCount do
    begin
     if(ldarch=elf_machine_riscv) and
     (middlelist.SecRel[i-1].SymType[j-1]=elf_reloc_riscv_align) then continue
     else if(ldarch=elf_machine_riscv) and
     (middlelist.SecRel[i-1].SymType[j-1]=elf_reloc_riscv_relax) then
      begin
       templist2.Adjust.AdjustRelax[templist2.Adjust.Count-1]:=true; continue;
      end
     else if(ldarch=elf_machine_loongarch) and
     (middlelist.SecRel[i-1].SymType[j-1]=elf_reloc_loongarch_relax) then
      begin
       templist2.Adjust.AdjustRelax[templist2.Adjust.Count-1]:=true; continue;
      end;
     if(middlelist.SecRel[i-1].SymHash[j-1]=0) then continue;
     d:=ld_search_for_index(hashtable,dynnatuintarray(middlelist.SymTable.SymbolNameHash),
     middlelist.SecRel[i-1].SymHash[j-1]);
     if(d>0) then
      begin
       c:=ld_search_for_index(hashtable2,dynnatuintarray(middlelist.SymTable.SymbolSectionHash),
       middlelist.SymTable.SymbolSectionHash[d-1]);
      end
     else c:=0;
     if(c<>0) then
      begin
       a:=templist1.ObjFile[middlelist.SymTable.SymbolFileIndex[c-1]-1].
       SecNowIndex[middlelist.SymTable.SymbolIndex[c-1]];
       b:=templist1.ObjFile[middlelist.SymTable.SymbolFileIndex[c-1]-1].
       SecNowPos[middlelist.SymTable.SymbolIndex[c-1]];
      end
     else
      begin
       a:=0; b:=0;
      end;
     {If the relocation can jump to,Jump to this relocation}
     inc(templist2.Adjust.Count);
     templist2.Adjust.SrcIndex[templist2.Adjust.count-1]:=k;
     templist2.Adjust.SrcOffset[templist2.Adjust.Count-1]:=
     templist2.SecContent[k-1].SecOffset[m-1]+middlelist.SecRel[i-1].SymOffset[j-1];
     templist2.Adjust.DestIndex[templist2.Adjust.Count-1]:=a;
     if(a<>0) then
      begin
       templist2.Adjust.DestOffset[templist2.Adjust.Count-1]:=templist2.SecContent[a-1].SecOffset[b-1];
      end
     else
      begin
       templist2.Adjust.DestOffset[templist2.Adjust.Count-1]:=0;
      end;
     templist2.Adjust.AdjustName[templist2.Adjust.Count-1]:=middlelist.SymTable.SymbolName[d-1];
     templist2.Adjust.AdjustHash[templist2.Adjust.Count-1]:=
     generate_hash_from_string(middlelist.SymTable.SymbolName[d-1]);
     if(templist2.SymTable.SymbolType[m-1]=elf_symbol_type_function) then
     templist2.Adjust.AdjustFunc[templist2.Adjust.Count-1]:=true
     else templist2.Adjust.AdjustFunc[templist2.Adjust.Count-1]:=false;
     Value:=middlelist.SecRel[i-1].SymType[j-1];
     templist2.Adjust.AdjustType[templist2.Adjust.Count-1]:=Value;
     templist2.Adjust.Addend[templist2.Adjust.Count-1]:=0;
     templist2.Adjust.AdjustRelax[templist2.Adjust.Count-1]:=false;
     if(ldarch=elf_machine_386) then
      begin
       case Value of
       elf_reloc_i386_none:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula([],0);
       elf_reloc_i386_32bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A'],32);
       elf_reloc_i386_pc32:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','P'],32);
       elf_reloc_i386_got32:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['G','+','A'],32);
       elf_reloc_i386_plt32:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['L','+','A','-','P'],32);
       elf_reloc_i386_copy:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula([],0);
       elf_reloc_i386_new_got_entry:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S'],32);
       elf_reloc_i386_new_plt_entry:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S'],32);
       elf_reloc_i386_relative:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['B','+','A'],32);
       elf_reloc_i386_got_offset:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','GOT'],32);
       elf_reloc_i386_32bit_pc_relative_offset:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['GOT','+','A','-','P'],32);
       elf_reloc_i386_32plt:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['L','+','A'],32);
       elf_reloc_i386_offset_in_static_tls_block:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['TLS_OFFSET'],32);
       elf_reloc_i386_address_of_got_entry_for_static_tls_block_offset:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['GOT_TLS','+','A'],32);
       elf_reloc_i386_got_entry_for_static_tls_block_offset:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['GOT_TLS','+','A'],32);
       elf_reloc_i386_offset_relative_to_static_tls_block:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['TLS_OFFSET'],32);
       elf_reloc_i386_general_dynamic_thread:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['GOT_TLS_GD','+','A'],32);
       elf_reloc_i386_local_dynamic_thread:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['GOT_TLS_LDM','+','A'],32);
       elf_reloc_i386_16bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A'],16);
       elf_reloc_i386_pc16bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','P'],16);
       elf_reloc_i386_8bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A'],8);
       elf_reloc_i386_pc8bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','P'],8);
       elf_reloc_i386_tls_general_dynamic_thread_32bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['GOT_TLS_GD','+','A'],32);
       elf_reloc_i386_tls_local_dynamic_thread_32bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['GOT_TLS_LDM','+','A'],32);
       elf_reloc_i386_offset_relative_for_tls_block:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A'],32);
       elf_reloc_i386_ie_32bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['GOT_TLS_IE','+','A'],32);
       elf_reloc_i386_le_32bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['-','TLS_OFFSET'],32);
       elf_reloc_i386_tls_module_containing_symbol:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['MODULE_ID'],32);
       elf_reloc_i386_tls_offset_in_tls_block:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['DTP_OFFSET'],32);
       elf_reloc_i386_tls_negated_offset:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['-','TLS_OFFSET'],32);
       elf_reloc_i386_tls_got_offset_for_tls_descriptor:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['Z','+','A'],32);
       elf_reloc_i386_tls_descriptor:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['DESC_ADDR'],32);
       elf_reloc_i386_indirect_relative:
       templist2.Adjust.Formula[templist2.Adjust.count-1]:=
       ld_generate_formula(['IFUNC_RESOLVER'],32);
       elf_reloc_i386_got_relaxable:
       templist2.Adjust.Formula[templist2.Adjust.count-1]:=
       ld_generate_formula(['G','+','A'],32);
       end;
      end
     else if(ldarch=elf_machine_arm) then
      begin
       case Value of
       elf_reloc_arm_none:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula([],0);
       elf_reloc_arm_pc_relative_26bit_branch:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['(','S','+','A',')','|','T','-','P'],26);
       elf_reloc_arm_absolute_32bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['(','S','+','A',')','|','T'],32);
       elf_reloc_arm_pc_relative_32bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['(','S','+','A',')','|','T','-','P'],32);
       elf_reloc_arm_pc_relative_13bit_branch:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','P'],32);
       elf_reloc_arm_absolute_16bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A'],16);
       elf_reloc_arm_absolute_12bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A'],12,$FFF);
       elf_reloc_arm_thumb_absolute_5bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A'],5,$7C);
       elf_reloc_arm_absolute_8bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A'],8);
       elf_reloc_arm_sb_reloc_32bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['(','S','+','A',')','|','T','-','B(S)'],32);
       elf_reloc_arm_thumb_pc_22bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['(','S','+','A',')','|','T','-','P'],22,$01FFFFFFE);
       elf_reloc_arm_thumb_pc_8bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','Pa'],8,$3FC);
       elf_reloc_arm_amp_vcall_9bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['ChangeIn[B(S)]','+','A'],9);
       elf_reloc_arm_tls_descriptor:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula([],0);
       elf_reloc_arm_thumb_swi8,elf_reloc_arm_xpc25,elf_reloc_arm_thumb_xpc22:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula([],0);
       elf_reloc_arm_tls_dtp_module:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['Module[S]'],32);
       elf_reloc_arm_tls_dtp_offset:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','TLS'],32);
       elf_reloc_arm_tls_tp_offset:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','tp'],32);
       elf_reloc_arm_copy:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula([],0);
       elf_reloc_arm_new_got_entry:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['(','S','+','A',')','|','T'],32);
       elf_reloc_arm_new_plt_entry:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['(','S','+','A',')','|','T'],32);
       elf_reloc_arm_relative:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['B(S)','+','A'],32);
       elf_reloc_arm_got_offset:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['(','(','S','+','A',')','|','T','-','GOT_ORG'],32);
       elf_reloc_arm_pc_relative_got_offset:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['B(S)','+','A','-','P'],32);
       elf_reloc_arm_got_entry_32bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['GOT(S)','+','A','-','GOT_ORG'],32);
       elf_reloc_arm_plt_address_32bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['(','S','+','A',')','|','T','-','P'],32);
       elf_reloc_arm_call:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['(','S','+','A',')','|','T','-','P'],32,$03FFFFFE);
       elf_reloc_arm_pc_relative_24bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['(','S','+','A',')','|','T','-','P'],24,$03FFFFFE);
       elf_reloc_arm_thumb_pc_relative_24bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['(','S','+','A',')','|','T','-','P'],24);
       elf_reloc_arm_base_absolute:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['B(S)','+','A'],32);
       elf_reloc_arm_alu_pcrel_bit7_0,elf_reloc_arm_alu_pcrel_bit15_8,elf_reloc_arm_alu_pcrel_bit23_16:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula([],0);
       elf_reloc_arm_ldr_sbrel_bit11_0:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','B(S)'],12);
       elf_reloc_arm_alu_sbrel_bit19_12:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','B(S)'],8);
       elf_reloc_arm_alu_sbrel_bit27_20:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','B(S)'],8);
       elf_reloc_arm_target1:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['(','S','+','A',')','|','T'],32);
       elf_reloc_arm_program_base_relative:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['(','(','S','+','A',')','|','T',')','-','B(S)'],32);
       elf_reloc_arm_v4bx,elf_reloc_arm_target2:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula([],0);
       elf_reloc_arm_31bit_pc_relative:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['(','(','S','+','A',')','|','T',')','-','P'],31);
       elf_reloc_arm_movw_absolute_16bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['(','S','+','A',')','|','T'],16,$FFFF);
       elf_reloc_arm_movt_absolute:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A'],32,$FFFF0000);
       elf_reloc_arm_movw_pc_relative:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['(','(','S','+','A',')','|','T',')','-','P'],16,$FFFF);
       elf_reloc_arm_movt_pc_relative:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','P'],32,$FFFF0000);
       elf_reloc_arm_thumb_movw_absolute:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['(','S','+','A',')','|','T'],32,$0000FFFF);
       elf_reloc_arm_thumb_movt_absolute:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A'],32,$FFFF0000);
       elf_reloc_arm_thumb_movw_pc_relative:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['(','(','S','+','A',')','|','T',')','-','P'],32,$0000FFFF);
       elf_reloc_arm_thumb_movt_pc_relative:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','P'],32,$FFFF0000);
       elf_reloc_arm_thumb_pc_relative_20bit_b:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['(','(','S','+','A',')','|','T',')','-','Pa'],20,$001FFFFE);
       elf_reloc_arm_thumb_pc_relative_6bit_b:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','Pa'],6,$7E);
       elf_reloc_arm_thumb_alu_pc_relative_bit11_0:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['(','(','S','+','A',')','|','T','-','Pa'],12,$00000FFF);
       elf_reloc_arm_thumb_pc_12bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','Pa'],12);
       elf_reloc_arm_absolute_32bit_no_interrupt:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A'],32);
       elf_reloc_arm_pc_relative_32bit_no_interrupt:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','P'],32);
       elf_reloc_arm_alu_pc_relative_g0_no_check:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['(','(','S','+','A',')','|','T',')','-','P'],32);
       elf_reloc_arm_alu_pc_relative_g0:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['(','(','S','+','A',')','|','T',')','-','P'],32);
       elf_reloc_arm_alu_pc_relative_g1_no_check:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['(','(','S','+','A',')','|','T',')','-','P'],32);
       elf_reloc_arm_alu_pc_relative_g1:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['(','(','S','+','A',')','|','T',')','-','P'],32);
       elf_reloc_arm_alu_pc_relative_g2:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['(','(','S','+','A',')','|','T',')','-','P'],32);
       elf_reloc_arm_ldr_str_ldrb_strb_pc_relative_g1:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','P'],32);
       elf_reloc_arm_ldr_str_ldrb_strb_pc_relative_g2:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','P'],32);
       elf_reloc_arm_ldr_str_pc_relative_g0:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','P'],32);
       elf_reloc_arm_ldr_str_pc_relative_g1:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','P'],32);
       elf_reloc_arm_ldr_str_pc_relative_g2:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','P'],32);
       elf_reloc_arm_ldc_stc_pc_relative_g0:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','P'],32);
       elf_reloc_arm_ldc_stc_pc_relative_g1:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','P'],32);
       elf_reloc_arm_ldc_stc_pc_relative_g2:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','P'],32);
       elf_reloc_arm_alu_program_base_relative_add_sub_g0_no_check:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['(','(','S','+','A',')','|','T','-','B(S)'],32);
       elf_reloc_arm_alu_program_base_relative_add_sub_g0:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['(','(','S','+','A',')','|','T','-','B(S)'],32);
       elf_reloc_arm_alu_program_base_relative_add_sub_g1_no_check:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['(','(','S','+','A',')','|','T','-','B(S)'],32);
       elf_reloc_arm_alu_program_base_relative_add_sub_g1:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['(','(','S','+','A',')','|','T','-','B(S)'],32);
       elf_reloc_arm_alu_program_base_relative_add_sub_g2:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['(','(','S','+','A',')','|','T','-','B(S)'],32);
       elf_reloc_arm_program_base_relative_ldr_str_ldrb_strb_g0:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','B(S)'],32);
       elf_reloc_arm_program_base_relative_ldr_str_ldrb_strb_g1:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','B(S)'],32);
       elf_reloc_arm_program_base_relative_ldr_str_ldrb_strb_g2:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','B(S)'],32);
       elf_reloc_arm_program_base_relative_ldrs_g0:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','B(S)'],32);
       elf_reloc_arm_program_base_relative_ldrs_g1:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','B(S)'],32);
       elf_reloc_arm_program_base_relative_ldrs_g2:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','B(S)'],32);
       elf_reloc_arm_ldc_base_relative_g0:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','B(S)'],32);
       elf_reloc_arm_ldc_base_relative_g1:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','B(S)'],32);
       elf_reloc_arm_ldc_base_relative_g2:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','B(S)'],32);
       elf_reloc_arm_movw_base_relative_no_check:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['(','(','S','+','A',')','|','T',')','-','B(S)'],16,$FFFF);
       elf_reloc_arm_movt_base_relative:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','B(S)'],32,$FFFF0000);
       elf_reloc_arm_movw_base_relative:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['(','(','S','+','A',')','|','T',')','-','B(S)'],16,$FFFF);
       elf_reloc_arm_thumb_movw_base_relative_no_check:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['(','(','S','+','A',')','|','T',')','-','B(S)'],32,$0000FFFF);
       elf_reloc_arm_thumb_movt_base_relative:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','B(S)'],32,$FFFF0000);
       elf_reloc_arm_thumb_movw_base_relative:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['(','(','S','+','A',')','|','T',')','-','B(S)'],32,$0000FFFF);
       elf_reloc_arm_tls_got_descriptor:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula([],0);
       elf_reloc_arm_tls_call:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula([],0);
       elf_reloc_arm_tls_descriptor_segment:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula([],0);
       elf_reloc_arm_thumb_tls_call:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula([],0);
       elf_reloc_arm_absolute_plt32:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['PLT(S)','+','A'],32);
       elf_reloc_arm_got_absolute:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['GOT(S)','+','A'],32);
       elf_reloc_arm_got_pc_relative:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['GOT(S)','+','A','-','P'],32);
       elf_reloc_arm_got_relative_to_got_origin:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['GOT(S)','+','A','-','GOT_ORG'],12,$FFF);
       elf_reloc_arm_got_offset_12bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','GOT_ORG'],12,$FFF);
       elf_reloc_arm_got_relax:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula([],0);
       elf_reloc_arm_gnu_vt_entry:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula([],0);
       elf_reloc_arm_gnu_vt_inherit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula([],0);
       elf_reloc_arm_thumb_pc_11bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','P'],11,$FFE);
       elf_reloc_arm_thumb_pc_9bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','P'],9,$1FE);
       elf_reloc_arm_tls_global_dynamic_32bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['GOT(S)','+','A','-','P'],12,$FFF);
       elf_reloc_arm_tls_local_dynamic_32bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['GOT(S)','+','A','-','P'],12,$FFF);
       elf_reloc_arm_tls_local_dynamic_offset_32bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','TLS'],32);
       elf_reloc_arm_tls_ie32:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['GOT(S)','+','A','-','P'],32);
       elf_reloc_arm_tls_le32:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','tp'],32);
       elf_reloc_arm_tls_ldo12:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','TLS'],12);
       elf_reloc_arm_tls_le12:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','tp'],12);
       elf_reloc_arm_tls_ie12gp:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['GOT(S)','+','A','-','GOT_ORG'],12);
       elf_reloc_arm_me_too:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula([],0);
       elf_reloc_arm_thumb_tls_descriptor_segment16:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula([],0);
       elf_reloc_arm_thumb_tls_descriptor_segment32:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula([],0);
       elf_reloc_arm_thumb_got_entry_relative_to_got_origin:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['GOT(S)','+','A','-','GOT_ORG'],12,$00000FFF);
       elf_reloc_arm_thumb_alu_abs_g0_no_check:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['(','S','+','A',')','|','T'],32,$000000FF);
       elf_reloc_arm_thumb_alu_abs_g1_no_check:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A'],32,$0000FF00);
       elf_reloc_arm_thumb_alu_abs_g2_no_check:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A'],32,$00FF0000);
       elf_reloc_arm_thumb_alu_abs_g3:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A'],32,$FF000000);
       elf_reloc_arm_thumb_bf16:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['(','(','S','+','A',')','|','T',')','-','P'],16,$0001FFFE);
       elf_reloc_arm_thumb_bf12:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['(','(','S','+','A',')','|','T',')','-','P'],12,$00001FFE);
       elf_reloc_arm_thumb_bf18:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['(','(','S','+','A',')','|','T',')','-','P'],18,$0007FFFE);
       else
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula([],0);
       end;
      end
     else if(ldarch=elf_machine_x86_64) then
      begin
       case Value of
       elf_reloc_x86_64_none:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula([],0);
       elf_reloc_x86_64_64bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A'],64);
       elf_reloc_x86_64_pc_32bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','P'],32);
       elf_reloc_x86_64_got_32bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['G','+','A'],32);
       elf_reloc_x86_64_plt_32bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['L','+','A','-','P'],32);
       elf_reloc_x86_64_copy:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula([],0);
       elf_reloc_x86_64_new_got_entry:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['S'],64);
       elf_reloc_x86_64_new_plt_entry:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['S'],64);
       elf_reloc_x86_64_relative:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['B','+','A'],64);
       elf_reloc_x86_64_pc_relative_offset_got:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['G','+','GOT','+','A','-','P'],32);
       elf_reloc_x86_64_32bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A'],32);
       elf_reloc_x86_64_32bit_sign:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A'],32);
       elf_reloc_x86_64_16bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A'],16);
       elf_reloc_x86_64_pc_16bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','P'],16);
       elf_reloc_x86_64_8bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A'],8);
       elf_reloc_x86_64_pc_8bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','P'],8);
       elf_reloc_x86_64_dtp_module_64bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['MODULE_ID'],64);
       elf_reloc_x86_64_dtp_offset_64bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['DTP(S)','+','A'],64);
       elf_reloc_x86_64_tp_offset_64bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['TP(S)','+','A'],64);
       elf_reloc_x86_64_tls_global_dynamic:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['G(TLSGD)','+','A','-','P'],32);
       elf_reloc_x86_64_tls_local_dynamic:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['G(TLSID)','+','A','-','P'],32);
       elf_reloc_x86_64_dtp_offset_32bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['DTP(S)','+','A'],32);
       elf_reloc_x86_64_got_tp_offset:
       templist2.Adjust.Formula[templist2.Adjust.count-1]:=
       ld_generate_formula(['G(TLSIE)','+','A','-','P'],32);
       elf_reloc_x86_64_tp_offset32:
       templist2.Adjust.Formula[templist2.Adjust.count-1]:=
       ld_generate_formula(['TP(S)','+','A'],32);
       elf_reloc_x86_64_pc64:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','P'],64);
       elf_reloc_x86_64_got_offset64:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','GOT'],64);
       elf_reloc_x86_64_got_pc32:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['GOT','+','A','-','P'],32);
       elf_reloc_x86_64_got64:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['G','+','A'],64);
       elf_reloc_x86_64_got_pc_relative:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['G','+','GOT','+','A','-','P'],64);
       elf_reloc_x86_64_got_pc64:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['GOT','+','A','-','P'],64);
       elf_reloc_x86_64_got_plt64:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['G(PLT)','+','A'],64);
       elf_reloc_x86_64_plt_offset64:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['L','+','A','-','GOT'],64);
       elf_reloc_x86_64_size32:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['Z','+','A'],32);
       elf_reloc_x86_64_size64:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['Z','+','A'],64);
       elf_reloc_x86_64_got_pc32_tls_descriptor:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['GOT_TLS_DESC','+','A','-','P'],32);
       elf_reloc_x86_64_tls_descriptor_call:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula([''],0);
       elf_reloc_x86_64_tls_descriptor:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['DESC_ADDR'],32);
       elf_reloc_x86_64_indirect_relative:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['B','+','A'],64);
       elf_reloc_x86_64_relative_64:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['B','+','A'],64);
       elf_reloc_x86_64_got_pc_rel:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','P'],32);
       elf_reloc_x86_64_rex_got_pc_rel:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','P'],32);
       else
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula([],0);
       end;
      end
     else if(ldarch=elf_machine_aarch64) then
      begin
       case Value of
       elf_reloc_aarch64_none:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula([],0);
       elf_reloc_aarch64_32bit_absolute:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S'],32);
       elf_reloc_aarch64_32bit_copy:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula([],32);
       elf_reloc_aarch64_32bit_new_got_entry:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S'],32);
       elf_reloc_aarch64_32bit_new_plt_entry:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S'],32);
       elf_reloc_aarch64_32bit_relative:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['B','+','A'],32);
       elf_reloc_aarch64_32bit_tls_module_number:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['MODULE_ID'],32);
       elf_reloc_aarch64_32bit_tls_module_relative_offset:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','TLS'],32);
       elf_reloc_aarch64_32bit_tls_tp_relative_offset:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','tp'],32);
       elf_reloc_aarch64_32bit_tls_descriptor:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['TLS'],32);
       elf_reloc_aarch64_32bit_indirect_relative:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula([],0);
       elf_reloc_aarch64_absolute_64bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A'],64);
       elf_reloc_aarch64_absolute_32bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A'],32);
       elf_reloc_aarch64_absolute_16bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A'],16);
       elf_reloc_aarch64_absolute_pc_relative_64bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','P'],64);
       elf_reloc_aarch64_absolute_pc_relative_32bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','P'],32);
       elf_reloc_aarch64_absolute_pc_relative_16bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','P'],16);
       elf_reloc_aarch64_plt_32:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','P'],32);
       elf_reloc_aarch64_movz_imm_bit15_0:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A'],16);
       elf_reloc_aarch64_movk_imm_bit15_0:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A'],16);
       elf_reloc_aarch64_movz_imm_bit31_16:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A'],16);
       elf_reloc_aarch64_movk_imm_bit31_16:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A'],16);
       elf_reloc_aarch64_movz_imm_bit47_32:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A'],16);
       elf_reloc_aarch64_movk_imm_bit47_32:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A'],16);
       elf_reloc_aarch64_movk_z_imm_bit64_48:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A'],16);
       elf_reloc_aarch64_movn_z_imm_bit15_0:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A'],16);
       elf_reloc_aarch64_movn_z_imm_bit31_16:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A'],16);
       elf_reloc_aarch64_movn_z_imm_bit47_32:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A'],16);
       elf_reloc_aarch64_ldr_literal_pc_rel_low19bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','P'],20,$FFFFF);
       elf_reloc_aarch64_adr_pc_rel_low21bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','P'],20,$FFFFF);
       elf_reloc_aarch64_adrp_page_rel_bit32_12:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['Page(S+A)','-','Page(P)'],20,$FFFFF);
       elf_reloc_aarch64_adrp_page_rel_bit32_12_no_check:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['Page(S+A)','-','Page(P)'],20,$FFFFF);
       elf_reloc_aarch64_add_absolute_low12bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A'],12,$FFF);
       elf_reloc_aarch64_ld_or_st_absolute_low12bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A'],12,$FFF);
       elf_reloc_aarch64_add_bit16_imm_bit11_1:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A'],12,$FFF);
       elf_reloc_aarch64_add_bit32_imm_bit11_2:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A'],12,$FFF);
       elf_reloc_aarch64_add_bit64_imm_bit11_3:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A'],12,$FFF);
       elf_reloc_aarch64_add_bit128_imm_from_bit11_4:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A'],12,$FFF);
       elf_reloc_aarch64_pc_rel_tbz_bit15_2:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','P'],14,$FFFC);
       elf_reloc_aarch64_pc_rel_cond_or_br_bit20_2:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','P'],19,$FFFFC);
       elf_reloc_aarch64_pc_rel_jump_bit27_2:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','P'],26,$FFFFFFC);
       elf_reloc_aarch64_pc_rel_call_bit27_2:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','P'],26,$FFFFFFC);
       elf_reloc_aarch64_pc_rel_movn_z_imm_bit15_0:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','P'],16,$FFFF);
       elf_reloc_aarch64_pc_rel_movk_imm_bit15_0:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','P'],16,$FFFF);
       elf_reloc_aarch64_pc_rel_movn_z_imm_bit31_16:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','P'],16,$FFFF);
       elf_reloc_aarch64_pc_rel_movk_imm_bit31_16:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','P'],16,$FFFF);
       elf_reloc_aarch64_pc_rel_movn_z_imm_bit47_32:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','P'],16,$FFFF);
       elf_reloc_aarch64_pc_rel_movk_imm_bit47_32:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','P'],16,$FFFF);
       elf_reloc_aarch64_pc_rel_movn_z_imm_bit63_48:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','P'],16,$FFFF);
       elf_reloc_aarch64_got_rel_offset_movn_z_imm_bit15_0:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['G(GDAT(S))','-','GOT'],16,$FFFF);
       elf_reloc_aarch64_got_rel_offset_movk_imm_bit15_0:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['G(GDAT(S))','-','GOT'],16,$FFFF);
       elf_reloc_aarch64_got_rel_offset_movn_z_imm_bit31_16:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['G(GDAT(S))','-','GOT'],16,$FFFF);
       elf_reloc_aarch64_got_rel_offset_movk_imm_bit31_16:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['G(GDAT(S))','-','GOT'],16,$FFFF);
       elf_reloc_aarch64_got_rel_offset_movn_z_imm_bit47_32:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['G(GDAT(S))','-','GOT'],16,$FFFF0000);
       elf_reloc_aarch64_got_rel_offset_movk_imm_bit47_32:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['G(GDAT(S))','-','GOT'],16,$0000FFFF0000);
       elf_reloc_aarch64_got_rel_offset_movn_z_imm_bit63_48:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['G(GDAT(S))','-','GOT'],16,$000000000000FFFF);
       elf_reloc_aarch64_got_relative_64bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','GOT'],64);
       elf_reloc_aarch64_got_relative_32bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','GOT'],32);
       elf_reloc_aarch64_pc_relative_got_offset32:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['G(GDAT(S))','-','GOT'],32);
       elf_reloc_aarch64_pc_rel_got_offset:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['G(GDAT(S))','-','P'],32,$FFFFC);
       elf_reloc_aarch64_got_rel_offset_ld_st_imm_bit14_3:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['G(GDAT(S))','-','GOT'],32,$3FF8);
       elf_reloc_aarch64_page_rel_adrp_bit32_12:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['Page(G(GDAT(S)))','-','Page(P)'],64,$1FFFFF000);
       elf_reloc_aarch64_dir_got_offset_ld_st_imm_bit11_3:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['G(GDAT(S))'],32,$FF8);
       elf_reloc_aarch64_got_page_rel_got_offset_ld_st_bit14_3:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['G(GDAT(S))','-','Page(GOT))'],32,$3FF8);
       elf_reloc_aarch64_pc_relative_adr_imm_bit20_0:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['G(GTSIDX(S,A))','-','P'],21,$1FFFFF);
       elf_reloc_aarch64_page_relative_adr_imm_bit32_12:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['Page(G(GTSIDX(S,A)))','-','Page(P)'],64,$1FFFFF);
       elf_reloc_aarch64_direct_add_imm_bit11_0:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['G(GTSIDX(S,A))'],32,$FFF);
       elf_reloc_aarch64_got_rel_movn_z_bit31_16:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['G(GTSIDX(S,A))','-','GOT'],16,$FFFF0000);
       elf_reloc_aarch64_got_rel_movk_imm_bit15_0:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['G(GTSIDX(S,A))','-','GOT'],16,$FFFF);
       elf_reloc_aarch64_adr_pc_relative_21bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['G(GLDM(S))','-','P'],21,$1FFFFF);
       elf_reloc_aarch64_adr_page_relative_21bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['Page(G(GLDM(S)))','-','Page(P)'],21,$1FFFFF000);
       elf_reloc_aarch64_direct_add_low_bit11_0:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['G(GLDM(S))'],12,$FFF);
       elf_reloc_aarch64_got_rel_movn_z_bit31_16_local_dynamic_model:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['G(GLDM(S))','-','GOT'],16,$FFFF0000);
       elf_reloc_aarch64_got_rel_movk_imm_bit15_0_local_dynamic_model:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['G(GLDM(S))','-','GOT'],16,$FFFF);
       elf_reloc_aarch64_tls_pc_relative:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['G(GLDM(S))','-','P'],18,$FFFFC);
       elf_reloc_aarch64_tls_dtp_rel_movn_z_bit47_32:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['DTPREL(S+A)'],16,$FFFF00000000);
       elf_reloc_aarch64_tls_dtp_rel_movn_z_bit31_16:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['DTPREL(S+A)'],16,$FFFF0000);
       elf_reloc_aarch64_tls_dtp_rel_movk_bit31_16:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['DTPREL(S+A)'],16,$FFFF0000);
       elf_reloc_aarch64_tls_dtp_rel_movn_z_bit15_0:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['DTPREL(S+A)'],16,$FFFF);
       elf_reloc_aarch64_tls_dtp_rel_movk_bit15_0:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['DTPREL(S+A)'],16,$FFFF);
       elf_reloc_aarch64_tls_dtp_rel_add_imm_bit23_12:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['DTPREL(S+A)'],12,$00FFF000);
       elf_reloc_aarch64_tls_dtp_rel_add_imm_bit11_0:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['DTPREL(S+A)'],12,$00000FFF);
       elf_reloc_aarch64_tls_dtp_rel_add_imm_no_check:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['DTPREL(S+A)'],12,$00000FFF);
       elf_reloc_aarch64_tls_dtp_rel_ld_sd_imm_bit11_0:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['DTPREL(S+A)'],12,$00000FFF);
       elf_reloc_aarch64_tls_dtp_rel_ld_sd_imm_bit11_0_no_check:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['DTPREL(S+A)'],12,$00000FFF);
       elf_reloc_aarch64_tls_dtp_rel_ld_sd_imm_bit11_1:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['DTPREL(S+A)'],12,$00000FFE);
       elf_reloc_aarch64_tls_dtp_rel_ld_sd_imm_bit11_1_no_check:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['DTPREL(S+A)'],12,$00000FFE);
       elf_reloc_aarch64_tls_dtp_rel_ld_sd_imm_bit11_2:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['DTPREL(S+A)'],12,$00000FFE);
       elf_reloc_aarch64_tls_dtp_rel_ld_sd_imm_bit11_2_no_check:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['DTPREL(S+A)'],12,$00000FFC);
       elf_reloc_aarch64_tls_dtp_rel_ld_sd_imm_bit11_3:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['DTPREL(S+A)'],12,$00000FF8);
       elf_reloc_aarch64_tls_dtp_rel_ld_sd_imm_bit11_3_no_check:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['DTPREL(S+A)'],12,$00000FF8);
       elf_reloc_aarch64_tls_dtp_rel_ld_st_imm:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['DTPREL(S+A)'],8,$00000FF0);
       elf_reloc_aarch64_tls_dtp_rel_ld_st_imm_no_check:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['DTPREL(S+A)'],8,$00000FF0);
       elf_reloc_aarch64_tls_got_rel_movn_z_bit31_16:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['G(GTPREL(S+A))','-','GOT'],16,$FFFF0000);
       elf_reloc_aarch64_tls_got_rel_movk_bit15_0:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['G(GTPREL(S+A))','-','GOT'],16,$0000FFFF);
       elf_reloc_aarch64_tls_page_rel_adrp_bit32_12:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['Page(G(GTPREL(S+A)))','-','Page(P)'],64,$1FFFFF000);
       elf_reloc_aarch64_tls_direct_ld_off_bit11_3:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['G(GTPREL(S+A))'],9,$FF8);
       elf_reloc_aarch64_tls_pc_rel_load_imm:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['G(GTPREL(S+A))','-','P'],19,$001FFFFC);
       elf_reloc_aarch64_tls_tp_rel_movn_z_bit47_32:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['TPREL(S+A)'],16,$FFFF00000000);
       elf_reloc_aarch64_tls_tp_rel_movn_z_bit31_16:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['TPREL(S+A)'],16,$FFFF0000);
       elf_reloc_aarch64_tls_tp_rel_movk_bit31_16:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['TPREL(S+A)'],16,$FFFF0000);
       elf_reloc_aarch64_tls_tp_rel_movn_z_bit15_0:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['TPREL(S+A)'],16,$FFFF);
       elf_reloc_aarch64_tls_tp_rel_movk_bit15_0:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['TPREL(S+A)'],16,$FFFF);
       elf_reloc_aarch64_tls_tp_rel_add_imm_bit23_12:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['TPREL(S+A)'],12,$FFF000);
       elf_reloc_aarch64_tls_tp_rel_add_imm_bit11_0:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['TPREL(S+A)'],12,$FFF);
       elf_reloc_aarch64_tls_tp_rel_add_no_overflow:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['TPREL(S+A)'],12,$FFF);
       elf_reloc_aarch64_tls_tp_rel_ld_st_off_bit11_0:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['TPREL(S+A)'],12,$FFF);
       elf_reloc_aarch64_tls_tp_rel_ld_st_bit11_0_no_overflow:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['TPREL(S+A)'],12,$FFF);
       elf_reloc_aarch64_tls_tp_rel_ld_st_off_bit11_1:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['TPREL(S+A)'],12,$FFE);
       elf_reloc_aarch64_tls_tp_rel_ld_st_bit11_1_no_overflow:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['TPREL(S+A)'],12,$FFE);
       elf_reloc_aarch64_tls_tp_rel_ld_st_off_bit11_2:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['TPREL(S+A)'],12,$FFC);
       elf_reloc_aarch64_tls_tp_rel_ld_st_bit11_2_no_overflow:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['TPREL(S+A)'],12,$FFC);
       elf_reloc_aarch64_tls_tp_rel_ld_st_off_bit11_3:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['TPREL(S+A)'],12,$FF8);
       elf_reloc_aarch64_tls_tp_rel_ld_st_bit11_3_no_overflow:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['TPREL(S+A)'],12,$FF8);
       elf_reloc_aarch64_tls_tp_rel_ld_st_offset:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['TPREL(S+A)'],12,$FF0);
       elf_reloc_aarch64_tls_tp_rel_ld_st_offset_no_check:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['TPREL(S+A)'],12,$FF0);
       elf_reloc_aarch64_tls_pc_rel_ld_bit20_2:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['G(GTLSDESC(S+A))','-','P'],19,$FFFFC);
       elf_reloc_aarch64_tls_pc_rel_adr_bit20_0:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['G(GTLSDESC(S+A))','-','P'],21,$FFFFC);
       elf_reloc_aarch64_tls_page_rel_adr_imm_bit32_12:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['Page(G(GTLSDESC(S+A)))','-','Page(P)'],21,$1FFFFF000);
       elf_reloc_aarch64_tls_descriptor_direct_ld_off_bit11_3:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['G(GTLSDESC(S+A))'],12,$FF8);
       elf_reloc_aarch64_tls_descriptor_direct_add_off_bit11_0:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['G(GTLSDESC(S+A))'],12,$FFF);
       elf_reloc_aarch64_tls_descriptor_got_rel_movn_z_bit31_16:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['G(GTLSDESC(S+A))-GOT'],16,$FFFF0000);
       elf_reloc_aarch64_tls_descriptor_got_rel_movk_bit15_0:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['G(GTLSDESC(S+A))-GOT'],16,$FFFF);
       elf_reloc_aarch64_tls_relax_ldr,elf_reloc_aarch64_tls_relax_add,elf_reloc_aarch64_tls_relax_blr:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula([],0);
       elf_reloc_aarch64_copy:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula([],0);
       elf_reloc_aarch64_new_global_entry:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['S+A'],64);
       elf_reloc_aarch64_new_plt_entry:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['S+A'],64);
       elf_reloc_aarch64_relative:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['B+A'],64);
       elf_reloc_aarch64_tls_dtp_module:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['DTPREL(S+A)'],64);
       elf_reloc_aarch64_tls_tp_relative_offset:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['TPREL(S+A)'],64);
       elf_reloc_aarch64_tls_descriptor:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['TLSDESC(S+A)'],64);
       elf_reloc_aarch64_indirect_relative:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['INDIRECT(TLSDESC(S+A))'],64);
       else templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula([],0);
       end;
      end
     else if(ldarch=elf_machine_riscv) then
      begin
       case Value of
       elf_reloc_riscv_none:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula([],0);
       elf_reloc_riscv_32bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['S+A'],32);
       elf_reloc_riscv_64bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['S+A'],64);
       elf_reloc_riscv_relative:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['B+A'],ldbit shl 5);
       elf_reloc_riscv_copy:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula([],0);
       elf_reloc_riscv_jump_slot:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['S'],ldbit shl 5);
       elf_reloc_riscv_tls_dtp_module32:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['TLSMODULE'],32);
       elf_reloc_riscv_tls_dtp_module64:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['TLSMODULE'],64);
       elf_reloc_riscv_tls_dtp_relative32:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['S+A-DTV_OFFSET'],32);
       elf_reloc_riscv_tls_dtp_relative64:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['S+A-DTV_OFFSET'],64);
       elf_reloc_riscv_tls_tp_relative32:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['S+A+TLS_OFFSET'],32);
       elf_reloc_riscv_tls_tp_relative64:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['S+A+TLS_OFFSET'],64);
       elf_reloc_riscv_branch:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S+A-P'],32,elf_riscv_b_type);
       elf_reloc_riscv_jal:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S+A-P'],32,elf_riscv_j_type);
       elf_reloc_riscv_call:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S+A-P'],64,elf_riscv_u_i_type);
       elf_reloc_riscv_call_plt:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S+A-P'],64,elf_riscv_u_i_type);
       elf_reloc_riscv_got_high_20bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['G+GOT+A-P'],32,elf_riscv_u_type);
       elf_reloc_riscv_tls_got_high_20bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula([],32,elf_riscv_u_type);
       elf_reloc_riscv_tls_global_descriptor_high_20bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula([],32,elf_riscv_u_type);
       elf_reloc_riscv_pc_relative_high_20bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S+A-P'],32,elf_riscv_u_type);
       elf_reloc_riscv_pc_relative_low_12bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S-P'],32,elf_riscv_i_type);
       elf_reloc_riscv_pc_relative_low_12bit_signed:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S-P'],32,elf_riscv_s_type);
       elf_reloc_riscv_high_20bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S+A'],32,elf_riscv_u_type);
       elf_reloc_riscv_low_12bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S+A'],32,elf_riscv_i_type);
       elf_reloc_riscv_low_12bit_signed:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S+A'],32,elf_riscv_s_type);
       elf_reloc_riscv_tp_relative_high_20bit,elf_reloc_riscv_tp_relative_low_12bit,
       elf_reloc_riscv_tp_relative_low_12bit_signed:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula([],32,elf_riscv_u_type);
       elf_reloc_riscv_tp_relative_add:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula([],0);
       elf_reloc_riscv_add_8bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['V+S+A'],8);
       elf_reloc_riscv_add_16bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['V+S+A'],16);
       elf_reloc_riscv_add_32bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['V+S+A'],32);
       elf_reloc_riscv_add_64bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['V+S+A'],64);
       elf_reloc_riscv_sub_8bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['V-S-A'],8);
       elf_reloc_riscv_sub_16bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['V-S-A'],16);
       elf_reloc_riscv_sub_32bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['V-S-A'],32);
       elf_reloc_riscv_sub_64bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['V-S-A'],64);
       elf_reloc_riscv_got_32_pc_relative:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['G+GOT+A-P'],32);
       elf_reloc_riscv_align:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula([],0);
       elf_reloc_riscv_rvc_branch:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S+A-P'],32,elf_riscv_cb_type);
       elf_reloc_riscv_rvc_jump:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S+A-P'],32,elf_riscv_cj_type);
       elf_reloc_riscv_relax:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula([],32);
       elf_reloc_riscv_sub_6:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['V-S-A'],6);
       elf_reloc_riscv_set_6:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S+A'],6);
       elf_reloc_riscv_set_8:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S+A'],8);
       elf_reloc_riscv_set_16:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S+A'],16);
       elf_reloc_riscv_set_32:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S+A'],32);
       elf_reloc_riscv_32_pcrel:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S+A-P'],32);
       elf_reloc_riscv_indirect_relative:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['ifunc_resolver(B+A)'],ldbit shl 5);
       elf_reloc_riscv_plt_32bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S+A-P'],32);
       elf_reloc_riscv_set_uleb128:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S+A'],128);
       elf_reloc_riscv_sub_uleb128:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['V-S-A'],128);
       elf_reloc_riscv_tls_descriptor_high_20bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S+A-P'],32);
       elf_reloc_riscv_tls_descriptor_load_low_12bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S-P'],32);
       elf_reloc_riscv_tls_descriptor_add_low_12bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S-P'],32);
       elf_reloc_riscv_tls_descriptor_call:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula([''],0);
       else
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula([''],0);
       end;
      end
     else if(ldarch=elf_machine_loongarch) then
      begin
       case Value of
       elf_reloc_loongarch_none:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula([''],0);
       elf_reloc_loongarch_32bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S+A'],32);
       elf_reloc_loongarch_64bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S+A'],64);
       elf_reloc_loongarch_relative:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['B+A'],ldbit shl 5);
       elf_reloc_loongarch_copy:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula([],0);
       elf_reloc_loongarch_jump_slot:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S'],ldbit shl 5);
       elf_reloc_loongarch_tls_dtp_module_32bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['MODULE_ID'],32);
       elf_reloc_loongarch_tls_dtp_module_64bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['MODULE_ID'],64);
       elf_reloc_loongarch_tls_dtp_relative_32bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S+A-DTV'],32);
       elf_reloc_loongarch_tls_dtp_relative_64bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S+A-DTV'],64);
       elf_reloc_loongarch_indirect_relative:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['ifunc_resolver(B+A)'],ldbit shl 5);
       elf_reloc_loongarch_tls_descriptor_32bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['TLSDESC'],32);
       elf_reloc_loongarch_tls_descriptor_64bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['TLSDESC'],64);
       elf_reloc_loongarch_mark_loongarch,elf_reloc_loongarch_mark_pc_relative:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula([],0);
       elf_reloc_loongarch_sop_push_pc_relative:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['push(S-PC+A)'],ldbit shl 5);
       elf_reloc_loongarch_sop_push_absolute:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['push(S+A)'],ldbit shl 5);
       elf_reloc_loongarch_sop_push_duplicate:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula([],ldbit shl 5);
       elf_reloc_loongarch_sop_push_gp_relative:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['push(G)'],ldbit shl 5);
       elf_reloc_loongarch_sop_push_tls_tp_relative:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['push(T)'],ldbit shl 5);
       elf_reloc_loongarch_sop_push_tls_got:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['push(IE)'],ldbit shl 5);
       elf_reloc_loongarch_sop_push_tls_global_dynamic:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['push(GD)'],ldbit shl 5);
       elf_reloc_loongarch_sop_push_plt_pc_relative:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['push(PLT-PC)'],ldbit shl 5);
       elf_reloc_loongarch_sop_assert:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['assert(pop())'],ldbit shl 5);
       elf_reloc_loongarch_sop_not,elf_reloc_loongarch_sop_sub,
       elf_reloc_loongarch_sop_sl,elf_reloc_loongarch_sop_sr,
       elf_reloc_loongarch_sop_add,elf_reloc_loongarch_sop_and,elf_reloc_loongarch_sop_if_else,
       elf_reloc_loongarch_sop_pop_32_s_10_5,elf_reloc_loongarch_sop_pop_32_u_10_12,
       elf_reloc_loongarch_sop_pop_32_s_10_12,elf_reloc_loongarch_sop_pop_32_s_10_16,
       elf_reloc_loongarch_sop_pop_32_s_10_16_s2,elf_reloc_loongarch_sop_pop_32_s_5_20,
       elf_reloc_loongarch_sop_pop_32_s_0_5_10_16_s2,
       elf_reloc_loongarch_sop_pop_32_s_0_10_10_16_s2,elf_reloc_loongarch_sop_pop_32_u:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula([],ldbit shl 5);
       elf_reloc_loongarch_add_8bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['S+A'],8);
       elf_reloc_loongarch_add_16bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['S+A'],16);
       elf_reloc_loongarch_add_24bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['S+A'],24);
       elf_reloc_loongarch_add_32bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['S+A'],32);
       elf_reloc_loongarch_add_64bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['S+A'],64);
       elf_reloc_loongarch_sub_8bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['S+A'],8);
       elf_reloc_loongarch_sub_16bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['S+A'],16);
       elf_reloc_loongarch_sub_24bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['S+A'],24);
       elf_reloc_loongarch_sub_32bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['S+A'],32);
       elf_reloc_loongarch_sub_64bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['S+A'],64);
       elf_reloc_loongarch_b16:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['S+A-PC'],16);
       elf_reloc_loongarch_b21:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['S+A-PC'],21);
       elf_reloc_loongarch_b26:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['S+A-PC'],26);
       elf_reloc_loongarch_absolute_high_20bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['S+A'],32,$000FFFFF);
       elf_reloc_loongarch_absolute_low_12bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['S+A'],32,$FFF00000);
       elf_reloc_loongarch_absolute_64bit_low_20bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['S+A'],
       64,$000FFFFF00000000);
       elf_reloc_loongarch_absolute_64bit_high_12bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['S+A'],
       64,Natuint($FFF0000000000000));
       elf_reloc_loongarch_absolute_pcala_high_20bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['Page(S+A+2048)-Page(PC)'],32,$FFFFF000);
       elf_reloc_loongarch_absolute_pcala_low_12bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S+A'],32,$00000FFF);
       elf_reloc_loongarch_absolute_pcala64_low_20bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S+A-Alignmax(PC)'],64,$000FFFFF00000000);
       elf_reloc_loongarch_absolute_pcala64_high_12bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S+A-Alignmax(PC)'],64,Natuint($FFF0000000000000));
       elf_reloc_loongarch_got_pc_high_20bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['Page(GP+G+2048)-Page(PC)'],32,$FFFFF000);
       elf_reloc_loongarch_got_pc_low_12bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['GP+G'],32,$00000FFF);
       elf_reloc_loongarch_got64_pc_low_20bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['GP+G-Alignmax(PC)'],64,$000FFFFF00000000);
       elf_reloc_loongarch_got64_pc_high_12bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['GP+G-Alignmax(PC)'],64,Natuint($FFF0000000000000));
       elf_reloc_loongarch_got_high_20bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['GP+G'],32,$FFFFF000);
       elf_reloc_loongarch_got_low_12bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['GP+G'],32,$00000FFF);
       elf_reloc_loongarch_got64_low_20bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['GP+G'],64,$000FFFFF00000000);
       elf_reloc_loongarch_got64_high_12bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['GP+G'],64,Natuint($FFF0000000000000));
       elf_reloc_loongarch_tls_le_high_20bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['TLSLE'],32,$FFFFF000);
       elf_reloc_loongarch_tls_le_low_12bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['TLSLE'],32,$00000FFF);
       elf_reloc_loongarch_tls_le64_low_20bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['TLSLE'],64,$000FFFFF00000000);
       elf_reloc_loongarch_tls_le64_high_12bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['TLSLE'],64,Natuint($FFF0000000000000));
       elf_reloc_loongarch_tls_ie_pc_high_20bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['GP+IE-PC'],32,$FFFFF000);
       elf_reloc_loongarch_tls_ie_pc_low_12bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['GP+IE-PC'],32,$00000FFF);
       elf_reloc_loongarch_tls_ie64_pc_low_20bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['GP+IE-PC'],64,$000FFFFF00000000);
       elf_reloc_loongarch_tls_ie64_pc_high_12bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['GP+IE-PC'],64,Natuint($FFF0000000000000));
       elf_reloc_loongarch_tls_ie_high_20bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['GP+IE'],32,$FFFFF000);
       elf_reloc_loongarch_tls_ie_low_12bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['GP+IE'],32,$00000FFF);
       elf_reloc_loongarch_tls_ie64_high_20bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['GP+IE'],64,Natuint($FFFFF00000000000));
       elf_reloc_loongarch_tls_ie64_low_12bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['GP+IE'],64,$00000FFF00000000);
       elf_reloc_loongarch_tls_ld_pc_high_20bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['GP+GD-PC'],32,$FFFFF000);
       elf_reloc_loongarch_tls_ld_high_20bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['GP+IE'],32,$FFFFF000);
       elf_reloc_loongarch_tls_global_dynamic_pc_high_20bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['GP+GD-PC'],32,$00000FFF);
       elf_reloc_loongarch_tls_global_dynamic_high_20bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['GP+IE'],32,$00000FFF);
       elf_reloc_loongarch_32_pc_relative:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S+A-PC'],32,$00000FFF);
       else
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula([],0);
       end;
      end;
     if(templist2.Adjust.Formula[templist2.Adjust.Count-1].item.count=0) then
     dec(templist2.Adjust.Count);
    end;
  end;
 {Initialize the adjustment using relatives}
 for i:=1 to middlelist.SecRelaCount do
  begin
   if(middlelist.SecRelaHash[i-1]=0) then continue;
   c:=ld_search_for_index(hashtable2,dynnatuintarray(middlelist.SymTable.SymbolSectionHash),
   middlelist.SecRelaHash[i-1]);
   if(c=0) then continue;
   k:=templist1.ObjFile[middlelist.SymTable.SymbolFileIndex[c-1]-1].
   SecNowIndex[middlelist.SymTable.SymbolIndex[c-1]];
   m:=templist1.ObjFile[middlelist.SymTable.SymbolFileIndex[c-1]-1].
   SecNowPos[middlelist.SymTable.SymbolIndex[c-1]];
   if(k=0) or (m=0) then continue;
   for j:=1 to middlelist.SecRela[i-1].SymCount do
    begin
     if(ldarch=elf_machine_riscv) and
     (middlelist.SecRela[i-1].SymType[j-1]=elf_reloc_riscv_align) then continue
     else if(ldarch=elf_machine_riscv) and
     (middlelist.SecRela[i-1].SymType[j-1]=elf_reloc_riscv_relax) then
      begin
       templist2.Adjust.AdjustRelax[templist2.Adjust.Count-1]:=true; continue;
      end
     else if(ldarch=elf_machine_loongarch) and
     (middlelist.SecRela[i-1].SymType[j-1]=elf_reloc_loongarch_relax) then
      begin
       templist2.Adjust.AdjustRelax[templist2.Adjust.Count-1]:=true; continue;
      end;
     if(middlelist.SecRela[i-1].SymHash[j-1]=0) then continue;
     d:=ld_search_for_index(hashtable,dynnatuintarray(middlelist.SymTable.SymbolNameHash),
     middlelist.SecRela[i-1].SymHash[j-1]);
     if(d>0) then
      begin
       c:=ld_search_for_index(hashtable2,dynnatuintarray(middlelist.SymTable.SymbolSectionHash),
       middlelist.SymTable.SymbolSectionHash[d-1]);
      end
     else c:=0;
     if(c<>0) then
      begin
       a:=templist1.ObjFile[middlelist.SymTable.SymbolFileIndex[c-1]-1].
       SecNowIndex[middlelist.SymTable.SymbolIndex[c-1]];
       b:=templist1.ObjFile[middlelist.SymTable.SymbolFileIndex[c-1]-1].
       SecNowPos[middlelist.SymTable.SymbolIndex[c-1]];
      end
     else
      begin
       a:=0; b:=0;
      end;
     {If the relocation can jump to,Jump to this relocation}
     inc(templist2.Adjust.Count);
     templist2.Adjust.SrcIndex[templist2.Adjust.count-1]:=k;
     templist2.Adjust.SrcOffset[templist2.Adjust.Count-1]:=
     templist2.SecContent[k-1].SecOffset[m-1]+middlelist.SecRela[i-1].SymOffset[j-1];
     templist2.Adjust.DestIndex[templist2.Adjust.Count-1]:=a;
     if(a<>0) then
      begin
       templist2.Adjust.DestOffset[templist2.Adjust.Count-1]:=templist2.SecContent[a-1].SecOffset[b-1];
      end
     else
      begin
       templist2.Adjust.DestOffset[templist2.Adjust.Count-1]:=0;
      end;
     templist2.Adjust.AdjustName[templist2.Adjust.Count-1]:=middlelist.SymTable.SymbolName[d-1];
     templist2.Adjust.AdjustHash[templist2.Adjust.Count-1]:=
     generate_hash_from_string(middlelist.SymTable.SymbolName[d-1]);
     if(templist2.SymTable.SymbolType[m-1]=elf_symbol_type_function) then
     templist2.Adjust.AdjustFunc[templist2.Adjust.Count-1]:=true
     else templist2.Adjust.AdjustFunc[templist2.Adjust.Count-1]:=false;
     Value:=middlelist.SecRela[i-1].SymType[j-1];
     templist2.Adjust.AdjustType[templist2.Adjust.Count-1]:=Value;
     templist2.Adjust.Addend[templist2.Adjust.Count-1]:=middlelist.SecRela[i-1].SymAddend[j-1];
     templist2.Adjust.AdjustRelax[templist2.Adjust.Count-1]:=false;
     if(ldarch=elf_machine_386) then
      begin
       case Value of
       elf_reloc_i386_none:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula([],0);
       elf_reloc_i386_32bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A'],32);
       elf_reloc_i386_pc32:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','P'],32);
       elf_reloc_i386_got32:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['G','+','A'],32);
       elf_reloc_i386_plt32:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['L','+','A','-','P'],32);
       elf_reloc_i386_copy:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula([],0);
       elf_reloc_i386_new_got_entry:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S'],32);
       elf_reloc_i386_new_plt_entry:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S'],32);
       elf_reloc_i386_relative:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['B','+','A'],32);
       elf_reloc_i386_got_offset:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','GOT'],32);
       elf_reloc_i386_32bit_pc_relative_offset:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['GOT','+','A','-','P'],32);
       elf_reloc_i386_32plt:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['L','+','A'],32);
       elf_reloc_i386_offset_in_static_tls_block:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['TLS_OFFSET'],32);
       elf_reloc_i386_address_of_got_entry_for_static_tls_block_offset:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['GOT_TLS','+','A'],32);
       elf_reloc_i386_got_entry_for_static_tls_block_offset:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['GOT_TLS','+','A'],32);
       elf_reloc_i386_offset_relative_to_static_tls_block:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['TLS_OFFSET'],32);
       elf_reloc_i386_general_dynamic_thread:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['GOT_TLS_GD','+','A'],32);
       elf_reloc_i386_local_dynamic_thread:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['GOT_TLS_LDM','+','A'],32);
       elf_reloc_i386_16bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A'],16);
       elf_reloc_i386_pc16bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','P'],16);
       elf_reloc_i386_8bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A'],8);
       elf_reloc_i386_pc8bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','P'],8);
       elf_reloc_i386_tls_general_dynamic_thread_32bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['GOT_TLS_GD','+','A'],32);
       elf_reloc_i386_tls_local_dynamic_thread_32bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['GOT_TLS_LDM','+','A'],32);
       elf_reloc_i386_offset_relative_for_tls_block:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A'],32);
       elf_reloc_i386_ie_32bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['GOT_TLS_IE','+','A'],32);
       elf_reloc_i386_le_32bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['-','TLS_OFFSET'],32);
       elf_reloc_i386_tls_module_containing_symbol:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['MODULE_ID'],32);
       elf_reloc_i386_tls_offset_in_tls_block:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['DTP_OFFSET'],32);
       elf_reloc_i386_tls_negated_offset:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['-','TLS_OFFSET'],32);
       elf_reloc_i386_tls_got_offset_for_tls_descriptor:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['Z','+','A'],32);
       elf_reloc_i386_tls_descriptor:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['DESC_ADDR'],32);
       elf_reloc_i386_indirect_relative:
       templist2.Adjust.Formula[templist2.Adjust.count-1]:=
       ld_generate_formula(['IFUNC_RESOLVER'],32);
       elf_reloc_i386_got_relaxable:
       templist2.Adjust.Formula[templist2.Adjust.count-1]:=
       ld_generate_formula(['G','+','A'],32);
       end;
      end
     else if(ldarch=elf_machine_arm) then
      begin
       case Value of
       elf_reloc_arm_none:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula([],0);
       elf_reloc_arm_pc_relative_26bit_branch:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['(','S','+','A',')','|','T','-','P'],26);
       elf_reloc_arm_absolute_32bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['(','S','+','A',')','|','T'],32);
       elf_reloc_arm_pc_relative_32bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['(','S','+','A',')','|','T','-','P'],32);
       elf_reloc_arm_pc_relative_13bit_branch:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','P'],32);
       elf_reloc_arm_absolute_16bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A'],16);
       elf_reloc_arm_absolute_12bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A'],12,$FFF);
       elf_reloc_arm_thumb_absolute_5bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A'],5,$7C);
       elf_reloc_arm_absolute_8bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A'],8);
       elf_reloc_arm_sb_reloc_32bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['(','S','+','A',')','|','T','-','B(S)'],32);
       elf_reloc_arm_thumb_pc_22bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['(','S','+','A',')','|','T','-','P'],22,$01FFFFFFE);
       elf_reloc_arm_thumb_pc_8bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','Pa'],8,$3FC);
       elf_reloc_arm_amp_vcall_9bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['ChangeIn[B(S)]','+','A'],9);
       elf_reloc_arm_tls_descriptor:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula([],0);
       elf_reloc_arm_thumb_swi8,elf_reloc_arm_xpc25,elf_reloc_arm_thumb_xpc22:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula([],0);
       elf_reloc_arm_tls_dtp_module:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['Module[S]'],32);
       elf_reloc_arm_tls_dtp_offset:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','TLS'],32);
       elf_reloc_arm_tls_tp_offset:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','tp'],32);
       elf_reloc_arm_copy:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula([],0);
       elf_reloc_arm_new_got_entry:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['(','S','+','A',')','|','T'],32);
       elf_reloc_arm_new_plt_entry:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['(','S','+','A',')','|','T'],32);
       elf_reloc_arm_relative:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['B(S)','+','A'],32);
       elf_reloc_arm_got_offset:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['(','(','S','+','A',')','|','T','-','GOT_ORG'],32);
       elf_reloc_arm_pc_relative_got_offset:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['B(S)','+','A','-','P'],32);
       elf_reloc_arm_got_entry_32bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['GOT(S)','+','A','-','GOT_ORG'],32);
       elf_reloc_arm_plt_address_32bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['(','S','+','A',')','|','T','-','P'],32);
       elf_reloc_arm_call:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['(','S','+','A',')','|','T','-','P'],32,$03FFFFFE);
       elf_reloc_arm_pc_relative_24bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['(','S','+','A',')','|','T','-','P'],24,$03FFFFFE);
       elf_reloc_arm_thumb_pc_relative_24bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['(','S','+','A',')','|','T','-','P'],24);
       elf_reloc_arm_base_absolute:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['B(S)','+','A'],32);
       elf_reloc_arm_alu_pcrel_bit7_0,elf_reloc_arm_alu_pcrel_bit15_8,elf_reloc_arm_alu_pcrel_bit23_16:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula([],0);
       elf_reloc_arm_ldr_sbrel_bit11_0:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','B(S)'],12);
       elf_reloc_arm_alu_sbrel_bit19_12:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','B(S)'],8);
       elf_reloc_arm_alu_sbrel_bit27_20:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','B(S)'],8);
       elf_reloc_arm_target1:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['(','S','+','A',')','|','T'],32);
       elf_reloc_arm_program_base_relative:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['(','(','S','+','A',')','|','T',')','-','B(S)'],32);
       elf_reloc_arm_v4bx,elf_reloc_arm_target2:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula([],0);
       elf_reloc_arm_31bit_pc_relative:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['(','(','S','+','A',')','|','T',')','-','P'],31);
       elf_reloc_arm_movw_absolute_16bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['(','S','+','A',')','|','T'],16,$FFFF);
       elf_reloc_arm_movt_absolute:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A'],32,$FFFF0000);
       elf_reloc_arm_movw_pc_relative:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['(','(','S','+','A',')','|','T',')','-','P'],16,$FFFF);
       elf_reloc_arm_movt_pc_relative:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','P'],32,$FFFF0000);
       elf_reloc_arm_thumb_movw_absolute:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['(','S','+','A',')','|','T'],32,$0000FFFF);
       elf_reloc_arm_thumb_movt_absolute:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A'],32,$FFFF0000);
       elf_reloc_arm_thumb_movw_pc_relative:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['(','(','S','+','A',')','|','T',')','-','P'],32,$0000FFFF);
       elf_reloc_arm_thumb_movt_pc_relative:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','P'],32,$FFFF0000);
       elf_reloc_arm_thumb_pc_relative_20bit_b:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['(','(','S','+','A',')','|','T',')','-','Pa'],20,$001FFFFE);
       elf_reloc_arm_thumb_pc_relative_6bit_b:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','Pa'],6,$7E);
       elf_reloc_arm_thumb_alu_pc_relative_bit11_0:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['(','(','S','+','A',')','|','T','-','Pa'],12,$00000FFF);
       elf_reloc_arm_thumb_pc_12bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','Pa'],12);
       elf_reloc_arm_absolute_32bit_no_interrupt:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A'],32);
       elf_reloc_arm_pc_relative_32bit_no_interrupt:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','P'],32);
       elf_reloc_arm_alu_pc_relative_g0_no_check:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['(','(','S','+','A',')','|','T',')','-','P'],32);
       elf_reloc_arm_alu_pc_relative_g0:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['(','(','S','+','A',')','|','T',')','-','P'],32);
       elf_reloc_arm_alu_pc_relative_g1_no_check:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['(','(','S','+','A',')','|','T',')','-','P'],32);
       elf_reloc_arm_alu_pc_relative_g1:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['(','(','S','+','A',')','|','T',')','-','P'],32);
       elf_reloc_arm_alu_pc_relative_g2:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['(','(','S','+','A',')','|','T',')','-','P'],32);
       elf_reloc_arm_ldr_str_ldrb_strb_pc_relative_g1:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','P'],32);
       elf_reloc_arm_ldr_str_ldrb_strb_pc_relative_g2:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','P'],32);
       elf_reloc_arm_ldr_str_pc_relative_g0:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','P'],32);
       elf_reloc_arm_ldr_str_pc_relative_g1:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','P'],32);
       elf_reloc_arm_ldr_str_pc_relative_g2:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','P'],32);
       elf_reloc_arm_ldc_stc_pc_relative_g0:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','P'],32);
       elf_reloc_arm_ldc_stc_pc_relative_g1:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','P'],32);
       elf_reloc_arm_ldc_stc_pc_relative_g2:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','P'],32);
       elf_reloc_arm_alu_program_base_relative_add_sub_g0_no_check:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['(','(','S','+','A',')','|','T','-','B(S)'],32);
       elf_reloc_arm_alu_program_base_relative_add_sub_g0:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['(','(','S','+','A',')','|','T','-','B(S)'],32);
       elf_reloc_arm_alu_program_base_relative_add_sub_g1_no_check:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['(','(','S','+','A',')','|','T','-','B(S)'],32);
       elf_reloc_arm_alu_program_base_relative_add_sub_g1:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['(','(','S','+','A',')','|','T','-','B(S)'],32);
       elf_reloc_arm_alu_program_base_relative_add_sub_g2:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['(','(','S','+','A',')','|','T','-','B(S)'],32);
       elf_reloc_arm_program_base_relative_ldr_str_ldrb_strb_g0:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','B(S)'],32);
       elf_reloc_arm_program_base_relative_ldr_str_ldrb_strb_g1:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','B(S)'],32);
       elf_reloc_arm_program_base_relative_ldr_str_ldrb_strb_g2:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','B(S)'],32);
       elf_reloc_arm_program_base_relative_ldrs_g0:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','B(S)'],32);
       elf_reloc_arm_program_base_relative_ldrs_g1:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','B(S)'],32);
       elf_reloc_arm_program_base_relative_ldrs_g2:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','B(S)'],32);
       elf_reloc_arm_ldc_base_relative_g0:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','B(S)'],32);
       elf_reloc_arm_ldc_base_relative_g1:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','B(S)'],32);
       elf_reloc_arm_ldc_base_relative_g2:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','B(S)'],32);
       elf_reloc_arm_movw_base_relative_no_check:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['(','(','S','+','A',')','|','T',')','-','B(S)'],16,$FFFF);
       elf_reloc_arm_movt_base_relative:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','B(S)'],32,$FFFF0000);
       elf_reloc_arm_movw_base_relative:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['(','(','S','+','A',')','|','T',')','-','B(S)'],16,$FFFF);
       elf_reloc_arm_thumb_movw_base_relative_no_check:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['(','(','S','+','A',')','|','T',')','-','B(S)'],32,$0000FFFF);
       elf_reloc_arm_thumb_movt_base_relative:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','B(S)'],32,$FFFF0000);
       elf_reloc_arm_thumb_movw_base_relative:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['(','(','S','+','A',')','|','T',')','-','B(S)'],32,$0000FFFF);
       elf_reloc_arm_tls_got_descriptor:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula([],0);
       elf_reloc_arm_tls_call:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula([],0);
       elf_reloc_arm_tls_descriptor_segment:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula([],0);
       elf_reloc_arm_thumb_tls_call:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula([],0);
       elf_reloc_arm_absolute_plt32:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['PLT(S)','+','A'],32);
       elf_reloc_arm_got_absolute:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['GOT(S)','+','A'],32);
       elf_reloc_arm_got_pc_relative:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['GOT(S)','+','A','-','P'],32);
       elf_reloc_arm_got_relative_to_got_origin:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['GOT(S)','+','A','-','GOT_ORG'],12,$FFF);
       elf_reloc_arm_got_offset_12bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','GOT_ORG'],12,$FFF);
       elf_reloc_arm_got_relax:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula([],0);
       elf_reloc_arm_gnu_vt_entry:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula([],0);
       elf_reloc_arm_gnu_vt_inherit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula([],0);
       elf_reloc_arm_thumb_pc_11bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','P'],11,$FFE);
       elf_reloc_arm_thumb_pc_9bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','P'],9,$1FE);
       elf_reloc_arm_tls_global_dynamic_32bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['GOT(S)','+','A','-','P'],12,$FFF);
       elf_reloc_arm_tls_local_dynamic_32bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['GOT(S)','+','A','-','P'],12,$FFF);
       elf_reloc_arm_tls_local_dynamic_offset_32bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','TLS'],32);
       elf_reloc_arm_tls_ie32:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['GOT(S)','+','A','-','P'],32);
       elf_reloc_arm_tls_le32:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','tp'],32);
       elf_reloc_arm_tls_ldo12:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','TLS'],12);
       elf_reloc_arm_tls_le12:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','tp'],12);
       elf_reloc_arm_tls_ie12gp:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['GOT(S)','+','A','-','GOT_ORG'],12);
       elf_reloc_arm_me_too:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula([],0);
       elf_reloc_arm_thumb_tls_descriptor_segment16:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula([],0);
       elf_reloc_arm_thumb_tls_descriptor_segment32:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula([],0);
       elf_reloc_arm_thumb_got_entry_relative_to_got_origin:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['GOT(S)','+','A','-','GOT_ORG'],12,$00000FFF);
       elf_reloc_arm_thumb_alu_abs_g0_no_check:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['(','S','+','A',')','|','T'],32,$000000FF);
       elf_reloc_arm_thumb_alu_abs_g1_no_check:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A'],32,$0000FF00);
       elf_reloc_arm_thumb_alu_abs_g2_no_check:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A'],32,$00FF0000);
       elf_reloc_arm_thumb_alu_abs_g3:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A'],32,$FF000000);
       elf_reloc_arm_thumb_bf16:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['(','(','S','+','A',')','|','T',')','-','P'],16,$0001FFFE);
       elf_reloc_arm_thumb_bf12:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['(','(','S','+','A',')','|','T',')','-','P'],12,$00001FFE);
       elf_reloc_arm_thumb_bf18:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['(','(','S','+','A',')','|','T',')','-','P'],18,$0007FFFE);
       else
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula([],0);
       end;
      end
     else if(ldarch=elf_machine_x86_64) then
      begin
       case Value of
       elf_reloc_x86_64_none:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula([],0);
       elf_reloc_x86_64_64bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A'],64);
       elf_reloc_x86_64_pc_32bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','P'],32);
       elf_reloc_x86_64_got_32bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['G','+','A'],32);
       elf_reloc_x86_64_plt_32bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['L','+','A','-','P'],32);
       elf_reloc_x86_64_copy:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula([],0);
       elf_reloc_x86_64_new_got_entry:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['S'],64);
       elf_reloc_x86_64_new_plt_entry:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['S'],64);
       elf_reloc_x86_64_relative:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['B','+','A'],64);
       elf_reloc_x86_64_pc_relative_offset_got:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['G','+','GOT','+','A','-','P'],32);
       elf_reloc_x86_64_32bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A'],32);
       elf_reloc_x86_64_32bit_sign:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A'],32);
       elf_reloc_x86_64_16bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A'],16);
       elf_reloc_x86_64_pc_16bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','P'],16);
       elf_reloc_x86_64_8bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A'],8);
       elf_reloc_x86_64_pc_8bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','P'],8);
       elf_reloc_x86_64_dtp_module_64bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['MODULE_ID'],64);
       elf_reloc_x86_64_dtp_offset_64bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['DTP(S)','+','A'],64);
       elf_reloc_x86_64_tp_offset_64bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['TP(S)','+','A'],64);
       elf_reloc_x86_64_tls_global_dynamic:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['G(TLSGD)','+','A','-','P'],32);
       elf_reloc_x86_64_tls_local_dynamic:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['G(TLSID)','+','A','-','P'],32);
       elf_reloc_x86_64_dtp_offset_32bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['DTP(S)','+','A'],32);
       elf_reloc_x86_64_got_tp_offset:
       templist2.Adjust.Formula[templist2.Adjust.count-1]:=
       ld_generate_formula(['G(TLSIE)','+','A','-','P'],32);
       elf_reloc_x86_64_tp_offset32:
       templist2.Adjust.Formula[templist2.Adjust.count-1]:=
       ld_generate_formula(['TP(S)','+','A'],32);
       elf_reloc_x86_64_pc64:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','P'],64);
       elf_reloc_x86_64_got_offset64:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','GOT'],64);
       elf_reloc_x86_64_got_pc32:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['GOT','+','A','-','P'],32);
       elf_reloc_x86_64_got64:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['G','+','A'],64);
       elf_reloc_x86_64_got_pc_relative:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['G','+','GOT','+','A','-','P'],64);
       elf_reloc_x86_64_got_pc64:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['GOT','+','A','-','P'],64);
       elf_reloc_x86_64_got_plt64:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['G(PLT)','+','A'],64);
       elf_reloc_x86_64_plt_offset64:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['L','+','A','-','GOT'],64);
       elf_reloc_x86_64_size32:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['Z','+','A'],32);
       elf_reloc_x86_64_size64:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['Z','+','A'],64);
       elf_reloc_x86_64_got_pc32_tls_descriptor:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['GOT_TLS_DESC','+','A','-','P'],32);
       elf_reloc_x86_64_tls_descriptor_call:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula([''],0);
       elf_reloc_x86_64_tls_descriptor:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['DESC_ADDR'],32);
       elf_reloc_x86_64_indirect_relative:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['B','+','A'],64);
       elf_reloc_x86_64_relative_64:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['B','+','A'],64);
       elf_reloc_x86_64_got_pc_rel:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','P'],32);
       elf_reloc_x86_64_rex_got_pc_rel:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','P'],32);
       else
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula([],0);
       end;
      end
     else if(ldarch=elf_machine_aarch64) then
      begin
       case Value of
       elf_reloc_aarch64_none:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula([],0);
       elf_reloc_aarch64_32bit_absolute:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S'],32);
       elf_reloc_aarch64_32bit_copy:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula([],32);
       elf_reloc_aarch64_32bit_new_got_entry:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S'],32);
       elf_reloc_aarch64_32bit_new_plt_entry:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S'],32);
       elf_reloc_aarch64_32bit_relative:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['B','+','A'],32);
       elf_reloc_aarch64_32bit_tls_module_number:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['MODULE_ID'],32);
       elf_reloc_aarch64_32bit_tls_module_relative_offset:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','TLS'],32);
       elf_reloc_aarch64_32bit_tls_tp_relative_offset:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','tp'],32);
       elf_reloc_aarch64_32bit_tls_descriptor:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['TLS'],32);
       elf_reloc_aarch64_32bit_indirect_relative:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula([],0);
       elf_reloc_aarch64_absolute_64bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A'],64);
       elf_reloc_aarch64_absolute_32bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A'],32);
       elf_reloc_aarch64_absolute_16bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A'],16);
       elf_reloc_aarch64_absolute_pc_relative_64bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','P'],64);
       elf_reloc_aarch64_absolute_pc_relative_32bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','P'],32);
       elf_reloc_aarch64_absolute_pc_relative_16bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','P'],16);
       elf_reloc_aarch64_plt_32:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','P'],32);
       elf_reloc_aarch64_movz_imm_bit15_0:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A'],16);
       elf_reloc_aarch64_movk_imm_bit15_0:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A'],16);
       elf_reloc_aarch64_movz_imm_bit31_16:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A'],16);
       elf_reloc_aarch64_movk_imm_bit31_16:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A'],16);
       elf_reloc_aarch64_movz_imm_bit47_32:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A'],16);
       elf_reloc_aarch64_movk_imm_bit47_32:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A'],16);
       elf_reloc_aarch64_movk_z_imm_bit64_48:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A'],16);
       elf_reloc_aarch64_movn_z_imm_bit15_0:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A'],16);
       elf_reloc_aarch64_movn_z_imm_bit31_16:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A'],16);
       elf_reloc_aarch64_movn_z_imm_bit47_32:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A'],16);
       elf_reloc_aarch64_ldr_literal_pc_rel_low19bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','P'],20,$FFFFF);
       elf_reloc_aarch64_adr_pc_rel_low21bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','P'],20,$FFFFF);
       elf_reloc_aarch64_adrp_page_rel_bit32_12:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['Page(S+A)','-','Page(P)'],20,$FFFFF);
       elf_reloc_aarch64_adrp_page_rel_bit32_12_no_check:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['Page(S+A)','-','Page(P)'],20,$FFFFF);
       elf_reloc_aarch64_add_absolute_low12bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A'],12,$FFF);
       elf_reloc_aarch64_ld_or_st_absolute_low12bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A'],12,$FFF);
       elf_reloc_aarch64_add_bit16_imm_bit11_1:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A'],12,$FFF);
       elf_reloc_aarch64_add_bit32_imm_bit11_2:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A'],12,$FFF);
       elf_reloc_aarch64_add_bit64_imm_bit11_3:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A'],12,$FFF);
       elf_reloc_aarch64_add_bit128_imm_from_bit11_4:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A'],12,$FFF);
       elf_reloc_aarch64_pc_rel_tbz_bit15_2:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','P'],14,$FFFC);
       elf_reloc_aarch64_pc_rel_cond_or_br_bit20_2:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','P'],19,$FFFFC);
       elf_reloc_aarch64_pc_rel_jump_bit27_2:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','P'],26,$FFFFFFC);
       elf_reloc_aarch64_pc_rel_call_bit27_2:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','P'],26,$FFFFFFC);
       elf_reloc_aarch64_pc_rel_movn_z_imm_bit15_0:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','P'],16,$FFFF);
       elf_reloc_aarch64_pc_rel_movk_imm_bit15_0:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','P'],16,$FFFF);
       elf_reloc_aarch64_pc_rel_movn_z_imm_bit31_16:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','P'],16,$FFFF);
       elf_reloc_aarch64_pc_rel_movk_imm_bit31_16:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','P'],16,$FFFF);
       elf_reloc_aarch64_pc_rel_movn_z_imm_bit47_32:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','P'],16,$FFFF);
       elf_reloc_aarch64_pc_rel_movk_imm_bit47_32:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','P'],16,$FFFF);
       elf_reloc_aarch64_pc_rel_movn_z_imm_bit63_48:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','P'],16,$FFFF);
       elf_reloc_aarch64_got_rel_offset_movn_z_imm_bit15_0:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['G(GDAT(S))','-','GOT'],16,$FFFF);
       elf_reloc_aarch64_got_rel_offset_movk_imm_bit15_0:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['G(GDAT(S))','-','GOT'],16,$FFFF);
       elf_reloc_aarch64_got_rel_offset_movn_z_imm_bit31_16:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['G(GDAT(S))','-','GOT'],16,$FFFF);
       elf_reloc_aarch64_got_rel_offset_movk_imm_bit31_16:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['G(GDAT(S))','-','GOT'],16,$FFFF);
       elf_reloc_aarch64_got_rel_offset_movn_z_imm_bit47_32:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['G(GDAT(S))','-','GOT'],16,$FFFF0000);
       elf_reloc_aarch64_got_rel_offset_movk_imm_bit47_32:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['G(GDAT(S))','-','GOT'],16,$0000FFFF0000);
       elf_reloc_aarch64_got_rel_offset_movn_z_imm_bit63_48:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['G(GDAT(S))','-','GOT'],16,$000000000000FFFF);
       elf_reloc_aarch64_got_relative_64bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','GOT'],64);
       elf_reloc_aarch64_got_relative_32bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S','+','A','-','GOT'],32);
       elf_reloc_aarch64_pc_relative_got_offset32:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['G(GDAT(S))','-','GOT'],32);
       elf_reloc_aarch64_pc_rel_got_offset:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['G(GDAT(S))','-','P'],32,$FFFFC);
       elf_reloc_aarch64_got_rel_offset_ld_st_imm_bit14_3:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['G(GDAT(S))','-','GOT'],32,$3FF8);
       elf_reloc_aarch64_page_rel_adrp_bit32_12:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['Page(G(GDAT(S)))','-','Page(P)'],64,$1FFFFF000);
       elf_reloc_aarch64_dir_got_offset_ld_st_imm_bit11_3:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['G(GDAT(S))'],11,$FF8);
       elf_reloc_aarch64_got_page_rel_got_offset_ld_st_bit14_3:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['G(GDAT(S))','-','Page(GOT)'],14,$3FF8);
       elf_reloc_aarch64_pc_relative_adr_imm_bit20_0:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['G(GTSIDX(S,A))','-','P'],21,$1FFFFF);
       elf_reloc_aarch64_page_relative_adr_imm_bit32_12:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['Page(G(GTSIDX(S,A)))','-','Page(P)'],64,$1FFFFF);
       elf_reloc_aarch64_direct_add_imm_bit11_0:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['G(GTSIDX(S,A))'],32,$FFF);
       elf_reloc_aarch64_got_rel_movn_z_bit31_16:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['G(GTSIDX(S,A))','-','GOT'],16,$FFFF0000);
       elf_reloc_aarch64_got_rel_movk_imm_bit15_0:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['G(GTSIDX(S,A))','-','GOT'],16,$FFFF);
       elf_reloc_aarch64_adr_pc_relative_21bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['G(GLDM(S))','-','P'],21,$1FFFFF);
       elf_reloc_aarch64_adr_page_relative_21bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['Page(G(GLDM(S)))','-','Page(P)'],21,$1FFFFF000);
       elf_reloc_aarch64_direct_add_low_bit11_0:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['G(GLDM(S))'],12,$FFF);
       elf_reloc_aarch64_got_rel_movn_z_bit31_16_local_dynamic_model:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['G(GLDM(S))','-','GOT'],16,$FFFF0000);
       elf_reloc_aarch64_got_rel_movk_imm_bit15_0_local_dynamic_model:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['G(GLDM(S))','-','GOT'],16,$FFFF);
       elf_reloc_aarch64_tls_pc_relative:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['G(GLDM(S))','-','P'],18,$FFFFC);
       elf_reloc_aarch64_tls_dtp_rel_movn_z_bit47_32:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['DTPREL(S+A)'],16,$FFFF00000000);
       elf_reloc_aarch64_tls_dtp_rel_movn_z_bit31_16:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['DTPREL(S+A)'],16,$FFFF0000);
       elf_reloc_aarch64_tls_dtp_rel_movk_bit31_16:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['DTPREL(S+A)'],16,$FFFF0000);
       elf_reloc_aarch64_tls_dtp_rel_movn_z_bit15_0:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['DTPREL(S+A)'],16,$FFFF);
       elf_reloc_aarch64_tls_dtp_rel_movk_bit15_0:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['DTPREL(S+A)'],16,$FFFF);
       elf_reloc_aarch64_tls_dtp_rel_add_imm_bit23_12:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['DTPREL(S+A)'],12,$00FFF000);
       elf_reloc_aarch64_tls_dtp_rel_add_imm_bit11_0:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['DTPREL(S+A)'],12,$00000FFF);
       elf_reloc_aarch64_tls_dtp_rel_add_imm_no_check:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['DTPREL(S+A)'],12,$00000FFF);
       elf_reloc_aarch64_tls_dtp_rel_ld_sd_imm_bit11_0:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['DTPREL(S+A)'],12,$00000FFF);
       elf_reloc_aarch64_tls_dtp_rel_ld_sd_imm_bit11_0_no_check:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['DTPREL(S+A)'],12,$00000FFF);
       elf_reloc_aarch64_tls_dtp_rel_ld_sd_imm_bit11_1:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['DTPREL(S+A)'],12,$00000FFE);
       elf_reloc_aarch64_tls_dtp_rel_ld_sd_imm_bit11_1_no_check:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['DTPREL(S+A)'],12,$00000FFE);
       elf_reloc_aarch64_tls_dtp_rel_ld_sd_imm_bit11_2:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['DTPREL(S+A)'],12,$00000FFE);
       elf_reloc_aarch64_tls_dtp_rel_ld_sd_imm_bit11_2_no_check:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['DTPREL(S+A)'],12,$00000FFC);
       elf_reloc_aarch64_tls_dtp_rel_ld_sd_imm_bit11_3:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['DTPREL(S+A)'],12,$00000FF8);
       elf_reloc_aarch64_tls_dtp_rel_ld_sd_imm_bit11_3_no_check:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['DTPREL(S+A)'],12,$00000FF8);
       elf_reloc_aarch64_tls_dtp_rel_ld_st_imm:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['DTPREL(S+A)'],8,$00000FF0);
       elf_reloc_aarch64_tls_dtp_rel_ld_st_imm_no_check:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['DTPREL(S+A)'],8,$00000FF0);
       elf_reloc_aarch64_tls_got_rel_movn_z_bit31_16:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['G(GTPREL(S+A))','-','GOT'],16,$FFFF0000);
       elf_reloc_aarch64_tls_got_rel_movk_bit15_0:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['G(GTPREL(S+A))','-','GOT'],16,$0000FFFF);
       elf_reloc_aarch64_tls_page_rel_adrp_bit32_12:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['Page(G(GTPREL(S+A)))','-','Page(P)'],64,$1FFFFF000);
       elf_reloc_aarch64_tls_direct_ld_off_bit11_3:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['G(GTPREL(S+A))'],9,$FF8);
       elf_reloc_aarch64_tls_pc_rel_load_imm:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['G(GTPREL(S+A))','-','P'],19,$001FFFFC);
       elf_reloc_aarch64_tls_tp_rel_movn_z_bit47_32:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['TPREL(S+A)'],16,$FFFF00000000);
       elf_reloc_aarch64_tls_tp_rel_movn_z_bit31_16:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['TPREL(S+A)'],16,$FFFF0000);
       elf_reloc_aarch64_tls_tp_rel_movk_bit31_16:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['TPREL(S+A)'],16,$FFFF0000);
       elf_reloc_aarch64_tls_tp_rel_movn_z_bit15_0:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['TPREL(S+A)'],16,$FFFF);
       elf_reloc_aarch64_tls_tp_rel_movk_bit15_0:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['TPREL(S+A)'],16,$FFFF);
       elf_reloc_aarch64_tls_tp_rel_add_imm_bit23_12:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['TPREL(S+A)'],12,$FFF000);
       elf_reloc_aarch64_tls_tp_rel_add_imm_bit11_0:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['TPREL(S+A)'],12,$FFF);
       elf_reloc_aarch64_tls_tp_rel_add_no_overflow:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['TPREL(S+A)'],12,$FFF);
       elf_reloc_aarch64_tls_tp_rel_ld_st_off_bit11_0:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['TPREL(S+A)'],12,$FFF);
       elf_reloc_aarch64_tls_tp_rel_ld_st_bit11_0_no_overflow:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['TPREL(S+A)'],12,$FFF);
       elf_reloc_aarch64_tls_tp_rel_ld_st_off_bit11_1:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['TPREL(S+A)'],12,$FFE);
       elf_reloc_aarch64_tls_tp_rel_ld_st_bit11_1_no_overflow:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['TPREL(S+A)'],12,$FFE);
       elf_reloc_aarch64_tls_tp_rel_ld_st_off_bit11_2:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['TPREL(S+A)'],12,$FFC);
       elf_reloc_aarch64_tls_tp_rel_ld_st_bit11_2_no_overflow:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['TPREL(S+A)'],12,$FFC);
       elf_reloc_aarch64_tls_tp_rel_ld_st_off_bit11_3:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['TPREL(S+A)'],12,$FF8);
       elf_reloc_aarch64_tls_tp_rel_ld_st_bit11_3_no_overflow:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['TPREL(S+A)'],12,$FF8);
       elf_reloc_aarch64_tls_tp_rel_ld_st_offset:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['TPREL(S+A)'],12,$FF0);
       elf_reloc_aarch64_tls_tp_rel_ld_st_offset_no_check:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['TPREL(S+A)'],12,$FF0);
       elf_reloc_aarch64_tls_pc_rel_ld_bit20_2:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['G(GTLSDESC(S+A))','-','P'],19,$FFFFC);
       elf_reloc_aarch64_tls_pc_rel_adr_bit20_0:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['G(GTLSDESC(S+A))','-','P'],21,$FFFFC);
       elf_reloc_aarch64_tls_page_rel_adr_imm_bit32_12:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['Page(G(GTLSDESC(S+A)))','-','Page(P)'],21,$1FFFFF000);
       elf_reloc_aarch64_tls_descriptor_direct_ld_off_bit11_3:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['G(GTLSDESC(S+A))'],12,$FF8);
       elf_reloc_aarch64_tls_descriptor_direct_add_off_bit11_0:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['G(GTLSDESC(S+A))'],12,$FFF);
       elf_reloc_aarch64_tls_descriptor_got_rel_movn_z_bit31_16:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['G(GTLSDESC(S+A))-GOT'],16,$FFFF0000);
       elf_reloc_aarch64_tls_descriptor_got_rel_movk_bit15_0:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['G(GTLSDESC(S+A))-GOT'],16,$FFFF);
       elf_reloc_aarch64_tls_relax_ldr,elf_reloc_aarch64_tls_relax_add,elf_reloc_aarch64_tls_relax_blr:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula([],0);
       elf_reloc_aarch64_copy:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula([],0);
       elf_reloc_aarch64_new_global_entry:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['S+A'],64);
       elf_reloc_aarch64_new_plt_entry:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['S+A'],64);
       elf_reloc_aarch64_relative:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['B+A'],64);
       elf_reloc_aarch64_tls_dtp_module:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['DTPREL(S+A)'],64);
       elf_reloc_aarch64_tls_tp_relative_offset:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['TPREL(S+A)'],64);
       elf_reloc_aarch64_tls_descriptor:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['TLSDESC(S+A)'],64);
       elf_reloc_aarch64_indirect_relative:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['INDIRECT(TLSDESC(S+A))'],64);
       else templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula([],0);
       end;
      end
     else if(ldarch=elf_machine_riscv) then
      begin
       case Value of
       elf_reloc_riscv_none:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula([],0);
       elf_reloc_riscv_32bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['S+A'],32);
       elf_reloc_riscv_64bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['S+A'],64);
       elf_reloc_riscv_relative:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['B+A'],ldbit shl 5);
       elf_reloc_riscv_copy:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula([],0);
       elf_reloc_riscv_jump_slot:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['S'],ldbit shl 5);
       elf_reloc_riscv_tls_dtp_module32:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['TLSMODULE'],32);
       elf_reloc_riscv_tls_dtp_module64:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['TLSMODULE'],64);
       elf_reloc_riscv_tls_dtp_relative32:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['S+A-DTV_OFFSET'],32);
       elf_reloc_riscv_tls_dtp_relative64:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['S+A-DTV_OFFSET'],64);
       elf_reloc_riscv_tls_tp_relative32:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['S+A+TLS_OFFSET'],32);
       elf_reloc_riscv_tls_tp_relative64:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['S+A+TLS_OFFSET'],64);
       elf_reloc_riscv_branch:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S+A-P'],32,elf_riscv_b_type);
       elf_reloc_riscv_jal:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S+A-P'],32,elf_riscv_j_type);
       elf_reloc_riscv_call:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S+A-P'],64,elf_riscv_u_i_type);
       elf_reloc_riscv_call_plt:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S+A-P'],64,elf_riscv_u_i_type);
       elf_reloc_riscv_got_high_20bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['G+GOT+A-P'],32,elf_riscv_u_type);
       elf_reloc_riscv_tls_got_high_20bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula([],32,elf_riscv_u_type);
       elf_reloc_riscv_tls_global_descriptor_high_20bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula([],32,elf_riscv_u_type);
       elf_reloc_riscv_pc_relative_high_20bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S+A-P'],32,elf_riscv_u_type);
       elf_reloc_riscv_pc_relative_low_12bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S-P'],32,elf_riscv_i_type);
       elf_reloc_riscv_pc_relative_low_12bit_signed:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S-P'],32,elf_riscv_s_type);
       elf_reloc_riscv_high_20bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S+A'],32,elf_riscv_u_type);
       elf_reloc_riscv_low_12bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S+A'],32,elf_riscv_i_type);
       elf_reloc_riscv_low_12bit_signed:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S+A'],32,elf_riscv_s_type);
       elf_reloc_riscv_tp_relative_high_20bit,elf_reloc_riscv_tp_relative_low_12bit,
       elf_reloc_riscv_tp_relative_low_12bit_signed:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula([],32,elf_riscv_u_type);
       elf_reloc_riscv_tp_relative_add:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula([],0);
       elf_reloc_riscv_add_8bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['V+S+A'],8);
       elf_reloc_riscv_add_16bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['V+S+A'],16);
       elf_reloc_riscv_add_32bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['V+S+A'],32);
       elf_reloc_riscv_add_64bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['V+S+A'],64);
       elf_reloc_riscv_sub_8bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['V-S-A'],8);
       elf_reloc_riscv_sub_16bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['V-S-A'],16);
       elf_reloc_riscv_sub_32bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['V-S-A'],32);
       elf_reloc_riscv_sub_64bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['V-S-A'],64);
       elf_reloc_riscv_got_32_pc_relative:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['G+GOT+A-P'],32,elf_riscv_u_i_type);
       elf_reloc_riscv_align:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula([],0);
       elf_reloc_riscv_rvc_branch:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S+A-P'],32,elf_riscv_cb_type);
       elf_reloc_riscv_rvc_jump:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S+A-P'],32,elf_riscv_cj_type);
       elf_reloc_riscv_relax:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula([],32);
       elf_reloc_riscv_sub_6:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['V-S-A'],6);
       elf_reloc_riscv_set_6:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S+A'],6);
       elf_reloc_riscv_set_8:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S+A'],8);
       elf_reloc_riscv_set_16:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S+A'],16);
       elf_reloc_riscv_set_32:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S+A'],32);
       elf_reloc_riscv_32_pcrel:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S+A-P'],32);
       elf_reloc_riscv_indirect_relative:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['ifunc_resolver(B+A)'],ldbit shl 5);
       elf_reloc_riscv_plt_32bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S+A-P'],32,elf_riscv_u_i_type);
       elf_reloc_riscv_set_uleb128:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S+A'],128);
       elf_reloc_riscv_sub_uleb128:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['V-S-A'],128);
       elf_reloc_riscv_tls_descriptor_high_20bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S+A-P'],32);
       elf_reloc_riscv_tls_descriptor_load_low_12bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S-P'],32);
       elf_reloc_riscv_tls_descriptor_add_low_12bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S-P'],32);
       elf_reloc_riscv_tls_descriptor_call:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula([''],0);
       else
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula([''],0);
       end;
      end
     else if(ldarch=elf_machine_loongarch) then
      begin
       case Value of
       elf_reloc_loongarch_none:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula([''],0);
       elf_reloc_loongarch_32bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S+A'],32);
       elf_reloc_loongarch_64bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S+A'],64);
       elf_reloc_loongarch_relative:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['B+A'],ldbit shl 5);
       elf_reloc_loongarch_copy:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula([],0);
       elf_reloc_loongarch_jump_slot:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S'],ldbit shl 5);
       elf_reloc_loongarch_tls_dtp_module_32bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['MODULE_ID'],32);
       elf_reloc_loongarch_tls_dtp_module_64bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['MODULE_ID'],64);
       elf_reloc_loongarch_tls_dtp_relative_32bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S+A-DTV'],32);
       elf_reloc_loongarch_tls_dtp_relative_64bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S+A-DTV'],64);
       elf_reloc_loongarch_indirect_relative:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['ifunc_resolver(B+A)'],ldbit shl 5);
       elf_reloc_loongarch_tls_descriptor_32bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['TLSDESC'],32);
       elf_reloc_loongarch_tls_descriptor_64bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['TLSDESC'],64);
       elf_reloc_loongarch_mark_loongarch,elf_reloc_loongarch_mark_pc_relative:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula([],0);
       elf_reloc_loongarch_sop_push_pc_relative:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['push(S-PC+A)'],ldbit shl 5);
       elf_reloc_loongarch_sop_push_absolute:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['push(S+A)'],ldbit shl 5);
       elf_reloc_loongarch_sop_push_duplicate:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula([],ldbit shl 5);
       elf_reloc_loongarch_sop_push_gp_relative:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['push(G)'],ldbit shl 5);
       elf_reloc_loongarch_sop_push_tls_tp_relative:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['push(T)'],ldbit shl 5);
       elf_reloc_loongarch_sop_push_tls_got:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['push(IE)'],ldbit shl 5);
       elf_reloc_loongarch_sop_push_tls_global_dynamic:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['push(GD)'],ldbit shl 5);
       elf_reloc_loongarch_sop_push_plt_pc_relative:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['push(PLT-PC)'],ldbit shl 5);
       elf_reloc_loongarch_sop_assert:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['assert(pop())'],ldbit shl 5);
       elf_reloc_loongarch_sop_not,elf_reloc_loongarch_sop_sub,
       elf_reloc_loongarch_sop_sl,elf_reloc_loongarch_sop_sr,
       elf_reloc_loongarch_sop_add,elf_reloc_loongarch_sop_and,elf_reloc_loongarch_sop_if_else,
       elf_reloc_loongarch_sop_pop_32_s_10_5,elf_reloc_loongarch_sop_pop_32_u_10_12,
       elf_reloc_loongarch_sop_pop_32_s_10_12,elf_reloc_loongarch_sop_pop_32_s_10_16,
       elf_reloc_loongarch_sop_pop_32_s_10_16_s2,elf_reloc_loongarch_sop_pop_32_s_5_20,
       elf_reloc_loongarch_sop_pop_32_s_0_5_10_16_s2,
       elf_reloc_loongarch_sop_pop_32_s_0_10_10_16_s2,elf_reloc_loongarch_sop_pop_32_u:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula([],ldbit shl 5);
       elf_reloc_loongarch_add_8bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['S+A'],8);
       elf_reloc_loongarch_add_16bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['S+A'],16);
       elf_reloc_loongarch_add_24bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['S+A'],24);
       elf_reloc_loongarch_add_32bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['S+A'],32);
       elf_reloc_loongarch_add_64bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['S+A'],64);
       elf_reloc_loongarch_sub_8bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['S+A'],8);
       elf_reloc_loongarch_sub_16bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['S+A'],16);
       elf_reloc_loongarch_sub_24bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['S+A'],24);
       elf_reloc_loongarch_sub_32bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['S+A'],32);
       elf_reloc_loongarch_sub_64bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['S+A'],64);
       elf_reloc_loongarch_b16:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['S+A-PC'],16);
       elf_reloc_loongarch_b21:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['S+A-PC'],21);
       elf_reloc_loongarch_b26:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['S+A-PC'],26);
       elf_reloc_loongarch_absolute_high_20bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['S+A'],32,$000FFFFF);
       elf_reloc_loongarch_absolute_low_12bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['S+A'],32,$FFF00000);
       elf_reloc_loongarch_absolute_64bit_low_20bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['S+A'],
       64,$000FFFFF00000000);
       elf_reloc_loongarch_absolute_64bit_high_12bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula(['S+A'],
       64,Natuint($FFF0000000000000));
       elf_reloc_loongarch_absolute_pcala_high_20bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['Page(S+A+2048)-Page(PC)'],32,$FFFFF000);
       elf_reloc_loongarch_absolute_pcala_low_12bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S+A'],32,$00000FFF);
       elf_reloc_loongarch_absolute_pcala64_low_20bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S+A-Alignmax(PC)'],64,$000FFFFF00000000);
       elf_reloc_loongarch_absolute_pcala64_high_12bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S+A-Alignmax(PC)'],64,Natuint($FFF0000000000000));
       elf_reloc_loongarch_got_pc_high_20bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['Page(GP+G+2048)-Page(PC)'],32,$FFFFF000);
       elf_reloc_loongarch_got_pc_low_12bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['GP+G'],32,$00000FFF);
       elf_reloc_loongarch_got64_pc_low_20bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['GP+G-Alignmax(PC)'],64,$000FFFFF00000000);
       elf_reloc_loongarch_got64_pc_high_12bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['GP+G-Alignmax(PC)'],64,Natuint($FFF0000000000000));
       elf_reloc_loongarch_got_high_20bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['GP+G'],32,$FFFFF000);
       elf_reloc_loongarch_got_low_12bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['GP+G'],32,$00000FFF);
       elf_reloc_loongarch_got64_low_20bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['GP+G'],64,$000FFFFF00000000);
       elf_reloc_loongarch_got64_high_12bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['GP+G'],64,Natuint($FFF0000000000000));
       elf_reloc_loongarch_tls_le_high_20bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['TLSLE'],32,$FFFFF000);
       elf_reloc_loongarch_tls_le_low_12bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['TLSLE'],32,$00000FFF);
       elf_reloc_loongarch_tls_le64_low_20bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['TLSLE'],64,$000FFFFF00000000);
       elf_reloc_loongarch_tls_le64_high_12bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['TLSLE'],64,Natuint($FFF0000000000000));
       elf_reloc_loongarch_tls_ie_pc_high_20bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['GP+IE-PC'],32,$FFFFF000);
       elf_reloc_loongarch_tls_ie_pc_low_12bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['GP+IE-PC'],32,$00000FFF);
       elf_reloc_loongarch_tls_ie64_pc_low_20bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['GP+IE-PC'],64,$000FFFFF00000000);
       elf_reloc_loongarch_tls_ie64_pc_high_12bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['GP+IE-PC'],64,Natuint($FFF0000000000000));
       elf_reloc_loongarch_tls_ie_high_20bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['GP+IE'],32,$FFFFF000);
       elf_reloc_loongarch_tls_ie_low_12bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['GP+IE'],32,$00000FFF);
       elf_reloc_loongarch_tls_ie64_high_20bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['GP+IE'],64,Natuint($FFFFF00000000000));
       elf_reloc_loongarch_tls_ie64_low_12bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['GP+IE'],64,$00000FFF00000000);
       elf_reloc_loongarch_tls_ld_pc_high_20bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['GP+GD-PC'],32,$FFFFF000);
       elf_reloc_loongarch_tls_ld_high_20bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['GP+IE'],32,$FFFFF000);
       elf_reloc_loongarch_tls_global_dynamic_pc_high_20bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['GP+GD-PC'],32,$00000FFF);
       elf_reloc_loongarch_tls_global_dynamic_high_20bit:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['GP+IE'],32,$00000FFF);
       elf_reloc_loongarch_32_pc_relative:
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=
       ld_generate_formula(['S+A-PC'],32,$00000FFF);
       else
       templist2.Adjust.Formula[templist2.Adjust.Count-1]:=ld_generate_formula([],0);
       end;
      end;
     if(templist2.Adjust.Formula[templist2.Adjust.Count-1].item.count=0) then
     dec(templist2.Adjust.Count);
    end;
  end;
 {Then Prepare for Adjust Table}
 SetLength(templist2.AdjustHashTable.AdjustIndex,templist2.Adjust.Count);
 SetLength(templist2.AdjustHashTable.AdjustStatus,templist2.Adjust.Count);
 templist2.AdjustHashTable.BucketCount:=templist2.Adjust.Count div 7*8+1;
 SetLength(templist2.AdjustHashTable.BucketItem,templist2.AdjustHashTable.BucketCount);
 SetLength(templist2.AdjustHashTable.BucketUsed,templist2.AdjustHashTable.BucketCount);
 templist2.AdjustHashTable.ChainCount:=templist2.Adjust.Count;
 SetLength(templist2.AdjustHashTable.ChainItem,templist2.AdjustHashTable.ChainCount);
 SetLength(templist2.AdjustHashTable.ChainUsed,templist2.AdjustHashTable.ChainCount);
 for i:=1 to templist2.Adjust.Count do
  begin
   tempvalue:=templist2.Adjust.AdjustHash[i-1];
   if(templist2.AdjustHashTable.BucketItem[tempvalue mod templist2.AdjustHashTable.BucketCount]=0) then
    begin
     templist2.AdjustHashTable.BucketItem[tempvalue mod templist2.AdjustHashTable.BucketCount]:=i-1;
     templist2.AdjustHashTable.BucketUsed[tempvalue mod templist2.AdjustHashTable.BucketCount]:=true;
    end
   else
    begin
     tempvalue2:=templist2.AdjustHashTable.BucketItem[tempvalue mod
     templist2.AdjustHashTable.BucketCount];
     while(templist2.AdjustHashTable.ChainUsed[tempvalue2])do
      begin
       tempvalue2:=templist2.AdjustHashTable.ChainItem[tempvalue2];
      end;
     templist2.AdjustHashTable.ChainItem[tempvalue2]:=i-1;
     templist2.AdjustHashTable.ChainUsed[tempvalue2]:=true;
    end;
  end;
 {Then treat the templist2 as Return value}
 ld_link_file:=templist2;
end;
procedure ld_handle_elf_file(fn:string;var ldfile:ld_object_file_stage_2;align:dword;debugframe:boolean;
format:byte;nodefaultlibrary:boolean;stripsymbol:boolean;dynamiclinker:string;
signature:string);
var tempfinal:ld_object_file_final;
    i,j,k,m,n:Natuint;
    tempformula:ld_formula;
    tempnum:Natuint;
    writeindex:word;
    writepos:array[1..2] of Natuint;
    strsize:Natuint;
    order:array of string;
    startoffset,endoffset:Natuint;
    changeptr:Pointer;
    tempresult:NatInt;
    index:Natuint;
    {Set for Unique Adjustment Table}
    AdjustHash:ld_object_hash_table_adjust;
    AdjNum:Natuint;
    AdjGotCount:Natuint=0;
    AdjGotPltCount:Natuint=0;
    {Set for Relocation}
    isrelative:boolean;
    isgotbase:boolean;
    isgotoffset:boolean;
    ispaged:boolean;
    isexternal:boolean;
    {Set the Write Pointer}
    ptr1,ptr2:Pointer;
    offset1,offset2:Natint;
    {For non-x64 architecture}
    tempnum1,tempnum2,tempnum3,tempnum4:Natint;
    gotindex,gotpltindex:word;
    movesecoffset,movesecoffset2:Natint;
    tempresult2:Natint;
    tempindex,tempindex2,tempindex3,tempindex4:Word;
    {Set the fixed length instruction data}
    d1,d2,d3,d4,d5,d6,d7,d8,d9,d10:dword;
    q1,q2:qword;
    negative:boolean;
    {Set the elf writer}
    writer32:ld_elf_writer_32;
    writer64:ld_elf_writer_64;
    writeoffset:Natuint;
    writestart,writeend:Natuint;
    writenameoffset:Natuint;
    elfbinary:Pbyte;
    startaddress:Natuint;
    textindex,dynstrindex,dynsymindex,strtabindex,symtabindex:Natuint;
    initindex,finiindex:Natuint;
    initarrayindex,finiarrayindex,preinitarrayindex:Natuint;
    haverodata,havetls,haveinit,havefini,haveinitarray,havefiniarray,havepreinitarray:boolean;
label label1,label2,label3,label4,label5;
begin
 {Initialize the Final Section}
 tempfinal.SecCount:=0;
 {Now Generate the entire vaild section}
 haverodata:=false; havetls:=false; haveinit:=false; havefini:=false;
 haveinitarray:=false; havefiniarray:=false; havepreinitarray:=false;
 SetLength(tempfinal.SecName,24);
 SetLength(tempfinal.SecIndex,24);
 SetLength(tempfinal.SecAddress,24);
 SetLength(tempfinal.SecSize,24);
 SetLength(tempfinal.SecContent,24);
 for i:=1 to ldfile.SecCount do
  begin
   if(ldfile.SecName[i-1]='.debug_frame') and (debugframe=false) then continue;
   if(ldfile.SecSize[i-1]=0) then continue;
   inc(tempfinal.SecCount);
   if(ldfile.SecName[i-1]='.text') then
   tempfinal.SecName[tempfinal.SecCount-1]:='.text'
   else if(ldfile.SecName[i-1]='.rodata') then
    begin
     tempfinal.SecName[tempfinal.SecCount-1]:='.rodata'; haverodata:=true;
    end
   else if(ldfile.SecName[i-1]='.data') then
   tempfinal.SecName[tempfinal.SecCount-1]:='.data'
   else if(ldfile.SecName[i-1]='.bss') then
   tempfinal.SecName[tempfinal.SecCount-1]:='.bss'
   else if(ldfile.SecName[i-1]='.tdata') then
    begin
     tempfinal.SecName[tempfinal.SecCount-1]:='.tdata'; havetls:=true;
    end
   else if(ldfile.SecName[i-1]='.tbss') then
   tempfinal.SecName[tempfinal.SecCount-1]:='.tbss'
   else if(ldfile.SecName[i-1]='.init') then
    begin
     tempfinal.SecName[tempfinal.SecCount-1]:='.init'; haveinit:=true;
    end
   else if(ldfile.SecName[i-1]='.init_array') then
    begin
     tempfinal.SecName[tempfinal.SecCount-1]:='.init_array'; haveinitarray:=true;
    end
   else if(ldfile.SecName[i-1]='.fini') then
    begin
     tempfinal.SecName[tempfinal.SecCount-1]:='.fini'; havefini:=true;
    end
   else if(ldfile.SecName[i-1]='.fini_array') then
    begin
     tempfinal.SecName[tempfinal.SecCount-1]:='.fini_array'; havefiniarray:=true;
    end
   else if(ldfile.SecName[i-1]='.preinit_array') then
    begin
     tempfinal.SecName[tempfinal.SecCount-1]:='.preinit_array'; havepreinitarray:=true;
    end
   else if(ldfile.SecName[i-1]='.debug_frame') then
   tempfinal.SecName[tempfinal.SecCount-1]:='.debug_frame';
   tempfinal.SecAddress[tempfinal.SecCount-1]:=0;
   tempfinal.SecIndex[tempfinal.SecCount-1]:=0;
   if(ldfile.SecName[i-1]<>'.bss') and (ldfile.SecName[i-1]<>'.tbss') and (ldfile.SecSize[i-1]>0) then
    begin
     tempfinal.SecSize[tempfinal.SecCount-1]:=ldfile.SecSize[i-1];
     tempfinal.SecContent[tempfinal.SecCount-1]:=ldfile.SecContent[i-1].SecContent;
    end
   else if(ldfile.SecSize[i-1]>0) then
    begin
     tempfinal.SecSize[tempfinal.SecCount-1]:=ldfile.SecSize[i-1];
     tempfinal.SecContent[tempfinal.SecCount-1]:=nil;
    end
   else
    begin
     dec(tempfinal.SecCount);
    end;
  end;
 {Check the got and got.plt section can be generated}
 SetLength(tempfinal.GotTable,0); SetLength(tempfinal.GotPltTable,0);
 SetLength(tempfinal.GotSymbol,ldGotCount); SetLength(tempfinal.GotPltSymbol,ldGotCount);
 tempfinal.GotCount:=0; tempfinal.GotPltCount:=0;
 tempfinal.DynSym.SymbolCount:=0; tempfinal.Rela.SymCount:=0;
 {Confirm the Adjust Table for Relative}
 for i:=1 to ldfile.Adjust.Count do
  begin
   isrelative:=ldfile.Adjust.Formula[i-1].isrelative;
   isgotbase:=ldfile.Adjust.Formula[i-1].isgotbase;
   isgotoffset:=ldfile.Adjust.Formula[i-1].isgotoffset;
   ispaged:=ldfile.Adjust.Formula[i-1].ispaged;
   if(isrelative) and ((ldarch=elf_machine_386) or (ldarch=elf_machine_x86_64)) then
    begin
     ldfile.Adjust.Formula[i-1]:=ld_generate_formula(['S+A-P'],ldfile.Adjust.Formula[i-1].bit,
     ldfile.Adjust.Formula[i-1].mask);
    end
   else if(isrelative) and (ldfile.Adjust.DestIndex[i-1]=0)
   and ((ldarch=elf_machine_386) or (ldarch=elf_machine_x86_64))
   and ((isgotbase) or (isgotoffset)) then
    begin
     Adjnum:=ld_adjust_search_for_index(ldfile.AdjustHashTable,
     DynNatuintArray(ldfile.Adjust.AdjustHash),ldfile.Adjust.AdjustHash[i-1],
     tempfinal.GotPltCount+1,ld_adjust_got_plt);
     if(Adjnum=0) then continue;
     inc(tempfinal.GotPltCount);
     tempfinal.GotPltSymbol[tempfinal.GotPltCount-1]:=ldfile.Adjust.AdjustHash[i-1];
     inc(tempfinal.Rela.SymCount);
     ldfile.Adjust.Formula[i-1]:=ld_generate_formula(['GOT+G+A-P'],ldfile.Adjust.Formula[i-1].bit,
     ldfile.Adjust.Formula[i-1].mask);
    end
   else if(isrelative) and (isgotbase=false) and (isgotoffset=false) then
    begin
     if(ispaged) and (ldarch<>elf_machine_loongarch) then
      begin
       ldfile.Adjust.Formula[i-1]:=ld_generate_formula(['Page(S+A)-Page(P)'],ldfile.Adjust.Formula[i-1].bit,
       ldfile.Adjust.Formula[i-1].mask);
      end
     else if(ispaged) then
      begin
       ldfile.Adjust.Formula[i-1]:=ld_generate_formula(['Page(S+A)-Page(PC)'],ldfile.Adjust.Formula[i-1].bit,
       ldfile.Adjust.Formula[i-1].mask);
      end
     else if(ldarch<>elf_machine_loongarch) then
      begin
       ldfile.Adjust.Formula[i-1]:=ld_generate_formula(['S+A-P'],ldfile.Adjust.Formula[i-1].bit,
       ldfile.Adjust.Formula[i-1].mask);
      end
     else
      begin
       ldfile.Adjust.Formula[i-1]:=ld_generate_formula(['S+A-PC'],ldfile.Adjust.Formula[i-1].bit,
       ldfile.Adjust.Formula[i-1].mask);
      end;
    end
   else if(ldarch=elf_machine_riscv) and
   ((ldfile.Adjust.AdjustType[i-1]=elf_reloc_riscv_low_12bit_signed) or
    (ldfile.Adjust.AdjustType[i-1]=elf_reloc_riscv_low_12bit) or
    (ldfile.Adjust.AdjustType[i-1]=elf_reloc_riscv_high_20bit)) then
    begin
     Adjnum:=ld_adjust_search_for_index(ldfile.AdjustHashTable,
     DynNatuintArray(ldfile.Adjust.AdjustHash),ldfile.Adjust.AdjustHash[i-1],
     tempfinal.GotCount+1,ld_adjust_got);
     if(Adjnum=0) then continue;
     inc(tempfinal.GotCount);
     tempfinal.GotSymbol[tempfinal.GotCount-1]:=ldfile.Adjust.AdjustHash[i-1];
     inc(tempfinal.Rela.SymCount);
    end
   else if((isgotbase) or (isgotoffset)) and (ldfile.Adjust.DestIndex[i-1]<>0) then
    begin
     Adjnum:=ld_adjust_search_for_index(ldfile.AdjustHashTable,
     DynNatuintArray(ldfile.Adjust.AdjustHash),ldfile.Adjust.AdjustHash[i-1],
     tempfinal.GotCount+1,ld_adjust_got);
     if(Adjnum=0) then continue;
     inc(tempfinal.GotCount);
     tempfinal.GotSymbol[tempfinal.GotCount-1]:=ldfile.Adjust.AdjustHash[i-1];
     inc(tempfinal.Rela.SymCount);
    end
   else if((isgotbase) or (isgotoffset)) and (ldfile.Adjust.DestIndex[i-1]=0) then
    begin
     Adjnum:=ld_adjust_search_for_index(ldfile.AdjustHashTable,
     DynNatuintArray(ldfile.Adjust.AdjustHash),ldfile.Adjust.AdjustHash[i-1],
     tempfinal.GotPltCount+1,ld_adjust_got_plt);
     if(Adjnum=0) then continue;
     inc(tempfinal.GotPltCount);
     tempfinal.GotPltSymbol[tempfinal.GotPltCount-1]:=ldfile.Adjust.AdjustHash[i-1];
     inc(tempfinal.Rela.SymCount);
    end
   else if(ldarch=elf_machine_386) or (ldarch=elf_machine_x86_64) then
    begin
     inc(tempfinal.Rela.SymCount);
    end;
  end;
 {Confirm the Symbol Table for Dynamic Symbol}
 SetLength(tempfinal.DynSym.SymbolBinding,ldfile.SymTable.SymbolCount);
 SetLength(tempfinal.DynSym.SymbolNameHash,ldfile.SymTable.SymbolCount);
 SetLength(tempfinal.DynSym.SymbolName,ldfile.SymTable.SymbolCount);
 SetLength(tempfinal.DynSym.SymbolType,ldfile.SymTable.SymbolCount);
 SetLength(tempfinal.DynSym.SymbolVisible,ldfile.SymTable.SymbolCount);
 for i:=1 to ldfile.SymTable.SymbolCount do
  begin
   if(ldfile.SymTable.SymbolIndex[i-1]=0) and (ldfile.SymTable.SymbolType[i-1]>0) then
    begin
     inc(tempfinal.DynSym.SymbolCount);
     tempfinal.DynSym.SymbolBinding[tempfinal.DynSym.SymbolCount-1]:=ldfile.SymTable.SymbolBinding[i-1];
     tempfinal.DynSym.SymbolNameHash[tempfinal.DynSym.SymbolCount-1]:=ldfile.SymTable.SymbolNameHash[i-1];
     tempfinal.DynSym.SymbolName[tempfinal.DynSym.SymbolCount-1]:=ldfile.SymTable.SymbolName[i-1];
     tempfinal.DynSym.SymbolType[tempfinal.DynSym.SymbolCount-1]:=ldfile.SymTable.SymbolType[i-1];
     tempfinal.DynSym.SymbolVisible[tempfinal.DynSym.SymbolCount-1]:=ldfile.SymTable.SymbolVisible[i-1];
    end;
  end;
 {Set the Got Table and Got Plt Table}
 if(tempfinal.GotCount>0) then
 SetLength(tempfinal.GotTable,3+tempfinal.GotCount);
 if(tempfinal.GotPltCount>0) then
 SetLength(tempfinal.GotPltTable,3+tempfinal.GotPltCount);
 {Now if dynamic linker does not empty,generate the dynamic linker section and initialize it}
 if(dynamiclinker<>'') then
  begin
   inc(tempfinal.SecCount);
   tempfinal.SecName[tempfinal.Seccount-1]:='.interp';
   tempfinal.SecContent[tempfinal.Seccount-1]:=tydq_getmem(length(dynamiclinker));
   tempfinal.SecIndex[tempfinal.Seccount-1]:=0;
   tempfinal.SecAddress[tempfinal.Seccount-1]:=0;
   tempfinal.SecSize[tempfinal.Seccount-1]:=length(dynamiclinker)+1;
   ptr1:=tempfinal.SecContent[tempfinal.Seccount-1];
   for i:=1 to length(dynamiclinker) do PChar(ptr1+i-1)^:=dynamiclinker[i];
  end;
 {Now if signature does not empty,generate the signature section and initialize it}
 if(signature<>'') then
  begin
   inc(tempfinal.SecCount);
   tempfinal.SecName[tempfinal.Seccount-1]:='.sign';
   tempfinal.SecContent[tempfinal.Seccount-1]:=tydq_getmem(length(signature));
   tempfinal.SecIndex[tempfinal.Seccount-1]:=0;
   tempfinal.SecAddress[tempfinal.Seccount-1]:=0;
   tempfinal.SecSize[tempfinal.Seccount-1]:=length(signature)+1;
   ptr1:=tempfinal.SecContent[tempfinal.Seccount-1];
   for i:=1 to length(signature) do PChar(ptr1+i-1)^:=signature[i];
  end;
 {Now Generate the Relocation Necessary Value}
 if(Length(tempfinal.GotTable)>0) then
  begin
   inc(tempfinal.SecCount);
   tempfinal.SecName[tempfinal.Seccount-1]:='.got';
   tempfinal.SecContent[tempfinal.Seccount-1]:=tydq_getmem(Length(tempfinal.GotTable)*ldbit shl 2);
   tempfinal.SecIndex[tempfinal.Seccount-1]:=0;
   tempfinal.SecAddress[tempfinal.Seccount-1]:=0;
   tempfinal.SecSize[tempfinal.Seccount-1]:=Length(tempfinal.GotTable)*ldbit shl 2;
  end;
 if(Length(tempfinal.GotPltTable)>0) then
  begin
   inc(tempfinal.SecCount);
   tempfinal.SecName[tempfinal.Seccount-1]:='.got.plt';
   tempfinal.SecContent[tempfinal.Seccount-1]:=tydq_getmem(Length(tempfinal.GotPltTable)*ldbit shl 2);
   tempfinal.SecIndex[tempfinal.Seccount-1]:=0;
   tempfinal.SecAddress[tempfinal.Seccount-1]:=0;
   tempfinal.SecSize[tempfinal.Seccount-1]:=Length(tempfinal.GotPltTable)*ldbit shl 2;
  end;
 {Now generate the hash table}
 tempfinal.Hash.BucketCount:=tempfinal.DynSym.SymbolCount*2+1;
 tempfinal.Hash.ChainCount:=tempfinal.DynSym.SymbolCount;
 SetLength(tempfinal.Hash.Bucket,tempfinal.DynSym.SymbolCount*2+1);
 SetLength(tempfinal.Hash.Chain,tempfinal.DynSym.SymbolCount);
 inc(tempfinal.SecCount);
 tempfinal.SecName[tempfinal.Seccount-1]:='.hash';
 tempfinal.SecContent[tempfinal.Seccount-1]:=
 tydq_getmem((tempfinal.Hash.BucketCount+tempfinal.Hash.ChainCount+2) shl 2);
 tempfinal.SecIndex[tempfinal.Seccount-1]:=0;
 tempfinal.SecAddress[tempfinal.Seccount-1]:=0;
 tempfinal.SecSize[tempfinal.Seccount-1]:=(tempfinal.Hash.BucketCount+tempfinal.Hash.ChainCount+2) shl 2;
 {Now Generate the empty rela.dyn section}
 if(tempfinal.Rela.SymCount>0) then
  begin
   inc(tempfinal.SecCount);
   tempfinal.SecName[tempfinal.Seccount-1]:='.rela.dyn';
   tempfinal.SecContent[tempfinal.Seccount-1]:=tydq_getmem(12*ldbit*tempfinal.Rela.SymCount);
   tempfinal.SecIndex[tempfinal.Seccount-1]:=0;
   tempfinal.SecAddress[tempfinal.Seccount-1]:=0;
   tempfinal.SecSize[tempfinal.Seccount-1]:=12*ldbit*tempfinal.Rela.SymCount;
  end;
 {Now Generate dynsym,dynstr,dynamic section}
 strsize:=1;
 if(tempfinal.DynSym.SymbolCount>0)then
  begin
   for i:=1 to tempfinal.DynSym.SymbolCount do inc(strsize,length(tempfinal.DynSym.SymbolName[i-1])+1);
  end
 else strsize:=1;
 strsize:=strsize+ldDynamicLibrary.StringTotalLength;
 inc(tempfinal.SecCount);
 tempfinal.SecName[tempfinal.Seccount-1]:='.dynstr';
 tempfinal.SecContent[tempfinal.Seccount-1]:=tydq_getmem(strsize);
 tempfinal.SecIndex[tempfinal.Seccount-1]:=0;
 tempfinal.SecAddress[tempfinal.Seccount-1]:=0;
 tempfinal.SecSize[tempfinal.Seccount-1]:=strsize;
 inc(tempfinal.SecCount);
 tempfinal.SecName[tempfinal.Seccount-1]:='.dynsym';
 if(ldbit=1) then
 tempfinal.SecContent[tempfinal.Seccount-1]:=
 tydq_getmem(sizeof(elf32_symbol_table_entry)*(tempfinal.DynSym.SymbolCount+1))
 else if(ldbit=2) then
 tempfinal.SecContent[tempfinal.Seccount-1]:=
 tydq_getmem(sizeof(elf64_symbol_table_entry)*(tempfinal.DynSym.SymbolCount+1));
 tempfinal.SecIndex[tempfinal.Seccount-1]:=0;
 tempfinal.SecAddress[tempfinal.Seccount-1]:=0;
 if(ldbit=1) then
 tempfinal.SecSize[tempfinal.Seccount-1]:=
 sizeof(elf32_symbol_table_entry)*(tempfinal.DynSym.SymbolCount+1)
 else if(ldbit=2) then
 tempfinal.SecSize[tempfinal.Seccount-1]:=
 sizeof(elf64_symbol_table_entry)*(tempfinal.DynSym.SymbolCount+1);
 inc(tempfinal.SecCount);
 tempfinal.SecName[tempfinal.Seccount-1]:='.dynamic';
 if(ldbit=1) then
 tempfinal.SecContent[tempfinal.Seccount-1]:=
 tydq_getmem(sizeof(elf32_dynamic_entry)*
 (13+Byte(haveinit)+Byte(havefini)+Byte(haveinitarray)*2+Byte(havefiniarray)*2+Byte(havepreinitarray)*2
 +lddynamiclibrary.Count))
 else if(ldbit=2) then
 tempfinal.SecContent[tempfinal.Seccount-1]:=
 tydq_getmem(sizeof(elf64_dynamic_entry)*
 (13+Byte(haveinit)+Byte(havefini)+Byte(haveinitarray)*2+Byte(havefiniarray)*2+Byte(havepreinitarray)*2
 +lddynamiclibrary.Count));
 tempfinal.SecIndex[tempfinal.Seccount-1]:=0;
 tempfinal.SecAddress[tempfinal.Seccount-1]:=0;
 if(ldbit=1) then
 tempfinal.SecSize[tempfinal.Seccount-1]:=sizeof(elf32_dynamic_entry)*
 (13+Byte(haveinit)+Byte(havefini)+Byte(haveinitarray)*2+Byte(havefiniarray)*2+Byte(havepreinitarray)*2)
 else if(ldbit=2) then
 tempfinal.SecSize[tempfinal.Seccount-1]:=sizeof(elf64_dynamic_entry)*
 (13+Byte(haveinit)+Byte(havefini)+Byte(haveinitarray)*2+Byte(havefiniarray)*2+Byte(havepreinitarray)*2);
 {Now Generate the empty symtab,shstrtab and strtab}
 if(stripsymbol) then goto label4;
 strsize:=0;
 if(ldfile.SymTable.SymbolCount>0)then
  begin
   for i:=1 to ldfile.SymTable.SymbolCount do
    begin
     if(ldfile.SecName[ldfile.SymTable.SymbolIndex[i-1]-1]='.debug_frame') and (debugframe=false)
     then continue;
     inc(strsize,length(ldfile.SymTable.SymbolName[i-1])+1);
    end;
  end
 else strsize:=1;
 inc(tempfinal.SecCount);
 tempfinal.SecName[tempfinal.Seccount-1]:='.strtab';
 tempfinal.SecContent[tempfinal.Seccount-1]:=tydq_getmem(strsize);
 tempfinal.SecIndex[tempfinal.Seccount-1]:=0;
 tempfinal.SecAddress[tempfinal.Seccount-1]:=0;
 tempfinal.SecSize[tempfinal.Seccount-1]:=strsize;
 inc(tempfinal.SecCount);
 tempfinal.SecName[tempfinal.Seccount-1]:='.symtab';
 if(ldbit=1) then
 tempfinal.SecContent[tempfinal.Seccount-1]:=
 tydq_getmem(sizeof(elf32_symbol_table_entry)*
 (ldfile.SymTable.SymbolCount-tempfinal.DynSym.SymbolCount+1))
 else if(ldbit=2) then
 tempfinal.SecContent[tempfinal.Seccount-1]:=
 tydq_getmem(sizeof(elf64_symbol_table_entry)*
 (ldfile.SymTable.SymbolCount-tempfinal.DynSym.SymbolCount+1));
 tempfinal.SecIndex[tempfinal.Seccount-1]:=0;
 tempfinal.SecAddress[tempfinal.Seccount-1]:=0;
 if(ldbit=1) then
 tempfinal.SecSize[tempfinal.Seccount-1]:=
 sizeof(elf32_symbol_table_entry)*(ldfile.SymTable.SymbolCount+1)
 else if(ldbit=2) then
 tempfinal.SecSize[tempfinal.Seccount-1]:=
 sizeof(elf64_symbol_table_entry)*(ldfile.SymTable.SymbolCount+1);
 label4:
 inc(tempfinal.SecCount);
 tempfinal.SecName[tempfinal.Seccount-1]:='.shstrtab';
 strsize:=1;
 if(tempfinal.SecCount>0)then
  begin
   for i:=1 to tempfinal.SecCount do inc(strsize,length(tempfinal.SecName[i-1])+1);
  end
 else strsize:=1;
 tempfinal.SecContent[tempfinal.Seccount-1]:=tydq_getmem(strsize);
 tempfinal.SecIndex[tempfinal.Seccount-1]:=0;
 tempfinal.SecAddress[tempfinal.Seccount-1]:=0;
 tempfinal.SecSize[tempfinal.Seccount-1]:=strsize;
 {Now allocate the order of the section}
 order:=['.hash','.dynsym','.dynstr','.rela.dyn','.interp','.text','.init','.fini','.rodata','.data',
 '.init_array','.fini_array','.preinit_array',
 '.dynamic','.got','.got.plt','.debug_frame','.bss','.tdata','.tbss','.sign',
 '.symtab','.strtab','.shstrtab'];
 if(ldbit=1) then
 startoffset:=sizeof(elf32_header)+(4+Byte(haverodata)+Byte(havetls)+Byte(dynamiclinker<>''))
 *sizeof(elf32_program_header)
 else if(ldbit=2) then
 startoffset:=sizeof(elf64_header)+(4+Byte(haverodata)+Byte(havetls)+Byte(dynamiclinker<>''))
 *sizeof(elf64_program_header);
 i:=1; writeindex:=0; gotindex:=1; gotpltindex:=1;
 for i:=1 to length(order) do
  begin
   j:=1;
   while(j<=tempfinal.SecCount)do
    begin
     if(tempfinal.SecName[j-1]=order[i-1]) then break;
     inc(j);
    end;
   if(j>tempfinal.SecCount) then continue;
   inc(writeindex);
   if(Order[i-1]='.dynsym') then dynsymindex:=writeindex;
   if(Order[i-1]='.dynstr') then dynstrindex:=writeindex;
   if(Order[i-1]='.text') then
    begin
     textindex:=writeindex;
     startoffset:=ld_align(startoffset,align);
    end
   else if(Order[i-1]='.rodata') or (Order[i-1]='.data') or (Order[i-1]='.tdata') then
   startoffset:=ld_align(startoffset,align)
   else
   startoffset:=ld_align(startoffset,ldbit shl 2);
   tempfinal.SecAddress[j-1]:=startoffset;
   tempfinal.SecIndex[j-1]:=writeindex;
   if(Order[i-1]='.got') then
    begin
     gotindex:=j;
    end
   else if(Order[i-1]='.got.plt') then
    begin
     gotpltindex:=j;
    end;
   if(Order[i-1]='.strtab') then strtabindex:=writeindex
   else if(Order[i-1]='.symtab') then symtabindex:=writeindex
   else if(Order[i-1]='.init') then initindex:=j
   else if(Order[i-1]='.fini') then finiindex:=j
   else if(Order[i-1]='.init_array') then initarrayindex:=j
   else if(Order[i-1]='.fini_array') then finiarrayindex:=j
   else if(Order[i-1]='.preinit_array') then preinitarrayindex:=j;
   if(Order[i-1]<>'.bss') and (Order[i-1]<>'.tbss') then
   inc(startoffset,tempfinal.SecSize[j-1]);
  end;
 {For AArch64 Architecture Only}
 movesecoffset:=0; movesecoffset2:=0;
 writepos[1]:=3; writepos[2]:=3;
 if(ldarch=elf_machine_aarch64) then
  begin
   for k:=1 to ldfile.Adjust.Count do
    begin
     index:=ldfile.Adjust.SrcIndex[i-1];
     if(ldfile.SecName[index-1]='.debug_frame') and (debugframe=false) then continue;
     j:=1;
     while(j<=tempfinal.SecCount)do
      begin
       if(ldfile.SecName[index-1]=tempfinal.SecName[j-1]) then break;
       inc(j);
      end;
     if(j>tempfinal.SecCount) then continue;
     startoffset:=tempfinal.SecAddress[j-1]+ldfile.Adjust.SrcOffset[i-1];
     changeptr:=tempfinal.SecContent[j-1]+ldfile.Adjust.Srcoffset[i-1];
     tempindex:=j;
     index:=ldfile.Adjust.DestIndex[i-1];
     if(index>0) then
      begin
       if(ldfile.SecName[index-1]='.debug_frame') and (debugframe=false) then continue;
       j:=1;
       while(j<=tempfinal.SecCount)do
        begin
         if(ldfile.SecName[index-1]=tempfinal.SecName[j-1]) then break;
         inc(j);
        end;
       if(j>tempfinal.SecCount) then continue;
      end;
     tempindex2:=j;
     if(ld_formula_check_got(ldfile.Adjust.Formula[i-1])) then
      begin
       j:=ld_adjust_search_for_index(ldfile.AdjustHashTable,
       DynNatuintArray(ldfile.Adjust.AdjustHash),ldfile.Adjust.AdjustHash[i-1],0,ld_adjust_got);
       if(j<>0) then
        begin
         offset1:=ldfile.AdjustHashTable.AdjustIndex[j-1]; writepos[1]:=2+offset1;
        end
       else
        begin
         offset1:=0; writepos[1]:=0;
        end;
       j:=ld_adjust_search_for_index(ldfile.AdjustHashTable,
       DynNatuintArray(ldfile.Adjust.AdjustHash),ldfile.Adjust.AdjustHash[i-1],0,ld_adjust_got_plt);
       if(j<>0) then
        begin
         offset2:=ldfile.AdjustHashTable.AdjustIndex[j-1]; writepos[2]:=2+offset2;
        end
       else
        begin
         offset2:=0; writepos[2]:=0;
        end;
      end;
     endoffset:=tempfinal.SecAddress[j-1]+ldfile.Adjust.DestOffset[i-1];
     isexternal:=false;
     if(isgotbase) or (isgotoffset) then
      begin
       j:=ld_adjust_search_for_index(ldfile.AdjustHashTable,
       DynNatuintArray(ldfile.Adjust.AdjustHash),ldfile.Adjust.AdjustHash[i-1],0,ld_adjust_got);
       if(j<>0) then
        begin
         offset1:=ldfile.AdjustHashTable.AdjustIndex[j-1]; writepos[1]:=2+offset1;
        end
       else
        begin
         offset1:=0; writepos[1]:=0;
        end;
       j:=ld_adjust_search_for_index(ldfile.AdjustHashTable,
       DynNatuintArray(ldfile.Adjust.AdjustHash),ldfile.Adjust.AdjustHash[i-1],0,ld_adjust_got_plt);
       if(j<>0) then
        begin
         offset2:=ldfile.AdjustHashTable.AdjustIndex[j-1]; writepos[2]:=2+offset2;
        end
       else
        begin
         offset2:=0; writepos[2]:=0;
        end;
      end;
     if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_adrp_page_rel_bit32_12)
     or(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_adrp_page_rel_bit32_12_no_check)
     or(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_page_rel_adrp_bit32_12) then
      begin
       tempnum3:=0; tempnum4:=1;
       if(ld_formula_check_got(ldfile.Adjust.Formula[i-1])) then
        begin
         if(isexternal) then
         tempresult:=ld_align_floor(tempfinal.SecAddress[gotpltindex-1]
         +writepos[2]*ldbit shl 2+ldfile.Adjust.Addend[i-1],$1000)-
         ld_align_floor(startoffset,$1000)
         else
         tempresult:=ld_align_floor(tempfinal.SecAddress[gotindex-1]
         +writepos[1]*ldbit shl 2+ldfile.Adjust.Addend[i-1],$1000)-
         ld_align_floor(startoffset,$1000);
        end
       else
       tempresult:=ld_align_floor(endoffset+ldfile.Adjust.Addend[i-1],$1000)-
       ld_align_floor(startoffset,$1000);
       tempresult2:=tempresult;
       movesecoffset:=0; movesecoffset2:=0;
       while(tempnum3<>tempnum4) or (tempresult<>tempresult2) do
        begin
         startoffset:=tempfinal.SecAddress[tempindex-1]+ldfile.Adjust.SrcOffset[i-1];
         endoffset:=tempfinal.SecAddress[tempindex2-1]+ldfile.Adjust.DestOffset[i-1];
         changeptr:=tempfinal.SecContent[tempindex-1]+ldfile.Adjust.SrcOffset[i-1];
         tempresult:=tempresult2;
         tempnum1:=ld_align_floor(startoffset,$1000);
         if(ld_formula_check_got(ldfile.Adjust.Formula[i-1])) then
          begin
           if(isexternal) then
           tempnum2:=tempfinal.SecAddress[gotpltindex-1]
           +writepos[2]*ldbit shl 2+ldfile.Adjust.Addend[i-1]
          else
           tempnum2:=tempfinal.SecAddress[gotindex-1]
           +writepos[1]*ldbit shl 2+ldfile.Adjust.Addend[i-1];
          end
         else tempnum2:=endoffset+ldfile.Adjust.Addend[i-1];
         tempnum3:=tempnum2-tempnum1-tempresult;
         movesecoffset:=0;
         if(Abs(tempnum3)>=4096) and (Abs(tempnum3) mod 4096<>0) then
          begin
           if(ldfile.Adjust.SrcOffset[i-1]+8<=tempfinal.SecSize[tempindex-1]) and
           (Pld_aarch64_add_or_sub_immediate(changeptr+4)^.FixedValue=
           ld_aarch64_add_or_sub_fixed_value) and
           (Pld_aarch64_add_or_sub_immediate(changeptr+4)^.Rd=Pdword(changeptr)^ and $1F) then
            begin
             if(tempnum3>=4096) and (tempnum3 mod 4096=0) then
              begin
              end
             else if(tempnum3>=4096) then inc(movesecoffset,4)
            end
           else inc(movesecoffset,8);
          end
         else if(Abs(tempnum3)>=4096) then
          begin
           if(ldfile.Adjust.SrcOffset[i-1]+8<=tempfinal.SecSize[tempindex-1]) and
           (Pld_aarch64_add_or_sub_immediate(changeptr+4)^.FixedValue=
           ld_aarch64_add_or_sub_fixed_value) and
           (Pld_aarch64_add_or_sub_immediate(changeptr+4)^.Rd=Pdword(changeptr)^ and $1F) then
            begin
            end
           else inc(movesecoffset,4);
          end
         else if(Abs(tempnum3)<>0) then
          begin
           if(ldfile.Adjust.SrcOffset[i-1]+8<=tempfinal.SecSize[tempindex-1]) and
           (Pld_aarch64_add_or_sub_immediate(changeptr+4)^.FixedValue=
           ld_aarch64_add_or_sub_fixed_value) and
           (Pld_aarch64_add_or_sub_immediate(changeptr+4)^.Rd=Pdword(changeptr)^ and $1F) then
            begin
            end
           else inc(movesecoffset,4);
          end;
         if(ldfile.Adjust.SrcOffset[i-1]+8<=tempfinal.SecSize[tempindex-1])
         and (Pld_aarch64_add_or_sub_immediate(changeptr+4)^.FixedValue=
         ld_aarch64_add_or_sub_fixed_value) and
         (Pld_aarch64_add_or_sub_immediate(changeptr+4)^.Rd=Pdword(changeptr)^ and $1F) and
         (Pld_aarch64_add_or_sub_immediate(changeptr+4)^.Imm12=0) then
          begin
           dec(movesecoffset,4);
          end;
         m:=1; tempindex3:=0; tempindex4:=0;
         while(m<=tempfinal.SecCount-1) do
          begin
           n:=1;
           while(n<=tempfinal.SecCount)do
            begin
             if(tempfinal.SecIndex[n-1]=m) then break;
             inc(n);
            end;
           tempindex3:=n;
           n:=1;
           while(n<=tempfinal.SecCount)do
            begin
             if(tempfinal.SecIndex[n-1]=m+1) then break;
             inc(n);
            end;
           tempindex4:=n;
           if(tempindex4=0) then break;
           if(tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1]<=
           tempfinal.SecAddress[tempindex4-1]) then
            begin
             if(tempfinal.SecName[tempindex4-1]='.text')
             or(tempfinal.SecName[tempindex4-1]='.rodata')
             or(tempfinal.SecName[tempindex4-1]='.data') then
              begin
               if(ld_align(tempfinal.SecAddress[tempindex4-1],align)-
               (tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1])>=align) then
                begin
                 ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                 DynWordArray(tempfinal.SecIndex),
                 tempfinal.SecIndex[tempindex4-1],-align);
                end;
              end
             else if(tempfinal.SecName[tempindex3-1]<>'.bss') and
             (tempfinal.SecName[tempindex3-1]<>'.tbss') then
              begin
               if(tempfinal.SecAddress[tempindex4-1]-
               (tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1])>=ldbit shl 2) then
                begin
                 ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                 DynWordArray(tempfinal.SecIndex),
                 tempfinal.SecIndex[tempindex4-1],-ldbit shl 2);
                end;
              end
             else
              begin
               if(tempfinal.SecAddress[tempindex4-1]-tempfinal.SecAddress[tempindex3-1]>=ldbit shl 2) then
                begin
                 ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                 DynwordArray(tempfinal.SecIndex),
                 tempfinal.SecIndex[tempindex4-1],-ldbit shl 2);
                end;
              end;
            end
           else
            begin
             if(tempfinal.SecName[tempindex4-1]='.text')
             or(tempfinal.SecName[tempindex4-1]='.rodata')
             or(tempfinal.SecName[tempindex4-1]='.data') then
              begin
               if(ld_align(tempfinal.SecAddress[tempindex4-1],align)-
               (tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1])<=0) then
                begin
                 ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                 DynWordArray(tempfinal.SecIndex),
                 tempfinal.SecIndex[tempindex4-1],align);
                end;
              end
             else if(tempfinal.SecName[tempindex3-1]<>'.bss') and
             (tempfinal.SecName[tempindex3-1]<>'.tbss') then
              begin
               if(tempfinal.SecAddress[tempindex4-1]-
               (tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1])<=0) then
                begin
                 ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                 DynWordArray(tempfinal.SecIndex),
                 tempfinal.SecIndex[tempindex4-1],ldbit shl 2);
                end;
              end
             else
              begin
               if(tempfinal.SecAddress[tempindex4-1]-
               (tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1])<0) then
                begin
                 ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                 DynWordArray(tempfinal.SecIndex),
                 tempfinal.SecIndex[tempindex4-1],ldbit shl 2);
                end;
              end;
            end;
           inc(m);
          end;
         startoffset:=tempfinal.SecAddress[tempindex-1]+ldfile.Adjust.SrcOffset[i-1];
         if(tempindex=tempindex2) and (ldfile.Adjust.SrcOffset[i-1]<ldfile.Adjust.DestOffset[i-1]) then
         endoffset:=tempfinal.SecAddress[tempindex2-1]+ldfile.Adjust.DestOffset[i-1]+movesecoffset
         else
         endoffset:=tempfinal.SecAddress[tempindex2-1]+ldfile.Adjust.DestOffset[i-1];
         if(ld_formula_check_got(ldfile.Adjust.Formula[i-1])) then
          begin
           if(isexternal) then
           tempresult2:=ld_align_floor(tempfinal.SecAddress[gotpltindex-1]
           +writepos[2]*ldbit shl 2+ldfile.Adjust.Addend[i-1],$1000)-
           ld_align_floor(startoffset,$1000)
           else
           tempresult2:=ld_align_floor(tempfinal.SecAddress[gotindex-1]
           +writepos[1]*ldbit shl 2+ldfile.Adjust.Addend[i-1],$1000)-
           ld_align_floor(startoffset,$1000);
          end
         else
         tempresult2:=ld_align_floor(endoffset+ldfile.Adjust.Addend[i-1],$1000)-
         ld_align_floor(startoffset,$1000);
         tempnum1:=ld_align_floor(startoffset,$1000);
         if(ld_formula_check_got(ldfile.Adjust.Formula[i-1])) then
          begin
           if(isexternal) then
           tempnum2:=tempfinal.SecAddress[gotpltindex-1]
           +writepos[2]*ldbit shl 2+ldfile.Adjust.Addend[i-1]
           else
           tempnum2:=tempfinal.SecAddress[gotindex-1]
           +writepos[1]*ldbit shl 2+ldfile.Adjust.Addend[i-1];
          end
         else tempnum2:=endoffset+ldfile.Adjust.Addend[i-1];
         tempnum4:=tempnum2-tempnum1-tempresult2;
         if(tempnum3<>tempnum4) or (tempresult<>tempresult2) then continue;
         if(Pld_aarch64_ld_or_st_immediate_12(changeptr+4)^.Opcode=1)
         and (Pld_aarch64_ld_or_st_immediate_12(changeptr+4)^.Size>=2)
         and (Pld_aarch64_ld_or_st_immediate_12(changeptr+4)^.Reserved2=7) then
          begin
           if(Pld_aarch64_ld_or_st_immediate_12(changeptr+4)^.Unsigned=1) then
            begin
             if(Pld_aarch64_ld_or_st_immediate_12(changeptr+4)^.Size=2) then
              begin
               if(tempnum3>$FFF shl 2) then dec(tempnum3,$FFF shl 2)
               else
                begin
                 tempnum3:=0; break;
                end;
              end
             else if(Pld_aarch64_ld_or_st_immediate_12(changeptr+4)^.Size=3) then
              begin
               if(tempnum3>$FFF shl 3) then dec(tempnum3,$FFF shl 3)
               else
                begin
                 tempnum3:=0; break;
                end;
              end;
            end
           else
            begin
             if(Abs(tempnum3)<=$1FF) then
              begin
               tempnum3:=0; break;
              end
             else if(tempnum3>0) then dec(tempnum3,$1FF)
             else if(tempnum3<0) then inc(tempnum3,$1FF);
            end;
          end;
         if(Abs(tempnum3)>=4096) and (Abs(tempnum3) mod 4096<>0) then
          begin
           if(ldfile.Adjust.SrcOffset[i-1]+12<=tempfinal.SecSize[tempindex-1]) and
           (Pld_aarch64_add_or_sub_immediate(changeptr+4)^.FixedValue=
           ld_aarch64_add_or_sub_fixed_value) and
           (Pld_aarch64_add_or_sub_immediate(changeptr+8)^.FixedValue=
           ld_aarch64_add_or_sub_fixed_value) and
           (Pld_aarch64_add_or_sub_immediate(changeptr+4)^.Rd=Pdword(changeptr)^ and $1F) and
           (Pld_aarch64_add_or_sub_immediate(changeptr+8)^.Rd=Pdword(changeptr)^ and $1F) then
            begin
             Pld_aarch64_add_or_sub_immediate(changeptr+4)^.Opcode:=tempnum3<0;
             Pld_aarch64_add_or_sub_immediate(changeptr+4)^.Imm12:=Abs(tempnum3) shr 12;
             Pld_aarch64_add_or_sub_immediate(changeptr+4)^.Shift:=1;
             Pld_aarch64_add_or_sub_immediate(changeptr+8)^.Opcode:=tempnum3<0;
             Pld_aarch64_add_or_sub_immediate(changeptr+8)^.Imm12:=Abs(tempnum3) and $FFF;
             Pld_aarch64_add_or_sub_immediate(changeptr+8)^.Shift:=0;
            end
           else if(ldfile.Adjust.SrcOffset[i-1]+8<=tempfinal.SecSize[tempindex-1]) and
           (Pld_aarch64_add_or_sub_immediate(changeptr+4)^.FixedValue=
           ld_aarch64_add_or_sub_fixed_value) and
           (Pld_aarch64_add_or_sub_immediate(changeptr+4)^.Rd=Pdword(changeptr)^ and $1F) then
            begin
             if(Abs(tempnum3)>=4096) and (Abs(tempnum3) mod 4096=0) then
              begin
               Pld_aarch64_add_or_sub_immediate(changeptr+4)^.Opcode:=tempnum3<0;
               Pld_aarch64_add_or_sub_immediate(changeptr+4)^.Imm12:=Abs(tempnum3) shr 12;
               Pld_aarch64_add_or_sub_immediate(changeptr+4)^.Shift:=1;
              end
             else if(Abs(tempnum3)>=4096) then
              begin
               Pld_aarch64_add_or_sub_immediate(changeptr+4)^.Opcode:=tempnum3<0;
               Pld_aarch64_add_or_sub_immediate(changeptr+4)^.Imm12:=Abs(tempnum3) shr 12;
               Pld_aarch64_add_or_sub_immediate(changeptr+4)^.Shift:=1;
               inc(tempfinal.SecSize[tempindex-1],8);
               tydq_reallocMem(tempfinal.SecContent[tempindex-1],tempfinal.SecSize[tempindex-1]);
               changeptr:=tempfinal.SecContent[tempindex-1]+ldfile.Adjust.SrcOffset[i-1];
               tydq_move(Pbyte(changeptr+8)^,Pbyte(changeptr+12)^,
               tempfinal.SecSize[tempindex-1]-ldfile.Adjust.Srcoffset[i-1]-12);
               if(tempnum3>0) then
               Pdword(changeptr+8)^:=
               ld_aarch64_stub_add(Pdword(changeptr)^ and $1F,Abs(tempnum3) and $FFF,false,ldbit=2)
               else
               Pdword(changeptr+8)^:=
               ld_aarch64_stub_sub(Pdword(changeptr)^ and $1F,Abs(tempnum3) and $FFF,false,ldbit=2);
               inc(movesecoffset2,4);
              end
             else
              begin
               Pld_aarch64_add_or_sub_immediate(changeptr+4)^.Opcode:=tempnum3<0;
               Pld_aarch64_add_or_sub_immediate(changeptr+4)^.Imm12:=Abs(tempnum3) and $FFF;
               Pld_aarch64_add_or_sub_immediate(changeptr+4)^.Shift:=0;
              end;
            end
           else
            begin
             inc(tempfinal.SecSize[tempindex-1],8);
             tydq_reallocMem(tempfinal.SecContent[tempindex-1],tempfinal.SecSize[tempindex-1]);
             changeptr:=tempfinal.SecContent[tempindex-1]+ldfile.Adjust.SrcOffset[i-1];
             tydq_move(Pbyte(changeptr+4)^,Pbyte(changeptr+12)^,
             tempfinal.SecSize[tempindex-1]-ldfile.Adjust.Srcoffset[i-1]-12);
             if(tempnum3>0) then
             Pdword(changeptr+4)^:=
             ld_aarch64_stub_add(Pdword(changeptr)^ and $1F,(Abs(tempnum3) shr 12) and $FFF,true,ldbit=2)
             else
             Pdword(changeptr+4)^:=
             ld_aarch64_stub_sub(Pdword(changeptr)^ and $1F,(Abs(tempnum3) shr 12) and $FFF,true,ldbit=2);
             if(tempnum3>0) then
             Pdword(changeptr+8)^:=
             ld_aarch64_stub_add(Pdword(changeptr)^ and $1F,Abs(tempnum3) and $FFF,false,ldbit=2)
             else
             Pdword(changeptr+8)^:=
             ld_aarch64_stub_sub(Pdword(changeptr)^ and $1F,Abs(tempnum3) and $FFF,false,ldbit=2);
             inc(movesecoffset2,8);
            end;
          end
         else if(Abs(tempnum3)>=4096) then
          begin
           if(ldfile.Adjust.SrcOffset[i-1]+8<=tempfinal.SecSize[tempindex-1]) and
           (Pld_aarch64_add_or_sub_immediate(changeptr+4)^.FixedValue=
           ld_aarch64_add_or_sub_fixed_value) and
           (Pld_aarch64_add_or_sub_immediate(changeptr+4)^.Rd=Pdword(changeptr)^ and $1F) then
            begin
             Pld_aarch64_add_or_sub_immediate(changeptr+4)^.Opcode:=tempnum3<0;
             Pld_aarch64_add_or_sub_immediate(changeptr+4)^.Imm12:=Abs(tempnum3) shr 12;
             Pld_aarch64_add_or_sub_immediate(changeptr+4)^.Shift:=1;
            end
           else
            begin
             inc(tempfinal.SecSize[tempindex-1],4);
             tydq_reallocMem(tempfinal.SecContent[tempindex-1],tempfinal.SecSize[tempindex-1]);
             changeptr:=tempfinal.SecContent[tempindex-1]+ldfile.Adjust.SrcOffset[i-1];
             tydq_move(Pbyte(changeptr+4)^,Pbyte(changeptr+8)^,
             tempfinal.SecSize[tempindex-1]-ldfile.Adjust.Srcoffset[i-1]-8);
             if(tempnum3>0) then
             Pdword(changeptr+4)^:=
             ld_aarch64_stub_add(Pdword(changeptr)^ and $1F,Abs(tempnum3) and $FFF,false,ldbit=2)
             else
             Pdword(changeptr+4)^:=
             ld_aarch64_stub_sub(Pdword(changeptr)^ and $1F,Abs(tempnum3) and $FFF,false,ldbit=2);
             inc(movesecoffset2,4);
            end;
          end
         else if(Abs(tempnum3)<>0) then
          begin
           if(ldfile.Adjust.SrcOffset[i-1]+8<=tempfinal.SecSize[tempindex-1]) and
           (Pld_aarch64_add_or_sub_immediate(changeptr+4)^.FixedValue=
           ld_aarch64_add_or_sub_fixed_value) and
           (Pld_aarch64_add_or_sub_immediate(changeptr+4)^.Rd=Pdword(changeptr)^ and $1F) then
            begin
             Pld_aarch64_add_or_sub_immediate(changeptr+4)^.Opcode:=tempnum3<0;
             Pld_aarch64_add_or_sub_immediate(changeptr+4)^.Imm12:=Abs(tempnum3);
            end
           else
            begin
             inc(tempfinal.SecSize[tempindex-1],4);
             tydq_reallocMem(tempfinal.SecContent[tempindex-1],tempfinal.SecSize[tempindex-1]);
             changeptr:=tempfinal.SecContent[tempindex-1]+ldfile.Adjust.SrcOffset[i-1];
             tydq_move(Pbyte(changeptr+4)^,Pbyte(changeptr+8)^,
             tempfinal.SecSize[tempindex-1]-ldfile.Adjust.Srcoffset[i-1]-8);
             if(tempnum3>0) then
             Pdword(changeptr+4)^:=
             ld_aarch64_stub_add(Pdword(changeptr)^ and $1F,Abs(tempnum3) and $FFF,false,ldbit=2)
             else
             Pdword(changeptr+4)^:=
             ld_aarch64_stub_sub(Pdword(changeptr)^ and $1F,Abs(tempnum3) and $FFF,false,ldbit=2);
             inc(movesecoffset2,4);
            end;
          end;
         changeptr:=tempfinal.SecContent[tempindex-1]+ldfile.Adjust.SrcOffset[i-1];
         if(ldfile.Adjust.SrcOffset[i-1]+8<=tempfinal.SecSize[tempindex-1])
         and (Pld_aarch64_add_or_sub_immediate(changeptr+4)^.FixedValue=
         ld_aarch64_add_or_sub_fixed_value) and
         (Pld_aarch64_add_or_sub_immediate(changeptr+4)^.Rd=Pdword(changeptr)^ and $1F) and
         (Pld_aarch64_add_or_sub_immediate(changeptr+4)^.Imm12=0) then
          begin
           tydq_move(Pbyte(changeptr+8)^,Pbyte(changeptr+4)^,
           tempfinal.SecSize[tempindex-1]-ldfile.Adjust.Srcoffset[i-1]-8);
           dec(tempfinal.SecSize[tempindex-1],4);
           tydq_reallocMem(tempfinal.SecContent[tempindex-1],tempfinal.SecSize[tempindex-1]);
           dec(movesecoffset2,4);
          end;
         if(movesecoffset2<>0) then
          begin
           m:=1; tempindex3:=0; tempindex4:=0;
           while(m<=tempfinal.SecCount-1) do
            begin
             n:=1;
             while(n<=tempfinal.SecCount)do
              begin
               if(tempfinal.SecIndex[n-1]=m) then break;
               inc(n);
              end;
             if(n<=tempfinal.SecCount) then tempindex3:=n else tempindex3:=0;
             if(tempindex3=0) then break;
             n:=1;
             while(n<=tempfinal.SecCount)do
              begin
               if(tempfinal.SecIndex[n-1]=m+1) then break;
               inc(n);
              end;
             if(n<=tempfinal.SecCount) then tempindex4:=n else tempindex4:=0;
             if(tempindex4=0) then break;
             if(tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1]<=
             tempfinal.SecAddress[tempindex4-1]) then
              begin
               if(tempfinal.SecName[tempindex4-1]='.text')
               or(tempfinal.SecName[tempindex4-1]='.rodata')
               or(tempfinal.SecName[tempindex4-1]='.data') then
                begin
                 if(ld_align(tempfinal.SecAddress[tempindex4-1],align)-
                 (tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1])>=align) then
                  begin
                   ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                   DynWordArray(tempfinal.SecIndex),
                   tempfinal.SecIndex[tempindex4-1],-align);
                  end;
                end
               else if(tempfinal.SecName[tempindex3-1]<>'.bss') and
               (tempfinal.SecName[tempindex3-1]<>'.tbss') then
                begin
                 if(tempfinal.SecAddress[tempindex4-1]-
                 (tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1])>=ldbit shl 2) then
                  begin
                   ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                   DynWordArray(tempfinal.SecIndex),
                   tempfinal.SecIndex[tempindex4-1],-ldbit shl 2);
                  end;
                end
               else
                begin
                 if(tempfinal.SecAddress[tempindex4-1]-tempfinal.SecAddress[tempindex3-1]>=ldbit shl 2) then
                  begin
                   ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                   DynwordArray(tempfinal.SecIndex),
                   tempfinal.SecIndex[tempindex4-1],-ldbit shl 2);
                  end;
                end;
              end
             else
              begin
               if(tempfinal.SecName[tempindex4-1]='.text')
               or(tempfinal.SecName[tempindex4-1]='.rodata')
               or(tempfinal.SecName[tempindex4-1]='.data') then
                begin
                 if(ld_align(tempfinal.SecAddress[tempindex4-1],align)-
                 (tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1])<=0) then
                  begin
                   ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                   DynWordArray(tempfinal.SecIndex),
                   tempfinal.SecIndex[tempindex4-1],align);
                  end;
                end
               else if(tempfinal.SecName[tempindex3-1]<>'.bss') and
               (tempfinal.SecName[tempindex3-1]<>'.tbss') then
                begin
                 if(tempfinal.SecAddress[tempindex4-1]-
                 (tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1])<=0) then
                  begin
                   ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                   DynWordArray(tempfinal.SecIndex),
                   tempfinal.SecIndex[tempindex4-1],ldbit shl 2);
                  end;
                end
               else
                begin
                 if(tempfinal.SecAddress[tempindex4-1]-
                 (tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1])<0) then
                  begin
                   ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                   DynWordArray(tempfinal.SecIndex),
                   tempfinal.SecIndex[tempindex4-1],ldbit shl 2);
                  end;
                end;
              end;
            inc(m);
           end;
           for m:=1 to ldfile.Adjust.Count do
            begin
             if(ldfile.Adjust.AdjustType[m-1]=0) then continue;
             if(ldfile.Adjust.SrcIndex[i-1]=ldfile.Adjust.SrcIndex[m-1]) then
              begin
               if(ldfile.Adjust.SrcOffset[i-1]+4<=ldfile.Adjust.SrcOffset[m-1]) then
                begin
                 inc(ldfile.Adjust.SrcOffset[m-1],movesecoffset2);
                end;
              end;
             if(ldfile.Adjust.SrcIndex[i-1]=ldfile.Adjust.DestIndex[m-1]) then
              begin
               if(ldfile.Adjust.SrcOffset[i-1]+4<=ldfile.Adjust.DestOffset[m-1]) then
                begin
                 inc(ldfile.Adjust.DestOffset[m-1],movesecoffset2);
                end;
              end;
            end;
           for m:=1 to ldfile.SymTable.SymbolCount do
            begin
             if(ldfile.Adjust.AdjustType[m-1]=0) then continue;
             if(ldfile.Adjust.SrcIndex[i-1]=ldfile.SymTable.SymbolIndex[m-1]) then
              begin
               if(ldfile.Adjust.SrcOffset[i-1]+4<=ldfile.SymTable.SymbolValue[m-1]) then
                begin
                 inc(ldfile.SymTable.SymbolValue[m-1],movesecoffset2);
                end
               else if(ldfile.Adjust.SrcOffset[i-1]=ldfile.SymTable.SymbolValue[m-1]) then
                begin
                 inc(ldfile.SymTable.SymbolSize[m-1],movesecoffset2);
                end;
              end;
            end;
           if(ldfile.Adjust.SrcIndex[i-1]=ldfile.EntryIndex) and
           (ldfile.Adjust.SrcOffset[i-1]+4<=ldfile.EntryOffset) then
            begin
             inc(ldfile.EntryOffset,movesecoffset2);
            end;
           movesecoffset2:=0;
          end;
        end;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_dir_got_offset_ld_st_imm_bit11_3) then
      begin
       if(ld_formula_check_got(ldfile.Adjust.Formula[i-1])) then
        begin
         if(isexternal) then
         tempresult:=tempfinal.SecAddress[gotpltindex-1]
         +writepos[2]*ldbit shl 2+ldfile.Adjust.Addend[i-1]
         else
         tempresult:=tempfinal.SecAddress[gotindex-1]
         +writepos[1]*ldbit shl 2+ldfile.Adjust.Addend[i-1];
        end
       else tempresult:=endoffset+ldfile.Adjust.Addend[i-1];
       tempresult:=(tempresult shr 3) and $1FF;
       if(tempresult=0) and
       (Pld_aarch64_ld_or_st_immediate_12(changeptr)^.Rd=
        Pld_aarch64_ld_or_st_immediate_12(changeptr)^.Rn) then
        begin
         changeptr:=tempfinal.SecContent[tempindex-1]+ldfile.Adjust.Srcoffset[i-1];
         tydq_move(Pbyte(changeptr+4)^,Pbyte(changeptr+0)^,
         tempfinal.SecSize[tempindex-1]-ldfile.Adjust.Srcoffset[i-1]-4);
         dec(tempfinal.SecSize[tempindex-1],4);
         tydq_reallocMem(tempfinal.SecContent[tempindex-1],tempfinal.SecSize[tempindex-1]);
         m:=1; tempindex3:=0; tempindex4:=0;
         while(m<=tempfinal.SecCount-1) do
          begin
           n:=1;
           while(n<=tempfinal.SecCount)do
            begin
             if(tempfinal.SecIndex[n-1]=m) then break;
             inc(n);
            end;
           if(n<=tempfinal.SecCount) then tempindex3:=n else tempindex3:=0;
           if(tempindex3=0) then break;
           n:=1;
           while(n<=tempfinal.SecCount)do
            begin
             if(tempfinal.SecIndex[n-1]=m+1) then break;
             inc(n);
            end;
           if(n<=tempfinal.SecCount) then tempindex4:=n else tempindex4:=0;
           if(tempindex4=0) then break;
           if(tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1]<=
             tempfinal.SecAddress[tempindex4-1]) then
              begin
               if(tempfinal.SecName[tempindex4-1]='.text')
               or(tempfinal.SecName[tempindex4-1]='.rodata')
               or(tempfinal.SecName[tempindex4-1]='.data') then
                begin
                 if(ld_align(tempfinal.SecAddress[tempindex4-1],align)-
                 (tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1])>=align) then
                  begin
                   ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                   DynWordArray(tempfinal.SecIndex),
                   tempfinal.SecIndex[tempindex4-1],-align);
                  end;
                end
               else if(tempfinal.SecName[tempindex3-1]<>'.bss') and
               (tempfinal.SecName[tempindex3-1]<>'.tbss') then
                begin
                 if(tempfinal.SecAddress[tempindex4-1]-
                 (tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1])>=ldbit shl 2) then
                  begin
                   ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                   DynWordArray(tempfinal.SecIndex),
                   tempfinal.SecIndex[tempindex4-1],-ldbit shl 2);
                  end;
                end
               else
                begin
                 if(tempfinal.SecAddress[tempindex4-1]-tempfinal.SecAddress[tempindex3-1]>=ldbit shl 2) then
                  begin
                   ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                   DynwordArray(tempfinal.SecIndex),
                   tempfinal.SecIndex[tempindex4-1],-ldbit shl 2);
                  end;
                end;
              end
             else
              begin
               if(tempfinal.SecName[tempindex4-1]='.text')
               or(tempfinal.SecName[tempindex4-1]='.rodata')
               or(tempfinal.SecName[tempindex4-1]='.data') then
                begin
                 if(ld_align(tempfinal.SecAddress[tempindex4-1],align)-
                 (tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1])<=0) then
                  begin
                   ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                   DynWordArray(tempfinal.SecIndex),
                   tempfinal.SecIndex[tempindex4-1],align);
                  end;
                end
               else if(tempfinal.SecName[tempindex3-1]<>'.bss') and
               (tempfinal.SecName[tempindex3-1]<>'.tbss') then
                begin
                 if(tempfinal.SecAddress[tempindex4-1]-
                 (tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1])<=0) then
                  begin
                   ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                   DynWordArray(tempfinal.SecIndex),
                   tempfinal.SecIndex[tempindex4-1],ldbit shl 2);
                  end;
                end
               else
                begin
                 if(tempfinal.SecAddress[tempindex4-1]-
                 (tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1])<0) then
                  begin
                   ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                   DynWordArray(tempfinal.SecIndex),
                   tempfinal.SecIndex[tempindex4-1],ldbit shl 2);
                  end;
                end;
              end;
           inc(m);
          end;
         for m:=1 to ldfile.Adjust.Count do
          begin
           if(ldfile.Adjust.AdjustType[m-1]=0) then continue;
           if(ldfile.Adjust.SrcIndex[i-1]=ldfile.Adjust.SrcIndex[m-1]) then
            begin
             if(ldfile.Adjust.SrcOffset[i-1]+8<=ldfile.Adjust.SrcOffset[m-1]) then
              begin
               dec(ldfile.Adjust.SrcOffset[m-1],4);
              end;
            end;
           if(ldfile.Adjust.SrcIndex[i-1]=ldfile.Adjust.DestIndex[m-1]) then
            begin
             if(ldfile.Adjust.SrcOffset[i-1]+8<=ldfile.Adjust.DestOffset[m-1]) then
              begin
               dec(ldfile.Adjust.DestOffset[m-1],4);
              end;
            end;
          end;
         for m:=1 to ldfile.SymTable.SymbolCount do
          begin
           if(ldfile.Adjust.SrcIndex[i-1]=ldfile.SymTable.SymbolIndex[m-1]) then
            begin
             if(ldfile.Adjust.SrcOffset[i-1]+8<=ldfile.SymTable.SymbolValue[m-1]) then
              begin
               dec(ldfile.SymTable.SymbolValue[m-1],4);
              end
             else if(ldfile.Adjust.SrcOffset[i-1]=ldfile.SymTable.SymbolValue[m-1]) then
              begin
               dec(ldfile.SymTable.SymbolSize[m-1],4);
              end;
            end;
          end;
         if(ldfile.Adjust.SrcIndex[i-1]=ldfile.EntryIndex) and
         (ldfile.Adjust.SrcOffset[i-1]+8<=ldfile.EntryOffset) then
          begin
           dec(ldfile.EntryOffset,4);
          end;
        end
       else if(Abs(tempresult)>$FF) and (Abs(tempresult)<$10FF) then
        begin
         inc(tempfinal.SecSize[tempindex-1],4);
         tydq_reallocMem(tempfinal.SecContent[tempindex-1],tempfinal.SecSize[tempindex-1]);
         changeptr:=tempfinal.SecContent[tempindex-1]+ldfile.Adjust.SrcOffset[i-1];
         tydq_move(Pbyte(changeptr)^,Pbyte(changeptr+4)^,
         tempfinal.SecSize[tempindex-1]-ldfile.Adjust.Srcoffset[i-1]-4);
         if(tempresult>0) then
         Pdword(changeptr)^:=
         ld_aarch64_stub_add(Pdword(changeptr)^ and $1F,Abs(tempresult-$FF) and $FFF,false,ldbit=2)
         else
         Pdword(changeptr)^:=
         ld_aarch64_stub_sub(Pdword(changeptr)^ and $1F,Abs(tempresult-$FF) and $FFF,false,ldbit=2);
         m:=1; tempindex3:=0; tempindex4:=0;
         while(m<=tempfinal.SecCount-1) do
          begin
           n:=1;
           while(n<=tempfinal.SecCount)do
            begin
             if(tempfinal.SecIndex[n-1]=m) then break;
             inc(n);
            end;
           if(n<=tempfinal.SecCount) then tempindex3:=n else tempindex3:=0;
           if(tempindex3=0) then break;
           n:=1;
           while(n<=tempfinal.SecCount)do
            begin
             if(tempfinal.SecIndex[n-1]=m+1) then break;
             inc(n);
            end;
           if(n<=tempfinal.SecCount) then tempindex4:=n else tempindex4:=0;
           if(tempindex4=0) then break;
           if(tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1]<=
             tempfinal.SecAddress[tempindex4-1]) then
              begin
               if(tempfinal.SecName[tempindex4-1]='.text')
               or(tempfinal.SecName[tempindex4-1]='.rodata')
               or(tempfinal.SecName[tempindex4-1]='.data') then
                begin
                 if(ld_align(tempfinal.SecAddress[tempindex4-1],align)-
                 (tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1])>=align) then
                  begin
                   ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                   DynWordArray(tempfinal.SecIndex),
                   tempfinal.SecIndex[tempindex4-1],-align);
                  end;
                end
               else if(tempfinal.SecName[tempindex3-1]<>'.bss') and
               (tempfinal.SecName[tempindex3-1]<>'.tbss') then
                begin
                 if(tempfinal.SecAddress[tempindex4-1]-
                 (tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1])>=ldbit shl 2) then
                  begin
                   ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                   DynWordArray(tempfinal.SecIndex),
                   tempfinal.SecIndex[tempindex4-1],-ldbit shl 2);
                  end;
                end
               else
                begin
                 if(tempfinal.SecAddress[tempindex4-1]-tempfinal.SecAddress[tempindex3-1]>=ldbit shl 2) then
                  begin
                   ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                   DynwordArray(tempfinal.SecIndex),
                   tempfinal.SecIndex[tempindex4-1],-ldbit shl 2);
                  end;
                end;
              end
             else
              begin
               if(tempfinal.SecName[tempindex4-1]='.text')
               or(tempfinal.SecName[tempindex4-1]='.rodata')
               or(tempfinal.SecName[tempindex4-1]='.data') then
                begin
                 if(ld_align(tempfinal.SecAddress[tempindex4-1],align)-
                 (tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1])<=0) then
                  begin
                   ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                   DynWordArray(tempfinal.SecIndex),
                   tempfinal.SecIndex[tempindex4-1],align);
                  end;
                end
               else if(tempfinal.SecName[tempindex3-1]<>'.bss') and
               (tempfinal.SecName[tempindex3-1]<>'.tbss') then
                begin
                 if(tempfinal.SecAddress[tempindex4-1]-
                 (tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1])<=0) then
                  begin
                   ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                   DynWordArray(tempfinal.SecIndex),
                   tempfinal.SecIndex[tempindex4-1],ldbit shl 2);
                  end;
                end
               else
                begin
                 if(tempfinal.SecAddress[tempindex4-1]-
                 (tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1])<0) then
                  begin
                   ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                   DynWordArray(tempfinal.SecIndex),
                   tempfinal.SecIndex[tempindex4-1],ldbit shl 2);
                  end;
                end;
              end;
           inc(m);
          end;
         for m:=1 to ldfile.Adjust.Count do
          begin
           if(ldfile.Adjust.AdjustType[m-1]=0) then continue;
           if(ldfile.Adjust.SrcIndex[i-1]=ldfile.Adjust.SrcIndex[m-1]) then
            begin
             if(ldfile.Adjust.SrcOffset[i-1]+4<=ldfile.Adjust.SrcOffset[m-1]) then
              begin
               inc(ldfile.Adjust.SrcOffset[m-1],4);
              end;
            end;
           if(ldfile.Adjust.SrcIndex[i-1]=ldfile.Adjust.DestIndex[m-1]) then
            begin
             if(ldfile.Adjust.SrcOffset[i-1]+4<=ldfile.Adjust.DestOffset[m-1]) then
              begin
               inc(ldfile.Adjust.DestOffset[m-1],4);
              end;
            end;
          end;
         for m:=1 to ldfile.SymTable.SymbolCount do
          begin
           if(ldfile.Adjust.SrcIndex[i-1]=ldfile.SymTable.SymbolIndex[m-1]) then
            begin
             if(ldfile.Adjust.SrcOffset[i-1]+4<=ldfile.SymTable.SymbolValue[m-1]) then
              begin
               inc(ldfile.SymTable.SymbolValue[m-1],4);
              end
             else if(ldfile.Adjust.SrcOffset[i-1]=ldfile.SymTable.SymbolValue[m-1]) then
              begin
               inc(ldfile.SymTable.SymbolSize[m-1],4);
              end;
            end;
          end;
         inc(ldfile.Adjust.SrcOffset[i-1],4);
         if(ldfile.Adjust.SrcIndex[i-1]=ldfile.EntryIndex) and
         (ldfile.Adjust.SrcOffset[i-1]+4<=ldfile.EntryOffset) then
          begin
           inc(ldfile.EntryOffset,4);
          end;
        end
       else if(tempresult>=$10FF) and (tempresult<$1000*$1000+$FF) then
        begin
         inc(tempfinal.SecSize[tempindex-1],8);
         tydq_reallocMem(tempfinal.SecContent[tempindex-1],tempfinal.SecSize[tempindex-1]);
         changeptr:=tempfinal.SecContent[tempindex-1]+ldfile.Adjust.SrcOffset[i-1];
         tydq_move(Pbyte(changeptr)^,Pbyte(changeptr+8)^,
         tempfinal.SecSize[tempindex-1]-ldfile.Adjust.Srcoffset[i-1]-8);
         if(tempresult>0) then
          begin
           Pdword(changeptr)^:=
           ld_aarch64_stub_add(Pdword(changeptr)^ and $1F,(Abs(tempresult-$FF) shr 12) and $FFF,false,ldbit=2);
           Pdword(changeptr+4)^:=
           ld_aarch64_stub_add(Pdword(changeptr)^ and $1F,Abs(tempresult-$FF) and $FFF,false,ldbit=2);
          end
         else
          begin
           Pdword(changeptr)^:=
           ld_aarch64_stub_sub(Pdword(changeptr)^ and $1F,(Abs(tempresult-$FF) shr 12) and $FFF,false,ldbit=2);
           Pdword(changeptr+4)^:=
           ld_aarch64_stub_sub(Pdword(changeptr)^ and $1F,Abs(tempresult-$FF) and $FFF,false,ldbit=2);
          end;
         m:=1; tempindex3:=0; tempindex4:=0;
         while(m<=tempfinal.SecCount-1) do
          begin
           n:=1;
           while(n<=tempfinal.SecCount)do
            begin
             if(tempfinal.SecIndex[n-1]=m) then break;
             inc(n);
            end;
           if(n<=tempfinal.SecCount) then tempindex3:=n else tempindex3:=0;
           if(tempindex3=0) then break;
           n:=1;
           while(n<=tempfinal.SecCount)do
            begin
             if(tempfinal.SecIndex[n-1]=m+1) then break;
             inc(n);
            end;
           if(n<=tempfinal.SecCount) then tempindex4:=n else tempindex4:=0;
           if(tempindex4=0) then break;
           if(tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1]<=
             tempfinal.SecAddress[tempindex4-1]) then
              begin
               if(tempfinal.SecName[tempindex4-1]='.text')
               or(tempfinal.SecName[tempindex4-1]='.rodata')
               or(tempfinal.SecName[tempindex4-1]='.data') then
                begin
                 if(ld_align(tempfinal.SecAddress[tempindex4-1],align)-
                 (tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1])>=align) then
                  begin
                   ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                   DynWordArray(tempfinal.SecIndex),
                   tempfinal.SecIndex[tempindex4-1],-align);
                  end;
                end
               else if(tempfinal.SecName[tempindex3-1]<>'.bss') and
               (tempfinal.SecName[tempindex3-1]<>'.tbss') then
                begin
                 if(tempfinal.SecAddress[tempindex4-1]-
                 (tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1])>=ldbit shl 2) then
                  begin
                   ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                   DynWordArray(tempfinal.SecIndex),
                   tempfinal.SecIndex[tempindex4-1],-ldbit shl 2);
                  end;
                end
               else
                begin
                 if(tempfinal.SecAddress[tempindex4-1]-tempfinal.SecAddress[tempindex3-1]>=ldbit shl 2) then
                  begin
                   ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                   DynwordArray(tempfinal.SecIndex),
                   tempfinal.SecIndex[tempindex4-1],-ldbit shl 2);
                  end;
                end;
              end
             else
              begin
               if(tempfinal.SecName[tempindex4-1]='.text')
               or(tempfinal.SecName[tempindex4-1]='.rodata')
               or(tempfinal.SecName[tempindex4-1]='.data') then
                begin
                 if(ld_align(tempfinal.SecAddress[tempindex4-1],align)-
                 (tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1])<=0) then
                  begin
                   ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                   DynWordArray(tempfinal.SecIndex),
                   tempfinal.SecIndex[tempindex4-1],align);
                  end;
                end
               else if(tempfinal.SecName[tempindex3-1]<>'.bss') and
               (tempfinal.SecName[tempindex3-1]<>'.tbss') then
                begin
                 if(tempfinal.SecAddress[tempindex4-1]-
                 (tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1])<=0) then
                  begin
                   ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                   DynWordArray(tempfinal.SecIndex),
                   tempfinal.SecIndex[tempindex4-1],ldbit shl 2);
                  end;
                end
               else
                begin
                 if(tempfinal.SecAddress[tempindex4-1]-
                 (tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1])<0) then
                  begin
                   ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                   DynWordArray(tempfinal.SecIndex),
                   tempfinal.SecIndex[tempindex4-1],ldbit shl 2);
                  end;
                end;
              end;
           inc(m);
          end;
         for m:=1 to ldfile.Adjust.Count do
          begin
           if(ldfile.Adjust.AdjustType[m-1]=0) then continue;
           if(ldfile.Adjust.SrcIndex[i-1]=ldfile.Adjust.SrcIndex[m-1]) then
            begin
             if(ldfile.Adjust.SrcOffset[i-1]<=ldfile.Adjust.SrcOffset[m-1]) then
              begin
               inc(ldfile.Adjust.SrcOffset[m-1],8);
              end;
            end;
           if(ldfile.Adjust.SrcIndex[i-1]=ldfile.Adjust.DestIndex[m-1]) then
            begin
             if(ldfile.Adjust.SrcOffset[i-1]<=ldfile.Adjust.DestOffset[m-1]) then
              begin
               inc(ldfile.Adjust.DestOffset[m-1],8);
              end;
            end;
          end;
         for m:=1 to ldfile.SymTable.SymbolCount do
          begin
           if(ldfile.Adjust.AdjustType[m-1]=0) then continue;
           if(ldfile.Adjust.SrcIndex[i-1]=ldfile.SymTable.SymbolIndex[m-1]) then
            begin
             if(ldfile.Adjust.SrcOffset[i-1]<=ldfile.SymTable.SymbolValue[m-1]) then
              begin
               inc(ldfile.SymTable.SymbolSize[m-1],8);
              end;
            end;
          end;
         inc(ldfile.Adjust.SrcOffset[i-1],8);
         if(ldfile.Adjust.SrcIndex[i-1]=ldfile.EntryIndex) and
         (ldfile.Adjust.SrcOffset[i-1]+8<=ldfile.EntryOffset) then
          begin
           inc(ldfile.EntryOffset,8);
          end;
        end;
      end;
    end;
  end;
 {For Riscv Only}
 writepos[1]:=3; writepos[2]:=3;
 if(ldarch=elf_machine_riscv) then
  begin
   for k:=1 to ldfile.Adjust.Count do
    begin
     index:=ldfile.Adjust.SrcIndex[i-1];
     if(ldfile.SecName[index-1]='.debug_frame') and (debugframe=false) then continue;
     j:=1;
     while(j<=tempfinal.SecCount)do
      begin
       if(ldfile.SecName[index-1]=tempfinal.SecName[j-1]) then break;
       inc(j);
      end;
     if(j>tempfinal.SecCount) then continue;
     startoffset:=tempfinal.SecAddress[j-1]+ldfile.Adjust.SrcOffset[i-1];
     changeptr:=tempfinal.SecContent[j-1]+ldfile.Adjust.Srcoffset[i-1];
     tempindex:=j;
     index:=ldfile.Adjust.DestIndex[i-1];
     if(index>0) then
      begin
       if(ldfile.SecName[index-1]='.debug_frame') and (debugframe=false) then continue;
       j:=1;
       while(j<=tempfinal.SecCount)do
        begin
         if(ldfile.SecName[index-1]=tempfinal.SecName[j-1]) then break;
         inc(j);
        end;
       if(j>tempfinal.SecCount) then continue;
      end;
     tempindex2:=j;
     if(ld_formula_check_got(ldfile.Adjust.Formula[i-1])) then
      begin
       j:=ld_adjust_search_for_index(ldfile.AdjustHashTable,
       DynNatuintArray(ldfile.Adjust.AdjustHash),ldfile.Adjust.AdjustHash[i-1],0,ld_adjust_got);
       if(j<>0) then
        begin
         offset1:=ldfile.AdjustHashTable.AdjustIndex[j-1]; writepos[1]:=2+offset1;
        end
       else
        begin
         offset1:=0; writepos[1]:=0;
        end;
       j:=ld_adjust_search_for_index(ldfile.AdjustHashTable,
       DynNatuintArray(ldfile.Adjust.AdjustHash),ldfile.Adjust.AdjustHash[i-1],0,ld_adjust_got_plt);
       if(j<>0) then
        begin
         offset2:=ldfile.AdjustHashTable.AdjustIndex[j-1]; writepos[2]:=2+offset2;
        end
       else
        begin
         offset2:=0; writepos[2]:=0;
        end;
      end;
     endoffset:=tempfinal.SecAddress[j-1]+ldfile.Adjust.DestOffset[i-1];
     {Rehandle the Adjustment Table For RISC-V}
     isexternal:=false;
     if(isgotbase) or (isgotoffset) then
      begin
       j:=1; writepos[1]:=0; writepos[2]:=0;
       while(j<=tempfinal.GotCount)do
        begin
         if(tempfinal.GotSymbol[j-1]=ldfile.Adjust.AdjustHash[i-1]) then
          begin
           writepos[1]:=2+j; break;
          end;
         inc(j);
        end;
       if(j<=tempfinal.GotCount) then offset1:=j else offset1:=0;
       j:=1;
       while(j<=tempfinal.GotPltCount)do
        begin
         if(tempfinal.GotPltSymbol[j-1]=ldfile.Adjust.AdjustHash[i-1]) then
          begin
           writepos[2]:=2+j; isexternal:=true; break;
          end;
         inc(j);
        end;
       if(j<=tempfinal.GotPltCount) then offset2:=tempfinal.GotCount+j else offset2:=0;
      end;
     if(ldfile.Adjust.Formula[i-1].mask=elf_riscv_u_i_type)then
      begin
       tempnum3:=0; tempnum4:=1;
       if(ld_formula_check_got(ldfile.Adjust.Formula[i-1])) then
        begin
         if(isexternal) then
         tempresult:=(tempfinal.SecAddress[gotpltindex-1]
         +writepos[2]*ldbit shl 2+ldfile.Adjust.Addend[i-1]-startoffset)
         else
         tempresult:=(tempfinal.SecAddress[gotindex-1]
         +writepos[1]*ldbit shl 2+ldfile.Adjust.Addend[i-1]-startoffset);
        end
       else
        begin
         tempresult:=(endoffset+ldfile.Adjust.Addend[i-1]-startoffset);
        end;
       if((tempresult and $FFF=0) or (tempresult shr 12=0)) and
       (ld_riscv_check_ld(Pdword(changeptr+4)^)=false) then
        begin
         if(tempresult and $FFF=0) and (tempresult shr 12=0) then
          begin
           changeptr:=tempfinal.SecContent[tempindex-1]+ldfile.Adjust.Srcoffset[i-1];
           tydq_move(Pbyte(changeptr+8)^,Pbyte(changeptr)^,
           tempfinal.SecSize[tempindex-1]-ldfile.Adjust.Srcoffset[i-1]-8);
           dec(tempfinal.SecSize[tempindex-1],8); movesecoffset:=8; movesecoffset2:=0;
           ldfile.Adjust.AdjustType[i-1]:=0;
          end
         else if(tempresult and $FFF=0) then
          begin
           changeptr:=tempfinal.SecContent[tempindex-1]+ldfile.Adjust.Srcoffset[i-1];
           tydq_move(Pbyte(changeptr+8)^,Pbyte(changeptr+4)^,
           tempfinal.SecSize[tempindex-1]-ldfile.Adjust.Srcoffset[i-1]-8);
           dec(tempfinal.SecSize[tempindex-1],4); movesecoffset:=4; movesecoffset2:=4;
           ldfile.Adjust.Formula[i-1].mask:=elf_riscv_u_type;
          end
         else if(tempresult shr 12=0) then
          begin
           changeptr:=tempfinal.SecContent[tempindex-1]+ldfile.Adjust.Srcoffset[i-1];
           tydq_move(Pbyte(changeptr+4)^,Pbyte(changeptr)^,
           tempfinal.SecSize[tempindex-1]-ldfile.Adjust.Srcoffset[i-1]-4);
           dec(tempfinal.SecSize[tempindex-1],4); movesecoffset:=4; movesecoffset2:=0;
           ldfile.Adjust.Formula[i-1].mask:=elf_riscv_i_type;
          end;
         tydq_reallocMem(tempfinal.SecContent[tempindex-1],tempfinal.SecSize[tempindex-1]);
         m:=1; tempindex3:=0; tempindex4:=0;
         while(m<=tempfinal.SecCount-1) do
          begin
           n:=1;
           while(n<=tempfinal.SecCount)do
            begin
             if(tempfinal.SecIndex[n-1]=m) then break;
             inc(n);
            end;
           if(n<=tempfinal.SecCount) then tempindex3:=n else tempindex3:=0;
           if(tempindex3=0) then break;
           n:=1;
           while(n<=tempfinal.SecCount)do
            begin
             if(tempfinal.SecIndex[n-1]=m+1) then break;
             inc(n);
            end;
           if(n<=tempfinal.SecCount) then tempindex4:=n else tempindex4:=0;
           if(tempindex4=0) then break;
           if(tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1]<=
             tempfinal.SecAddress[tempindex4-1]) then
              begin
               if(tempfinal.SecName[tempindex4-1]='.text')
               or(tempfinal.SecName[tempindex4-1]='.rodata')
               or(tempfinal.SecName[tempindex4-1]='.data') then
                begin
                 if(ld_align(tempfinal.SecAddress[tempindex4-1],align)-
                 (tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1])>=align) then
                  begin
                   ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                   DynWordArray(tempfinal.SecIndex),
                   tempfinal.SecIndex[tempindex4-1],-align);
                  end;
                end
               else if(tempfinal.SecName[tempindex3-1]<>'.bss') and
               (tempfinal.SecName[tempindex3-1]<>'.tbss') then
                begin
                 if(tempfinal.SecAddress[tempindex4-1]-
                 (tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1])>=ldbit shl 2) then
                  begin
                   ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                   DynWordArray(tempfinal.SecIndex),
                   tempfinal.SecIndex[tempindex4-1],-ldbit shl 2);
                  end;
                end
               else
                begin
                 if(tempfinal.SecAddress[tempindex4-1]-tempfinal.SecAddress[tempindex3-1]>=ldbit shl 2) then
                  begin
                   ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                   DynwordArray(tempfinal.SecIndex),
                   tempfinal.SecIndex[tempindex4-1],-ldbit shl 2);
                  end;
                end;
              end
             else
              begin
               if(tempfinal.SecName[tempindex4-1]='.text')
               or(tempfinal.SecName[tempindex4-1]='.rodata')
               or(tempfinal.SecName[tempindex4-1]='.data') then
                begin
                 if(ld_align(tempfinal.SecAddress[tempindex4-1],align)-
                 (tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1])<=0) then
                  begin
                   ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                   DynWordArray(tempfinal.SecIndex),
                   tempfinal.SecIndex[tempindex4-1],align);
                  end;
                end
               else if(tempfinal.SecName[tempindex3-1]<>'.bss') and
               (tempfinal.SecName[tempindex3-1]<>'.tbss') then
                begin
                 if(tempfinal.SecAddress[tempindex4-1]-
                 (tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1])<=0) then
                  begin
                   ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                   DynWordArray(tempfinal.SecIndex),
                   tempfinal.SecIndex[tempindex4-1],ldbit shl 2);
                  end;
                end
               else
                begin
                 if(tempfinal.SecAddress[tempindex4-1]-
                 (tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1])<0) then
                  begin
                   ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                   DynWordArray(tempfinal.SecIndex),
                   tempfinal.SecIndex[tempindex4-1],ldbit shl 2);
                  end;
                end;
              end;
           inc(m);
          end;
         for m:=1 to ldfile.Adjust.Count do
          begin
           if(ldfile.Adjust.AdjustType[m-1]=0) then continue;
           if(ldfile.Adjust.SrcIndex[i-1]=ldfile.Adjust.SrcIndex[m-1]) then
            begin
             if(ldfile.Adjust.SrcOffset[i-1]+movesecoffset2<=ldfile.Adjust.SrcOffset[m-1]) then
              begin
               dec(ldfile.Adjust.SrcOffset[m-1],movesecoffset);
              end;
            end;
           if(ldfile.Adjust.SrcIndex[i-1]=ldfile.Adjust.DestIndex[m-1]) then
            begin
             if(ldfile.Adjust.SrcOffset[i-1]+movesecoffset2<=ldfile.Adjust.DestOffset[m-1]) then
              begin
               dec(ldfile.Adjust.DestOffset[m-1],movesecoffset);
              end;
            end;
          end;
         for m:=1 to ldfile.SymTable.SymbolCount do
          begin
           if(ldfile.Adjust.AdjustType[m-1]=0) then continue;
           if(ldfile.Adjust.SrcIndex[i-1]=ldfile.SymTable.SymbolIndex[m-1]) then
            begin
             if(ldfile.Adjust.SrcOffset[i-1]+movesecoffset2<=ldfile.SymTable.SymbolValue[m-1]) then
              begin
               dec(ldfile.SymTable.SymbolValue[m-1],movesecoffset);
              end
             else if(ldfile.Adjust.SrcOffset[i-1]=ldfile.SymTable.SymbolValue[m-1]) then
              begin
               dec(ldfile.SymTable.SymbolSize[m-1],movesecoffset);
              end;
            end;
          end;
         if(ldfile.Adjust.SrcIndex[i-1]=ldfile.EntryIndex) and
         (ldfile.Adjust.SrcOffset[i-1]+movesecoffset<=ldfile.EntryOffset) then
          begin
           dec(ldfile.EntryOffset,movesecoffset);
          end;
        end;
      end
     else if(ldfile.Adjust.Formula[i-1].mask=elf_riscv_u_type) then
      begin
       if(ld_formula_check_got(ldfile.Adjust.Formula[i-1])) then
        begin
         if(isexternal) then
         tempresult:=(tempfinal.SecAddress[gotpltindex-1]
         +writepos[2]*ldbit shl 2+ldfile.Adjust.Addend[i-1]-startoffset)
         else
         tempresult:=(tempfinal.SecAddress[gotindex-1]
         +writepos[1]*ldbit shl 2+ldfile.Adjust.Addend[i-1]-startoffset);
        end
       else
        begin
         tempresult:=(endoffset+ldfile.Adjust.Addend[i-1]-startoffset);
        end;
       movesecoffset:=0;
       if(ld_riscv_check_ld(Pdword(changeptr+4)^)) and
       (i<ldfile.Adjust.Count) and (ldfile.Adjust.SrcOffset[i]-ldfile.Adjust.SrcOffset[i-1]=4)
       and(ldfile.Adjust.Formula[i].mask=elf_riscv_i_type) then
        begin
         tempresult:=0; ldfile.Adjust.Formula[i-1].mask:=elf_riscv_u_i_type;
         ldfile.Adjust.AdjustType[i]:=0;
        end
       else if(ld_riscv_check_jalr(Pdword(changeptr+4)^)) and
       (i<ldfile.Adjust.Count) and (ldfile.Adjust.SrcOffset[i]-ldfile.Adjust.SrcOffset[i-1]=4)
       and(ldfile.Adjust.Formula[i].mask=elf_riscv_i_type) then
        begin
         tempresult:=0; ldfile.Adjust.Formula[i-1].mask:=elf_riscv_u_i_type;
         ldfile.Adjust.AdjustType[i]:=0;
        end;
       if(tempresult shr 12=0) and (tempresult and $FFF=0)
       and (ld_riscv_check_ld(Pdword(changeptr+4)^)=false) then
        begin
         ldfile.Adjust.AdjustType[i-1]:=0;
         changeptr:=tempfinal.SecContent[tempindex-1]+ldfile.Adjust.Srcoffset[i-1];
         tydq_move(Pbyte(changeptr+4)^,Pbyte(changeptr)^,
         tempfinal.SecSize[tempindex-1]-ldfile.Adjust.Srcoffset[i-1]-4);
         dec(tempfinal.SecSize[tempindex-1],4); movesecoffset:=4;
         tydq_reallocMem(tempfinal.SecContent[tempindex-1],tempfinal.SecSize[tempindex-1]);
         m:=1; tempindex3:=0; tempindex4:=0;
         while(m<=tempfinal.SecCount-1) do
          begin
           n:=1;
           while(n<=tempfinal.SecCount)do
            begin
             if(tempfinal.SecIndex[n-1]=m) then break;
             inc(n);
            end;
           if(n<=tempfinal.SecCount) then tempindex3:=n else tempindex3:=0;
           if(tempindex3=0) then break;
           n:=1;
           while(n<=tempfinal.SecCount)do
            begin
             if(tempfinal.SecIndex[n-1]=m+1) then break;
             inc(n);
            end;
           if(n<=tempfinal.SecCount) then tempindex4:=n else tempindex4:=0;
           if(tempindex4=0) then break;
           if(tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1]<=
           tempfinal.SecAddress[tempindex4-1]) then
              begin
               if(tempfinal.SecName[tempindex4-1]='.text')
               or(tempfinal.SecName[tempindex4-1]='.rodata')
               or(tempfinal.SecName[tempindex4-1]='.data') then
                begin
                 if(ld_align(tempfinal.SecAddress[tempindex4-1],align)-
                 (tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1])>=align) then
                  begin
                   ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                   DynWordArray(tempfinal.SecIndex),
                   tempfinal.SecIndex[tempindex4-1],-align);
                  end;
                end
               else if(tempfinal.SecName[tempindex3-1]<>'.bss') and
               (tempfinal.SecName[tempindex3-1]<>'.tbss') then
                begin
                 if(tempfinal.SecAddress[tempindex4-1]-
                 (tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1])>=ldbit shl 2) then
                  begin
                   ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                   DynWordArray(tempfinal.SecIndex),
                   tempfinal.SecIndex[tempindex4-1],-ldbit shl 2);
                  end;
                end
               else
                begin
                 if(tempfinal.SecAddress[tempindex4-1]-tempfinal.SecAddress[tempindex3-1]>=ldbit shl 2) then
                  begin
                   ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                   DynwordArray(tempfinal.SecIndex),
                   tempfinal.SecIndex[tempindex4-1],-ldbit shl 2);
                  end;
                end;
              end
             else
              begin
               if(tempfinal.SecName[tempindex4-1]='.text')
               or(tempfinal.SecName[tempindex4-1]='.rodata')
               or(tempfinal.SecName[tempindex4-1]='.data') then
                begin
                 if(ld_align(tempfinal.SecAddress[tempindex4-1],align)-
                 (tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1])<=0) then
                  begin
                   ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                   DynWordArray(tempfinal.SecIndex),
                   tempfinal.SecIndex[tempindex4-1],align);
                  end;
                end
               else if(tempfinal.SecName[tempindex3-1]<>'.bss') and
               (tempfinal.SecName[tempindex3-1]<>'.tbss') then
                begin
                 if(tempfinal.SecAddress[tempindex4-1]-
                 (tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1])<=0) then
                  begin
                   ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                   DynWordArray(tempfinal.SecIndex),
                   tempfinal.SecIndex[tempindex4-1],ldbit shl 2);
                  end;
                end
               else
                begin
                 if(tempfinal.SecAddress[tempindex4-1]-
                 (tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1])<0) then
                  begin
                   ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                   DynWordArray(tempfinal.SecIndex),
                   tempfinal.SecIndex[tempindex4-1],ldbit shl 2);
                  end;
                end;
              end;
           inc(m);
          end;
         for m:=1 to ldfile.Adjust.Count do
          begin
           if(ldfile.Adjust.AdjustType[m-1]=0) then continue;
           if(ldfile.Adjust.SrcIndex[i-1]=ldfile.Adjust.SrcIndex[m-1]) then
            begin
             if(ldfile.Adjust.SrcOffset[i-1]<=ldfile.Adjust.SrcOffset[m-1]) then
              begin
               dec(ldfile.Adjust.SrcOffset[m-1],movesecoffset);
              end;
            end;
           if(ldfile.Adjust.SrcIndex[i-1]=ldfile.Adjust.DestIndex[m-1]) then
            begin
             if(ldfile.Adjust.SrcOffset[i-1]<=ldfile.Adjust.DestOffset[m-1]) then
              begin
               dec(ldfile.Adjust.DestOffset[m-1],movesecoffset);
              end;
            end;
          end;
         for m:=1 to ldfile.SymTable.SymbolCount do
          begin
           if(ldfile.Adjust.AdjustType[m-1]=0) then continue;
           if(ldfile.Adjust.SrcIndex[i-1]=ldfile.SymTable.SymbolIndex[m-1]) then
            begin
             if(ldfile.Adjust.SrcOffset[i-1]<=ldfile.SymTable.SymbolValue[m-1]) then
              begin
               dec(ldfile.SymTable.SymbolValue[m-1],movesecoffset);
              end
             else if(ldfile.Adjust.SrcOffset[i-1]=ldfile.SymTable.SymbolValue[m-1]) then
              begin
               dec(ldfile.SymTable.SymbolSize[m-1],movesecoffset);
              end;
            end;
          end;
         ldfile.Adjust.Formula[i-1].mask:=elf_riscv_i_type;
         if(ldfile.Adjust.SrcIndex[i-1]=ldfile.EntryIndex) and
         (ldfile.Adjust.SrcOffset[i-1]<=ldfile.EntryOffset) then
          begin
           dec(ldfile.EntryOffset,movesecoffset);
          end
        end
       else if(tempresult and $FFF<>0) then
        begin
         if(Abs(tempresult and $FFF)>2047) and (tempresult>=0) then
          begin
           tempresult:=tempresult+$1000;
           movesecoffset:=4;
           inc(tempfinal.SecSize[tempindex-1],4);
           tydq_reallocMem(tempfinal.SecContent[tempindex-1],tempfinal.SecSize[tempindex-1]);
           changeptr:=tempfinal.SecContent[tempindex-1]+ldfile.Adjust.SrcOffset[i-1];
           tydq_move(Pbyte(changeptr+4)^,Pbyte(changeptr+8)^,
           tempfinal.SecSize[tempindex-1]-ldfile.Adjust.Srcoffset[i-1]-8);
           Pdword(changeptr+4)^:=ld_riscv_stub_addi(
           Pld_riscv_u_type(changeptr)^.DestinationRegister,
           Pld_riscv_u_type(changeptr)^.DestinationRegister,-($1000-tempresult and $FFF));
          end
         else if(Abs(tempresult and $FFF)>2047) and (tempresult<0) then
          begin
           tempresult:=tempresult-$1000;
           movesecoffset:=4;
           inc(tempfinal.SecSize[tempindex-1],4);
           tydq_reallocMem(tempfinal.SecContent[tempindex-1],tempfinal.SecSize[tempindex-1]);
           changeptr:=tempfinal.SecContent[tempindex-1]+ldfile.Adjust.SrcOffset[i-1];
           tydq_move(Pbyte(changeptr+4)^,Pbyte(changeptr+8)^,
           tempfinal.SecSize[tempindex-1]-ldfile.Adjust.Srcoffset[i-1]-8);
           Pdword(changeptr+4)^:=ld_riscv_stub_addi(
           Pld_riscv_u_type(changeptr)^.DestinationRegister,
           Pld_riscv_u_type(changeptr)^.DestinationRegister,($1000-tempresult and $FFF));
          end
         else
          begin
           movesecoffset:=4;
           inc(tempfinal.SecSize[tempindex-1],4);
           tydq_reallocMem(tempfinal.SecContent[tempindex-1],tempfinal.SecSize[tempindex-1]);
           changeptr:=tempfinal.SecContent[tempindex-1]+ldfile.Adjust.SrcOffset[i-1];
           tydq_move(Pbyte(changeptr+4)^,Pbyte(changeptr+8)^,
           tempfinal.SecSize[tempindex-1]-ldfile.Adjust.Srcoffset[i-1]-12);
           if(tempresult>0) then
            begin
             Pdword(changeptr+4)^:=ld_riscv_stub_addi(
             Pld_riscv_u_type(changeptr)^.DestinationRegister,
             Pld_riscv_u_type(changeptr)^.DestinationRegister,tempresult and $FFF);
            end
           else
            begin
             Pdword(changeptr+4)^:=ld_riscv_stub_addi(
             Pld_riscv_u_type(changeptr)^.DestinationRegister,
             Pld_riscv_u_type(changeptr)^.DestinationRegister,-(tempresult and $FFF));
            end;
          end;
         m:=1; tempindex3:=0; tempindex4:=0;
         while(m<=tempfinal.SecCount-1) do
          begin
           n:=1;
           while(n<=tempfinal.SecCount)do
            begin
             if(tempfinal.SecIndex[n-1]=m) then break;
             inc(n);
            end;
           if(n<=tempfinal.SecCount) then tempindex3:=n else tempindex3:=0;
           if(tempindex3=0) then break;
           n:=1;
           while(n<=tempfinal.SecCount)do
            begin
             if(tempfinal.SecIndex[n-1]=m+1) then break;
             inc(n);
            end;
           if(n<=tempfinal.SecCount) then tempindex4:=n else tempindex4:=0;
           if(tempindex4=0) then break;
           if(tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1]<=
           tempfinal.SecAddress[tempindex4-1]) then
            begin
             if(tempfinal.SecName[tempindex4-1]='.text')
             or(tempfinal.SecName[tempindex4-1]='.rodata')
             or(tempfinal.SecName[tempindex4-1]='.data') then
              begin
               if(ld_align(tempfinal.SecAddress[tempindex4-1],align)-
               (tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1])>=align) then
                begin
                 ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                 DynWordArray(tempfinal.SecIndex),
                 tempfinal.SecIndex[tempindex4-1],-align);
                end;
              end
             else if(tempfinal.SecName[tempindex3-1]<>'.bss') and
             (tempfinal.SecName[tempindex3-1]<>'.tbss') then
              begin
               if(tempfinal.SecAddress[tempindex4-1]-
               (tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1])>=ldbit shl 2) then
                begin
                 ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                 DynWordArray(tempfinal.SecIndex),
                 tempfinal.SecIndex[tempindex4-1],-ldbit shl 2);
                end;
              end
            else
             begin
              if(tempfinal.SecAddress[tempindex4-1]-tempfinal.SecAddress[tempindex3-1]>=ldbit shl 2) then
               begin
                ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                DynwordArray(tempfinal.SecIndex),
                tempfinal.SecIndex[tempindex4-1],-ldbit shl 2);
                end;
              end;
             end
            else
             begin
              if(tempfinal.SecName[tempindex4-1]='.text')
              or(tempfinal.SecName[tempindex4-1]='.rodata')
              or(tempfinal.SecName[tempindex4-1]='.data') then
               begin
                if(ld_align(tempfinal.SecAddress[tempindex4-1],align)-
                (tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1])<=0) then
                 begin
                  ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                  DynWordArray(tempfinal.SecIndex),
                  tempfinal.SecIndex[tempindex4-1],align);
                 end;
               end
              else if(tempfinal.SecName[tempindex3-1]<>'.bss') and
              (tempfinal.SecName[tempindex3-1]<>'.tbss') then
               begin
                if(tempfinal.SecAddress[tempindex4-1]-
                (tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1])<=0) then
                 begin
                  ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                  DynWordArray(tempfinal.SecIndex),
                  tempfinal.SecIndex[tempindex4-1],ldbit shl 2);
                 end;
               end
              else
               begin
                if(tempfinal.SecAddress[tempindex4-1]-
                (tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1])<0) then
                 begin
                  ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                  DynWordArray(tempfinal.SecIndex),
                  tempfinal.SecIndex[tempindex4-1],ldbit shl 2);
                 end;
               end;
             end;
           inc(m);
          end;
         for m:=1 to ldfile.Adjust.Count do
          begin
           if(ldfile.Adjust.AdjustType[m-1]=0) then continue;
           if(ldfile.Adjust.SrcIndex[i-1]=ldfile.Adjust.SrcIndex[m-1]) then
            begin
             if(ldfile.Adjust.SrcOffset[i-1]+4<=ldfile.Adjust.SrcOffset[m-1]) then
              begin
               inc(ldfile.Adjust.SrcOffset[m-1],movesecoffset);
              end;
            end;
           if(ldfile.Adjust.SrcIndex[i-1]=ldfile.Adjust.DestIndex[m-1]) then
            begin
             if(ldfile.Adjust.SrcOffset[i-1]+4<=ldfile.Adjust.DestOffset[m-1]) then
              begin
               inc(ldfile.Adjust.DestOffset[m-1],movesecoffset);
              end;
            end;
          end;
         for m:=1 to ldfile.SymTable.SymbolCount do
          begin
           if(ldfile.Adjust.AdjustType[m-1]=0) then continue;
           if(ldfile.Adjust.SrcIndex[i-1]=ldfile.SymTable.SymbolIndex[m-1]) then
            begin
             if(ldfile.Adjust.SrcOffset[i-1]+4<=ldfile.SymTable.SymbolValue[m-1]) then
              begin
               inc(ldfile.SymTable.SymbolValue[m-1],movesecoffset);
              end
             else if(ldfile.Adjust.SrcOffset[i-1]=ldfile.SymTable.SymbolValue[m-1]) then
              begin
               inc(ldfile.SymTable.SymbolSize[m-1],movesecoffset);
              end;
            end;
          end;
         ldfile.Adjust.Formula[i-1].mask:=elf_riscv_u_i_type;
         if(ldfile.Adjust.SrcIndex[i-1]=ldfile.EntryIndex) and
         (ldfile.Adjust.SrcOffset[i-1]+4<=ldfile.EntryOffset) then
          begin
           inc(ldfile.EntryOffset,movesecoffset);
          end;
        end;
      end;
     m:=1;
     while(m<=ldfile.Adjust.Count) do
      begin
       if(ldfile.Adjust.Formula[i-1].mask=elf_riscv_j_type) or
       (ldfile.Adjust.Formula[i-1].mask=elf_riscv_b_type) or
       (ldfile.Adjust.Formula[i-1].mask=elf_riscv_cb_type) or
       (ldfile.Adjust.Formula[i-1].mask=elf_riscv_cj_type) or
       ((ldfile.Adjust.Formula[i-1].mask=elf_riscv_i_type) and
       (ld_riscv_check_jalr(Pdword(changeptr)^))) or
       ((ldfile.Adjust.Formula[i-1].mask=elf_riscv_u_i_type) and
       (ld_riscv_check_jalr(Pdword(changeptr+4)^))) then
        begin
         break;
        end;
       if(i=m) then
        begin
         inc(m); continue;
        end;
       if(ldfile.Adjust.DestIndex[i-1]=ldfile.Adjust.SrcIndex[m-1])
       and(ldfile.Adjust.DestOffset[i-1]=ldfile.Adjust.SrcOffset[m-1])
       and(ldfile.Adjust.DestOffset[i-1]<>ldfile.Adjust.DestOffset[m-1])
       and(ldfile.Adjust.AdjustHash[i-1]<>ldfile.Adjust.AdjustHash[m-1])then
        begin
         ldfile.Adjust.DestIndex[i-1]:=ldfile.Adjust.DestIndex[m-1];
         ldfile.Adjust.DestOffset[i-1]:=ldfile.Adjust.DestOffset[m-1];
         ldfile.Adjust.AdjustHash[i-1]:=ldfile.Adjust.AdjustHash[m-1];
         ldfile.Adjust.Addend[i-1]:=Natint(ldfile.Adjust.SrcOffset[i-1])-
         Natint(ldfile.Adjust.SrcOffset[m-1]);
         break;
        end
       else inc(m);
      end;
    end;
  end;
 {Now Relocate the file with adjustment table}
 SetLength(tempfinal.Rela.SymOffset,tempfinal.Rela.SymCount);
 SetLength(tempfinal.Rela.SymAddend,tempfinal.Rela.SymCount);
 SetLength(tempfinal.Rela.SymType,tempfinal.Rela.SymCount);
 tempfinal.Rela.SymCount:=0;
 writepos[1]:=3; writepos[2]:=3; startoffset:=0; endoffset:=0;
 movesecoffset:=0; index:=0; offset1:=0; offset2:=0;
 for i:=1 to ldfile.Adjust.Count do
  begin
   if(ldfile.Adjust.AdjustType[i-1]=0) then continue;
   index:=ldfile.Adjust.SrcIndex[i-1];
   if(ldfile.SecName[index-1]='.debug_frame') and (debugframe=false) then continue;
   j:=1;
   while(j<=tempfinal.SecCount)do
    begin
     if(ldfile.SecName[index-1]=tempfinal.SecName[j-1]) then break;
     inc(j);
    end;
   if(j>tempfinal.SecCount) then continue;
   startoffset:=tempfinal.SecAddress[j-1]+ldfile.Adjust.SrcOffset[i-1];
   changeptr:=tempfinal.SecContent[j-1]+ldfile.Adjust.Srcoffset[i-1];
   tempindex:=j;
   index:=ldfile.Adjust.DestIndex[i-1];
   if(ldfile.SecName[index-1]='.debug_frame') and (debugframe=false) then continue;
   j:=1;
   while(j<=tempfinal.SecCount)do
    begin
     if(ldfile.SecName[index-1]=tempfinal.SecName[j-1]) then break;
     inc(j);
    end;
   if(j>tempfinal.SecCount) then continue;
   endoffset:=tempfinal.SecAddress[j-1]+ldfile.Adjust.DestOffset[i-1];
   tempformula:=ldfile.Adjust.Formula[i-1];
   isrelative:=tempformula.isrelative;
   isgotbase:=tempformula.isgotbase;
   isgotoffset:=tempformula.isgotoffset;
   ispaged:=tempformula.ispaged;
   isexternal:=false;
   if(isgotbase) or (isgotoffset) then
    begin
     j:=ld_adjust_search_for_index(ldfile.AdjustHashTable,
     DynNatuintArray(ldfile.Adjust.AdjustHash),ldfile.Adjust.AdjustHash[i-1],0,ld_adjust_got);
     if(j<>0) then
      begin
       offset1:=ldfile.AdjustHashTable.AdjustIndex[j-1]; writepos[1]:=2+offset1;
      end
     else
      begin
       offset1:=0; writepos[1]:=0;
      end;
     j:=ld_adjust_search_for_index(ldfile.AdjustHashTable,
     DynNatuintArray(ldfile.Adjust.AdjustHash),ldfile.Adjust.AdjustHash[i-1],0,ld_adjust_got_plt);
     if(j<>0) then
      begin
       offset2:=ldfile.AdjustHashTable.AdjustIndex[j-1]; writepos[2]:=2+offset2;
      end
     else
      begin
       offset2:=0; writepos[2]:=0;
      end;
    end;
   if(ldarch=elf_machine_386) or (ldarch=elf_machine_x86_64) then
    begin
     if(isexternal) or (ldfile.Adjust.DestIndex[i-1]=0) then
      begin
       tempresult:=ld_calculate_formula(tempformula,
       ['S='+IntToStr(endoffset),'A='+IntToStr(ldfile.Adjust.Addend[i-1]),'B=0',
        'P='+IntToStr(startoffset),'L='+IntToStr(endoffset),
        'GOT='+IntToStr(tempfinal.SecAddress[GotPltIndex-1]),
        'G='+IntToStr(writepos[2]*ldbit shl 2)]);
      end
     else
      begin
       tempresult:=ld_calculate_formula(tempformula,
       ['S='+IntToStr(endoffset),'A='+IntToStr(ldfile.Adjust.Addend[i-1]),'B=0',
        'P='+IntToStr(startoffset),'L='+IntToStr(endoffset),
        'GOT='+IntToStr(tempfinal.SecAddress[GotIndex-1]),
        'G='+IntToStr(writepos[1]*ldbit shl 2)]);
      end;
     if((isgotbase) or (isgotoffset)) or (ldfile.Adjust.DestIndex[i-1]=0) then
      begin
       if(isexternal) or (ldfile.Adjust.DestIndex[i-1]=0) then
        begin
         inc(tempfinal.Rela.SymCount);
         tempfinal.Rela.SymOffset[tempfinal.Rela.SymCount-1]:=tempfinal.SecAddress[GotPltIndex-1]+writepos[2]*ldbit shl 2;
         tempfinal.GotPltTable[writepos[2]]:=0;
         tempfinal.Rela.SymAddend[tempfinal.Rela.SymCount-1]:=0;
         tempfinal.Rela.SymType[tempfinal.Rela.SymCount-1]:=1;
         k:=1;
         while(k<=tempfinal.DynSym.SymbolCount)do
          begin
           if(tempfinal.DynSym.SymbolNameHash[k-1]=ldfile.Adjust.AdjustHash[i-1]) then break;
           inc(k);
          end;
         if(k<=tempfinal.DynSym.SymbolCount) and (ldarch=elf_machine_386) then
          begin
           tempfinal.Rela.SymType[tempfinal.Rela.SymCount-1]:=k shl 8+tempfinal.Rela.SymType[tempfinal.Rela.SymCount-1];
          end
         else if(k<=tempfinal.DynSym.SymbolCount) and (ldarch=elf_machine_x86_64) then
          begin
           tempfinal.Rela.SymType[tempfinal.Rela.SymCount-1]:=k shl 32+tempfinal.Rela.SymType[tempfinal.Rela.SymCount-1];
          end;
        end
       else
        begin
         inc(tempfinal.Rela.SymCount);
         tempfinal.Rela.SymOffset[tempfinal.Rela.SymCount-1]:=tempfinal.SecAddress[GotIndex-1]+writepos[1]*ldbit shl 2;
         tempfinal.GotTable[writepos[1]]:=endoffset+ldfile.Adjust.Addend[i-1];
         tempfinal.Rela.SymAddend[tempfinal.Rela.SymCount-1]:=endoffset+ldfile.Adjust.Addend[i-1];
         tempfinal.Rela.SymType[tempfinal.Rela.SymCount-1]:=8;
        end;
      end
     else if(isrelative=false) then
      begin
       inc(tempfinal.Rela.SymCount);
       tempfinal.Rela.SymOffset[tempfinal.Rela.SymCount-1]:=startoffset;
       tempfinal.Rela.SymAddend[tempfinal.Rela.SymCount-1]:=endoffset+ldfile.Adjust.Addend[i-1];
       tempfinal.Rela.SymType[tempfinal.Rela.SymCount-1]:=8;
      end;
     if(Natuint(changeptr)=ldfile.Adjust.Srcoffset[i-1]) then continue;
     if(ldfile.Adjust.Formula[i-1].bit=8) then
      begin
       Pshortint(changeptr)^:=shortint(tempresult and $FF);
      end
     else if(ldfile.Adjust.Formula[i-1].bit=16) then
      begin
       Psmallint(changeptr)^:=smallint(tempresult and $FFFF);
      end
     else if(ldfile.Adjust.Formula[i-1].bit=32) then
      begin
       if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_x86_64_got_pc_rel) then
        begin
         case Pbyte(changeptr-1)^ of
         $15:Pword(changeptr-2)^:=$E840;
         $25:Pword(changeptr-2)^:=$E940;
         end;
        end
       else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_x86_64_rex_got_pc_rel) then
        begin
         Pbyte(changeptr-2)^:=$8D;
        end;
       PInteger(changeptr)^:=Integer(tempresult and $FFFFFFFF);
      end
     else if(ldfile.Adjust.Formula[i-1].bit=64) then
      begin
       PInt64(changeptr)^:=tempresult;
      end;
    end
   else if(ldarch=elf_machine_arm) then
    begin
     if(isexternal) or (ldfile.Adjust.DestIndex[i-1]=0) then
      begin
       tempresult:=ld_calculate_formula(tempformula,
       ['S='+IntToStr(endoffset),'A='+IntToStr(ldfile.Adjust.Addend[i-1]),
        'B=0','T='+IntToStr(Byte(ldfile.Adjust.AdjustFunc[i-1])),
        'P='+IntToStr(startoffset),
        'Pa='+IntToStr(startoffset and $FFFFFFFC),
        'PLT='+IntToStr(startoffset),
        'GOT_ORG='+IntToStr(tempfinal.SecAddress[GotPltIndex-1]),
        'GOT='+IntToStr(tempfinal.SecAddress[GotPltIndex-1]+writepos[2]*ldbit shl 2)]);
      end
     else
      begin
       tempresult:=ld_calculate_formula(tempformula,
       ['S='+IntToStr(endoffset),'A='+IntToStr(ldfile.Adjust.Addend[i-1]),
        'B=0','T='+IntToStr(Byte(ldfile.Adjust.AdjustFunc[i-1])),
        'P='+IntToStr(startoffset),
        'Pa='+IntToStr(startoffset and $FFFFFFFC),
        'PLT='+IntToStr(startoffset),
        'GOT_ORG='+IntToStr(tempfinal.SecAddress[GotIndex-1]),
        'GOT='+IntToStr(tempfinal.SecAddress[GotIndex-1]+writepos[1]*ldbit shl 2)]);
      end;
     if(isrelative=false) or ((isgotbase) or (isgotoffset)) or (ldfile.Adjust.DestIndex[i-1]=0) then
      begin
       if(isexternal) or (ldfile.Adjust.DestIndex[i-1]=0) then
        begin
         inc(tempfinal.Rela.SymCount);
         tempfinal.Rela.SymOffset[tempfinal.Rela.SymCount-1]:=tempfinal.SecAddress[GotPltIndex-1]+writepos[2]*ldbit shl 2;
         tempfinal.GotPltTable[writepos[2]]:=endoffset+ldfile.Adjust.Addend[i-1];
         tempfinal.Rela.SymAddend[tempfinal.Rela.SymCount-1]:=endoffset+ldfile.Adjust.Addend[i-1];
         tempfinal.Rela.SymType[tempfinal.Rela.SymCount-1]:=elf_reloc_arm_absolute_32bit;
         k:=1;
         while(k<=tempfinal.DynSym.SymbolCount)do
          begin
           if(tempfinal.DynSym.SymbolNameHash[k-1]=ldfile.Adjust.AdjustHash[i-1]) then break;
           inc(k);
          end;
         if(k<=tempfinal.DynSym.SymbolCount) then
          begin
           tempfinal.Rela.SymType[tempfinal.Rela.SymCount-1]:=k shl 8+tempfinal.Rela.SymType[tempfinal.Rela.SymCount-1];
          end;
        end
       else
        begin
         inc(tempfinal.Rela.SymCount);
         tempfinal.Rela.SymOffset[tempfinal.Rela.SymCount-1]:=tempfinal.SecAddress[GotIndex-1]+writepos[1]*ldbit shl 2;
         tempfinal.GotTable[writepos[1]]:=endoffset+ldfile.Adjust.Addend[i-1];
         tempfinal.Rela.SymAddend[tempfinal.Rela.SymCount-1]:=endoffset+ldfile.Adjust.Addend[i-1];
         tempfinal.Rela.SymType[tempfinal.Rela.SymCount-1]:=elf_reloc_arm_relative;
        end;
      end;
     negative:=false;
     if(tempresult<0) then
      begin
       tempresult:=-tempresult; negative:=true;
      end;
     if(tempformula.mask<>0) then tempresult:=tempresult and tempformula.mask;
     if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_arm_pc_relative_13bit_branch) or
     ((ldfile.Adjust.AdjustType[i-1]>=elf_reloc_arm_ldr_str_ldrb_strb_pc_relative_g1)
     and (ldfile.Adjust.AdjustType[i-1]<=elf_reloc_arm_ldr_str_pc_relative_g2))
     or ((ldfile.Adjust.AdjustType[i-1]>=elf_reloc_arm_program_base_relative_ldr_str_ldrb_strb_g0)
     and (ldfile.Adjust.AdjustType[i-1]<=elf_reloc_arm_program_base_relative_ldrs_g2)) then
      begin
       d1:=0;
       if(negative=false) then d1:=1 shl 23;
       d1:=d1 or tempresult;
       d2:=1 shl 23+$FFF; d2:=Pdword(changeptr)^ and (not d2);
       d3:=d1+d2;
       Pdword(changeptr)^:=d3;
      end
     else if((ldfile.Adjust.AdjustType[i-1]>=elf_reloc_arm_ldc_stc_pc_relative_g0) and
     (ldfile.Adjust.AdjustType[i-1]<=elf_reloc_arm_ldc_stc_pc_relative_g2))
     or((ldfile.Adjust.AdjustType[i-1]>=elf_reloc_arm_ldc_base_relative_g0) and
     (ldfile.Adjust.AdjustType[i-1]<=elf_reloc_arm_ldc_base_relative_g2)) then
      begin
       d1:=0;
       if(negative=false) then d1:=1 shl 23;
       d1:=d1 or tempresult;
       d2:=1 shl 23+$FFF; d2:=Pdword(changeptr)^ and (not d2);
       d3:=d1+d2;
       Pdword(changeptr)^:=d3;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_arm_thumb_absolute_5bit) then
      begin
       d1:=(tempresult shr 2) and $7C0;
       d2:=Pdword(changeptr)^ and (not $000007C0);
       d3:=d1+d2;
       Pdword(changeptr)^:=d3;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_arm_thumb_pc_8bit) then
      begin
       d1:=(tempresult shr 2) and $FF;
       d2:=Pdword(changeptr)^ and (not $000000FF);
       d3:=d1+d2;
       Pdword(changeptr)^:=d3;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_arm_thumb_pc_relative_6bit_b) then
      begin
       d1:=(tempresult shr 6) and 1 shl 9+(tempresult shr 1) and $1F;
       d2:=Pdword(changeptr)^ and (not $000002FF);
       d3:=d1+d2;
       Pdword(changeptr)^:=d3;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_arm_thumb_pc_11bit) then
      begin
       d1:=(tempresult shr 1) and $3FF;
       d2:=Pdword(changeptr)^ and (not $000003FF);
       d3:=d1+d2;
       Pdword(changeptr)^:=d3;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_arm_thumb_pc_9bit) then
      begin
       d1:=(tempresult shr 1) and $FF;
       d2:=Pdword(changeptr)^ and (not $000000FF);
       d3:=d1+d2;
       Pdword(changeptr)^:=d3;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_arm_thumb_alu_abs_g0_no_check) then
      begin
       d1:=tempresult and $FF;
       d2:=Pdword(changeptr)^ and (not $000000FF);
       d3:=d1+d2;
       Pdword(changeptr)^:=d3;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_arm_thumb_alu_abs_g1_no_check) then
      begin
       d1:=(tempresult shr 8) and $FF;
       d2:=Pdword(changeptr)^ and (not $000000FF);
       d3:=d1+d2;
       Pdword(changeptr)^:=d3;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_arm_thumb_alu_abs_g2_no_check) then
      begin
       d1:=(tempresult shr 16) and $FF;
       d2:=Pdword(changeptr)^ and (not $000000FF);
       d3:=d1+d2;
       Pdword(changeptr)^:=d3;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_arm_thumb_alu_abs_g3) then
      begin
       d1:=(tempresult shr 24) and $FF;
       d2:=Pdword(changeptr)^ and (not $000000FF);
       d3:=d1+d2;
       Pdword(changeptr)^:=d3;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_arm_thumb_pc_22bit) then
      begin
       d1:=tempresult and $003FFFFF;
       d2:=Pdword(changeptr)^ and (not $003FFFFF);
       d3:=d1+d2;
       Pdword(changeptr)^:=d3;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_arm_thumb_pc_relative_24bit) then
      begin
       d2:=tempresult and $7FF;
       d3:=tempresult shr 11 and $3FF;
       d2:=d2+d3 shl 16;
       d4:=Pdword(changeptr)^ and (not ($000003FF shl 16+$000007FF));
       d4:=d4+d2;
       Pdword(changeptr)^:=d4;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_arm_thumb_movw_absolute)
     or(ldfile.Adjust.AdjustType[i-1]=elf_reloc_arm_thumb_movw_pc_relative)
     or(ldfile.Adjust.AdjustType[i-1]=elf_reloc_arm_thumb_movw_base_relative_no_check)
     or(ldfile.Adjust.AdjustType[i-1]=elf_reloc_arm_thumb_movw_base_relative) then
      begin
       d1:=tempresult and $FF;
       d2:=tempresult shr 12;
       d3:=tempresult shr 8 and $7;
       d4:=tempresult shr 11 and $1;
       d5:=Pdword(changeptr)^ and (not ($000000FF+$00000007 shl 12+$00000001 shl 26+$0000000F shl 16));
       d6:=d5+d1+d2 shl 16+d4 shl 26+d3 shl 12;
       Pdword(changeptr)^:=d6;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_arm_thumb_movt_absolute)
     or(ldfile.Adjust.AdjustType[i-1]=elf_reloc_arm_thumb_movt_pc_relative)
     or(ldfile.Adjust.AdjustType[i-1]=elf_reloc_arm_thumb_movt_base_relative) then
      begin
       d1:=(tempresult shr 16) and $FF;
       d2:=tempresult shr 28;
       d3:=tempresult shr 24 and $7;
       d4:=tempresult shr 27 and $1;
       d5:=Pdword(changeptr)^ and (not ($000000FF+$00000007 shl 12+$00000001 shl 26+$0000000F shl 16));
       d6:=d5+d1+d2 shl 16+d4 shl 26+d3 shl 12;
       Pdword(changeptr)^:=d6;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_arm_thumb_pc_relative_20bit_b) then
      begin
       d1:=tempresult and $7FF;
       d2:=tempresult shr 11 and $3F;
       d2:=d2 shl 16+d1;
       d3:=Pdword(changeptr)^ and (not ($000007FF+$0000003F shl 16));
       d3:=d3+d2;
       Pdword(changeptr)^:=d3;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_arm_thumb_alu_pc_relative_bit11_0) then
      begin
       d1:=tempresult shr 11;
       d2:=tempresult shr 8 and $7;
       d3:=tempresult and $FF;
       d4:=d1 shl 26+d2 shl 12+d3;
       d5:=Pdword(changeptr)^ and (not (1 shl 26+$7 shl 12+$FF));
       d5:=d5+d4;
       Pdword(changeptr)^:=d5;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_arm_thumb_pc_12bit) then
      begin
       d1:=0;
       if(negative=false) then d1:=1 shl 23;
       d1:=d1 or tempresult;
       d2:=1 shl 23+$FFF; d2:=Pdword(changeptr)^ and (not d2);
       d1:=d1+d2;
       Pdword(changeptr)^:=d1;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_arm_thumb_got_entry_relative_to_got_origin) then
      begin
       d1:=Pdword(changeptr)^ and (not (1 shl 23+$FFF));
       d1:=d1+tempresult;
       Pdword(changeptr)^:=d1;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_arm_thumb_bf16) then
      begin
       d1:=tempresult shr 2 and $000003FF;
       d2:=tempresult shr 1 and 1;
       d3:=tempresult shr 12;
       d4:=d1 shl 1+d2 shl 11+d3 shl 16;
       d2:=Pdword(changeptr)^ and (not ($000003FF shl 1+$00000001 shl 11+$0000001F shl 16));
       d4:=d4+d2;
       Pdword(changeptr)^:=d4;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_arm_thumb_bf12) then
      begin
       d1:=tempresult shr 2 and $000003FF;
       d2:=tempresult shr 1 and 1;
       d3:=tempresult shr 12;
       d4:=d1 shl 1+d2 shl 11+d3 shl 16;
       d2:=Pdword(changeptr)^ and (not ($000003FF shl 1+$00000001 shl 11+$00000001 shl 16));
       d4:=d4+d2;
       Pdword(changeptr)^:=d4;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_arm_thumb_bf18) then
      begin
       d1:=tempresult shr 2 and $000003FF;
       d2:=tempresult shr 1 and 1;
       d3:=tempresult shr 12;
       d4:=d1 shl 1+d2 shl 11+d3 shl 16;
       d2:=Pdword(changeptr)^ and (not ($000003FF shl 1+$00000001 shl 11+$0000007F shl 16));
       d4:=d4+d2;
       Pdword(changeptr)^:=d4;
      end
     else if(tempformula.mask<>0) then
      begin
       d1:=Pdword(changeptr)^ and (not Dword(tempformula.mask));
       d1:=d1+tempresult;
       Pdword(changeptr)^:=d1;
      end
     else if(tempformula.bit=32) then
      begin
       PInteger(changeptr)^:=tempresult and $FFFFFFFF;
      end
     else if(tempformula.bit=16) then
      begin
       PShortint(changeptr)^:=tempresult and $FFFF;
      end
     else if(tempformula.bit=8) then
      begin
       PSmallint(changeptr)^:=tempresult and $FF;
      end
    end
   else if(ldarch=elf_machine_aarch64) then
    begin
     if(isexternal) or (ldfile.Adjust.DestIndex[i-1]=0) then
      begin
       tempresult:=ld_calculate_formula(tempformula,
       ['S='+IntToStr(endoffset),'A='+IntToStr(ldfile.Adjust.Addend[i-1]),
        'Delta=0','P='+IntToStr(startoffset),
        'GDAT='+IntToStr(writepos[2]*ldbit shl 2),
        'GOT='+IntToStr(tempfinal.SecAddress[GotPltIndex-1]),
        'G='+IntToStr(tempfinal.SecAddress[GotPltIndex-1])]);
      end
     else
      begin
       tempresult:=ld_calculate_formula(tempformula,
       ['S='+IntToStr(endoffset),'A='+IntToStr(ldfile.Adjust.Addend[i-1]),
        'Delta=0','P='+IntToStr(startoffset),
        'GDAT='+IntToStr(writepos[1]*ldbit shl 2),
        'GOT='+IntToStr(tempfinal.SecAddress[GotIndex-1]),
        'G='+IntToStr(tempfinal.SecAddress[GotIndex-1])]);
      end;
     if(isrelative=false) or ((isgotbase) or (isgotoffset)) or (ldfile.Adjust.DestIndex[i-1]=0) then
      begin
       if(isexternal) or (ldfile.Adjust.DestIndex[i-1]=0) then
        begin
         inc(tempfinal.Rela.SymCount);
         tempfinal.Rela.SymOffset[tempfinal.Rela.SymCount-1]:=tempfinal.SecAddress[GotPltIndex-1]+writepos[2]*ldbit shl 2;
         tempfinal.GotPltTable[writepos[2]]:=0;
         tempfinal.Rela.SymAddend[tempfinal.Rela.SymCount-1]:=0;
         tempfinal.Rela.SymType[tempfinal.Rela.SymCount-1]:=elf_reloc_aarch64_absolute_64bit;
         k:=1;
         while(k<=tempfinal.DynSym.SymbolCount)do
          begin
           if(tempfinal.DynSym.SymbolNameHash[k-1]=ldfile.Adjust.AdjustHash[i-1]) then break;
           inc(k);
          end;
         if(k<=tempfinal.DynSym.SymbolCount) then
          begin
           tempfinal.Rela.SymType[tempfinal.Rela.SymCount-1]:=k shl 32+tempfinal.Rela.SymType[tempfinal.Rela.SymCount-1];
          end;
        end
       else
        begin
         inc(tempfinal.Rela.SymCount);
         tempfinal.Rela.SymOffset[tempfinal.Rela.SymCount-1]:=tempfinal.SecAddress[GotIndex-1]+writepos[1]*ldbit shl 2;
         tempfinal.GotTable[writepos[1]]:=endoffset+ldfile.Adjust.Addend[i-1];
         tempfinal.Rela.SymAddend[tempfinal.Rela.SymCount-1]:=endoffset+ldfile.Adjust.Addend[i-1];
         tempfinal.Rela.SymType[tempfinal.Rela.SymCount-1]:=elf_reloc_aarch64_relative;
        end;
      end;
     negative:=false;
     if(tempresult<0) then
      begin
       tempresult:=-tempresult; negative:=true;
      end;
     if(tempformula.mask<>0) then tempresult:=tempresult and tempformula.mask;
     if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_movz_imm_bit15_0)
     or(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_movk_imm_bit15_0)
     or(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_pc_rel_movk_imm_bit15_0)
     or(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_got_rel_offset_movk_imm_bit15_0) then
      begin
       d1:=tempresult and $FFFF;
       d2:=Pdword(changeptr)^ and (not ($0000FFFF shl 5));
       d2:=d2+d1 shl 5;
       Pdword(changeptr)^:=d2;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_movz_imm_bit31_16)
     or(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_movk_imm_bit31_16)
     or(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_pc_rel_movk_imm_bit31_16)
     or(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_got_rel_offset_movk_imm_bit31_16)then
      begin
       d1:=(tempresult shr 16) and $FFFF;
       d2:=Pdword(changeptr)^ and (not ($0000FFFF shl 5));
       d2:=d2+d1 shl 5;
       Pdword(changeptr)^:=d2;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_movz_imm_bit47_32)
     or(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_movk_imm_bit47_32)
     or(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_pc_rel_movk_imm_bit47_32)
     or(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_got_rel_offset_movk_imm_bit47_32)then
      begin
       d1:=(tempresult shr 32) and $FFFF;
       d2:=Pdword(changeptr)^ and (not ($0000FFFF shl 5));
       d2:=d2+d1 shl 5;
       Pdword(changeptr)^:=d2;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_movn_z_imm_bit15_0)
     or (ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_pc_rel_movn_z_imm_bit15_0)
     or (ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_got_rel_offset_movn_z_imm_bit15_0)then
      begin
       if(negative=false) then d1:=1 shl 30 else d1:=0;
       d2:=Pdword(changeptr)^ and (not ($0000FFFF shl 5+1 shl 30));
       if(negative=false) then d1:=d1+tempresult and $FFFF else d1:=d1+not Word(tempresult and $FFFF);
       d2:=d2+d1 shl 5;
       Pdword(changeptr)^:=d2;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_movn_z_imm_bit31_16)
     or (ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_pc_rel_movn_z_imm_bit31_16)
     or (ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_got_rel_offset_movn_z_imm_bit31_16)then
      begin
       if(negative=false) then d1:=1 shl 30 else d1:=0;
       d2:=Pdword(changeptr)^ and (not ($0000FFFF shl 5+1 shl 30));
       if(negative=false) then d1:=d1+(tempresult shr 16) and $FFFF else d1:=d1+not Word((tempresult shr 16) and $FFFF);
       d2:=d2+d1 shl 5;
       Pdword(changeptr)^:=d2;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_movn_z_imm_bit47_32)
     or(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_pc_rel_movn_z_imm_bit47_32)
     or (ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_got_rel_offset_movn_z_imm_bit47_32)then
      begin
       if(negative=false) then d1:=1 shl 30 else d1:=0;
       d2:=Pdword(changeptr)^ and (not ($0000FFFF shl 5+1 shl 30));
       if(negative=false) then d1:=d1+(tempresult shr 32) and $FFFF else d1:=d1+not Word((tempresult shr 32) and $FFFF);
       d2:=d2+d1 shl 5;
       Pdword(changeptr)^:=d2;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_pc_rel_movn_z_imm_bit63_48)
     or (ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_got_rel_offset_movn_z_imm_bit63_48) then
      begin
       if(negative=false) then d1:=1 shl 30 else d1:=0;
       d2:=Pdword(changeptr)^ and (not ($0000FFFF shl 5+1 shl 30));
       if(negative=false) then d1:=d1+(tempresult shr 48) and $FFFF else d1:=d1+not Word((tempresult shr 48) and $FFFF);
       d2:=d2+d1 shl 5;
       Pdword(changeptr)^:=d2;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_ldr_literal_pc_rel_low19bit)
     or(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_pc_rel_got_offset) then
      begin
       if(negative) then d1:=ld_calc_comple(-(tempresult shr 2),19,true)
       else d1:=(tempresult shr 2) and $0007FFFF;
       d2:=Pdword(changeptr)^ and (not ($0007FFFF shl 5));
       if(negative) then d2:=d2+d1 shl 5+1 shl 23 else d2:=d2+d1 shl 5;
       Pdword(changeptr)^:=d2;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_adr_pc_rel_low21bit) then
      begin
       if(negative) then d1:=ld_calc_comple(-tempresult,21,true)
       else d1:=tempresult and $001FFFFF;
       d2:=d1 and 3; d3:=(d1 shr 2) and $7FFFF;
       d4:=Pdword(changeptr)^ and (not ($0007FFFF shl 5+$00000003 shl 29));
       d4:=d4+d2 shl 29+d3 shl 5;
       Pdword(changeptr)^:=d4;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_adrp_page_rel_bit32_12)
     or(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_adrp_page_rel_bit32_12_no_check)
     or(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_page_rel_adrp_bit32_12)then
      begin
       if(negative) then d1:=ld_calc_comple(-(tempresult shr 12),21,true)
       else d1:=(tempresult shr 12) and $001FFFFF;
       d2:=d1 and 3; d3:=(d1 shr 2) and $7FFFF;
       d4:=Pdword(changeptr)^ and (not ($0007FFFF shl 5+$00000003 shl 29));
       d4:=d4+d2 shl 29+d3 shl 5;
       Pdword(changeptr)^:=d4;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_add_absolute_low12bit) then
      begin
       d1:=tempresult and $00000FFF;
       d2:=Pdword(changeptr)^ and (not ($00000FFF shl 10));
       d2:=d2+d1 shl 10;
       Pdword(changeptr)^:=d2;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_ld_or_st_absolute_low12bit) then
      begin
       d1:=tempresult and $00000FFF;
       d2:=Pdword(changeptr)^ and (not ($00000FFF shl 10));
       d2:=d2+d1 shl 10;
       Pdword(changeptr)^:=d2;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_add_bit16_imm_bit11_1) then
      begin
       d1:=(tempresult shr 1) and $7FF;
       d2:=Pdword(changeptr)^ and (not ($00000FFF shl 10));
       d2:=d2+d1 shl 11;
       Pdword(changeptr)^:=d2;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_add_bit32_imm_bit11_2) then
      begin
       d1:=(tempresult shr 2) and $3FF;
       d2:=Pdword(changeptr)^ and (not ($000003FF shl 10));
       d2:=d2+d1 shl 12;
       Pdword(changeptr)^:=d2;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_add_bit64_imm_bit11_3) then
      begin
       d1:=(tempresult shr 3) and $1FF;
       d2:=Pdword(changeptr)^ and (not ($00000FFF shl 10));
       d2:=d2+d1 shl 13;
       Pdword(changeptr)^:=d2;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_add_bit128_imm_from_bit11_4) then
      begin
       d1:=(tempresult shr 4) and $7F;
       d2:=Pdword(changeptr)^ and (not ($00000FFF shl 10));
       d2:=d2+d1 shl 10;
       Pdword(changeptr)^:=d2;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_pc_rel_tbz_bit15_2) then
      begin
       d1:=(tempresult shr 2) and $1FFF;
       d2:=Pdword(changeptr)^ and (not ($00003FFF shl 5));
       d2:=d2+d1 shl 5;
       Pdword(changeptr)^:=d2;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_pc_rel_cond_or_br_bit20_2) then
      begin
       if(negative) then d1:=ld_calc_comple(-(tempresult shr 2),19,true)
       else d1:=(tempresult shr 2) and $7FFFF;
       d2:=Pdword(changeptr)^ and (not ($0007FFFF shl 5));
       d2:=d2+d1 shl 5;
       Pdword(changeptr)^:=d2;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_pc_rel_jump_bit27_2) or
     (ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_pc_rel_call_bit27_2)then
      begin
       if(negative) then d1:=ld_calc_comple(-(tempresult shr 2),26,true)
       else d1:=(tempresult shr 2) and $03FFFFFF;
       d2:=Pdword(changeptr)^ and (not $03FFFFFF);
       d2:=d2+d1;
       Pdword(changeptr)^:=d2;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_got_rel_offset_ld_st_imm_bit14_3)
     or(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_got_page_rel_got_offset_ld_st_bit14_3) then
      begin
       d1:=(tempresult shr 3) and $FFF;
       d2:=Pdword(changeptr)^ and (not ($00000FFF shl 10));
       d2:=d2+d1 shl 10;
       Pdword(changeptr)^:=d2;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_dir_got_offset_ld_st_imm_bit11_3) then
      begin
       if(tempresult>$1FF) and (negative=false) then
        begin
         d1:=(tempresult shr 3) and $FFF;
         d2:=Pdword(changeptr)^ and (not ($000001FF shl 12+$00000001 shl 11+$00000001 shl 24));
         d2:=d2+d1 shl 10+1 shl 24;
         Pdword(changeptr)^:=d2;
        end
       else
        begin
         d1:=(tempresult shr 3) and $1FF;
         d2:=Pdword(changeptr)^ and (not ($000001FF shl 12+$00000001 shl 11));
         if(negative) then d2:=d2+d1 shl 12+1 shl 11 else d2:=d2+d1 shl 12;
         Pdword(changeptr)^:=d2;
        end;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_got_relative_64bit) then
      begin
       PInt64(changeptr)^:=tempresult;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_got_relative_32bit)
     or(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_pc_relative_got_offset32) then
      begin
       PInteger(changeptr)^:=tempresult;
      end
     else if(tempformula.mask<>0) and (tempformula.bit=64) then
      begin
       q1:=Pqword(changeptr)^ and (not tempformula.mask);
       q1:=q1+tempresult;
       Pqword(changeptr)^:=q1;
      end
     else if(tempformula.mask<>0) and (tempformula.bit=32) then
      begin
       d1:=Pdword(changeptr)^ and (not Dword(tempformula.mask));
       d1:=d1+tempresult;
       Pdword(changeptr)^:=d1;
      end
     else if(tempformula.bit=64) then
      begin
       PInt64(changeptr)^:=tempresult;
      end
     else if(tempformula.bit=32) then
      begin
       PInteger(changeptr)^:=Integer(tempresult and $FFFFFFFF);
      end
     else if(tempformula.bit=16) then
      begin
       Pshortint(changeptr)^:=SmallInt(tempresult and $FFFF);
      end
     else if(tempformula.bit=8) then
      begin
       Psmallint(changeptr)^:=Shortint(tempresult and $FF);
      end;
    end
   else if(ldarch=elf_machine_riscv) then
    begin
     if(ldfile.Adjust.Formula[i-1].bit=8) and
     ((ldfile.Adjust.AdjustType[i-1]=elf_reloc_riscv_add_8bit)
     or(ldfile.Adjust.AdjustType[i-1]=elf_reloc_riscv_sub_8bit)) then
      begin
       q1:=Pbyte(changeptr)^;
      end
     else if(ldfile.Adjust.Formula[i-1].bit=16) and
     ((ldfile.Adjust.AdjustType[i-1]=elf_reloc_riscv_add_16bit)
     or(ldfile.Adjust.AdjustType[i-1]=elf_reloc_riscv_sub_16bit)) then
      begin
       q1:=Pword(changeptr)^;
      end
     else if(ldfile.Adjust.Formula[i-1].bit=32) and
     ((ldfile.Adjust.AdjustType[i-1]=elf_reloc_riscv_add_32bit)
     or(ldfile.Adjust.AdjustType[i-1]=elf_reloc_riscv_sub_32bit)) then
      begin
       q1:=Pdword(changeptr)^;
      end
     else if(ldfile.Adjust.Formula[i-1].bit=64) and
     ((ldfile.Adjust.AdjustType[i-1]=elf_reloc_riscv_add_64bit)
     or(ldfile.Adjust.AdjustType[i-1]=elf_reloc_riscv_sub_64bit)) then
      begin
       q1:=Pqword(changeptr)^;
      end;
     if(isexternal) or (ldfile.Adjust.DestIndex[i-1]=0) then
      begin
       tempresult:=ld_calculate_formula(tempformula,
       ['S='+IntToStr(endoffset),'A='+IntToStr(ldfile.Adjust.Addend[i-1]),
        'Delta=0','P='+IntToStr(startoffset),'V='+IntToStr(q1),
        'G='+IntToStr(writepos[2]*ldbit shl 2),
        'GOT='+IntToStr(tempfinal.SecAddress[GotPltIndex-1])]);
      end
     else
      begin
       tempresult:=ld_calculate_formula(tempformula,
       ['S='+IntToStr(endoffset),'A='+IntToStr(ldfile.Adjust.Addend[i-1]),
        'Delta=0','P='+IntToStr(startoffset),'V='+IntToStr(q1),
        'G='+IntToStr(writepos[1]*ldbit shl 2),
        'GOT='+IntToStr(tempfinal.SecAddress[GotIndex-1])]);
      end;
     negative:=false;
     if(tempresult<0) then
      begin
       tempresult:=-tempresult; negative:=true;
      end;
     if(isrelative=false) or ((isgotbase) or (isgotoffset)) or (ldfile.Adjust.DestIndex[i-1]=0) then
      begin
       if(isexternal) or (ldfile.Adjust.DestIndex[i-1]=0) then
        begin
         inc(tempfinal.Rela.SymCount);
         tempfinal.Rela.SymOffset[tempfinal.Rela.SymCount-1]:=tempfinal.SecAddress[GotPltIndex-1]+writepos[2]*ldbit shl 2;
         tempfinal.GotPltTable[writepos[2]]:=0;
         tempfinal.Rela.SymAddend[tempfinal.Rela.SymCount-1]:=0;
         if(ldbit=1) then
         tempfinal.Rela.SymType[tempfinal.Rela.SymCount-1]:=elf_reloc_riscv_32bit
         else if(ldbit=2) then
         tempfinal.Rela.SymType[tempfinal.Rela.SymCount-1]:=elf_reloc_riscv_64bit;
         k:=1;
         while(k<=tempfinal.DynSym.SymbolCount)do
          begin
           if(tempfinal.DynSym.SymbolNameHash[k-1]=ldfile.Adjust.AdjustHash[i-1]) then break;
           inc(k);
          end;
         if(k<=tempfinal.DynSym.SymbolCount) and (ldbit=1) then
          begin
           tempfinal.Rela.SymType[tempfinal.Rela.SymCount-1]:=k shl 8+tempfinal.Rela.SymType[tempfinal.Rela.SymCount-1];
          end
         else if(k<=tempfinal.DynSym.SymbolCount) and (ldbit=2) then
          begin
           tempfinal.Rela.SymType[tempfinal.Rela.SymCount-1]:=k shl 32+tempfinal.Rela.SymType[tempfinal.Rela.SymCount-1];
          end;
        end
       else
        begin
         inc(tempfinal.Rela.SymCount);
         tempfinal.Rela.SymOffset[tempfinal.Rela.SymCount-1]:=tempfinal.SecAddress[GotIndex-1]+writepos[1]*ldbit shl 2;
         tempfinal.GotTable[writepos[1]]:=endoffset+ldfile.Adjust.Addend[i-1];
         tempfinal.Rela.SymAddend[tempfinal.Rela.SymCount-1]:=endoffset+ldfile.Adjust.Addend[i-1];
         tempfinal.Rela.SymType[tempfinal.Rela.SymCount-1]:=elf_reloc_riscv_relative;
        end;
      end;
     if(tempformula.mask=0) then
      begin
       if(tempformula.bit=6) then
        begin
         d1:=Pbyte(changeptr)^ and $C0;
         d2:=tempresult and $3F;
         Pbyte(changeptr)^:=d1+d2;
        end
       else if(tempformula.bit=8) then
        begin
         Pbyte(changeptr)^:=tempresult and $FF;
        end
       else if(tempformula.bit=16) then
        begin
         Pword(changeptr)^:=tempresult and $FFFF;
        end
       else if(tempformula.bit=32) then
        begin
         Pdword(changeptr)^:=tempresult and $FFFFFFFF;
        end
       else if(tempformula.bit=64) then
        begin
         Pqword(changeptr)^:=tempresult;
        end;
      end
     else if(tempformula.mask=elf_riscv_b_type) then
      begin
       if(negative) then d1:=ld_calc_comple(-((tempresult shr 1) and $FFF),12,true)
       else d1:=(tempresult shr 1) and $FFF;
       d2:=d1 and $F; d3:=(d1 shr 4) and $3F; d4:=(d1 shr 10) and $1;
       d5:=(d1 shr 11) and $1;
       d6:=Pdword(changeptr)^ and (not ($1F shl 7+$7F shl 25));
       d6:=d6+d2 shl 8+d3 shl 25+d4 shl 7+d5 shl 31;
       Pdword(changeptr)^:=d6;
      end
     else if(tempformula.mask=elf_riscv_cb_type) then
      begin
       if(negative) then d7:=ld_calc_comple(-((tempresult shr 1) and $FF),8,true)
       else d7:=(tempresult shr 1) and $FF;
       d1:=(d7 and $3); d2:=(d7 shr 2) and $3;
       d3:=(d7 shr 4) and $1; d4:=(d7 shr 5) and $3;
       d5:=(d7 shr 7) and $1;
       d6:=Pword(changeptr)^ and (not ($1F shl 2+$7 shl 10));
       d6:=d6+d1 shl 3+d2 shl 10+d3 shl 2+d4 shl 5+d5 shl 12;
       Pword(changeptr)^:=d6;
      end
     else if(tempformula.mask=elf_riscv_cj_type) then
      begin
       if(negative) then d10:=ld_calc_comple(-((tempresult shr 1) and $7FF),11,true) shl 1
       else d10:=tempresult and $FFE;
       d1:=(d10 and $20) shr 5; d2:=(d10 and $E) shr 1;
       d3:=(d10 and $40) shr 7; d4:=(d10 and $20) shr 6;
       d5:=(d10 and $400) shr 10; d6:=(d10 and $300) shr 8;
       d7:=(d10 and $10) shr 4;
       d8:=(d10 and $800) shr 11;
       d9:=Pword(changeptr)^ and (not ($7FF shl 2));
       d9:=d9+d1 shl 2+d2 shl 3+d3 shl 6+d4 shl 7+d5 shl 8+d6 shl 9+d7 shl 11+d8 shl 12;
       Pword(changeptr)^:=d9;
      end
     else if(tempformula.mask=elf_riscv_i_type) then
      begin
       if(negative) then d1:=ld_calc_comple(-(tempresult and $FFF),12,true)
       else d1:=tempresult and $FFF;
       d2:=Pdword(changeptr)^ and $000FFFFF;
       d2:=d2+d1 shl 20; Pdword(changeptr)^:=d2;
      end
     else if(tempformula.mask=elf_riscv_s_type) then
      begin
       if(negative) then d5:=ld_calc_comple((tempresult and $FFF),12,true)
       else d5:=tempresult and $FFF;
       d1:=d5 and $1F; d2:=(d5 shr 5) and $3F;
       d3:=(d5 shr 11) and 1;
       d4:=Pdword(changeptr)^ and (not ($1F shl 7+$7F shl 25));
       d4:=d4+d1 shl 7+d2 shl 25+d3 shl 31; Pdword(changeptr)^:=d4;
      end
     else if(tempformula.mask=elf_riscv_u_type) then
      begin
       if(negative) then d2:=ld_calc_comple(-(tempresult shr 12),20,true)
       else d2:=(tempresult shr 12) and $FFFFF;
       d1:=Pdword(changeptr)^ and $00000FFF;
       d1:=d1+d2 shl 12;
       Pdword(changeptr)^:=d1;
      end
     else if(tempformula.mask=elf_riscv_j_type) then
      begin
       if(negative) then d1:=ld_calc_comple(-((tempresult shr 1) and $FFFFF),20,true)
       else d1:=(tempresult shr 1) and $FFFFF;
       d2:=d1 and $3FF; d3:=(d1 shr 10) and 1; d4:=(d1 shr 11) and $FF;
       d5:=(d1 shr 19) and $1;
       d6:=Pdword(changeptr)^ and $00000FFF;
       d6:=d6+d2 shl 21+d3 shl 20+d4 shl 12+d5 shl 31;
       Pdword(changeptr)^:=d6;
      end
     else if(tempformula.mask=elf_riscv_u_i_type) then
      begin
       if(tempresult and $FFF<=$7FF) then
        begin
         {Former is U Type}
         if(negative) then d2:=ld_calc_comple(-(tempresult shr 12),20,true)
         else d2:=(tempresult shr 12) and $FFFFF;
         d1:=Pdword(changeptr)^ and $00000FFF;
         d1:=d1+d2 shl 12;
         Pdword(changeptr)^:=d1;
         {Latter is I Type}
         if(negative) then d1:=ld_calc_comple(-(tempresult and $FFF),12,true)
         else d1:=tempresult and $FFF;
         d2:=Pdword(changeptr+4)^ and $000FFFFF;
         d2:=d2+d1 shl 20; Pdword(changeptr+4)^:=d2;
        end
       else
        begin
         {Former is U Type}
         if(negative) then d2:=ld_calc_comple(-((tempresult+$1000) shr 12),20,true)
         else d2:=((tempresult+$1000) shr 12) and $FFFFF;
         d1:=Pdword(changeptr)^ and $00000FFF;
         d1:=d1+d2 shl 12;
         Pdword(changeptr)^:=d1;
         {Latter is I Type}
         if(negative=false) then d1:=ld_calc_comple(-(($1000-tempresult) and $FFF),12,true)
         else d1:=($1000-tempresult) and $FFF;
         d2:=Pdword(changeptr+4)^ and $000FFFFF;
         d2:=d2+d1 shl 20; Pdword(changeptr+4)^:=d2;
        end;
      end;
    end
   else if(ldarch=elf_machine_loongarch) then
    begin
     if(isexternal) or (ldfile.Adjust.DestIndex[i-1]=0) then
      begin
       tempresult:=ld_calculate_formula(tempformula,
       ['S='+IntToStr(endoffset),'A='+IntToStr(ldfile.Adjust.Addend[i-1]),
        'PC='+IntToStr(startoffset),'B=0',
        'GP='+IntToStr(tempfinal.SecAddress[GotPltIndex-1]),'G='+IntToStr(writepos[2]*ldbit shl 2)]);
      end
     else
      begin
       tempresult:=ld_calculate_formula(tempformula,
       ['S='+IntToStr(endoffset),'A='+IntToStr(ldfile.Adjust.Addend[i-1]),
        'PC='+IntToStr(startoffset),'B=0',
        'GP='+IntToStr(tempfinal.SecAddress[GotIndex-1]),'G='+IntToStr(writepos[1]*ldbit shl 2)]);
      end;
     negative:=false;
     if(tempresult<0) then
      begin
       tempresult:=-tempresult; negative:=true;
      end;
     if(isrelative=false) or ((isgotbase) or (isgotoffset)) or (ldfile.Adjust.DestIndex[i-1]=0) then
      begin
       if(isexternal) or (ldfile.Adjust.DestIndex[i-1]=0) then
        begin
         inc(tempfinal.Rela.SymCount);
         tempfinal.Rela.SymOffset[tempfinal.Rela.SymCount-1]:=tempfinal.SecAddress[GotPltIndex-1]+writepos[2]*ldbit shl 2;
         tempfinal.GotPltTable[writepos[2]]:=0;
         tempfinal.Rela.SymAddend[tempfinal.Rela.SymCount-1]:=0;
         if(ldbit=1) then
         tempfinal.Rela.SymType[tempfinal.Rela.SymCount-1]:=elf_reloc_loongarch_32bit
         else if(ldbit=2) then
         tempfinal.Rela.SymType[tempfinal.Rela.SymCount-1]:=elf_reloc_loongarch_64bit;
         k:=1;
         while(k<=tempfinal.DynSym.SymbolCount)do
          begin
           if(tempfinal.DynSym.SymbolNameHash[k-1]=ldfile.Adjust.AdjustHash[i-1]) then break;
           inc(k);
          end;
         if(k<=tempfinal.DynSym.SymbolCount) and (ldbit=1) then
          begin
           tempfinal.Rela.SymType[tempfinal.Rela.SymCount-1]:=k shl 8+tempfinal.Rela.SymType[tempfinal.Rela.SymCount-1];
          end
         else if(k<=tempfinal.DynSym.SymbolCount) and (ldbit=2) then
          begin
           tempfinal.Rela.SymType[tempfinal.Rela.SymCount-1]:=k shl 32+tempfinal.Rela.SymType[tempfinal.Rela.SymCount-1];
          end;
        end
       else
        begin
         inc(tempfinal.Rela.SymCount);
         tempfinal.Rela.SymOffset[tempfinal.Rela.SymCount-1]:=tempfinal.SecAddress[GotIndex-1]+writepos[1]*ldbit shl 2;
         tempfinal.GotTable[writepos[1]]:=endoffset+ldfile.Adjust.Addend[i-1];
         tempfinal.Rela.SymAddend[tempfinal.Rela.SymCount-1]:=endoffset+ldfile.Adjust.Addend[i-1];
         tempfinal.Rela.SymType[tempfinal.Rela.SymCount-1]:=elf_reloc_loongarch_relative;
        end;
      end;
     if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_loongarch_add_8bit) or
     (ldfile.Adjust.AdjustType[i-1]=elf_reloc_loongarch_sub_8bit) then
      begin
       Pbyte(changeptr)^:=tempresult and $FF;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_loongarch_add_16bit) or
     (ldfile.Adjust.AdjustType[i-1]=elf_reloc_loongarch_sub_16bit) then
      begin
       Pword(changeptr)^:=tempresult and $FFFF;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_loongarch_add_32bit) or
     (ldfile.Adjust.AdjustType[i-1]=elf_reloc_loongarch_sub_32bit) then
      begin
       Pdword(changeptr)^:=tempresult and $FFFFFFFF;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_loongarch_add_64bit) or
     (ldfile.Adjust.AdjustType[i-1]=elf_reloc_loongarch_sub_64bit) then
      begin
       Pqword(changeptr)^:=tempresult;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_loongarch_b16) then
      begin
       if(negative) then d1:=ld_calc_comple(-(tempresult shr 2),16,true)
       else d1:=(tempresult shr 2) and $FFFF;
       d2:=Pdword(changeptr)^ and (not ($0000FFFF shl 10));
       Pdword(changeptr)^:=d2+d1 shl 10;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_loongarch_b21) then
      begin
       if(negative) then d1:=ld_calc_comple(-(tempresult shr 2),21,true)
       else d1:=(tempresult shr 2) and $1FFFFF;
       d2:=(d1 shr 16) and $1F; d3:=d1 and $FFFF;
       d4:=Pdword(changeptr)^ and (not ($0000FFFF shl 10+$1F));
       Pdword(changeptr)^:=d4+d3 shl 10+d2;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_loongarch_b26) then
      begin
       if(negative) then d1:=ld_calc_comple(-(tempresult shr 2),26,true)
       else d1:=(tempresult shr 2) and $3FFFFFF;
       d2:=(d1 shr 16) and $3FF; d3:=d1 and $FFFF;
       d4:=Pdword(changeptr)^ and (not ($0000FFFF shl 10+$3FF));
       Pdword(changeptr)^:=d4+d3 shl 10+d2;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_loongarch_absolute_high_20bit) then
      begin
       d1:=(tempresult shr 12) and $FFFFF;
       d2:=Pdword(changeptr)^ and (not ($FFFFF shl 5));
       Pdword(changeptr)^:=d2+d1 shl 5;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_loongarch_absolute_low_12bit) then
      begin
       d1:=tempresult and $FFF;
       d2:=Pdword(changeptr)^ and (not ($FFF shl 10));
       Pdword(changeptr)^:=d2+d1 shl 10;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_loongarch_absolute_64bit_low_20bit) then
      begin
       if((tempresult shr 32) and $FFFFF<=$7FFFF) then
        begin
         if(negative) then d1:=ld_calc_comple((tempresult shr 32) and $FFFFF,20)
         else d1:=(tempresult shr 32) and $FFFFF;
         d2:=Pdword(changeptr)^ and (not ($FFFFF shl 5));
         Pdword(changeptr)^:=d2+d1 shl 5;
        end
       else
        begin
         if(negative) then d1:=ld_calc_comple(($100000-tempresult shr 32) and $FFFFF,20)
         else d1:=($100000-tempresult shr 32) and $FFFFF;
         d2:=Pdword(changeptr)^ and (not ($FFFFF shl 5));
         Pdword(changeptr)^:=d2+d1 shl 5;
        end;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_loongarch_absolute_64bit_high_12bit) then
      begin
       if((tempresult shr 32) and $FFF<=$7FF) then
        begin
         if(negative) then d1:=ld_calc_comple(-((tempresult shr 52) and $FFF),12)
         else d1:=(tempresult shr 52) and $FFF;
         d2:=Pdword(changeptr)^ and (not ($FFF shl 10));
         Pdword(changeptr)^:=d2+d1 shl 10;
        end
       else
        begin
         if(negative=false) then d1:=ld_calc_comple(-((tempresult shr 52+$1000) and $FFF),12)
         else d1:=(tempresult shr 52+$1000) and $FFF;
         d2:=Pdword(changeptr)^ and (not ($FFF shl 10));
         Pdword(changeptr)^:=d2+d1 shl 10;
        end;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_loongarch_absolute_pcala_high_20bit) then
      begin
       if(tempresult and $FFF<=$7FF) then
        begin
         if(negative) then d1:=ld_calc_comple(-((tempresult shr 12) and $FFFFF),20,true)
         else d1:=(tempresult shr 12) and $FFFFF;
         d2:=Pdword(changeptr)^ and (not ($FFFFF shl 5));
         Pdword(changeptr)^:=d2+d1 shl 5;
        end
       else
        begin
         if(negative) then d1:=ld_calc_comple(-(((tempresult+$1000) shr 12) and $FFFFF),20,true)
         else d1:=((tempresult+$1000) shr 12) and $FFFFF;
         d2:=Pdword(changeptr)^ and (not ($FFFFF shl 5));
         Pdword(changeptr)^:=d2+d1 shl 5;
        end;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_loongarch_absolute_pcala_low_12bit) then
      begin
       if(tempresult and $FFF<=$7FF) then
        begin
         if(negative) then d1:=ld_calc_comple(-(tempresult and $FFF),12,true)
         else d1:=tempresult and $FFF;
         d2:=Pdword(changeptr)^ and (not ($FFF shl 10));
         Pdword(changeptr)^:=d2+d1 shl 10;
        end
       else
        begin
         if(negative=false) then d1:=ld_calc_comple(-(($1000-tempresult) and $FFF),12,true)
         else d1:=($1000-tempresult) and $FFF;
         d2:=Pdword(changeptr)^ and (not ($FFF shl 10));
         Pdword(changeptr)^:=d2+d1 shl 10;
        end;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_loongarch_absolute_pcala64_low_20bit) then
      begin
       if((tempresult shr 32) and $FFFFF<=$7FFFF) then
        begin
         if(negative) then d1:=ld_calc_comple(-((tempresult shr 32) and $FFFFF),20,true)
         else d1:=(tempresult shr 32) and $FFFFF;
         d2:=Pdword(changeptr)^ and (not ($FFFFF shl 5));
         Pdword(changeptr)^:=d2+d1 shl 5;
        end
       else
        begin
         if(negative=false) then d1:=ld_calc_comple(-(($100000-tempresult shr 32) and $FFFFF),20,true)
         else d1:=($100000-tempresult shr 32) and $FFFFF;
         d2:=Pdword(changeptr)^ and (not ($FFFFF shl 5));
         Pdword(changeptr)^:=d2+d1 shl 5;
        end;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_loongarch_absolute_pcala64_high_12bit) then
      begin
       if((tempresult shr 32) and $FFFFF<=$7FFFF) then
        begin
         if(negative) then d1:=ld_calc_comple(-((tempresult shr 52) and $FFF),12,true)
         else d1:=(tempresult shr 52) and $FFF;
         d2:=Pdword(changeptr)^ and (not ($FFF shl 10));
         Pdword(changeptr)^:=d2+d1 shl 10;
        end
       else
        begin
         if(negative) then d1:=ld_calc_comple(-(($1000+tempresult shr 52) and $FFF),12,true)
         else d1:=($1000+tempresult shr 52) and $FFF;
         d2:=Pdword(changeptr)^ and (not ($FFF shl 10));
         Pdword(changeptr)^:=d2+d1 shl 10;
        end;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_loongarch_got_pc_high_20bit) then
      begin
       if(tempresult and $FFF<=$7FF) then
        begin
         if(negative) then d1:=ld_calc_comple(-((tempresult shr 12) and $FFFFF),20,true)
         else d1:=(tempresult shr 12) and $FFFFF;
         d2:=Pdword(changeptr)^ and (not ($FFFFF shl 5));
         Pdword(changeptr)^:=d2+d1 shl 5;
        end
       else
        begin
         if(negative) then d1:=ld_calc_comple(-(((tempresult+$1000) shr 12) and $FFFFF),20,true)
         else d1:=((tempresult+$1000) shr 12) and $FFFFF;
         d2:=Pdword(changeptr)^ and (not ($FFFFF shl 5));
         Pdword(changeptr)^:=d2+d1 shl 5;
        end;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_loongarch_got_pc_low_12bit) then
      begin
       if(tempresult and $FFF<=$7FF) then
        begin
         if(negative) then d1:=ld_calc_comple(-(tempresult and $FFF),12,true)
         else d1:=tempresult and $FFF;
         d2:=Pdword(changeptr)^ and (not ($FFF shl 10));
         Pdword(changeptr)^:=d2+d1 shl 10;
        end
       else
        begin
         if(negative=false) then d1:=ld_calc_comple(-(($1000-tempresult) and $FFF),12,true)
         else d1:=($1000-tempresult) and $FFF;
         d2:=Pdword(changeptr)^ and (not ($FFF shl 10));
         Pdword(changeptr)^:=d2+d1 shl 10;
        end;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_loongarch_got64_pc_low_20bit) then
      begin
       if((tempresult shr 32) and $FFFFF<=$7FFFF) then
        begin
         if(negative) then d1:=ld_calc_comple(-((tempresult shr 32) and $FFFFF),20,true)
         else d1:=(tempresult shr 32) and $FFFFF;
         d2:=Pdword(changeptr)^ and (not ($FFFFF shl 5));
         Pdword(changeptr)^:=d2+d1 shl 5;
        end
       else
        begin
         if(negative=false) then d1:=ld_calc_comple(-((($100000-tempresult) shr 32) and $FFFFF),20,true)
         else d1:=($100000-tempresult shr 32) and $FFFFF;
         d2:=Pdword(changeptr)^ and (not ($FFFFF shl 5));
         Pdword(changeptr)^:=d2+d1 shl 5;
        end;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_loongarch_got64_pc_high_12bit) then
      begin
       if((tempresult shr 32) and $FFFFF<=$7FFFF) then
        begin
         if(negative) then d1:=ld_calc_comple(-((tempresult shr 52) and $FFF),12,true)
         else d1:=(tempresult shr 52) and $FFF;
         d2:=Pdword(changeptr)^ and (not ($FFF shl 10));
         Pdword(changeptr)^:=d2+d1 shl 5;
        end
       else
        begin
         if(negative) then d1:=ld_calc_comple(-((tempresult shr 52+$1000) and $FFF),12,true)
         else d1:=(tempresult shr 52+$1000) and $FFF;
         d2:=Pdword(changeptr)^ and (not ($FFF shl 10));
         Pdword(changeptr)^:=d2+d1 shl 5;
        end;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_loongarch_got_high_20bit) then
      begin
       if(negative) then d1:=ld_calc_comple(-((tempresult shr 12) and $FFFFF),20,true)
       else d1:=(tempresult shr 12) and $FFFFF;
       d2:=Pdword(changeptr)^ and (not ($FFFFF shl 5));
       Pdword(changeptr)^:=d2+d1 shl 5;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_loongarch_got_low_12bit) then
      begin
       if(negative) then d1:=ld_calc_comple(-(tempresult and $FFF),12,true)
       else d1:=tempresult and $FFF;
       d2:=Pdword(changeptr)^ and (not ($FFF shl 10));
       Pdword(changeptr)^:=d2+d1 shl 10;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_loongarch_got64_low_20bit) then
      begin
       if(negative) then d1:=ld_calc_comple(-((tempresult shr 32) and $FFFFF),20,true)
       else d1:=(tempresult shr 32) and $FFFFF;
       d2:=Pdword(changeptr)^ and (not ($FFFFF shl 5));
       Pdword(changeptr)^:=d2+d1 shl 5;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_loongarch_got64_high_12bit) then
      begin
       if(negative) then d1:=ld_calc_comple(-((tempresult shr 52) and $FFF),12,true)
       else d1:=(tempresult shr 52) and $FFF;
       d2:=Pdword(changeptr)^ and (not ($FFF shl 10));
       Pdword(changeptr)^:=d2+d1 shl 5;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_loongarch_32_pc_relative) then
      begin
       if(tempresult and $FFF<=$7FF) then
        begin
         if(negative) then d1:=ld_calc_comple(-((tempresult shr 12) and $FFFFF),20,true)
         else d1:=(tempresult shr 12) and $FFFFF;
         d2:=Pdword(changeptr)^ and (not ($FFFFF shl 5));
         Pdword(changeptr)^:=d2+d1 shl 5;
         if(negative) then d1:=ld_calc_comple(-(tempresult and $FFF),12,true)
         else d1:=tempresult and $FFF;
         d2:=Pdword(changeptr+4)^ and (not ($FFF shl 10));
         Pdword(changeptr+4)^:=d2+d1 shl 10;
        end
       else
        begin
         if(negative) then d1:=ld_calc_comple(-(((tempresult+$1000) shr 12) and $FFFFF),20,true)
         else d1:=((tempresult+$1000) shr 12) and $FFFFF;
         d2:=Pdword(changeptr)^ and (not ($FFFFF shl 5));
         Pdword(changeptr)^:=d2+d1 shl 5;
         if(negative) then d1:=ld_calc_comple(-(($1000-tempresult) and $FFF),12,true)
         else d1:=($1000-tempresult) and $FFF;
         d2:=Pdword(changeptr+4)^ and (not ($FFF shl 10));
         Pdword(changeptr+4)^:=d2+d1 shl 10;
        end;
      end;
    end;
  end;
 {Generate the hash table}
 for i:=1 to tempfinal.Hash.ChainCount do
  begin
   tempnum:=ld_elf_hash(tempfinal.DynSym.SymbolName[i-1]);
   if(tempfinal.Hash.Bucket[tempnum mod tempfinal.Hash.BucketCount+1]=0) then
   tempfinal.Hash.Bucket[tempnum mod tempfinal.Hash.BucketCount+1]:=i
   else
    begin
     tempnum:=tempfinal.Hash.Bucket[tempnum mod tempfinal.Hash.BucketCount+1];
     while(tempfinal.Hash.Chain[tempnum+1]<>0)do tempnum:=tempfinal.Hash.Chain[tempnum+1];
     tempfinal.Hash.Chain[tempnum+1]:=i;
    end;
  end;
 {Generate the Dynamic Table}
 if(ldbit=1) then
  begin
   SetLength(tempfinal.Dynamic32,
   13+Byte(haveinit)+Byte(havefini)+Byte(haveinitarray)*2+Byte(havefiniarray)*2+Byte(havepreinitarray)*2
   +lddynamiclibrary.Count);
   {Hash Table Address}
   j:=1;
   while(j<=tempfinal.SecCount)do
    begin
     if(tempfinal.SecName[j-1]='.hash') then break;
     inc(j);
    end;
   tempfinal.Dynamic32[0].dynamic_entry_type:=elf_dynamic_type_hash;
   tempfinal.Dynamic32[0].dynamic_pointer:=tempfinal.SecAddress[j-1];
   {DynSym Table Address}
   j:=1;
   while(j<=tempfinal.SecCount)do
    begin
     if(tempfinal.SecName[j-1]='.dynsym') then break;
     inc(j);
    end;
   tempfinal.Dynamic32[1].dynamic_entry_type:=elf_dynamic_type_symbol_table;
   tempfinal.Dynamic32[1].dynamic_pointer:=tempfinal.SecAddress[j-1];
   {DynSym Symbol Entry Size}
   tempfinal.Dynamic32[4].dynamic_entry_type:=elf_dynamic_type_symbol_table_entry;
   tempfinal.Dynamic32[4].dynamic_value:=sizeof(elf32_dynamic_entry);
   {DynStr Table Address}
   j:=1;
   while(j<=tempfinal.SecCount)do
    begin
     if(tempfinal.SecName[j-1]='.dynstr') then break;
     inc(j);
    end;
   tempfinal.Dynamic32[2].dynamic_entry_type:=elf_dynamic_type_string_table;
   tempfinal.Dynamic32[2].dynamic_pointer:=tempfinal.SecAddress[j-1];
   {DynStr String Size}
   tempfinal.Dynamic32[3].dynamic_entry_type:=elf_dynamic_type_String_table_size;
   tempfinal.Dynamic32[3].dynamic_value:=tempfinal.SecSize[j-1];
   {Debug Size}
   j:=1;
   while(j<=tempfinal.SecCount)do
    begin
     if(tempfinal.SecName[j-1]='.debug_frame') then break;
     inc(j);
    end;
   tempfinal.Dynamic32[5].dynamic_entry_type:=elf_dynamic_type_debug;
   if(j>tempfinal.SecCount) then
   tempfinal.Dynamic32[5].dynamic_value:=0
   else
   tempfinal.Dynamic32[5].dynamic_value:=tempfinal.SecSize[j-1];
   {Relative Section Address}
   j:=1;
   while(j<=tempfinal.SecCount)do
    begin
     if(tempfinal.SecName[j-1]='.rela.dyn') then break;
     inc(j);
    end;
   tempfinal.Dynamic32[6].dynamic_entry_type:=elf_dynamic_type_rela;
   if(j>tempfinal.SecCount) then
   tempfinal.Dynamic32[6].dynamic_pointer:=0
   else
   tempfinal.Dynamic32[6].dynamic_pointer:=tempfinal.SecAddress[j-1];
   {Relative Section Size}
   tempfinal.Dynamic32[7].dynamic_entry_type:=elf_dynamic_type_rela_size;
   if(j>tempfinal.SecCount) then
   tempfinal.Dynamic32[7].dynamic_value:=0
   else
   tempfinal.Dynamic32[7].dynamic_value:=tempfinal.SecSize[j-1];
   {Relative Section Entry Size}
   tempfinal.Dynamic32[8].dynamic_entry_type:=elf_dynamic_type_rela_entry;
   tempfinal.Dynamic32[8].dynamic_value:=sizeof(elf32_rela);
   {Relative Section Entry Count}
   tempfinal.Dynamic32[9].dynamic_entry_type:=elf_dynamic_type_rela_count;
   tempfinal.Dynamic32[9].dynamic_value:=tempfinal.SecSize[j-1] div sizeof(elf32_rela);
   {Relative Flags}
   tempfinal.Dynamic32[10].dynamic_entry_type:=elf_dynamic_type_flags;
   tempfinal.Dynamic32[10].dynamic_value:=elf_dynamic_flag_bind_now;
   {Relative Second Flags}
   tempfinal.Dynamic32[11].dynamic_entry_type:=elf_dynamic_type_flags_1;
   tempfinal.Dynamic32[11].dynamic_value:=0;
   if(nodefaultlibrary) then
   tempfinal.Dynamic32[11].dynamic_value:=
   tempfinal.Dynamic32[11].dynamic_value or elf_dynamic_flag_1_nodeflib;
   if(format=ld_format_executable_pie) then
   tempfinal.Dynamic32[11].dynamic_value:=
   tempfinal.Dynamic32[11].dynamic_value or elf_dynamic_flag_1_pie;
   {Initialize the Index}
   i:=12;
   {If Init code does exist,generate the dynamic item for init code}
   if(haveinit) then
    begin
     inc(i);
     tempfinal.Dynamic32[i-1].dynamic_entry_type:=elf_dynamic_type_initialization;
     tempfinal.Dynamic32[i-1].dynamic_pointer:=tempfinal.SecAddress[initindex-1];
    end;
   {If Fini code does exist,generate the dynamic item for init code}
   if(havefini) then
    begin
     inc(i);
     tempfinal.Dynamic32[i-1].dynamic_entry_type:=elf_dynamic_type_finalization;
     tempfinal.Dynamic32[i-1].dynamic_pointer:=tempfinal.SecAddress[finiindex-1];
    end;
   {If Init Array code does exist,generate the dynamic item for init code}
   if(haveinitarray) then
    begin
     inc(i,2);
     tempfinal.Dynamic32[i-2].dynamic_entry_type:=elf_dynamic_type_initialize_array;
     tempfinal.Dynamic32[i-2].dynamic_pointer:=tempfinal.SecAddress[initarrayindex-1];
     tempfinal.Dynamic32[i-1].dynamic_entry_type:=elf_dynamic_type_initialize_array_size;
     tempfinal.Dynamic32[i-1].dynamic_pointer:=tempfinal.SecSize[initarrayindex-1];
    end;
   {If Fini Array code does exist,generate the dynamic item for init code}
   if(havefiniarray) then
    begin
     inc(i,2);
     tempfinal.Dynamic32[i-2].dynamic_entry_type:=elf_dynamic_type_finalize_array;
     tempfinal.Dynamic32[i-2].dynamic_pointer:=tempfinal.SecAddress[finiarrayindex-1];
     tempfinal.Dynamic32[i-2].dynamic_entry_type:=elf_dynamic_type_finalize_array_size;
     tempfinal.Dynamic32[i-2].dynamic_pointer:=tempfinal.SecSize[finiarrayindex-1];
    end;
   {If Preinit Array code does exist,generate the dynamic item for init code}
   if(havepreinitarray) then
    begin
     inc(i,2);
     tempfinal.Dynamic32[i-2].dynamic_entry_type:=elf_dynamic_type_preinitialize_array;
     tempfinal.Dynamic32[i-2].dynamic_pointer:=tempfinal.SecAddress[preinitarrayindex-1];
     tempfinal.Dynamic32[i-2].dynamic_entry_type:=elf_dynamic_type_preinitialize_array_size;
     tempfinal.Dynamic32[i-2].dynamic_pointer:=tempfinal.SecSize[preinitarrayindex-1];
    end;
   {Needed Dynamic item}
   if(lddynamiclibrary.count>0) then
    begin
     for j:=1 to lddynamiclibrary.Count do
      begin
       inc(i);
       tempfinal.Dynamic64[i-1].dynamic_entry_type:=elf_dynamic_type_needed;
       tempfinal.Dynamic64[i-1].dynamic_pointer:=lddynamiclibrary.NamePosition[j-1]+1;
      end;
    end;
   {Null Dynamic item}
   inc(i);
   tempfinal.Dynamic32[i-1].dynamic_entry_type:=elf_dynamic_type_null;
   tempfinal.Dynamic32[i-1].dynamic_value:=0;
  end
 else if(ldbit=2) then
  begin
   SetLength(tempfinal.Dynamic64,
   13+Byte(haveinit)+Byte(havefini)+Byte(haveinitarray)*2+Byte(havefiniarray)*2+Byte(havepreinitarray)*2
   +lddynamiclibrary.Count);
   {Hash Table Address}
   j:=1;
   while(j<=tempfinal.SecCount)do
    begin
     if(tempfinal.SecName[j-1]='.hash') then break;
     inc(j);
    end;
   tempfinal.Dynamic64[0].dynamic_entry_type:=elf_dynamic_type_hash;
   tempfinal.Dynamic64[0].dynamic_pointer:=tempfinal.SecAddress[j-1];
   {DynSym Table Address}
   j:=1;
   while(j<=tempfinal.SecCount)do
    begin
     if(tempfinal.SecName[j-1]='.dynsym') then break;
     inc(j);
    end;
   tempfinal.Dynamic64[1].dynamic_entry_type:=elf_dynamic_type_symbol_table;
   tempfinal.Dynamic64[1].dynamic_pointer:=tempfinal.SecAddress[j-1];
   {DynSym Symbol Entry Size}
   tempfinal.Dynamic64[4].dynamic_entry_type:=elf_dynamic_type_symbol_table_entry;
   tempfinal.Dynamic64[4].dynamic_value:=sizeof(elf64_dynamic_entry);
   {DynStr Table Address}
   j:=1;
   while(j<=tempfinal.SecCount)do
    begin
     if(tempfinal.SecName[j-1]='.dynstr') then break;
     inc(j);
    end;
   tempfinal.Dynamic64[2].dynamic_entry_type:=elf_dynamic_type_string_table;
   tempfinal.Dynamic64[2].dynamic_pointer:=tempfinal.SecAddress[j-1];
   {DynStr String Size}
   tempfinal.Dynamic64[3].dynamic_entry_type:=elf_dynamic_type_String_table_size;
   tempfinal.Dynamic64[3].dynamic_value:=tempfinal.SecSize[j-1];
   {Debug Size}
   j:=1;
   while(j<=tempfinal.SecCount)do
    begin
     if(tempfinal.SecName[j-1]='.debug_frame') then break;
     inc(j);
    end;
   tempfinal.Dynamic64[5].dynamic_entry_type:=elf_dynamic_type_debug;
   if(j>tempfinal.SecCount) then
   tempfinal.Dynamic64[5].dynamic_value:=0
   else
   tempfinal.Dynamic64[5].dynamic_value:=tempfinal.SecSize[j-1];
   {Relative Section Address}
   j:=1;
   while(j<=tempfinal.SecCount)do
    begin
     if(tempfinal.SecName[j-1]='.rela.dyn') then break;
     inc(j);
    end;
   tempfinal.Dynamic64[6].dynamic_entry_type:=elf_dynamic_type_rela;
   if(j>tempfinal.SecCount) then
   tempfinal.Dynamic64[6].dynamic_pointer:=0
   else
   tempfinal.Dynamic64[6].dynamic_pointer:=tempfinal.SecAddress[j-1];
   {Relative Section Size}
   tempfinal.Dynamic64[7].dynamic_entry_type:=elf_dynamic_type_rela_size;
   if(j>tempfinal.SecCount) then
   tempfinal.Dynamic64[7].dynamic_value:=0
   else
   tempfinal.Dynamic64[7].dynamic_value:=tempfinal.SecSize[j-1];
   {Relative Section Entry Size}
   tempfinal.Dynamic64[8].dynamic_entry_type:=elf_dynamic_type_rela_entry;
   tempfinal.Dynamic64[8].dynamic_value:=sizeof(elf64_rela);
   {Relative Section Entry Count}
   tempfinal.Dynamic64[9].dynamic_entry_type:=elf_dynamic_type_rela_count;
   if(j>tempfinal.SecCount) then
   tempfinal.Dynamic64[9].dynamic_value:=0
   else
   tempfinal.Dynamic64[9].dynamic_value:=tempfinal.SecSize[j-1] div sizeof(elf64_rela);
   {Relative Flags}
   tempfinal.Dynamic64[10].dynamic_entry_type:=elf_dynamic_type_flags;
   tempfinal.Dynamic64[10].dynamic_value:=elf_dynamic_flag_bind_now;
   {Relative Second Flags}
   tempfinal.Dynamic64[11].dynamic_entry_type:=elf_dynamic_type_flags_1;
   tempfinal.Dynamic64[11].dynamic_value:=0;
   if(nodefaultlibrary) then
   tempfinal.Dynamic64[11].dynamic_value:=
   tempfinal.Dynamic64[11].dynamic_value or elf_dynamic_flag_1_nodeflib;
   if(format=ld_format_executable_pie) then
   tempfinal.Dynamic64[11].dynamic_value:=
   tempfinal.Dynamic64[11].dynamic_value or elf_dynamic_flag_1_pie;
   {Initialize the Index}
   i:=12;
   {If Init code does exist,generate the dynamic item for init code}
   if(haveinit) then
    begin
     inc(i);
     tempfinal.Dynamic64[i-1].dynamic_entry_type:=elf_dynamic_type_initialization;
     tempfinal.Dynamic64[i-1].dynamic_pointer:=tempfinal.SecAddress[initindex-1];
    end;
   {If Fini code does exist,generate the dynamic item for init code}
   if(havefini) then
    begin
     inc(i);
     tempfinal.Dynamic64[i-1].dynamic_entry_type:=elf_dynamic_type_finalization;
     tempfinal.Dynamic64[i-1].dynamic_pointer:=tempfinal.SecAddress[finiindex-1];
    end;
   {If Init Array code does exist,generate the dynamic item for init code}
   if(haveinitarray) then
    begin
     inc(i,2);
     tempfinal.Dynamic64[i-2].dynamic_entry_type:=elf_dynamic_type_initialize_array;
     tempfinal.Dynamic64[i-2].dynamic_pointer:=tempfinal.SecAddress[initarrayindex-1];
     tempfinal.Dynamic64[i-1].dynamic_entry_type:=elf_dynamic_type_initialize_array_size;
     tempfinal.Dynamic64[i-1].dynamic_pointer:=tempfinal.SecSize[initarrayindex-1];
    end;
   {If Fini Array code does exist,generate the dynamic item for init code}
   if(havefiniarray) then
    begin
     inc(i,2);
     tempfinal.Dynamic64[i-2].dynamic_entry_type:=elf_dynamic_type_finalize_array;
     tempfinal.Dynamic64[i-2].dynamic_pointer:=tempfinal.SecAddress[finiarrayindex-1];
     tempfinal.Dynamic64[i-2].dynamic_entry_type:=elf_dynamic_type_finalize_array_size;
     tempfinal.Dynamic64[i-2].dynamic_pointer:=tempfinal.SecSize[finiarrayindex-1];
    end;
   {If Preinit Array code does exist,generate the dynamic item for init code}
   if(havepreinitarray) then
    begin
     inc(i,2);
     tempfinal.Dynamic64[i-2].dynamic_entry_type:=elf_dynamic_type_preinitialize_array;
     tempfinal.Dynamic64[i-2].dynamic_pointer:=tempfinal.SecAddress[preinitarrayindex-1];
     tempfinal.Dynamic64[i-2].dynamic_entry_type:=elf_dynamic_type_preinitialize_array_size;
     tempfinal.Dynamic64[i-2].dynamic_pointer:=tempfinal.SecSize[preinitarrayindex-1];
    end;
   {Needed Dynamic item}
   if(lddynamiclibrary.count>0) then
    begin
     for j:=1 to lddynamiclibrary.Count do
      begin
       inc(i);
       tempfinal.Dynamic64[i-1].dynamic_entry_type:=elf_dynamic_type_needed;
       tempfinal.Dynamic64[i-1].dynamic_pointer:=lddynamiclibrary.NamePosition[j-1]+1;
      end;
    end;
   {Null Dynamic item}
   inc(i);
   tempfinal.Dynamic64[i-1].dynamic_entry_type:=elf_dynamic_type_null;
   tempfinal.Dynamic64[i-1].dynamic_value:=0;
  end;
 {Now Fill the shstrtab section}
 j:=1;
 while(j<=tempfinal.SecCount)do
  begin
   if(tempfinal.SecName[j-1]='.shstrtab') then break;
   inc(j);
  end;
 ptr1:=tempfinal.SecContent[j-1]; offset1:=1;
 i:=1;
 while(i<=tempfinal.SecCount)do
  begin
   j:=1;
   while(j<=tempfinal.SecCount)do
    begin
     if(tempfinal.SecIndex[j-1]=i) then break;
     inc(j);
    end;
   if(j<=tempfinal.SecCount) then
    begin
     k:=1; m:=length(tempfinal.SecName[j-1]);
     while(k<=m)do
      begin
       PChar(ptr1+offset1)^:=tempfinal.SecName[j-1][k];
       inc(offset1); inc(k);
      end;
     PChar(ptr1+offset1)^:=#0; inc(offset1);
    end;
   inc(i);
  end;
 {Fill the strtab section and symtab section}
 j:=1;
 while(j<=tempfinal.SecCount)do
  begin
   if(tempfinal.SecName[j-1]='.strtab') then break;
   inc(j);
  end;
 if(j>tempfinal.SecCount) then goto label5;
 ptr1:=tempfinal.SecContent[j-1]; offset1:=1;
 j:=1;
 while(j<=tempfinal.SecCount)do
  begin
   if(tempfinal.SecName[j-1]='.symtab') then break;
   inc(j);
  end;
 if(j>tempfinal.SecCount) then goto label5;
 ptr2:=tempfinal.SecContent[j-1]; offset2:=0;
 i:=1;
 while(i<=ldfile.SymTable.SymbolCount)do
  begin
   if(ldfile.SymTable.SymbolType[i-1]=0) then
    begin
     inc(i); continue;
    end;
   index:=ldfile.SymTable.SymbolIndex[i-1];
   if(ldfile.SecName[index-1]='.debug_frame') and (debugframe=false) then
    begin
     inc(i); continue;
    end;
   j:=1;
   while(j<=tempfinal.SecCount)do
    begin
     if(ldfile.SecName[index-1]=tempfinal.SecName[j-1]) then break;
     inc(j);
    end;
   if(j>tempfinal.SecCount) then continue;
   startaddress:=tempfinal.SecAddress[j-1]+ldfile.SymTable.SymbolValue[i-1];
   if(ldbit=1) then
    begin
     if(i=1) then
      begin
       Pelf32_symbol_table_entry(ptr2+offset2)^.symbol_name:=0;
       Pelf32_symbol_table_entry(ptr2+offset2)^.symbol_info:=0;
       Pelf32_symbol_table_entry(ptr2+offset2)^.symbol_other:=0;
       Pelf32_symbol_table_entry(ptr2+offset2)^.symbol_section_index:=0;
       Pelf32_symbol_table_entry(ptr2+offset2)^.symbol_size:=0;
       Pelf32_symbol_table_entry(ptr2+offset2)^.symbol_value:=0;
       inc(offset2,sizeof(elf32_symbol_table_entry));
      end;
     Pelf32_symbol_table_entry(ptr2+offset2)^.symbol_name:=offset1;
     Pelf32_symbol_table_entry(ptr2+offset2)^.symbol_info:=ldfile.SymTable.SymbolType[i-1] and $F+
     ldfile.SymTable.SymbolBinding[i-1] shl 4;
     Pelf32_symbol_table_entry(ptr2+offset2)^.symbol_other:=ldfile.SymTable.SymbolVisible[i-1];
     Pelf32_symbol_table_entry(ptr2+offset2)^.symbol_section_index:=tempfinal.SecIndex[index-1];
     Pelf32_symbol_table_entry(ptr2+offset2)^.symbol_size:=ldfile.SymTable.SymbolSize[i-1];
     Pelf32_symbol_table_entry(ptr2+offset2)^.symbol_value:=startaddress;
     inc(offset2,sizeof(elf32_symbol_table_entry));
    end
   else if(ldbit=2) then
    begin
     if(i=1) then
      begin
       Pelf64_symbol_table_entry(ptr2+offset2)^.symbol_name:=0;
       Pelf64_symbol_table_entry(ptr2+offset2)^.symbol_info:=0;
       Pelf64_symbol_table_entry(ptr2+offset2)^.symbol_other:=0;
       Pelf64_symbol_table_entry(ptr2+offset2)^.symbol_section_index:=0;
       Pelf64_symbol_table_entry(ptr2+offset2)^.symbol_size:=0;
       Pelf64_symbol_table_entry(ptr2+offset2)^.symbol_value:=0;
       inc(offset2,sizeof(elf64_symbol_table_entry));
      end;
     Pelf64_symbol_table_entry(ptr2+offset2)^.symbol_name:=offset1;
     Pelf64_symbol_table_entry(ptr2+offset2)^.symbol_info:=ldfile.SymTable.SymbolType[i-1] and $F+
     ldfile.SymTable.SymbolBinding[i-1] shl 4;
     Pelf64_symbol_table_entry(ptr2+offset2)^.symbol_other:=ldfile.SymTable.SymbolVisible[i-1];
     Pelf64_symbol_table_entry(ptr2+offset2)^.symbol_section_index:=tempfinal.SecIndex[index-1];
     Pelf64_symbol_table_entry(ptr2+offset2)^.symbol_size:=ldfile.SymTable.SymbolSize[i-1];
     Pelf64_symbol_table_entry(ptr2+offset2)^.symbol_value:=startaddress;
     inc(offset2,sizeof(elf64_symbol_table_entry));
    end;
   j:=1; k:=length(ldfile.SymTable.SymbolName[i-1]);
   while(j<=k)do
    begin
     PChar(ptr1+offset1)^:=ldfile.SymTable.SymbolName[i-1][j];
     inc(offset1); inc(j);
    end;
   PChar(ptr1+offset1)^:=#0; inc(offset1);
   inc(i);
  end;
 label5:
 {Generate the .dynsym and .dynstr section}
 j:=1;
 while(j<=tempfinal.SecCount)do
  begin
   if(tempfinal.SecName[j-1]='.dynstr') then break;
   inc(j);
  end;
 ptr1:=tempfinal.SecContent[j-1]; offset1:=1;
 j:=1;
 while(j<=tempfinal.SecCount)do
  begin
   if(tempfinal.SecName[j-1]='.dynsym') then break;
   inc(j);
  end;
 {If Dynamic Library Exists,stab the path to .dynstr}
 if(lddynamiclibrary.Count>0) then
  begin
   i:=1;
   while(i<=lddynamiclibrary.Count)do
    begin
     j:=1; k:=length(lddynamiclibrary.Name[i-1]);
     while(j<=k)do
      begin
       PChar(ptr1+offset1)^:=lddynamiclibrary.Name[i-1][j];
       inc(offset1); inc(j);
      end;
     PChar(ptr1+offset1)^:=#0; inc(offset1);
     inc(i);
    end;
  end;
 ptr2:=tempfinal.SecContent[j-1]; offset2:=0;
 i:=1; writepos[1]:=3; writepos[2]:=3;
 while(i<=tempfinal.DynSym.SymbolCount)do
  begin
   index:=tempfinal.DynSym.SymbolIndex[i-1];
   if(tempfinal.SecName[index-1]='.debug_frame') and (debugframe=false) then
    begin
     inc(i); continue;
    end;
   j:=1;
   while(j<=tempfinal.SecCount)do
    begin
     if(ldfile.SecName[index-1]=tempfinal.SecName[j-1]) then break;
     inc(j);
    end;
   if(j>tempfinal.SecCount) then continue;
   k:=1;
   while(k<=tempfinal.GotPltCount)do
    begin
     if(tempfinal.GotPltSymbol[k-1]=tempfinal.DynSym.SymbolNameHash[i-1]) then break;
     inc(k);
    end;
   writepos[2]:=k+2;
   startaddress:=tempfinal.SecAddress[j-1]+tempfinal.DynSym.SymbolValue[i-1];
   if(ldbit=1) then
    begin
     if(i=1) then
      begin
       Pelf32_symbol_table_entry(ptr2+offset2)^.symbol_name:=0;
       Pelf32_symbol_table_entry(ptr2+offset2)^.symbol_info:=0;
       Pelf32_symbol_table_entry(ptr2+offset2)^.symbol_other:=0;
       Pelf32_symbol_table_entry(ptr2+offset2)^.symbol_section_index:=0;
       Pelf32_symbol_table_entry(ptr2+offset2)^.symbol_size:=0;
       Pelf32_symbol_table_entry(ptr2+offset2)^.symbol_value:=0;
       inc(offset2,sizeof(elf32_symbol_table_entry));
      end;
     Pelf32_symbol_table_entry(ptr2+offset2)^.symbol_name:=offset1;
     Pelf32_symbol_table_entry(ptr2+offset2)^.symbol_info:=tempfinal.DynSym.SymbolType[i-1] and $F
     +tempfinal.DynSym.SymbolBinding[i-1] shl 4;
     Pelf32_symbol_table_entry(ptr2+offset2)^.symbol_other:=0;
     j:=1;
     while(j<=tempfinal.SecCount)do
      begin
       if(tempfinal.SecName[j-1]='.got.plt') then break;
       inc(j);
      end;
     Pelf32_symbol_table_entry(ptr2+offset2)^.symbol_section_index:=0;
     Pelf32_symbol_table_entry(ptr2+offset2)^.symbol_size:=0;
     Pelf32_symbol_table_entry(ptr2+offset2)^.symbol_value:=0;
     inc(offset2,sizeof(elf32_symbol_table_entry));
    end
   else if(ldbit=2) then
    begin
     if(i=1) then
      begin
       Pelf64_symbol_table_entry(ptr2+offset2)^.symbol_name:=0;
       Pelf64_symbol_table_entry(ptr2+offset2)^.symbol_info:=0;
       Pelf64_symbol_table_entry(ptr2+offset2)^.symbol_other:=0;
       Pelf64_symbol_table_entry(ptr2+offset2)^.symbol_section_index:=0;
       Pelf64_symbol_table_entry(ptr2+offset2)^.symbol_size:=0;
       Pelf64_symbol_table_entry(ptr2+offset2)^.symbol_value:=0;
       inc(offset2,sizeof(elf64_symbol_table_entry));
      end;
     Pelf64_symbol_table_entry(ptr2+offset2)^.symbol_name:=offset1;
     Pelf64_symbol_table_entry(ptr2+offset2)^.symbol_info:=tempfinal.DynSym.SymbolType[i-1] and $F
     +tempfinal.DynSym.SymbolBinding[i-1] shl 4;
     Pelf64_symbol_table_entry(ptr2+offset2)^.symbol_other:=0;
     j:=1;
     while(j<=tempfinal.SecCount)do
      begin
       if(tempfinal.SecName[j-1]='.got.plt') then break;
       inc(j);
      end;
     Pelf64_symbol_table_entry(ptr2+offset2)^.symbol_section_index:=0;
     Pelf64_symbol_table_entry(ptr2+offset2)^.symbol_size:=0;
     Pelf64_symbol_table_entry(ptr2+offset2)^.symbol_value:=0;
     inc(offset2,sizeof(elf64_symbol_table_entry));
    end;
   j:=1; k:=length(tempfinal.DynSym.SymbolName[i-1]);
   while(j<=k)do
    begin
     PChar(ptr1+offset1)^:=tempfinal.DynSym.SymbolName[i-1][j];
     inc(offset1); inc(j);
    end;
   PChar(ptr1+offset1)^:=#0; inc(offset1);
   inc(i);
  end;
 {Generate the dynamic table}
 j:=1;
 while(j<=tempfinal.SecCount)do
  begin
   if(tempfinal.SecName[j-1]='.dynamic') then break;
   inc(j);
  end;
 if(Length(tempfinal.GotTable)>0) then tempfinal.GotTable[0]:=tempfinal.SecAddress[j-1];
 if(Length(tempfinal.GotPltTable)>0) then tempfinal.GotPltTable[0]:=tempfinal.SecAddress[j-1];
 ptr1:=tempfinal.SecContent[j-1]; offset1:=0; i:=1;
 if(ldbit=1) then
  begin
   while(i<=Length(tempfinal.Dynamic32))do
    begin
     Pelf32_dynamic_entry(ptr1+offset1)^:=tempfinal.Dynamic32[i-1];
     inc(offset1,sizeof(elf32_dynamic_entry));
     inc(i);
    end;
  end
 else if(ldbit=2) then
  begin
   while(i<=Length(tempfinal.Dynamic64)) do
    begin
     Pelf64_dynamic_entry(ptr1+offset1)^:=tempfinal.Dynamic64[i-1];
     inc(offset1,sizeof(elf64_dynamic_entry));
     inc(i);
    end;
  end;
 {Generate the rela table of .rela.dyn}
 j:=1;
 while(j<=tempfinal.SecCount)do
  begin
   if(tempfinal.SecName[j-1]='.rela.dyn') then break;
   inc(j);
  end;
 if(j>tempfinal.SecCount) then goto label3;
 ptr1:=tempfinal.SecContent[j-1]; offset1:=0; i:=1;
 if(ldbit=1) then
  begin
   while(i<=tempfinal.Rela.SymCount)do
    begin
     Pelf32_rela(ptr1+offset1)^.Offset:=tempfinal.Rela.SymOffset[i-1];
     Pelf32_rela(ptr1+offset1)^.Info:=tempfinal.Rela.SymType[i-1];
     Pelf32_rela(ptr1+offset1)^.Addend:=tempfinal.Rela.SymAddend[i-1];
     inc(offset1,sizeof(elf32_rela));
     inc(i);
    end;
  end
 else if(ldbit=2) then
  begin
   while(i<=tempfinal.Rela.SymCount)do
    begin
     Pelf64_rela(ptr1+offset1)^.Offset:=tempfinal.Rela.SymOffset[i-1];
     Pelf64_rela(ptr1+offset1)^.Info:=tempfinal.Rela.SymType[i-1];
     Pelf64_rela(ptr1+offset1)^.Addend:=tempfinal.Rela.SymAddend[i-1];
     inc(offset1,sizeof(elf64_rela));
     inc(i);
    end;
  end;
 label3:
 {Generate the hash table}
 j:=1;
 while(j<=tempfinal.SecCount)do
  begin
   if(tempfinal.SecName[j-1]='.hash') then break;
   inc(j);
  end;
 ptr1:=tempfinal.SecContent[j-1]; offset1:=0;
 Pdword(ptr1+offset1)^:=tempfinal.Hash.BucketCount;
 inc(offset1,4);
 Pdword(ptr1+offset1)^:=tempfinal.Hash.ChainCount;
 inc(offset1,4);
 i:=1;
 while(i<=tempfinal.Hash.BucketCount)do
  begin
   Pdword(ptr1+offset1)^:=tempfinal.Hash.Bucket[i-1]; inc(offset1,4); inc(i);
  end;
 i:=1;
 while(i<=tempfinal.Hash.ChainCount)do
  begin
   Pdword(ptr1+offset1)^:=tempfinal.Hash.Chain[i-1]; inc(offset1,4); inc(i);
  end;
 {Generate the .got table}
 j:=1;
 while(j<=tempfinal.SecCount)do
  begin
   if(tempfinal.SecName[j-1]='.got') then break;
   inc(j);
  end;
 if(j>tempfinal.SecCount) then goto label1;
 ptr1:=tempfinal.SecContent[j-1]; offset1:=0;
 j:=1; k:=length(tempfinal.GotTable);
 while(j<=k)do
  begin
   if(ldbit=1) then
    begin
     Pdword(ptr1+offset1)^:=tempfinal.GotTable[j-1];
     inc(offset1,4);
    end
   else if(ldbit=2) then
    begin
     Pqword(ptr1+offset1)^:=tempfinal.GotTable[j-1];
     inc(offset1,8);
    end;
   inc(j);
  end;
 label1:
 {Generate the .got.plt table}
 j:=1;
 while(j<=tempfinal.SecCount)do
  begin
   if(tempfinal.SecName[j-1]='.got.plt') then break;
   inc(j);
  end;
 if(j>tempfinal.SecCount) then goto label2;
 ptr1:=tempfinal.SecContent[j-1]; offset1:=0;
 j:=1; k:=length(tempfinal.GotPltTable);
 while(j<=k)do
  begin
   if(ldbit=1) then
    begin
     Pdword(ptr1+offset1)^:=tempfinal.GotPltTable[j-1];
     inc(offset1,4);
    end
   else if(ldbit=2) then
    begin
     Pqword(ptr1+offset1)^:=tempfinal.GotPltTable[j-1];
     inc(offset1,8);
    end;
   inc(j);
  end;
 label2:
 {Confirm the Entry Address of Program}
 tempfinal.EntryAddress:=tempfinal.SecAddress[ldfile.EntryIndex-1]+ldfile.EntryOffset;
 tempfinal.SecFlag:=ldfile.SecFlag;
 {Free the memory of the variable ldfile}
 while(i<=ldfile.SecCount)do
  begin
   tydq_freemem(ldfile.SecContent[i-1].SecContent);
   tydq_freemem(ldfile.SecContent[i-1].SecOffset);
   inc(i);
  end;
 {Now Send it to elf writer}
 writeindex:=0;
 if(FileExists(fn)) then DeleteFile(fn);
 if(ldbit=1) then
  begin
   for i:=1 to 16 do writer32.Header.elf_id[i]:=0;
   writer32.Header.elf_id[1]:=$7F;
   writer32.Header.elf_id[2]:=Byte('E');
   writer32.Header.elf_id[3]:=Byte('L');
   writer32.Header.elf_id[4]:=Byte('F');
   writer32.Header.elf_id[5]:=1;
   writer32.Header.elf_id[6]:=1;
   writer32.Header.elf_id[7]:=1;
   writer32.Header.elf_id[8]:=elf_os_abi_system_v;
   writer32.Header.elf_id[9]:=1;
   writer32.Header.elf_entry:=tempfinal.EntryAddress;
   writer32.Header.elf_machine:=ldarch;
   writer32.Header.elf_flags:=ldfile.SecFlag;
   writer32.Header.elf_header_size:=sizeof(elf32_header);
   writer32.Header.elf_version:=1;
   if(format>ld_format_static_library) then writer32.Header.elf_type:=elf_type_dynamic
   else writer32.Header.elf_type:=elf_type_relocatable;
   writestart:=0; writeend:=0; writenameoffset:=0;
   SetLength(writer32.SectionHeader,tempfinal.SecCount+1);
   SetLength(writer32.ProgramHeader,4+Byte(haverodata)+Byte(havetls)+Byte(dynamiclinker<>''));
   SetLength(writer32.Content,tempfinal.SecCount+1);
   {Create NULL Section Header}
   writer32.SectionHeader[0].section_header_name:=0;
   writer32.SectionHeader[0].section_header_address_align:=1;
   writer32.SectionHeader[0].section_header_address:=0;
   writer32.SectionHeader[0].section_header_entry_size:=0;
   writer32.SectionHeader[0].section_header_size:=0;
   writer32.SectionHeader[0].section_header_offset:=0;
   writer32.SectionHeader[0].section_header_flags:=0;
   writer32.SectionHeader[0].section_header_link:=0;
   writer32.SectionHeader[0].section_header_info:=0;
   writer32.SectionHeader[0].section_header_type:=0;
   {Generate NULL Program Header}
   writer32.ProgramHeader[0].program_align:=1;
   writer32.ProgramHeader[0].program_file_size:=0;
   writer32.ProgramHeader[0].program_memory_size:=0;
   writer32.ProgramHeader[0].program_offset:=0;
   writer32.ProgramHeader[0].program_physical_address:=0;
   writer32.ProgramHeader[0].program_virtual_address:=0;
   writer32.ProgramHeader[0].program_flags:=0;
   writer32.ProgramHeader[0].program_type:=elf_program_header_type_self;
   {Create other Section Header and Program Header}
   writenameoffset:=1;
   for j:=1 to tempfinal.SecCount do
    begin
     for i:=1 to tempfinal.SecCount do if(tempfinal.SecIndex[i-1]=j) then break;
     if(tempfinal.SecContent[i-1]<>nil) then
      begin
       writer32.Content[i]:=tempfinal.SecContent[i-1];
      end;
     writer32.SectionHeader[i].section_header_name:=writenameoffset;
     if(tempfinal.SecName[i-1]='.rela.dyn') then
     writer32.SectionHeader[i].section_header_entry_size:=sizeof(elf32_rela)
     else if(tempfinal.SecName[i-1]='.dynsym') or (tempfinal.SecName[i-1]='.symtab') then
     writer32.SectionHeader[i].section_header_entry_size:=sizeof(elf32_symbol_table_entry)
     else if(tempfinal.SecName[i-1]='.dynamic') then
     writer32.SectionHeader[i].section_header_entry_size:=sizeof(elf32_dynamic_entry)
     else if(tempfinal.SecName[i-1]='.got') or (tempfinal.SecName[i-1]='.got.plt')
     or(tempfinal.SecName[i-1]='.init_array') or (tempfinal.SecName[i-1]='.fini_array')
     or(tempfinal.SecName[i-1]='.preinit_array') then
     writer32.SectionHeader[i].section_header_entry_size:=8
     else
     writer32.SectionHeader[i].section_header_entry_size:=0;
     writer32.SectionHeader[i].section_header_size:=tempfinal.SecSize[i-1];
     writer32.SectionHeader[i].section_header_offset:=tempfinal.SecAddress[i-1];
     if(tempfinal.SecName[i-1]='.text') or (tempfinal.SecName[i-1]='.data')
     or(tempfinal.SecName[i-1]='.got') or (tempfinal.SecName[i-1]='.got.plt')
     or(tempfinal.SecName[i-1]='.debug_frame') or (tempfinal.SecName[i-1]='.rodata')
     or(tempfinal.SecName[i-1]='.init') or (tempfinal.SecName[i-1]='.fini')
     or(tempfinal.SecName[i-1]='.tdata') or (tempfinal.SecName[i-1]='.sign') then
     writer32.SectionHeader[i].section_header_type:=elf_section_type_progbit
     else if(tempfinal.SecName[i-1]='.init_array') then
     writer32.SectionHeader[i].section_header_type:=elf_section_type_init_array
     else if(tempfinal.SecName[i-1]='.fini_array') then
     writer32.SectionHeader[i].section_header_type:=elf_section_type_fini_array
     else if(tempfinal.SecName[i-1]='.preinit_array') then
     writer32.SectionHeader[i].section_header_type:=elf_section_type_preinit_array
     else if(tempfinal.SecName[i-1]='.bss') or (tempfinal.SecName[i-1]='.tbss') then
     writer32.SectionHeader[i].section_header_type:=elf_section_type_nobit
     else if(tempfinal.SecName[i-1]='.rela.dyn') or (tempfinal.SecName[i-1]='.rela') then
     writer32.SectionHeader[i].section_header_type:=elf_section_type_rela
     else if(tempfinal.SecName[i-1]='.hash') then
     writer32.SectionHeader[i].section_header_type:=elf_section_type_hash
     else if(tempfinal.SecName[i-1]='.dynsym') then
     writer32.SectionHeader[i].section_header_type:=elf_section_type_dynsym
     else if(tempfinal.SecName[i-1]='.dynstr') or (tempfinal.SecName[i-1]='.strtab')
     or(tempfinal.SecName[i-1]='.shstrtab') then
     writer32.SectionHeader[i].section_header_type:=elf_section_type_strtab
     else if(tempfinal.SecName[i-1]='.symtab') then
     writer32.SectionHeader[i].section_header_type:=elf_section_type_symtab
     else if(tempfinal.SecName[i-1]='.dynamic') then
     writer32.SectionHeader[i].section_header_type:=elf_section_type_dynamic;
     if(tempfinal.SecName[i-1]='.text') or (tempfinal.SecName[i-1]='.init')
     or(tempfinal.SecName[i-1]='.fini') then
     writer32.SectionHeader[i].section_header_flags:=
     elf_section_flag_alloc or elf_section_flag_executable
     else if(tempfinal.SecName[i-1]='.tdata') or (tempfinal.SecName[i-1]='.tbss') then
     writer32.SectionHeader[i].section_header_flags:=
     elf_section_flag_alloc or elf_section_flag_write or elf_section_flag_tls
     else if(tempfinal.SecName[i-1]='.data') or (tempfinal.SecName[i-1]='.dynamic')
     or(tempfinal.SecName[i-1]='.got') or (tempfinal.SecName[i-1]='.got.plt')
     or(tempfinal.SecName[i-1]='.bss') or (tempfinal.SecName[i-1]='.init_array')
     or(tempfinal.SecName[i-1]='.fini_array') or (tempfinal.SecName[i-1]='.preinit_array') then
     writer32.SectionHeader[i].section_header_flags:=
     elf_section_flag_alloc or elf_section_flag_write
     else if(tempfinal.SecName[i-1]<>'.symtab') and (tempfinal.SecName[i-1]<>'.strtab')
     and(tempfinal.SecName[i-1]<>'.shstrtab') then
     writer32.SectionHeader[i].section_header_flags:=elf_section_flag_alloc
     else
     writer32.SectionHeader[i].section_header_flags:=0;
     if(tempfinal.SecName[i-1]='.dynstr') or (tempfinal.SecName[i-1]='.strtab')
     or(tempfinal.SecName[i-1]='.shstrtab') or (tempfinal.SecName[i-1]='.sign') then
     writer32.SectionHeader[i].section_header_address_align:=1
     else
     writer32.SectionHeader[i].section_header_address_align:=8;
     if(writer32.SectionHeader[i].section_header_flags<>0) then
     writer32.SectionHeader[i].section_header_address:=tempfinal.SecAddress[i-1]
     else
     writer32.SectionHeader[i].section_header_address:=0;
     if(tempfinal.SecName[i-1]='.dynsym') then
     writer32.SectionHeader[i].section_header_link:=dynstrindex
     else if(tempfinal.SecName[i-1]='.symtab') then
     writer32.SectionHeader[i].section_header_link:=strtabindex
     else if(tempfinal.SecName[i-1]='.dynamic') then
     writer32.SectionHeader[i].section_header_link:=dynstrindex
     else if(tempfinal.SecName[i-1]='.hash') then
     writer32.SectionHeader[i].section_header_link:=dynsymindex
     else if(tempfinal.SecName[i-1]='.rela.dyn') then
     writer32.SectionHeader[i].section_header_link:=dynsymindex
     else if(tempfinal.SecName[i-1]='.rela') then
     writer32.SectionHeader[i].section_header_link:=symtabindex
     else
     writer32.SectionHeader[i].section_header_link:=0;
     if(tempfinal.SecName[i-1]='.dynsym') or (tempfinal.SecName[i-1]='.symtab') then
     writer32.SectionHeader[i].section_header_info:=1
     else if(tempfinal.SecName[i-1]='.rela.dyn') then
     writer32.SectionHeader[i].section_header_info:=textindex
     else
     writer32.SectionHeader[i].section_header_info:=0;
     inc(writenameoffset,length(tempfinal.SecName[i-1])+1);
     if(tempfinal.SecName[i-1]='.text') then
      begin
       writestart:=0; inc(writeindex);
       writeend:=tempfinal.SecAddress[i-1]+tempfinal.SecSize[i-1];
       writer32.ProgramHeader[writeindex].program_align:=align;
       writer32.ProgramHeader[writeindex].program_file_size:=writeend-writestart;
       writer32.ProgramHeader[writeindex].program_memory_size:=ld_align(writeend,align)-writestart;
       writer32.ProgramHeader[writeindex].program_offset:=0;
       writer32.ProgramHeader[writeindex].program_physical_address:=0;
       writer32.ProgramHeader[writeindex].program_virtual_address:=0;
       writer32.ProgramHeader[writeindex].program_flags:=elf_program_header_execute or elf_program_header_alloc;
       writer32.ProgramHeader[writeindex].program_type:=elf_program_header_type_load;
      end
     else if(tempfinal.SecName[i-1]='.interp') then
      begin
       inc(writeindex);
       writestart:=tempfinal.SecAddress[i-1];
       writeend:=tempfinal.SecAddress[i-1]+tempfinal.SecSize[i-1];
       writer32.ProgramHeader[writeindex].program_align:=align;
       writer32.ProgramHeader[writeindex].program_file_size:=writeend-writestart;
       writer32.ProgramHeader[writeindex].program_memory_size:=ld_align(writeend,align)-writestart;
       writer32.ProgramHeader[writeindex].program_offset:=writestart;
       writer32.ProgramHeader[writeindex].program_physical_address:=writestart;
       writer32.ProgramHeader[writeindex].program_virtual_address:=writestart;
       writer32.ProgramHeader[writeindex].program_flags:=elf_program_header_alloc;
       writer32.ProgramHeader[writeindex].program_type:=elf_program_header_type_interp;
      end
     else if(tempfinal.SecName[i-1]='.rodata') then
      begin
       inc(writeindex);
       writestart:=tempfinal.SecAddress[i-1];
       writeend:=tempfinal.SecAddress[i-1]+tempfinal.SecSize[i-1];
       writer32.ProgramHeader[writeindex].program_align:=align;
       writer32.ProgramHeader[writeindex].program_file_size:=writeend-writestart;
       writer32.ProgramHeader[writeindex].program_memory_size:=ld_align(writeend,align)-writestart;
       writer32.ProgramHeader[writeindex].program_offset:=writestart;
       writer32.ProgramHeader[writeindex].program_physical_address:=writestart;
       writer32.ProgramHeader[writeindex].program_virtual_address:=writestart;
       writer32.ProgramHeader[writeindex].program_flags:=elf_program_header_alloc;
       writer32.ProgramHeader[writeindex].program_type:=elf_program_header_type_load;
      end
     else if(tempfinal.SecName[i-1]='.data') then
      begin
       inc(writeindex);
       writestart:=tempfinal.SecAddress[i-1];
       k:=1;
       while(k<=tempfinal.SecCount)do
        begin
         for m:=1 to tempfinal.SecCount do if(tempfinal.SecIndex[k-1]=m) then break;
         if(tempfinal.SecName[m-1]='.strtab') or (tempfinal.SecName[m-1]='.shstrtab')
         or(tempfinal.SecName[m-1]='.tdata') then
          begin
           dec(k);
           for m:=1 to tempfinal.SecCount do if(tempfinal.SecIndex[k-1]=m) then break;
           break;
          end;
         inc(k);
        end;
       writeend:=tempfinal.SecAddress[k-1]+tempfinal.SecSize[k-1];
       writer32.ProgramHeader[writeindex].program_align:=align;
       writer32.ProgramHeader[writeindex].program_file_size:=writeend-writestart;
       writer32.ProgramHeader[writeindex].program_memory_size:=ld_align(writeend,align)-writestart;
       writer32.ProgramHeader[writeindex].program_offset:=writestart;
       writer32.ProgramHeader[writeindex].program_physical_address:=writestart;
       writer32.ProgramHeader[writeindex].program_virtual_address:=writestart;
       writer32.ProgramHeader[writeindex].program_flags:=elf_program_header_write or elf_program_header_alloc;
       writer32.ProgramHeader[writeindex].program_type:=elf_program_header_type_load;
      end
     else if(tempfinal.SecName[i-1]='.tdata') then
      begin
       inc(writeindex);
       writestart:=tempfinal.SecAddress[i-1];
       k:=1;
       while(k<=tempfinal.SecCount)do
        begin
         for m:=1 to tempfinal.SecCount do if(tempfinal.SecIndex[k-1]=m) then break;
         if(tempfinal.SecName[m-1]='.strtab') or (tempfinal.SecName[m-1]='.shstrtab') then
          begin
           dec(k);
           for m:=1 to tempfinal.SecCount do if(tempfinal.SecIndex[k-1]=m) then break;
           break;
          end;
         inc(k);
        end;
       writeend:=tempfinal.SecAddress[k-1]+tempfinal.SecSize[k-1];
       writer32.ProgramHeader[writeindex].program_align:=align;
       writer32.ProgramHeader[writeindex].program_file_size:=writeend-writestart;
       writer32.ProgramHeader[writeindex].program_memory_size:=ld_align(writeend,align)-writestart;
       writer32.ProgramHeader[writeindex].program_offset:=writestart;
       writer32.ProgramHeader[writeindex].program_physical_address:=writestart;
       writer32.ProgramHeader[writeindex].program_virtual_address:=writestart;
       writer32.ProgramHeader[writeindex].program_flags:=elf_program_header_write or elf_program_header_alloc;
       writer32.ProgramHeader[writeindex].program_type:=elf_program_header_type_tls;
      end
     else if(tempfinal.SecName[i-1]='.dynamic') then
      begin
       writestart:=tempfinal.SecAddress[i-1];
       writeend:=tempfinal.SecAddress[i-1]+tempfinal.SecSize[i-1];
       writeindex:=length(writer32.ProgramHeader)-1;
       writer32.ProgramHeader[writeindex].program_align:=align;
       writer32.ProgramHeader[writeindex].program_file_size:=writeend-writestart;
       writer32.ProgramHeader[writeindex].program_memory_size:=ld_align(writeend,align)-writestart;
       writer32.ProgramHeader[writeindex].program_offset:=writestart;
       writer32.ProgramHeader[writeindex].program_physical_address:=writestart;
       writer32.ProgramHeader[writeindex].program_virtual_address:=writestart;
       writer32.ProgramHeader[writeindex].program_flags:=elf_program_header_write or elf_program_header_alloc;
       writer32.ProgramHeader[writeindex].program_type:=elf_program_header_type_load;
       writer32.ProgramHeader[writeindex].program_type:=elf_program_header_type_dynamic;
      end;
    end;
   {Rehandle the elf file header}
   writer32.Header.elf_entry:=tempfinal.EntryAddress;
   writer32.Header.elf_section_header_string_table_index:=Length(writer32.SectionHeader)-1;
   writer32.Header.elf_section_header_number:=Length(writer32.SectionHeader);
   writer32.Header.elf_section_header_size:=sizeof(elf32_section_header);
   for i:=1 to tempfinal.SecCount do
    begin
     if(tempfinal.SecName[i-1]='.shstrtab') then break;
    end;
   writer32.Header.elf_section_header_offset:=tempfinal.SecAddress[i-1]+tempfinal.SecSize[i-1];
   writer32.Header.elf_program_header_number:=Length(writer32.ProgramHeader);
   writer32.Header.elf_program_header_size:=sizeof(elf32_program_header);
   writer32.Header.elf_program_header_offset:=sizeof(elf32_header);
   {Create the memory of elf}
   elfbinary:=tydq_getmem(writer32.Header.elf_section_header_offset+
   writer32.Header.elf_section_header_number*writer32.Header.elf_section_header_size);
   writeoffset:=0;
   tydq_move(writer32.Header,(elfbinary+writeoffset)^,sizeof(elf32_header));
   inc(writeoffset,sizeof(elf32_header));
   i:=1;
   while(i<=writer32.Header.elf_program_header_number)do
    begin
     tydq_move(writer32.ProgramHeader[i-1],(elfbinary+writeoffset)^,sizeof(elf32_program_header));
     inc(writeoffset,sizeof(elf32_program_header));
     inc(i);
    end;
   i:=1;
   while(i<=writer32.Header.elf_section_header_number)do
    begin
     if(writer32.Content[i-1]<>nil) then
      begin
       writeoffset:=writer32.SectionHeader[i-1].section_header_offset;
       tydq_move(writer32.Content[i-1]^,(elfbinary+writeoffset)^,
       writer32.SectionHeader[i-1].section_header_size);
      end;
     inc(i);
    end;
   i:=1; writeoffset:=writer32.Header.elf_section_header_offset;
   tydq_move(writer32.SectionHeader[0],(elfbinary+writeoffset)^,sizeof(elf32_section_header));
   inc(writeoffset,sizeof(elf32_section_header));
   while(i<=writer32.Header.elf_section_header_number-1)do
    begin
     for j:=1 to tempfinal.SecCount do if(tempfinal.SecIndex[j-1]=i) then break;
     tydq_move(writer32.SectionHeader[j],(elfbinary+writeoffset)^,sizeof(elf32_section_header));
     inc(writeoffset,sizeof(elf32_section_header));
     inc(i);
    end;
   ld_io_write(fn,1,elfbinary^,writer32.Header.elf_section_header_offset+
   writer32.Header.elf_section_header_number*writer32.Header.elf_section_header_size);
  end
 else if(ldbit=2) then
  begin
   for i:=1 to 16 do writer64.Header.elf_id[i]:=0;
   writer64.Header.elf_id[1]:=$7F;
   writer64.Header.elf_id[2]:=Byte('E');
   writer64.Header.elf_id[3]:=Byte('L');
   writer64.Header.elf_id[4]:=Byte('F');
   writer64.Header.elf_id[5]:=2;
   writer64.Header.elf_id[6]:=1;
   writer64.Header.elf_id[7]:=1;
   writer64.Header.elf_id[8]:=elf_os_abi_system_v;
   writer64.Header.elf_id[9]:=1;
   writer64.Header.elf_entry:=tempfinal.EntryAddress;
   writer64.Header.elf_machine:=ldarch;
   writer64.Header.elf_flags:=ldfile.SecFlag;
   writer64.Header.elf_header_size:=sizeof(elf64_header);
   writer64.Header.elf_version:=1;
   if(format>ld_format_static_library) then writer64.Header.elf_type:=elf_type_dynamic
   else writer64.Header.elf_type:=elf_type_relocatable;
   writestart:=0; writeend:=0; writenameoffset:=0;
   SetLength(writer64.SectionHeader,tempfinal.SecCount+1);
   SetLength(writer64.ProgramHeader,4+Byte(haverodata)+Byte(havetls)+Byte(dynamiclinker<>''));
   SetLength(writer64.Content,tempfinal.SecCount+1);
   {Create NULL Section Header}
   writer64.SectionHeader[0].section_header_name:=0;
   writer64.SectionHeader[0].section_header_address_align:=1;
   writer64.SectionHeader[0].section_header_address:=0;
   writer64.SectionHeader[0].section_header_entry_size:=0;
   writer64.SectionHeader[0].section_header_size:=0;
   writer64.SectionHeader[0].section_header_offset:=0;
   writer64.SectionHeader[0].section_header_flags:=0;
   writer64.SectionHeader[0].section_header_link:=0;
   writer64.SectionHeader[0].section_header_info:=0;
   writer64.SectionHeader[0].section_header_type:=0;
   {Generate NULL Program Header}
   writer64.ProgramHeader[0].program_align:=1;
   writer64.ProgramHeader[0].program_file_size:=0;
   writer64.ProgramHeader[0].program_memory_size:=0;
   writer64.ProgramHeader[0].program_offset:=0;
   writer64.ProgramHeader[0].program_physical_address:=0;
   writer64.ProgramHeader[0].program_virtual_address:=0;
   writer64.ProgramHeader[0].program_flags:=0;
   writer64.ProgramHeader[0].program_type:=elf_program_header_type_self;
   {Create other Section Header and Program Header}
   writenameoffset:=1;
   for j:=1 to tempfinal.SecCount do
    begin
     for i:=1 to tempfinal.SecCount do if(tempfinal.SecIndex[i-1]=j) then break;
     if(tempfinal.SecContent[i-1]<>nil) then
      begin
       writer64.Content[i]:=tempfinal.SecContent[i-1];
      end;
     writer64.SectionHeader[i].section_header_name:=writenameoffset;
     if(tempfinal.SecName[i-1]='.rela.dyn') then
     writer64.SectionHeader[i].section_header_entry_size:=sizeof(elf64_rela)
     else if(tempfinal.SecName[i-1]='.dynsym') or (tempfinal.SecName[i-1]='.symtab') then
     writer64.SectionHeader[i].section_header_entry_size:=sizeof(elf64_symbol_table_entry)
     else if(tempfinal.SecName[i-1]='.dynamic') then
     writer64.SectionHeader[i].section_header_entry_size:=sizeof(elf64_dynamic_entry)
     else if(tempfinal.SecName[i-1]='.got') or (tempfinal.SecName[i-1]='.got.plt')
     or(tempfinal.SecName[i-1]='.init_array') or (tempfinal.SecName[i-1]='.fini_array')
     or(tempfinal.SecName[i-1]='.preinit_array') then
     writer64.SectionHeader[i].section_header_entry_size:=8
     else
     writer64.SectionHeader[i].section_header_entry_size:=0;
     writer64.SectionHeader[i].section_header_size:=tempfinal.SecSize[i-1];
     writer64.SectionHeader[i].section_header_offset:=tempfinal.SecAddress[i-1];
     if(tempfinal.SecName[i-1]='.text') or (tempfinal.SecName[i-1]='.data')
     or(tempfinal.SecName[i-1]='.got') or (tempfinal.SecName[i-1]='.got.plt')
     or(tempfinal.SecName[i-1]='.debug_frame') or (tempfinal.SecName[i-1]='.rodata')
     or(tempfinal.SecName[i-1]='.init') or (tempfinal.SecName[i-1]='.fini')
     or(tempfinal.SecName[i-1]='.tdata') or (tempfinal.SecName[i-1]='.sign') then
     writer64.SectionHeader[i].section_header_type:=elf_section_type_progbit
     else if(tempfinal.SecName[i-1]='.init_array') then
     writer64.SectionHeader[i].section_header_type:=elf_section_type_init_array
     else if(tempfinal.SecName[i-1]='.fini_array') then
     writer64.SectionHeader[i].section_header_type:=elf_section_type_fini_array
     else if(tempfinal.SecName[i-1]='.preinit_array') then
     writer64.SectionHeader[i].section_header_type:=elf_section_type_preinit_array
     else if(tempfinal.SecName[i-1]='.bss') or (tempfinal.SecName[i-1]='.tbss') then
     writer64.SectionHeader[i].section_header_type:=elf_section_type_nobit
     else if(tempfinal.SecName[i-1]='.rela.dyn') or (tempfinal.SecName[i-1]='.rela') then
     writer64.SectionHeader[i].section_header_type:=elf_section_type_rela
     else if(tempfinal.SecName[i-1]='.hash') then
     writer64.SectionHeader[i].section_header_type:=elf_section_type_hash
     else if(tempfinal.SecName[i-1]='.dynsym') then
     writer64.SectionHeader[i].section_header_type:=elf_section_type_dynsym
     else if(tempfinal.SecName[i-1]='.dynstr') or (tempfinal.SecName[i-1]='.strtab')
     or(tempfinal.SecName[i-1]='.shstrtab') then
     writer64.SectionHeader[i].section_header_type:=elf_section_type_strtab
     else if(tempfinal.SecName[i-1]='.symtab') then
     writer64.SectionHeader[i].section_header_type:=elf_section_type_symtab
     else if(tempfinal.SecName[i-1]='.dynamic') then
     writer64.SectionHeader[i].section_header_type:=elf_section_type_dynamic;
     if(tempfinal.SecName[i-1]='.text') or (tempfinal.SecName[i-1]='.init')
     or(tempfinal.SecName[i-1]='.fini') then
     writer64.SectionHeader[i].section_header_flags:=
     elf_section_flag_alloc or elf_section_flag_executable
     else if(tempfinal.SecName[i-1]='.tdata') or (tempfinal.SecName[i-1]='.tbss') then
     writer64.SectionHeader[i].section_header_flags:=
     elf_section_flag_alloc or elf_section_flag_write or elf_section_flag_tls
     else if(tempfinal.SecName[i-1]='.data') or (tempfinal.SecName[i-1]='.dynamic')
     or(tempfinal.SecName[i-1]='.got') or (tempfinal.SecName[i-1]='.got.plt')
     or(tempfinal.SecName[i-1]='.bss') or (tempfinal.SecName[i-1]='.init_array')
     or(tempfinal.SecName[i-1]='.fini_array') or (tempfinal.SecName[i-1]='.preinit_array') then
     writer64.SectionHeader[i].section_header_flags:=
     elf_section_flag_alloc or elf_section_flag_write
     else if(tempfinal.SecName[i-1]<>'.symtab') and (tempfinal.SecName[i-1]<>'.strtab')
     and(tempfinal.SecName[i-1]<>'.shstrtab') then
     writer64.SectionHeader[i].section_header_flags:=elf_section_flag_alloc
     else
     writer64.SectionHeader[i].section_header_flags:=0;
     if(tempfinal.SecName[i-1]='.dynstr') or (tempfinal.SecName[i-1]='.strtab')
     or(tempfinal.SecName[i-1]='.shstrtab') or (tempfinal.SecName[i-1]='.sign') then
     writer64.SectionHeader[i].section_header_address_align:=1
     else
     writer64.SectionHeader[i].section_header_address_align:=8;
     if(writer64.SectionHeader[i].section_header_flags<>0) then
     writer64.SectionHeader[i].section_header_address:=tempfinal.SecAddress[i-1]
     else
     writer64.SectionHeader[i].section_header_address:=0;
     if(tempfinal.SecName[i-1]='.dynsym') then
     writer64.SectionHeader[i].section_header_link:=dynstrindex
     else if(tempfinal.SecName[i-1]='.symtab') then
     writer64.SectionHeader[i].section_header_link:=strtabindex
     else if(tempfinal.SecName[i-1]='.dynamic') then
     writer64.SectionHeader[i].section_header_link:=dynstrindex
     else if(tempfinal.SecName[i-1]='.hash') then
     writer64.SectionHeader[i].section_header_link:=dynsymindex
     else if(tempfinal.SecName[i-1]='.rela.dyn') then
     writer64.SectionHeader[i].section_header_link:=dynsymindex
     else if(tempfinal.SecName[i-1]='.rela') then
     writer64.SectionHeader[i].section_header_link:=symtabindex
     else
     writer64.SectionHeader[i].section_header_link:=0;
     if(tempfinal.SecName[i-1]='.dynsym') or (tempfinal.SecName[i-1]='.symtab') then
     writer64.SectionHeader[i].section_header_info:=1
     else if(tempfinal.SecName[i-1]='.rela.dyn') then
     writer64.SectionHeader[i].section_header_info:=textindex
     else
     writer64.SectionHeader[i].section_header_info:=0;
     inc(writenameoffset,length(tempfinal.SecName[i-1])+1);
     if(tempfinal.SecName[i-1]='.text') then
      begin
       writestart:=0; inc(writeindex);
       writeend:=tempfinal.SecAddress[i-1]+tempfinal.SecSize[i-1];
       writer64.ProgramHeader[writeindex].program_align:=align;
       writer64.ProgramHeader[writeindex].program_file_size:=writeend-writestart;
       writer64.ProgramHeader[writeindex].program_memory_size:=ld_align(writeend,align)-writestart;
       writer64.ProgramHeader[writeindex].program_offset:=0;
       writer64.ProgramHeader[writeindex].program_physical_address:=0;
       writer64.ProgramHeader[writeindex].program_virtual_address:=0;
       writer64.ProgramHeader[writeindex].program_flags:=elf_program_header_execute or elf_program_header_alloc;
       writer64.ProgramHeader[writeindex].program_type:=elf_program_header_type_load;
      end
     else if(tempfinal.SecName[i-1]='.interp') then
      begin
       inc(writeindex);
       writestart:=tempfinal.SecAddress[i-1];
       writeend:=tempfinal.SecAddress[i-1]+tempfinal.SecSize[i-1];
       writer64.ProgramHeader[writeindex].program_align:=align;
       writer64.ProgramHeader[writeindex].program_file_size:=writeend-writestart;
       writer64.ProgramHeader[writeindex].program_memory_size:=ld_align(writeend,align)-writestart;
       writer64.ProgramHeader[writeindex].program_offset:=writestart;
       writer64.ProgramHeader[writeindex].program_physical_address:=writestart;
       writer64.ProgramHeader[writeindex].program_virtual_address:=writestart;
       writer64.ProgramHeader[writeindex].program_flags:=elf_program_header_alloc;
       writer64.ProgramHeader[writeindex].program_type:=elf_program_header_type_interp;
      end
     else if(tempfinal.SecName[i-1]='.rodata') then
      begin
       inc(writeindex);
       writestart:=tempfinal.SecAddress[i-1];
       writeend:=tempfinal.SecAddress[i-1]+tempfinal.SecSize[i-1];
       writer64.ProgramHeader[writeindex].program_align:=align;
       writer64.ProgramHeader[writeindex].program_file_size:=writeend-writestart;
       writer64.ProgramHeader[writeindex].program_memory_size:=ld_align(writeend,align)-writestart;
       writer64.ProgramHeader[writeindex].program_offset:=writestart;
       writer64.ProgramHeader[writeindex].program_physical_address:=writestart;
       writer64.ProgramHeader[writeindex].program_virtual_address:=writestart;
       writer64.ProgramHeader[writeindex].program_flags:=elf_program_header_alloc;
       writer64.ProgramHeader[writeindex].program_type:=elf_program_header_type_load;
      end
     else if(tempfinal.SecName[i-1]='.data') then
      begin
       inc(writeindex);
       writestart:=tempfinal.SecAddress[i-1];
       k:=1;
       while(k<=tempfinal.SecCount)do
        begin
         for m:=1 to tempfinal.SecCount do if(tempfinal.SecIndex[k-1]=m) then break;
         if(tempfinal.SecName[m-1]='.strtab') or (tempfinal.SecName[m-1]='.shstrtab')
         or(tempfinal.SecName[m-1]='.tdata') then
          begin
           dec(k);
           for m:=1 to tempfinal.SecCount do if(tempfinal.SecIndex[k-1]=m) then break;
           break;
          end;
         inc(k);
        end;
       writeend:=tempfinal.SecAddress[k-1]+tempfinal.SecSize[k-1];
       writer64.ProgramHeader[writeindex].program_align:=align;
       writer64.ProgramHeader[writeindex].program_file_size:=writeend-writestart;
       writer64.ProgramHeader[writeindex].program_memory_size:=ld_align(writeend,align)-writestart;
       writer64.ProgramHeader[writeindex].program_offset:=writestart;
       writer64.ProgramHeader[writeindex].program_physical_address:=writestart;
       writer64.ProgramHeader[writeindex].program_virtual_address:=writestart;
       writer64.ProgramHeader[writeindex].program_flags:=elf_program_header_write or elf_program_header_alloc;
       writer64.ProgramHeader[writeindex].program_type:=elf_program_header_type_load;
      end
     else if(tempfinal.SecName[i-1]='.tdata') then
      begin
       inc(writeindex);
       writestart:=tempfinal.SecAddress[i-1];
       k:=1;
       while(k<=tempfinal.SecCount)do
        begin
         for m:=1 to tempfinal.SecCount do if(tempfinal.SecIndex[k-1]=m) then break;
         if(tempfinal.SecName[m-1]='.strtab') or (tempfinal.SecName[m-1]='.shstrtab') then
          begin
           dec(k);
           for m:=1 to tempfinal.SecCount do if(tempfinal.SecIndex[k-1]=m) then break;
           break;
          end;
         inc(k);
        end;
       writeend:=tempfinal.SecAddress[k-1]+tempfinal.SecSize[k-1];
       writer64.ProgramHeader[writeindex].program_align:=align;
       writer64.ProgramHeader[writeindex].program_file_size:=writeend-writestart;
       writer64.ProgramHeader[writeindex].program_memory_size:=ld_align(writeend,align)-writestart;
       writer64.ProgramHeader[writeindex].program_offset:=writestart;
       writer64.ProgramHeader[writeindex].program_physical_address:=writestart;
       writer64.ProgramHeader[writeindex].program_virtual_address:=writestart;
       writer64.ProgramHeader[writeindex].program_flags:=elf_program_header_write or elf_program_header_alloc;
       writer64.ProgramHeader[writeindex].program_type:=elf_program_header_type_tls;
      end
     else if(tempfinal.SecName[i-1]='.dynamic') then
      begin
       writestart:=tempfinal.SecAddress[i-1];
       writeend:=tempfinal.SecAddress[i-1]+tempfinal.SecSize[i-1];
       writeindex:=length(writer64.ProgramHeader)-1;
       writer64.ProgramHeader[writeindex].program_align:=align;
       writer64.ProgramHeader[writeindex].program_file_size:=writeend-writestart;
       writer64.ProgramHeader[writeindex].program_memory_size:=writeend-writestart;
       writer64.ProgramHeader[writeindex].program_offset:=writestart;
       writer64.ProgramHeader[writeindex].program_physical_address:=writestart;
       writer64.ProgramHeader[writeindex].program_virtual_address:=writestart;
       writer64.ProgramHeader[writeindex].program_flags:=elf_program_header_write or elf_program_header_alloc;
       writer64.ProgramHeader[writeindex].program_type:=elf_program_header_type_load;
       writer64.ProgramHeader[writeindex].program_type:=elf_program_header_type_dynamic;
      end;
    end;
   {Rehandle the elf file header}
   writer64.Header.elf_entry:=tempfinal.EntryAddress;
   writer64.Header.elf_section_header_string_table_index:=Length(writer64.SectionHeader)-1;
   writer64.Header.elf_section_header_number:=Length(writer64.SectionHeader);
   writer64.Header.elf_section_header_size:=sizeof(elf64_section_header);
   for i:=1 to tempfinal.SecCount do
    begin
     if(tempfinal.SecName[i-1]='.shstrtab') then break;
    end;
   writer64.Header.elf_section_header_offset:=tempfinal.SecAddress[i-1]+tempfinal.SecSize[i-1];
   writer64.Header.elf_program_header_number:=Length(writer64.ProgramHeader);
   writer64.Header.elf_program_header_size:=sizeof(elf64_program_header);
   writer64.Header.elf_program_header_offset:=sizeof(elf64_header);
   {Create the memory of elf}
   elfbinary:=tydq_getmem(writer64.Header.elf_section_header_offset+
   writer64.Header.elf_section_header_number*writer64.Header.elf_section_header_size);
   writeoffset:=0;
   tydq_move(writer64.Header,(elfbinary+writeoffset)^,sizeof(elf64_header));
   inc(writeoffset,sizeof(elf64_header));
   i:=1;
   while(i<=writer64.Header.elf_program_header_number)do
    begin
     tydq_move(writer64.ProgramHeader[i-1],(elfbinary+writeoffset)^,sizeof(elf64_program_header));
     inc(writeoffset,sizeof(elf64_program_header));
     inc(i);
    end;
   i:=1;
   while(i<=writer64.Header.elf_section_header_number)do
    begin
     if(writer64.Content[i-1]<>nil) then
      begin
       writeoffset:=writer64.SectionHeader[i-1].section_header_offset;
       tydq_move(writer64.Content[i-1]^,(elfbinary+writeoffset)^,
       writer64.SectionHeader[i-1].section_header_size);
      end;
     inc(i);
    end;
   i:=1; writeoffset:=writer64.Header.elf_section_header_offset;
   tydq_move(writer64.SectionHeader[0],(elfbinary+writeoffset)^,sizeof(elf64_section_header));
   inc(writeoffset,sizeof(elf64_section_header));
   while(i<=writer64.Header.elf_section_header_number-1)do
    begin
     for j:=1 to tempfinal.SecCount do if(tempfinal.SecIndex[j-1]=i) then break;
     tydq_move(writer64.SectionHeader[j],(elfbinary+writeoffset)^,sizeof(elf64_section_header));
     inc(writeoffset,sizeof(elf64_section_header));
     inc(i);
    end;
   ld_io_write(fn,1,elfbinary^,writer64.Header.elf_section_header_offset+
   writer64.Header.elf_section_header_number*writer64.Header.elf_section_header_size);
  end;
end;
procedure ld_initialize_pe_writer(var writer:ld_pe_writer);
var i:Natuint;
    ptr:Pqword;
begin
 ptr:=@writer;
 for i:=1 to (sizeof(pe_dos_header)+64+sizeof(pe_image_header)) div 8 do
  begin
   ptr^:=0; inc(ptr);
  end;
end;
procedure ld_handle_elf_file_to_efi_file(fn:string;var ldfile:ld_object_file_stage_2;align:dword;
debugframe:boolean;format:byte;stripsymbol:boolean);
var tempfinal:ld_object_file_final;
    i,j,k,m,n:Natuint;
    tempformula:ld_formula;
    writeindex:word;
    writepos:array[1..1] of Natuint;
    order:array of string;
    startoffset,endoffset:Natuint;
    changeptr:Pointer;
    tempresult:NatInt;
    index:Natuint;
    haverodata:boolean;
    {Set the Adjustment Hash}
    Adjnum:Natuint;
    {Set for Relocation}
    isrelative:boolean;
    isgotbase:boolean;
    isgotoffset:boolean;
    ispaged:boolean;
    {Set the EFI writer}
    writeoffset:Natuint;
    checksumoffset:Natuint;
    textoffset,rodataoffset,dataoffset,relocoffset:Natuint;
    pebinary:Pbyte;
    pesize:dword;
    baserelativeaddress:Natuint;
    baseaddresssize:Natuint;
    symboltableAddr:Natuint;
    symboltable:array of coff_symbol_table_item;
    symbolstringtable:PChar;
    symbolstringtableptr:Natuint;
    symbolandstringtablesize:Natuint;
    writer:ld_pe_writer;
    {For non-x64 architecture}
    tempnum1,tempnum2,tempnum3,tempnum4:Natint;
    tempnum5:Dword;
    gotindex:word;
    movesecoffset,movesecoffset2:Natint;
    tempresult2:Natint;
    tempindex,tempindex2,tempindex3,tempindex4:Word;
    offset1:Natuint;
    {Set the fixed length instruction data}
    d1,d2,d3,d4,d5,d6,d7,d8,d9,d10:dword;
    q1,q2:qword;
    negative:boolean;
label label1;
begin
 tempfinal.SecCount:=0;
 SetLength(ldfile.Adjust.AdjustUsed,ldfile.Adjust.Count);
 {Now Generate the entire vaild section}
 haverodata:=false;
 SetLength(tempfinal.SecName,10);
 SetLength(tempfinal.SecIndex,10);
 SetLength(tempfinal.SecAddress,10);
 SetLength(tempfinal.SecSize,10);
 SetLength(tempfinal.SecContent,10);
 for i:=1 to ldfile.SecCount do
  begin
   if(ldfile.SecName[i-1]='.debug_frame') and (debugframe=false) then continue;
   if(ldfile.SecSize[i-1]=0) then continue;
   inc(tempfinal.SecCount);
   if(ldfile.SecName[i-1]='.text') then
   tempfinal.SecName[tempfinal.SecCount-1]:='.text'
   else if(ldfile.SecName[i-1]='.rodata') then
    begin
     tempfinal.SecName[tempfinal.SecCount-1]:='.rodata'; haverodata:=true;
    end
   else if(ldfile.SecName[i-1]='.data') then
   tempfinal.SecName[tempfinal.SecCount-1]:='.data'
   else if(ldfile.SecName[i-1]='.bss') then
   tempfinal.SecName[tempfinal.SecCount-1]:='.bss'
   else if(ldfile.SecName[i-1]='.init') then
    begin
     tempfinal.SecName[tempfinal.SecCount-1]:='.init';
    end
   else if(ldfile.SecName[i-1]='.init_array') then
    begin
     tempfinal.SecName[tempfinal.SecCount-1]:='.init_array';
    end
   else if(ldfile.SecName[i-1]='.fini') then
    begin
     tempfinal.SecName[tempfinal.SecCount-1]:='.fini';
    end
   else if(ldfile.SecName[i-1]='.fini_array') then
    begin
     tempfinal.SecName[tempfinal.SecCount-1]:='.fini_array';
    end
   else if(ldfile.SecName[i-1]='.preinit_array') then
    begin
     tempfinal.SecName[tempfinal.SecCount-1]:='.preinit_array';
    end
   else if(ldfile.SecName[i-1]='.debug_frame') then
   tempfinal.SecName[tempfinal.SecCount-1]:='.debug_frame';
   tempfinal.SecAddress[tempfinal.SecCount-1]:=0;
   tempfinal.SecIndex[tempfinal.SecCount-1]:=0;
   if(ldfile.SecName[i-1]<>'.bss') and (ldfile.SecName[i-1]<>'.tbss') and (ldfile.SecSize[i-1]>0) then
    begin
     tempfinal.SecSize[tempfinal.SecCount-1]:=ldfile.SecSize[i-1];
     tempfinal.SecContent[tempfinal.SecCount-1]:=ldfile.SecContent[i-1].SecContent;
    end
   else if(ldfile.SecSize[i-1]>0) then
    begin
     tempfinal.SecSize[tempfinal.SecCount-1]:=ldfile.SecSize[i-1];
     tempfinal.SecContent[tempfinal.SecCount-1]:=nil;
    end
   else
    begin
     dec(tempfinal.SecCount);
    end;
  end;
 {Check the got and got.plt section can be generated}
 SetLength(tempfinal.GotTable,0); SetLength(tempfinal.GotSymbol,ldGotCount);
 tempfinal.DynSym.SymbolCount:=0; tempfinal.Rela.SymCount:=0;
 {Confirm the Adjust Table for Relative}
 for i:=1 to ldfile.Adjust.Count do
  begin
   j:=1;
   isrelative:=ldfile.Adjust.Formula[i-1].isrelative;
   isgotbase:=ldfile.Adjust.Formula[i-1].isgotbase;
   isgotoffset:=ldfile.Adjust.Formula[i-1].isgotoffset;
   ispaged:=ldfile.Adjust.Formula[i-1].ispaged;
   if(isrelative) and ((ldarch=elf_machine_386) or (ldarch=elf_machine_x86_64)) then
    begin
     ldfile.Adjust.Formula[i-1]:=ld_generate_formula(['S+A-P'],ldfile.Adjust.Formula[i-1].bit,
     ldfile.Adjust.Formula[i-1].mask);
    end
   else if(isrelative) and (ldfile.Adjust.DestIndex[i-1]=0)
   and ((ldarch=elf_machine_386) or (ldarch=elf_machine_x86_64)) then
    begin
     writeln('ERROR:Cannot generate the UEFI File due to Symbol '+ldfile.Adjust.AdjustName[i-1]+
     ' undefined.');
     readln;
     abort;
    end
   else if(isrelative) and (isgotbase=false) and (isgotoffset=false) then
    begin
     if(ispaged) and (ldarch<>elf_machine_loongarch) then
      begin
       ldfile.Adjust.Formula[i-1]:=ld_generate_formula(['Page(S+A)-Page(P)'],ldfile.Adjust.Formula[i-1].bit,
       ldfile.Adjust.Formula[i-1].mask);
      end
     else if(ispaged) then
      begin
       ldfile.Adjust.Formula[i-1]:=ld_generate_formula(['Page(S+A)-Page(PC)'],ldfile.Adjust.Formula[i-1].bit,
       ldfile.Adjust.Formula[i-1].mask);
      end
     else if(ldarch<>elf_machine_loongarch) then
      begin
       ldfile.Adjust.Formula[i-1]:=ld_generate_formula(['S+A-P'],ldfile.Adjust.Formula[i-1].bit,
       ldfile.Adjust.Formula[i-1].mask);
      end
     else
      begin
       ldfile.Adjust.Formula[i-1]:=ld_generate_formula(['S+A-PC'],ldfile.Adjust.Formula[i-1].bit,
       ldfile.Adjust.Formula[i-1].mask);
      end;
    end
   else if(ldarch=elf_machine_riscv) and
   ((ldfile.Adjust.AdjustType[i-1]=elf_reloc_riscv_low_12bit_signed) or
    (ldfile.Adjust.AdjustType[i-1]=elf_reloc_riscv_low_12bit) or
    (ldfile.Adjust.AdjustType[i-1]=elf_reloc_riscv_high_20bit)) then
    begin
     Adjnum:=ld_adjust_search_for_index(ldfile.AdjustHashTable,
     DynNatuintArray(ldfile.Adjust.AdjustHash),ldfile.Adjust.AdjustHash[i-1],
     tempfinal.GotCount+1,ld_adjust_got);
     if(Adjnum=0) then continue;
     inc(tempfinal.GotCount);
     tempfinal.GotSymbol[tempfinal.GotCount-1]:=ldfile.Adjust.AdjustHash[i-1];
     inc(tempfinal.Rela.SymCount);
    end
   else if((isgotbase) or (isgotoffset)) and (ldfile.Adjust.DestIndex[i-1]<>0) then
    begin
     Adjnum:=ld_adjust_search_for_index(ldfile.AdjustHashTable,
     DynNatuintArray(ldfile.Adjust.AdjustHash),ldfile.Adjust.AdjustHash[i-1],
     tempfinal.GotCount+1,ld_adjust_got);
     if(Adjnum=0) then continue;
     inc(tempfinal.GotCount);
     tempfinal.GotSymbol[tempfinal.GotCount-1]:=ldfile.Adjust.AdjustHash[i-1];
     inc(tempfinal.Rela.SymCount);
    end
   else if((isgotbase) or (isgotoffset)) and (ldfile.Adjust.DestIndex[i-1]=0) then
    begin
     writeln('ERROR:Cannot generate the UEFI File due to the Symbol '+ldfile.Adjust.AdjustName[i-1]+
     ' undefined.');
     readln;
     abort;
    end
   else if(ldarch=elf_machine_386) or (ldarch=elf_machine_x86_64) then
    begin
     inc(tempfinal.Rela.SymCount);
    end;
  end;
 {Set the Got Table and Got Plt Table}
 if(tempfinal.GotCount>0) then SetLength(tempfinal.GotTable,3+tempfinal.GotCount);
 {Now Generate the Relocation Necessary Value}
 if(Length(tempfinal.GotTable)>0) then
  begin
   inc(tempfinal.SecCount);
   tempfinal.SecName[tempfinal.Seccount-1]:='.got';
   tempfinal.SecContent[tempfinal.Seccount-1]:=tydq_getmem(Length(tempfinal.GotTable)*ldbit shl 2);
   tempfinal.SecIndex[tempfinal.Seccount-1]:=0;
   tempfinal.SecAddress[tempfinal.Seccount-1]:=0;
   tempfinal.SecSize[tempfinal.Seccount-1]:=Length(tempfinal.GotTable)*ldbit shl 2;
  end;
 {Now allocate the order of the section}
 order:=['.text','.init','.fini','.rodata','.data',
 '.init_array','.fini_array','.preinit_array','.got','.got.plt',
 '.bss','.debug_frame']; rodataoffset:=0;
 if(ldbit=1) then
 startoffset:=sizeof(pe_dos_header)+64+4+
 sizeof(coff_image_header)+sizeof(coff_optional_image_header32)+6*sizeof(pe_data_directory)+
 (3+Byte(haverodata))*sizeof(pe_image_section_header)
 else if(ldbit=2) then
 startoffset:=sizeof(pe_dos_header)+64+4+
 sizeof(coff_image_header)+sizeof(coff_optional_image_header64)+6*sizeof(pe_data_directory)+
 (3+Byte(haverodata))*sizeof(pe_image_section_header);
 i:=1; writeindex:=0; gotindex:=1;
 for i:=1 to length(order) do
  begin
   j:=1;
   while(j<=tempfinal.SecCount)do
    begin
     if(tempfinal.SecName[j-1]=order[i-1]) then break;
     inc(j);
    end;
   if(j>tempfinal.SecCount) then continue;
   inc(writeindex);
   if(Order[i-1]='.text') or (Order[i-1]='.rodata') or (Order[i-1]='.data') then
   startoffset:=ld_align(startoffset,align)
   else
   startoffset:=ld_align(startoffset,ldbit shl 2);
   tempfinal.SecAddress[j-1]:=startoffset;
   tempfinal.SecIndex[j-1]:=writeindex;
   if(Order[i-1]='.got') then
    begin
     tempfinal.SecAddress[GotIndex-1]:=startoffset; gotindex:=j;
    end;
   if(Order[i-1]='.text') then textoffset:=startoffset
   else if(Order[i-1]='.rodata') then rodataoffset:=startoffset
   else if(Order[i-1]='.data') then dataoffset:=startoffset;
   inc(startoffset,tempfinal.SecSize[j-1]);
  end;
 relocoffset:=ld_align(startoffset,align);
 {For AArch64 Architecture Only}
 movesecoffset:=0; movesecoffset2:=0;
 if(ldarch=elf_machine_aarch64) then
  begin
   for i:=1 to ldfile.Adjust.Count do
    begin
     index:=ldfile.Adjust.SrcIndex[i-1];
     if(ldfile.SecName[index-1]='.debug_frame') and (debugframe=false) then continue;
     j:=1;
     while(j<=tempfinal.SecCount)do
      begin
       if(ldfile.SecName[index-1]=tempfinal.SecName[j-1]) then break;
       inc(j);
      end;
     if(j>tempfinal.SecCount) then continue;
     startoffset:=tempfinal.SecAddress[j-1]+ldfile.Adjust.SrcOffset[i-1];
     changeptr:=tempfinal.SecContent[j-1]+ldfile.Adjust.Srcoffset[i-1];
     tempindex:=j;
     index:=ldfile.Adjust.DestIndex[i-1];
     if(index>0) then
      begin
       if(ldfile.SecName[index-1]='.debug_frame') and (debugframe=false) then continue;
       j:=1;
       while(j<=tempfinal.SecCount)do
        begin
         if(ldfile.SecName[index-1]=tempfinal.SecName[j-1]) then break;
         inc(j);
        end;
       if(j>tempfinal.SecCount) then continue;
      end;
     tempindex2:=j;
     if(ld_formula_check_got(ldfile.Adjust.Formula[i-1])) then
      begin
       j:=ld_adjust_search_for_index(ldfile.AdjustHashTable,
       DynNatuintArray(ldfile.Adjust.AdjustHash),ldfile.Adjust.AdjustHash[i-1],0,ld_adjust_got);
       if(j<>0) then
        begin
         offset1:=ldfile.AdjustHashTable.AdjustIndex[j-1]; writepos[1]:=2+offset1;
        end
       else
        begin
         offset1:=0; writepos[1]:=0;
        end;
      end;
     endoffset:=tempfinal.SecAddress[j-1]+ldfile.Adjust.DestOffset[i-1];
     if(isgotbase) or (isgotoffset) then
      begin
       j:=ld_adjust_search_for_index(ldfile.AdjustHashTable,
       DynNatuintArray(ldfile.Adjust.AdjustHash),ldfile.Adjust.AdjustHash[i-1],0,ld_adjust_got);
       if(j<>0) then
        begin
         offset1:=ldfile.AdjustHashTable.AdjustIndex[j-1]; writepos[1]:=2+offset1;
        end
       else
        begin
         offset1:=0; writepos[1]:=0;
        end;
      end;
     if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_adrp_page_rel_bit32_12)
     or(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_adrp_page_rel_bit32_12_no_check)
     or(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_page_rel_adrp_bit32_12) then
      begin
       tempnum3:=0; tempnum4:=1;
       if(ld_formula_check_got(ldfile.Adjust.Formula[i-1])) then
        begin
         tempresult:=ld_align_floor(tempfinal.SecAddress[gotindex-1]
         +writepos[1]*ldbit shl 2+ldfile.Adjust.Addend[i-1],$1000)-
         ld_align_floor(startoffset,$1000);
        end
       else
       tempresult:=ld_align_floor(endoffset+ldfile.Adjust.Addend[i-1],$1000)-
       ld_align_floor(startoffset,$1000);
       tempresult2:=tempresult;
       movesecoffset:=0; movesecoffset2:=0;
       while(tempnum3<>tempnum4) or (tempresult<>tempresult2) do
        begin
         startoffset:=tempfinal.SecAddress[tempindex-1]+ldfile.Adjust.SrcOffset[i-1];
         endoffset:=tempfinal.SecAddress[tempindex2-1]+ldfile.Adjust.DestOffset[i-1];
         changeptr:=tempfinal.SecContent[tempindex-1]+ldfile.Adjust.SrcOffset[i-1];
         tempresult:=tempresult2;
         tempnum1:=ld_align_floor(startoffset,$1000);
         if(ld_formula_check_got(ldfile.Adjust.Formula[i-1])) then
          begin
           tempnum2:=tempfinal.SecAddress[gotindex-1]
           +writepos[1]*ldbit shl 2+ldfile.Adjust.Addend[i-1];
          end
         else tempnum2:=endoffset+ldfile.Adjust.Addend[i-1];
         tempnum3:=tempnum2-tempnum1-tempresult;
         movesecoffset:=0;
         if(Abs(tempnum3)>=4096) and (Abs(tempnum3) mod 4096<>0) then
          begin
           if(ldfile.Adjust.SrcOffset[i-1]+8<=tempfinal.SecSize[tempindex-1]) and
           (Pld_aarch64_add_or_sub_immediate(changeptr+4)^.FixedValue=
           ld_aarch64_add_or_sub_fixed_value) and
           (Pld_aarch64_add_or_sub_immediate(changeptr+4)^.Rd=Pdword(changeptr)^ and $1F) then
            begin
             if(tempnum3>=4096) and (tempnum3 mod 4096=0) then
              begin
              end
             else if(tempnum3>=4096) then inc(movesecoffset,4)
            end
           else inc(movesecoffset,8);
          end
         else if(Abs(tempnum3)>=4096) then
          begin
           if(ldfile.Adjust.SrcOffset[i-1]+8<=tempfinal.SecSize[tempindex-1]) and
           (Pld_aarch64_add_or_sub_immediate(changeptr+4)^.FixedValue=
           ld_aarch64_add_or_sub_fixed_value) and
           (Pld_aarch64_add_or_sub_immediate(changeptr+4)^.Rd=Pdword(changeptr)^ and $1F) then
            begin
            end
           else inc(movesecoffset,4);
          end
         else if(Abs(tempnum3)<>0) then
          begin
           if(ldfile.Adjust.SrcOffset[i-1]+8<=tempfinal.SecSize[tempindex-1]) and
           (Pld_aarch64_add_or_sub_immediate(changeptr+4)^.FixedValue=
           ld_aarch64_add_or_sub_fixed_value) and
           (Pld_aarch64_add_or_sub_immediate(changeptr+4)^.Rd=Pdword(changeptr)^ and $1F) then
            begin
            end
           else inc(movesecoffset,4);
          end;
         if(ldfile.Adjust.SrcOffset[i-1]+8<=tempfinal.SecSize[tempindex-1])
         and (Pld_aarch64_add_or_sub_immediate(changeptr+4)^.FixedValue=
         ld_aarch64_add_or_sub_fixed_value) and
         (Pld_aarch64_add_or_sub_immediate(changeptr+4)^.Rd=Pdword(changeptr)^ and $1F) and
         (Pld_aarch64_add_or_sub_immediate(changeptr+4)^.Imm12=0) then
          begin
           dec(movesecoffset,4);
          end;
         m:=1; tempindex3:=0; tempindex4:=0;
         while(m<=tempfinal.SecCount-1) do
          begin
           n:=1;
           while(n<=tempfinal.SecCount)do
            begin
             if(tempfinal.SecIndex[n-1]=m) then break;
             inc(n);
            end;
           tempindex3:=n;
           n:=1;
           while(n<=tempfinal.SecCount)do
            begin
             if(tempfinal.SecIndex[n-1]=m+1) then break;
             inc(n);
            end;
           tempindex4:=n;
           if(tempindex4=0) then break;
           if(tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1]<=
           tempfinal.SecAddress[tempindex4-1]) then
            begin
             if(tempfinal.SecName[tempindex4-1]='.text')
             or(tempfinal.SecName[tempindex4-1]='.rodata')
             or(tempfinal.SecName[tempindex4-1]='.data') then
              begin
               if(ld_align(tempfinal.SecAddress[tempindex4-1],align)-
               (tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1])>=align) then
                begin
                 ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                 DynWordArray(tempfinal.SecIndex),
                 tempfinal.SecIndex[tempindex4-1],-align);
                end;
              end
             else if(tempfinal.SecName[tempindex3-1]<>'.bss') and
             (tempfinal.SecName[tempindex3-1]<>'.tbss') then
              begin
               if(tempfinal.SecAddress[tempindex4-1]-
               (tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1])>=ldbit shl 2) then
                begin
                 ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                 DynWordArray(tempfinal.SecIndex),
                 tempfinal.SecIndex[tempindex4-1],-ldbit shl 2);
                end;
              end
             else
              begin
               if(tempfinal.SecAddress[tempindex4-1]-tempfinal.SecAddress[tempindex3-1]>=ldbit shl 2) then
                begin
                 ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                 DynwordArray(tempfinal.SecIndex),
                 tempfinal.SecIndex[tempindex4-1],-ldbit shl 2);
                end;
              end;
            end
           else
            begin
             if(tempfinal.SecName[tempindex4-1]='.text')
             or(tempfinal.SecName[tempindex4-1]='.rodata')
             or(tempfinal.SecName[tempindex4-1]='.data') then
              begin
               if(ld_align(tempfinal.SecAddress[tempindex4-1],align)-
               (tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1])<=0) then
                begin
                 ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                 DynWordArray(tempfinal.SecIndex),
                 tempfinal.SecIndex[tempindex4-1],align);
                end;
              end
             else if(tempfinal.SecName[tempindex3-1]<>'.bss') and
             (tempfinal.SecName[tempindex3-1]<>'.tbss') then
              begin
               if(tempfinal.SecAddress[tempindex4-1]-
               (tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1])<=0) then
                begin
                 ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                 DynWordArray(tempfinal.SecIndex),
                 tempfinal.SecIndex[tempindex4-1],ldbit shl 2);
                end;
              end
             else
              begin
               if(tempfinal.SecAddress[tempindex4-1]-
               (tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1])<0) then
                begin
                 ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                 DynWordArray(tempfinal.SecIndex),
                 tempfinal.SecIndex[tempindex4-1],ldbit shl 2);
                end;
              end;
            end;
           inc(m);
          end;
         startoffset:=tempfinal.SecAddress[tempindex-1]+ldfile.Adjust.SrcOffset[i-1];
         if(tempindex=tempindex2) and (ldfile.Adjust.SrcOffset[i-1]<ldfile.Adjust.DestOffset[i-1]) then
         endoffset:=tempfinal.SecAddress[tempindex2-1]+ldfile.Adjust.DestOffset[i-1]+movesecoffset
         else
         endoffset:=tempfinal.SecAddress[tempindex2-1]+ldfile.Adjust.DestOffset[i-1];
         if(ld_formula_check_got(ldfile.Adjust.Formula[i-1])) then
          begin
           tempresult2:=ld_align_floor(tempfinal.SecAddress[gotindex-1]
           +writepos[1]*ldbit shl 2+ldfile.Adjust.Addend[i-1],$1000)-
           ld_align_floor(startoffset,$1000);
          end
         else
         tempresult2:=ld_align_floor(endoffset+ldfile.Adjust.Addend[i-1],$1000)-
         ld_align_floor(startoffset,$1000);
         tempnum1:=ld_align_floor(startoffset,$1000);
         if(ld_formula_check_got(ldfile.Adjust.Formula[i-1])) then
          begin
           tempnum2:=tempfinal.SecAddress[gotindex-1]
           +writepos[1]*ldbit shl 2+ldfile.Adjust.Addend[i-1];
          end
         else tempnum2:=endoffset+ldfile.Adjust.Addend[i-1];
         tempnum4:=tempnum2-tempnum1-tempresult2;
         if(tempnum3<>tempnum4) or (tempresult<>tempresult2) then continue;
         if(Pld_aarch64_ld_or_st_immediate_12(changeptr+4)^.Opcode=1)
         and (Pld_aarch64_ld_or_st_immediate_12(changeptr+4)^.Size>=2)
         and (Pld_aarch64_ld_or_st_immediate_12(changeptr+4)^.Reserved2=7) then
          begin
           if(Pld_aarch64_ld_or_st_immediate_12(changeptr+4)^.Unsigned=1) then
            begin
             if(Pld_aarch64_ld_or_st_immediate_12(changeptr+4)^.Size=2) then
              begin
               if(tempnum3>$FFF shl 2) then dec(tempnum3,$FFF shl 2)
               else
                begin
                 tempnum3:=0; break;
                end;
              end
             else if(Pld_aarch64_ld_or_st_immediate_12(changeptr+4)^.Size=3) then
              begin
               if(tempnum3>$FFF shl 3) then dec(tempnum3,$FFF shl 3)
               else
                begin
                 tempnum3:=0; break;
                end;
              end;
            end
           else
            begin
             if(Abs(tempnum3)<=$1FF) then
              begin
               tempnum3:=0; break;
              end
             else if(tempnum3>0) then dec(tempnum3,$1FF)
             else if(tempnum3<0) then inc(tempnum3,$1FF);
            end;
          end;
         if(Abs(tempnum3)>=4096) and (Abs(tempnum3) mod 4096<>0) then
          begin
           if(ldfile.Adjust.SrcOffset[i-1]+12<=tempfinal.SecSize[tempindex-1]) and
           (Pld_aarch64_add_or_sub_immediate(changeptr+4)^.FixedValue=
           ld_aarch64_add_or_sub_fixed_value) and
           (Pld_aarch64_add_or_sub_immediate(changeptr+8)^.FixedValue=
           ld_aarch64_add_or_sub_fixed_value) and
           (Pld_aarch64_add_or_sub_immediate(changeptr+4)^.Rd=Pdword(changeptr)^ and $1F) and
           (Pld_aarch64_add_or_sub_immediate(changeptr+8)^.Rd=Pdword(changeptr)^ and $1F) then
            begin
             Pld_aarch64_add_or_sub_immediate(changeptr+4)^.Opcode:=tempnum3<0;
             Pld_aarch64_add_or_sub_immediate(changeptr+4)^.Imm12:=Abs(tempnum3) shr 12;
             Pld_aarch64_add_or_sub_immediate(changeptr+4)^.Shift:=1;
             Pld_aarch64_add_or_sub_immediate(changeptr+8)^.Opcode:=tempnum3<0;
             Pld_aarch64_add_or_sub_immediate(changeptr+8)^.Imm12:=Abs(tempnum3) and $FFF;
             Pld_aarch64_add_or_sub_immediate(changeptr+8)^.Shift:=0;
            end
           else if(ldfile.Adjust.SrcOffset[i-1]+8<=tempfinal.SecSize[tempindex-1]) and
           (Pld_aarch64_add_or_sub_immediate(changeptr+4)^.FixedValue=
           ld_aarch64_add_or_sub_fixed_value) and
           (Pld_aarch64_add_or_sub_immediate(changeptr+4)^.Rd=Pdword(changeptr)^ and $1F) then
            begin
             if(Abs(tempnum3)>=4096) and (Abs(tempnum3) mod 4096=0) then
              begin
               Pld_aarch64_add_or_sub_immediate(changeptr+4)^.Opcode:=tempnum3<0;
               Pld_aarch64_add_or_sub_immediate(changeptr+4)^.Imm12:=Abs(tempnum3) shr 12;
               Pld_aarch64_add_or_sub_immediate(changeptr+4)^.Shift:=1;
              end
             else if(Abs(tempnum3)>=4096) then
              begin
               Pld_aarch64_add_or_sub_immediate(changeptr+4)^.Opcode:=tempnum3<0;
               Pld_aarch64_add_or_sub_immediate(changeptr+4)^.Imm12:=Abs(tempnum3) shr 12;
               Pld_aarch64_add_or_sub_immediate(changeptr+4)^.Shift:=1;
               inc(tempfinal.SecSize[tempindex-1],8);
               tydq_reallocMem(tempfinal.SecContent[tempindex-1],tempfinal.SecSize[tempindex-1]);
               changeptr:=tempfinal.SecContent[tempindex-1]+ldfile.Adjust.SrcOffset[i-1];
               tydq_move(Pbyte(changeptr+8)^,Pbyte(changeptr+12)^,
               tempfinal.SecSize[tempindex-1]-ldfile.Adjust.Srcoffset[i-1]-12);
               if(tempnum3>0) then
               Pdword(changeptr+8)^:=
               ld_aarch64_stub_add(Pdword(changeptr)^ and $1F,Abs(tempnum3) and $FFF,false,ldbit=2)
               else
               Pdword(changeptr+8)^:=
               ld_aarch64_stub_sub(Pdword(changeptr)^ and $1F,Abs(tempnum3) and $FFF,false,ldbit=2);
               inc(movesecoffset2,4);
              end
             else
              begin
               Pld_aarch64_add_or_sub_immediate(changeptr+4)^.Opcode:=tempnum3<0;
               Pld_aarch64_add_or_sub_immediate(changeptr+4)^.Imm12:=Abs(tempnum3) and $FFF;
               Pld_aarch64_add_or_sub_immediate(changeptr+4)^.Shift:=0;
              end;
            end
           else
            begin
             inc(tempfinal.SecSize[tempindex-1],8);
             tydq_reallocMem(tempfinal.SecContent[tempindex-1],tempfinal.SecSize[tempindex-1]);
             changeptr:=tempfinal.SecContent[tempindex-1]+ldfile.Adjust.SrcOffset[i-1];
             tydq_move(Pbyte(changeptr+4)^,Pbyte(changeptr+12)^,
             tempfinal.SecSize[tempindex-1]-ldfile.Adjust.Srcoffset[i-1]-12);
             if(tempnum3>0) then
             Pdword(changeptr+4)^:=
             ld_aarch64_stub_add(Pdword(changeptr)^ and $1F,(Abs(tempnum3) shr 12) and $FFF,true,ldbit=2)
             else
             Pdword(changeptr+4)^:=
             ld_aarch64_stub_sub(Pdword(changeptr)^ and $1F,(Abs(tempnum3) shr 12) and $FFF,true,ldbit=2);
             if(tempnum3>0) then
             Pdword(changeptr+8)^:=
             ld_aarch64_stub_add(Pdword(changeptr)^ and $1F,Abs(tempnum3) and $FFF,false,ldbit=2)
             else
             Pdword(changeptr+8)^:=
             ld_aarch64_stub_sub(Pdword(changeptr)^ and $1F,Abs(tempnum3) and $FFF,false,ldbit=2);
             inc(movesecoffset2,8);
            end;
          end
         else if(Abs(tempnum3)>=4096) then
          begin
           if(ldfile.Adjust.SrcOffset[i-1]+8<=tempfinal.SecSize[tempindex-1]) and
           (Pld_aarch64_add_or_sub_immediate(changeptr+4)^.FixedValue=
           ld_aarch64_add_or_sub_fixed_value) and
           (Pld_aarch64_add_or_sub_immediate(changeptr+4)^.Rd=Pdword(changeptr)^ and $1F) then
            begin
             Pld_aarch64_add_or_sub_immediate(changeptr+4)^.Opcode:=tempnum3<0;
             Pld_aarch64_add_or_sub_immediate(changeptr+4)^.Imm12:=Abs(tempnum3) shr 12;
             Pld_aarch64_add_or_sub_immediate(changeptr+4)^.Shift:=1;
            end
           else
            begin
             inc(tempfinal.SecSize[tempindex-1],4);
             tydq_reallocMem(tempfinal.SecContent[tempindex-1],tempfinal.SecSize[tempindex-1]);
             changeptr:=tempfinal.SecContent[tempindex-1]+ldfile.Adjust.SrcOffset[i-1];
             tydq_move(Pbyte(changeptr+4)^,Pbyte(changeptr+8)^,
             tempfinal.SecSize[tempindex-1]-ldfile.Adjust.Srcoffset[i-1]-8);
             if(tempnum3>0) then
             Pdword(changeptr+4)^:=
             ld_aarch64_stub_add(Pdword(changeptr)^ and $1F,Abs(tempnum3) and $FFF,false,ldbit=2)
             else
             Pdword(changeptr+4)^:=
             ld_aarch64_stub_sub(Pdword(changeptr)^ and $1F,Abs(tempnum3) and $FFF,false,ldbit=2);
             inc(movesecoffset2,4);
            end;
          end
         else if(Abs(tempnum3)<>0) then
          begin
           if(ldfile.Adjust.SrcOffset[i-1]+8<=tempfinal.SecSize[tempindex-1]) and
           (Pld_aarch64_add_or_sub_immediate(changeptr+4)^.FixedValue=
           ld_aarch64_add_or_sub_fixed_value) and
           (Pld_aarch64_add_or_sub_immediate(changeptr+4)^.Rd=Pdword(changeptr)^ and $1F) then
            begin
             Pld_aarch64_add_or_sub_immediate(changeptr+4)^.Opcode:=tempnum3<0;
             Pld_aarch64_add_or_sub_immediate(changeptr+4)^.Imm12:=Abs(tempnum3);
            end
           else
            begin
             inc(tempfinal.SecSize[tempindex-1],4);
             tydq_reallocMem(tempfinal.SecContent[tempindex-1],tempfinal.SecSize[tempindex-1]);
             changeptr:=tempfinal.SecContent[tempindex-1]+ldfile.Adjust.SrcOffset[i-1];
             tydq_move(Pbyte(changeptr+4)^,Pbyte(changeptr+8)^,
             tempfinal.SecSize[tempindex-1]-ldfile.Adjust.Srcoffset[i-1]-8);
             if(tempnum3>0) then
             Pdword(changeptr+4)^:=
             ld_aarch64_stub_add(Pdword(changeptr)^ and $1F,Abs(tempnum3) and $FFF,false,ldbit=2)
             else
             Pdword(changeptr+4)^:=
             ld_aarch64_stub_sub(Pdword(changeptr)^ and $1F,Abs(tempnum3) and $FFF,false,ldbit=2);
             inc(movesecoffset2,4);
            end;
          end;
         changeptr:=tempfinal.SecContent[tempindex-1]+ldfile.Adjust.SrcOffset[i-1];
         if(ldfile.Adjust.SrcOffset[i-1]+8<=tempfinal.SecSize[tempindex-1])
         and (Pld_aarch64_add_or_sub_immediate(changeptr+4)^.FixedValue=
         ld_aarch64_add_or_sub_fixed_value) and
         (Pld_aarch64_add_or_sub_immediate(changeptr+4)^.Rd=Pdword(changeptr)^ and $1F) and
         (Pld_aarch64_add_or_sub_immediate(changeptr+4)^.Imm12=0) then
          begin
           tydq_move(Pbyte(changeptr+8)^,Pbyte(changeptr+4)^,
           tempfinal.SecSize[tempindex-1]-ldfile.Adjust.Srcoffset[i-1]-8);
           dec(tempfinal.SecSize[tempindex-1],4);
           tydq_reallocMem(tempfinal.SecContent[tempindex-1],tempfinal.SecSize[tempindex-1]);
           dec(movesecoffset2,4);
          end;
         if(movesecoffset2<>0) then
          begin
           m:=1; tempindex3:=0; tempindex4:=0;
           while(m<=tempfinal.SecCount-1) do
            begin
             n:=1;
             while(n<=tempfinal.SecCount)do
              begin
               if(tempfinal.SecIndex[n-1]=m) then break;
               inc(n);
              end;
             if(n<=tempfinal.SecCount) then tempindex3:=n else tempindex3:=0;
             if(tempindex3=0) then break;
             n:=1;
             while(n<=tempfinal.SecCount)do
              begin
               if(tempfinal.SecIndex[n-1]=m+1) then break;
               inc(n);
              end;
             if(n<=tempfinal.SecCount) then tempindex4:=n else tempindex4:=0;
             if(tempindex4=0) then break;
             if(tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1]<=
             tempfinal.SecAddress[tempindex4-1]) then
              begin
               if(tempfinal.SecName[tempindex4-1]='.text')
               or(tempfinal.SecName[tempindex4-1]='.rodata')
               or(tempfinal.SecName[tempindex4-1]='.data') then
                begin
                 if(ld_align(tempfinal.SecAddress[tempindex4-1],align)-
                 (tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1])>=align) then
                  begin
                   ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                   DynWordArray(tempfinal.SecIndex),
                   tempfinal.SecIndex[tempindex4-1],-align);
                  end;
                end
               else if(tempfinal.SecName[tempindex3-1]<>'.bss') and
               (tempfinal.SecName[tempindex3-1]<>'.tbss') then
                begin
                 if(tempfinal.SecAddress[tempindex4-1]-
                 (tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1])>=ldbit shl 2) then
                  begin
                   ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                   DynWordArray(tempfinal.SecIndex),
                   tempfinal.SecIndex[tempindex4-1],-ldbit shl 2);
                  end;
                end
               else
                begin
                 if(tempfinal.SecAddress[tempindex4-1]-tempfinal.SecAddress[tempindex3-1]>=ldbit shl 2) then
                  begin
                   ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                   DynwordArray(tempfinal.SecIndex),
                   tempfinal.SecIndex[tempindex4-1],-ldbit shl 2);
                  end;
                end;
              end
             else
              begin
               if(tempfinal.SecName[tempindex4-1]='.text')
               or(tempfinal.SecName[tempindex4-1]='.rodata')
               or(tempfinal.SecName[tempindex4-1]='.data') then
                begin
                 if(ld_align(tempfinal.SecAddress[tempindex4-1],align)-
                 (tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1])<=0) then
                  begin
                   ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                   DynWordArray(tempfinal.SecIndex),
                   tempfinal.SecIndex[tempindex4-1],align);
                  end;
                end
               else if(tempfinal.SecName[tempindex3-1]<>'.bss') and
               (tempfinal.SecName[tempindex3-1]<>'.tbss') then
                begin
                 if(tempfinal.SecAddress[tempindex4-1]-
                 (tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1])<=0) then
                  begin
                   ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                   DynWordArray(tempfinal.SecIndex),
                   tempfinal.SecIndex[tempindex4-1],ldbit shl 2);
                  end;
                end
               else
                begin
                 if(tempfinal.SecAddress[tempindex4-1]-
                 (tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1])<0) then
                  begin
                   ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                   DynWordArray(tempfinal.SecIndex),
                   tempfinal.SecIndex[tempindex4-1],ldbit shl 2);
                  end;
                end;
              end;
            inc(m);
           end;
           for m:=1 to ldfile.Adjust.Count do
            begin
             if(ldfile.Adjust.AdjustType[m-1]=0) then continue;
             if(ldfile.Adjust.SrcIndex[i-1]=ldfile.Adjust.SrcIndex[m-1]) then
              begin
               if(ldfile.Adjust.SrcOffset[i-1]+4<=ldfile.Adjust.SrcOffset[m-1]) then
                begin
                 inc(ldfile.Adjust.SrcOffset[m-1],movesecoffset2);
                end;
              end;
             if(ldfile.Adjust.SrcIndex[i-1]=ldfile.Adjust.DestIndex[m-1]) then
              begin
               if(ldfile.Adjust.SrcOffset[i-1]+4<=ldfile.Adjust.DestOffset[m-1]) then
                begin
                 inc(ldfile.Adjust.DestOffset[m-1],movesecoffset2);
                end;
              end;
            end;
           for m:=1 to ldfile.SymTable.SymbolCount do
            begin
             if(ldfile.Adjust.AdjustType[m-1]=0) then continue;
             if(ldfile.Adjust.SrcIndex[i-1]=ldfile.SymTable.SymbolIndex[m-1]) then
              begin
               if(ldfile.Adjust.SrcOffset[i-1]+4<=ldfile.SymTable.SymbolValue[m-1]) then
                begin
                 inc(ldfile.SymTable.SymbolValue[m-1],movesecoffset2);
                end
               else if(ldfile.Adjust.SrcOffset[i-1]=ldfile.SymTable.SymbolValue[m-1]) then
                begin
                 inc(ldfile.SymTable.SymbolSize[m-1],movesecoffset2);
                end;
              end;
            end;
           if(ldfile.Adjust.SrcIndex[i-1]=ldfile.EntryIndex) and
           (ldfile.Adjust.SrcOffset[i-1]+4<=ldfile.EntryOffset) then
            begin
             inc(ldfile.EntryOffset,movesecoffset2);
            end;
           movesecoffset2:=0;
          end;
        end;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_dir_got_offset_ld_st_imm_bit11_3) then
      begin
       if(ld_formula_check_got(ldfile.Adjust.Formula[i-1])) then
        begin
         tempresult:=tempfinal.SecAddress[gotindex-1]
         +writepos[1]*ldbit shl 2+ldfile.Adjust.Addend[i-1];
        end
       else tempresult:=endoffset+ldfile.Adjust.Addend[i-1];
       tempresult:=(tempresult shr 3) and $1FF;
       if(tempresult=0) and
       (Pld_aarch64_ld_or_st_immediate_12(changeptr)^.Rd=
        Pld_aarch64_ld_or_st_immediate_12(changeptr)^.Rn) then
        begin
         changeptr:=tempfinal.SecContent[tempindex-1]+ldfile.Adjust.Srcoffset[i-1];
         tydq_move(Pbyte(changeptr+4)^,Pbyte(changeptr+0)^,
         tempfinal.SecSize[tempindex-1]-ldfile.Adjust.Srcoffset[i-1]-4);
         dec(tempfinal.SecSize[tempindex-1],4);
         tydq_reallocMem(tempfinal.SecContent[tempindex-1],tempfinal.SecSize[tempindex-1]);
         m:=1; tempindex3:=0; tempindex4:=0;
         while(m<=tempfinal.SecCount-1) do
          begin
           n:=1;
           while(n<=tempfinal.SecCount)do
            begin
             if(tempfinal.SecIndex[n-1]=m) then break;
             inc(n);
            end;
           if(n<=tempfinal.SecCount) then tempindex3:=n else tempindex3:=0;
           if(tempindex3=0) then break;
           n:=1;
           while(n<=tempfinal.SecCount)do
            begin
             if(tempfinal.SecIndex[n-1]=m+1) then break;
             inc(n);
            end;
           if(n<=tempfinal.SecCount) then tempindex4:=n else tempindex4:=0;
           if(tempindex4=0) then break;
           if(tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1]<=
             tempfinal.SecAddress[tempindex4-1]) then
              begin
               if(tempfinal.SecName[tempindex4-1]='.text')
               or(tempfinal.SecName[tempindex4-1]='.rodata')
               or(tempfinal.SecName[tempindex4-1]='.data') then
                begin
                 if(ld_align(tempfinal.SecAddress[tempindex4-1],align)-
                 (tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1])>=align) then
                  begin
                   ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                   DynWordArray(tempfinal.SecIndex),
                   tempfinal.SecIndex[tempindex4-1],-align);
                  end;
                end
               else if(tempfinal.SecName[tempindex3-1]<>'.bss') and
               (tempfinal.SecName[tempindex3-1]<>'.tbss') then
                begin
                 if(tempfinal.SecAddress[tempindex4-1]-
                 (tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1])>=ldbit shl 2) then
                  begin
                   ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                   DynWordArray(tempfinal.SecIndex),
                   tempfinal.SecIndex[tempindex4-1],-ldbit shl 2);
                  end;
                end
               else
                begin
                 if(tempfinal.SecAddress[tempindex4-1]-tempfinal.SecAddress[tempindex3-1]>=ldbit shl 2) then
                  begin
                   ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                   DynwordArray(tempfinal.SecIndex),
                   tempfinal.SecIndex[tempindex4-1],-ldbit shl 2);
                  end;
                end;
              end
             else
              begin
               if(tempfinal.SecName[tempindex4-1]='.text')
               or(tempfinal.SecName[tempindex4-1]='.rodata')
               or(tempfinal.SecName[tempindex4-1]='.data') then
                begin
                 if(ld_align(tempfinal.SecAddress[tempindex4-1],align)-
                 (tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1])<=0) then
                  begin
                   ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                   DynWordArray(tempfinal.SecIndex),
                   tempfinal.SecIndex[tempindex4-1],align);
                  end;
                end
               else if(tempfinal.SecName[tempindex3-1]<>'.bss') and
               (tempfinal.SecName[tempindex3-1]<>'.tbss') then
                begin
                 if(tempfinal.SecAddress[tempindex4-1]-
                 (tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1])<=0) then
                  begin
                   ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                   DynWordArray(tempfinal.SecIndex),
                   tempfinal.SecIndex[tempindex4-1],ldbit shl 2);
                  end;
                end
               else
                begin
                 if(tempfinal.SecAddress[tempindex4-1]-
                 (tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1])<0) then
                  begin
                   ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                   DynWordArray(tempfinal.SecIndex),
                   tempfinal.SecIndex[tempindex4-1],ldbit shl 2);
                  end;
                end;
              end;
           inc(m);
          end;
         for m:=1 to ldfile.Adjust.Count do
          begin
           if(ldfile.Adjust.AdjustType[m-1]=0) then continue;
           if(ldfile.Adjust.SrcIndex[i-1]=ldfile.Adjust.SrcIndex[m-1]) then
            begin
             if(ldfile.Adjust.SrcOffset[i-1]+8<=ldfile.Adjust.SrcOffset[m-1]) then
              begin
               dec(ldfile.Adjust.SrcOffset[m-1],4);
              end;
            end;
           if(ldfile.Adjust.SrcIndex[i-1]=ldfile.Adjust.DestIndex[m-1]) then
            begin
             if(ldfile.Adjust.SrcOffset[i-1]+8<=ldfile.Adjust.DestOffset[m-1]) then
              begin
               dec(ldfile.Adjust.DestOffset[m-1],4);
              end;
            end;
          end;
         for m:=1 to ldfile.SymTable.SymbolCount do
          begin
           if(ldfile.Adjust.SrcIndex[i-1]=ldfile.SymTable.SymbolIndex[m-1]) then
            begin
             if(ldfile.Adjust.SrcOffset[i-1]+8<=ldfile.SymTable.SymbolValue[m-1]) then
              begin
               dec(ldfile.SymTable.SymbolValue[m-1],4);
              end
             else if(ldfile.Adjust.SrcOffset[i-1]=ldfile.SymTable.SymbolValue[m-1]) then
              begin
               dec(ldfile.SymTable.SymbolSize[m-1],4);
              end;
            end;
          end;
         if(ldfile.Adjust.SrcIndex[i-1]=ldfile.EntryIndex) and
         (ldfile.Adjust.SrcOffset[i-1]+8<=ldfile.EntryOffset) then
          begin
           dec(ldfile.EntryOffset,4);
          end;
        end
       else if(Abs(tempresult)>$FF) and (Abs(tempresult)<$10FF) then
        begin
         inc(tempfinal.SecSize[tempindex-1],4);
         tydq_reallocMem(tempfinal.SecContent[tempindex-1],tempfinal.SecSize[tempindex-1]);
         changeptr:=tempfinal.SecContent[tempindex-1]+ldfile.Adjust.SrcOffset[i-1];
         tydq_move(Pbyte(changeptr)^,Pbyte(changeptr+4)^,
         tempfinal.SecSize[tempindex-1]-ldfile.Adjust.Srcoffset[i-1]-4);
         if(tempresult>0) then
         Pdword(changeptr)^:=
         ld_aarch64_stub_add(Pdword(changeptr)^ and $1F,Abs(tempresult-$FF) and $FFF,false,ldbit=2)
         else
         Pdword(changeptr)^:=
         ld_aarch64_stub_sub(Pdword(changeptr)^ and $1F,Abs(tempresult-$FF) and $FFF,false,ldbit=2);
         m:=1; tempindex3:=0; tempindex4:=0;
         while(m<=tempfinal.SecCount-1) do
          begin
           n:=1;
           while(n<=tempfinal.SecCount)do
            begin
             if(tempfinal.SecIndex[n-1]=m) then break;
             inc(n);
            end;
           if(n<=tempfinal.SecCount) then tempindex3:=n else tempindex3:=0;
           if(tempindex3=0) then break;
           n:=1;
           while(n<=tempfinal.SecCount)do
            begin
             if(tempfinal.SecIndex[n-1]=m+1) then break;
             inc(n);
            end;
           if(n<=tempfinal.SecCount) then tempindex4:=n else tempindex4:=0;
           if(tempindex4=0) then break;
           if(tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1]<=
             tempfinal.SecAddress[tempindex4-1]) then
              begin
               if(tempfinal.SecName[tempindex4-1]='.text')
               or(tempfinal.SecName[tempindex4-1]='.rodata')
               or(tempfinal.SecName[tempindex4-1]='.data') then
                begin
                 if(ld_align(tempfinal.SecAddress[tempindex4-1],align)-
                 (tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1])>=align) then
                  begin
                   ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                   DynWordArray(tempfinal.SecIndex),
                   tempfinal.SecIndex[tempindex4-1],-align);
                  end;
                end
               else if(tempfinal.SecName[tempindex3-1]<>'.bss') and
               (tempfinal.SecName[tempindex3-1]<>'.tbss') then
                begin
                 if(tempfinal.SecAddress[tempindex4-1]-
                 (tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1])>=ldbit shl 2) then
                  begin
                   ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                   DynWordArray(tempfinal.SecIndex),
                   tempfinal.SecIndex[tempindex4-1],-ldbit shl 2);
                  end;
                end
               else
                begin
                 if(tempfinal.SecAddress[tempindex4-1]-tempfinal.SecAddress[tempindex3-1]>=ldbit shl 2) then
                  begin
                   ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                   DynwordArray(tempfinal.SecIndex),
                   tempfinal.SecIndex[tempindex4-1],-ldbit shl 2);
                  end;
                end;
              end
             else
              begin
               if(tempfinal.SecName[tempindex4-1]='.text')
               or(tempfinal.SecName[tempindex4-1]='.rodata')
               or(tempfinal.SecName[tempindex4-1]='.data') then
                begin
                 if(ld_align(tempfinal.SecAddress[tempindex4-1],align)-
                 (tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1])<=0) then
                  begin
                   ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                   DynWordArray(tempfinal.SecIndex),
                   tempfinal.SecIndex[tempindex4-1],align);
                  end;
                end
               else if(tempfinal.SecName[tempindex3-1]<>'.bss') and
               (tempfinal.SecName[tempindex3-1]<>'.tbss') then
                begin
                 if(tempfinal.SecAddress[tempindex4-1]-
                 (tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1])<=0) then
                  begin
                   ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                   DynWordArray(tempfinal.SecIndex),
                   tempfinal.SecIndex[tempindex4-1],ldbit shl 2);
                  end;
                end
               else
                begin
                 if(tempfinal.SecAddress[tempindex4-1]-
                 (tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1])<0) then
                  begin
                   ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                   DynWordArray(tempfinal.SecIndex),
                   tempfinal.SecIndex[tempindex4-1],ldbit shl 2);
                  end;
                end;
              end;
           inc(m);
          end;
         for m:=1 to ldfile.Adjust.Count do
          begin
           if(ldfile.Adjust.AdjustType[m-1]=0) then continue;
           if(ldfile.Adjust.SrcIndex[i-1]=ldfile.Adjust.SrcIndex[m-1]) then
            begin
             if(ldfile.Adjust.SrcOffset[i-1]+4<=ldfile.Adjust.SrcOffset[m-1]) then
              begin
               inc(ldfile.Adjust.SrcOffset[m-1],4);
              end;
            end;
           if(ldfile.Adjust.SrcIndex[i-1]=ldfile.Adjust.DestIndex[m-1]) then
            begin
             if(ldfile.Adjust.SrcOffset[i-1]+4<=ldfile.Adjust.DestOffset[m-1]) then
              begin
               inc(ldfile.Adjust.DestOffset[m-1],4);
              end;
            end;
          end;
         for m:=1 to ldfile.SymTable.SymbolCount do
          begin
           if(ldfile.Adjust.SrcIndex[i-1]=ldfile.SymTable.SymbolIndex[m-1]) then
            begin
             if(ldfile.Adjust.SrcOffset[i-1]+4<=ldfile.SymTable.SymbolValue[m-1]) then
              begin
               inc(ldfile.SymTable.SymbolValue[m-1],4);
              end
             else if(ldfile.Adjust.SrcOffset[i-1]=ldfile.SymTable.SymbolValue[m-1]) then
              begin
               inc(ldfile.SymTable.SymbolSize[m-1],4);
              end;
            end;
          end;
         inc(ldfile.Adjust.SrcOffset[i-1],4);
         if(ldfile.Adjust.SrcIndex[i-1]=ldfile.EntryIndex) and
         (ldfile.Adjust.SrcOffset[i-1]+4<=ldfile.EntryOffset) then
          begin
           inc(ldfile.EntryOffset,4);
          end;
        end
       else if(tempresult>=$10FF) and (tempresult<$1000*$1000+$FF) then
        begin
         inc(tempfinal.SecSize[tempindex-1],8);
         tydq_reallocMem(tempfinal.SecContent[tempindex-1],tempfinal.SecSize[tempindex-1]);
         changeptr:=tempfinal.SecContent[tempindex-1]+ldfile.Adjust.SrcOffset[i-1];
         tydq_move(Pbyte(changeptr)^,Pbyte(changeptr+8)^,
         tempfinal.SecSize[tempindex-1]-ldfile.Adjust.Srcoffset[i-1]-8);
         if(tempresult>0) then
          begin
           Pdword(changeptr)^:=
           ld_aarch64_stub_add(Pdword(changeptr)^ and $1F,(Abs(tempresult-$FF) shr 12) and $FFF,false,ldbit=2);
           Pdword(changeptr+4)^:=
           ld_aarch64_stub_add(Pdword(changeptr)^ and $1F,Abs(tempresult-$FF) and $FFF,false,ldbit=2);
          end
         else
          begin
           Pdword(changeptr)^:=
           ld_aarch64_stub_sub(Pdword(changeptr)^ and $1F,(Abs(tempresult-$FF) shr 12) and $FFF,false,ldbit=2);
           Pdword(changeptr+4)^:=
           ld_aarch64_stub_sub(Pdword(changeptr)^ and $1F,Abs(tempresult-$FF) and $FFF,false,ldbit=2);
          end;
         m:=1; tempindex3:=0; tempindex4:=0;
         while(m<=tempfinal.SecCount-1) do
          begin
           n:=1;
           while(n<=tempfinal.SecCount)do
            begin
             if(tempfinal.SecIndex[n-1]=m) then break;
             inc(n);
            end;
           if(n<=tempfinal.SecCount) then tempindex3:=n else tempindex3:=0;
           if(tempindex3=0) then break;
           n:=1;
           while(n<=tempfinal.SecCount)do
            begin
             if(tempfinal.SecIndex[n-1]=m+1) then break;
             inc(n);
            end;
           if(n<=tempfinal.SecCount) then tempindex4:=n else tempindex4:=0;
           if(tempindex4=0) then break;
           if(tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1]<=
             tempfinal.SecAddress[tempindex4-1]) then
              begin
               if(tempfinal.SecName[tempindex4-1]='.text')
               or(tempfinal.SecName[tempindex4-1]='.rodata')
               or(tempfinal.SecName[tempindex4-1]='.data') then
                begin
                 if(ld_align(tempfinal.SecAddress[tempindex4-1],align)-
                 (tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1])>=align) then
                  begin
                   ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                   DynWordArray(tempfinal.SecIndex),
                   tempfinal.SecIndex[tempindex4-1],-align);
                  end;
                end
               else if(tempfinal.SecName[tempindex3-1]<>'.bss') and
               (tempfinal.SecName[tempindex3-1]<>'.tbss') then
                begin
                 if(tempfinal.SecAddress[tempindex4-1]-
                 (tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1])>=ldbit shl 2) then
                  begin
                   ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                   DynWordArray(tempfinal.SecIndex),
                   tempfinal.SecIndex[tempindex4-1],-ldbit shl 2);
                  end;
                end
               else
                begin
                 if(tempfinal.SecAddress[tempindex4-1]-tempfinal.SecAddress[tempindex3-1]>=ldbit shl 2) then
                  begin
                   ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                   DynwordArray(tempfinal.SecIndex),
                   tempfinal.SecIndex[tempindex4-1],-ldbit shl 2);
                  end;
                end;
              end
             else
              begin
               if(tempfinal.SecName[tempindex4-1]='.text')
               or(tempfinal.SecName[tempindex4-1]='.rodata')
               or(tempfinal.SecName[tempindex4-1]='.data') then
                begin
                 if(ld_align(tempfinal.SecAddress[tempindex4-1],align)-
                 (tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1])<=0) then
                  begin
                   ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                   DynWordArray(tempfinal.SecIndex),
                   tempfinal.SecIndex[tempindex4-1],align);
                  end;
                end
               else if(tempfinal.SecName[tempindex3-1]<>'.bss') and
               (tempfinal.SecName[tempindex3-1]<>'.tbss') then
                begin
                 if(tempfinal.SecAddress[tempindex4-1]-
                 (tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1])<=0) then
                  begin
                   ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                   DynWordArray(tempfinal.SecIndex),
                   tempfinal.SecIndex[tempindex4-1],ldbit shl 2);
                  end;
                end
               else
                begin
                 if(tempfinal.SecAddress[tempindex4-1]-
                 (tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1])<0) then
                  begin
                   ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                   DynWordArray(tempfinal.SecIndex),
                   tempfinal.SecIndex[tempindex4-1],ldbit shl 2);
                  end;
                end;
              end;
           inc(m);
          end;
         for m:=1 to ldfile.Adjust.Count do
          begin
           if(ldfile.Adjust.AdjustType[m-1]=0) then continue;
           if(ldfile.Adjust.SrcIndex[i-1]=ldfile.Adjust.SrcIndex[m-1]) then
            begin
             if(ldfile.Adjust.SrcOffset[i-1]<=ldfile.Adjust.SrcOffset[m-1]) then
              begin
               inc(ldfile.Adjust.SrcOffset[m-1],8);
              end;
            end;
           if(ldfile.Adjust.SrcIndex[i-1]=ldfile.Adjust.DestIndex[m-1]) then
            begin
             if(ldfile.Adjust.SrcOffset[i-1]<=ldfile.Adjust.DestOffset[m-1]) then
              begin
               inc(ldfile.Adjust.DestOffset[m-1],8);
              end;
            end;
          end;
         for m:=1 to ldfile.SymTable.SymbolCount do
          begin
           if(ldfile.Adjust.AdjustType[m-1]=0) then continue;
           if(ldfile.Adjust.SrcIndex[i-1]=ldfile.SymTable.SymbolIndex[m-1]) then
            begin
             if(ldfile.Adjust.SrcOffset[i-1]<=ldfile.SymTable.SymbolValue[m-1]) then
              begin
               inc(ldfile.SymTable.SymbolSize[m-1],8);
              end;
            end;
          end;
         inc(ldfile.Adjust.SrcOffset[i-1],8);
         if(ldfile.Adjust.SrcIndex[i-1]=ldfile.EntryIndex) and
         (ldfile.Adjust.SrcOffset[i-1]+8<=ldfile.EntryOffset) then
          begin
           inc(ldfile.EntryOffset,8);
          end;
        end;
      end;
    end;
  end;
 {For Riscv Only}
 writepos[1]:=3;
 if(ldarch=elf_machine_riscv) then
  begin
   for k:=1 to ldfile.Adjust.Count do
    begin
     index:=ldfile.Adjust.SrcIndex[i-1];
     if(ldfile.SecName[index-1]='.debug_frame') and (debugframe=false) then continue;
     j:=1;
     while(j<=tempfinal.SecCount)do
      begin
       if(ldfile.SecName[index-1]=tempfinal.SecName[j-1]) then break;
       inc(j);
      end;
     if(j>tempfinal.SecCount) then continue;
     startoffset:=tempfinal.SecAddress[j-1]+ldfile.Adjust.SrcOffset[i-1];
     changeptr:=tempfinal.SecContent[j-1]+ldfile.Adjust.Srcoffset[i-1];
     tempindex:=j;
     index:=ldfile.Adjust.DestIndex[i-1];
     if(index>0) then
      begin
       if(ldfile.SecName[index-1]='.debug_frame') and (debugframe=false) then continue;
       j:=ld_adjust_search_for_index(ldfile.AdjustHashTable,
       DynNatuintArray(ldfile.Adjust.AdjustHash),ldfile.Adjust.AdjustHash[i-1],0,ld_adjust_got);
       if(j<>0) then
        begin
         offset1:=ldfile.AdjustHashTable.AdjustIndex[j-1]; writepos[1]:=2+offset1;
        end
       else
        begin
         offset1:=0; writepos[1]:=0;
        end;
      end;
     tempindex2:=j;
     if(ld_formula_check_got(ldfile.Adjust.Formula[i-1])) then
      begin
       j:=ld_adjust_search_for_index(ldfile.AdjustHashTable,
       DynNatuintArray(ldfile.Adjust.AdjustHash),ldfile.Adjust.AdjustHash[i-1],0,ld_adjust_got);
       if(j<>0) then
        begin
         offset1:=ldfile.AdjustHashTable.AdjustIndex[j-1]; writepos[1]:=2+offset1;
        end
       else
        begin
         offset1:=0; writepos[1]:=0;
        end;
      end;
     endoffset:=tempfinal.SecAddress[j-1]+ldfile.Adjust.DestOffset[i-1];
     {Rehandle the Adjustment Table For RISC-V}
     if(isgotbase) or (isgotoffset) then
      begin
       j:=ld_adjust_search_for_index(ldfile.AdjustHashTable,
       DynNatuintArray(ldfile.Adjust.AdjustHash),ldfile.Adjust.AdjustHash[i-1],0,ld_adjust_got);
       if(j<>0) then
        begin
         offset1:=ldfile.AdjustHashTable.AdjustIndex[j-1]; writepos[1]:=2+offset1;
        end
       else
        begin
         offset1:=0; writepos[1]:=0;
        end;
      end;
     if(ldfile.Adjust.Formula[i-1].mask=elf_riscv_u_i_type)then
      begin
       tempnum3:=0; tempnum4:=1;
       if(ld_formula_check_got(ldfile.Adjust.Formula[i-1])) then
        begin
         tempresult:=(tempfinal.SecAddress[gotindex-1]
         +writepos[1]*ldbit shl 2+ldfile.Adjust.Addend[i-1]-startoffset);
        end
       else
        begin
         tempresult:=(endoffset+ldfile.Adjust.Addend[i-1]-startoffset);
        end;
       if((tempresult and $FFF=0) or (tempresult shr 12=0)) and
       (ld_riscv_check_ld(Pdword(changeptr+4)^)=false) then
        begin
         if(tempresult and $FFF=0) and (tempresult shr 12=0) then
          begin
           changeptr:=tempfinal.SecContent[tempindex-1]+ldfile.Adjust.Srcoffset[i-1];
           tydq_move(Pbyte(changeptr+8)^,Pbyte(changeptr)^,
           tempfinal.SecSize[tempindex-1]-ldfile.Adjust.Srcoffset[i-1]-8);
           dec(tempfinal.SecSize[tempindex-1],8); movesecoffset:=8; movesecoffset2:=0;
           ldfile.Adjust.AdjustType[i-1]:=0;
          end
         else if(tempresult and $FFF=0) then
          begin
           changeptr:=tempfinal.SecContent[tempindex-1]+ldfile.Adjust.Srcoffset[i-1];
           tydq_move(Pbyte(changeptr+8)^,Pbyte(changeptr+4)^,
           tempfinal.SecSize[tempindex-1]-ldfile.Adjust.Srcoffset[i-1]-8);
           dec(tempfinal.SecSize[tempindex-1],4); movesecoffset:=4; movesecoffset2:=4;
           ldfile.Adjust.Formula[i-1].mask:=elf_riscv_u_type;
          end
         else if(tempresult shr 12=0) then
          begin
           changeptr:=tempfinal.SecContent[tempindex-1]+ldfile.Adjust.Srcoffset[i-1];
           tydq_move(Pbyte(changeptr+4)^,Pbyte(changeptr)^,
           tempfinal.SecSize[tempindex-1]-ldfile.Adjust.Srcoffset[i-1]-4);
           dec(tempfinal.SecSize[tempindex-1],4); movesecoffset:=4; movesecoffset2:=0;
           ldfile.Adjust.Formula[i-1].mask:=elf_riscv_i_type;
          end;
         tydq_reallocMem(tempfinal.SecContent[tempindex-1],tempfinal.SecSize[tempindex-1]);
         m:=1; tempindex3:=0; tempindex4:=0;
         while(m<=tempfinal.SecCount-1) do
          begin
           n:=1;
           while(n<=tempfinal.SecCount)do
            begin
             if(tempfinal.SecIndex[n-1]=m) then break;
             inc(n);
            end;
           if(n<=tempfinal.SecCount) then tempindex3:=n else tempindex3:=0;
           if(tempindex3=0) then break;
           n:=1;
           while(n<=tempfinal.SecCount)do
            begin
             if(tempfinal.SecIndex[n-1]=m+1) then break;
             inc(n);
            end;
           if(n<=tempfinal.SecCount) then tempindex4:=n else tempindex4:=0;
           if(tempindex4=0) then break;
           if(tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1]<=
             tempfinal.SecAddress[tempindex4-1]) then
              begin
               if(tempfinal.SecName[tempindex4-1]='.text')
               or(tempfinal.SecName[tempindex4-1]='.rodata')
               or(tempfinal.SecName[tempindex4-1]='.data') then
                begin
                 if(ld_align(tempfinal.SecAddress[tempindex4-1],align)-
                 (tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1])>=align) then
                  begin
                   ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                   DynWordArray(tempfinal.SecIndex),
                   tempfinal.SecIndex[tempindex4-1],-align);
                  end;
                end
               else if(tempfinal.SecName[tempindex3-1]<>'.bss') and
               (tempfinal.SecName[tempindex3-1]<>'.tbss') then
                begin
                 if(tempfinal.SecAddress[tempindex4-1]-
                 (tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1])>=ldbit shl 2) then
                  begin
                   ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                   DynWordArray(tempfinal.SecIndex),
                   tempfinal.SecIndex[tempindex4-1],-ldbit shl 2);
                  end;
                end
               else
                begin
                 if(tempfinal.SecAddress[tempindex4-1]-tempfinal.SecAddress[tempindex3-1]>=ldbit shl 2) then
                  begin
                   ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                   DynwordArray(tempfinal.SecIndex),
                   tempfinal.SecIndex[tempindex4-1],-ldbit shl 2);
                  end;
                end;
              end
             else
              begin
               if(tempfinal.SecName[tempindex4-1]='.text')
               or(tempfinal.SecName[tempindex4-1]='.rodata')
               or(tempfinal.SecName[tempindex4-1]='.data') then
                begin
                 if(ld_align(tempfinal.SecAddress[tempindex4-1],align)-
                 (tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1])<=0) then
                  begin
                   ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                   DynWordArray(tempfinal.SecIndex),
                   tempfinal.SecIndex[tempindex4-1],align);
                  end;
                end
               else if(tempfinal.SecName[tempindex3-1]<>'.bss') and
               (tempfinal.SecName[tempindex3-1]<>'.tbss') then
                begin
                 if(tempfinal.SecAddress[tempindex4-1]-
                 (tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1])<=0) then
                  begin
                   ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                   DynWordArray(tempfinal.SecIndex),
                   tempfinal.SecIndex[tempindex4-1],ldbit shl 2);
                  end;
                end
               else
                begin
                 if(tempfinal.SecAddress[tempindex4-1]-
                 (tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1])<0) then
                  begin
                   ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                   DynWordArray(tempfinal.SecIndex),
                   tempfinal.SecIndex[tempindex4-1],ldbit shl 2);
                  end;
                end;
              end;
           inc(m);
          end;
         for m:=1 to ldfile.Adjust.Count do
          begin
           if(ldfile.Adjust.AdjustType[m-1]=0) then continue;
           if(ldfile.Adjust.SrcIndex[i-1]=ldfile.Adjust.SrcIndex[m-1]) then
            begin
             if(ldfile.Adjust.SrcOffset[i-1]+movesecoffset2<=ldfile.Adjust.SrcOffset[m-1]) then
              begin
               dec(ldfile.Adjust.SrcOffset[m-1],movesecoffset);
              end;
            end;
           if(ldfile.Adjust.SrcIndex[i-1]=ldfile.Adjust.DestIndex[m-1]) then
            begin
             if(ldfile.Adjust.SrcOffset[i-1]+movesecoffset2<=ldfile.Adjust.DestOffset[m-1]) then
              begin
               dec(ldfile.Adjust.DestOffset[m-1],movesecoffset);
              end;
            end;
          end;
         for m:=1 to ldfile.SymTable.SymbolCount do
          begin
           if(ldfile.Adjust.AdjustType[m-1]=0) then continue;
           if(ldfile.Adjust.SrcIndex[i-1]=ldfile.SymTable.SymbolIndex[m-1]) then
            begin
             if(ldfile.Adjust.SrcOffset[i-1]+movesecoffset2<=ldfile.SymTable.SymbolValue[m-1]) then
              begin
               dec(ldfile.SymTable.SymbolValue[m-1],movesecoffset);
              end
             else if(ldfile.Adjust.SrcOffset[i-1]=ldfile.SymTable.SymbolValue[m-1]) then
              begin
               dec(ldfile.SymTable.SymbolSize[m-1],movesecoffset);
              end;
            end;
          end;
         if(ldfile.Adjust.SrcIndex[i-1]=ldfile.EntryIndex) and
         (ldfile.Adjust.SrcOffset[i-1]+movesecoffset<=ldfile.EntryOffset) then
          begin
           dec(ldfile.EntryOffset,movesecoffset);
          end;
        end;
      end
     else if(ldfile.Adjust.Formula[i-1].mask=elf_riscv_u_type) then
      begin
       if(ld_formula_check_got(ldfile.Adjust.Formula[i-1])) then
        begin
         tempresult:=(tempfinal.SecAddress[gotindex-1]
         +writepos[1]*ldbit shl 2+ldfile.Adjust.Addend[i-1]-startoffset);
        end
       else
        begin
         tempresult:=(endoffset+ldfile.Adjust.Addend[i-1]-startoffset);
        end;
       movesecoffset:=0;
       if(ld_riscv_check_ld(Pdword(changeptr+4)^)) and
       (i<ldfile.Adjust.Count) and (ldfile.Adjust.SrcOffset[i]-ldfile.Adjust.SrcOffset[i-1]=4)
       and(ldfile.Adjust.Formula[i].mask=elf_riscv_i_type) then
        begin
         tempresult:=0; ldfile.Adjust.Formula[i-1].mask:=elf_riscv_u_i_type;
         ldfile.Adjust.AdjustType[i]:=0;
        end
       else if(ld_riscv_check_jalr(Pdword(changeptr+4)^)) and
       (i<ldfile.Adjust.Count) and (ldfile.Adjust.SrcOffset[i]-ldfile.Adjust.SrcOffset[i-1]=4)
       and(ldfile.Adjust.Formula[i].mask=elf_riscv_i_type) then
        begin
         tempresult:=0; ldfile.Adjust.Formula[i-1].mask:=elf_riscv_u_i_type;
         ldfile.Adjust.AdjustType[i]:=0;
        end;
       if(tempresult shr 12=0) and (tempresult and $FFF=0)
       and (ld_riscv_check_ld(Pdword(changeptr+4)^)=false) then
        begin
         ldfile.Adjust.AdjustType[i-1]:=0;
         changeptr:=tempfinal.SecContent[tempindex-1]+ldfile.Adjust.Srcoffset[i-1];
         tydq_move(Pbyte(changeptr+4)^,Pbyte(changeptr)^,
         tempfinal.SecSize[tempindex-1]-ldfile.Adjust.Srcoffset[i-1]-4);
         dec(tempfinal.SecSize[tempindex-1],4); movesecoffset:=4;
         tydq_reallocMem(tempfinal.SecContent[tempindex-1],tempfinal.SecSize[tempindex-1]);
         m:=1; tempindex3:=0; tempindex4:=0;
         while(m<=tempfinal.SecCount-1) do
          begin
           n:=1;
           while(n<=tempfinal.SecCount)do
            begin
             if(tempfinal.SecIndex[n-1]=m) then break;
             inc(n);
            end;
           if(n<=tempfinal.SecCount) then tempindex3:=n else tempindex3:=0;
           if(tempindex3=0) then break;
           n:=1;
           while(n<=tempfinal.SecCount)do
            begin
             if(tempfinal.SecIndex[n-1]=m+1) then break;
             inc(n);
            end;
           if(n<=tempfinal.SecCount) then tempindex4:=n else tempindex4:=0;
           if(tempindex4=0) then break;
           if(tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1]<=
           tempfinal.SecAddress[tempindex4-1]) then
              begin
               if(tempfinal.SecName[tempindex4-1]='.text')
               or(tempfinal.SecName[tempindex4-1]='.rodata')
               or(tempfinal.SecName[tempindex4-1]='.data') then
                begin
                 if(ld_align(tempfinal.SecAddress[tempindex4-1],align)-
                 (tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1])>=align) then
                  begin
                   ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                   DynWordArray(tempfinal.SecIndex),
                   tempfinal.SecIndex[tempindex4-1],-align);
                  end;
                end
               else if(tempfinal.SecName[tempindex3-1]<>'.bss') and
               (tempfinal.SecName[tempindex3-1]<>'.tbss') then
                begin
                 if(tempfinal.SecAddress[tempindex4-1]-
                 (tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1])>=ldbit shl 2) then
                  begin
                   ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                   DynWordArray(tempfinal.SecIndex),
                   tempfinal.SecIndex[tempindex4-1],-ldbit shl 2);
                  end;
                end
               else
                begin
                 if(tempfinal.SecAddress[tempindex4-1]-tempfinal.SecAddress[tempindex3-1]>=ldbit shl 2) then
                  begin
                   ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                   DynwordArray(tempfinal.SecIndex),
                   tempfinal.SecIndex[tempindex4-1],-ldbit shl 2);
                  end;
                end;
              end
             else
              begin
               if(tempfinal.SecName[tempindex4-1]='.text')
               or(tempfinal.SecName[tempindex4-1]='.rodata')
               or(tempfinal.SecName[tempindex4-1]='.data') then
                begin
                 if(ld_align(tempfinal.SecAddress[tempindex4-1],align)-
                 (tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1])<=0) then
                  begin
                   ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                   DynWordArray(tempfinal.SecIndex),
                   tempfinal.SecIndex[tempindex4-1],align);
                  end;
                end
               else if(tempfinal.SecName[tempindex3-1]<>'.bss') and
               (tempfinal.SecName[tempindex3-1]<>'.tbss') then
                begin
                 if(tempfinal.SecAddress[tempindex4-1]-
                 (tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1])<=0) then
                  begin
                   ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                   DynWordArray(tempfinal.SecIndex),
                   tempfinal.SecIndex[tempindex4-1],ldbit shl 2);
                  end;
                end
               else
                begin
                 if(tempfinal.SecAddress[tempindex4-1]-
                 (tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1])<0) then
                  begin
                   ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                   DynWordArray(tempfinal.SecIndex),
                   tempfinal.SecIndex[tempindex4-1],ldbit shl 2);
                  end;
                end;
              end;
           inc(m);
          end;
         for m:=1 to ldfile.Adjust.Count do
          begin
           if(ldfile.Adjust.AdjustType[m-1]=0) then continue;
           if(ldfile.Adjust.SrcIndex[i-1]=ldfile.Adjust.SrcIndex[m-1]) then
            begin
             if(ldfile.Adjust.SrcOffset[i-1]<=ldfile.Adjust.SrcOffset[m-1]) then
              begin
               dec(ldfile.Adjust.SrcOffset[m-1],movesecoffset);
              end;
            end;
           if(ldfile.Adjust.SrcIndex[i-1]=ldfile.Adjust.DestIndex[m-1]) then
            begin
             if(ldfile.Adjust.SrcOffset[i-1]<=ldfile.Adjust.DestOffset[m-1]) then
              begin
               dec(ldfile.Adjust.DestOffset[m-1],movesecoffset);
              end;
            end;
          end;
         for m:=1 to ldfile.SymTable.SymbolCount do
          begin
           if(ldfile.Adjust.AdjustType[m-1]=0) then continue;
           if(ldfile.Adjust.SrcIndex[i-1]=ldfile.SymTable.SymbolIndex[m-1]) then
            begin
             if(ldfile.Adjust.SrcOffset[i-1]<=ldfile.SymTable.SymbolValue[m-1]) then
              begin
               dec(ldfile.SymTable.SymbolValue[m-1],movesecoffset);
              end
             else if(ldfile.Adjust.SrcOffset[i-1]=ldfile.SymTable.SymbolValue[m-1]) then
              begin
               dec(ldfile.SymTable.SymbolSize[m-1],movesecoffset);
              end;
            end;
          end;
         ldfile.Adjust.Formula[i-1].mask:=elf_riscv_i_type;
         if(ldfile.Adjust.SrcIndex[i-1]=ldfile.EntryIndex) and
         (ldfile.Adjust.SrcOffset[i-1]<=ldfile.EntryOffset) then
          begin
           dec(ldfile.EntryOffset,movesecoffset);
          end
        end
       else if(tempresult and $FFF<>0) then
        begin
         if(Abs(tempresult and $FFF)>2047) and (tempresult>=0) then
          begin
           tempresult:=tempresult+$1000;
           movesecoffset:=4;
           inc(tempfinal.SecSize[tempindex-1],4);
           tydq_reallocMem(tempfinal.SecContent[tempindex-1],tempfinal.SecSize[tempindex-1]);
           changeptr:=tempfinal.SecContent[tempindex-1]+ldfile.Adjust.SrcOffset[i-1];
           tydq_move(Pbyte(changeptr+4)^,Pbyte(changeptr+8)^,
           tempfinal.SecSize[tempindex-1]-ldfile.Adjust.Srcoffset[i-1]-8);
           Pdword(changeptr+4)^:=ld_riscv_stub_addi(
           Pld_riscv_u_type(changeptr)^.DestinationRegister,
           Pld_riscv_u_type(changeptr)^.DestinationRegister,-($1000-tempresult and $FFF));
          end
         else if(Abs(tempresult and $FFF)>2047) and (tempresult<0) then
          begin
           tempresult:=tempresult-$1000;
           movesecoffset:=4;
           inc(tempfinal.SecSize[tempindex-1],4);
           tydq_reallocMem(tempfinal.SecContent[tempindex-1],tempfinal.SecSize[tempindex-1]);
           changeptr:=tempfinal.SecContent[tempindex-1]+ldfile.Adjust.SrcOffset[i-1];
           tydq_move(Pbyte(changeptr+4)^,Pbyte(changeptr+8)^,
           tempfinal.SecSize[tempindex-1]-ldfile.Adjust.Srcoffset[i-1]-8);
           Pdword(changeptr+4)^:=ld_riscv_stub_addi(
           Pld_riscv_u_type(changeptr)^.DestinationRegister,
           Pld_riscv_u_type(changeptr)^.DestinationRegister,($1000-tempresult and $FFF));
          end
         else
          begin
           movesecoffset:=4;
           inc(tempfinal.SecSize[tempindex-1],4);
           tydq_reallocMem(tempfinal.SecContent[tempindex-1],tempfinal.SecSize[tempindex-1]);
           changeptr:=tempfinal.SecContent[tempindex-1]+ldfile.Adjust.SrcOffset[i-1];
           tydq_move(Pbyte(changeptr+4)^,Pbyte(changeptr+8)^,
           tempfinal.SecSize[tempindex-1]-ldfile.Adjust.Srcoffset[i-1]-12);
           if(tempresult>0) then
            begin
             Pdword(changeptr+4)^:=ld_riscv_stub_addi(
             Pld_riscv_u_type(changeptr)^.DestinationRegister,
             Pld_riscv_u_type(changeptr)^.DestinationRegister,tempresult and $FFF);
            end
           else
            begin
             Pdword(changeptr+4)^:=ld_riscv_stub_addi(
             Pld_riscv_u_type(changeptr)^.DestinationRegister,
             Pld_riscv_u_type(changeptr)^.DestinationRegister,-(tempresult and $FFF));
            end;
          end;
         m:=1; tempindex3:=0; tempindex4:=0;
         while(m<=tempfinal.SecCount-1) do
          begin
           n:=1;
           while(n<=tempfinal.SecCount)do
            begin
             if(tempfinal.SecIndex[n-1]=m) then break;
             inc(n);
            end;
           if(n<=tempfinal.SecCount) then tempindex3:=n else tempindex3:=0;
           if(tempindex3=0) then break;
           n:=1;
           while(n<=tempfinal.SecCount)do
            begin
             if(tempfinal.SecIndex[n-1]=m+1) then break;
             inc(n);
            end;
           if(n<=tempfinal.SecCount) then tempindex4:=n else tempindex4:=0;
           if(tempindex4=0) then break;
           if(tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1]<=
           tempfinal.SecAddress[tempindex4-1]) then
            begin
             if(tempfinal.SecName[tempindex4-1]='.text')
             or(tempfinal.SecName[tempindex4-1]='.rodata')
             or(tempfinal.SecName[tempindex4-1]='.data') then
              begin
               if(ld_align(tempfinal.SecAddress[tempindex4-1],align)-
               (tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1])>=align) then
                begin
                 ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                 DynWordArray(tempfinal.SecIndex),
                 tempfinal.SecIndex[tempindex4-1],-align);
                end;
              end
             else if(tempfinal.SecName[tempindex3-1]<>'.bss') and
             (tempfinal.SecName[tempindex3-1]<>'.tbss') then
              begin
               if(tempfinal.SecAddress[tempindex4-1]-
               (tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1])>=ldbit shl 2) then
                begin
                 ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                 DynWordArray(tempfinal.SecIndex),
                 tempfinal.SecIndex[tempindex4-1],-ldbit shl 2);
                end;
              end
            else
             begin
              if(tempfinal.SecAddress[tempindex4-1]-tempfinal.SecAddress[tempindex3-1]>=ldbit shl 2) then
               begin
                ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                DynwordArray(tempfinal.SecIndex),
                tempfinal.SecIndex[tempindex4-1],-ldbit shl 2);
                end;
              end;
             end
            else
             begin
              if(tempfinal.SecName[tempindex4-1]='.text')
              or(tempfinal.SecName[tempindex4-1]='.rodata')
              or(tempfinal.SecName[tempindex4-1]='.data') then
               begin
                if(ld_align(tempfinal.SecAddress[tempindex4-1],align)-
                (tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1])<=0) then
                 begin
                  ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                  DynWordArray(tempfinal.SecIndex),
                  tempfinal.SecIndex[tempindex4-1],align);
                 end;
               end
              else if(tempfinal.SecName[tempindex3-1]<>'.bss') and
              (tempfinal.SecName[tempindex3-1]<>'.tbss') then
               begin
                if(tempfinal.SecAddress[tempindex4-1]-
                (tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1])<=0) then
                 begin
                  ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                  DynWordArray(tempfinal.SecIndex),
                  tempfinal.SecIndex[tempindex4-1],ldbit shl 2);
                 end;
               end
              else
               begin
                if(tempfinal.SecAddress[tempindex4-1]-
                (tempfinal.SecAddress[tempindex3-1]+tempfinal.SecSize[tempindex3-1])<0) then
                 begin
                  ld_calculate_behind(DynQwordArray(tempfinal.SecAddress),
                  DynWordArray(tempfinal.SecIndex),
                  tempfinal.SecIndex[tempindex4-1],ldbit shl 2);
                 end;
               end;
             end;
           inc(m);
          end;
         for m:=1 to ldfile.Adjust.Count do
          begin
           if(ldfile.Adjust.AdjustType[m-1]=0) then continue;
           if(ldfile.Adjust.SrcIndex[i-1]=ldfile.Adjust.SrcIndex[m-1]) then
            begin
             if(ldfile.Adjust.SrcOffset[i-1]+4<=ldfile.Adjust.SrcOffset[m-1]) then
              begin
               inc(ldfile.Adjust.SrcOffset[m-1],movesecoffset);
              end;
            end;
           if(ldfile.Adjust.SrcIndex[i-1]=ldfile.Adjust.DestIndex[m-1]) then
            begin
             if(ldfile.Adjust.SrcOffset[i-1]+4<=ldfile.Adjust.DestOffset[m-1]) then
              begin
               inc(ldfile.Adjust.DestOffset[m-1],movesecoffset);
              end;
            end;
          end;
         for m:=1 to ldfile.SymTable.SymbolCount do
          begin
           if(ldfile.Adjust.AdjustType[m-1]=0) then continue;
           if(ldfile.Adjust.SrcIndex[i-1]=ldfile.SymTable.SymbolIndex[m-1]) then
            begin
             if(ldfile.Adjust.SrcOffset[i-1]+4<=ldfile.SymTable.SymbolValue[m-1]) then
              begin
               inc(ldfile.SymTable.SymbolValue[m-1],movesecoffset);
              end
             else if(ldfile.Adjust.SrcOffset[i-1]=ldfile.SymTable.SymbolValue[m-1]) then
              begin
               inc(ldfile.SymTable.SymbolSize[m-1],movesecoffset);
              end;
            end;
          end;
         ldfile.Adjust.Formula[i-1].mask:=elf_riscv_u_i_type;
         if(ldfile.Adjust.SrcIndex[i-1]=ldfile.EntryIndex) and
         (ldfile.Adjust.SrcOffset[i-1]+4<=ldfile.EntryOffset) then
          begin
           inc(ldfile.EntryOffset,movesecoffset);
          end;
        end;
      end;
     m:=1;
     while(m<=ldfile.Adjust.Count) do
      begin
       if(ldfile.Adjust.Formula[i-1].mask=elf_riscv_j_type) or
       (ldfile.Adjust.Formula[i-1].mask=elf_riscv_b_type) or
       (ldfile.Adjust.Formula[i-1].mask=elf_riscv_cb_type) or
       (ldfile.Adjust.Formula[i-1].mask=elf_riscv_cj_type) or
       ((ldfile.Adjust.Formula[i-1].mask=elf_riscv_i_type) and
       (ld_riscv_check_jalr(Pdword(changeptr)^))) or
       ((ldfile.Adjust.Formula[i-1].mask=elf_riscv_u_i_type) and
       (ld_riscv_check_jalr(Pdword(changeptr+4)^))) then
        begin
         break;
        end;
       if(i=m) then
        begin
         inc(m); continue;
        end;
       if(ldfile.Adjust.DestIndex[i-1]=ldfile.Adjust.SrcIndex[m-1])
       and(ldfile.Adjust.DestOffset[i-1]=ldfile.Adjust.SrcOffset[m-1])
       and(ldfile.Adjust.DestOffset[i-1]<>ldfile.Adjust.DestOffset[m-1])
       and(ldfile.Adjust.AdjustHash[i-1]<>ldfile.Adjust.AdjustHash[m-1])then
        begin
         ldfile.Adjust.DestIndex[i-1]:=ldfile.Adjust.DestIndex[m-1];
         ldfile.Adjust.DestOffset[i-1]:=ldfile.Adjust.DestOffset[m-1];
         ldfile.Adjust.AdjustHash[i-1]:=ldfile.Adjust.AdjustHash[m-1];
         ldfile.Adjust.Addend[i-1]:=Natint(ldfile.Adjust.SrcOffset[i-1])-
         Natint(ldfile.Adjust.SrcOffset[m-1]);
         break;
        end
       else inc(m);
      end;
    end;
  end;
 {Relocate the got and got.plt table}
 for i:=1 to tempfinal.SecCount do
  begin
   if(tempfinal.SecName[i-1]='.got') then tempfinal.SecAddress[GotIndex-1]:=tempfinal.SecAddress[i-1];
  end;
 {Now Relocate the file with adjustment table}
 SetLength(tempfinal.Rela.SymOffset,tempfinal.Rela.SymCount);
 SetLength(tempfinal.Rela.SymAddend,tempfinal.Rela.SymCount);
 SetLength(tempfinal.Rela.SymType,tempfinal.Rela.SymCount);
 tempfinal.Rela.SymCount:=0;
 writepos[1]:=3; startoffset:=0; endoffset:=0;
 movesecoffset:=0; index:=0; offset1:=0;
 for i:=1 to ldfile.Adjust.Count do
  begin
   if(ldfile.Adjust.AdjustType[i-1]=0) then continue;
   index:=ldfile.Adjust.SrcIndex[i-1];
   if(ldfile.SecName[index-1]='.debug_frame') and (debugframe=false) then continue;
   j:=1;
   while(j<=tempfinal.SecCount)do
    begin
     if(ldfile.SecName[index-1]=tempfinal.SecName[j-1]) then break;
     inc(j);
    end;
   if(j>tempfinal.SecCount) then continue;
   startoffset:=tempfinal.SecAddress[j-1]+ldfile.Adjust.SrcOffset[i-1];
   changeptr:=tempfinal.SecContent[j-1]+ldfile.Adjust.Srcoffset[i-1];
   tempindex:=j;
   index:=ldfile.Adjust.DestIndex[i-1];
   if(ldfile.SecName[index-1]='.debug_frame') and (debugframe=false) then continue;
   j:=1;
   while(j<=tempfinal.SecCount)do
    begin
     if(ldfile.SecName[index-1]=tempfinal.SecName[j-1]) then break;
     inc(j);
    end;
   if(j>tempfinal.SecCount) then continue;
   endoffset:=tempfinal.SecAddress[j-1]+ldfile.Adjust.DestOffset[i-1];
   j:=1; isrelative:=false; isgotbase:=false; isgotoffset:=false;
   tempformula:=ldfile.Adjust.Formula[i-1];
   isrelative:=tempformula.isrelative;
   isgotbase:=tempformula.isgotbase;
   isgotoffset:=tempformula.isgotoffset;
   ispaged:=tempformula.ispaged;
   if(isgotbase) or (isgotoffset) then
    begin
     j:=ld_adjust_search_for_index(ldfile.AdjustHashTable,
     DynNatuintArray(ldfile.Adjust.AdjustHash),ldfile.Adjust.AdjustHash[i-1],0,ld_adjust_got);
     if(j<>0) then
      begin
       offset1:=ldfile.AdjustHashTable.AdjustIndex[j-1]; writepos[1]:=2+offset1;
      end
     else
      begin
       offset1:=0; writepos[1]:=0;
      end;
    end;
   if(ldarch=elf_machine_386) or (ldarch=elf_machine_x86_64) then
    begin
     tempresult:=ld_calculate_formula(tempformula,
     ['S='+IntToStr(endoffset),'A='+IntToStr(ldfile.Adjust.Addend[i-1]),'B=0',
     'P='+IntToStr(startoffset),'L='+IntToStr(endoffset),
     'GOT='+IntToStr(tempfinal.SecAddress[GotIndex-1]),
     'G='+IntToStr(writepos[1]*ldbit shl 2)]);
     if((isgotbase) or (isgotoffset)) or (ldfile.Adjust.DestIndex[i-1]=0) then
      begin
       inc(tempfinal.Rela.SymCount);
       tempfinal.Rela.SymOffset[tempfinal.Rela.SymCount-1]:=tempfinal.SecAddress[GotIndex-1]+writepos[1]*ldbit shl 2;
       tempfinal.GotTable[writepos[1]]:=endoffset+ldfile.Adjust.Addend[i-1];
       tempfinal.Rela.SymAddend[tempfinal.Rela.SymCount-1]:=endoffset+ldfile.Adjust.Addend[i-1];
       tempfinal.Rela.SymType[tempfinal.Rela.SymCount-1]:=8;
      end
     else if(isrelative=false) then
      begin
       inc(tempfinal.Rela.SymCount);
       tempfinal.Rela.SymOffset[tempfinal.Rela.SymCount-1]:=startoffset;
       tempfinal.Rela.SymAddend[tempfinal.Rela.SymCount-1]:=endoffset+ldfile.Adjust.Addend[i-1];
       tempfinal.Rela.SymType[tempfinal.Rela.SymCount-1]:=8;
      end;
     if(Natuint(changeptr)=ldfile.Adjust.Srcoffset[i-1]) then continue;
     if(ldfile.Adjust.Formula[i-1].bit=8) then
      begin
       Pshortint(changeptr)^:=shortint(tempresult and $FF);
      end
     else if(ldfile.Adjust.Formula[i-1].bit=16) then
      begin
       Psmallint(changeptr)^:=smallint(tempresult and $FFFF);
      end
     else if(ldfile.Adjust.Formula[i-1].bit=32) then
      begin
       if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_x86_64_got_pc_rel) then
        begin
         case Pbyte(changeptr-1)^ of
         $15:Pword(changeptr-2)^:=$E840;
         $25:Pword(changeptr-2)^:=$E940;
         end;
        end
       else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_x86_64_rex_got_pc_rel) then
        begin
         Pbyte(changeptr-2)^:=$8D;
        end;
       PInteger(changeptr)^:=Integer(tempresult and $FFFFFFFF);
      end
     else if(ldfile.Adjust.Formula[i-1].bit=64) then
      begin
       PInt64(changeptr)^:=tempresult;
      end;
    end
   else if(ldarch=elf_machine_arm) then
    begin
     tempresult:=ld_calculate_formula(tempformula,
     ['S='+IntToStr(endoffset),'A='+IntToStr(ldfile.Adjust.Addend[i-1]),
     'B=0','T='+IntToStr(Byte(ldfile.Adjust.AdjustFunc[i-1])),
     'P='+IntToStr(startoffset),
     'Pa='+IntToStr(startoffset and $FFFFFFFC),
     'PLT='+IntToStr(startoffset),
     'GOT_ORG='+IntToStr(tempfinal.SecAddress[GotIndex-1]),
     'GOT='+IntToStr(tempfinal.SecAddress[GotIndex-1]+writepos[1]*ldbit shl 2)]);
     if(isrelative=false) or ((isgotbase) or (isgotoffset)) or (ldfile.Adjust.DestIndex[i-1]=0) then
      begin
       inc(tempfinal.Rela.SymCount);
       tempfinal.Rela.SymOffset[tempfinal.Rela.SymCount-1]:=tempfinal.SecAddress[GotIndex-1]+writepos[1]*ldbit shl 2;
       tempfinal.GotTable[writepos[1]]:=endoffset+ldfile.Adjust.Addend[i-1];
       tempfinal.Rela.SymAddend[tempfinal.Rela.SymCount-1]:=endoffset+ldfile.Adjust.Addend[i-1];
       tempfinal.Rela.SymType[tempfinal.Rela.SymCount-1]:=elf_reloc_arm_relative;
      end;
     negative:=false;
     if(tempresult<0) then
      begin
       tempresult:=-tempresult; negative:=true;
      end;
     if(tempformula.mask<>0) then tempresult:=tempresult and tempformula.mask;
     if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_arm_pc_relative_13bit_branch) or
     ((ldfile.Adjust.AdjustType[i-1]>=elf_reloc_arm_ldr_str_ldrb_strb_pc_relative_g1)
     and (ldfile.Adjust.AdjustType[i-1]<=elf_reloc_arm_ldr_str_pc_relative_g2))
     or ((ldfile.Adjust.AdjustType[i-1]>=elf_reloc_arm_program_base_relative_ldr_str_ldrb_strb_g0)
     and (ldfile.Adjust.AdjustType[i-1]<=elf_reloc_arm_program_base_relative_ldrs_g2)) then
      begin
       d1:=0;
       if(negative=false) then d1:=1 shl 23;
       d1:=d1 or tempresult;
       d2:=1 shl 23+$FFF; d2:=Pdword(changeptr)^ and (not d2);
       d3:=d1+d2;
       Pdword(changeptr)^:=d3;
      end
     else if((ldfile.Adjust.AdjustType[i-1]>=elf_reloc_arm_ldc_stc_pc_relative_g0) and
     (ldfile.Adjust.AdjustType[i-1]<=elf_reloc_arm_ldc_stc_pc_relative_g2))
     or((ldfile.Adjust.AdjustType[i-1]>=elf_reloc_arm_ldc_base_relative_g0) and
     (ldfile.Adjust.AdjustType[i-1]<=elf_reloc_arm_ldc_base_relative_g2)) then
      begin
       d1:=0;
       if(negative=false) then d1:=1 shl 23;
       d1:=d1 or tempresult;
       d2:=1 shl 23+$FFF; d2:=Pdword(changeptr)^ and (not d2);
       d3:=d1+d2;
       Pdword(changeptr)^:=d3;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_arm_thumb_absolute_5bit) then
      begin
       d1:=(tempresult shr 2) and $7C0;
       d2:=Pdword(changeptr)^ and (not $000007C0);
       d3:=d1+d2;
       Pdword(changeptr)^:=d3;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_arm_thumb_pc_8bit) then
      begin
       d1:=(tempresult shr 2) and $FF;
       d2:=Pdword(changeptr)^ and (not $000000FF);
       d3:=d1+d2;
       Pdword(changeptr)^:=d3;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_arm_thumb_pc_relative_6bit_b) then
      begin
       d1:=(tempresult shr 6) and 1 shl 9+(tempresult shr 1) and $1F;
       d2:=Pdword(changeptr)^ and (not $000002FF);
       d3:=d1+d2;
       Pdword(changeptr)^:=d3;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_arm_thumb_pc_11bit) then
      begin
       d1:=(tempresult shr 1) and $3FF;
       d2:=Pdword(changeptr)^ and (not $000003FF);
       d3:=d1+d2;
       Pdword(changeptr)^:=d3;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_arm_thumb_pc_9bit) then
      begin
       d1:=(tempresult shr 1) and $FF;
       d2:=Pdword(changeptr)^ and (not $000000FF);
       d3:=d1+d2;
       Pdword(changeptr)^:=d3;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_arm_thumb_alu_abs_g0_no_check) then
      begin
       d1:=tempresult and $FF;
       d2:=Pdword(changeptr)^ and (not $000000FF);
       d3:=d1+d2;
       Pdword(changeptr)^:=d3;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_arm_thumb_alu_abs_g1_no_check) then
      begin
       d1:=(tempresult shr 8) and $FF;
       d2:=Pdword(changeptr)^ and (not $000000FF);
       d3:=d1+d2;
       Pdword(changeptr)^:=d3;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_arm_thumb_alu_abs_g2_no_check) then
      begin
       d1:=(tempresult shr 16) and $FF;
       d2:=Pdword(changeptr)^ and (not $000000FF);
       d3:=d1+d2;
       Pdword(changeptr)^:=d3;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_arm_thumb_alu_abs_g3) then
      begin
       d1:=(tempresult shr 24) and $FF;
       d2:=Pdword(changeptr)^ and (not $000000FF);
       d3:=d1+d2;
       Pdword(changeptr)^:=d3;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_arm_thumb_pc_22bit) then
      begin
       d1:=tempresult and $003FFFFF;
       d2:=Pdword(changeptr)^ and (not $003FFFFF);
       d3:=d1+d2;
       Pdword(changeptr)^:=d3;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_arm_thumb_pc_relative_24bit) then
      begin
       d2:=tempresult and $7FF;
       d3:=tempresult shr 11 and $3FF;
       d2:=d2+d3 shl 16;
       d4:=Pdword(changeptr)^ and (not ($000003FF shl 16+$000007FF));
       d4:=d4+d2;
       Pdword(changeptr)^:=d4;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_arm_thumb_movw_absolute)
     or(ldfile.Adjust.AdjustType[i-1]=elf_reloc_arm_thumb_movw_pc_relative)
     or(ldfile.Adjust.AdjustType[i-1]=elf_reloc_arm_thumb_movw_base_relative_no_check)
     or(ldfile.Adjust.AdjustType[i-1]=elf_reloc_arm_thumb_movw_base_relative) then
      begin
       d1:=tempresult and $FF;
       d2:=tempresult shr 12;
       d3:=tempresult shr 8 and $7;
       d4:=tempresult shr 11 and $1;
       d5:=Pdword(changeptr)^ and (not ($000000FF+$00000007 shl 12+$00000001 shl 26+$0000000F shl 16));
       d6:=d5+d1+d2 shl 16+d4 shl 26+d3 shl 12;
       Pdword(changeptr)^:=d6;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_arm_thumb_movt_absolute)
     or(ldfile.Adjust.AdjustType[i-1]=elf_reloc_arm_thumb_movt_pc_relative)
     or(ldfile.Adjust.AdjustType[i-1]=elf_reloc_arm_thumb_movt_base_relative) then
      begin
       d1:=(tempresult shr 16) and $FF;
       d2:=tempresult shr 28;
       d3:=tempresult shr 24 and $7;
       d4:=tempresult shr 27 and $1;
       d5:=Pdword(changeptr)^ and (not ($000000FF+$00000007 shl 12+$00000001 shl 26+$0000000F shl 16));
       d6:=d5+d1+d2 shl 16+d4 shl 26+d3 shl 12;
       Pdword(changeptr)^:=d6;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_arm_thumb_pc_relative_20bit_b) then
      begin
       d1:=tempresult and $7FF;
       d2:=tempresult shr 11 and $3F;
       d2:=d2 shl 16+d1;
       d3:=Pdword(changeptr)^ and (not ($000007FF+$0000003F shl 16));
       d3:=d3+d2;
       Pdword(changeptr)^:=d3;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_arm_thumb_alu_pc_relative_bit11_0) then
      begin
       d1:=tempresult shr 11;
       d2:=tempresult shr 8 and $7;
       d3:=tempresult and $FF;
       d4:=d1 shl 26+d2 shl 12+d3;
       d5:=Pdword(changeptr)^ and (not (1 shl 26+$7 shl 12+$FF));
       d5:=d5+d4;
       Pdword(changeptr)^:=d5;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_arm_thumb_pc_12bit) then
      begin
       d1:=0;
       if(negative=false) then d1:=1 shl 23;
       d1:=d1 or tempresult;
       d2:=1 shl 23+$FFF; d2:=Pdword(changeptr)^ and (not d2);
       d1:=d1+d2;
       Pdword(changeptr)^:=d1;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_arm_thumb_got_entry_relative_to_got_origin) then
      begin
       d1:=Pdword(changeptr)^ and (not (1 shl 23+$FFF));
       d1:=d1+tempresult;
       Pdword(changeptr)^:=d1;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_arm_thumb_bf16) then
      begin
       d1:=tempresult shr 2 and $000003FF;
       d2:=tempresult shr 1 and 1;
       d3:=tempresult shr 12;
       d4:=d1 shl 1+d2 shl 11+d3 shl 16;
       d2:=Pdword(changeptr)^ and (not ($000003FF shl 1+$00000001 shl 11+$0000001F shl 16));
       d4:=d4+d2;
       Pdword(changeptr)^:=d4;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_arm_thumb_bf12) then
      begin
       d1:=tempresult shr 2 and $000003FF;
       d2:=tempresult shr 1 and 1;
       d3:=tempresult shr 12;
       d4:=d1 shl 1+d2 shl 11+d3 shl 16;
       d2:=Pdword(changeptr)^ and (not ($000003FF shl 1+$00000001 shl 11+$00000001 shl 16));
       d4:=d4+d2;
       Pdword(changeptr)^:=d4;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_arm_thumb_bf18) then
      begin
       d1:=tempresult shr 2 and $000003FF;
       d2:=tempresult shr 1 and 1;
       d3:=tempresult shr 12;
       d4:=d1 shl 1+d2 shl 11+d3 shl 16;
       d2:=Pdword(changeptr)^ and (not ($000003FF shl 1+$00000001 shl 11+$0000007F shl 16));
       d4:=d4+d2;
       Pdword(changeptr)^:=d4;
      end
     else if(tempformula.mask<>0) then
      begin
       d1:=Pdword(changeptr)^ and (not Dword(tempformula.mask));
       d1:=d1+tempresult;
       Pdword(changeptr)^:=d1;
      end
     else if(tempformula.bit=32) then
      begin
       PInteger(changeptr)^:=tempresult and $FFFFFFFF;
      end
     else if(tempformula.bit=16) then
      begin
       PShortint(changeptr)^:=tempresult and $FFFF;
      end
     else if(tempformula.bit=8) then
      begin
       PSmallint(changeptr)^:=tempresult and $FF;
      end
    end
   else if(ldarch=elf_machine_aarch64) then
    begin
     tempresult:=ld_calculate_formula(tempformula,
     ['S='+IntToStr(endoffset),'A='+IntToStr(ldfile.Adjust.Addend[i-1]),
     'Delta=0','P='+IntToStr(startoffset),
     'GDAT='+IntToStr(writepos[1]*ldbit shl 2),
     'GOT='+IntToStr(tempfinal.SecAddress[GotIndex-1]),
     'G='+IntToStr(tempfinal.SecAddress[GotIndex-1])]);
     if(isrelative=false) or ((isgotbase) or (isgotoffset)) or (ldfile.Adjust.DestIndex[i-1]=0) then
      begin
       inc(tempfinal.Rela.SymCount);
       tempfinal.Rela.SymOffset[tempfinal.Rela.SymCount-1]:=tempfinal.SecAddress[GotIndex-1]+writepos[1]*ldbit shl 2;
       tempfinal.GotTable[writepos[1]]:=endoffset+ldfile.Adjust.Addend[i-1];
       tempfinal.Rela.SymAddend[tempfinal.Rela.SymCount-1]:=endoffset+ldfile.Adjust.Addend[i-1];
       tempfinal.Rela.SymType[tempfinal.Rela.SymCount-1]:=elf_reloc_aarch64_relative;
      end;
     negative:=false;
     if(tempresult<0) then
      begin
       tempresult:=-tempresult; negative:=true;
      end;
     if(tempformula.mask<>0) then tempresult:=tempresult and tempformula.mask;
     if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_movz_imm_bit15_0)
     or(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_movk_imm_bit15_0)
     or(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_pc_rel_movk_imm_bit15_0)
     or(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_got_rel_offset_movk_imm_bit15_0) then
      begin
       d1:=tempresult and $FFFF;
       d2:=Pdword(changeptr)^ and (not ($0000FFFF shl 5));
       d2:=d2+d1 shl 5;
       Pdword(changeptr)^:=d2;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_movz_imm_bit31_16)
     or(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_movk_imm_bit31_16)
     or(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_pc_rel_movk_imm_bit31_16)
     or(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_got_rel_offset_movk_imm_bit31_16)then
      begin
       d1:=(tempresult shr 16) and $FFFF;
       d2:=Pdword(changeptr)^ and (not ($0000FFFF shl 5));
       d2:=d2+d1 shl 5;
       Pdword(changeptr)^:=d2;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_movz_imm_bit47_32)
     or(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_movk_imm_bit47_32)
     or(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_pc_rel_movk_imm_bit47_32)
     or(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_got_rel_offset_movk_imm_bit47_32)then
      begin
       d1:=(tempresult shr 32) and $FFFF;
       d2:=Pdword(changeptr)^ and (not ($0000FFFF shl 5));
       d2:=d2+d1 shl 5;
       Pdword(changeptr)^:=d2;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_movn_z_imm_bit15_0)
     or (ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_pc_rel_movn_z_imm_bit15_0)
     or (ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_got_rel_offset_movn_z_imm_bit15_0)then
      begin
       if(negative=false) then d1:=1 shl 30 else d1:=0;
       d2:=Pdword(changeptr)^ and (not ($0000FFFF shl 5+1 shl 30));
       if(negative=false) then d1:=d1+tempresult and $FFFF else d1:=d1+not Word(tempresult and $FFFF);
       d2:=d2+d1 shl 5;
       Pdword(changeptr)^:=d2;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_movn_z_imm_bit31_16)
     or (ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_pc_rel_movn_z_imm_bit31_16)
     or (ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_got_rel_offset_movn_z_imm_bit31_16)then
      begin
       if(negative=false) then d1:=1 shl 30 else d1:=0;
       d2:=Pdword(changeptr)^ and (not ($0000FFFF shl 5+1 shl 30));
       if(negative=false) then d1:=d1+(tempresult shr 16) and $FFFF else d1:=d1+not Word((tempresult shr 16) and $FFFF);
       d2:=d2+d1 shl 5;
       Pdword(changeptr)^:=d2;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_movn_z_imm_bit47_32)
     or(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_pc_rel_movn_z_imm_bit47_32)
     or (ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_got_rel_offset_movn_z_imm_bit47_32)then
      begin
       if(negative=false) then d1:=1 shl 30 else d1:=0;
       d2:=Pdword(changeptr)^ and (not ($0000FFFF shl 5+1 shl 30));
       if(negative=false) then d1:=d1+(tempresult shr 32) and $FFFF else d1:=d1+not Word((tempresult shr 32) and $FFFF);
       d2:=d2+d1 shl 5;
       Pdword(changeptr)^:=d2;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_pc_rel_movn_z_imm_bit63_48)
     or (ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_got_rel_offset_movn_z_imm_bit63_48) then
      begin
       if(negative=false) then d1:=1 shl 30 else d1:=0;
       d2:=Pdword(changeptr)^ and (not ($0000FFFF shl 5+1 shl 30));
       if(negative=false) then d1:=d1+(tempresult shr 48) and $FFFF else d1:=d1+not Word((tempresult shr 48) and $FFFF);
       d2:=d2+d1 shl 5;
       Pdword(changeptr)^:=d2;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_ldr_literal_pc_rel_low19bit)
     or(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_pc_rel_got_offset) then
      begin
       if(negative) then d1:=ld_calc_comple(-(tempresult shr 2),19,true)
       else d1:=(tempresult shr 2) and $0007FFFF;
       d2:=Pdword(changeptr)^ and (not ($0007FFFF shl 5));
       if(negative) then d2:=d2+d1 shl 5+1 shl 23 else d2:=d2+d1 shl 5;
       Pdword(changeptr)^:=d2;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_adr_pc_rel_low21bit) then
      begin
       if(negative) then d1:=ld_calc_comple(-tempresult,21,true)
       else d1:=tempresult and $001FFFFF;
       d2:=d1 and 3; d3:=(d1 shr 2) and $7FFFF;
       d4:=Pdword(changeptr)^ and (not ($0007FFFF shl 5+$00000003 shl 29));
       d4:=d4+d2 shl 29+d3 shl 5;
       Pdword(changeptr)^:=d4;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_adrp_page_rel_bit32_12)
     or(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_adrp_page_rel_bit32_12_no_check)
     or(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_page_rel_adrp_bit32_12)then
      begin
       if(negative) then d1:=ld_calc_comple(-(tempresult shr 12),21,true)
       else d1:=(tempresult shr 12) and $001FFFFF;
       d2:=d1 and 3; d3:=(d1 shr 2) and $7FFFF;
       d4:=Pdword(changeptr)^ and (not ($0007FFFF shl 5+$00000003 shl 29));
       d4:=d4+d2 shl 29+d3 shl 5;
       Pdword(changeptr)^:=d4;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_add_absolute_low12bit) then
      begin
       d1:=tempresult and $00000FFF;
       d2:=Pdword(changeptr)^ and (not ($00000FFF shl 10));
       d2:=d2+d1 shl 10;
       Pdword(changeptr)^:=d2;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_ld_or_st_absolute_low12bit) then
      begin
       d1:=tempresult and $00000FFF;
       d2:=Pdword(changeptr)^ and (not ($00000FFF shl 10));
       d2:=d2+d1 shl 10;
       Pdword(changeptr)^:=d2;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_add_bit16_imm_bit11_1) then
      begin
       d1:=(tempresult shr 1) and $7FF;
       d2:=Pdword(changeptr)^ and (not ($00000FFF shl 10));
       d2:=d2+d1 shl 11;
       Pdword(changeptr)^:=d2;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_add_bit32_imm_bit11_2) then
      begin
       d1:=(tempresult shr 2) and $3FF;
       d2:=Pdword(changeptr)^ and (not ($000003FF shl 10));
       d2:=d2+d1 shl 12;
       Pdword(changeptr)^:=d2;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_add_bit64_imm_bit11_3) then
      begin
       d1:=(tempresult shr 3) and $1FF;
       d2:=Pdword(changeptr)^ and (not ($00000FFF shl 10));
       d2:=d2+d1 shl 13;
       Pdword(changeptr)^:=d2;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_add_bit128_imm_from_bit11_4) then
      begin
       d1:=(tempresult shr 4) and $7F;
       d2:=Pdword(changeptr)^ and (not ($00000FFF shl 10));
       d2:=d2+d1 shl 10;
       Pdword(changeptr)^:=d2;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_pc_rel_tbz_bit15_2) then
      begin
       d1:=(tempresult shr 2) and $1FFF;
       d2:=Pdword(changeptr)^ and (not ($00003FFF shl 5));
       d2:=d2+d1 shl 5;
       Pdword(changeptr)^:=d2;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_pc_rel_cond_or_br_bit20_2) then
      begin
       if(negative) then d1:=ld_calc_comple(-(tempresult shr 2),19,true)
       else d1:=(tempresult shr 2) and $7FFFF;
       d2:=Pdword(changeptr)^ and (not ($0007FFFF shl 5));
       d2:=d2+d1 shl 5;
       Pdword(changeptr)^:=d2;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_pc_rel_jump_bit27_2) or
     (ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_pc_rel_call_bit27_2)then
      begin
       if(negative) then d1:=ld_calc_comple(-(tempresult shr 2),26,true)
       else d1:=(tempresult shr 2) and $03FFFFFF;
       d2:=Pdword(changeptr)^ and (not $03FFFFFF);
       d2:=d2+d1;
       Pdword(changeptr)^:=d2;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_got_rel_offset_ld_st_imm_bit14_3)
     or(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_got_page_rel_got_offset_ld_st_bit14_3) then
      begin
       d1:=(tempresult shr 3) and $FFF;
       d2:=Pdword(changeptr)^ and (not ($00000FFF shl 10));
       d2:=d2+d1 shl 10;
       Pdword(changeptr)^:=d2;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_dir_got_offset_ld_st_imm_bit11_3) then
      begin
       if(tempresult>$1FF) and (negative=false) then
        begin
         d1:=(tempresult shr 3) and $FFF;
         d2:=Pdword(changeptr)^ and (not ($000001FF shl 12+$00000001 shl 11+$00000001 shl 24));
         d2:=d2+d1 shl 10+1 shl 24;
         Pdword(changeptr)^:=d2;
        end
       else
        begin
         d1:=(tempresult shr 3) and $1FF;
         d2:=Pdword(changeptr)^ and (not ($000001FF shl 12+$00000001 shl 11));
         if(negative) then d2:=d2+d1 shl 12+1 shl 11 else d2:=d2+d1 shl 12;
         Pdword(changeptr)^:=d2;
        end;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_got_relative_64bit) then
      begin
       PInt64(changeptr)^:=tempresult;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_got_relative_32bit)
     or(ldfile.Adjust.AdjustType[i-1]=elf_reloc_aarch64_pc_relative_got_offset32) then
      begin
       PInteger(changeptr)^:=tempresult;
      end
     else if(tempformula.mask<>0) and (tempformula.bit=64) then
      begin
       q1:=Pqword(changeptr)^ and (not tempformula.mask);
       q1:=q1+tempresult;
       Pqword(changeptr)^:=q1;
      end
     else if(tempformula.mask<>0) and (tempformula.bit=32) then
      begin
       d1:=Pdword(changeptr)^ and (not Dword(tempformula.mask));
       d1:=d1+tempresult;
       Pdword(changeptr)^:=d1;
      end
     else if(tempformula.bit=64) then
      begin
       PInt64(changeptr)^:=tempresult;
      end
     else if(tempformula.bit=32) then
      begin
       PInteger(changeptr)^:=Integer(tempresult and $FFFFFFFF);
      end
     else if(tempformula.bit=16) then
      begin
       Pshortint(changeptr)^:=SmallInt(tempresult and $FFFF);
      end
     else if(tempformula.bit=8) then
      begin
       Psmallint(changeptr)^:=Shortint(tempresult and $FF);
      end;
    end
   else if(ldarch=elf_machine_riscv) then
    begin
     if(ldfile.Adjust.Formula[i-1].bit=8) and
     ((ldfile.Adjust.AdjustType[i-1]=elf_reloc_riscv_add_8bit)
     or(ldfile.Adjust.AdjustType[i-1]=elf_reloc_riscv_sub_8bit)) then
      begin
       q1:=Pbyte(changeptr)^;
      end
     else if(ldfile.Adjust.Formula[i-1].bit=16) and
     ((ldfile.Adjust.AdjustType[i-1]=elf_reloc_riscv_add_16bit)
     or(ldfile.Adjust.AdjustType[i-1]=elf_reloc_riscv_sub_16bit)) then
      begin
       q1:=Pword(changeptr)^;
      end
     else if(ldfile.Adjust.Formula[i-1].bit=32) and
     ((ldfile.Adjust.AdjustType[i-1]=elf_reloc_riscv_add_32bit)
     or(ldfile.Adjust.AdjustType[i-1]=elf_reloc_riscv_sub_32bit)) then
      begin
       q1:=Pdword(changeptr)^;
      end
     else if(ldfile.Adjust.Formula[i-1].bit=64) and
     ((ldfile.Adjust.AdjustType[i-1]=elf_reloc_riscv_add_64bit)
     or(ldfile.Adjust.AdjustType[i-1]=elf_reloc_riscv_sub_64bit)) then
      begin
       q1:=Pqword(changeptr)^;
      end;
     tempresult:=ld_calculate_formula(tempformula,
     ['S='+IntToStr(endoffset),'A='+IntToStr(ldfile.Adjust.Addend[i-1]),
      'Delta=0','P='+IntToStr(startoffset),'V='+IntToStr(q1),
      'G='+IntToStr(writepos[1]*ldbit shl 2),
      'GOT='+IntToStr(tempfinal.SecAddress[GotIndex-1])]);
     negative:=false;
     if(tempresult<0) then
      begin
       tempresult:=-tempresult; negative:=true;
      end;
     if(isrelative=false) or ((isgotbase) or (isgotoffset)) or (ldfile.Adjust.DestIndex[i-1]=0) then
      begin
       inc(tempfinal.Rela.SymCount);
       tempfinal.Rela.SymOffset[tempfinal.Rela.SymCount-1]:=tempfinal.SecAddress[GotIndex-1]+writepos[1]*ldbit shl 2;
       tempfinal.GotTable[writepos[1]]:=endoffset+ldfile.Adjust.Addend[i-1];
       tempfinal.Rela.SymAddend[tempfinal.Rela.SymCount-1]:=endoffset+ldfile.Adjust.Addend[i-1];
       tempfinal.Rela.SymType[tempfinal.Rela.SymCount-1]:=elf_reloc_riscv_relative;
      end;
     if(tempformula.mask=0) then
      begin
       if(tempformula.bit=6) then
        begin
         d1:=Pbyte(changeptr)^ and $C0;
         d2:=tempresult and $3F;
         Pbyte(changeptr)^:=d1+d2;
        end
       else if(tempformula.bit=8) then
        begin
         Pbyte(changeptr)^:=tempresult and $FF;
        end
       else if(tempformula.bit=16) then
        begin
         Pword(changeptr)^:=tempresult and $FFFF;
        end
       else if(tempformula.bit=32) then
        begin
         Pdword(changeptr)^:=tempresult and $FFFFFFFF;
        end
       else if(tempformula.bit=64) then
        begin
         Pqword(changeptr)^:=tempresult;
        end;
      end
     else if(tempformula.mask=elf_riscv_b_type) then
      begin
       if(negative) then d1:=ld_calc_comple(-((tempresult shr 1) and $FFF),12,true)
       else d1:=(tempresult shr 1) and $FFF;
       d2:=d1 and $F; d3:=(d1 shr 4) and $3F; d4:=(d1 shr 10) and $1;
       d5:=(d1 shr 11) and $1;
       d6:=Pdword(changeptr)^ and (not ($1F shl 7+$7F shl 25));
       d6:=d6+d2 shl 8+d3 shl 25+d4 shl 7+d5 shl 31;
       Pdword(changeptr)^:=d6;
      end
     else if(tempformula.mask=elf_riscv_cb_type) then
      begin
       if(negative) then d7:=ld_calc_comple(-((tempresult shr 1) and $FF),8,true)
       else d7:=(tempresult shr 1) and $FF;
       d1:=(d7 and $3); d2:=(d7 shr 2) and $3;
       d3:=(d7 shr 4) and $1; d4:=(d7 shr 5) and $3;
       d5:=(d7 shr 7) and $1;
       d6:=Pword(changeptr)^ and (not ($1F shl 2+$7 shl 10));
       d6:=d6+d1 shl 3+d2 shl 10+d3 shl 2+d4 shl 5+d5 shl 12;
       Pword(changeptr)^:=d6;
      end
     else if(tempformula.mask=elf_riscv_cj_type) then
      begin
       if(negative) then d10:=ld_calc_comple(-((tempresult shr 1) and $7FF),11,true) shl 1
       else d10:=tempresult and $FFE;
       d1:=(d10 and $20) shr 5; d2:=(d10 and $E) shr 1;
       d3:=(d10 and $40) shr 7; d4:=(d10 and $20) shr 6;
       d5:=(d10 and $400) shr 10; d6:=(d10 and $300) shr 8;
       d7:=(d10 and $10) shr 4;
       d8:=(d10 and $800) shr 11;
       d9:=Pword(changeptr)^ and (not ($7FF shl 2));
       d9:=d9+d1 shl 2+d2 shl 3+d3 shl 6+d4 shl 7+d5 shl 8+d6 shl 9+d7 shl 11+d8 shl 12;
       Pword(changeptr)^:=d9;
      end
     else if(tempformula.mask=elf_riscv_i_type) then
      begin
       if(negative) then d1:=ld_calc_comple(-(tempresult and $FFF),12,true)
       else d1:=tempresult and $FFF;
       d2:=Pdword(changeptr)^ and $000FFFFF;
       d2:=d2+d1 shl 20; Pdword(changeptr)^:=d2;
      end
     else if(tempformula.mask=elf_riscv_s_type) then
      begin
       if(negative) then d5:=ld_calc_comple((tempresult and $FFF),12,true)
       else d5:=tempresult and $FFF;
       d1:=d5 and $1F; d2:=(d5 shr 5) and $3F;
       d3:=(d5 shr 11) and 1;
       d4:=Pdword(changeptr)^ and (not ($1F shl 7+$7F shl 25));
       d4:=d4+d1 shl 7+d2 shl 25+d3 shl 31; Pdword(changeptr)^:=d4;
      end
     else if(tempformula.mask=elf_riscv_u_type) then
      begin
       if(negative) then d2:=ld_calc_comple(-(tempresult shr 12),20,true)
       else d2:=(tempresult shr 12) and $FFFFF;
       d1:=Pdword(changeptr)^ and $00000FFF;
       d1:=d1+d2 shl 12;
       Pdword(changeptr)^:=d1;
      end
     else if(tempformula.mask=elf_riscv_j_type) then
      begin
       if(negative) then d1:=ld_calc_comple(-((tempresult shr 1) and $FFFFF),20,true)
       else d1:=(tempresult shr 1) and $FFFFF;
       d2:=d1 and $3FF; d3:=(d1 shr 10) and 1; d4:=(d1 shr 11) and $FF;
       d5:=(d1 shr 19) and $1;
       d6:=Pdword(changeptr)^ and $00000FFF;
       d6:=d6+d2 shl 21+d3 shl 20+d4 shl 12+d5 shl 31;
       Pdword(changeptr)^:=d6;
      end
     else if(tempformula.mask=elf_riscv_u_i_type) then
      begin
       if(tempresult and $FFF<=$7FF) then
        begin
         {Former is U Type}
         if(negative) then d2:=ld_calc_comple(-(tempresult shr 12),20,true)
         else d2:=(tempresult shr 12) and $FFFFF;
         d1:=Pdword(changeptr)^ and $00000FFF;
         d1:=d1+d2 shl 12;
         Pdword(changeptr)^:=d1;
         {Latter is I Type}
         if(negative) then d1:=ld_calc_comple(-(tempresult and $FFF),12,true)
         else d1:=tempresult and $FFF;
         d2:=Pdword(changeptr+4)^ and $000FFFFF;
         d2:=d2+d1 shl 20; Pdword(changeptr+4)^:=d2;
        end
       else
        begin
         {Former is U Type}
         if(negative) then d2:=ld_calc_comple(-((tempresult+$1000) shr 12),20,true)
         else d2:=((tempresult+$1000) shr 12) and $FFFFF;
         d1:=Pdword(changeptr)^ and $00000FFF;
         d1:=d1+d2 shl 12;
         Pdword(changeptr)^:=d1;
         {Latter is I Type}
         if(negative=false) then d1:=ld_calc_comple(-(($1000-tempresult) and $FFF),12,true)
         else d1:=($1000-tempresult) and $FFF;
         d2:=Pdword(changeptr+4)^ and $000FFFFF;
         d2:=d2+d1 shl 20; Pdword(changeptr+4)^:=d2;
        end;
      end;
    end
   else if(ldarch=elf_machine_loongarch) then
    begin
     tempresult:=ld_calculate_formula(tempformula,
     ['S='+IntToStr(endoffset),'A='+IntToStr(ldfile.Adjust.Addend[i-1]),
      'PC='+IntToStr(startoffset),'B=0',
      'GP='+IntToStr(tempfinal.SecAddress[GotIndex-1]),'G='+IntToStr(writepos[1]*ldbit shl 2)]);
     negative:=false;
     if(tempresult<0) then
      begin
       tempresult:=-tempresult; negative:=true;
      end;
     if(isrelative=false) or ((isgotbase) or (isgotoffset)) or (ldfile.Adjust.DestIndex[i-1]=0) then
      begin
       inc(tempfinal.Rela.SymCount);
       tempfinal.Rela.SymOffset[tempfinal.Rela.SymCount-1]:=tempfinal.SecAddress[GotIndex-1]+writepos[1]*ldbit shl 2;
       tempfinal.GotTable[writepos[1]]:=endoffset+ldfile.Adjust.Addend[i-1];
       tempfinal.Rela.SymAddend[tempfinal.Rela.SymCount-1]:=endoffset+ldfile.Adjust.Addend[i-1];
       tempfinal.Rela.SymType[tempfinal.Rela.SymCount-1]:=elf_reloc_loongarch_relative;
      end;
     if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_loongarch_add_8bit) or
     (ldfile.Adjust.AdjustType[i-1]=elf_reloc_loongarch_sub_8bit) then
      begin
       Pbyte(changeptr)^:=tempresult and $FF;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_loongarch_add_16bit) or
     (ldfile.Adjust.AdjustType[i-1]=elf_reloc_loongarch_sub_16bit) then
      begin
       Pword(changeptr)^:=tempresult and $FFFF;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_loongarch_add_32bit) or
     (ldfile.Adjust.AdjustType[i-1]=elf_reloc_loongarch_sub_32bit) then
      begin
       Pdword(changeptr)^:=tempresult and $FFFFFFFF;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_loongarch_add_64bit) or
     (ldfile.Adjust.AdjustType[i-1]=elf_reloc_loongarch_sub_64bit) then
      begin
       Pqword(changeptr)^:=tempresult;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_loongarch_b16) then
      begin
       if(negative) then d1:=ld_calc_comple(-(tempresult shr 2),16,true)
       else d1:=(tempresult shr 2) and $FFFF;
       d2:=Pdword(changeptr)^ and (not ($0000FFFF shl 10));
       Pdword(changeptr)^:=d2+d1 shl 10;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_loongarch_b21) then
      begin
       if(negative) then d1:=ld_calc_comple(-(tempresult shr 2),21,true)
       else d1:=(tempresult shr 2) and $1FFFFF;
       d2:=(d1 shr 16) and $1F; d3:=d1 and $FFFF;
       d4:=Pdword(changeptr)^ and (not ($0000FFFF shl 10+$1F));
       Pdword(changeptr)^:=d4+d3 shl 10+d2;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_loongarch_b26) then
      begin
       if(negative) then d1:=ld_calc_comple(-(tempresult shr 2),26,true)
       else d1:=(tempresult shr 2) and $3FFFFFF;
       d2:=(d1 shr 16) and $3FF; d3:=d1 and $FFFF;
       d4:=Pdword(changeptr)^ and (not ($0000FFFF shl 10+$3FF));
       Pdword(changeptr)^:=d4+d3 shl 10+d2;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_loongarch_absolute_high_20bit) then
      begin
       d1:=(tempresult shr 12) and $FFFFF;
       d2:=Pdword(changeptr)^ and (not ($FFFFF shl 5));
       Pdword(changeptr)^:=d2+d1 shl 5;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_loongarch_absolute_low_12bit) then
      begin
       d1:=tempresult and $FFF;
       d2:=Pdword(changeptr)^ and (not ($FFF shl 10));
       Pdword(changeptr)^:=d2+d1 shl 10;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_loongarch_absolute_64bit_low_20bit) then
      begin
       if((tempresult shr 32) and $FFFFF<=$7FFFF) then
        begin
         if(negative) then d1:=ld_calc_comple((tempresult shr 32) and $FFFFF,20)
         else d1:=(tempresult shr 32) and $FFFFF;
         d2:=Pdword(changeptr)^ and (not ($FFFFF shl 5));
         Pdword(changeptr)^:=d2+d1 shl 5;
        end
       else
        begin
         if(negative) then d1:=ld_calc_comple(($100000-tempresult shr 32) and $FFFFF,20)
         else d1:=($100000-tempresult shr 32) and $FFFFF;
         d2:=Pdword(changeptr)^ and (not ($FFFFF shl 5));
         Pdword(changeptr)^:=d2+d1 shl 5;
        end;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_loongarch_absolute_64bit_high_12bit) then
      begin
       if((tempresult shr 32) and $FFF<=$7FF) then
        begin
         if(negative) then d1:=ld_calc_comple(-((tempresult shr 52) and $FFF),12)
         else d1:=(tempresult shr 52) and $FFF;
         d2:=Pdword(changeptr)^ and (not ($FFF shl 10));
         Pdword(changeptr)^:=d2+d1 shl 10;
        end
       else
        begin
         if(negative=false) then d1:=ld_calc_comple(-((tempresult shr 52+$1000) and $FFF),12)
         else d1:=(tempresult shr 52+$1000) and $FFF;
         d2:=Pdword(changeptr)^ and (not ($FFF shl 10));
         Pdword(changeptr)^:=d2+d1 shl 10;
        end;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_loongarch_absolute_pcala_high_20bit) then
      begin
       if(tempresult and $FFF<=$7FF) then
        begin
         if(negative) then d1:=ld_calc_comple(-((tempresult shr 12) and $FFFFF),20,true)
         else d1:=(tempresult shr 12) and $FFFFF;
         d2:=Pdword(changeptr)^ and (not ($FFFFF shl 5));
         Pdword(changeptr)^:=d2+d1 shl 5;
        end
       else
        begin
         if(negative) then d1:=ld_calc_comple(-(((tempresult+$1000) shr 12) and $FFFFF),20,true)
         else d1:=((tempresult+$1000) shr 12) and $FFFFF;
         d2:=Pdword(changeptr)^ and (not ($FFFFF shl 5));
         Pdword(changeptr)^:=d2+d1 shl 5;
        end;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_loongarch_absolute_pcala_low_12bit) then
      begin
       if(tempresult and $FFF<=$7FF) then
        begin
         if(negative) then d1:=ld_calc_comple(-(tempresult and $FFF),12,true)
         else d1:=tempresult and $FFF;
         d2:=Pdword(changeptr)^ and (not ($FFF shl 10));
         Pdword(changeptr)^:=d2+d1 shl 10;
        end
       else
        begin
         if(negative=false) then d1:=ld_calc_comple(-(($1000-tempresult) and $FFF),12,true)
         else d1:=($1000-tempresult) and $FFF;
         d2:=Pdword(changeptr)^ and (not ($FFF shl 10));
         Pdword(changeptr)^:=d2+d1 shl 10;
        end;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_loongarch_absolute_pcala64_low_20bit) then
      begin
       if((tempresult shr 32) and $FFFFF<=$7FFFF) then
        begin
         if(negative) then d1:=ld_calc_comple(-((tempresult shr 32) and $FFFFF),20,true)
         else d1:=(tempresult shr 32) and $FFFFF;
         d2:=Pdword(changeptr)^ and (not ($FFFFF shl 5));
         Pdword(changeptr)^:=d2+d1 shl 5;
        end
       else
        begin
         if(negative=false) then d1:=ld_calc_comple(-(($100000-tempresult shr 32) and $FFFFF),20,true)
         else d1:=($100000-tempresult shr 32) and $FFFFF;
         d2:=Pdword(changeptr)^ and (not ($FFFFF shl 5));
         Pdword(changeptr)^:=d2+d1 shl 5;
        end;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_loongarch_absolute_pcala64_high_12bit) then
      begin
       if((tempresult shr 32) and $FFFFF<=$7FFFF) then
        begin
         if(negative) then d1:=ld_calc_comple(-((tempresult shr 52) and $FFF),12,true)
         else d1:=(tempresult shr 52) and $FFF;
         d2:=Pdword(changeptr)^ and (not ($FFF shl 10));
         Pdword(changeptr)^:=d2+d1 shl 10;
        end
       else
        begin
         if(negative) then d1:=ld_calc_comple(-(($1000+tempresult shr 52) and $FFF),12,true)
         else d1:=($1000+tempresult shr 52) and $FFF;
         d2:=Pdword(changeptr)^ and (not ($FFF shl 10));
         Pdword(changeptr)^:=d2+d1 shl 10;
        end;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_loongarch_got_pc_high_20bit) then
      begin
       if(tempresult and $FFF<=$7FF) then
        begin
         if(negative) then d1:=ld_calc_comple(-((tempresult shr 12) and $FFFFF),20,true)
         else d1:=(tempresult shr 12) and $FFFFF;
         d2:=Pdword(changeptr)^ and (not ($FFFFF shl 5));
         Pdword(changeptr)^:=d2+d1 shl 5;
        end
       else
        begin
         if(negative) then d1:=ld_calc_comple(-(((tempresult+$1000) shr 12) and $FFFFF),20,true)
         else d1:=((tempresult+$1000) shr 12) and $FFFFF;
         d2:=Pdword(changeptr)^ and (not ($FFFFF shl 5));
         Pdword(changeptr)^:=d2+d1 shl 5;
        end;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_loongarch_got_pc_low_12bit) then
      begin
       if(tempresult and $FFF<=$7FF) then
        begin
         if(negative) then d1:=ld_calc_comple(-(tempresult and $FFF),12,true)
         else d1:=tempresult and $FFF;
         d2:=Pdword(changeptr)^ and (not ($FFF shl 10));
         Pdword(changeptr)^:=d2+d1 shl 10;
        end
       else
        begin
         if(negative=false) then d1:=ld_calc_comple(-(($1000-tempresult) and $FFF),12,true)
         else d1:=($1000-tempresult) and $FFF;
         d2:=Pdword(changeptr)^ and (not ($FFF shl 10));
         Pdword(changeptr)^:=d2+d1 shl 10;
        end;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_loongarch_got64_pc_low_20bit) then
      begin
       if((tempresult shr 32) and $FFFFF<=$7FFFF) then
        begin
         if(negative) then d1:=ld_calc_comple(-((tempresult shr 32) and $FFFFF),20,true)
         else d1:=(tempresult shr 32) and $FFFFF;
         d2:=Pdword(changeptr)^ and (not ($FFFFF shl 5));
         Pdword(changeptr)^:=d2+d1 shl 5;
        end
       else
        begin
         if(negative=false) then d1:=ld_calc_comple(-((($100000-tempresult) shr 32) and $FFFFF),20,true)
         else d1:=($100000-tempresult shr 32) and $FFFFF;
         d2:=Pdword(changeptr)^ and (not ($FFFFF shl 5));
         Pdword(changeptr)^:=d2+d1 shl 5;
        end;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_loongarch_got64_pc_high_12bit) then
      begin
       if((tempresult shr 32) and $FFFFF<=$7FFFF) then
        begin
         if(negative) then d1:=ld_calc_comple(-((tempresult shr 52) and $FFF),12,true)
         else d1:=(tempresult shr 52) and $FFF;
         d2:=Pdword(changeptr)^ and (not ($FFF shl 10));
         Pdword(changeptr)^:=d2+d1 shl 5;
        end
       else
        begin
         if(negative) then d1:=ld_calc_comple(-((tempresult shr 52+$1000) and $FFF),12,true)
         else d1:=(tempresult shr 52+$1000) and $FFF;
         d2:=Pdword(changeptr)^ and (not ($FFF shl 10));
         Pdword(changeptr)^:=d2+d1 shl 5;
        end;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_loongarch_got_high_20bit) then
      begin
       if(negative) then d1:=ld_calc_comple(-((tempresult shr 12) and $FFFFF),20,true)
       else d1:=(tempresult shr 12) and $FFFFF;
       d2:=Pdword(changeptr)^ and (not ($FFFFF shl 5));
       Pdword(changeptr)^:=d2+d1 shl 5;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_loongarch_got_low_12bit) then
      begin
       if(negative) then d1:=ld_calc_comple(-(tempresult and $FFF),12,true)
       else d1:=tempresult and $FFF;
       d2:=Pdword(changeptr)^ and (not ($FFF shl 10));
       Pdword(changeptr)^:=d2+d1 shl 10;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_loongarch_got64_low_20bit) then
      begin
       if(negative) then d1:=ld_calc_comple(-((tempresult shr 32) and $FFFFF),20,true)
       else d1:=(tempresult shr 32) and $FFFFF;
       d2:=Pdword(changeptr)^ and (not ($FFFFF shl 5));
       Pdword(changeptr)^:=d2+d1 shl 5;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_loongarch_got64_high_12bit) then
      begin
       if(negative) then d1:=ld_calc_comple(-((tempresult shr 52) and $FFF),12,true)
       else d1:=(tempresult shr 52) and $FFF;
       d2:=Pdword(changeptr)^ and (not ($FFF shl 10));
       Pdword(changeptr)^:=d2+d1 shl 5;
      end
     else if(ldfile.Adjust.AdjustType[i-1]=elf_reloc_loongarch_32_pc_relative) then
      begin
       if(tempresult and $FFF<=$7FF) then
        begin
         if(negative) then d1:=ld_calc_comple(-((tempresult shr 12) and $FFFFF),20,true)
         else d1:=(tempresult shr 12) and $FFFFF;
         d2:=Pdword(changeptr)^ and (not ($FFFFF shl 5));
         Pdword(changeptr)^:=d2+d1 shl 5;
         if(negative) then d1:=ld_calc_comple(-(tempresult and $FFF),12,true)
         else d1:=tempresult and $FFF;
         d2:=Pdword(changeptr+4)^ and (not ($FFF shl 10));
         Pdword(changeptr+4)^:=d2+d1 shl 10;
        end
       else
        begin
         if(negative) then d1:=ld_calc_comple(-(((tempresult+$1000) shr 12) and $FFFFF),20,true)
         else d1:=((tempresult+$1000) shr 12) and $FFFFF;
         d2:=Pdword(changeptr)^ and (not ($FFFFF shl 5));
         Pdword(changeptr)^:=d2+d1 shl 5;
         if(negative) then d1:=ld_calc_comple(-(($1000-tempresult) and $FFF),12,true)
         else d1:=($1000-tempresult) and $FFF;
         d2:=Pdword(changeptr+4)^ and (not ($FFF shl 10));
         Pdword(changeptr+4)^:=d2+d1 shl 10;
        end;
      end;
    end;
  end;
 {Now generate PE relocation table}
 ld_initialize_pe_writer(writer);
 i:=1; j:=1; baserelativeaddress:=0; baseaddresssize:=0;
 SetLength(writer.RelocationTable,0);
 while(i<=tempfinal.Rela.SymCount)do
  begin
   if(baserelativeaddress=0) or
   (tempfinal.Rela.SymOffset[i-1]-baserelativeaddress>=4096) then
    begin
     baserelativeaddress:=tempfinal.Rela.SymOffset[i-1];
     SetLength(writer.RelocationTable,length(writer.RelocationTable)+1);
     writer.RelocationTable[length(writer.RelocationTable)-1].Block.VirtualAddress:=
     baserelativeaddress;
     writer.RelocationTable[length(writer.RelocationTable)-1].Block.SizeOfBlock:=8;
     SetLength(writer.RelocationTable[length(writer.RelocationTable)-1].item,0);
     inc(baseaddresssize,8);
     j:=1;
    end;
   if(j mod (ldbit shl 1)<>0) and
   ((j+ldbit shl 1-1) div (ldbit shl 1)*(ldbit shl 1)<>
   length(writer.RelocationTable[length(writer.RelocationTable)-1].item)) then
    begin
     SetLength(writer.RelocationTable[length(writer.RelocationTable)-1].item,
     (j+ldbit shl 1-1) div (ldbit shl 1)*(ldbit shl 1));
     inc(baseaddresssize,(j+ldbit shl 1-1) div (ldbit shl 1)*(ldbit shl 1)-j);
    end;
   writer.RelocationTable[length(writer.RelocationTable)-1].item[j-1].Offset:=
   tempfinal.Rela.SymOffset[i-1]-baserelativeaddress;
   if(ldbit=1) then
   writer.RelocationTable[length(writer.RelocationTable)-1].item[j-1].RelocationType:=
   coff_image_base_relocation_highlow
   else
   writer.RelocationTable[length(writer.RelocationTable)-1].item[j-1].RelocationType:=
   coff_image_base_relocation_dir64;
   inc(writer.RelocationTable[length(writer.RelocationTable)-1].Block.SizeOfBlock,2);
   inc(j); inc(i);
  end;
 if(tempfinal.Rela.SymCount=0) and (ldbit=1) then
  begin
   SetLength(writer.RelocationTable,length(writer.RelocationTable)+1);
   writer.RelocationTable[length(writer.RelocationTable)-1].Block.VirtualAddress:=
   baserelativeaddress;
   writer.RelocationTable[length(writer.RelocationTable)-1].Block.SizeOfBlock:=12;
   SetLength(writer.RelocationTable[length(writer.RelocationTable)-1].item,2);
   inc(baseaddresssize,12);
  end
 else if(tempfinal.Rela.SymCount=0) and (ldbit=2) then
  begin
   SetLength(writer.RelocationTable,length(writer.RelocationTable)+1);
   writer.RelocationTable[length(writer.RelocationTable)-1].Block.VirtualAddress:=
   baserelativeaddress;
   writer.RelocationTable[length(writer.RelocationTable)-1].Block.SizeOfBlock:=16;
   SetLength(writer.RelocationTable[length(writer.RelocationTable)-1].item,4);
   inc(baseaddresssize,16);
  end;
 {Get the PE Symbol Table Needed Size and generate PE Symbol Table}
 symboltableaddr:=0; symbolstringtableptr:=0;
 if(stripsymbol) then goto label1;
 symbolstringtableptr:=4;
 SetLength(symbolTable,ldfile.SymTable.SymbolCount); i:=1;
 while(i<=ldfile.SymTable.SymbolCount)do
  begin
   index:=ldfile.SymTable.SymbolIndex[i-1]; j:=1;
   while(j<=tempfinal.SecCount)do
    begin
     if(ldfile.SecName[index-1]=tempfinal.SecName[j-1]) then break;
     inc(j);
    end;
   if(j>tempfinal.SecCount) then
    begin
     writeln('ERROR:Symbol Name '+ldfile.SymTable.SymbolName[i-1]+' not related to the EFI File.');
     readln;
     abort;
    end;
   startoffset:=tempfinal.SecAddress[j-1]+ldfile.SymTable.SymbolValue[i-1];
   if(length(ldfile.SymTable.SymbolName[i-1])<=8) then
   symboltable[i-1].Name.Name:=ldfile.SymTable.SymbolName[i-1]
   else
    begin
     symboltable[i-1].Name.Reserved:=0;
     symboltable[i-1].Name.Offset:=symbolstringtableptr;
     inc(symbolstringtableptr,length(ldfile.SymTable.SymbolName[i-1])+1);
    end;
   symboltable[i-1].Address:=startoffset;
   if(tempfinal.SecName[j-1]='.text') then
    begin
     symboltable[i-1].SectionNumber:=1;
    end
   else if(tempfinal.SecName[j-1]='.rodata') and (haverodata=true) then
    begin
     symboltable[i-1].SectionNumber:=2;
    end
   else
    begin
     symboltable[i-1].SectionNumber:=2+Byte(haverodata);
    end;
   if(ldfile.SymTable.SymbolType[i-1]=elf_symbol_type_function) then
   symboltable[i-1].SymbolType:=coff_image_symbol_high_type_function shl 4
   else
   symboltable[i-1].SymbolType:=0;
   symboltable[i-1].StorageClass:=coff_image_symbol_class_function;
   symboltable[i-1].NumberOfAuxSymbols:=0;
   inc(i);
  end;
 {Then generate PE string table for symbol table}
 symbolandstringtablesize:=symbolstringtableptr+
 ldfile.SymTable.SymbolCount*sizeof(coff_symbol_table_item);
 symbolstringtable:=tydq_getmem(symbolstringtableptr-4);
 i:=1; offset1:=1;
 while(i<=ldfile.SymTable.SymbolCount)do
  begin
   j:=1;
   if(length(ldfile.SymTable.SymbolName[i-1])>8) then
    begin
     j:=1;
     while(j<=length(ldfile.SymTable.SymbolName[i-1]))do
      begin
       (symbolstringtable+offset1-1)^:=ldfile.SymTable.SymbolName[i-1][j];
       inc(j); inc(offset1);
      end;
     (symbolstringtable+offset1-1)^:=#0; inc(offset1);
    end;
   inc(i);
  end;
 {Then Get the Symbol Table Address}
 i:=1; offset1:=0;
 symboltableAddr:=ld_align(relocoffset+baseaddresssize,align);
 {Get the Entry Point of PE File}
 label1:
 i:=1; index:=ldfile.EntryIndex;
 while(i<=tempfinal.SecCount)do
  begin
   if(tempfinal.SecName[i-1]=ldfile.SecName[index-1]) then break;
   inc(i);
  end;
 tempfinal.EntryAddress:=tempfinal.SecAddress[i-1]+ldfile.EntryOffset;
 {Initialize the PE Writer}
 writeoffset:=0;
 writer.DosHeader.MagicNumber:='MZ';
 writer.DosHeader.FileAddressOfNewExeHeader:=sizeof(pe_dos_header)+64;
 writer.PeHeader.signature:='PE';
 if(ldbit=1) then
  begin
   if(ldarch=elf_machine_386) then
   writer.PeHeader.ImageHeader.Machine:=pe_image_file_machine_i386
   else if(ldarch=elf_machine_arm) then
   writer.PeHeader.ImageHeader.Machine:=pe_image_file_machine_arm
   else if(ldarch=elf_machine_riscv) then
   writer.PeHeader.ImageHeader.Machine:=pe_image_file_machine_riscv32
   else if(ldarch=elf_machine_loongarch) then
   writer.PeHeader.ImageHeader.Machine:=pe_image_file_machine_loongarch32;
   if(stripsymbol=false) then
    begin
     writer.PeHeader.ImageHeader.NumberOfSymbols:=ldfile.SymTable.SymbolCount;
     writer.PeHeader.ImageHeader.PointerToSymbolTable:=symboltableAddr;
    end
   else
    begin
     writer.PeHeader.ImageHeader.NumberOfSymbols:=0;
     writer.PeHeader.ImageHeader.PointerToSymbolTable:=0;
    end;
   writer.PeHeader.ImageHeader.Characteristics:=pe_image_file_characteristics_executable_image
   or pe_image_file_characteristics_line_number_stripped
   or pe_image_file_characteristics_debug_stripped;
   if(stripsymbol) then
   writer.PeHeader.ImageHeader.Characteristics:=writer.PeHeader.ImageHeader.Characteristics or
   pe_image_file_characteristics_symbol_stripped;
   writer.PeHeader.ImageHeader.NumberOfSections:=3+Byte(haverodata);
   writer.PeHeader.ImageHeader.SizeOfOptionalHeader:=
   sizeof(coff_optional_image_header32)+6*sizeof(pe_data_directory);
   writer.PeHeader.OptionalHeader32.AddressOfEntryPoint:=tempfinal.EntryAddress;
   writer.PeHeader.OptionalHeader32.BaseOfCode:=textoffset;
   writer.PeHeader.OptionalHeader32.BaseOfData:=dataoffset;
   if(rodataoffset<>0) then
    begin
     writer.PeHeader.OptionalHeader32.SizeOfCode:=rodataoffset-textoffset;
     writer.PeHeader.OptionalHeader32.SizeOfInitializedData:=relocoffset-rodataoffset;
     writer.PeHeader.OptionalHeader32.SizeOfUnInitializedData:=0;
    end
   else
    begin
     writer.PeHeader.OptionalHeader32.SizeOfCode:=dataoffset-textoffset;
     writer.PeHeader.OptionalHeader32.SizeOfInitializedData:=relocoffset-dataoffset;
     writer.PeHeader.OptionalHeader32.SizeOfUnInitializedData:=0;
    end;
   writer.PeHeader.OptionalHeader32.MagicNumber:=pe_image_pe32;
   writer.PeHeader.OptionalHeader32.MajorLinkerVersion:=0;
   writer.PeHeader.OptionalHeader32.MinorLinkerVersion:=2;
   writer.PeHeader.OptionalHeader32.MajorImageVersion:=0;
   writer.PeHeader.OptionalHeader32.MinorImageVersion:=2;
   writer.PeHeader.OptionalHeader32.MajorOperatingSystemVersion:=0;
   writer.PeHeader.OptionalHeader32.MinorOperatingSystemVersion:=0;
   writer.PeHeader.OptionalHeader32.MajorSubSystemVersion:=0;
   writer.PeHeader.OptionalHeader32.MinorSubSystemVersion:=0;
   if(format=ld_format_efi_application) then
   writer.PeHeader.OptionalHeader32.SubSystem:=pe_image_subsystem_efi_application
   else if(format=ld_format_efi_boot_driver) then
   writer.PeHeader.OptionalHeader32.SubSystem:=pe_image_subsystem_efi_boot_service_driver
   else if(format=ld_format_efi_application) then
   writer.PeHeader.OptionalHeader32.SubSystem:=pe_image_subsystem_efi_runtime_service_driver
   else if(format=ld_format_efi_boot_driver) then
   writer.PeHeader.OptionalHeader32.SubSystem:=pe_image_subsystem_efi_rom;
   writer.PeHeader.OptionalHeader32.SizeOfHeapCommit:=0;
   writer.PeHeader.OptionalHeader32.SizeOfHeapReserve:=0;
   writer.PeHeader.OptionalHeader32.SizeOfStackCommit:=0;
   writer.PeHeader.OptionalHeader32.SizeOfStackReserve:=0;
   writer.PeHeader.OptionalHeader32.Win32VersionValue:=0;
   writer.PeHeader.OptionalHeader32.ImageBase:=0;
   writer.PeHeader.OptionalHeader32.LoaderFlags:=0;
   writer.PeHeader.OptionalHeader32.CheckSum:=0;
   writer.PeHeader.OptionalHeader32.DLLCharacteristics:=
   pe_image_dll_characteristics_dynamic_base;
   writer.PeHeader.OptionalHeader32.SizeOfHeaders:=
   ld_align(sizeof(writer.DosHeader)+sizeof(writer.DosStub)+
   sizeof(writer.PeHeader.signature)+sizeof(writer.PeHeader.ImageHeader)+
   sizeof(writer.PeHeader.OptionalHeader32)+6*sizeof(pe_data_directory)
   +(3+Byte(haverodata))*sizeof(pe_image_section_header),align);
   writer.PeHeader.OptionalHeader32.SectionAlignment:=align;
   writer.PeHeader.OptionalHeader32.FileAlignment:=align;
   if(stripsymbol=false) then
   writer.PeHeader.OptionalHeader32.SizeOfImage:=
   ld_align(symboltableAddr+symbolandstringtablesize,align)
   else
   writer.PeHeader.OptionalHeader32.SizeOfImage:=
   ld_align(relocoffset+baseaddresssize,align);
   writer.PeHeader.OptionalHeader32.NumberOfRvaAndSizes:=6;
   SetLength(writer.DataHeader,6);
   writer.DataHeader[5].VirtualAddress:=relocoffset;
   writer.DataHeader[5].Size:=baseaddresssize;
   SetLength(writer.SectionHeader,3+Byte(haverodata));
   if(haverodata) then
    begin
     {Generate the text section}
     writer.SectionHeader[0].Name:='.text';
     writer.SectionHeader[0].VirtualAddress:=textoffset;
     writer.SectionHeader[0].VirtualSize:=rodataoffset-textoffset;
     writer.SectionHeader[0].NumberOfLineNumbers:=0;
     writer.SectionHeader[0].NumberOfRelocations:=0;
     writer.SectionHeader[0].Characteristics:=pe_image_section_characteristics_memory_execute
     or pe_image_section_characteristics_memory_read or pe_image_section_characteristics_type_code;
     writer.SectionHeader[0].PointerToLineNumbers:=0;
     writer.SectionHeader[0].PointerToRelocations:=0;
     writer.SectionHeader[1].PointerToRawData:=textoffset;
     writer.SectionHeader[0].SizeOfRawData:=rodataoffset-textoffset;
     {Generate the rodata section}
     writer.SectionHeader[1].Name:='.rodata';
     writer.SectionHeader[1].VirtualAddress:=rodataoffset;
     writer.SectionHeader[1].VirtualSize:=dataoffset-rodataoffset;
     writer.SectionHeader[1].NumberOfLineNumbers:=0;
     writer.SectionHeader[1].NumberOfRelocations:=0;
     writer.SectionHeader[1].Characteristics:=pe_image_section_characteristics_memory_read
     or pe_image_section_characteristics_initialized_data;
     writer.SectionHeader[1].PointerToLineNumbers:=0;
     writer.SectionHeader[1].PointerToRelocations:=0;
     writer.SectionHeader[1].PointerToRawData:=rodataoffset;
     writer.SectionHeader[1].SizeOfRawData:=dataoffset-rodataoffset;
     {Generate the data section}
     writer.SectionHeader[2].Name:='.data';
     writer.SectionHeader[2].VirtualAddress:=dataoffset;
     writer.SectionHeader[2].VirtualSize:=relocoffset-dataoffset;
     writer.SectionHeader[2].NumberOfLineNumbers:=0;
     writer.SectionHeader[2].NumberOfRelocations:=0;
     writer.SectionHeader[2].Characteristics:=pe_image_section_characteristics_memory_read
     or pe_image_section_characteristics_memory_write
     or pe_image_section_characteristics_initialized_data;
     writer.SectionHeader[2].PointerToLineNumbers:=0;
     writer.SectionHeader[2].PointerToRelocations:=0;
     writer.SectionHeader[2].PointerToRawData:=dataoffset;
     writer.SectionHeader[2].SizeOfRawData:=relocoffset-dataoffset;
     {Generate the reloc section}
     writer.SectionHeader[3].Name:='.reloc';
     writer.SectionHeader[3].VirtualAddress:=relocoffset;
     writer.SectionHeader[3].VirtualSize:=baseaddresssize;
     writer.SectionHeader[3].NumberOfLineNumbers:=0;
     writer.SectionHeader[3].NumberOfRelocations:=0;
     writer.SectionHeader[3].Characteristics:=pe_image_section_characteristics_memory_read or
     pe_image_section_characteristics_memory_discardable;
     writer.SectionHeader[3].PointerToLineNumbers:=0;
     writer.SectionHeader[3].PointerToRelocations:=0;
     writer.SectionHeader[3].PointerToRawData:=relocoffset;
     writer.SectionHeader[3].SizeOfRawData:=baseaddresssize;
    end
   else
    begin
     {Generate the text section}
     writer.SectionHeader[0].Name:='.text';
     writer.SectionHeader[0].VirtualAddress:=textoffset;
     writer.SectionHeader[0].VirtualSize:=dataoffset-textoffset;
     writer.SectionHeader[0].NumberOfLineNumbers:=0;
     writer.SectionHeader[0].NumberOfRelocations:=0;
     writer.SectionHeader[0].Characteristics:=pe_image_section_characteristics_memory_execute
     or pe_image_section_characteristics_memory_read or pe_image_section_characteristics_type_code;
     writer.SectionHeader[0].PointerToLineNumbers:=0;
     writer.SectionHeader[0].PointerToRelocations:=0;
     writer.SectionHeader[0].PointerToRawData:=textoffset;
     writer.SectionHeader[0].SizeOfRawData:=dataoffset-textoffset;
     {Generate the data section}
     writer.SectionHeader[1].Name:='.data';
     writer.SectionHeader[1].VirtualAddress:=dataoffset;
     writer.SectionHeader[1].VirtualSize:=relocoffset-dataoffset;
     writer.SectionHeader[1].NumberOfLineNumbers:=0;
     writer.SectionHeader[1].NumberOfRelocations:=0;
     writer.SectionHeader[1].Characteristics:=pe_image_section_characteristics_memory_read
     or pe_image_section_characteristics_memory_write
     or pe_image_section_characteristics_initialized_data;
     writer.SectionHeader[1].PointerToLineNumbers:=0;
     writer.SectionHeader[1].PointerToRelocations:=0;
     writer.SectionHeader[1].PointerToRawData:=dataoffset;
     writer.SectionHeader[1].SizeOfRawData:=relocoffset-dataoffset;
     {Generate the reloc section}
     writer.SectionHeader[2].Name:='.reloc';
     writer.SectionHeader[2].VirtualAddress:=relocoffset;
     writer.SectionHeader[2].VirtualSize:=baseaddresssize;
     writer.SectionHeader[2].NumberOfLineNumbers:=0;
     writer.SectionHeader[2].NumberOfRelocations:=0;
     writer.SectionHeader[2].Characteristics:=pe_image_section_characteristics_memory_read or
     pe_image_section_characteristics_memory_discardable;
     writer.SectionHeader[2].PointerToLineNumbers:=0;
     writer.SectionHeader[2].PointerToRelocations:=0;
     writer.SectionHeader[2].PointerToRawData:=relocoffset;
     writer.SectionHeader[2].SizeOfRawData:=baseaddresssize;
    end;
   pebinary:=tydq_getmem(writer.PeHeader.OptionalHeader32.SizeOfImage);
   pesize:=writer.PeHeader.OptionalHeader32.SizeOfImage;
   writeoffset:=0;
   tydq_move(writer.DosHeader,pebinary^,sizeof(writer.DosHeader));
   inc(writeoffset,sizeof(writer.DosHeader));
   tydq_move(writer.DosStub,(pebinary+writeoffset)^,sizeof(writer.DosStub));
   inc(writeoffset,sizeof(writer.DosStub));
   tydq_move(writer.PeHeader.signature,(pebinary+writeoffset)^,sizeof(writer.PeHeader.signature));
   inc(writeoffset,sizeof(writer.PeHeader.signature));
   tydq_move(writer.PeHeader.ImageHeader,(pebinary+writeoffset)^,sizeof(writer.PeHeader.ImageHeader));
   inc(writeoffset,sizeof(writer.PeHeader.ImageHeader));
   checksumoffset:=writeoffset;
   tydq_move(writer.PeHeader.OptionalHeader32,(pebinary+writeoffset)^,
   sizeof(writer.PeHeader.OptionalHeader32));
   inc(writeoffset,sizeof(writer.PeHeader.OptionalHeader32));
   for i:=1 to length(writer.DataHeader) do
    begin
     tydq_move(writer.DataHeader[i-1],(pebinary+writeoffset)^,sizeof(pe_data_directory));
     inc(writeoffset,sizeof(pe_data_directory));
    end;
   for i:=1 to length(writer.SectionHeader) do
    begin
     tydq_move(writer.SectionHeader[i-1],(pebinary+writeoffset)^,sizeof(pe_image_section_header));
     inc(writeoffset,sizeof(pe_image_section_header));
    end;
  end
 else if(ldbit=2) then
  begin
   if(ldarch=elf_machine_x86_64) then
   writer.PeHeader.ImageHeader.Machine:=pe_image_file_machine_amd64
   else if(ldarch=elf_machine_aarch64) then
   writer.PeHeader.ImageHeader.Machine:=pe_image_file_machine_arm64
   else if(ldarch=elf_machine_riscv) then
   writer.PeHeader.ImageHeader.Machine:=pe_image_file_machine_riscv64
   else if(ldarch=elf_machine_loongarch) then
   writer.PeHeader.ImageHeader.Machine:=pe_image_file_machine_loongarch64;
   if(stripsymbol=false) then
    begin
     writer.PeHeader.ImageHeader.NumberOfSymbols:=ldfile.SymTable.SymbolCount;
     writer.PeHeader.ImageHeader.PointerToSymbolTable:=symboltableAddr;
    end
   else
    begin
     writer.PeHeader.ImageHeader.NumberOfSymbols:=0;
     writer.PeHeader.ImageHeader.PointerToSymbolTable:=0;
    end;
   writer.PeHeader.ImageHeader.Characteristics:=pe_image_file_characteristics_executable_image
   or pe_image_file_characteristics_line_number_stripped
   or pe_image_file_characteristics_debug_stripped;
   if(stripsymbol) then
   writer.PeHeader.ImageHeader.Characteristics:=writer.PeHeader.ImageHeader.Characteristics or
   pe_image_file_characteristics_symbol_stripped;
   writer.PeHeader.ImageHeader.NumberOfSections:=3+Byte(haverodata);
   writer.PeHeader.ImageHeader.SizeOfOptionalHeader:=
   sizeof(coff_optional_image_header64)+6*sizeof(pe_data_directory);
   writer.PeHeader.OptionalHeader64.AddressOfEntryPoint:=tempfinal.EntryAddress;
   writer.PeHeader.OptionalHeader64.BaseOfCode:=textoffset;
   if(rodataoffset<>0) then
    begin
     writer.PeHeader.OptionalHeader64.SizeOfCode:=rodataoffset-textoffset;
     writer.PeHeader.OptionalHeader64.SizeOfInitializedData:=relocoffset-rodataoffset;
     writer.PeHeader.OptionalHeader64.SizeOfUnInitializedData:=0;
    end
   else
    begin
     writer.PeHeader.OptionalHeader64.SizeOfCode:=dataoffset-textoffset;
     writer.PeHeader.OptionalHeader64.SizeOfInitializedData:=relocoffset-dataoffset;
     writer.PeHeader.OptionalHeader64.SizeOfUnInitializedData:=0;
    end;
   writer.PeHeader.OptionalHeader64.MagicNumber:=pe_image_pe32plus;
   writer.PeHeader.OptionalHeader64.MajorLinkerVersion:=0;
   writer.PeHeader.OptionalHeader64.MinorLinkerVersion:=2;
   writer.PeHeader.OptionalHeader64.MajorImageVersion:=0;
   writer.PeHeader.OptionalHeader64.MinorImageVersion:=2;
   writer.PeHeader.OptionalHeader64.MajorOperatingSystemVersion:=0;
   writer.PeHeader.OptionalHeader64.MinorOperatingSystemVersion:=0;
   writer.PeHeader.OptionalHeader64.MajorSubSystemVersion:=0;
   writer.PeHeader.OptionalHeader64.MinorSubSystemVersion:=0;
   writer.PeHeader.OptionalHeader64.SectionAlignment:=align;
   writer.PeHeader.OptionalHeader64.FileAlignment:=align;
   if(format=ld_format_efi_application) then
   writer.PeHeader.OptionalHeader64.SubSystem:=pe_image_subsystem_efi_application
   else if(format=ld_format_efi_boot_driver) then
   writer.PeHeader.OptionalHeader64.SubSystem:=pe_image_subsystem_efi_boot_service_driver
   else if(format=ld_format_efi_application) then
   writer.PeHeader.OptionalHeader64.SubSystem:=pe_image_subsystem_efi_runtime_service_driver
   else if(format=ld_format_efi_boot_driver) then
   writer.PeHeader.OptionalHeader64.SubSystem:=pe_image_subsystem_efi_rom;
   writer.PeHeader.OptionalHeader64.SizeOfHeapCommit:=0;
   writer.PeHeader.OptionalHeader64.SizeOfHeapReserve:=0;
   writer.PeHeader.OptionalHeader64.SizeOfStackCommit:=0;
   writer.PeHeader.OptionalHeader64.SizeOfStackReserve:=0;
   writer.PeHeader.OptionalHeader64.Win32VersionValue:=0;
   writer.PeHeader.OptionalHeader64.ImageBase:=0;
   writer.PeHeader.OptionalHeader64.LoaderFlags:=0;
   writer.PeHeader.OptionalHeader64.FileAlignment:=align;
   writer.PeHeader.OptionalHeader64.CheckSum:=0;
   writer.PeHeader.OptionalHeader64.DLLCharacteristics:=
   pe_image_dll_characteristics_high_entropy_virtual_address or
   pe_image_dll_characteristics_dynamic_base;
   writer.PeHeader.OptionalHeader64.SizeOfHeaders:=
   ld_align(sizeof(writer.DosHeader)+sizeof(writer.DosStub)+
   sizeof(writer.PeHeader.signature)+sizeof(writer.PeHeader.ImageHeader)+
   sizeof(writer.PeHeader.OptionalHeader64)+6*sizeof(pe_data_directory)
   +(3+Byte(haverodata))*sizeof(pe_image_section_header),align);
   if(stripsymbol=false) then
   writer.PeHeader.OptionalHeader64.SizeOfImage:=
   ld_align(symboltableAddr+symbolandstringtablesize,align)
   else
   writer.PeHeader.OptionalHeader64.SizeOfImage:=
   ld_align(relocoffset+baseaddresssize,align);
   writer.PeHeader.OptionalHeader64.NumberOfRvaAndSizes:=6;
   SetLength(writer.DataHeader,6);
   writer.DataHeader[5].VirtualAddress:=relocoffset;
   writer.DataHeader[5].Size:=baseaddresssize;
   SetLength(writer.SectionHeader,3+Byte(haverodata));
   if(haverodata) then
    begin
     {Generate the text section}
     writer.SectionHeader[0].Name:='.text';
     writer.SectionHeader[0].VirtualAddress:=textoffset;
     writer.SectionHeader[0].VirtualSize:=rodataoffset-textoffset;
     writer.SectionHeader[0].NumberOfLineNumbers:=0;
     writer.SectionHeader[0].NumberOfRelocations:=0;
     writer.SectionHeader[0].Characteristics:=pe_image_section_characteristics_memory_execute
     or pe_image_section_characteristics_memory_read
     or pe_image_section_characteristics_type_code;
     writer.SectionHeader[0].PointerToLineNumbers:=0;
     writer.SectionHeader[0].PointerToRelocations:=0;
     writer.SectionHeader[1].PointerToRawData:=textoffset;
     writer.SectionHeader[0].SizeOfRawData:=rodataoffset-textoffset;
     {Generate the rodata section}
     writer.SectionHeader[1].Name:='.rodata';
     writer.SectionHeader[1].VirtualAddress:=rodataoffset;
     writer.SectionHeader[1].VirtualSize:=dataoffset-rodataoffset;
     writer.SectionHeader[1].NumberOfLineNumbers:=0;
     writer.SectionHeader[1].NumberOfRelocations:=0;
     writer.SectionHeader[1].Characteristics:=pe_image_section_characteristics_memory_read
     or pe_image_section_characteristics_initialized_data;
     writer.SectionHeader[1].PointerToLineNumbers:=0;
     writer.SectionHeader[1].PointerToRelocations:=0;
     writer.SectionHeader[1].PointerToRawData:=rodataoffset;
     writer.SectionHeader[1].SizeOfRawData:=dataoffset-rodataoffset;
     {Generate the data section}
     writer.SectionHeader[2].Name:='.data';
     writer.SectionHeader[2].VirtualAddress:=dataoffset;
     writer.SectionHeader[2].VirtualSize:=relocoffset-dataoffset;
     writer.SectionHeader[2].NumberOfLineNumbers:=0;
     writer.SectionHeader[2].NumberOfRelocations:=0;
     writer.SectionHeader[2].Characteristics:=pe_image_section_characteristics_memory_read
     or pe_image_section_characteristics_memory_write
     or pe_image_section_characteristics_initialized_data;
     writer.SectionHeader[2].PointerToLineNumbers:=0;
     writer.SectionHeader[2].PointerToRelocations:=0;
     writer.SectionHeader[2].PointerToRawData:=dataoffset;
     writer.SectionHeader[2].SizeOfRawData:=relocoffset-dataoffset;
     {Generate the reloc section}
     writer.SectionHeader[3].Name:='.reloc';
     writer.SectionHeader[3].VirtualAddress:=relocoffset;
     writer.SectionHeader[3].VirtualSize:=baseaddresssize;
     writer.SectionHeader[3].NumberOfLineNumbers:=0;
     writer.SectionHeader[3].NumberOfRelocations:=0;
     writer.SectionHeader[3].Characteristics:=pe_image_section_characteristics_memory_read
     or pe_image_section_characteristics_memory_discardable;
     writer.SectionHeader[3].PointerToLineNumbers:=0;
     writer.SectionHeader[3].PointerToRelocations:=0;
     writer.SectionHeader[3].PointerToRawData:=relocoffset;
     writer.SectionHeader[3].SizeOfRawData:=baseaddresssize;
    end
   else
    begin
     {Generate the text section}
     writer.SectionHeader[0].Name:='.text';
     writer.SectionHeader[0].VirtualAddress:=textoffset;
     writer.SectionHeader[0].VirtualSize:=dataoffset-textoffset;
     writer.SectionHeader[0].NumberOfLineNumbers:=0;
     writer.SectionHeader[0].NumberOfRelocations:=0;
     writer.SectionHeader[0].Characteristics:=pe_image_section_characteristics_memory_execute
     or pe_image_section_characteristics_memory_read
     or pe_image_section_characteristics_type_code;
     writer.SectionHeader[0].PointerToRawData:=textoffset;
     writer.SectionHeader[0].PointerToLineNumbers:=0;
     writer.SectionHeader[0].PointerToRelocations:=0;
     writer.SectionHeader[0].SizeOfRawData:=dataoffset-textoffset;
     {Generate the data section}
     writer.SectionHeader[1].Name:='.data';
     writer.SectionHeader[1].VirtualAddress:=dataoffset;
     writer.SectionHeader[1].VirtualSize:=relocoffset-dataoffset;
     writer.SectionHeader[1].NumberOfLineNumbers:=0;
     writer.SectionHeader[1].NumberOfRelocations:=0;
     writer.SectionHeader[1].Characteristics:=pe_image_section_characteristics_memory_read or
     pe_image_section_characteristics_memory_write or pe_image_section_characteristics_initialized_data;
     writer.SectionHeader[1].PointerToRawData:=dataoffset;
     writer.SectionHeader[1].PointerToLineNumbers:=0;
     writer.SectionHeader[1].PointerToRelocations:=0;
     writer.SectionHeader[1].SizeOfRawData:=relocoffset-dataoffset;
     {Generate the reloc section}
     writer.SectionHeader[2].Name:='.reloc';
     writer.SectionHeader[2].VirtualAddress:=relocoffset;
     writer.SectionHeader[2].VirtualSize:=baseaddresssize;
     writer.SectionHeader[2].NumberOfLineNumbers:=0;
     writer.SectionHeader[2].NumberOfRelocations:=0;
     writer.SectionHeader[2].Characteristics:=pe_image_section_characteristics_memory_read or
     pe_image_section_characteristics_memory_discardable;
     writer.SectionHeader[2].PointerToRawData:=relocoffset;
     writer.SectionHeader[2].PointerToLineNumbers:=0;
     writer.SectionHeader[2].PointerToRelocations:=0;
     writer.SectionHeader[2].SizeOfRawData:=baseaddresssize;
    end;
   pebinary:=tydq_getmem(writer.PeHeader.OptionalHeader64.SizeOfImage);
   pesize:=writer.PeHeader.OptionalHeader64.SizeOfImage;
   writeoffset:=0;
   tydq_move(writer.DosHeader,pebinary^,sizeof(writer.DosHeader));
   inc(writeoffset,sizeof(writer.DosHeader));
   tydq_move(writer.DosStub,(pebinary+writeoffset)^,sizeof(writer.DosStub));
   inc(writeoffset,sizeof(writer.DosStub));
   tydq_move(writer.PeHeader.signature,(pebinary+writeoffset)^,sizeof(writer.PeHeader.signature));
   inc(writeoffset,sizeof(writer.PeHeader.signature));
   tydq_move(writer.PeHeader.ImageHeader,(pebinary+writeoffset)^,sizeof(writer.PeHeader.ImageHeader));
   inc(writeoffset,sizeof(writer.PeHeader.ImageHeader));
   checksumoffset:=writeoffset;
   tydq_move(writer.PeHeader.OptionalHeader64,(pebinary+writeoffset)^,
   sizeof(writer.PeHeader.OptionalHeader64));
   inc(writeoffset,sizeof(writer.PeHeader.OptionalHeader64));
   for i:=1 to length(writer.DataHeader) do
    begin
     tydq_move(writer.DataHeader[i-1],(pebinary+writeoffset)^,sizeof(pe_data_directory));
     inc(writeoffset,sizeof(pe_data_directory));
    end;
   for i:=1 to length(writer.SectionHeader) do
    begin
     tydq_move(writer.SectionHeader[i-1],(pebinary+writeoffset)^,sizeof(pe_image_section_header));
     inc(writeoffset,sizeof(pe_image_section_header));
    end;
  end;
 {Then move the content of PE to file}
 i:=1; writeoffset:=0;
 while(i<=tempfinal.SecCount)do
  begin
   writeoffset:=tempfinal.SecAddress[i-1];
   if(tempfinal.SecContent[i-1]<>nil) then
   tydq_move(tempfinal.SecContent[i-1]^,(pebinary+writeoffset)^,tempfinal.SecSize[i-1]);
   inc(i);
  end;
 {move the relocation content of PE to file}
 i:=1; j:=1;
 writeoffset:=writer.SectionHeader[length(writer.SectionHeader)-1].VirtualAddress;
 for i:=1 to length(writer.RelocationTable) do
  begin
   tydq_move(writer.RelocationTable[i-1].Block,(pebinary+writeoffset)^,8);
   inc(writeoffset,8);
   for j:=1 to length(writer.RelocationTable[i-1].item) do
    begin
     tydq_move(writer.RelocationTable[i-1].Item[j-1],(pebinary+writeoffset)^,8);
     inc(writeoffset,2);
    end;
  end;
 {If symbol table not stripped,tydq_move the symbol content of PE to file}
 i:=1; j:=1;
 writeoffset:=symboltableAddr;
 tydq_move(symboltable[0],(pebinary+writeoffset)^,length(symboltable)*sizeof(coff_symbol_table_item));
 inc(writeoffset,length(symboltable)*sizeof(coff_symbol_table_item));
 tydq_move(symbolstringtableptr,(pebinary+writeoffset)^,4);
 inc(writeoffset,4);
 tydq_move(symbolstringtable^,(pebinary+writeoffset)^,symbolstringtableptr-4);
 writeoffset:=checksumoffset;
 if(ldbit=1) then
  begin
   writer.PeHeader.OptionalHeader32.CheckSum:=pe_calculate_checksum(pebinary,pesize);
   tydq_move(writer.PeHeader.OptionalHeader32,(pebinary+writeoffset)^,
   sizeof(writer.PeHeader.OptionalHeader32));
  end
 else if(ldbit=2) then
  begin
   writer.PeHeader.OptionalHeader64.CheckSum:=pe_calculate_checksum(pebinary,pesize);
   tydq_move(writer.PeHeader.OptionalHeader64,(pebinary+writeoffset)^,
   sizeof(writer.PeHeader.OptionalHeader64));
  end;
 if(FileExists(fn)) then DeleteFile(fn);
 ld_io_write(fn,1,pebinary^,pesize);
end;

end.
