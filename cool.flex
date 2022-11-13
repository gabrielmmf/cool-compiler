/*
 *  The scanner definition for COOL.
 */

/*
 *  Stuff enclosed in %{ %} in the first section is copied verbatim to the
 *  output, so headers and global definitions are placed here to be visible
 * to the code in the file.  Don't remove anything that was here initially
 */
%{
#include <cool-parse.h>
#include <stringtab.h>
#include <utilities.h>

/* The compiler assumes these identifiers. */
#define yylval cool_yylval
#define yylex  cool_yylex

/* Max size of string constants */
#define MAX_STR_CONST 1025
#define YY_NO_UNPUT   /* keep g++ happy */

extern FILE *fin; /* we read from this file */

/* define YY_INPUT so we read from the FILE fin:
 * This change makes it possible to use this scanner in
 * the Cool compiler.
 */
#undef YY_INPUT
#define YY_INPUT(buf,result,max_size) \
	if ( (result = fread( (char*)buf, sizeof(char), max_size, fin)) < 0) \
		YY_FATAL_ERROR( "read() in flex scanner failed");

char string_buf[MAX_STR_CONST]; /* to assemble string constants */
char *string_buf_ptr;

extern int curr_lineno;
extern int verbose_flag;

extern YYSTYPE cool_yylval;

/*
 *  Add Your own definitions here
 */

 /* ADICIONADO POR TZ; */

/* Varieble to store the number of subcomments */
 int comment_val = 0

 
 /* Macro for send errors */
 #define RETURN_ERROR(msg) \
	       yylval.error_msg = msg;\
	       return ERROR;

 /* FIM DA ADIÇÃO DE TZ */

%}

/*
 * Define names for regular expressions here.		
 */

DIGIT [0-9]
TYPE_ID [A-Z][a-zA-Z0-9_]*
OBJECT_ID [a-z][a-zA-Z0-9_]*
INTEGER {DIGIT}+

DARROW          =>

/* ADICIONADO POR TZ: */

ASSIGN               <-
LE                   <=

COMMENT_START        ("(*")
COMMENT_END          ("*)")

STRING_DELIMITER         "\""


/* STATES OF THE LEXER */
%x COMMENT STRING STRING_ERROR

/* FIM DA ADIÇÃO DE TZ */

%%
/* ADICIONADO POR TZ */

\n              { curr_lineno++; }
[ \t\r\v\f]+    {} 

/* FIM DA ADIÇÃO DE TZ */

 /*
  *  Nested comments
  */

/* ADICIONADO POR TZ */

/* VERIFY UNMATCHED COMMENT */
{COMMENT_END} {
  RETURN_ERROR("Unexpected end of commentary")
}

{COMMENT_START} { 
  BEGIN(COMMENT);
  comment_val = 1
}

<COMMENT>{COMMENT_START}{
  comment_val++;
}

<COMMENT>{COMMENT_END}{
  comment_val--;
  if (comment_val == 0) 
    BEGIN(INITIAL);
}

<COMMENT>\n {
  curr_lineno++;
}

<COMMENT><<EOF>> {
  BEGIN(INITIAL)
  RETURN_ERROR("Comment reached the End Of File")
}

/* FIM DA ADIÇÃO DE TZ */


 /*
  *  The multiple-character operators.
  */
"+" {return '+';}
"-" {return '-';}
"*" {return "*";}
"/" {return "/";}
"=" {return "=";}
"(" {return '(';}
")" {return ')';}
"{" {return '{';}
"}" {return '}';}
"@" {return '@';}
":" {return ':';}
";" {return ';';}
'.' {return '.';}
',' {return ',';}
'<' {return '<';}
'~' {return '~';}

{DARROW}		{ return (DARROW); }

/*ADICIONADO POR TZ: */

{ASSIGN} { return (ASSIGN);}
{LE} { return (LE);}
{INTEGER} { cool_yylval.symbol = inttable.add_string(yytext); return INT_CONST; }

/* FIM DA ADIÇÃO DE TZ */

 /*
  * Keywords are case-insensitive except for the values true and false,
  * which must begin with a lower-case letter.
  */

(t)(?i:rue){
    cool_yylval.boolean = true;
    return BOOL_CONST;
}

(f)(?i:alse){
    cool_yylval.boolean = false;
    return BOOL_CONST;
}  
(?i:class) {return CLASS;}
(?i:else) {return ELSE;}
(?i:fi) {return FI;}
(?i:if) {return IF;}
(?i:in) {return IN;}
(?i:inherits) {return INHERITS;}
(?i:isvoid) {return ISVOID;}
(?i:let) {return LET;}
(?i:loop) {return LOOP;}
(?i:pool) {return POOL;}
(?i:then) {return THEN;}
(?i:while) {return WHILE;}
(?i:case) {return CASE;}
(?i:esac) {return ESAC;}
(?i:new) {return NEW;}
(?i:of) {return OF;}
(?i:new) {return NEW;}
(?i:not) {return NOT;}

/* ADICIONADO POR TZ */

{TYPE_ID}{
  cool_yylval.symbol = stringtable.add_string(yytext);
	return TYPE_ID;
}

{OBJECT_ID} {
	cool_yylval.symbol = stringtable.add_string(yytext);
	return OBJECT_ID;
}


/* Any character that disrespect above rules throws an error: */

. { RETURN_ERROR(yytext) }

/*FIM DA ADIÇÃO DE TZ */

 /*
  *  String constants (C syntax)
  *  Escape sequence \c is accepted for all characters c. Except for 
  *  \n \t \b \f, the result is c.
  *
  */

/* ADICIONADO POR TZ */

{STRING_DELIMITER} {
  string_buf_ptr = string_buf;
  BEGIN(STRING);
}

<STRING>{STRING_DELIMITER} {
  BEGIN(INITIAL);
  (*string_buf_ptr) = '\0';
  cool_yylval.symbol = stringtable.add_string(string_buf);
  return STR_CONST
}

<STRING>"\\"\n {
  curr_lineno++;
  if (string_buf_ptr - string_buf + 2 > MAX_STR_CONST) {
    BEGIN(STRING_ERROR);
    RETURN_ERROR("String too much long")
  }
  *(string_buf_ptr++) = '\n';
}

<STRING><<EOF>> {
  RETURN_ERROR("String reache End Of File");
}

<STRING>\n {
  curr_lineno++;
  string_buf_ptr = string_buf;
  BEGIN(INITIAL);
  RETURN_ERROR("Unterminated string");
}

<STRING>\0 {
  BEGIN(STRING_ERROR);
  SET_ERROR("String contains null character");
}

<STRING>\\. {
  if (string_buf_ptr - string_buf + 2 > MAX_STR_CONST) {
    BEGIN(STRING_ERROR);
    RETURN_ERROR("String constant too much long");
  }
  if (yytext[1] == 'b') {
    (*string_buf_ptr++) = '\b';
  } else if (yytext[1] == 't') {
    (*string_buf_ptr++) = '\t';
  } else if (yytext[1] == 'n') {
    (*string_buf_ptr++) = '\n';
  } else if (yytext[1] == 'f') {
    (*string_buf_ptr++) = '\f';
  } else if (yytext[1] == '\0') {
    cool_yylval.error_msg = "String contains null character";
    BEGIN(STRING_ERROR);
    return (ERROR);
  } else {
    (*string_buf_ptr++) = yytext[1];
  }
}

<STRING>.                {
  if (string_buf_ptr - string_buf + 2 > MAX_STR_CONST) {
    BEGIN(STRING_ERROR);
    RETURN_ERROR("String constant too much long");
  }
  *(string_buf_ptr++) = yytext[0];
}

<STRING_ERROR>{STRING_DELIMITER}{
  BEGIN(INITIAL);
}

<STRING_ERROR>\n {
  BEGIN(INITIAL);
}

<STRING_ERROR><<EOF>> {return 0;}
<STRING_ERROR>. {}


/* FIM DA ADIÇÃO DE TZ */


%%
