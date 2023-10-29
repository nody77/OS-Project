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
			uint32 remaining_size = (element->size) - required_size_to_be_allocated;
			if(remaining_size >= sizeOfMetaData())
			{
				struct BlockMetaData * newMetadata = (struct BlockMetaData *)address;
				newMetadata->is_free = 1;
				newMetadata->size = (element->size) - (required_size_to_be_allocated);
				LIST_INSERT_AFTER(&metaData,element,newMetadata);
				element->size = required_size_to_be_allocated;
			}
			void * returned_va = (void *)element + sizeOfMetaData();
			return returned_va;
		}
	}
	if (found_block == 0)
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
					return element+1;
			}

			}
	int var = 0;
	struct BlockMetaData * flag;
		LIST_FOREACH(element , &metaData)
		{

			 if (element->is_free == 1 && (element->size) > required_size_to_be_allocated)
			 {
				 var = (element->size - required_size_to_be_allocated );
				 if(var < min)
				 {
					 cprintf("var=%d\n",var);
					 min = var;
					 NeedSbrk = 0;
				 }
			 }

		}
		LIST_FOREACH(element , &metaData)
				{
					 if ((element->size - required_size_to_be_allocated)==var)
					 {
//						 if(var<sizeOfMetaData())
//						 {
//							element->is_free =0;
//							element->size  = required_size_to_be_allocated + var;
//							NeedSbrk=0;
//							return element+1;
//						 }
						element->is_free =0;
						void * address = (void *)element +required_size_to_be_allocated;
						cprintf("the address is %x\n",address);
						struct BlockMetaData * newMetadata = (struct BlockMetaData *)address;
						cprintf("the address is %x\n",address);
						newMetadata->is_free = 1;
						newMetadata->size = (element->size) - (required_size_to_be_allocated);
						LIST_INSERT_AFTER(&metaData,element,newMetadata);
						element->size = required_size_to_be_allocated;
						//cprintf("The address of the new meta data = %x\n" , newMetadata);
						cprintf("The address of the block found  = %x\n" , element);

						void * returned_va = (void *)element + sizeOfMetaData();
						//cprintf("The address of the returned block  = %x\n" , returned_va);
						return returned_va;
						NeedSbrk=0;
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
		cprintf("Before ifs \n");
		struct BlockMetaData * ptr_to_before = LIST_PREV(ptr_to_deleted);
		struct BlockMetaData * ptr_to_after = LIST_NEXT(ptr_to_deleted);
		if(ptr_to_deleted == LIST_FIRST(&metaData))
		{
			if((ptr_to_after->is_free) == 0)
			{
				cprintf("Entered  if only head and next is not free \n");
				(ptr_to_deleted->is_free)= 1;
			}
			else if ((ptr_to_after->is_free) == 1)
			{
				cprintf("Entered  if only head and next is free \n");
				ptr_to_deleted->is_free=1;
				ptr_to_deleted->size = (ptr_to_deleted->size) + (ptr_to_after->size);
				ptr_to_after->is_free=0;
				ptr_to_after->size=0;
				//LIST_REMOVE(&metaData,ptr_to_after);
			}
		}
		else if (ptr_to_deleted == LIST_LAST(&metaData))
		{
			if((ptr_to_before->is_free) == 0)
			{
				cprintf("Entered  if only tail and next is not free \n");
				(ptr_to_deleted->is_free)= 1;
			}
			else if ((ptr_to_before->is_free) == 1)
			{
				cprintf("Entered  if only tail and next is free \n");
				ptr_to_before->size = (ptr_to_deleted->size) + (ptr_to_before->size);
				ptr_to_deleted->size = 0;
				ptr_to_deleted->is_free=0;
				//LIST_REMOVE(&metaData,ptr_to_deleted);
			}
		}
		else if ((ptr_to_after->is_free) == 0 &&(ptr_to_before->is_free) == 0)
		{
			// up  and down are full
			cprintf("Entered  if \n");
			(ptr_to_deleted->is_free)= 1;

		}
		else if ((ptr_to_after->is_free) == 1 &&(ptr_to_before->is_free) == 0)
		{
			// up is free
			cprintf("Entered  if up\n");
			(ptr_to_deleted->size)= (ptr_to_deleted->size) + (ptr_to_after->size);
			(ptr_to_deleted->is_free) = 1;
			ptr_to_after->is_free=0;
			ptr_to_after->size=0;
			//LIST_REMOVE(&metaData,ptr_to_after);

		}
		else if ((ptr_to_after->is_free) == 0 &&((ptr_to_before)->is_free) == 1)
		{
			// down is free
			cprintf("Entered  if down\n");
			((ptr_to_before)->size) =  ((ptr_to_before)->size) + (ptr_to_deleted->size);
			ptr_to_deleted->is_free=0;
			ptr_to_deleted->size=0;
			//LIST_REMOVE(&metaData,(ptr_to_deleted));
		}
		else if (((ptr_to_after)->is_free) == 1 &&((ptr_to_before)->is_free) == 1)
		{
			// both are free
			cprintf("Entered  if up and down\n");
			((ptr_to_before)->size ) = ((ptr_to_before)->size)  + (ptr_to_deleted->size) + ((ptr_to_after)->size);
			ptr_to_after->is_free=0;
			ptr_to_after->size=0;
			ptr_to_deleted->is_free=0;
			ptr_to_deleted->size=0;
			//LIST_REMOVE(&metaData,ptr_to_after);
			//LIST_REMOVE(&metaData,(ptr_to_deleted));
		}
	}
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
	struct BlockMetaData * ptr_to_be_changed_before = LIST_PREV(ptr_to_be_changed);
	struct BlockMetaData * ptr_to_be_changed_after = LIST_NEXT(ptr_to_be_changed);
	if ( va == NULL &&  new_size== 0)
	{
		//cprintf("The va = null and new size = 0\n");
		return NULL;
	}
	else if(va == NULL && new_size > 0)
	{
		//cprintf("The va is null only\n");
		return alloc_block_FF(new_size);

	}
	else if (va != NULL && new_size == 0)
	{
		//cprintf("The new size = 0 only\n");
		free_block(va);
		return NULL;
	}
	//HEAD
	else if(ptr_to_be_changed == LIST_FIRST(&metaData))
	{
		cprintf("The pointer is the head\n");
		if(ptr_to_be_changed->size > size && ptr_to_be_changed_after->is_free ==0)
		{
			//SIZED DEC , SPLIT , next not available
			cprintf("The size is small in head\n");
			void * address = ptr_void + size;
			uint32 remianing_size = ptr_to_be_changed->size - size;
			if (remianing_size >= sizeOfMetaData())
			{
				struct BlockMetaData * new_metadata = (struct BlockMetaData * ) address;
				new_metadata->is_free = 1;
				new_metadata->size = ptr_to_be_changed->size - size;
				ptr_to_be_changed->size = size;
				LIST_INSERT_AFTER(&metaData,ptr_to_be_changed,new_metadata);
			}
			return va;
		}
		else if(ptr_to_be_changed->size > size && ptr_to_be_changed_after->is_free == 1)
		{
			//SIZED DEC , SPLIT , merge
			//splite
			cprintf("The size is small in head\n");
			void * address = ptr_void + size;
			struct BlockMetaData * new_metadata = (struct BlockMetaData * ) address;
			new_metadata->is_free=1;
			new_metadata->size = ptr_to_be_changed->size - size;
			cprintf("The new metadata size before merging =  %d\n",new_metadata->size);
			ptr_to_be_changed->size = size;
			LIST_INSERT_AFTER(&metaData,ptr_to_be_changed,new_metadata);

			//merge
			new_metadata->size  = new_metadata->size + ptr_to_be_changed_after->size;
			cprintf("The size of next = %d\n" , ptr_to_be_changed_after->size);
			cprintf("The new metadata size after merging =  %d\n",new_metadata->size);
			ptr_to_be_changed_after->size=0;
			ptr_to_be_changed_after->is_free=0;

			return va;
		}
		else if ((ptr_to_be_changed->size + ptr_to_be_changed_after->size) < size && ptr_to_be_changed_after->is_free==1)
		{
			//SIZED INC ,SIZE NOT AVAILABLE
			cprintf("The pointer is in head and does not fit with the next\n");
			free_block(va);
			void * returned_ptr = alloc_block_FF(new_size);
			return returned_ptr;
		}
		else if ((ptr_to_be_changed->size + ptr_to_be_changed_after->size) > size && ptr_to_be_changed_after->is_free==1)
		{
			//SIZED INC , SIZE AVAILABLE,SPLITE
			cprintf("The pointer is in head and fits with the next\n");
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
			}
			else
			{
				ptr_to_be_changed->size += ptr_to_be_changed_after->size;
				ptr_to_be_changed_after->is_free=0;
				ptr_to_be_changed_after->size=0;
			}
			return va;
		}
		else if (ptr_to_be_changed->size < size &&ptr_to_be_changed_after->is_free==0)
		{
			//SIZED INC , NEXT NOT AVAILABLE
			cprintf("The pointer is in head  and the next is not free\n");
			free_block(va);
			void * returned_ptr = alloc_block_FF(new_size);
			return returned_ptr;
		}
	}
	//in middle COMPARE WITH NEXT
	else if (ptr_to_be_changed->size == size)
	{
		cprintf("Nothing will happen\n");
		return va;
	}
	else if (ptr_to_be_changed->size > size && ptr_to_be_changed_after->is_free == 0)
	{
		//SIZE DEC , SPLITE , NEXT IS NOT FREE
		//cprintf("The size is small\n");
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
		//SIZED DEC , SPLIT , MERGE

		//splite
		//cprintf("The size is small in head\n");
		void * address = ptr_void + size;
		struct BlockMetaData * new_metadata = (struct BlockMetaData * ) address;
		new_metadata->is_free=1;
		new_metadata->size = ptr_to_be_changed->size - size;
		ptr_to_be_changed->size = size;
		LIST_INSERT_AFTER(&metaData,ptr_to_be_changed,new_metadata);

		//merge
		new_metadata->size += ptr_to_be_changed_after->size;
		ptr_to_be_changed_after->size=0;
		ptr_to_be_changed_after->is_free=0;

		return va;
	}
	else if ((ptr_to_be_changed->size + ptr_to_be_changed_after->size) > size && ptr_to_be_changed_after->is_free==1)
	{
		// SIZE INC , AVAILABLE , SPLITE
		//cprintf("fits with the next\n");
		void * address = ptr_void + size;
		uint32 remaining_size = (ptr_to_be_changed->size + ptr_to_be_changed_after->size) - size;
		if(remaining_size >= sizeOfMetaData())
		{
			struct BlockMetaData * new_metadata = (struct BlockMetaData * ) address;
			new_metadata->is_free=1;
			new_metadata->size = (ptr_to_be_changed->size + ptr_to_be_changed_before->size) - size;
			ptr_to_be_changed->size = size;
			LIST_INSERT_AFTER(&metaData,ptr_to_be_changed_after,new_metadata);
			ptr_to_be_changed_after->is_free=0;
			ptr_to_be_changed_after->size=0;
		}
		else
		{
			ptr_to_be_changed->size += ptr_to_be_changed_after->size;
			ptr_to_be_changed_after->is_free=0;
			ptr_to_be_changed_after->size=0;
		}
		return va;
	}
	else if ((ptr_to_be_changed->size + ptr_to_be_changed_after->size) < size && ptr_to_be_changed_after->is_free==1)
	{
		// SIZE INC , NEXT AVAILABLE , BUT SIZE DOESNT FIT
		cprintf("does not fit with the next\n");
		free_block(va);
		void * returned_ptr = alloc_block_FF(new_size);
		return returned_ptr;
	}
	else if (ptr_to_be_changed->size < size &&ptr_to_be_changed_after->is_free==0)
	{
		// SIZE INC , NEXT NOT AVAILABLE
		cprintf("next is not free\n");
		free_block(va);
		void * returned_ptr = alloc_block_FF(new_size);
		return returned_ptr;
	}
	return NULL;
}
