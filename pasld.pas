program pasld;

uses ldbase,binbase,strutils,convmem,sysutils;

type pasld_param=packed record
                 filename:dynstrarray;
                 dynamiclibraryname:dynstrarray;
                 align:dword;
                 SmartLinking:boolean;
                 ExecutableType:byte;
                 NoDefaultLibrary:boolean;
                 ReserveSymbol:boolean;
                 DynamicLinker:string;
                 Signature:string;
                 EntryName:string;
                 NeedMemory:Natuint;
                 NeedBlockSize:Natuint;
                 DebugFrame:boolean;
                 OutputFileName:string;
                 end;
    pasld_filelist=packed record
                   filepath:array of string;
                   filename:array of string;
                   count:Natuint;
                   end;

var error:boolean=false;

function pasld_search_for_filelist(basepath:string;mask:string;includesubdir:boolean):pasld_filelist;
var SearchRec:TSearchRec;
    signal:LongInt;
    i:Natuint;
    templist:pasld_filelist;
begin
 Result.count:=0; signal:=-1;
 if(includesubdir) then
  begin
   while(True)do
    begin
     if(signal<>0) then signal:=FindFirst(basepath,faDirectory,SearchRec)
     else signal:=FindNext(SearchRec);
     if(signal<>0) then break;
     if(SearchRec.Name='..') or (SearchRec.Name='.') then continue;
     templist:=pasld_search_for_filelist(basepath+'/'+SearchRec.Name,mask,true);
     i:=1;
     while(i<=templist.count)do
      begin
       inc(Result.count);
       SetLength(Result.filename,Result.count);
       SetLength(Result.filepath,Result.count);
       Result.filename[Result.count-1]:=templist.filename[i-1];
       Result.filepath[Result.count-1]:=templist.filepath[i-1];
       inc(i);
      end;
    end;
   FindClose(SearchRec);
  end;
 signal:=-1;
 while(True)do
  begin
   if(signal<>0) then signal:=FindFirst(basepath+'/'+mask,faAnyFile,SearchRec)
   else signal:=FindNext(SearchRec);
   if(SearchRec.Name='..') or (SearchRec.Name='.') then continue;
   if(signal<>0) then break;
   inc(Result.count);
   SetLength(Result.filename,Result.count);
   SetLength(Result.filepath,Result.count);
   Result.filename[Result.count-1]:=SearchRec.Name;
   Result.filepath[Result.count-1]:=basepath;
  end;
 FindClose(SearchRec);
end;
function pasld_size_to_number(size:string):Natuint;
var len:Natuint;
begin
 len:=length(size);
 if(Copy(size,len-2,3)='GiB') then
  begin
   Result:=StrToInt(Copy(size,1,len-3))*1024*1024*1024;
  end
 else if(Copy(size,len-2,3)='MiB') then
  begin
   Result:=StrToInt(Copy(size,1,len-3))*1024*1024;
  end
 else if(Copy(size,len-2,3)='KiB') then
  begin
   Result:=StrToInt(Copy(size,1,len-3))*1024;
  end
 else if(Copy(size,len-1,2)='GB') then
  begin
   Result:=StrToInt(Copy(size,1,len-2))*1024*1024*1024;
  end
 else if(Copy(size,len-1,2)='MB') then
  begin
   Result:=StrToInt(Copy(size,1,len-2))*1024*1024;
  end
 else if(Copy(size,len-1,2)='KB') then
  begin
   Result:=StrToInt(Copy(size,1,len-2))*1024;
  end
 else if(Copy(size,len-1,2)='B') then
  begin
   Result:=StrToInt(Copy(size,1,len-1));
  end
 else
  begin
   pasld_size_to_number:=0;
   writeln('ERROR:size unit must be specified.');
   error:=true;
   exit;
  end;
end;
function pasld_block_size_to_power(size:Natuint):byte;
var i:byte;
    tempsize:Natuint;
begin
 i:=1; tempsize:=size;
 while(tempsize>0)do
  begin
   tempsize:=tempsize shr 1;
   inc(i);
  end;
 pasld_block_size_to_power:=i;
end;
procedure pasld_show_help;
begin
 writeln('pasld(pascal linker) Version 0.0.2');
 writeln('Now show the help:');
 writeln('Template:pasld/pasld.exe [parameters]');
 writeln('Vaild parameters:');
 writeln('--input-path [The path you want to specify including input files]');
 writeln('             include the input file path to push them to the pasld');
 writeln('--input-path-with-subdirectory [The path you want to specify including input files]');
 writeln('             include the input file path to push them to the pasld including all input file in'+
 ' subdirectory.');
 writeln('--input [single file to input]');
 writeln('             input the single file(relocatable object file or archive file(*.a,*.ar)');
 writeln('--output [output file which the linker generated]');
 writeln('             output the executable file with the file name specified by you.');
 writeln('--include-dynamic-library [include dynamic library specified by you]');
 writeln('             include the needed dynamic library specified by you.');
 writeln('--include-dynamic-library-path [directory which include dynamic library specified by you]');
 writeln('--include-dynamic-library-path-with-subdirectory [Root Directory including'+
 'all dynamic libraries needed].');
 writeln('             include the needed dynamic library path specified by you.');
 writeln('--alignment [alignment in file segment]');
 writeln('             Specify the alignment about output file(You can input page as alignment 4096.');
 writeln('--dynamic-linker-path [the dynamic linker path specified by you]');
 writeln('             The dynamic linker path the executable file needed to use.');
 writeln('--signature [the signature you want to add to the file]');
 writeln('             The signature you want to add to the file as a segment.');
 writeln('--no-symbol-table');
 writeln('             The option to strip the symbol table.');
 writeln('--no-debug-frame');
 writeln('             The option to strip the debugging information.');
 writeln('--no-default-library');
 writeln('             The option to add the signal not using default library.');
 writeln('--smartlinking');
 writeln('             The option to enable the smart linking to used segment and strip unused segment.');
 writeln('--executable');
 writeln('             The option to generate executable file.');
 writeln('--dynamic-library');
 writeln('             The option to generate dynamic library file.');
 writeln('--efi-application');
 writeln('             The option to generate UEFI Application file.');
 writeln('--efi-boot-driver');
 writeln('             The option to generate UEFI Boot Service Driver file.');
 writeln('--efi-runtime-driver');
 writeln('             The option to generate UEFI Runtime Service Driver file.');
 writeln('--entry-point [entry point name]');
 writeln('             The entry point of the generated file.');
 writeln('--linker-heap-size [specified size]');
 writeln('             Change the linker total block size to block size you have assigned.');
 writeln('--linker-block-size [block size]');
 writeln('             Change the linker minimum block size to block size you have assigned.');
 readln;
end;
function pasld_parse_parameter:pasld_param;
var i,j:Natuint;
    templist:pasld_filelist;
begin
 i:=1;
 Result.align:=$1000; Result.SmartLinking:=false;
 Result.ExecutableType:=0; Result.NoDefaultLibrary:=false;
 Result.ReserveSymbol:=true; Result.NeedMemory:=1024*1024*1024; Result.NeedBlockSize:=8;
 Result.DebugFrame:=true; Result.OutputFileName:='';
 Result.DynamicLinker:=''; Result.Signature:=''; Result.EntryName:='';
 SetLength(Result.filename,0); SetLength(Result.dynamiclibraryname,0);
 while(i<=ParamCount)do
  begin
   if(error) then exit;
   if(LowerCase(ParamStr(i))='--input-path') then
    begin
     if(DirectoryExists(ParamStr(i+1))=false) and (FileExists(ParamStr(i+1))=false) then
      begin
       writeln('ERROR:input path is not file or directory.');
       error:=true;
       exit;
      end;
     templist:=pasld_search_for_filelist(ParamStr(i+1),'*.o',false);
     for j:=1 to templist.count do
      begin
       SetLength(Result.filename,Length(Result.filename)+1);
       Result.filename[length(Result.filename)-1]:=templist.filepath[j-1]+'/'+templist.filename[j-1];
      end;
     templist:=pasld_search_for_filelist(ParamStr(i+1),'*.a',false);
     for j:=1 to templist.count do
      begin
       SetLength(Result.filename,Length(Result.filename)+1);
       Result.filename[length(Result.filename)-1]:=templist.filepath[j-1]+'/'+templist.filename[j-1];
      end;
     templist:=pasld_search_for_filelist(ParamStr(i+1),'*.ar',false);
     for j:=1 to templist.count do
      begin
       SetLength(Result.filename,Length(Result.filename)+1);
       Result.filename[length(Result.filename)-1]:=templist.filepath[j-1]+'/'+templist.filename[j-1];
      end;
     inc(i);
    end
   else if(LowerCase(ParamStr(i))='--input-path-with-subdirectory') then
    begin
     if(DirectoryExists(ParamStr(i+1))=false) and (FileExists(ParamStr(i+1))=false) then
      begin
       writeln('ERROR:input path is not file or directory.');
       error:=true;
       exit;
      end;
     templist:=pasld_search_for_filelist(ParamStr(i+1),'*.o',true);
     for j:=1 to templist.count do
      begin
       SetLength(Result.filename,Length(Result.filename)+1);
       Result.filename[length(Result.filename)-1]:=templist.filepath[j-1]+'/'+templist.filename[j-1];
      end;
     templist:=pasld_search_for_filelist(ParamStr(i+1),'*.a',true);
     for j:=1 to templist.count do
      begin
       SetLength(Result.filename,Length(Result.filename)+1);
       Result.filename[length(Result.filename)-1]:=templist.filepath[j-1]+'/'+templist.filename[j-1];
      end;
     templist:=pasld_search_for_filelist(ParamStr(i+1),'*.ar',true);
     for j:=1 to templist.count do
      begin
       SetLength(Result.filename,Length(Result.filename)+1);
       Result.filename[length(Result.filename)-1]:=templist.filepath[j-1]+'/'+templist.filename[j-1];
      end;
     inc(i);
    end
   else if(LowerCase(ParamStr(i))='--input') then
    begin
     SetLength(Result.filename,Length(Result.filename)+1);
     Result.filename[length(Result.filename)-1]:=ParamStr(i+1); inc(i);
    end
   else if(LowerCase(ParamStr(i))='--output') then
    begin
     Result.OutputFileName:=ParamStr(i+1); inc(i);
    end
   else if(LowerCase(ParamStr(i))='--include-dynamic-library') then
    begin
     SetLength(Result.filename,Length(Result.filename)+1);
     Result.filename[length(Result.filename)-1]:=ParamStr(i+1); inc(i);
    end
   else if(LowerCase(ParamStr(i))='--include-dynamic-library-path') then
    begin
     templist:=pasld_search_for_filelist(ParamStr(i+1),'*.so',false);
     for j:=1 to templist.count do
      begin
       SetLength(Result.filename,Length(Result.filename)+1);
       Result.filename[length(Result.filename)-1]:=templist.filepath[j-1]+'/'+templist.filename[j-1];
      end;
     inc(i);
    end
   else if(LowerCase(ParamStr(I))='--include-dynamic-library-path-with-subdirectory') then
    begin
     templist:=pasld_search_for_filelist(ParamStr(i+1),'*.so',true);
     for j:=1 to templist.count do
      begin
       SetLength(Result.filename,Length(Result.filename)+1);
       Result.filename[length(Result.filename)-1]:=templist.filepath[j-1]+'/'+templist.filename[j-1];
      end;
     inc(i);
    end
   else if(LowerCase(ParamStr(i))='--alignment') then
    begin
     if(LowerCase(ParamStr(i+1))='page') then Result.align:=$1000
     else Result.align:=StrToInt(ParamStr(i+1));
     inc(i);
    end
   else if(LowerCase(ParamStr(i))='--dynamic-linker-path') then
    begin
     Result.DynamicLinker:=ParamStr(i+1); inc(i);
    end
   else if(LowerCase(ParamStr(i))='--signature') then
    begin
     Result.Signature:=ParamStr(i+1); inc(i);
    end
   else if(LowerCase(ParamStr(i))='--no-symbol-table') then
    begin
     Result.ReserveSymbol:=false;
    end
   else if(LowerCase(ParamStr(i))='--no-debug-frame') then
    begin
     Result.DebugFrame:=false;
    end
   else if(LowerCase(ParamStr(i))='--no-default-library') then
    begin
     Result.NoDefaultLibrary:=true;
    end
   else if(LowerCase(ParamStr(i))='--smartlinking') then
    begin
     Result.SmartLinking:=true;
    end
   else if(LowerCase(Paramstr(i))='--executable') and (Result.ExecutableType=0) then
    begin
     Result.ExecutableType:=1;
    end
   else if(LowerCase(ParamStr(i))='--dynamic-library') and (Result.ExecutableType=0) then
    begin
     Result.ExecutableType:=2;
    end
   else if(LowerCase(ParamStr(i))='--efi-application') and (Result.ExecutableType=0) then
    begin
     Result.ExecutableType:=3;
    end
   else if(LowerCase(ParamStr(i))='--efi-boot-driver') and (Result.ExecutableType=0) then
    begin
     Result.ExecutableType:=4;
    end
   else if(LowerCase(ParamStr(i))='--efi-runtime-driver') and (Result.ExecutableType=0) then
    begin
     Result.ExecutableType:=5;
    end
   else if(LowerCase(ParamStr(i))='--entry-point') then
    begin
     Result.EntryName:=ParamStr(i+1); inc(i);
    end
   else if(LowerCase(ParamStr(i))='--linker-heap-size') then
    begin
     Result.NeedBlockSize:=pasld_size_to_number(ParamStr(i+1));
     inc(i);
    end
   else if(LowerCase(ParamStr(i))='--linker-block-size') then
    begin
     Result.NeedBlockSize:=pasld_block_size_to_power(StrToInt(ParamStr(i+1)));
     inc(i);
    end
   else
    begin
     writeln('ERROR:Unknown instruction '+ParamStr(i));
     error:=true;
     exit;
    end;
   inc(i);
  end;
 if(Length(Result.filename)<=0) then
  begin
   writeln('ERROR:No input file found to link.');
   error:=true;
   exit;
  end;
 if(Result.OutputFileName='') then
  begin
   writeln('ERROR:No output file name specified to generate.');
   error:=true;
   exit;
  end;
 if(Result.ExecutableType=0) then
  begin
   writeln('ERROR:No Executable Type specified to generate.');
   error:=true;
   exit;
  end;
 if(Result.EntryName='') then
  begin
   writeln('ERROR:No entry point specified to locate.');
   error:=true;
   exit;
  end;
end;
procedure pasld_execute(param:pasld_param);
var ptr:Pointer;
    objlist:ld_object_file_list;
    handlefile:ld_object_file_stage_2;
begin
 ptr:=allocmem(param.NeedMemory);
 memheap:=heap_initialize(Natuint(ptr),Natuint(ptr+param.NeedMemory),param.NeedBlockSize);
 if(Length(param.dynamiclibraryname)>0) then
  begin
   writeln('Handling the needed......');
   ld_handle_dynamic_library(dynstrarray(param.dynamiclibraryname));
  end
 else
  begin
   ld_handle_dynamic_library([]);
  end;
 writeln('Reading Files......');
 objlist:=ld_generate_file_list(dynstrarray(param.filename));
 if(param.ExecutableType<=2) then
  begin
   writeln('Linking ELF Files......');
   handlefile:=ld_link_file(objlist,param.EntryName,param.SmartLinking);
   writeln('Generating ELF Files......');
   ld_handle_elf_file(param.OutputFileName,handlefile,param.align,
   param.DebugFrame,(3-param.ExecutableType)*2,param.NoDefaultLibrary,not param.ReserveSymbol,
   param.DynamicLinker,param.Signature);
   writeln('File '+param.OutputFileName+' generated!');
  end
 else
  begin
   writeln('Linking ELF Files......');
   handlefile:=ld_link_file(objlist,param.EntryName,param.SmartLinking);
   writeln('Generating EFI Files......');
   ld_handle_elf_file_to_efi_file(param.OutputFileName,handlefile,param.align,
   param.DebugFrame,param.ExecutableType*2,not param.ReserveSymbol);
   writeln('File '+param.OutputFileName+' generated!');
  end;
 FreeMem(ptr);
end;
var param:pasld_param;
begin
 if(ParamCount<=0) then
  begin
   pasld_show_help; exit;
  end;
 param:=pasld_parse_parameter;
 if(error) then
  begin
   pasld_show_help; exit;
  end;
 pasld_execute(param);
end.

