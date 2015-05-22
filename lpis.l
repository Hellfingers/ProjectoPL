%{
	#include <stdlib.h>
%}
%x COMENTARIO

num [0-9]+
pal [a-zA-Z]+

%%

"int"	     	{ 
					return INT; 
				}

"if"			{
					return IF;
				}

"while"			{
					return WHILE;
				}

"for"			{
					return FOR;
				}

"print"			{
					return PRINT;
				}

"input"			{
					return INPUT;
				}

[<>()\{\}\[\];=+*\/]    {
					return yytext[0]; 
				}

{pal}			{ 
					yylval.valc = strdup(yytext);
					return id;
				}

{num}			{
					yylval.vali = atoi(yytext);
					return num;
				}


.|\n      		{ 
					; 
				}

%%

int yywrap()
    { return(1); }
