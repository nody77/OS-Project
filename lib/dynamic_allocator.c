/*
 * dynamic_allocator.c
 *
 *  Created on: Sep 21, 2023
 *      Author: HP
 */
#include <inc/assert.h>
#include <inc/string.h>
#include "../inc/dynamic_allocator.h"


//==================================================================================//
//============================== GIVEN FUNCTIONS ===================================//
//==================================================================================//

//=====================================================
// 1) GET BLOCK SIZE (including size of its meta data):
//=====================================================
uint32 get_block_size(void* va)
{
	struct BlockMetaData *curBlkMetaData = ((struct BlockMetaData *)va - 1) ;
	return curBlkMetaData->size ;
}

//===========================
// 2) GET BLOCK STATUS:
//===========================
int8 is_free_block(void* va)
{
	struct BlockMetaData *curBlkMetaData = ((struct BlockMetaData *)va - 1) ;
	return curBlkMetaData->is_free ;
}

//===========================================
// 3) ALLOCATE BLOCK BASED ON GIVEN STRATEGY:
//===========================================
void *alloc_block(uint32 size, int ALLOC_STRATEGY)
{
	void *va = NULL;
	switch (ALLOC_STRATEGY)
	{
	case DA_FF:
		va = alloc_block_FF(size);
		break;
	case DA_NF:
		va = alloc_block_NF(size);
		break;
	case DA_BF:
		va = alloc_block_BF(size);
		break;
	case DA_WF:
		va = alloc_block_WF(size);
		break;
	default:
		cprintf("Invalid allocation strategy\n");
		break;
	}
	return va;
}

//===========================
// 4) PRINT BLOCKS LIST:
//===========================

void print_blocks_list(struct MemBlock_LIST list)
{
	cprintf("=========================================\n");
	struct BlockMetaData* blk ;
	cprintf("\nDynAlloc Blocks List:\n");
	LIST_FOREACH(blk, &list)
	{
		cprintf("(size: %d, isFree: %d)\n", blk->size, blk->is_free) ;
	}
	cprintf("=========================================\n");

}
//
////********************************************************************************//
////********************************************************************************//

//==================================================================================//
//============================ REQUIRED FUNCTIONS ==================================//
//==================================================================================//

//==================================
// [1] INITIALIZE DYNAMIC ALLOCATOR:
//==================================
void initialize_dynamic_allocator(uint32 daStart, uint32 initSizeOfAllocatedSpace)
{
	//=========================================
	//DON'T CHANGE THESE LINES=================
	if (initSizeOfAllocatedSpace == 0)
		return ;
	//=========================================
	//=========================================

	//int* kh_ptr = (int*)KERNEL_HEAP_START;
	//int* kb_ptr = (int*)KERNEL_BASE;
	//int* ds_ptr = (int*)daStart;

	//TODO: [PROJECT'23.MS1 - #5] [3] DYNAMIC ALLOCATOR - initialize_dynamic_allocator()
	//panic("initialize_dynamic_allocator is not implemented yet");
	//cprintf("daStart --- > %d\n", daStart);
	//cprintf("initSizeOfAllocatedSpace is %d\n", initSizeOfAllocatedSpace);

	//long long kernel_heap_size = (KERNEL_HEAP_START - KERNEL_BASE);
	//cprintf("The size of the heap is %d ", kernel_heap_size);
	if(  daStart >=  KERNEL_HEAP_START &&  daStart <= KERNEL_HEAP_MAX){

		//LIST_INIT(&metaData); --> this line does not affect the run but we will see after implementing the rest
		//cprintf("Have entered the if condition " );
		struct BlockMetaData *meta = ((struct BlockMetaData *) daStart) ;
		meta->is_free = 1;
		meta->size = initSizeOfAllocatedSpace;
		//meta->prev_next_info.le_next =
		//cprintf(" Address of meta is %x\n meta.size = %d\n meta.is_free = %d\n" , meta , meta->size , meta->is_free );
		LIST_INSERT_HEAD(&metaData, meta);
		//daStart++;
	}
}

//=========================================
// [4] ALLOCATE BLOCK BY FIRST FIT:
//=========================================
void *alloc_block_FF(uint32 size)
{
	//TODO: [PROJECT'23.MS1 - #6] [3] DYNAMIC ALLOCATOR - alloc_block_FF()
	//panic("alloc_block_FF is not implemented yet");
	//cprintf("the allocated size = %d" , size);
	if(size == 0)
	{
		return NULL;
	}
	uint32 required_size_to_be_allocated = size + sizeOfMetaData();
	int found_block = 0;
	struct BlockMetaData * element;
	LIST_FOREACH(element , &metaData)
	{
		if(element->is_free == 1 && (element->size) == required_size_to_be_allocated)
		{
			element->is_free =0;
			found_block = 1;
			element->size  = required_size_to_be_allocated;
			return element+1;
		}
		else if (element->is_free == 1 && (element->size) > required_size_to_be_allocated)
		{
			element->is_free =0;
			found_block = 1;
			void * address = (void *)element +required_size_to_be_allocated;
			cprintf("the address is %x\n",address);
			struct BlockMetaData * newMetadata = (struct BlockMetaData *)address;
			cprintf("the address is %x\n",address);
			newMetadata->is_free = 1;
			newMetadata->size = (element->size) - (required_size_to_be_allocated);
			LIST_INSERT_AFTER(&metaData,element,newMetadata);
			element->size = required_size_to_be_allocated;
			cprintf("The address of the new meta data = %x\n" , newMetadata);
			cprintf("The address of the block found  = %x\n" , element);
			void * returned_va = (void *)element + sizeOfMetaData();
			return returned_va;
		}
	}
	if (found_block == 0)
	{
		int is_extended = (int)sbrk(size);
		if (is_extended == -1)
		{
			//cprintf("found =0 \n");
			return NULL;
		}
	}
	return NULL;
}
//=========================================
// [5] ALLOCATE BLOCK BY BEST FIT:
//=========================================
void *alloc_block_BF(uint32 size)
{
	//TODO: [PROJECT'23.MS1 - BONUS] [3] DYNAMIC ALLOCATOR - alloc_block_BF()
	panic("alloc_block_BF is not implemented yet");
	return NULL;
}

//=========================================
// [6] ALLOCATE BLOCK BY WORST FIT:
//=========================================
void *alloc_block_WF(uint32 size)
{
	panic("alloc_block_WF is not implemented yet");
	return NULL;
}

//=========================================
// [7] ALLOCATE BLOCK BY NEXT FIT:
//=========================================
void *alloc_block_NF(uint32 size)
{
	panic("alloc_block_NF is not implemented yet");
	return NULL;
}

//===================================================
// [8] FREE BLOCK WITH COALESCING:
//===================================================
void free_block(void *va)
{
	//TODO: [PROJECT'23.MS1 - #7] [3] DYNAMIC ALLOCATOR - free_block()
	panic("free_block is not implemented yet");
}

//=========================================
// [4] REALLOCATE BLOCK BY FIRST FIT:
//=========================================
void *realloc_block_FF(void* va, uint32 new_size)
{
	//TODO: [PROJECT'23.MS1 - #8] [3] DYNAMIC ALLOCATOR - realloc_block_FF()
	panic("realloc_block_FF is not implemented yet");
	return NULL;
}
