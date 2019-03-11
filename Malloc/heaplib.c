//Project 6 - Malloc 
//Richard Greenbaum (rrg73), John Demouly (jjd268) 
#include "heaplib.h"
#include <limits.h>


/* Useful shorthand: casts a pointer to a (char *) before adding */
#define ADD_BYTES(base_addr, num_bytes) (((char *)(base_addr)) + (num_bytes))
#define DATASIZE sizeof(block_data)

typedef unsigned int uintptr_t;

typedef struct _block_data {
    unsigned int block_size;
} block_data;



void hl_init(void *heap, unsigned int heap_size) {
	spin_lock(malloc_lock);
    if (((uintptr_t)heap)%8 != 0) {
        heap_size -= 8 - ((uintptr_t)heap)%8;
    }
    heap_size -= heap_size%4;
    if (((uintptr_t)heap)%8 != 0) {
        heap = ADD_BYTES(heap, 8 - ((uintptr_t)heap)%8);
    }
    *((int*)heap) = 0;
    block_data *front_block = (block_data *)ADD_BYTES(heap, sizeof(unsigned int));
    front_block->block_size = heap_size - 2*DATASIZE - sizeof(unsigned int);
    block_data *end_block = ADD_BYTES(front_block, front_block->block_size + DATASIZE);
    end_block->block_size = INT_MAX;
    spin_unlock(malloc_lock);
    
}

void *hl_alloc(void *heap, unsigned int block_size) {
	spin_lock(malloc_lock);
    if (((uintptr_t)heap)%8 != 0) {
        heap = ADD_BYTES(heap, 8 - ((uintptr_t)heap)%8);
    }
    if (block_size%8 <= 4) {
        block_size += 4 - (block_size)%8;
    }
    else {
        block_size += 12 - (block_size)%8;
    }

    //set front block to location immedietly following the lock int
    block_data *front_block = (block_data *)ADD_BYTES(heap, sizeof(unsigned int));
    block_data *ptr = front_block;

    block_data *best_ptr = NULL;
    int smallest_space = INT_MAX;
    while (ptr->block_size != INT_MAX) {
        if ((ptr->block_size%2 == 0) && (ptr->block_size >= block_size) && (ptr->block_size < smallest_space)){
            smallest_space = ptr->block_size;
            best_ptr = (block_data *)ptr;
        }
        ptr = ADD_BYTES(ptr, ptr->block_size + DATASIZE - ptr->block_size%2);
    }
    //if no such block was found, return null
    if (best_ptr == NULL) {
    	spin_unlock(malloc_lock);
        return NULL;
    }
    ptr = ADD_BYTES(best_ptr, block_size + DATASIZE);
    if (best_ptr->block_size != block_size)
        ptr->block_size = best_ptr->block_size - block_size - DATASIZE;
    best_ptr->block_size = block_size + 1;
   
    //set the block_data at the optimal_location to point to the new block.
    //set the block_data of the new block to point to the location that the optimal_location pointed to
    
    best_ptr = ADD_BYTES(best_ptr, DATASIZE);
    spin_unlock(malloc_lock);
    return best_ptr;

}
void *hl_prealloc(void *heap, void *old_pointer, unsigned int block_size) {
    if (((uintptr_t)heap)%8 != 0) {
        heap = ADD_BYTES(heap, 8 - ((uintptr_t)heap)%8);
    }
    if (block_size%8 <= 4) {
        block_size += 4 - (block_size)%8;
    }
    else {
        block_size += 12 - (block_size)%8;
    }

    //set front block to location immedietly following the lock int
    block_data *front_block = (block_data *)ADD_BYTES(heap, sizeof(unsigned int));
    block_data *ptr = front_block;

    block_data *best_ptr = NULL;
    int smallest_space = INT_MAX;
    while (ptr->block_size != INT_MAX) {
        if ((ptr->block_size%2 == 0) && (ptr->block_size >= block_size) && (ptr->block_size < smallest_space) && 
        	!(ADD_BYTES(ptr, block_size + 4)>old_pointer && ADD_BYTES(ptr, 4) < old_pointer)){
            smallest_space = ptr->block_size;
            best_ptr = (block_data *)ptr;
        }
        ptr = ADD_BYTES(ptr, ptr->block_size + DATASIZE - ptr->block_size%2);
    }
    //if no such block was found, return null
    if (best_ptr == NULL) {
        return NULL;
    }
    ptr = ADD_BYTES(best_ptr, block_size + DATASIZE);
    if (best_ptr->block_size != block_size)
        ptr->block_size = best_ptr->block_size - block_size - DATASIZE;
    best_ptr->block_size = block_size + 1;
   
    //set the block_data at the optimal_location to point to the new block.
    //set the block_data of the new block to point to the location that the optimal_location pointed to
    
    best_ptr = ADD_BYTES(best_ptr, DATASIZE);
    return best_ptr;

}
void hl_release(void *heap, void *block) {
	spin_lock(malloc_lock);
    if (((uintptr_t)heap)%8 != 0) {
        heap = ADD_BYTES(heap, 8 - ((uintptr_t)heap)%8);
    }
    block_data *front_block = (block_data *)ADD_BYTES(heap, sizeof(unsigned int));
    block_data *ptr = front_block;
    block_data *prev_ptr;
    block_data *next_ptr;

    if ((uintptr_t)block != 0) {
        
        if (ptr == ADD_BYTES(block, -4)) {
            next_ptr = (block_data *)ADD_BYTES(ptr, ptr->block_size + DATASIZE - ptr->block_size%2);

            if (next_ptr->block_size%2 == 1){
                ptr->block_size -= 1;
            }
            else{
                ptr->block_size += next_ptr->block_size + DATASIZE -1;
            }
        }

        else {
            
            while (ADD_BYTES(ptr, ptr->block_size + DATASIZE + 4 - ptr->block_size%2) != block){
                ptr = ADD_BYTES(ptr, ptr->block_size + DATASIZE - ptr->block_size%2);

            }
            prev_ptr = ptr;
            ptr = ADD_BYTES(ptr, ptr->block_size + DATASIZE - ptr->block_size%2);
            next_ptr = ADD_BYTES(ptr, ptr->block_size + DATASIZE - ptr->block_size%2);
            ptr->block_size -= 1;
            if (prev_ptr->block_size%2 == 0 && next_ptr->block_size%2==0) {
                prev_ptr->block_size += ptr->block_size + next_ptr->block_size + 2*DATASIZE;
            }
            if (prev_ptr->block_size%2 == 0 && next_ptr->block_size%2==1) {
                prev_ptr->block_size += ptr->block_size + DATASIZE;
            }
            if (prev_ptr->block_size%2 == 1 && next_ptr->block_size%2==0) {
                ptr->block_size += next_ptr->block_size + DATASIZE;
            }
        }
        
    }
    
    spin_unlock(malloc_lock);
}
void hl_prerelease(void *heap, void *block) {
    if (((uintptr_t)heap)%8 != 0) {
        heap = ADD_BYTES(heap, 8 - ((uintptr_t)heap)%8);
    }
    block_data *front_block = (block_data *)ADD_BYTES(heap, sizeof(unsigned int));
    block_data *ptr = front_block;
    block_data *prev_ptr;
    block_data *next_ptr;

    if ((uintptr_t)block != 0) {
        
        if (ptr == ADD_BYTES(block, -4)) {
            next_ptr = (block_data *)ADD_BYTES(ptr, ptr->block_size + DATASIZE - ptr->block_size%2);

            if (next_ptr->block_size%2 == 1){
                ptr->block_size -= 1;
            }
            else{
                ptr->block_size += next_ptr->block_size + DATASIZE -1;
            }
        }

        else {
            
            while (ADD_BYTES(ptr, ptr->block_size + DATASIZE + 4 - ptr->block_size%2) != block){
                ptr = ADD_BYTES(ptr, ptr->block_size + DATASIZE - ptr->block_size%2);

            }
            prev_ptr = ptr;
            ptr = ADD_BYTES(ptr, ptr->block_size + DATASIZE - ptr->block_size%2);
            next_ptr = ADD_BYTES(ptr, ptr->block_size + DATASIZE - ptr->block_size%2);
            ptr->block_size -= 1;
            if (prev_ptr->block_size%2 == 0 && next_ptr->block_size%2==0) {
                prev_ptr->block_size += ptr->block_size + next_ptr->block_size + 2*DATASIZE;
            }
            if (prev_ptr->block_size%2 == 0 && next_ptr->block_size%2==1) {
                prev_ptr->block_size += ptr->block_size + DATASIZE;
            }
            if (prev_ptr->block_size%2 == 1 && next_ptr->block_size%2==0) {
                ptr->block_size += next_ptr->block_size + DATASIZE;
            }
        }
        
    }
    
}


void *hl_resize(void *heap, void *block, unsigned int new_size) {
	spin_lock(malloc_lock);
	char *to_return = NULL;
	unsigned int amnt_to_move = new_size;
		  		
    //Checks if null block pointer
    if((uintptr_t)block == 0) {
  		to_return = hl_prealloc(heap, block, new_size);
  	}
    
    
    

  	else{
  		//deals with allignement
		if (((uintptr_t)heap)%8 != 0) {
        heap = ADD_BYTES(heap, 8 - ((uintptr_t)heap)%8);
    	}
    	block_data *front_block = (block_data *)ADD_BYTES(heap, sizeof(unsigned int));
    	block_data *ptr = front_block;
	    
	    //gets meta pointer rather than data pointer
	  	block_data *old_meta_point = ADD_BYTES(block, -sizeof(unsigned int));
	  	unsigned int meta_old_size = old_meta_point->block_size;
	  	//first block in heap
	    if (old_meta_point == front_block){
	    	hl_prerelease(heap, block);
	    	amnt_to_move = new_size;
		  		if (amnt_to_move > meta_old_size - meta_old_size%2){
		  			amnt_to_move = meta_old_size - meta_old_size%2;
		  		}
	    	to_return = hl_prealloc(heap, block, new_size);

	    	if (to_return == NULL){
	    		old_meta_point->block_size =meta_old_size;
	    	}
	    	else{
	    		memcpy(to_return, block, amnt_to_move);
	    	}
	    }
	    else{ 
		    
		    //locates previous pointer
		    block_data *pre_pointer;
		    while (ptr < old_meta_point){
		  		pre_pointer = ptr;
		  		ptr = ADD_BYTES(ptr, ptr->block_size + DATASIZE- (ptr->block_size%2));
		  	}

		  	unsigned int old_size = pre_pointer->block_size;
		  	//temporarily frees and allocates mem location of new size
		  	
		  	hl_prerelease(heap, block);
		  	
		  	char *new_point = hl_prealloc(heap, block, new_size);
		  	
		  	//checks if no room
		  	if ((uintptr_t)new_point == 0){
		  		pre_pointer->block_size = old_size;
		  		old_meta_point->block_size = meta_old_size;
		  		spin_unlock(malloc_lock);
		  		return NULL;
		  	}
		  	//checks if position unchanged
		    else if (new_point == block){
		  		to_return = block;
		  	}
		    //else if it is moved
		    else{
		  		amnt_to_move = new_size;
		  		if (amnt_to_move > meta_old_size - meta_old_size%2){
		  			amnt_to_move = meta_old_size - meta_old_size%2;
		  		}
		  		
		  		
		  		
		  		memcpy(new_point, block, amnt_to_move);
		  		
		  		
		  		
		  		to_return = new_point;

		  	}
		}
	}
	spin_unlock(malloc_lock);
    return to_return;
}

