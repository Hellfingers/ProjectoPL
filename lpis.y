%{
	#include <stdio.h>

%}

%union {int num;char id;}

%token INT IF ELSE WHILE FOR print input

%token <id> id
%token <num> num


%%

Prog	:	Decls Instrs	{}
		;

Decls	:	InitVar			{}
		|	Decls InitVar	{}
		;

InitVar	:	INT Var ';'	{printf("Variavel!");}
		;

Var		:	id				{}
		|	id '[' Exp ']'	{}
		;

Instrs	:	Instr 			{}
		|	Instrs Instr 	{}
		;	

Instr	:	If 				{}		
		|	While 			{}
		|	For 			{}
		|	Atr	';'			{}
		|	IO	';'			{}
		;

If		:	IF '(' Comp ')' '{' Instrs '}'						{}
		|	IF '(' Comp ')' '{' Instrs '}' ELSE '{' Instrs '}'	{}
		;

While 	: 	WHILE '(' Comp ')' '{' Instrs '}'						{}
		;

For		:	FOR '(' Atr ',' Comp ',' Atr ')' '{' Instrs '}'		{}
		;

Atr		:	Var '='	Exp		{}
		;

IO		:	print Out		{}
		|	input Var 	{}
		;

Out		:	Exp				{}
		|	'\"' id '\"'	{}
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

Fator	:	Var 			{}
		|	num				{}
		|	'(' Exp ')'		{}
		|	'!' Exp			{}
		;

Comp	:	Exp				{}
		|	Exp OpComp Exp	{}
		;

OpComp	:	'>'
		|	'<'
		;
%%
#include "lex.yy.c"

int yyerror(char *s){
	printf("erro sintático: %s\n", s);
}
     
int main(){
	yyparse(); 
	return 0; 
}	
