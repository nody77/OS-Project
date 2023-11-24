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

	Start=(uint32*)daStart;
	SegmentBreak=(uint32*) (daStart + initSizeToAllocate) ;
	HardLimit=(uint32*)daLimit;

	if(SegmentBreak > HardLimit)
	{
		return E_NO_MEM;
	}
	int noOfPages = ROUNDUP(initSizeToAllocate,PAGE_SIZE) / PAGE_SIZE;
	uint32 va =daStart ;
	for(int i = 0 ; i <noOfPages ; i++)
	{
		//1)allocate
		struct FrameInfo * ptr;
		int ret = allocate_frame(&ptr);
		if (ret != E_NO_MEM )
		{
			//2)map
			map_frame(ptr_page_directory,ptr,va,PERM_WRITEABLE);//wrong permission for now
			ptr->va = va;
			va = va + PAGE_SIZE;
		}
		else
		{
			return E_NO_MEM;
		}
	}
	initialize_dynamic_allocator(daStart,initSizeToAllocate);
	initialize_page_list();
	return 0;
}


void* sbrk(int increment)
{
	//TODO: [PROJECT'23.MS2 - #02] [1] KERNEL HEAP - sbrk()

	if(increment > 0){

		int num_of_kilos;
		if(increment % PAGE_SIZE != 0)
		{
			num_of_kilos = ROUNDUP(increment , PAGE_SIZE); // size is the rounded up value of the increment
		}
		else
		{
			num_of_kilos = increment;
		}
		int num_of_iterations = num_of_kilos / PAGE_SIZE;
		uint32 * returnedBreak = SegmentBreak;
		for(int i = 0; i < num_of_iterations ; i++ )
		{
			if(SegmentBreak >= HardLimit)
			{
				panic("Invalid Access !!");
			}
			else
			{
				struct FrameInfo * frame_to_be_allocated ;
				int returned_frame = allocate_frame(&frame_to_be_allocated);
				if(returned_frame != 0)
				{

					panic("Memory is full !!");
				}
				else
				{

					int perm = PERM_WRITEABLE;
					map_frame(ptr_page_directory , frame_to_be_allocated, (uint32) SegmentBreak, perm);
					frame_to_be_allocated->va = (uint32)SegmentBreak;
					SegmentBreak = (uint32 *)((void *)SegmentBreak + PAGE_SIZE);
				}
			}
		}
		return (void *)returnedBreak;
	}
	else if (increment < 0){


	}
	return (void *) SegmentBreak;

	 /*increment > 0: move the segment break of the kernel to increase the size of its heap,
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
	//return (void*)-1 ;
	//panic("not implemented yet");
}
void initialize_page_list()
{
	for(int i = 0; i<KHEAP_PAGE_ALLOCATOR_SIZE ;i+=1)
	{
		Page_Allocation_list[i].is_free = 1 ;
	}

}
void* kmalloc(unsigned int size)
{
	//TODO: [PROJECT'23.MS2 - #03] [1] KERNEL HEAP - kmalloc()
	//refer to the project presentation and documentation for details
	// use "isKHeapPlacementStrategyFIRSTFIT() ..." functions to check the current strategy

	//change this "return" according to your answer
	//kpanic_into_prompt("kmalloc() is not implemented yet...!!");
	if (size <= DYN_ALLOC_MAX_BLOCK_SIZE)
	{
		void * va = alloc_block_FF(size);
		return va;
	}
	else
	{
		if(isKHeapPlacementStrategyFIRSTFIT() == 1)
		{
			int index , counter = 0 , flag_frames_found = 0;
			uint32 number_of_allocated_frames = ROUNDUP(size , PAGE_SIZE) / PAGE_SIZE;
			for(index = 0 ; index < KHEAP_PAGE_ALLOCATOR_SIZE ; index+=1)
			{
				if(counter == number_of_allocated_frames)
				{
					flag_frames_found = 1;
					break;
				}
				if(Page_Allocation_list[index].is_free == 0)
				{
					counter = 0;
				}
				else
				{
					counter+=1;
				}
			}
			if(flag_frames_found == 1)
			{
				int start_index = index - number_of_allocated_frames;
				uint32 va = (uint32)HardLimit + PAGE_SIZE + (PAGE_SIZE * start_index);
				struct FrameInfo * frame_to_be_allocated;
				for(int i = start_index ; i < (index); i += 1)
				{
					int return_allocated_frame = allocate_frame(&frame_to_be_allocated);
					if(return_allocated_frame == 0)
					{
						int return_mapped_frame  = map_frame(ptr_page_directory , frame_to_be_allocated , va , PERM_WRITEABLE);
						if(return_mapped_frame != 0)
						{
							return NULL;
						}
						if(i == start_index)
						{
							Page_Allocation_list[i].size = size;
						}
						else
						{
							Page_Allocation_list[i].size = 0;
						}
						Page_Allocation_list[i].is_free =0;
						Page_Allocation_list[i].virtual_address = va;
						frame_to_be_allocated->va = va;
						va += PAGE_SIZE;
					}
					else
					{
						return NULL;
					}

				}
				return (void *)((uint32)HardLimit + PAGE_SIZE + (PAGE_SIZE * start_index));
			}

		}
	}
	return NULL;
}


void kfree(void* virtual_address)
{

	//TODO: [PROJECT'23.MS2 - #04] [1] KERNEL HEAP - kfree()
	//refer to the project presentation and documentation for details
	// Write your code here, remove the panic and write your code
	//panic("kfree() is not implemented yet...!!");
	if(virtual_address >= (void *)Start && virtual_address <= (void *)SegmentBreak)
	{
		free_block(virtual_address);
	}
	else if(virtual_address >= (void *)((void *)HardLimit + PAGE_SIZE) && virtual_address < (void *)KERNEL_HEAP_MAX)
	{
		uint32 index = 0;
		for(index = 0 ; index < KHEAP_PAGE_ALLOCATOR_SIZE ; index+=1)
		{
			if(Page_Allocation_list[index].virtual_address == (uint32)virtual_address)
			{
				break;
			}
		}
		uint32 number_of_allocated_frames = ROUNDUP( Page_Allocation_list[index].size, PAGE_SIZE) / PAGE_SIZE;
		uint32 end_index = number_of_allocated_frames + index;
		for(int i = index; i < end_index; i+=1)
		{
			uint32 * ptr_page_table;
			struct FrameInfo * frame_to_be_deleted = get_frame_info(ptr_page_directory , Page_Allocation_list[i].virtual_address,&ptr_page_table);
			unmap_frame(ptr_page_directory , Page_Allocation_list[i].virtual_address);
			ptr_page_table[PTX(Page_Allocation_list[i].virtual_address)] = ptr_page_table[PTX(Page_Allocation_list[i].virtual_address)] & (~PERM_PRESENT);
			Page_Allocation_list[i].is_free = 1;
			Page_Allocation_list[i].size = 0;
			frame_to_be_deleted->va = 0;
			Page_Allocation_list[i].virtual_address = 0;
		}
	}
	else
	{
		panic("Invalid Address\n");
	}
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
	if(frame->va >= (uint32)HardLimit + PAGE_SIZE && frame->va < KERNEL_HEAP_MAX)
	{
		uint32 page_table_index = PTX(frame->va);
		uint32 offset = page_table_index & 0x00000FFF;
		uint32 returned_address = frame->va + offset;
		return (unsigned int)returned_address;
	}
	else if(frame->va >= (uint32)Start && frame->va < (uint32)SegmentBreak)
	{
		//uint32 offset = PGOFF(physical_address);
		//return (unsigned int)(PGADDR(PDX(frame->va) , PTX(frame->va) , offset));
		uint32 offset = physical_address & 0x00000FFF;
		//cprintf("The frame va = %x , the frame references = %d\n" ,frame->va,frame->references );
		uint32 returned_address = frame->va + offset;
		return (unsigned int)returned_address;
	}
	return 0;
}
unsigned int kheap_physical_address(unsigned int virtual_address)
{
	//TODO: [PROJECT'23.MS2 - #06] [1] KERNEL HEAP - kheap_physical_address()
	//refer to the project presentation and documentation for details
	// Write your code here, remove the panic and write your code
	//panic("kheap_physical_address() is not implemented yet...!!");
	if(virtual_address >=((unsigned int)HardLimit + PAGE_SIZE) && virtual_address <= KERNEL_HEAP_MAX)
	{
		uint32 offset = (uint32)(virtual_address & 0x00000FFF);
		uint32 *ptr_page_table;
		get_page_table(ptr_page_directory, virtual_address, &ptr_page_table);
		uint32 start_of_frame = ptr_page_table[PTX(virtual_address)] & 0xFFFFF000 ;
		return (unsigned int)(start_of_frame + offset);
	}
	else if(virtual_address >= (unsigned int)Start && virtual_address <= (unsigned int)SegmentBreak)
	{
		uint32 offset = (uint32)(virtual_address & 0x00000FFF);
		uint32 *ptr_page_table;
		get_page_table(ptr_page_directory, virtual_address, &ptr_page_table);
		uint32 start_of_frame = ptr_page_table[PTX(virtual_address)] & 0xFFFFF000 ;
		return (unsigned int)(start_of_frame + offset);
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
	//return NULL;
	//panic("krealloc() is not implemented yet...!!");
	if(virtual_address >= (void *) Start && virtual_address < (void *) SegmentBreak && new_size <= DYN_ALLOC_MAX_BLOCK_SIZE)
	{
		void * new_address = realloc_block_FF(virtual_address , new_size);
		return new_address;
	}
	else if (virtual_address >= (void *)((void *)HardLimit + PAGE_SIZE) && virtual_address < (void *)KERNEL_HEAP_MAX && new_size <= DYN_ALLOC_MAX_BLOCK_SIZE)
	{
		kfree(virtual_address);
		void * new_address = alloc_block_FF(new_size);
		return new_address;
	}
	else if (virtual_address >= (void *) Start && virtual_address < (void *) SegmentBreak && new_size > DYN_ALLOC_MAX_BLOCK_SIZE)
	{
		free_block(virtual_address);
		void * new_address = kmalloc(new_size);
		return new_address;
	}
	else if (new_size == 0)
	{
		kfree(virtual_address);
		return NULL;
	}
	else if (virtual_address == NULL)
	{
		void * new_address = kmalloc(new_size);
		return new_address;
	}
	else if (virtual_address >= (void *)((void *)HardLimit + PAGE_SIZE) && virtual_address < (void *)KERNEL_HEAP_MAX && new_size > DYN_ALLOC_MAX_BLOCK_SIZE)
	{
		uint32 index =0;
		for(index = 0 ; index < KHEAP_PAGE_ALLOCATOR_SIZE; index +=1)
		{
			 if((void *)Page_Allocation_list[index].virtual_address == virtual_address)
			 {
				 break;
			 }
		}
		if(new_size > Page_Allocation_list[index].size)
		{
			uint32 number_of_allocated_frames = ROUNDUP( Page_Allocation_list[index].size, PAGE_SIZE) / PAGE_SIZE;
			uint32 number_of_new_allocated_frames = ROUNDUP( new_size, PAGE_SIZE) / PAGE_SIZE;
			if(number_of_allocated_frames == number_of_new_allocated_frames)
			{
				Page_Allocation_list[index].size = new_size;
				return (void *)Page_Allocation_list[index].virtual_address;
			}
			else
			{
				kfree(virtual_address);
				void * new_address = kmalloc(new_size);
				return new_address;
			}
		}
		else if (new_size < Page_Allocation_list[index].size)
		{
			uint32 number_of_allocated_frames = ROUNDUP( Page_Allocation_list[index].size, PAGE_SIZE) / PAGE_SIZE;
			uint32 number_of_new_allocated_frames = ROUNDUP( new_size, PAGE_SIZE) / PAGE_SIZE;
			if(number_of_allocated_frames == number_of_new_allocated_frames)
			{
				Page_Allocation_list[index].size = new_size;
				return (void *)Page_Allocation_list[index].virtual_address;
			}
			else
			{
				uint32 number_of_pages_to_be_freed = number_of_allocated_frames - number_of_new_allocated_frames;
				for(int i = 0 ; i<number_of_pages_to_be_freed;i+=1)
				{
					index += 1;
				}
				for(int i = index ; i<number_of_allocated_frames; i+=1)
				{
					uint32 * ptr_page_table;
					struct FrameInfo * frame_to_be_deleted = get_frame_info(ptr_page_directory , Page_Allocation_list[i].virtual_address,&ptr_page_table);
					unmap_frame(ptr_page_directory , Page_Allocation_list[i].virtual_address);
					ptr_page_table[PTX(Page_Allocation_list[i].virtual_address)] = ptr_page_table[PTX(Page_Allocation_list[i].virtual_address)] & (~PERM_PRESENT);
					Page_Allocation_list[i].is_free = 1;
					Page_Allocation_list[i].size = 0;
					frame_to_be_deleted->va = 0;
					Page_Allocation_list[i].virtual_address = 0;
				}
				return (void *)Page_Allocation_list[index].virtual_address;
			}
		}
		else
		{
			return (void *)Page_Allocation_list[index].virtual_address;
		}
	}
	return NULL;
}
