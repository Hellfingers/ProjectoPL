#ifndef HASHTABLE_H_
#define HASHTABLE_H_

typedef struct table* HashTable;

HashTable hashCreate(int size);
int hashInsert(HashTable t, char* key, char* type, int tamanho);
int hashContains(HashTable t, char* key);
int hashIsInit(HashTable t, char* key);
int hashInit(HashTable t, char* key);
int hashInd(HashTable t, char* key);

#endif