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
		char aux[1000];

		res = hashInsert(symbolTable, symb, type, tamanho);

		if(res == 0){
			sprintf(aux,"Variável '%s' já definida.",symb);
			yyerror(aux);
		}
	}

	int checkSymbol(char* symb){

		int res;
		char aux[1000];

		res = hashContains(symbolTable, symb);

		if(res == 0){
			sprintf(aux,"Variável '%s' não definida.",symb);
			yyerror(aux);
		}
		return res;
	}

	char* checkType(char* symb){
		
		int res;

		res = hashContains(symbolTable, symb);

		if(res == 0){
			return "erro";
		}
		else{
			return hashType(symbolTable,symb);
		}
	}

	void checkSymbolInit(char* symb){

		int res;

		res = hashIsInit(symbolTable, symb);

			//printf("Variável '%s' não inicializada!\n",symb);
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

%token STRING INT IF ELSE WHILE FOR PRINT INPUT 

%token <valc> id OpComp str
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
		|	STRING Var ';'			{
										insertSymbol($2,"string",0);
										printf("\tPUSHS \"\"\n");
									}
		;

Array	:					{$$ = 1;}
		|	'[' Exp ']'		{$$ = $2;}
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
		|	INPUT Var 		{printf("\tREAD\n");printf("\tATOI\n");printf("\tSTOREG %d\n", hashInd(symbolTable,$2));}
		;

Out		:	Exp				{
								if($1==1){printf("\tWRITEI\n");}
								else{printf("\tWRITES\n");}}
		|	str				{printf("\tPUSHS %s\n",$1);printf("\tWRITES\n");}
		;

Atr		:	Var '=' Exp			{
									char aux[1000];
									if(strcmp(checkType($1),"int")==0){
										if($3==1){
											if(checkSymbol($1)){
												initSymbol($1);
												printf("\tSTOREG %d\n", hashInd(symbolTable,$1));	
											}
										}
										else{
											yyerror("Tipos diferentes");
										}
									}
									else if(strcmp(checkType($1),"string")==0){
										if($3==2){
											if(checkSymbol($1)){
												initSymbol($1);
												printf("\tSTOREG %d\n", hashInd(symbolTable,$1));	
											}
										}
										else{
											yyerror("Tipos diferentes");
										}
									}
									else if(strcmp(checkType($1),"erro")==0){
										sprintf(aux,"Variável '%s' não definida.",$1);
										yyerror(aux);
									}
								}
		|	Var Array '=' Exp			{
									if(checkSymbol($1)){
										initSymbol($1);
										printf("\tSTOREG %d\n", hashInd(symbolTable,$1));	
									}

									if($2 == 1){

									}
									else{

									}
								}
		;

Exp		:	Termo			{}
		|	Exp OpA	Termo	{
								if($1 == 1 && $3 == 1){
									switch($2){
										case '+': 
											printf("\tADD\n");
											break;
										case '-': 
											printf("\tSUB\n");
											break;
										case '|':
											printf("\tADD\n");
									}
								}
								else if($1 == 2 && $3 == 2){
									switch($2){

										case '+': 
											printf("\tCONCAT\n");
											break;
										default:
											yyerror("Tipos diferentes");
											break;
									}
								}
								else{
									yyerror("Tipos diferentes");
								}
							}
		;

Termo	:	Fator			{$$ = $1;}
		|	Termo OpM Fator	{
								if($1 == 1 && $3 == 1){
									switch($2){	

										case '/': 
											printf("\tDIV\n");
											break;
										case '*': 
											printf("\tMUL\n");
											break;
										case '%': 
											printf("\tMOD\n");
											break;
										case '&':
											printf("\tMUL\n");
											break;
									}
								}
								else{
									yyerror("Tipos diferentes");
								}
							}
		;

Fator	:	Var  Array		{
 								if(checkSymbol($1))
									checkSymbolInit($1);

								if(strcmp(checkType($1),"int")==0){
									$$=1;
									printf("\tPUSHG %d\n", hashInd(symbolTable,$1));
								}
								else if(strcmp(checkType($1),"string")==0){
									$$=2;
									printf("\tPUSHG %d\n", hashInd(symbolTable,$1));
								}
								else {
								}

							}
		|	num				{$$ = 1; printf("\tPUSHI %d\n", $1);}
		|	str 			{$$ = 2; printf("\tPUSHS %s\n", $1);}
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
									case '!':
										printf("\tEQUAL\n");
										printf("\tNOT\n");
										break;

								}
							}
		;

%%

#include "lex.yy.c"

int yyerror(char *s){
	printf("Erro Sintático linha %d: %s\n",yylineno, s);
}
     
int main(){

	symbolTable = hashCreate(1000);
	bloco = malloc(sizeof(char*)*1000);
	yyparse(); 
	return 0; 
}	
