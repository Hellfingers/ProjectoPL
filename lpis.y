%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include "hashTable.h"

	int countLabel=1;
	int labelStack[100], sp=0;
	FILE *f;
	HashTable symbolTable;

	void insertSymbol(char* symb, char* type){

		int res;
		char aux[1000];

		res = hashInsert(symbolTable, symb, type);

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
			return "ND";
		}
		else{
			return hashType(symbolTable,symb);
		}
	}

	void checkSymbolInit(char* symb){

		int res;

		res = hashIsInit(symbolTable, symb);

	//	printf("Warning linha %d: Variável '%s' não inicializada!\n",symb);
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
%type <vali> Exp Termo Fator

%%

Prog	:	Declss Instrs	{fprintf(f,"\tSTOP\n");}
		;

Declss	:	Decls 			{fprintf(f,"\tSTART\n");}

Decls	:	InitVar			{}
		|	Decls InitVar	{}
		;

InitVar	:	INT Var '[' num ']' ';'	{
										insertSymbol($2,"arrayint");
										fprintf(f,"\tPUSHN %d\n", $4);
									}
										
		|	INT Var ';'				{
										insertSymbol($2,"int");
										fprintf(f,"\tPUSHI 0\n");
									}

		|	STRING Var ';'			{
										insertSymbol($2,"string");
										fprintf(f,"\tPUSHS \"\"\n");
									}
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

If 		:	IF '(' Cond ')'	{
								labelStack[sp++] = countLabel++;
								fprintf(f,"\tJZ L%d\n",labelStack[sp-1]);
							}
			'{' Instrs '}'	Else
		;

Else 	:					{	
								fprintf(f,"L%d:\n",labelStack[--sp]);
							}
		|	ELSE 			{
								fprintf(f,"\tJUMP L%d\n",countLabel);
								fprintf(f,"L%d:\n",labelStack[--sp]);
								labelStack[sp++] = countLabel++;
							} 
			'{' Instrs '}'	{
								fprintf(f,"L%d:\n",labelStack[--sp]);
								}
		;

While 	: 	WHILE 			{
								labelStack[sp++] = countLabel++;
								fprintf(f,"L%d:\n",countLabel);
							}
			'(' Cond ')' 	{
								fprintf(f,"\tJZ L%d\n",labelStack[sp-1]);
								labelStack[sp++] = countLabel++;
							}
			'{' Instrs '}'	{
								fprintf(f,"\tJUMP L%d\n",labelStack[--sp]);
								fprintf(f,"L%d:\n",labelStack[--sp]);
							}
		;

For		:	FOR '(' Atr ';' {
								labelStack[sp++] = countLabel++;
								fprintf(f,"L%d:\n",countLabel);
							}
			Cond ';' 		{
								fprintf(f,"\tJZ L%d\n",labelStack[sp-1]);
								fprintf(f,"\tJUMP L%d\n",countLabel+2);
								labelStack[sp++] = countLabel++;
								fprintf(f,"L%d:\n",countLabel++);
							}
			Atr ')' 		{	
								fprintf(f,"\tJUMP L%d\n", countLabel-2);
								fprintf(f,"L%d:\n",countLabel++);
							}
			'{' Instrs '}'	{
								fprintf(f,"\tJUMP L%d\n",labelStack[--sp]+1);
								fprintf(f,"L%d:\n",labelStack[--sp]);
							}
		;

IO		:	PRINT Out		{}
		|	INPUT Var 		{
								fprintf(f,"\tREAD\n");
								fprintf(f,"\tATOI\n");
								fprintf(f,"\tSTOREG %d\n", hashInd(symbolTable,$2));
							}
		;

Out		:	Exp				{
								if($1==1){
									fprintf(f,"\tWRITEI\n");
								}
								else{
									fprintf(f,"\tWRITES\n");
								}
							}

		|	str				{
								fprintf(f,"\tPUSHS %s\n",$1);
								fprintf(f,"\tWRITES\n");
							}
		;

Atr		:	Var '=' Exp	{
									char aux[1000];
								if(strcmp(checkType($1),"arrayint")!=0){
									if(strcmp(checkType($1),"int")==0){
										if($3==1){
											if(checkSymbol($1)){
												initSymbol($1);
												fprintf(f,"\tSTOREG %d\n", hashInd(symbolTable,$1));	
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
												fprintf(f,"\tSTOREG %d\n", hashInd(symbolTable,$1));	
											}
										}
										else{
											yyerror("Tipos diferentes");
										}
									}
									else if(strcmp(checkType($1),"arrayint")==0){
										if($3==1){
											if(checkSymbol($1)){
												initSymbol($1);
												fprintf(f,"\tLOADN\n");	
											}
										}
										else{
											yyerror("Tipos diferentes");
										}
									}
									else if(strcmp(checkType($1),"ND")==0){
										sprintf(aux,"Variável '%s' não definida.",$1);
										yyerror(aux);
									}
								}
								else{
									yyerror("Tipos diferentes");
								}
						}
		|	Var '[' Exp ']' '=' Exp {	
										if(strcmp(checkType($1),"arrayint")==0){
											fprintf(f,"\tPUSHG %d\n", hashInd(symbolTable,$1));
											fprintf(f,"\tSTOREN\n");
										}
										else{
											yyerror("Tipos diferentes");
										}
									}
		;

Exp		:	Termo			{}
		|	Exp OpA	Termo	{
								if($1 == 1 && $3 == 1){
									switch($2){
										case '+': 
											fprintf(f,"\tADD\n");
											break;
										case '-': 
											fprintf(f,"\tSUB\n");
											break;
									}
								}
								else if($1 == 2 && $3 == 2){
									switch($2){

										case '+': 
											fprintf(f,"\tCONCAT\n");
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
											fprintf(f,"\tDIV\n");
											break;
										case '*': 
											fprintf(f,"\tMUL\n");
											break;
										case '%': 
											fprintf(f,"\tMOD\n");
											break;
									}
								}
								else{
									yyerror("Tipos diferentes");
								}
							}
		;

Fator	:	Var		{
								if(checkSymbol($1))
									checkSymbolInit($1);

								if(strcmp(checkType($1),"int")==0){
									$$=1;
									fprintf(f,"\tPUSHG %d\n", hashInd(symbolTable,$1));
								}
								else if(strcmp(checkType($1),"string")==0){
									$$=2;
									fprintf(f,"\tPUSHG %d\n", hashInd(symbolTable,$1));
								}
								else{
								}
					}

		|	Var '[' Exp ']' 	{
									if(strcmp(checkType($1),"arrayint")==0){
										$$=1;
										fprintf(f,"\tPUSHG %d\n", hashInd(symbolTable,$1));
										fprintf(f,"\tLOADN\n");
									}
									else{
										yyerror("Tipos diferentes");
									}
								}
		|	num				{$$ = 1; fprintf(f,"\tPUSHI %d\n", $1);}
		|	str 			{$$ = 2; fprintf(f,"\tPUSHS %s\n", $1);}
		|	'(' Exp ')'		{}
		|	'!' Exp			{}
		;

Cond	:	 Comp 				{}
		|	'(' Cond ')'		{}
		|	Cond '&''&' Cond 	{
									fprintf(f,"\tMUL\n");
								}
		|	Cond '|''|' Cond 	{
									fprintf(f,"\tADD\n");
								}
		;

Comp	:	Exp				{}
		|	Exp OpComp Exp	{
								switch($2[0]){

									case '>':
										if($2[1] == '='){
											fprintf(f,"\tSUPEQ\n");
										}
										else{
											fprintf(f,"\tSUP\n");
										}
										break;
									case '<':
										if($2[1] == '='){
											fprintf(f,"\tINFEQ\n");
										}
										else{
											fprintf(f,"\tINF\n");
										}
										break;
									case '=':
										fprintf(f,"\tEQUAL\n");
										break;
									case '!':
										fprintf(f,"\tEQUAL\n");
										fprintf(f,"\tNOT\n");
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
	f = fopen("assembly.vm","w");
	yyparse(); 
	return 0; 
}	
