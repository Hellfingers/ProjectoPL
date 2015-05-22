%{
	#include <stdio.h>

%}

%union {
	int vali;
	char* valc;
}

%token INT IF ELSE WHILE FOR PRINT INPUT

%token <valc> id
%token <vali> num

%type <valc> Var
%type <vali> Exp Termo Fator


%%

Prog	:	Decls Instrs	{}
		;

Decls	:	InitVar			{}
		|	Decls InitVar	{}
		;

InitVar	:	INT Var ';'		{printf("Variavel!\n");}
		;

Var		:	id				{}
		|	id '[' num ']'	{}
		;

Instrs	:	Instr 			{}
		|	Instrs Instr 	{}
		;	

Instr	:					{}
		|	If 				{printf("if!\n");}
		|	While 			{printf("while!\n");}
		|	For 			{printf("for!\n");}
		|	Atr	';'			{printf("ATRIBUICAO!\n");}
		|	IO ';'			{}
		;

If 		:	IF '(' Comp ')' '{' Instrs '}'						{}
		;

While 	: 	WHILE '(' Comp ')' '{' Instrs '}'						{}
		;

For		:	FOR '(' Atr ';' Comp ';' Atr ')' '{' Instrs '}'		{}
		;

IO		:	PRINT Out		{printf("print!\n");}
		|	INPUT Var 	{printf("input!\n");}
		;
		
Out		:	Exp				{}
		|	'\"' id '\"'	{}
		;

Atr		:	Var '='	Exp		{}
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
	yyparse(); 
	return 0; 
}	
