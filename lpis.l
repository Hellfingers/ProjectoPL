%{
	#include "y.tab.h"
%}
%x COMENTARIO

num [0-9]+
pal [a-zA-Z]+

%%

";"       { return yytext[0]; }
"int"     { return INT; }
{pal}	  { yylval.id = stdup(yytext);return id;}

.|\n      { ; }

%%

int yywrap()
    { return(1); }
