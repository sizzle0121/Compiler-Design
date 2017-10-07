%{
# define LIST strcat (buf , yytext )
# define token(s) { LIST ; if ( Opt_T ) printf ("<%s>\n", (s));}
# define tokenKW(s) {LIST ; if( Opt_T ) printf("<KW%s>\n", (s));}
//# define tokenChar(t) { LIST ; if ( Opt_T ) printf ("<%c>\n", (t));}
# define tokenInteger(t, i) { LIST ; if ( Opt_T ) printf ("<%s: %d>\n", #t, (i));}
# define tokenString(t, s) { LIST ; if ( Opt_T ) printf ("<%s: %s>\n", #t, (s));}
# define MAX_LINE_LENG 256
int Opt_S = 1;
int Opt_T = 1;
int linenum = 1;
char buf[ MAX_LINE_LENG ];
char *t;
%}

keyword			array|begin|boolean|def|do|else|end|false|for|integer|if|of|print|read|real|string|then|to|true|return|var|while
digit			[0-9]
letter			[a-zA-Z]
id				{letter}({letter}|{digit})*	
delimiter		","|";"|":"|"("|")"|"["|"]"
arithmetic		"+"|"-"|"*"|"/"|mod|":="
relational		"<"|"<="|"<>"|">="|">"|"="
logical			and|or|not
oct_integer		(-?0{digit}+)
integer 		(0|(-?[1-9]{digit}*))
posint			([1-9]{digit}*)
float			({integer}\.{digit}+)
posfloat		({posint}\.{digit}+)
scientific		({posfloat}|{posint})[E|e][+-]?{posint}
string 			(\".*\")

whitespace		[\40\t]
comment			((\/\/).*|(\/\*.*\*\/))


%%

{whitespace}	{ LIST; }
{comment}		{ LIST; }

{keyword}		{ tokenKW(yytext); }

{id}			{ tokenString(id,yytext); }

{delimiter}		{ token(yytext); }

{arithmetic}	{ token(yytext); }
{relational}	{ token(yytext); }
{logical}		{ token(yytext); }

{integer}		{ tokenString(integer,yytext); }
{oct_integer}	{ tokenString(oct_integer,yytext); }


{float}			{ tokenString(float,yytext); }

{scientific}	{ tokenString(scientific,yytext); }

{string}		{
	char newtext[256];
	int i;
	for(i=1; i<yyleng-1; i++){
		newtext[i-1] = yytext[i];
	}
	newtext[i-1] = '\0';
	tokenString(string,newtext);
}



\n 		{
			LIST ;
			if ( Opt_S )
			printf ("%d: %s", linenum , buf );
			linenum ++;
			buf [0] = '\0';
		}



%%

int main ( int argc , char ** argv ){
	if( argc != 2 ) {
		fprintf ( stderr , " Usage : ./ scanner [ filename ]\n" );
		exit (0);
	}
	FILE *fp = fopen ( argv [1] , "r" );
	if( fp == NULL ) {
		fprintf ( stderr , " Open file error \n" );
		exit ( -1);
	}
	yyin = fp;
	yylex ();
	exit (0);
}