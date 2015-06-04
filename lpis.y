%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include "hashTable.h"

	int countLabel=1;
	int labelStack[100], sp=0;

	HashTable symbolTable;
	char **bloco;
	int i;

	void insertSymbol(char* symb, char* type, int tamanho){

		int res;

		res = hashInsert(symbolTable, symb, type, tamanho);

		if(res == 0)
			printf("Variável '%s' já definida.\n",symb);
	}

	int checkSymbol(char* symb){

		int res;

		res = hashContains(symbolTable, symb);

		if(res == 0)
			printf("Variável '%s' não definida.\n",symb);

		return res;
	}

	void checkSymbolInit(char* symb){

		int res;

		res = hashIsInit(symbolTable, symb);

		if(res == 0)
			printf("Variável '%s' não inicializada!\n",symb);
	}

	void initSymbol(char* symb){

		hashInit(symbolTable, symb);
	}

%}

%union {
	int vali;
	char* valc;
	char valOp;
}

%token INT IF ELSE WHILE FOR PRINT INPUT

%token <valc> id OpComp
%token <vali> num
%token <valOp> OpA OpM

%type <valc> Var 
%type <vali> Exp Termo Fator Array

%%

Prog	:	Declss Instrs	{printf("\tSTOP\n");}
		;

Declss	:	Decls 			{printf("\tSTART\n");}

Decls	:	InitVar			{}
		|	Decls InitVar	{}
		;

InitVar	:	INT Var Array ';'		{
										insertSymbol($2,"int",$3);
										printf("\tPUSHI 0\n");
									}
		;

Array	:					{$$ = 1;}
		|	'[' num ']'		{$$ = $2;}
		;

Var		:	id				{$$ = $1;}
		;

Instrs	:	Instr 			{}
		|	Instrs Instr 	{}
		;	

Instr	:	If 				{}
		|	While 			{}
		|	For 			{}
		|	Atr	';'			{}
		|	IO ';'			{}
		;

If 		:	IF '(' Comp ')'{labelStack[sp++] = countLabel++;printf("\tJZ L%d\n",labelStack[sp-1]);} '{' Instrs '}'	Else
		;

Else 	:														{	
																	printf("L%d:\n",labelStack[--sp]);
																}
		|	ELSE 												{
																	printf("\tJUMP L%d\n",countLabel);
																	printf("L%d:\n",labelStack[--sp]);
																	labelStack[sp++] = countLabel++;
																	
																} 
			'{' Instrs '}'										{
																	printf("L%d:\n",labelStack[--sp]);
																}
		;

While 	: 	WHILE 			{
								labelStack[sp++] = countLabel++;
								printf("L%d:\n",countLabel);
							}
			'(' Comp ')' 	{
								printf("\tJZ L%d\n",labelStack[sp-1]);
								labelStack[sp++] = countLabel++;
							}
			'{' Instrs '}'	{
								printf("\tJUMP L%d\n",labelStack[--sp]);
								printf("L%d:\n",labelStack[--sp]);
							}
		;

For		:	FOR '(' Atr ';' {
								labelStack[sp++] = countLabel++;
								printf("L%d:\n",countLabel);
							}
			Comp ';' 		{
								printf("\tJZ L%d\n",labelStack[sp-1]);
								printf("\tJUMP L%d\n",countLabel+2);
								labelStack[sp++] = countLabel++;
								printf("L%d:\n",countLabel++);
							}
			Atr ')' 		{	
								printf("\tJUMP L%d\n", countLabel-2);
								printf("L%d:\n",countLabel++);
							}
			'{' Instrs '}'	{
								printf("\tJUMP L%d\n",labelStack[--sp]+1);
								printf("L%d:\n",labelStack[--sp]);
							}
		;

IO		:	PRINT Out		{}
		|	INPUT Var Array	{}
		;

Out		:	Exp				{}
		|	'\"' id '\"'	{}
		;

Atr		:	Var Array '='	Exp		{
								if(checkSymbol($1)){
									initSymbol($1);
									//printf("PUSHI %d\n", $3);
									printf("\tSTOREG %d\n", hashInd(symbolTable,$1));	
								}
							}
		;

Exp		:	Termo			{}
		|	Exp OpA	Termo	{
								switch($2){

									case '+': printf("\tADD\n");
											break;
									case '-': printf("\tSUB\n");
											break;
								}
							}
		;


Termo	:	Fator			{}
		|	Termo OpM Fator	{
								switch($2){	

									case '/': printf("\tDIV\n");
											break;
									case '*': printf("\tMUL\n");
											break;
								}
							}
		;

Fator	:	Var  Array		{
 								if(checkSymbol($1))
									checkSymbolInit($1);

								printf("\tPUSHG %d\n", hashInd(symbolTable,$1));
							}
		|	num				{ printf("\tPUSHI %d\n", $1);}
		|	'(' Exp ')'		{}
		|	'!' Exp			{}
		;

Comp	:	Exp				{}
		|	Exp OpComp Exp	{
								switch($2[0]){

									case '>':
										if($2[1] == '='){
											printf("\tSUPEQ\n");
										}
										else{
											printf("\tSUP\n");
										}
										break;
									case '<':
										if($2[1] == '='){
											printf("\tINFEQ\n");
										}
										else{
											printf("\tINF\n");
										}
										break;
									case '=':
										printf("\tEQUAL\n");
										break;

								}
							}
		;

%%

#include "lex.yy.c"

int yyerror(char *s){
	printf("erro sintático: %s\n", s);
}
     
int main(){

	symbolTable = hashCreate(1000);
	bloco = malloc(sizeof(char*)*1000);
	yyparse(); 
	return 0; 
}	
