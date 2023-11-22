#include <inc/lib.h>
#include<lib/syscall.c>
//==================================================================================//
//============================== GIVEN FUNCTIONS ===================================//
//==================================================================================//

int FirstTimeFlag = 1;
void InitializeUHeap()
{
	if(FirstTimeFlag)
	{
#if UHP_USE_BUDDY
		initialize_buddy();
		cprintf("BUDDY SYSTEM IS INITIALIZED\n");
#endif
		FirstTimeFlag = 0;
	}
}

//==================================================================================//
//============================ REQUIRED FUNCTIONS ==================================//
//==================================================================================//

//=============================================
// [1] CHANGE THE BREAK LIMIT OF THE USER HEAP:
//=============================================
/*2023*/
void* sbrk(int increment)
{
	return (void*) sys_sbrk(increment);
}

void initialize_user_page_list()
{
	for(int i = 0; i<UHEAP_PAGE_ALLOCATOR_SIZE ;i+=1)
	{
		user_Page_Allocation_list[i].is_free=1;
	}

}
//=================================
// [2] ALLOCATE SPACE IN USER HEAP:
//=================================
void* malloc(uint32 size)
{
	//==============================================================
	//DON'T CHANGE THIS CODE========================================
	InitializeUHeap();
	if (size == 0) return NULL ;
	//==============================================================
	//TODO: [PROJECT'23.MS2 - #09] [2] USER HEAP - malloc() [User Side]
	// Write your code here, remove the panic and write your code
	//panic("malloc() is not implemented yet...!!");
	if (size <= DYN_ALLOC_MAX_BLOCK_SIZE)
	{
			void * va = alloc_block_FF(size);
			return va;
	}
	else
	{
		uint32 * HardLimit = (uint32*)sys_hardlimit();
		if(sys_isUHeapPlacementStrategyFIRSTFIT() == 1) //sys_isUHeapPlacementStrategyBESTFIT()
			{
					int index , counter = 0 , flag_frames_found = 0;
					uint32 number_of_allocated_frames = ROUNDUP(size , PAGE_SIZE) / PAGE_SIZE;
					for(index = 0 ; index < UHEAP_PAGE_ALLOCATOR_SIZE ; index+=1)
					{
						if(counter == number_of_allocated_frames)
						{
							flag_frames_found = 1;
							break;
						}
						if(user_Page_Allocation_list[index].is_free == 0)
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
						uint32 startVa = va;
						for(int i = start_index ; i < (index); i += 1)
						{
							if(i == start_index)
							{
								user_Page_Allocation_list[i].size = size;
							}
							else
							{
								user_Page_Allocation_list[i].size = 0;
							}

							    user_Page_Allocation_list[i].is_free =0;
							    user_Page_Allocation_list[i].virtual_address = va;
								va += PAGE_SIZE;
						}
						sys_allocate_user_mem(startVa,size);
						return (void *)((uint32)HardLimit + PAGE_SIZE + (PAGE_SIZE * start_index));

					}
			}
	}

	return NULL;
	//Use sys_isUHeapPlacementStrategyFIRSTFIT() and	sys_isUHeapPlacementStrategyBESTFIT()
	//to check the current strategy

}


//=================================
// [3] FREE SPACE FROM USER HEAP:
//=================================
void free(void* virtual_address)
{
	void * SegmentBrk = sys_sbrk(0);
	//uint32 * HardLimit = (uint32*)sys_hardlimit();
	void * HardLimit =sys_hardlimit();
	if(virtual_address>= (void*) USER_HEAP_START && virtual_address < SegmentBrk)
	{
		free_block(virtual_address);
	}
	else if (virtual_address >=  (HardLimit+PAGE_SIZE) && virtual_address <(void*) USER_HEAP_MAX)
	{
		uint32 size;
		uint32 index = 0;
		for(index = 0 ; index < UHEAP_PAGE_ALLOCATOR_SIZE ; index+=1)
				{
					if(user_Page_Allocation_list[index].virtual_address == (uint32)virtual_address)
					{
						size = user_Page_Allocation_list[index].size;
						break;
					}
				}

				uint32 number_of_allocated_frames = ROUNDUP( user_Page_Allocation_list[index].size, PAGE_SIZE) / PAGE_SIZE;
				uint32 end_index = number_of_allocated_frames + index;
				for(int i = index; i < end_index; i+=1)
				{
					user_Page_Allocation_list[i].is_free = 1;
					user_Page_Allocation_list[i].size = 0;
					user_Page_Allocation_list[i].virtual_address = 0;
				}
				sys_free_user_mem((uint32)virtual_address,size);

	}
	else
	{
		panic("invalid address\n");
	}
}



//=================================
// [4] ALLOCATE SHARED VARIABLE:
//=================================
void* smalloc(char *sharedVarName, uint32 size, uint8 isWritable)
{
	//==============================================================
	//DON'T CHANGE THIS CODE========================================
	InitializeUHeap();
	if (size == 0) return NULL ;
	//==============================================================
	panic("smalloc() is not implemented yet...!!");
	return NULL;
}

//========================================
// [5] SHARE ON ALLOCATED SHARED VARIABLE:
//========================================
void* sget(int32 ownerEnvID, char *sharedVarName)
{
	//==============================================================
	//DON'T CHANGE THIS CODE========================================
	InitializeUHeap();
	//==============================================================
	// Write your code here, remove the panic and write your code
	panic("sget() is not implemented yet...!!");
	return NULL;
}


//==================================================================================//
//============================== BONUS FUNCTIONS ===================================//
//==================================================================================//

//=================================
// REALLOC USER SPACE:
//=================================
//	Attempts to resize the allocated space at "virtual_address" to "new_size" bytes,
//	possibly moving it in the heap.
//	If successful, returns the new virtual_address, in which case the old virtual_address must no longer be accessed.
//	On failure, returns a null pointer, and the old virtual_address remains valid.

//	A call with virtual_address = null is equivalent to malloc().
//	A call with new_size = zero is equivalent to free().

//  Hint: you may need to use the sys_move_user_mem(...)
//		which switches to the kernel mode, calls move_user_mem(...)
//		in "kern/mem/chunk_operations.c", then switch back to the user mode here
//	the move_user_mem() function is empty, make sure to implement it.
void *realloc(void *virtual_address, uint32 new_size)
{
	//==============================================================
	//DON'T CHANGE THIS CODE========================================
	InitializeUHeap();
	//==============================================================

	// Write your code here, remove the panic and write your code
	panic("realloc() is not implemented yet...!!");
	return NULL;

}


//=================================
// FREE SHARED VARIABLE:
//=================================
//	This function frees the shared variable at the given virtual_address
//	To do this, we need to switch to the kernel, free the pages AND "EMPTY" PAGE TABLES
//	from main memory then switch back to the user again.
//
//	use sys_freeSharedObject(...); which switches to the kernel mode,
//	calls freeSharedObject(...) in "shared_memory_manager.c", then switch back to the user mode here
//	the freeSharedObject() function is empty, make sure to implement it.

void sfree(void* virtual_address)
{
	// Write your code here, remove the panic and write your code
	panic("sfree() is not implemented yet...!!");
}


//==================================================================================//
//========================== MODIFICATION FUNCTIONS ================================//
//==================================================================================//

void expand(uint32 newSize)
{
	panic("Not Implemented");

}
void shrink(uint32 newSize)
{
	panic("Not Implemented");

}
void freeHeap(void* virtual_address)
{
	panic("Not Implemented");

}
