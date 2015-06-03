#include <stdlib.h>
#include <string.h>
#include "hashTable.h"

struct list{
	char *key;
	char *type;
	int init;
	int ind;
	int tamanho;
	struct list* next;
};

struct table{
	int size;
	int elems;
	struct list **list;
};

struct table* hashCreate(int size){

	struct table *table;
	int i;

	table = malloc(sizeof(table));

	table->size = size;

	table->list = malloc(sizeof(struct list *) * size);

	for(i=0;i<size;i++)
		table->list[i] = NULL;

	return table;
}

unsigned long hash(unsigned char *str){

	unsigned long hash = 5381;
    int c;

	while (c = *str++)
    	hash = ((hash << 5) + hash) + c; /* hash * 33 + c */
		
	return hash;
}

int hashInsert(struct table* t, char* key, char* type, int ind){

	struct list *aux;
	long h;

	if(hashContains(t,key))
		return 0;

	aux = malloc(sizeof(struct list *) * 4);

	aux->key = strdup(key);
	aux->type = strdup(type);
	aux->init = 0;
	aux->ind = t->elems;
	aux->tamanho = ind;

	t->elems++;

	h = hash(key) % t->size;

	aux->next = t->list[h];
	t->list[h] = aux;

	return 1;
}

int hashContains(struct table* t, char* key){

	struct list* aux;
	int h=hash(key)%t->size;

	for(aux = t->list[h];aux!=NULL;aux = aux->next){
		if(strcmp(aux->key,key) == 0)
			return 1;
	}

	return 0;
}

int hashIsInit(struct table* t, char* key){

	struct list* aux;
	int h=hash(key)%t->size;

	if(!hashContains(t,key))
		return 0;

	for(aux = t->list[h];aux != NULL;aux = aux->next)
		if(strcmp(key,aux->key) == 0)
			return aux->init;

}

int hashInit(struct table* t, char* key){

	struct list* aux;
	int h=hash(key)%t->size;

	if(!hashContains(t,key))
		return 0;

	for(aux = t->list[h];aux != NULL;aux = aux->next)
		if(strcmp(key,aux->key) == 0)
			aux->init = 1;

	return 1;

}

int hashInd(struct table* t, char* key){


	struct list* aux;
	int h=hash(key)%t->size;

	if(!hashContains(t,key))
		return 0;

	for(aux = t->list[h];aux != NULL;aux = aux->next)
		if(strcmp(key,aux->key) == 0)
			return aux->ind;
}