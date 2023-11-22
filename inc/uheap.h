#include <inc/dynamic_allocator.h>

#ifndef FOS_INC_UHEAP_H
#define FOS_INC_UHEAP_H 1

//Values for user heap placement strategy
#define UHP_PLACE_FIRSTFIT 	0x1
#define UHP_PLACE_BESTFIT 	0x2
#define UHP_PLACE_NEXTFIT 	0x3
#define UHP_PLACE_WORSTFIT 	0x4

//2020
#define UHP_USE_BUDDY 0

#define UHEAP_PAGE_ALLOCATOR_SIZE (USER_HEAP_MAX-(USER_HEAP_START + DYN_ALLOC_MAX_SIZE + PAGE_SIZE))/PAGE_SIZE


struct userBlock{
	uint8 is_free;
	uint32 size;
	uint32 virtual_address;
};

struct userBlock user_Page_Allocation_list[UHEAP_PAGE_ALLOCATOR_SIZE];

void *malloc(uint32 size);
void* smalloc(char *sharedVarName, uint32 size, uint8 isWritable);
void* sget(int32 ownerEnvID, char *sharedVarName);
void free(void* virtual_address);
void sfree(void* virtual_address);
void *realloc(void *virtual_address, uint32 new_size);

void initialize_user_page_list();




#endif
