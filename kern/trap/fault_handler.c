/*
 * fault_handler.c
 *
 *  Created on: Oct 12, 2022
 *      Author: HP
 */

#include "trap.h"
#include <kern/proc/user_environment.h>
#include "../cpu/sched.h"
#include "../disk/pagefile_manager.h"
#include "../mem/memory_manager.h"

#include <kern/mem/kheap.h>
//2014 Test Free(): Set it to bypass the PAGE FAULT on an instruction with this length and continue executing the next one
// 0 means don't bypass the PAGE FAULT
uint8 bypassInstrLength = 0;

//===============================
// REPLACEMENT STRATEGIES
//===============================
//2020
void setPageReplacmentAlgorithmLRU(int LRU_TYPE)
{
	assert(LRU_TYPE == PG_REP_LRU_TIME_APPROX || LRU_TYPE == PG_REP_LRU_LISTS_APPROX);
	_PageRepAlgoType = LRU_TYPE ;
}
void setPageReplacmentAlgorithmCLOCK(){_PageRepAlgoType = PG_REP_CLOCK;}
void setPageReplacmentAlgorithmFIFO(){_PageRepAlgoType = PG_REP_FIFO;}
void setPageReplacmentAlgorithmModifiedCLOCK(){_PageRepAlgoType = PG_REP_MODIFIEDCLOCK;}
/*2018*/ void setPageReplacmentAlgorithmDynamicLocal(){_PageRepAlgoType = PG_REP_DYNAMIC_LOCAL;}
/*2021*/ void setPageReplacmentAlgorithmNchanceCLOCK(int PageWSMaxSweeps){_PageRepAlgoType = PG_REP_NchanceCLOCK;  page_WS_max_sweeps = PageWSMaxSweeps;}

//2020
uint32 isPageReplacmentAlgorithmLRU(int LRU_TYPE){return _PageRepAlgoType == LRU_TYPE ? 1 : 0;}
uint32 isPageReplacmentAlgorithmCLOCK(){if(_PageRepAlgoType == PG_REP_CLOCK) return 1; return 0;}
uint32 isPageReplacmentAlgorithmFIFO(){if(_PageRepAlgoType == PG_REP_FIFO) return 1; return 0;}
uint32 isPageReplacmentAlgorithmModifiedCLOCK(){if(_PageRepAlgoType == PG_REP_MODIFIEDCLOCK) return 1; return 0;}
/*2018*/ uint32 isPageReplacmentAlgorithmDynamicLocal(){if(_PageRepAlgoType == PG_REP_DYNAMIC_LOCAL) return 1; return 0;}
/*2021*/ uint32 isPageReplacmentAlgorithmNchanceCLOCK(){if(_PageRepAlgoType == PG_REP_NchanceCLOCK) return 1; return 0;}

//===============================
// PAGE BUFFERING
//===============================
void enableModifiedBuffer(uint32 enableIt){_EnableModifiedBuffer = enableIt;}
uint8 isModifiedBufferEnabled(){  return _EnableModifiedBuffer ; }

void enableBuffering(uint32 enableIt){_EnableBuffering = enableIt;}
uint8 isBufferingEnabled(){  return _EnableBuffering ; }

void setModifiedBufferLength(uint32 length) { _ModifiedBufferLength = length;}
uint32 getModifiedBufferLength() { return _ModifiedBufferLength;}

//===============================
// FAULT HANDLERS
//===============================

//Handle the table fault
void table_fault_handler(struct Env * curenv, uint32 fault_va)
{
	//panic("table_fault_handler() is not implemented yet...!!");
	//Check if it's a stack page
	uint32* ptr_table;
#if USE_KHEAP
	{
		ptr_table = create_page_table(curenv->env_page_directory, (uint32)fault_va);
	}
#else
	{
		__static_cpt(curenv->env_page_directory, (uint32)fault_va, &ptr_table);
	}
#endif
}

//Handle the page fault

void page_fault_handler(struct Env * curenv, uint32 fault_va)
{
	//env_page_ws_print(curenv);
#if USE_KHEAP
		struct WorkingSetElement *victimWSElement = NULL;
		uint32 wsSize = LIST_SIZE(&(curenv->page_WS_list));
#else
		int iWS =curenv->page_last_WS_index;
		uint32 wsSize = env_page_ws_get_size(curenv);
#endif

		//cprintf("REPLACEMENT=========================WS Size = %d\n", wsSize );
		//refer to the project presentation and documentation for details
		if(isPageReplacmentAlgorithmFIFO())
		{
			if(wsSize < (curenv->page_WS_max_size))
			{
				//cprintf("PLACEMENT=========================WS Size = %d\n", wsSize );
				//TODO: [PROJECT'23.MS2 - #15] [3] PAGE FAULT HANDLER - Placement
				// Write your code here, remove the panic and write your code
				//panic("page_fault_handler().PLACEMENT is not implemented yet...!!");
				struct FrameInfo * frame_to_be_allocated;
				int return_frame_allocation = allocate_frame(&frame_to_be_allocated);
				if (return_frame_allocation == 0)
				{
					//cprintf("entered return_frame_allocation == 0\n");
					int return_map_allcoation = map_frame(curenv->env_page_directory ,frame_to_be_allocated, fault_va,(PERM_PRESENT|PERM_USER|PERM_WRITEABLE));
					if (return_map_allcoation == 0 )
					{
						//cprintf("entered return_map_allcoation == 0\n");
						int return_read_pageFile = pf_read_env_page(curenv , (void *)fault_va);
						if(return_read_pageFile == E_PAGE_NOT_EXIST_IN_PF)
						{
							//cprintf("entered  E_PAGE_NOT_EXIST_IN_PF \n");
							// check if the page file is illegal access
							//if((uint32 *)fault_va < curenv->start || (uint32 *)fault_va > curenv->hardLimit)
							if((fault_va >= USER_HEAP_START && fault_va < USER_HEAP_MAX))
							{
								//cprintf("heap page \n");
								struct WorkingSetElement * wseToBeAdded = env_page_ws_list_create_element(curenv,fault_va);

								//update the working set list to add the new frame
								if (wseToBeAdded==NULL)
									return;
								//struct WorkingSetElement * lastWse = LIST_LAST(&(curenv->page_WS_list));
								LIST_INSERT_TAIL(&(curenv->page_WS_list) , wseToBeAdded);
								//cprintf(" LIST_SIZE(&curenv->page_WS_list) = %d\n", LIST_SIZE(&curenv->page_WS_list));
								//cprintf(" curenv->page_WS_max_size = %d\n", curenv->page_WS_max_size);
								if (LIST_SIZE(&curenv->page_WS_list)==curenv->page_WS_max_size){

									curenv->page_last_WS_element = LIST_FIRST(&curenv->page_WS_list);
									//LIST_LAST(&curenv->page_WS_list)->prev_next_info.le_next = LIST_FIRST(&curenv->page_WS_list);
								}

								else
									curenv->page_last_WS_element = NULL;
								return;

							}
							else if ((fault_va <USTACKTOP && fault_va>= USTACKBOTTOM))
							{
								//cprintf("stack page\n");
								struct WorkingSetElement * wseToBeAdded = env_page_ws_list_create_element(curenv,fault_va);
								if (wseToBeAdded==NULL)
									return;
								//update the working set list to add the new frame
								LIST_INSERT_TAIL(&(curenv->page_WS_list) , wseToBeAdded);
								if (LIST_SIZE(&curenv->page_WS_list)==curenv->page_WS_max_size){

									curenv->page_last_WS_element = LIST_FIRST(&curenv->page_WS_list);
									//LIST_LAST(&curenv->page_WS_list)->prev_next_info.le_next = LIST_FIRST(&curenv->page_WS_list);
								}

								else
									curenv->page_last_WS_element = NULL;
								//env_page_ws_print(curenv);
								return;
							}
							else
							{
								//cprintf("kill env\n");
								sched_kill_env(curenv->env_id);
								return;
							}
						}
						//cprintf("entered Found in PF \n");
						//env_page_ws_print(curenv);
						struct WorkingSetElement * wseToBeAdded = env_page_ws_list_create_element(curenv,fault_va);
						if (wseToBeAdded==NULL)
							return;
						//update the working set list to add the new frame
						LIST_INSERT_TAIL(&(curenv->page_WS_list) , wseToBeAdded);
						if (LIST_SIZE(&curenv->page_WS_list)==curenv->page_WS_max_size){

							curenv->page_last_WS_element = LIST_FIRST(&curenv->page_WS_list);
							//LIST_LAST(&curenv->page_WS_list)->prev_next_info.le_next = LIST_FIRST(&curenv->page_WS_list);
						}

						else
							curenv->page_last_WS_element = NULL;
						//env_page_ws_print(curenv);
						return;
					}
				}
				//refer to the project presentation and documentation for details
			}
			else
			{
				//TODO: [PROJECT'23.MS3 - #1] [1] PAGE FAULT HANDLER - FIFO Replacement
				// Write your code here, remove the panic and write your code
				//panic("page_fault_handler() FIFO Replacement is not implemented yet...!!");
				//cprintf("FIFO REPLACEMENT \n\n");
				struct WorkingSetElement* toBeRemoved = curenv->page_last_WS_element ;
				int temp = 0;
				uint32 page_permissions = pt_get_page_permissions(curenv->env_page_directory, (uint32)(toBeRemoved->virtual_address) );
				if(page_permissions & PERM_MODIFIED)
				{
					uint32 *ptr_page_table =NULL ;
					struct FrameInfo* modified_page_frame_info = get_frame_info(curenv->env_page_directory,(uint32)(toBeRemoved->virtual_address),&ptr_page_table);
					pf_update_env_page(curenv, (uint32)(toBeRemoved->virtual_address), modified_page_frame_info);
				}

				struct WorkingSetElement* element;
				if(LIST_NEXT(toBeRemoved) == NULL)
				{
					temp = 1;
					curenv->page_last_WS_element = LIST_FIRST(&(curenv->page_WS_list));
				}
				//if toBeRemoved is the first element
				else if (LIST_PREV(toBeRemoved) == NULL)
				{
					temp = 2;
					curenv->page_last_WS_element = LIST_NEXT(toBeRemoved);
				}
				//if toBeRemoved is in the middle
				else
				{
					curenv->page_last_WS_element = LIST_NEXT(toBeRemoved);
				}
				unmap_frame(curenv->env_page_directory, (uint32)(toBeRemoved->virtual_address));

				LIST_REMOVE(&(curenv->page_WS_list),toBeRemoved);

				kfree(toBeRemoved);
				struct FrameInfo * frame_to_be_allocated;
				int return_frame_allocation = allocate_frame(&frame_to_be_allocated);
				if (return_frame_allocation == 0)
				{

					int return_map_allcoation = map_frame(curenv->env_page_directory ,frame_to_be_allocated, fault_va,(PERM_PRESENT|PERM_USER|PERM_WRITEABLE));
					if (return_map_allcoation == 0 )
					{

						int return_read_pageFile = pf_read_env_page(curenv , (void *)fault_va);
						if(return_read_pageFile == E_PAGE_NOT_EXIST_IN_PF)
						{

							//check userHeap & userstack
							if((fault_va >= USER_HEAP_START && fault_va < USER_HEAP_MAX)||(fault_va <USTACKTOP && fault_va>= USTACKBOTTOM))
							{
								struct WorkingSetElement * wseToBeAdded = env_page_ws_list_create_element(curenv,fault_va);

								if (wseToBeAdded==NULL)
									return;

								//if last element
								if(temp==1)
								{
									LIST_INSERT_TAIL(&(curenv->page_WS_list) , wseToBeAdded);
								}
								//if first element
								else if(temp == 2)
								{
									LIST_INSERT_HEAD(&(curenv->page_WS_list) , wseToBeAdded);
								}
								//if in the middle
								else
								{
									LIST_INSERT_BEFORE(&(curenv->page_WS_list), curenv->page_last_WS_element , wseToBeAdded);
								}
								return;

							}
							else
							{
								sched_kill_env(curenv->env_id);
								return;
							}
						}
						else
						{
							struct WorkingSetElement * wseToBeAdded = env_page_ws_list_create_element(curenv,fault_va);

							if (wseToBeAdded==NULL)
								return;

							//if last element
							if(temp==1)
							{
								LIST_INSERT_TAIL(&(curenv->page_WS_list) , wseToBeAdded);
							}
							//if first element
							else if(temp == 2)
							{
								LIST_INSERT_HEAD(&(curenv->page_WS_list) , wseToBeAdded);
							}
							//if in the middle
							else
							{
								LIST_INSERT_BEFORE(&(curenv->page_WS_list), curenv->page_last_WS_element , wseToBeAdded);
							}
							return;
						}

					}
				}
		   }
		}
		if(isPageReplacmentAlgorithmLRU(PG_REP_LRU_LISTS_APPROX))
		{
			//TODO: [PROJECT'23.MS3 - #2] [1] PAGE FAULT HANDLER - LRU Replacement
			// Write your code here, remove the panic and write your code
			//panic("page_fault_handler() LRU Replacement is not implemented yet...!!");
			//env_page_ws_print(curenv);
		if(LIST_SIZE(&curenv->ActiveList)+LIST_SIZE(&curenv->SecondList)<curenv->page_WS_max_size)
		{
			int found_in_second_list = 0;
			struct WorkingSetElement * element;
			LIST_FOREACH(element , &curenv->SecondList)
			{
				if(ROUNDDOWN(fault_va,PAGE_SIZE) == element->virtual_address)
				{
					found_in_second_list= 1;
					break;
				}
			}
			if(found_in_second_list == 1)
			{
				LIST_REMOVE(&curenv->SecondList , element);
				pt_set_page_permissions(curenv->env_page_directory , element->virtual_address , PERM_PRESENT , 0);
				struct WorkingSetElement * tail=LIST_LAST(&curenv->ActiveList);
				LIST_REMOVE(&curenv->ActiveList,tail);
				pt_set_page_permissions(curenv->env_page_directory,tail->virtual_address,0,PERM_PRESENT);
				LIST_INSERT_HEAD(&curenv->SecondList,tail);
				LIST_INSERT_HEAD(&curenv->ActiveList,element);
				return;
			}
			else
			{
				struct FrameInfo * frame_to_be_allocated;
				int return_frame_allocation = allocate_frame(&frame_to_be_allocated);
				if (return_frame_allocation == 0)
				{
					int return_map_allcoation = map_frame(curenv->env_page_directory ,frame_to_be_allocated, fault_va,(PERM_PRESENT|PERM_USER|PERM_WRITEABLE));
					if (return_map_allcoation == 0 )
					{
						int return_read_pageFile = pf_read_env_page(curenv , (void *)fault_va);
						if(return_read_pageFile==E_PAGE_NOT_EXIST_IN_PF)
						{
							if((fault_va >= USER_HEAP_START && fault_va < USER_HEAP_MAX))
							{
								struct WorkingSetElement * wseToBeAdded = env_page_ws_list_create_element(curenv,fault_va);
								if (wseToBeAdded==NULL)
									return;
								if(LIST_SIZE(&curenv->ActiveList)<curenv->ActiveListSize)
								{
									LIST_INSERT_HEAD(&curenv->ActiveList,wseToBeAdded);
								}else
								{
									struct WorkingSetElement * tail=LIST_LAST(&curenv->ActiveList);
									LIST_REMOVE(&curenv->ActiveList,tail);
									pt_set_page_permissions(curenv->env_page_directory,tail->virtual_address,0,PERM_PRESENT);
									LIST_INSERT_HEAD(&curenv->SecondList,tail);
									LIST_INSERT_HEAD(&curenv->ActiveList,wseToBeAdded);
								}
								return;
							}
							else if ((fault_va <USTACKTOP && fault_va>= USTACKBOTTOM))
							{
								struct WorkingSetElement * wseToBeAdded = env_page_ws_list_create_element(curenv,fault_va);
								if (wseToBeAdded==NULL)
									return;
								if(LIST_SIZE(&curenv->ActiveList)<curenv->ActiveListSize)
								{
									LIST_INSERT_HEAD(&curenv->ActiveList,wseToBeAdded);
								}else
								{
									struct WorkingSetElement * tail=LIST_LAST(&curenv->ActiveList);
									LIST_REMOVE(&curenv->ActiveList,tail);
									pt_set_page_permissions(curenv->env_page_directory,tail->virtual_address,0,PERM_PRESENT);
									LIST_INSERT_HEAD(&curenv->SecondList,tail);
									LIST_INSERT_HEAD(&curenv->ActiveList,wseToBeAdded);
								}
								return;
							}
							else
							{
								sched_kill_env(curenv->env_id);
								return;
							}
						}
						else
						{
							struct WorkingSetElement * wseToBeAdded = env_page_ws_list_create_element(curenv,fault_va);
							if (wseToBeAdded==NULL)
								return;
							if(LIST_SIZE(&curenv->ActiveList)<curenv->ActiveListSize)
							{
								LIST_INSERT_HEAD(&curenv->ActiveList,wseToBeAdded);
							}
							else
							{
								struct WorkingSetElement * tail=LIST_LAST(&curenv->ActiveList);
								LIST_REMOVE(&curenv->ActiveList,tail);
								pt_set_page_permissions(curenv->env_page_directory,tail->virtual_address,0,PERM_PRESENT);
								LIST_INSERT_HEAD(&curenv->SecondList,tail);
								LIST_INSERT_HEAD(&curenv->ActiveList,wseToBeAdded);
							}
							return;
						}
					}
				}
			}
		}
		else{
				//LRU Replacement
			int found_in_second_list = 0;
			struct WorkingSetElement * element;
			LIST_FOREACH(element, &curenv->SecondList){
				if(ROUNDDOWN(fault_va , PAGE_SIZE) == (uint32)element->virtual_address){

					found_in_second_list = 1;
					break;
				}
			}
			if(found_in_second_list == 1){

				struct WorkingSetElement* FIFO_tail = LIST_LAST(&curenv->ActiveList);
				// Remove Last Element from FIFO
				LIST_REMOVE(&curenv->ActiveList , FIFO_tail);
				// Insert the element in the Head of FIFO
				LIST_REMOVE(&curenv->SecondList , element);
				LIST_INSERT_HEAD(&curenv->ActiveList, element);
				pt_set_page_permissions(curenv->env_page_directory, fault_va, PERM_PRESENT,0);
				//struct WorkingSetElement* previous_element = LIST_PREV(element);
				LIST_INSERT_HEAD(&curenv->SecondList, FIFO_tail);
				pt_set_page_permissions(curenv->env_page_directory, FIFO_tail->virtual_address, 0, PERM_PRESENT);
			}
		else
		{
			//LRU Replacement
			int found_in_second_list = 0;
			struct WorkingSetElement * element;
			LIST_FOREACH(element, &curenv->SecondList){
				if(ROUNDDOWN(fault_va , PAGE_SIZE) == (uint32)element->virtual_address){

					found_in_second_list = 1;
					break;
				}
			}
			if(found_in_second_list == 1){

				struct WorkingSetElement* FIFO_tail = LIST_LAST(&curenv->ActiveList);
				// Remove Last Element from FIFO
				LIST_REMOVE(&curenv->ActiveList , FIFO_tail);
				// Insert the element in the Head of FIFO
				LIST_REMOVE(&curenv->SecondList , element);
				LIST_INSERT_HEAD(&curenv->ActiveList, element);
				pt_set_page_permissions(curenv->env_page_directory, fault_va, PERM_PRESENT,0);
				//struct WorkingSetElement* previous_element = LIST_PREV(element);
				LIST_INSERT_HEAD(&curenv->SecondList, FIFO_tail);
				pt_set_page_permissions(curenv->env_page_directory, FIFO_tail->virtual_address, 0, PERM_PRESENT);
			}
			else
			{
				struct FrameInfo * frame_to_be_allocated;
				int return_frame_allocation = allocate_frame(&frame_to_be_allocated);
				if(return_frame_allocation == 0 ){

					int return_map_allcoation = map_frame(curenv->env_page_directory ,frame_to_be_allocated, fault_va,(PERM_PRESENT|PERM_USER|PERM_WRITEABLE));
					if (return_map_allcoation == 0 ){

						int return_read_pageFile = pf_read_env_page(curenv , (void *)fault_va);
						if(return_read_pageFile == E_PAGE_NOT_EXIST_IN_PF)
						{
							if((fault_va >= USER_HEAP_START && fault_va < USER_HEAP_MAX) || (fault_va <USTACKTOP && fault_va>= USTACKBOTTOM)){

								struct WorkingSetElement * wseToBeAdded  = env_page_ws_list_create_element(curenv,fault_va);

								if (wseToBeAdded  == NULL)
									return;

								struct WorkingSetElement* FIFO_tail = LIST_LAST(&curenv->ActiveList);
								LIST_REMOVE(&curenv->ActiveList , FIFO_tail);
								LIST_INSERT_HEAD(&curenv->ActiveList , wseToBeAdded);
								struct WorkingSetElement* LRU_tail = LIST_LAST(&curenv->SecondList);
								uint32 page_permissions = pt_get_page_permissions(curenv->env_page_directory, (uint32)LRU_tail->virtual_address);
								if(page_permissions & PERM_MODIFIED)
								{
									uint32 * ptr_page_table;
									int ret = get_page_table(curenv->env_page_directory, LRU_tail->virtual_address, &ptr_page_table);
									struct FrameInfo * victim_frame = get_frame_info(curenv->env_page_directory , LRU_tail->virtual_address, &ptr_page_table);
									pf_update_env_page(curenv, LRU_tail->virtual_address, victim_frame);
									//Ask about permissions
									pt_set_page_permissions(curenv->env_page_directory, LRU_tail->virtual_address, 0, PERM_PRESENT);
									pt_set_page_permissions(curenv->env_page_directory, LRU_tail->virtual_address, 0, PERM_MODIFIED);
								}
								LIST_REMOVE(&curenv->SecondList, LRU_tail);
								unmap_frame(curenv->env_page_directory, LRU_tail->virtual_address);
								LIST_INSERT_HEAD(&curenv->SecondList, FIFO_tail);
								pt_set_page_permissions(curenv->env_page_directory, FIFO_tail->virtual_address, 0, PERM_PRESENT);
								return;
							}
							else
							{
								sched_kill_env(curenv->env_id);
								return;
							}
						}
						else{
							// In page file

							struct WorkingSetElement * wseToBeAdded = env_page_ws_list_create_element(curenv,fault_va);
							if (wseToBeAdded == NULL)
								return;

							struct WorkingSetElement* FIFO_tail = LIST_LAST(&curenv->ActiveList);
							// Remove Last Element from FIFO
							LIST_REMOVE(&curenv->ActiveList , FIFO_tail);
							LIST_INSERT_HEAD(&curenv->ActiveList , wseToBeAdded);

							struct WorkingSetElement* LRU_tail = LIST_LAST(&curenv->SecondList);
							uint32 page_permissions = pt_get_page_permissions(curenv->env_page_directory, (uint32)LRU_tail->virtual_address);
							if(page_permissions & PERM_MODIFIED)
							{
								uint32 * ptr_page_table;
								int ret = get_page_table(curenv->env_page_directory, LRU_tail->virtual_address, &ptr_page_table);
								struct FrameInfo * victim_frame = get_frame_info(curenv->env_page_directory , LRU_tail->virtual_address, &ptr_page_table);
								pf_update_env_page(curenv, LRU_tail->virtual_address, victim_frame);
								//Ask about permissions
								pt_set_page_permissions(curenv->env_page_directory, LRU_tail->virtual_address, 0, PERM_PRESENT);
								pt_set_page_permissions(curenv->env_page_directory, LRU_tail->virtual_address, 0, PERM_MODIFIED);
							}
							LIST_REMOVE(&curenv->SecondList, LRU_tail);
							unmap_frame(curenv->env_page_directory, LRU_tail->virtual_address);
							LIST_INSERT_HEAD(&curenv->SecondList, FIFO_tail);
							pt_set_page_permissions(curenv->env_page_directory, FIFO_tail->virtual_address, 0, PERM_PRESENT);
							return;
						}
					}
				}
			}

		}
			//TODO: [PROJECT'23.MS3 - BONUS] [1] PAGE FAULT HANDLER - O(1) implementation of LRU replacement
		}
	}
}
void __page_fault_handler_with_buffering(struct Env * curenv, uint32 fault_va)
{
	panic("this function is not required...!!");
}
