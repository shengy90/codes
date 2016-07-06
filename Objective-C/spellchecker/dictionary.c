/**
 * dictionary.c
 *
 * Computer Science 50
 * Problem Set 5
 *
 * Implements a dictionary's functionality using tries data structure.
 */

#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>
#include "dictionary.h"

typedef struct node
{
    bool is_word;
    struct node *children[27];
} node;

int CharToNum(int character);
void freeNode(node *currentNode);



//Initiate a first node call root.
node root;
//Number of words in dictionary
int numOfWords = 0;




/**
 * Loads dictionary into memory.  Returns true if successful else false.
 */
bool load(const char *dictionary)
{
    //open file
    FILE* file = fopen(dictionary, "r");
    
    //If failed to open, return false
    if (file == NULL) {
        return false;
    }
    
    // //Keep doing when end of file is not yet reached
    while(!feof(file)) {
        
        //Create an array for a word in the dictionary with length = LENGTH(45) + 1
        char word[LENGTH + 1] = {};
        //Read the entire chunk of word at once then increment the count numOfWords
        fscanf(file,"%s\n",word);
        numOfWords++;
        
        //Create a pointer ptr that points to root.
        node *ptr = &root;
        
        for (int i = 0; i <strlen(word); i++) {
            if (ptr->children[ CharToNum(word[i]) ] == NULL) {
                //if the children is null, then create a new node for the letter
                node* new_Children = malloc(sizeof(node)); 
                ptr -> children[ CharToNum(word[i]) ] = new_Children;
                ptr = new_Children;
            } else {
                ptr = ptr -> children[ CharToNum(word[i]) ];
            }
            
        }
            
        ptr -> is_word = true;
    }
    
    fclose(file);
    return true;
}



/**
 * Returns true if word is in dictionary else false.
 */
bool check(const char* word)
{
    node *ptr = &root;
    
    //For each character, traverse the trie structure.
    for (int i = 0; i<strlen(word); i++) {
        if (ptr->children[ CharToNum(word[i])] == NULL) {
            //If character doesn't exist in Trie, it is mispelled.
            return false;
        } else {
            //If it's in the Trie, go on to the next node.
            ptr = ptr->children[ CharToNum(word[i])];
        }
    }
        
    //At the end of the word, if is_word is true, then return true.
    if (ptr->is_word == true) {
        return true;
    } else {
        return false;
    }
    return false;
}


/**
 * Returns number of words in dictionary if loaded else 0 if not yet loaded.
 */
unsigned int size(void)
{
    if(numOfWords) {
        return numOfWords;
    } else {
        return 0;
    }
}

/**
 * Unloads dictionary from memory.  Returns true if successful else false.
 */
bool unload(void)
{
    /*For each of the element in the root array, check if Null. If not null, traverse down the node until bottom
    most*/
    for (int i=0; i<27; i++){
        if (root.children[i] != NULL) {
            freeNode(root.children[i]);
        }
    }
    return true;
}




int CharToNum(int character) {
    
    /*Function to convert characters into numbers 0 - 26, where a = 0 and Z = 25 and ' = 26.
    Function also converts all characters into lowercase. If character is not an alphabet nor an apostrophe,
    return -1.
    */
    
    int number;
    if (character >= 65 && character <= 90) {
        number = character - 65;
    } else if (character >= 97 && character <= 122 ) {
        number = character - 97;
    } else if (character==39) {
        number = 26;
    } else {
        number = -1;
    }
    
    return number;
}

void freeNode(node* currentNode) {
    for (int i=0; i<27; i++) {
        
        if (currentNode->children[i]!=NULL) {
            freeNode(currentNode->children[i]);
        }
    }
        free(currentNode);
}