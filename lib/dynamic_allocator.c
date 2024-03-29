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
bool is_initialized = 0;
void initialize_dynamic_allocator(uint32 daStart, uint32 initSizeOfAllocatedSpace)
{
	//=========================================
	//DON'T CHANGE THESE LINES=================
	if (initSizeOfAllocatedSpace == 0)
		return ;
	is_initialized = 1;
	//=========================================
	//=========================================

	//TODO: [PROJECT'23.MS1 - #5] [3] DYNAMIC ALLOCATOR - initialize_dynamic_allocator()
	//panic("initialize_dynamic_allocator is not implemented yet");
	struct BlockMetaData *meta = (struct BlockMetaData *) daStart;
	meta->is_free = 1;
	meta->size = initSizeOfAllocatedSpace;
	LIST_INSERT_HEAD(&metaData, meta);
}


//=========================================
// [4] ALLOCATE BLOCK BY FIRST FIT:
//=========================================
void *alloc_block_FF(uint32 size)
{
	//TODO: [PROJECT'23.MS1 - #6] [3] DYNAMIC ALLOCATOR - alloc_block_FF()
	//panic("alloc_block_FF is not implemented yet");
	if(size == 0)
	{
		return NULL;
	}
	if (!is_initialized)
	{
		uint32 required_size = size + sizeOfMetaData();
		uint32 da_start = (uint32)sbrk(required_size);
		//get new break since it's page aligned! thus, the size can be more than the required one
		uint32 da_break = (uint32)sbrk(0);
		initialize_dynamic_allocator(da_start, da_break - da_start);
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
			uint32 * returned_va = (uint32 *)(element + 1);
			//cprintf("The returned va from element with the same size = %x , size = %d\n" , returned_va , element->size);
			return (void *)returned_va;
		}
		else if (element->is_free == 1 && (element->size) > required_size_to_be_allocated)
		{

			element->is_free =0;
			found_block = 1;
			struct BlockMetaData * address = (struct BlockMetaData *)((uint32)element + required_size_to_be_allocated);
			uint32 remaining_size = (element->size) - required_size_to_be_allocated;
			if(remaining_size >= sizeOfMetaData())
			{
				struct BlockMetaData * newMetadata = (struct BlockMetaData *)address;
				newMetadata->is_free = 1;
				newMetadata->size = (element->size) - (required_size_to_be_allocated);
				LIST_INSERT_AFTER(&metaData,element,newMetadata);
				element->size = required_size_to_be_allocated;
			}

			uint32 * returned_va = (uint32 *)(element + 1);
			//cprintf("The returned va from element with the bigger size = %x , size = %d\n" , returned_va , element->size);
			return (void *)returned_va;
		}
	}
	if (found_block == 0)
	{
		void * is_extended = (void *)sbrk(required_size_to_be_allocated);
		if (is_extended == (void *)-1)
		{
			return NULL;
		}
		else
		{
			uint32 new_size = (uint32)(ROUNDUP(required_size_to_be_allocated , PAGE_SIZE));
			element = LIST_LAST(&metaData);
			if(element->is_free == 1)
			{
				//the last element is free but its size does not fit
				element->is_free = 0;
				if (new_size == required_size_to_be_allocated)
				{
					element->size = required_size_to_be_allocated;
					uint32 * returned_va = (uint32 *)(element + 1);
					return (void *)returned_va;
				}
				else if (new_size > required_size_to_be_allocated)
				{
					element->size  = required_size_to_be_allocated;
					struct BlockMetaData * address = (struct BlockMetaData *)((uint32)element + element->size);
					struct BlockMetaData * newMetadata = address;
					newMetadata->is_free = 1;
					newMetadata->size = new_size - element->size;
					LIST_INSERT_AFTER(&metaData,element,newMetadata);
					uint32 * returned_va = (uint32 *)(element + 1);
					return (void *)returned_va;
				}
			}
			else
			{
				//the last element is not free
				struct BlockMetaData * address = (struct BlockMetaData *)((uint32)element + element->size);
				struct BlockMetaData * newMetadata = address;
				if(new_size == required_size_to_be_allocated)
				{
					newMetadata->is_free = 0;
					newMetadata->size = required_size_to_be_allocated;
					LIST_INSERT_AFTER(&metaData,element,newMetadata);
					uint32 * returned_va = (uint32 *)(newMetadata + 1);
					return (void *)returned_va;
				}
				else if (new_size > required_size_to_be_allocated)
				{
					newMetadata->is_free = 0;
					newMetadata->size = required_size_to_be_allocated;
					LIST_INSERT_AFTER(&metaData,element,newMetadata);
					struct BlockMetaData * address_for_new_metadata2 =  (struct BlockMetaData *)((uint32)newMetadata + newMetadata->size);
					struct BlockMetaData * newMetadata2 = address_for_new_metadata2;
					newMetadata2->is_free = 1;
					newMetadata2->size = new_size - newMetadata->size;
					LIST_INSERT_AFTER(&metaData,newMetadata,newMetadata2);
					uint32 * returned_va = (uint32 *)(newMetadata + 1);
					return (void *)returned_va;
				}

			}
		}
	}

	return NULL;
}
//=========================================
// [5] ALLOCATE BLOCK BY BEST FIT:
//=========================================
void *alloc_block_BF(uint32 size)
{
	int min= 99999999;
	//TODO: [PROJECT'23.MS1 - BONUS] [3] DYNAMIC ALLOCATOR - alloc_block_BF()
	//panic("alloc_block_BF is not implemented yet");
	if(size == 0)
	{
			return NULL;
	}
	uint32 required_size_to_be_allocated = size + sizeOfMetaData();
	int NeedSbrk = 1;
	struct BlockMetaData * element;
	LIST_FOREACH(element , &metaData)
	{
		if( element->is_free == 1 && (element->size) == required_size_to_be_allocated)
		{
			element->is_free =0;
			element->size  = required_size_to_be_allocated;
			NeedSbrk=0;
			return (void *)element + sizeOfMetaData();
		}

	}
	int var = 0;
	LIST_FOREACH(element , &metaData)
	{

		 if (element->is_free == 1 && (element->size) > required_size_to_be_allocated)
		 {
			 var = (element->size - required_size_to_be_allocated );
			 if(var < min)
			 {
				 min = var;
				 NeedSbrk = 0;
			 }
		 }

	}
	LIST_FOREACH(element , &metaData)
	{
		if ((element->size - required_size_to_be_allocated) == min)
		{
			if(min < sizeOfMetaData())
			{
				element->is_free =0;
				element->size  = required_size_to_be_allocated + min;
				NeedSbrk=0;
				return (void *)element + sizeOfMetaData();
			}
			else
			{
				element->is_free = 0;
				void * address = (void *)element + required_size_to_be_allocated;
				struct BlockMetaData * newMetadata = (struct BlockMetaData *)address;
				newMetadata->is_free = 1;
				newMetadata->size = min;
				LIST_INSERT_AFTER(&metaData,element,newMetadata);
				element->size = required_size_to_be_allocated;
				void * returned_va = (void *)element + sizeOfMetaData();
				return returned_va;
			}
		 }

	}

    if (NeedSbrk == 1)
	{
		int is_extended = (int)sbrk(size);
		if (is_extended == -1)
		{
			return NULL;
		}

	}
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
	//print_blocks_list(metaData);
	//TODO: [PROJECT'23.MS1 - #7] [3] DYNAMIC ALLOCATOR - free_block()
	//panic("free_block is not implemented yet");
	if(va == NULL)
	{
		return;
	}
	else
	{
		void * ptr_void = va - sizeOfMetaData();
		struct BlockMetaData * ptr_to_deleted = (struct BlockMetaData *)ptr_void;
		struct BlockMetaData * ptr_to_before = LIST_PREV(ptr_to_deleted);
		struct BlockMetaData * ptr_to_after = LIST_NEXT(ptr_to_deleted);
		if(ptr_to_deleted == LIST_FIRST(&metaData))
		{
			if((ptr_to_after->is_free) == 0)
			{
				//the deleted block is the head and the next is not free
				(ptr_to_deleted->is_free)= 1;
			}
			else if ((ptr_to_after->is_free) == 1)
			{
				//the deleted block is the head and the next is free
				ptr_to_deleted->is_free = 1;
				ptr_to_deleted->size += (ptr_to_after->size);
				ptr_to_after->is_free = 0;
				ptr_to_after->size = 0;
				LIST_REMOVE(&metaData , ptr_to_after);
			}
		}
		else if (ptr_to_deleted == LIST_LAST(&metaData))
		{
			if((ptr_to_before->is_free) == 0)
			{
				//the deleted block is the tail and the prev is not free
				(ptr_to_deleted->is_free) = 1;
			}
			else if ((ptr_to_before->is_free) == 1)
			{
				//the deleted block is the tail and the prev is free
				ptr_to_before->size += (ptr_to_deleted->size);
				ptr_to_deleted->size = 0;
				ptr_to_deleted->is_free = 0;
				LIST_REMOVE(&metaData , ptr_to_deleted);
			}
		}
		else if ((ptr_to_after->is_free) == 0 &&(ptr_to_before->is_free) == 0)
		{
			//up  and down are full
			(ptr_to_deleted->is_free)= 1;
		}
		else if ((ptr_to_after->is_free) == 1 && (ptr_to_before->is_free) == 0)
		{
			//up is free
			(ptr_to_deleted->size) += (ptr_to_after->size);
			(ptr_to_deleted->is_free) = 1;
			ptr_to_after->is_free = 0;
			ptr_to_after->size = 0;
			LIST_REMOVE(&metaData , ptr_to_after);
		}
		else if ((ptr_to_after->is_free) == 0 && (ptr_to_before->is_free) == 1)
		{
			//down is free
			(ptr_to_before->size) +=  (ptr_to_deleted->size);
			ptr_to_deleted->is_free = 0;
			ptr_to_deleted->size = 0;
			LIST_REMOVE(&metaData , ptr_to_deleted);
		}
		else if ((ptr_to_after->is_free) == 1 &&(ptr_to_before->is_free) == 1)
		{
			//both are free
			(ptr_to_before->size ) += (ptr_to_deleted->size) + (ptr_to_after->size);
			ptr_to_after->is_free = 0;
			ptr_to_after->size = 0;
			ptr_to_deleted->is_free = 0;
			ptr_to_deleted->size = 0;
			LIST_REMOVE(&metaData , ptr_to_deleted);
			LIST_REMOVE(&metaData , ptr_to_after);

		}
	}
	//print_blocks_list(metaData);
}

//=========================================
// [4] REALLOCATE BLOCK BY FIRST FIT:
//=========================================
void *realloc_block_FF(void* va, uint32 new_size)
{
	//TODO: [PROJECT'23.MS1 - #8] [3] DYNAMIC ALLOCATOR - realloc_block_FF()
	//panic("realloc_block_FF is not implemented yet");
	uint32 size = new_size + sizeOfMetaData();
	void * ptr_void = va - sizeOfMetaData();
	struct BlockMetaData * ptr_to_be_changed = (struct BlockMetaData *)ptr_void;
	struct BlockMetaData * ptr_to_be_changed_after = LIST_NEXT(ptr_to_be_changed);
	if ( va == NULL &&  new_size== 0)
	{
		//TEST 1 DONE
		return NULL;
	}
	else if(va == NULL && new_size > 0)
	{
		//TEST 2 DONE
		return alloc_block_FF(new_size);

	}
	else if (va != NULL && new_size == 0)
	{
		//TEST 2 DONE
		free_block(va);
		return NULL;
	}
	//HEAD OR IN THE MIDDLE
	else if (ptr_to_be_changed->size == size)
	{
		// TEST 3.2 DONE
		return va;
	}
	else if (ptr_to_be_changed->size > size && ptr_to_be_changed_after->is_free == 0)
	{
		//SIZE DEC , SPLITE , NEXT IS NOT FREE DONE
		// TEST 4.1
		cprintf ("1 \n");
		void * address = ptr_void + size;
		uint32 remaining_size = ptr_to_be_changed->size -size;
		if (remaining_size >= sizeOfMetaData())
		{
			struct BlockMetaData * new_metadata = (struct BlockMetaData * ) address;
			new_metadata->is_free=1;
			new_metadata->size = ptr_to_be_changed->size - size;
			ptr_to_be_changed->size = size;
			LIST_INSERT_AFTER(&metaData,ptr_to_be_changed,new_metadata);
		}
		return va;
	}
	else if (ptr_to_be_changed->size > size && ptr_to_be_changed_after->is_free == 1)
	{
		//SIZED DEC , SPLIT , MERGE WITH THE NEXT DONE
		//TEST 4.2
		cprintf ("2 \n");
		void * address = ptr_void + size;
		struct BlockMetaData * new_metadata = (struct BlockMetaData * ) address;
		new_metadata->is_free=1;
		new_metadata->size = (ptr_to_be_changed->size - size) + ptr_to_be_changed_after->size;
		ptr_to_be_changed->size = size;
		LIST_INSERT_AFTER(&metaData,ptr_to_be_changed,new_metadata);
		ptr_to_be_changed_after->is_free=0;
		ptr_to_be_changed_after->size=0;
		LIST_REMOVE(&metaData , ptr_to_be_changed_after);
		return va;
	}
	else if ((ptr_to_be_changed->size + ptr_to_be_changed_after->size) >= size && ptr_to_be_changed_after->is_free==1)
	{
		// SIZE INC , AVAILABLE , SPLITE OR TAKE THEM ALL DONE
		cprintf ("3 \n");
		void * address = ptr_void + size;
		uint32 remaining_size = (ptr_to_be_changed->size + ptr_to_be_changed_after->size) - size;
		if(remaining_size >= sizeOfMetaData())
		{
			struct BlockMetaData * new_metadata = (struct BlockMetaData * ) address;
			new_metadata->is_free=1;
			new_metadata->size = (ptr_to_be_changed->size + ptr_to_be_changed_after->size) - size;
			ptr_to_be_changed->size = size;
			LIST_INSERT_AFTER(&metaData,ptr_to_be_changed_after,new_metadata);
			ptr_to_be_changed_after->is_free=0;
			ptr_to_be_changed_after->size=0;
			LIST_REMOVE(&metaData , ptr_to_be_changed_after);
		}
		else
		{
			ptr_to_be_changed->size += ptr_to_be_changed_after->size;
			ptr_to_be_changed_after->is_free=0;
			ptr_to_be_changed_after->size=0;
			LIST_REMOVE(&metaData , ptr_to_be_changed_after);
		}
		return va;
	}
	else if ((ptr_to_be_changed->size + ptr_to_be_changed_after->size) < size && ptr_to_be_changed_after->is_free==1)
	{
		// SIZE INC , NEXT AVAILABLE , BUT SIZE DOESNT FIT DONE
		// TEST 3.3
		cprintf ("4 \n");
		void * returned_ptr = alloc_block_FF(new_size);
		if(returned_ptr == NULL)
		{
			//returned_ptr = alloc_block_FF(ptr_to_be_changed->size);
			returned_ptr = va;
		}
		else
		{
			free_block(va);
		}
		return returned_ptr;
	}
	else if (ptr_to_be_changed->size < size && ptr_to_be_changed_after->is_free==0)
	{
		// SIZE INC , NEXT NOT AVAILABLE DONE
		// TEST 3.4
		cprintf ("5 \n");
		void * returned_ptr = alloc_block_FF(new_size);
		if(returned_ptr == NULL)
		{
			//returned_ptr = alloc_block_FF(ptr_to_be_changed->size);
			returned_ptr = va;
		}
		else
		{
			free_block(va);
		}
		return returned_ptr;
	}
	return NULL;
}
