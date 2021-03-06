#ifndef HASHTABLE_H_
#define HASHTABLE_H_

typedef struct table* HashTable;

HashTable hashCreate(int size);
int hashInsert(HashTable t, char* key, char* type);
int hashContains(HashTable t, char* key);
int hashInd(HashTable t, char* key);
char* hashType(HashTable t, char *key);

#endif