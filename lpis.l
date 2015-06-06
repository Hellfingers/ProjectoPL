%{
	#include <stdlib.h>
%}
%x COMENTARIO

%option yylineno

num [0-9]+
pal [a-zA-Z]+

%%


.*\/\/.*		{
					;
				}
		
.*\/\*			{
					BEGIN COMENTARIO;
				}

<COMENTARIO>\*\/	{BEGIN INITIAL;}

<COMENTARIO>.|\n 	{;}

"int"	     	{ 
					return INT; 
				}

"string"     	{ 
					return STRING; 
				}

"if"			{
					return IF;
				}

"else"			{
					return ELSE;
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

[+-]				{
						yylval.valOp = yytext[0];
						return OpA;
					}

[*\/%]				{
						yylval.valOp = yytext[0];
						return OpM;
					}

\"[^\"]*\"			{yylval.valc = strdup(yytext);return str;}

(([<>][=]?)|"=="|"!=")		{
								yylval.valc = strdup(yytext);
								return OpComp;
							}					

([<>\(\)\{\}\[\];=!&]|"|")		{
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
