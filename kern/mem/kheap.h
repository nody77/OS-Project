#ifndef FOS_KERN_KHEAP_H_
#define FOS_KERN_KHEAP_H_

#ifndef FOS_KERNEL
# error "This is a FOS kernel header; user programs should not #include it"
#endif

#include <inc/queue.h>
#include <inc/types.h>
#include <inc/memlayout.h>
#include <inc/dynamic_allocator.h>

struct Block
{
	uint8 is_free;
	uint32 virtual_address;
	struct FrameInfo * frame;
};


/*2017*/
uint32 _KHeapPlacementStrategy;
//Values for user heap placement strategy
#define KHP_PLACE_CONTALLOC 0x0
#define KHP_PLACE_FIRSTFIT 	0x1
#define KHP_PLACE_BESTFIT 	0x2
#define KHP_PLACE_NEXTFIT 	0x3
#define KHP_PLACE_WORSTFIT 	0x4

#define KHEAP_PAGE_ALLOCATOR_SIZE (KERNEL_HEAP_MAX-(KERNEL_HEAP_START + DYN_ALLOC_MAX_SIZE + PAGE_SIZE))/PAGE_SIZE


static inline void setKHeapPlacementStrategyCONTALLOC(){_KHeapPlacementStrategy = KHP_PLACE_CONTALLOC;}
static inline void setKHeapPlacementStrategyFIRSTFIT(){_KHeapPlacementStrategy = KHP_PLACE_FIRSTFIT;}
static inline void setKHeapPlacementStrategyBESTFIT(){_KHeapPlacementStrategy = KHP_PLACE_BESTFIT;}
static inline void setKHeapPlacementStrategyNEXTFIT(){_KHeapPlacementStrategy = KHP_PLACE_NEXTFIT;}
static inline void setKHeapPlacementStrategyWORSTFIT(){_KHeapPlacementStrategy = KHP_PLACE_WORSTFIT;}

static inline uint8 isKHeapPlacementStrategyCONTALLOC(){if(_KHeapPlacementStrategy == KHP_PLACE_CONTALLOC) return 1; return 0;}
static inline uint8 isKHeapPlacementStrategyFIRSTFIT(){if(_KHeapPlacementStrategy == KHP_PLACE_FIRSTFIT) return 1; return 0;}
static inline uint8 isKHeapPlacementStrategyBESTFIT(){if(_KHeapPlacementStrategy == KHP_PLACE_BESTFIT) return 1; return 0;}
static inline uint8 isKHeapPlacementStrategyNEXTFIT(){if(_KHeapPlacementStrategy == KHP_PLACE_NEXTFIT) return 1; return 0;}
static inline uint8 isKHeapPlacementStrategyWORSTFIT(){if(_KHeapPlacementStrategy == KHP_PLACE_WORSTFIT) return 1; return 0;}

//***********************************

void* kmalloc(unsigned int size);
void kfree(void* virtual_address);
void *krealloc(void *virtual_address, unsigned int new_size);
void initialize_page_list();

unsigned int kheap_virtual_address(unsigned int physical_address);
unsigned int kheap_physical_address(unsigned int virtual_address);

int numOfKheapVACalls ;


/*2023*/
//TODO: [PROJECT'23.MS2 - #01] [1] KERNEL HEAP - initialization: add suitable code here
//pointer to start , pointer to segment break , pointer to hard limit
uint32 *Start;
uint32 *SegmentBreak;
uint32 *HardLimit;
struct Block Page_Allocation_list[KHEAP_PAGE_ALLOCATOR_SIZE];
//====================================================================================

#endif // FOS_KERN_KHEAP_H_
