#include "kheap.h"

#include <inc/memlayout.h>
#include <inc/dynamic_allocator.h>
#include "memory_manager.h"


int initialize_kheap_dynamic_allocator(uint32 daStart, uint32 initSizeToAllocate, uint32 daLimit)
{
	//TODO: [PROJECT'23.MS2 - #01] [1] KERNEL HEAP - initialize_kheap_dynamic_allocator()
	//Initialize the dynamic allocator of kernel heap with the given start address, size & limit
	//All pages in the given range should be allocated
	//Remember: call the initialize_dynamic_allocator(..) to complete the initialization
	//Return:
	//	On success: 0
	//	Otherwise (if no memory OR initial size exceed the given limit): E_NO_MEM

	//Comment the following line(s) before start coding...
	//panic("not implemented yet");
	
	int no_memory = 0;
	int initial_size_exceed_the_given_limit = 0;


	cprintf("daStart = %x\n",daStart);
	cprintf("====================================\n");
	cprintf("initSizeToAllocate =%d\n",initSizeToAllocate);
	cprintf("====================================\n");
	cprintf("daLimit =%x\n",daLimit);
	cprintf("====================================\n");


	Start=(uint32*)daStart;
	HardLimit=(uint32*)daLimit;
	SegmentBreak=(uint32*) (daStart + initSizeToAllocate) ;

	cprintf("Start = %x\n",Start);
	cprintf("====================================\n");
	cprintf("SegmentBreak =%x\n",SegmentBreak);
	cprintf("====================================\n");
	cprintf("HardLimit =%x\n",HardLimit);
	cprintf("====================================\n");
	int noOfPages = initSizeToAllocate/PAGE_SIZE;
	cprintf("noOfPages = %d\n",noOfPages);
	cprintf("====================================\n");

//	initialize_paging();
//
//	for(int i = 0 ; i<noOfPages ; i++)
//	{
//	   struct FrameInfo *ptr_frame_info ;
//	   allocate_frame(&ptr_frame_info);
//
//	}

	//initialize_dynamic_allocator(daStart,initSizeToAllocate);

	//int num = ROUNDUP(initSizeToAllocate,PAGE_SIZE);



	if(no_memory == 1 || initial_size_exceed_the_given_limit ==1)
	{
		return E_NO_MEM;
	}
	return 0;
	
}

void* sbrk(int increment)
{
	
	//TODO: [PROJECT'23.MS2 - #02] [1] KERNEL HEAP - sbrk()
	if(increment > 0){
		int num_of_kilos = ROUNDUP(increment , 4); // size is the rounded up value of the increment
		int size = num_of_kilos * (PAGE_SIZE/4);
		uint32 * returnedBreak = SegmentBreak;
		for(int i = 0; i < increment ; i++ ){
			
			//struct FrameInfo *frame_to_be_allocated = get_frame_info(ptr_page_directory , SegmentBreak, )
			if(SegmentBreak >= HardLimit){
				panic("Invalid Access !!");
			}
			else{
				struct FrameInfo * frame_to_be_allocated ;
				if(allocate_frame(&frame_to_be_allocated) == NULL){
					
					panic("Memory is full !!");
				}
				else{
					int perm = (~PERM_AVAILABLE) & (~PERM_BUFFERED) & (~PERM_MODIFIED) & PERM_PRESENT & PERM_USED & (~ PERM_USER) & PERM_WRITEABLE;
					map_frame(ptr_page_directory , frame_to_be_allocated, (uint32) SegmentBreak, perm);
					SegmentBreak = SegmentBreak + size;
					return (void *)returnedBreak;
				}
			}
		}
	}
	else if (increment < 0){

	}
	else {
		return (void *) SegmentBreak;
	}
	/* increment > 0: move the segment break of the kernel to increase the size of its heap,
	 * 				you should allocate pages and map them into the kernel virtual address space as necessary,
	 * 				and returns the address of the previous break (i.e. the beginning of newly mapped memory).
	 * increment = 0: just return the current position of the segment break
	 * increment < 0: move the segment break of the kernel to decrease the size of its heap,
	 * 				you should deallocate pages that no longer contain part of the heap as necessary.
	 * 				and returns the address of the new break (i.e. the end of the current heap space).
	 *
	 * NOTES:
	 * 	1) You should only have to allocate or deallocate pages if the segment break crosses a page boundary
	 * 	2) New segment break should be aligned on page-boundary to avoid "No Man's Land" problem
	 * 	3) Allocating additional pages for a kernel dynamic allocator will fail if the free frames are exhausted
	 * 		or the break exceed the limit of the dynamic allocator. If sbrk fails, kernel should panic(...)
	 */

	//MS2: COMMENT THIS LINE BEFORE START CODING====
	return (void*)-1 ;
	panic("not implemented yet");
}


void* kmalloc(unsigned int size)
{
	//TODO: [PROJECT'23.MS2 - #03] [1] KERNEL HEAP - kmalloc()
	//refer to the project presentation and documentation for details
	// use "isKHeapPlacementStrategyFIRSTFIT() ..." functions to check the current strategy

	//change this "return" according to your answer
	kpanic_into_prompt("kmalloc() is not implemented yet...!!");
	return NULL;
}

void kfree(void* virtual_address)
{
	//TODO: [PROJECT'23.MS2 - #04] [1] KERNEL HEAP - kfree()
	//refer to the project presentation and documentation for details
	// Write your code here, remove the panic and write your code
	panic("kfree() is not implemented yet...!!");
}

unsigned int kheap_virtual_address(unsigned int physical_address)
{
	//TODO: [PROJECT'23.MS2 - #05] [1] KERNEL HEAP - kheap_virtual_address()
	//refer to the project presentation and documentation for details
	// Write your code here, remove the panic and write your code
	//panic("kheap_virtual_address() is not implemented yet...!!");
	//EFFICIENT IMPLEMENTATION ~O(1) IS REQUIRED ==================
	//change this "return" according to your answer
	struct FrameInfo* frame = to_frame_info(physical_address);
	if (frame->references > 0)
	{
		return (unsigned int)frame->va;
	}
	return 0;
}
unsigned int kheap_physical_address(unsigned int virtual_address)
{
	//TODO: [PROJECT'23.MS2 - #06] [1] KERNEL HEAP - kheap_physical_address()
	//refer to the project presentation and documentation for details
	// Write your code here, remove the panic and write your code
	//panic("kheap_physical_address() is not implemented yet...!!");
	if(virtual_address >=KERNEL_HEAP_START && virtual_address <=KERNEL_HEAP_MAX)
	{
		uint32 *ptr_page_table;
		struct FrameInfo * frame = get_frame_info(ptr_page_directory,virtual_address,&ptr_page_table);
		uint32 physical_address = to_physical_address(frame);
		return (unsigned int)physical_address;
	}
	//change this "return" according to your answer
	return 0;
}


void kfreeall()
{
	panic("Not implemented!");

}

void kshrink(uint32 newSize)
{
	panic("Not implemented!");
}

void kexpand(uint32 newSize)
{
	panic("Not implemented!");
}




//=================================================================================//
//============================== BONUS FUNCTION ===================================//
//=================================================================================//
// krealloc():

//	Attempts to resize the allocated space at "virtual_address" to "new_size" bytes,
//	possibly moving it in the heap.
//	If successful, returns the new virtual_address, in which case the old virtual_address must no longer be accessed.
//	On failure, returns a null pointer, and the old virtual_address remains valid.

//	A call with virtual_address = null is equivalent to kmalloc().
//	A call with new_size = zero is equivalent to kfree().

void *krealloc(void *virtual_address, uint32 new_size)
{
	//TODO: [PROJECT'23.MS2 - BONUS#1] [1] KERNEL HEAP - krealloc()
	// Write your code here, remove the panic and write your code
	return NULL;
	panic("krealloc() is not implemented yet...!!");
}
