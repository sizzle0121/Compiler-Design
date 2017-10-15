%Start COMMENT P_COMMENT

%{
# define LIST strcat (buf , yytext )
# define token(s) { LIST ; if ( Opt_T ) printf ("<%s>\n", (s));}
# define tokenKW(s) {LIST ; if( Opt_T ) printf("<KW%s>\n", (s));}
# define tokenInteger(t, i) { LIST ; if ( Opt_T ) printf ("<%s: %d>\n", #t, (i));}
# define tokenString(t, s) { LIST ; if ( Opt_T ) printf ("<%s: %s>\n", #t, (s));}
# define MAX_LINE_LENG 256
int Opt_S = 1;
int Opt_T = 1;
int linenum = 1;
char buf[ MAX_LINE_LENG ];
char *t;

//# define tokenChar(t) { LIST ; if ( Opt_T ) printf ("<%c>\n", (t));}
//Maybe need to add unrecognized lexem
//posfloat		({posint}\.{digit}+)
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

scientific		({float}|{integer})[E|e][+-]?{posint}
string 			(\".*\")

whitespace		[\40\t]
cpp_comment		((\/\/).*)			

pseudocomment	((\/\/)&[SsTt][+-].*)

%%

{whitespace}			{ LIST; }

<COMMENT>\*\/			{ LIST; BEGIN(INITIAL);  }
<COMMENT>.				{ LIST; /*printf(".\n");*/ }
<INITIAL>\/\*			{ LIST; BEGIN(COMMENT); /*printf("* : %d\n", yyleng);*/  /*printf("/*\n");*/ }	

<INITIAL>{pseudocomment}	{ 
		/*the order of S+- should be confirmed*/
			LIST ;
			if(yytext[3] == 'S' || yytext[3] == 's'){
				if(yytext[4] == '+')		Opt_S = 1;
				else if(yytext[4] == '-')	Opt_S = 0;
			}else if(yytext[3] == 'T' || yytext[3] == 't'){
				if(yytext[4] == '+')		Opt_T = 1;
				else if(yytext[4] == '-')	Opt_T = 0;
			}
}

<INITIAL>{cpp_comment}	{ LIST; }



<INITIAL>{keyword}		{ tokenKW(yytext); }

<INITIAL>{id}			{ tokenString(id,yytext); }

<INITIAL>{delimiter}	{ token(yytext); }

<INITIAL>{arithmetic}	{ token(yytext); }
<INITIAL>{relational}	{ token(yytext); }
<INITIAL>{logical}		{ token(yytext); }

<INITIAL>{integer}		{ tokenString(integer,yytext); }
<INITIAL>{oct_integer}	{ tokenString(oct_integer,yytext); }


<INITIAL>{float}		{ tokenString(float,yytext); }

<INITIAL>{scientific}	{ tokenString(scientific,yytext); }

<INITIAL>{string}		{
	char newtext[256];
	for(int k=0; k<256; k++)
		newtext[k] = '\0';

	int i = 1, j = 0;
	while(i < yyleng-1){
		if(i != yyleng-2 && yytext[i] == '\"' && yytext[i+1] == '\"'){
			i += 1;
		}else if((yytext[i] == '\"' && yytext[i+1] != '\"') || (i == yyleng-2 && yytext[i] == '\"')){
			/*error*/
			printf("error at line %d: bad character \"%s\"\n",linenum,yytext);
			exit(0);
		}
		newtext[j++] = yytext[i++];
	}
	newtext[j] = '\0';
	if(Opt_T)	tokenString(string,newtext);
}


\n 		{
			LIST ;
			if ( Opt_S )
			printf ("%d: %s", linenum , buf );
			linenum ++;
			buf [0] = '\0';
}

[\40-\176]		{
	printf("error at line %d: bad character \"%s\"\n",linenum,yytext);
	exit(0);
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

	return 0;
}