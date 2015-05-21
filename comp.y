%{

%}



%%

Prog	:	Decls Instrs	{}
		;

Decls	:	InitVar			{}
		|	Decls InitVar	{}
		;

InitVar	:	'int' Var ';'	{}
		;

Var		:	id				{}
		|	id '[' Exp ']'	{}
		;

Instrs	:	Instr 			{}
		|	Instrs Instr 	{}
		;	

Inst	:	If 				{}		
		|	While 			{}
		|	For 			{}
		|	Atr	';'			{}
		|	IO	';'			{}
		;

If		:	'if' '(' Cond ')' '{' Instrs '}'						{}
		|	'if' '(' Cond ')' '{' Instrs '}' 'else' '{' Instrs '}'	{}
		;

While 	: 	'while' '(' Cond ')' '{' Instrs '}'						{}
		;

For		:	'for' '(' Atr ',' Cond ',' Atr ')' '{' Instrs '}'		{}
		;

Atr		:	Var '='	Exp		{}
		;

IO		:	'print' Out		{}
		|	'input' Var 	{}
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

Conp	:	Exp				{}
		|	Exp OpConp Exp	{}
		;

OpComp	:	'>'
		|	'<'
		|	'>='
		|	'<='
		|	'=='
		|	'!='
		;
%%

int yyerror(char *s){
	printf("erro sintático: %s\n", s);
}
     
int main(){
	yyparse(); 
	return 0; 
}	
