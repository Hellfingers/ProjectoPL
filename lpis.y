%{
	#include <stdio.h>
	#include "hashTable.h"

	HashTable symbolTable;

	void insertSymbol(char* symb, char* type){

		int res;

		res = hashInsert(symbolTable, symb, type);

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
}

%token INT IF ELSE WHILE FOR PRINT INPUT

%token <valc> id
%token <vali> num

%type <valc> Var

%%

Prog	:	Decls Instrs	{}
		;

Decls	:	InitVar			{}
		|	Decls InitVar	{}
		;

InitVar	:	INT Var ';'		{insertSymbol($2,"int");}
		;

Var		:	id				{$$ = $1;}
		|	id '[' num ']'	{}
		;

Instrs	:	Instr 			{}
		|	Instrs Instr 	{}
		;	

Instr	:					{}
		|	If 				{}
		|	While 			{}
		|	For 			{}
		|	Atr	';'			{}
		|	IO ';'			{}
		;

If 		:	IF '(' Comp ')' '{' Instrs '}'						{}
		;

While 	: 	WHILE '(' Comp ')' '{' Instrs '}'						{}
		;

For		:	FOR '(' Atr ';' Comp ';' Atr ')' '{' Instrs '}'		{}
		;

IO		:	PRINT Out		{}
		|	INPUT Var 		{}
		;

Out		:	Exp				{}
		|	'\"' id '\"'	{}
		;

Atr		:	Var '='	Exp		{
								if(checkSymbol($1))
									initSymbol($1);
							}
		;

Exp		:	Termo			{}
		|	Exp OpA	Termo	{}
		;

OpA		:	'+'				{}
		|	'-'				{}
		|	'&' '&'			{}
		;

Termo	:	Fator			{}
		|	Termo OpM Fator	{}
		;

OpM		:	'*'				{}
		|	'/'				{}
		|	'|' '|'			{}
		;

Fator	:	Var 			{
								if(checkSymbol($1))
									checkSymbolInit($1);
							}
		|	num				{}
		|	'(' Exp ')'		{}
		|	'!' Exp			{}
		;

Comp	:	Exp				{}
		|	Exp OpComp Exp	{}
		;

OpComp	:	'>'
		|	'<'
		|	'<''='
		|	'>''='
		|	'=''='
		|	'!''='
		;

%%

#include "lex.yy.c"

int yyerror(char *s){
	printf("erro sintático: %s\n", s);
}
     
int main(){

	symbolTable = hashCreate(1000);
	yyparse(); 
	return 0; 
}	
