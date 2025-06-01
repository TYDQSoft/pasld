unit convmem;

interface

type natuint=SizeUint;
     natint=SizeInt;
     heap_item=bitpacked record
               haveprev:boolean;
               allocated:0..63;
               havenext:boolean;
               end;
     Pheap_item=^heap_item;
     heap_record=packed record
                 mem_start:Pointer;
                 mem_end:Pointer;
                 mem_block_power:byte;
                 item_max_pos:natuint;
                 end;
     heap_total_record=packed record
                       HeapEnable:array[1..7] of boolean;
                       HeapAttribute:array[1..7] of heap_record;
                       HeapCount:byte;
                       end;

const heap_have_prev:byte=$03;
      heap_have_next:byte=$82;
      heap_have_all:byte=$83;

var memheap:heap_total_record;

procedure tydq_heap_initialize(startpos:Pointer;totalsize:Natuint;
baseblockpower:byte;blockstep:byte;heapcount:byte);
function tydq_getmem(size:natuint):Pointer;
function tydq_getmemsize(ptr:Pointer):natuint;
function tydq_allocmem(size:natuint):Pointer;
procedure tydq_freemem(var ptr:Pointer);
procedure tydq_reallocmem(var ptr:Pointer;size:natuint);
procedure tydq_move(const Source;var dest;Size:natuint);

implementation

function heap_initialize(startpos,endpos:Pointer;blockpower:byte):heap_record;
var res:heap_record;
begin
 res.mem_start:=Pointer(startpos); res.mem_end:=Pointer(endpos);
 res.mem_block_power:=blockpower; res.item_max_pos:=0;
 heap_initialize:=res;
end;
procedure tydq_heap_initialize(startpos:Pointer;totalsize:Natuint;
baseblockpower:byte;blockstep:byte;heapcount:byte);
var i:byte;
    heapunit,totalheapblock:Natuint;
    tempptr:Pointer;
begin
 memheap.HeapCount:=heapcount; i:=1; heapunit:=0;
 while(i<=heapcount)do
  begin
   heapunit:=heapunit shl 1+1;
   inc(i);
  end;
 totalheapblock:=totalsize div heapunit; tempptr:=startpos;
 for i:=1 to heapcount do
  begin
   memheap.HeapEnable[i]:=true;
   memheap.HeapAttribute[i].mem_block_power:=baseblockpower+blockstep*(i-1);
   memheap.HeapAttribute[i].mem_start:=tempptr;
   memheap.HeapAttribute[i].mem_end:=tempptr+totalheapblock shl (i-1);
   tempptr:=tempptr+totalheapblock shl (i-1);
   memheap.HeapAttribute[i].item_max_pos:=0;
  end;
end;
function heap_get_total_size(heap:heap_record):natuint;
begin
 heap_get_total_size:=Natuint(heap.mem_end-heap.mem_start);
end;
function heap_conv_addr_to_index(heap:heap_record;addr:Pointer;isitem:Boolean):natuint;
begin
 if(isitem) then heap_conv_addr_to_index:=(heap.mem_end-addr) shr heap.mem_block_power
 else heap_conv_addr_to_index:=(addr-heap.mem_start) shr heap.mem_block_power+1;
end;
function heap_conv_index_to_addr(heap:heap_record;index:natuint;isitem:boolean):Pointer;
begin
 if(isitem) then heap_conv_index_to_addr:=Pointer(heap.mem_end-index)
 else heap_conv_index_to_addr:=Pointer(heap.mem_start+(index-1) shl heap.mem_block_power);
end;
function heap_conv_index_to_item(heap:heap_record;index:natuint):heap_item;
begin
 heap_conv_index_to_item:=Pheap_item(heap.mem_end-index*sizeof(heap_item))^;
end;
function heap_conv_mem_to_item(heap:heap_record;mem:Pointer):heap_item;
var index:natuint;
begin
 index:=Natuint(mem-heap.mem_start) shr heap.mem_block_power+1;
 heap_conv_mem_to_item:=Pheap_item(mem-index)^;
end;
function heap_get_mem_count(heap:heap_record;ptr:Pointer):natuint;
var i1,i2,index:natuint;
    tempitem:heap_item;
begin
 if(ptr=nil) or (ptr<heap.mem_start) or (ptr>heap.mem_end) then exit(0);
 index:=heap_conv_addr_to_index(heap,ptr,false);
 i1:=index; i2:=index;
 tempitem:=heap_conv_index_to_item(heap,i1);
 if(tempitem.havenext) and (tempitem.haveprev) then
  begin
   while(i1<heap.item_max_pos)do
    begin
     tempitem:=heap_conv_index_to_item(heap,i1);
     if(tempitem.havenext=false) then break;
     inc(i1);
    end;
   while(i2>1)do
    begin
     tempitem:=heap_conv_index_to_item(heap,i2);
     if(tempitem.haveprev=false) then break;
     dec(i2);
    end;
   heap_get_mem_count:=i1-i2+1;
  end
 else if(tempitem.havenext) then
  begin
   while(i1<heap.item_max_pos)do
    begin
     tempitem:=heap_conv_index_to_item(heap,i1);
     if(tempitem.havenext=false) then break;
     inc(i1);
    end;
   heap_get_mem_count:=(i1-index+1);
  end
 else if(tempitem.haveprev) then
  begin
   while(i2>1)do
    begin
     tempitem:=heap_conv_index_to_item(heap,i2);
     if(tempitem.haveprev=false) then break;
     dec(i2);
    end;
   heap_get_mem_count:=(index-i2+1);
  end
 else
  begin
   heap_get_mem_count:=1;
  end;
end;
function heap_get_mem_size(heap:heap_record;ptr:Pointer):natuint;
var i1,i2,index:natuint;
    tempitem:heap_item;
begin
 if(ptr=nil) or (ptr<heap.mem_start) or (ptr>heap.mem_end) then exit(0);
 index:=heap_conv_addr_to_index(heap,ptr,false);
 i1:=index; i2:=index;
 tempitem:=heap_conv_index_to_item(heap,i1);
 if(tempitem.havenext) and (tempitem.haveprev) then
  begin
   while(i1<heap.item_max_pos)do
    begin
     tempitem:=heap_conv_index_to_item(heap,i1);
     if(tempitem.havenext=false) then break;
     inc(i1);
    end;
   while(i2>1)do
    begin
     tempitem:=heap_conv_index_to_item(heap,i2);
     if(tempitem.haveprev=false) then break;
     dec(i2);
    end;
   heap_get_mem_size:=(i1-i2+1) shl heap.mem_block_power;
  end
 else if(tempitem.havenext) then
  begin
   while(i1<heap.item_max_pos)do
    begin
     tempitem:=heap_conv_index_to_item(heap,i1);
     if(tempitem.havenext=false) then break;
     inc(i1);
    end;
   heap_get_mem_size:=(i1-index+1) shl heap.mem_block_power;
  end
 else if(tempitem.haveprev) then
  begin
   while(i2>1)do
    begin
     tempitem:=heap_conv_index_to_item(heap,i2);
     if(tempitem.haveprev=false) then break;
     dec(i2);
    end;
   heap_get_mem_size:=(index-i2+1) shl heap.mem_block_power;
  end
 else
  begin
   heap_get_mem_size:=1 shl heap.mem_block_power;
  end;
end;
function heap_get_mem_start(heap:heap_record;ptr:Pointer):Pointer;
var i1,index:natuint;
    tempitem:heap_item;
begin
 if(ptr=nil) or (ptr<heap.mem_start) or (ptr>heap.mem_end) then exit(nil);
 index:=heap_conv_addr_to_index(heap,ptr,false);
 tempitem:=heap_conv_index_to_item(heap,index);
 i1:=index;
 if(tempitem.haveprev) then
  begin
   while(i1>0)do
    begin
     tempitem:=heap_conv_index_to_item(heap,i1);
     if(tempitem.haveprev=false) then break;
     dec(i1);
    end;
   heap_get_mem_start:=heap.mem_start+(i1-1) shl heap.mem_block_power;
  end
 else
  begin
   heap_get_mem_start:=heap.mem_start+(index-1) shl heap.mem_block_power;
  end;
end;
function heap_request_mem(var heap:heap_record;size:natuint;meminit:boolean):Pointer;
var blockcount:SizeUint;
    i1,i2,i3,i4:natuint;
    tempptr:Pheap_item;
    tempmemptr:Pqword;
    totalsize:natuint;
begin
 totalsize:=heap_get_total_size(heap);
 blockcount:=(size+1 shl heap.mem_block_power-1) shr heap.mem_block_power;
 if(blockcount=0) then heap_request_mem:=nil
 else
  begin
   {Search for empty block which is in heap.item_max_pos
    If it is suitable,allocate it in heap.item_max_pos
    else,raise the item_max_pos for allocating memory}
   if(heap.item_max_pos=0) and (blockcount shl heap.mem_block_power+blockcount<=totalsize) then
    begin
     i1:=1;
     while(i1<=blockcount)do
      begin
       tempptr:=heap_conv_index_to_addr(heap,i1,true);
       tempmemptr:=heap_conv_index_to_addr(heap,i1,false);
       if(i1>1) and (i1<blockcount) then
       Pbyte(tempptr)^:=heap_have_all
       else if(i1>1) then
       Pbyte(tempptr)^:=heap_have_prev
       else
       Pbyte(tempptr)^:=heap_have_next;
       if(meminit) then
        begin
         for i2:=1 to 1 shl heap.mem_block_power shr 3 do (tempmemptr+i2-1)^:=0;
        end;
       inc(i1);
      end;
     heap_request_mem:=heap.mem_start;
     inc(heap.item_max_pos,blockcount);
    end
   else if(heap.item_max_pos>0) then
    begin
     i1:=1; i2:=0;
     while(i1<=heap.item_max_pos)do
      begin
       tempptr:=heap_conv_index_to_addr(heap,i1,true);
       if(tempptr^.allocated=0) and (i2<blockcount) then inc(i2)
       else if(tempptr^.allocated=0) then break
       else i2:=0;
       inc(i1);
      end;
     if(i2=0) and ((heap.item_max_pos+blockcount)
     shl heap.mem_block_power+(heap.item_max_pos+blockcount)<=totalsize) then
      begin
       i1:=1;
       while(i1<=blockcount)do
        begin
         tempptr:=heap_conv_index_to_addr(heap,heap.item_max_pos+i1,true);
         tempmemptr:=heap_conv_index_to_addr(heap,heap.item_max_pos+i1,false);
         if(i1>1) and (i1<blockcount) then
         Pbyte(tempptr)^:=heap_have_all
         else if(i1>1) then
         Pbyte(tempptr)^:=heap_have_prev
         else
         Pbyte(tempptr)^:=heap_have_next;
         if(meminit) then
          begin
           for i4:=1 to 1 shl heap.mem_block_power shr 3 do (tempmemptr+i4-1)^:=0;
          end;
         inc(i1);
        end;
       heap_request_mem:=heap.mem_start+heap.item_max_pos shl heap.mem_block_power;
       inc(heap.item_max_pos,blockcount);
      end
     else if(i2=0) then
      begin
       heap_request_mem:=nil;
      end
     else
      begin
       i3:=i1-i2+1;
       while(i3<=i1)do
        begin
         tempptr:=heap_conv_index_to_addr(heap,i3,true);
         tempmemptr:=heap_conv_index_to_addr(heap,i3,false);
         if(i3>i1-i2+1) and (i3<i1) then
         Pbyte(tempptr)^:=heap_have_all
         else if(i3>i1-i2+1) then
         Pbyte(tempptr)^:=heap_have_prev
         else
         Pbyte(tempptr)^:=heap_have_next;
         if(meminit) then
          begin
           for i4:=1 to 1 shl heap.mem_block_power shr 3 do (tempmemptr+i4-1)^:=0;
          end;
         inc(i3);
        end;
       heap_request_mem:=heap.mem_start+(i1-i2) shl heap.mem_block_power;
      end;
    end
   else heap_request_mem:=nil;
  end;
end;
procedure heap_free_mem(var heap:heap_record;var ptr:Pointer;forcenil:boolean);
var start:Pointer;
    index,i,blockcount:natuint;
    tempptr:Pheap_item;
begin
 if(ptr=nil) then exit;
 start:=heap_get_mem_start(heap,ptr);
 index:=heap_conv_addr_to_index(heap,start,true);
 blockcount:=heap_get_mem_size(heap,ptr) shr heap.mem_block_power;
 i:=1;
 while(i<=blockcount)do
  begin
   tempptr:=heap_conv_index_to_addr(heap,index+i-1,true);
   if(Pbyte(tempptr)^<>0) then Pbyte(tempptr)^:=0;
   inc(i);
  end;
 i:=heap.item_max_pos;
 while(i>0)do
  begin
   tempptr:=heap_conv_index_to_addr(heap,i-1,true);
   if(Pbyte(tempptr)^ and $7E<>0) then break;
   dec(i);
  end;
 heap.item_max_pos:=i;
 if(forcenil) then ptr:=nil;
end;
procedure heap_move_mem(heap:heap_record;src,dest:Pointer);
var start1,start2:Pqword;
    size1,size2,i:natuint;
begin
 if(src=nil) or (dest=nil) then exit;
 start1:=heap_get_mem_start(heap,src);
 start2:=heap_get_mem_start(heap,dest);
 size1:=heap_get_mem_size(heap,src);
 size2:=heap_get_mem_size(heap,dest);
 if(size1<>0) and (size2<>0) then
  begin
   if(size1>size2) then
    begin
     for i:=1 to size2 shr 3 do (start2+i-1)^:=(start1+i-1)^;
    end
   else
    begin
     for i:=1 to size1 shr 3 do (start2+i-1)^:=(start1+i-1)^;
    end;
  end;
end;
function tydq_getmem(size:natuint):Pointer;
var i:byte;
    ptr:Pointer;
begin
 i:=memheap.HeapCount; ptr:=nil;
 while(i>0)do
  begin
   if(size>=1 shl memheap.HeapAttribute[i].mem_block_power) or (i=1) then
    begin
     ptr:=heap_request_mem(memheap.HeapAttribute[i],size,false);
     if(ptr<>nil) then break;
    end;
   dec(i);
  end;
 tydq_getmem:=ptr;
end;
function tydq_getmemstart(ptr:Pointer):Pointer;
var i:byte;
    resptr:Pointer;
begin
 i:=memheap.HeapCount; resptr:=nil;
 while(i>0)do
  begin
   if(ptr>=memheap.HeapAttribute[i].mem_start) and (ptr<memheap.HeapAttribute[i].mem_end) then
    begin
     resptr:=heap_get_mem_start(memheap.HeapAttribute[i],ptr);
     if(resptr<>nil) then break;
    end;
   dec(i);
  end;
 tydq_getmemstart:=resptr;
end;
function tydq_getmemsize(ptr:Pointer):natuint;
var i:byte;
    size:Natuint;
begin
 i:=memheap.HeapCount; size:=0;
 while(i>0)do
  begin
   if(ptr>=memheap.HeapAttribute[i].mem_start) and (ptr<memheap.HeapAttribute[i].mem_end) then
    begin
     size:=heap_get_mem_size(memheap.HeapAttribute[i],ptr);
     if(size>0) then break;
    end;
   dec(i);
  end;
 tydq_getmemsize:=size;
end;
function tydq_allocmem(size:natuint):Pointer;
var i:byte;
    ptr:Pointer;
begin
 i:=memheap.HeapCount; ptr:=nil;
 while(i>0)do
  begin
   if(size>=1 shl memheap.HeapAttribute[i].mem_block_power) or (i=1) then
    begin
     ptr:=heap_request_mem(memheap.HeapAttribute[i],size,true);
     if(ptr<>nil) then break;
    end;
   dec(i);
  end;
 tydq_allocmem:=ptr;
end;
procedure tydq_freemem(var ptr:Pointer);
var i:byte;
begin
 i:=memheap.HeapCount;
 while(i>0)do
  begin
   if(ptr>=memheap.HeapAttribute[i].mem_start) and (ptr<memheap.HeapAttribute[i].mem_end) then
    begin
     heap_free_mem(memheap.HeapAttribute[i],ptr,true);
     if(ptr=nil) then break;
    end;
   dec(i);
  end;
end;
procedure tydq_move(const Source;var dest;Size:natuint);
var i,j,offset,total,rest:Natuint;
    {$IFDEF CPU64}
    q1,q2:Pqword;
    {$ENDIF}
    d1,d2:Pdword;
    w1,w2:Pword;
    b1,b2:Pbyte;
    conflict:boolean;
begin
 conflict:=false;
 if((Pointer(@Dest)>=Pointer(@Source)) and (Pointer(@Dest)<=Pointer(@Source)+Size))
 or((Pointer(@Source)>=Pointer(@Dest)) and (Pointer(@Source)<=Pointer(@Dest)+Size)) then
 conflict:=true;
 if(conflict=false) then
  begin
   {$IFDEF CPU64}
   total:=size shr 3; rest:=size-total shl 3;
   q1:=Pqword(@Source); q2:=Pqword(@Dest);
   for i:=1 to total do (q2+i-1)^:=(q1+i-1)^;
   offset:=total shl 3;
   if(rest>=4) then
    begin
     d1:=PDword(Pointer(q1)+offset); d2:=PDword(Pointer(q2)+offset); d2^:=d1^;
     inc(offset,4); dec(rest,4);
    end;
   if(rest>=2) then
    begin
     w1:=Pword(Pointer(q1)+offset); w2:=Pword(Pointer(q2)+offset); w2^:=w1^;
     inc(offset,2); dec(rest,2);
    end;
   if(rest>=1) then
    begin
     b1:=Pbyte(Pointer(q1)+offset); b2:=Pbyte(Pointer(q2)+offset); b2^:=b1^;
     inc(offset); dec(rest);
    end;
   {$ELSE}
   total:=size shr 2; rest:=size-total shl 2;
   d1:=Pdword(@Source); d2:=Pdword(@Dest);
   for i:=1 to total do (d2+i-1)^:=(d1+i-1)^;
   offset:=total shl 2;
   if(rest>=2) then
    begin
     w1:=Pword(Pointer(q1)+offset); w2:=Pword(Pointer(q2)+offset); w2^:=w1^;
     inc(offset,2); dec(rest,2);
    end;
   if(rest>=1) then
    begin
     b1:=Pbyte(Pointer(q1)+offset); b2:=Pbyte(Pointer(q2)+offset); b2^:=b1^;
     inc(offset); dec(rest);
    end;
   {$ENDIF}
  end
 else
  begin
   {$IFDEF CPU64}
   total:=size shr 3; rest:=size-total shl 3;
   q1:=Pqword(@Source); q2:=Pqword(@Dest);
   offset:=size;
   if(rest>=4) then
    begin
     d1:=PDword(Pointer(q1)+offset); d2:=PDword(Pointer(q2)+offset); d2^:=d1^;
     dec(offset,4); dec(rest,4);
    end;
   if(rest>=2) then
    begin
     w1:=Pword(Pointer(q1)+offset); w2:=Pword(Pointer(q2)+offset); w2^:=w1^;
     dec(offset,2); dec(rest,2);
    end;
   if(rest>=1) then
    begin
     b1:=Pbyte(Pointer(q1)+offset); b2:=Pbyte(Pointer(q2)+offset); b2^:=b1^;
     dec(offset); dec(rest);
    end;
   for i:=total downto 1 do (q2+i-1)^:=(q1+i-1)^;
   {$ELSE}
   total:=size shr 2; rest:=size-total shl 2;
   d1:=Pdword(@Source); d2:=Pdword(@Dest);
   offset:=size;
   if(rest>=2) then
    begin
     w1:=Pword(Pointer(q1)+offset); w2:=Pword(Pointer(q2)+offset); w2^:=w1^;
     dec(offset,2); dec(rest,2);
    end;
   if(rest>=1) then
    begin
     b1:=Pbyte(Pointer(q1)+offset); b2:=Pbyte(Pointer(q2)+offset); b2^:=b1^;
     dec(offset); dec(rest);
    end;
   for i:=total downto 1 do (d2+i-1)^:=(d1+i-1)^;
   {$ENDIF}
  end;
end;
procedure tydq_reallocmem(var ptr:Pointer;size:natuint);
var newptr,oldptr:Pointer;
    size1,size2,sizemin:Natuint;
begin
 newptr:=tydq_allocmem(size);
 size1:=tydq_getmemsize(newptr); size2:=tydq_getmemsize(ptr);
 if(size1=size2) then exit;
 oldptr:=tydq_getmemstart(ptr);
 if(size1>size2) then sizemin:=size2 else sizemin:=size1;
 tydq_move(oldptr,newptr,sizemin);
 tydq_freemem(oldptr);
 ptr:=newptr;
end;

end.

