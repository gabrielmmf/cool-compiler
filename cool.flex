%option noyywrap
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

 int comment_val = 0;

%}

/*
 * Define names for regular expressions here.		
 */
 
DIGIT [0-9]
TYPE_ID [A-Z][a-zA-Z0-9_]*
OBJECT_ID [a-z][a-zA-Z0-9_]*
INTEGER {DIGIT}+

DARROW          =>
ASSIGN          <-
LE              <=

COMMENT_START        ("(*")
COMMENT_END          ("*)")

STRING_DELIMITER         "\""


/* STATES OF THE LEXER */

%x COMMENT STRING STRING_ERROR

%%

 /*
  *  The multiple-character operators.
  */
{DARROW}  { return (DARROW); }
{ASSIGN}  { return (ASSIGN);}
{LE} 	  { return (LE);}
 "+" {return '+';}
 "-" {return '-';}
 "*" {return '*';}
 "/" {return '/';}
 "~" {return '~';}
 "=" {return '=';}
 "(" {return '(';}
 ")" {return ')';}
 "{" {return '{';}
 "}" {return '}';}
 "@" {return '@';}
 ":" {return ':';}
 ";" {return ';';}
 "." {return '.';}
 "," {return ',';}
 "<" {return '<';}
 
 /*
  * Keywords are case-insensitive except for the values true and false,
  * which must begin with a lower-case letter.
  */

t(?i:rue) {
    cool_yylval.boolean = true;
    return BOOL_CONST;
}

f(?i:alse) {
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
(?i:not) {return NOT;}

{TYPE_ID} {
  	cool_yylval.symbol = stringtable.add_string(yytext);
	return TYPEID;
}

{OBJECT_ID} {
	cool_yylval.symbol = stringtable.add_string(yytext);
	return OBJECTID;
}
 
{INTEGER} { cool_yylval.symbol = inttable.add_string(yytext); return INT_CONST; }



 /*
  *  Nested comments
  */

{COMMENT_END} {
  yylval.error_msg = "Unmatched *)";
  return ERROR;
}

{COMMENT_START} { 
  comment_val = 1;
  BEGIN(COMMENT);
  
}

<COMMENT>{COMMENT_START} {
  comment_val++;
}

<COMMENT>{COMMENT_END} {
  comment_val--;
  if (comment_val == 0) 
    BEGIN(INITIAL);
}

<COMMENT><<EOF>> {
  BEGIN(INITIAL);
  yylval.error_msg = "EOF in comment";
  return ERROR;
}

<COMMENT>\n {
  curr_lineno++;
}

<COMMENT>. {} 


 /*
  *  String constants (C syntax)
  *  Escape sequence \c is accepted for all characters c. Except for 
  *  \n \t \b \f, the result is c.
  *
  */

{STRING_DELIMITER} {
  string_buf_ptr = string_buf;
  BEGIN(STRING);
}

<STRING>{STRING_DELIMITER} {
  BEGIN(INITIAL);
  (*string_buf_ptr) = '\0';
  cool_yylval.symbol = stringtable.add_string(string_buf);
  return STR_CONST;
}

<STRING>"\\"\n {
  curr_lineno++;
  if (string_buf_ptr - string_buf > MAX_STR_CONST - 2) {
    BEGIN(STRING_ERROR);
    yylval.error_msg = "String constant too long";
    return ERROR;
  }
  *(string_buf_ptr++) = '\n';
}

<STRING><<EOF>> {
  yylval.error_msg = "EOF in string constant";
  return ERROR;
}

<STRING>\n {
  curr_lineno++;
  string_buf_ptr = string_buf;
  BEGIN(INITIAL);
  yylval.error_msg = "Unterminated string constant";
  return ERROR;
}

<STRING>\0 {
  BEGIN(STRING_ERROR);
  yylval.error_msg = "String contains null character";
  return ERROR;
}

<STRING>\\. {
  if (string_buf_ptr - string_buf > MAX_STR_CONST - 2) {
    BEGIN(STRING_ERROR);
    yylval.error_msg = "String constant too long";
    return ERROR;
  }
  if (yytext[1] == '\0') {
    yylval.error_msg = "String contains null character";
    BEGIN(STRING_ERROR);
    return (ERROR);
  } 
  else if (yytext[1] == 'b') {
    (*string_buf_ptr++) = '\b';
  } 
  else if (yytext[1] == 't') {
    (*string_buf_ptr++) = '\t';
  }
  else if (yytext[1] == 'f') {
    (*string_buf_ptr++) = '\f';
  }  
  else if (yytext[1] == 'n') {
    (*string_buf_ptr++) = '\n';
  } 
  else {
    (*string_buf_ptr++) = yytext[1];
  }
}

<STRING>.                {
  if (string_buf_ptr - string_buf > MAX_STR_CONST - 2) {
    BEGIN(STRING_ERROR);
    yylval.error_msg = "String constant too long";
    return ERROR;
  }
  *(string_buf_ptr++) = yytext[0];
}

<STRING_ERROR>{STRING_DELIMITER} {
  BEGIN(INITIAL);
}

<STRING_ERROR>\n {
  BEGIN(INITIAL);
}

<STRING_ERROR><<EOF>> {return 0;}
<STRING_ERROR>. {}


\n              { curr_lineno++; }

[ \t\r\v\f]+    {} 

. { 
  yylval.error_msg = yytext;
  return ERROR;
 }

%%
