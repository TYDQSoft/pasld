program pasld;

uses ldbase,binbase,strutils,convmem,sysutils,classes;

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
                 NeedBlockPower:byte;
                 NeedBlockLevel:byte;
                 DebugFrame:boolean;
                 OutputFileName:string;
                 TotalFileSize:Natuint;
                 verbose:boolean;
                 startaddress:Natuint;
                 end;
    pasld_filelist=packed record
                   filepath:array of string;
                   filename:array of string;
                   filesize:array of Natuint;
                   count:Natuint;
                   end;

var error:boolean=false;

function pasld_io_get_size(fn:string):dword;
var fs:TFileStream;
begin
 fs:=TFileStream.Create(fn,fmOpenRead);
 pasld_io_get_size:=fs.Size;
 fs.Free;
end;
function pasld_hex_to_int(str:string):Natuint;
const hex1:string='0123456789abcdef';
      hex2:string='0123456789ABCDEF';
var i,j,len:byte;
begin
 len:=length(str); Result:=0;
 for i:=1 to len do
  begin
   j:=1;
   while(j<=16)do
    begin
     if(str[i]=hex1[j]) then break;
     if(str[i]=hex2[j]) then break;
     inc(j);
    end;
   if(j>16) then
    begin
     writeln('ERROR:Address '+str+' is not hexidecimal value.');
     readln;
     halt;
    end;
   Result:=Result*16+j-1;
  end;
end;
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
       SetLength(Result.filepath,Result.count);
       Result.filename[Result.count-1]:=templist.filename[i-1];
       Result.filepath[Result.count-1]:=templist.filepath[i-1];
       Result.filesize[Result.count-1]:=templist.filesize[i-1];
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
   SetLength(Result.filesize,Result.count);
   Result.filename[Result.count-1]:=SearchRec.Name;
   Result.filepath[Result.count-1]:=basepath;
   Result.filesize[Result.count-1]:=SearchRec.Size;
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
 writeln('pasld(pascal linker) Version 0.0.3');
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
 writeln('             Specify the alignment about output file(You can input page as alignment 4096).');
 writeln('             You can also input largepage as alignment 65536.');
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
 writeln('--relocatable');
 writeln('             The option to generate relocatable file.');
 writeln('--efi-application');
 writeln('             The option to generate UEFI Application file.');
 writeln('--efi-boot-driver');
 writeln('             The option to generate UEFI Boot Service Driver file.');
 writeln('--efi-runtime-driver');
 writeln('             The option to generate UEFI Runtime Service Driver file.');
 writeln('--entry-point [entry point name]');
 writeln('             The entry point of the generated file.');
 writeln('--linker-heap-no-smart');
 writeln('             Close the smart adjustment for linker.');
 writeln('--linker-heap-size [specified size]');
 writeln('             Change the linker total block size to block size you have assigned.');
 writeln('--linker-block-size [block size]');
 writeln('             Change the linker minimum block size to block size you have assigned.');
 writeln('--linker-block-power [block size]');
 writeln('             Change the linker accelerate block power to block size you have assigned.');
 writeln('--verbose');
 writeln('             if it is set,it will generate verbose information.');
 writeln('--start-address');
 writeln('             set the section start address of the binary file.');
 writeln('--version');
 writeln('             show the version of pasld(Pascal Linker).');
 readln;
end;
function pasld_parse_parameter:pasld_param;
var i,j:Natuint;
    templist:pasld_filelist;
    smart:boolean=true;
begin
 i:=1;
 Result.align:=$1000; Result.SmartLinking:=false;
 Result.ExecutableType:=0; Result.NoDefaultLibrary:=false;
 Result.ReserveSymbol:=true; Result.NeedMemory:=1024*1024*1024;
 Result.NeedBlockSize:=3; Result.NeedBlockPower:=3; Result.NeedBlockLevel:=7;
 Result.DebugFrame:=true; Result.OutputFileName:=''; Result.TotalFileSize:=0;
 Result.DynamicLinker:=''; Result.Signature:=''; Result.EntryName:=''; Result.verbose:=false;
 Result.startaddress:=0;
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
       inc(Result.TotalFileSize,templist.filesize[j-1]);
      end;
     templist:=pasld_search_for_filelist(ParamStr(i+1),'*.a',false);
     for j:=1 to templist.count do
      begin
       SetLength(Result.filename,Length(Result.filename)+1);
       Result.filename[length(Result.filename)-1]:=templist.filepath[j-1]+'/'+templist.filename[j-1];
       inc(Result.TotalFileSize,templist.filesize[j-1]);
      end;
     templist:=pasld_search_for_filelist(ParamStr(i+1),'*.ar',false);
     for j:=1 to templist.count do
      begin
       SetLength(Result.filename,Length(Result.filename)+1);
       Result.filename[length(Result.filename)-1]:=templist.filepath[j-1]+'/'+templist.filename[j-1];
       inc(Result.TotalFileSize,templist.filesize[j-1]);
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
       inc(Result.TotalFileSize,templist.filesize[j-1]);
      end;
     templist:=pasld_search_for_filelist(ParamStr(i+1),'*.a',true);
     for j:=1 to templist.count do
      begin
       SetLength(Result.filename,Length(Result.filename)+1);
       Result.filename[length(Result.filename)-1]:=templist.filepath[j-1]+'/'+templist.filename[j-1];
       inc(Result.TotalFileSize,templist.filesize[j-1]);
      end;
     templist:=pasld_search_for_filelist(ParamStr(i+1),'*.ar',true);
     for j:=1 to templist.count do
      begin
       SetLength(Result.filename,Length(Result.filename)+1);
       Result.filename[length(Result.filename)-1]:=templist.filepath[j-1]+'/'+templist.filename[j-1];
       inc(Result.TotalFileSize,templist.filesize[j-1]);
      end;
     inc(i);
    end
   else if(LowerCase(ParamStr(i))='--input') then
    begin
     SetLength(Result.filename,Length(Result.filename)+1);
     Result.filename[length(Result.filename)-1]:=ParamStr(i+1);
     Result.TotalFileSize:=pasld_io_get_size(ParamStr(i+1));
     inc(i);
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
     else if(LowerCase(ParamStr(i+1))='largepage') then Result.align:=$10000
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
   else if(LowerCase(ParamStr(i))='--relocatable') and (Result.ExecutableType=0) then
    begin
     Result.ExecutableType:=3;
    end
   else if(LowerCase(ParamStr(i))='--efi-application') and (Result.ExecutableType=0) then
    begin
     Result.ExecutableType:=4;
    end
   else if(LowerCase(ParamStr(i))='--efi-boot-driver') and (Result.ExecutableType=0) then
    begin
     Result.ExecutableType:=5;
    end
   else if(LowerCase(ParamStr(i))='--efi-runtime-driver') and (Result.ExecutableType=0) then
    begin
     Result.ExecutableType:=6;
    end
   else if(LowerCase(ParamStr(i))='--entry-point') then
    begin
     Result.EntryName:=ParamStr(i+1); inc(i);
    end
   else if(LowerCase(ParamStr(i))='--linker-heap-no-smart') then
    begin
     Smart:=false;
    end
   else if(LowerCase(ParamStr(i))='--linker-heap-size') then
    begin
     Result.NeedBlockSize:=pasld_size_to_number(ParamStr(i+1));
     inc(i);
    end
   else if(LowerCase(ParamStr(i))='--linker-block-size') then
    begin
     Result.NeedBlockSize:=pasld_block_size_to_power(StrToInt(ParamStr(i+1))); inc(i);
    end
   else if(LowerCase(ParamStr(i))='--linker-block-power') then
    begin
     Result.NeedBlockPower:=StrToInt(ParamStr(i+1)); inc(i);
    end
   else if(LowerCase(ParamStr(i))='--linker-block-level') then
    begin
     Result.NeedBlockLevel:=StrToInt(ParamStr(i+1)); inc(i);
    end
   else if(LowerCase(ParamStr(i))='--verbose') then
    begin
     Result.verbose:=true;
    end
   else if(LowerCase(ParamStr(i))='--start-address') then
    begin
     Result.startaddress:=pasld_hex_to_int(ParamStr(i+1)); inc(i);
    end
   else if(LowerCase(ParamStr(i))='--version') then
    begin
     writeln('Pascal Linker(pasld) version 0.0.3');
    end
   else
    begin
     writeln('ERROR:Unknown instruction '+ParamStr(i));
     error:=true;
     exit;
    end;
   inc(i);
  end;
 if(Smart=false) and (Result.NeedBlockLevel>7) and (Result.NeedBlockLevel<1) then
  begin
   writeln('ERROR:Needed Block Level '+IntToStr(Result.NeedBlockLevel)+' illegal,must be 1 to 7.');
   error:=true;
   exit;
  end;
 if(Smart=false) and (Result.NeedBlockSize<3) then
  begin
   writeln('ERROR:Needed Block Size '+IntToStr(1 shl Result.NeedBlockSize)+' illegal,must be equal or greater than 8.');
   error:=true;
   exit;
  end;
 if(Smart) then
  begin
   Result.NeedMemory:=(Result.TotalFileSize*8+$1000-1) div $1000*$1000;
   if(Result.NeedMemory>=$40000000) then
    begin
     Result.NeedBlockSize:=5; Result.NeedBlockPower:=4; Result.NeedBlockLevel:=7;
    end
   else if(Result.NeedMemory>=$10000000) then
    begin
     Result.NeedBlockSize:=4; Result.NeedBlockPower:=4; Result.NeedBlockLevel:=7;
    end
   else if(Result.NeedMemory>=$C000000) then
    begin
     Result.NeedBlockSize:=5; Result.NeedBlockPower:=3; Result.NeedBlockLevel:=7;
    end
   else if(Result.NeedMemory>=$8000000) then
    begin
     Result.NeedBlockSize:=4; Result.NeedBlockPower:=3; Result.NeedBlockLevel:=7;
    end
   else if(Result.NeedMemory>=$4000000) then
    begin
     Result.NeedBlockSize:=5; Result.NeedBlockPower:=2; Result.NeedBlockLevel:=7;
    end
   else if(Result.NeedMemory>=$1000000) then
    begin
     Result.NeedBlockSize:=4; Result.NeedBlockPower:=2; Result.NeedBlockLevel:=7;
    end
   else if(Result.NeedMemory>=$C00000) then
    begin
     Result.NeedBlockSize:=5; Result.NeedBlockPower:=2; Result.NeedBlockLevel:=6;
    end
   else if(Result.NeedMemory>=$800000) then
    begin
     Result.NeedBlockSize:=4; Result.NeedBlockPower:=2; Result.NeedBlockLevel:=6;
    end
   else if(Result.NeedMemory>=$400000) then
    begin
     Result.NeedBlockSize:=5; Result.NeedBlockPower:=2; Result.NeedBlockLevel:=5;
    end
   else if(Result.NeedMemory>=$100000) then
    begin
     Result.NeedBlockSize:=4; Result.NeedBlockPower:=2; Result.NeedBlockLevel:=5;
    end
   else if(Result.NeedMemory>=$C0000) then
    begin
     Result.NeedBlockSize:=5; Result.NeedBlockPower:=2; Result.NeedBlockLevel:=4;
    end
   else if(Result.NeedMemory>=$80000) then
    begin
     Result.NeedBlockSize:=4; Result.NeedBlockPower:=2; Result.NeedBlockLevel:=4;
    end
   else if(Result.NeedMemory>=$40000) then
    begin
     Result.NeedBlockSize:=5; Result.NeedBlockPower:=2; Result.NeedBlockLevel:=3;
    end
   else
    begin
     Result.NeedBlockSize:=4; Result.NeedBlockPower:=2; Result.NeedBlockLevel:=3;
    end;
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
 ptr:=getmem(param.NeedMemory);
 tydq_heap_initialize(ptr,param.NeedMemory,param.NeedBlockSize,param.NeedBlockPower,param.NeedBlockLevel);
 if(Length(param.dynamiclibraryname)>0) then
  begin
   if(param.verbose) then writeln('Handling the needed......');
   ld_handle_dynamic_library(dynstrarray(param.dynamiclibraryname));
  end
 else
  begin
   ld_handle_dynamic_library([]);
  end;
 if(param.verbose) then writeln('Reading Files......');
 objlist:=ld_generate_file_list(dynstrarray(param.filename));
 if(param.ExecutableType<=2) then
  begin
   if(param.verbose) then writeln('Linking ELF Files......');
   handlefile:=ld_link_file(objlist,param.EntryName,param.SmartLinking);
   if(param.verbose) then writeln('Generating ELF Files......');
   ld_handle_elf_file(param.OutputFileName,handlefile,param.align,
   false,(3-param.ExecutableType) shl 1,param.NoDefaultLibrary,not param.ReserveSymbol,
   param.DynamicLinker,param.Signature,param.startaddress);
   if(param.verbose) then writeln('File '+param.OutputFileName+' generated!');
  end
 else if(param.ExecutableType=3) then
  begin
   if(param.verbose) and (param.SmartLinking) then
   writeln('SmartLinking Relocatable ELF Files......')
   else if(param.verbose) then
   writeln('Linking Relocatable ELF Files......');
   ld_generate_relocatable_file(param.OutputFileName,objlist,param.EntryName,param.SmartLinking);
   if(param.verbose) then writeln('File '+param.OutputFileName+' generated!');
  end
 else
  begin
   if(param.verbose) then writeln('Linking ELF Files......');
   handlefile:=ld_link_file(objlist,param.EntryName,param.SmartLinking);
   if(param.verbose) then writeln('Generating EFI Files......');
   ld_handle_elf_file_to_efi_file(param.OutputFileName,handlefile,param.align,
   false,param.ExecutableType*2,not param.ReserveSymbol,param.startaddress);
   if(param.verbose) then writeln('File '+param.OutputFileName+' generated!');
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

