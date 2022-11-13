# Design Decisions
## Definitions
A comment_val variable was used to store the depth of the comment, allowing nested comment without errors.
When a token "(*" is reached, the comment_val is incremented:

	int comment_val = 0;

**The regular expressions were defined as follows:**

Digits can be numbers from 0 to 9:

	DIGIT [0-9] 

An type identifier starts with an uppercase letter and is followed by letters, numbers or underline:

	TYPE_ID [A-Z][a-zA-Z0-9_]*

An object identifier starts with an lowercase letter and is followed by letters, numbers or underline:
	
	OBJECT_ID [a-z][a-zA-Z0-9_]*

A integer is formed by at least one digit:
	
	INTEGER {DIGIT}+

**The rules for DARROW, ASSIGN, LE, COMMENT_START, COMMENT_END, STRING_DELIMITER were defined as follows:**
	
	DARROW            =>
	ASSIGN            <-
	LE                <=
	COMMENT_START     ("(*")
	COMMENT_END       ("*)")
	STRING_DELIMITER  "\""

**The defined states of the lexer were:**

When a comment starts:

	COMMENT

When a string starts:

	STRING

When an error is found in a string:

	STRING_ERROR

## Rules

**Rules for returning tokens for main symbols and operators:**

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

**Rules for returning tokens and values for keywords that handle case-sensitive booleans:**

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
 
**Rules for returning identifiers's tokens and add the values to the stringtable:**

	{TYPE_ID} {
		cool_yylval.symbol = stringtable.add_string(yytext);
		return TYPEID;
	}

	{OBJECT_ID} {
		cool_yylval.symbol = stringtable.add_string(yytext);
		return OBJECTID;
	}

**Rule for returning the integer token with the respective value:**

	{INTEGER} { cool_yylval.symbol = inttable.add_string(yytext); return INT_CONST; }

### Rules for commenting logic:

**Return error for unmached end of comment:**
	
	{COMMENT_END} {
  	yylval.error_msg = "Unmatched *)";
  	return ERROR;
	}

**Condition for start a comment:**

	{COMMENT_START} { 
	comment_val = 1;
	BEGIN(COMMENT);	
	}

**Comment inside the comment:**

	<COMMENT>{COMMENT_START} {
	comment_val++;
	}

**Comment ends. If is a subcomment, just decrease the depth and continue. Else, finish the comment:**

	<COMMENT>{COMMENT_END} {
	comment_val--;
	if (comment_val == 0) 
		BEGIN(INITIAL);
	}

**Returning an error when a comment reaches the End Of File:**

	<COMMENT><<EOF>> {
	BEGIN(INITIAL);
	yylval.error_msg = "EOF in comment";
	return ERROR;
	}

**Allowing to skip lines in comment:**

	<COMMENT>\n {
	curr_lineno++;
	}

**Allowing any character that does not match the rules above:**

	<COMMENT>. {} 

### Rules for string constant logic:

**Condition for start a string:**

	{STRING_DELIMITER} {
	string_buf_ptr = string_buf;
	BEGIN(STRING);
	}

**Condition for close a string and add it to stringtable when a quote is reached:**

	<STRING>{STRING_DELIMITER} {
	BEGIN(INITIAL);
	(*string_buf_ptr) = '\0';
	cool_yylval.symbol = stringtable.add_string(string_buf);
	return STR_CONST;
	}

**Condition for allowing endline in a string by inserting a \ before the line break:**

	<STRING>"\\"\n {
	curr_lineno++;
	if (string_buf_ptr - string_buf > MAX_STR_CONST - 2) {
		BEGIN(STRING_ERROR);
		yylval.error_msg = "String constant too long";
		return ERROR;
	}
	*(string_buf_ptr++) = '\n';
	}

**Return an error if the string reaches the End Of File:**

	<STRING><<EOF>> {
	yylval.error_msg = "EOF in string constant";
	return ERROR;
	}

**Return an error if the string reaches the end of line:**

	<STRING>\n {
	curr_lineno++;
	string_buf_ptr = string_buf;
	BEGIN(INITIAL);
	yylval.error_msg = "Unterminated string constant";
	return ERROR;
	}

**Return an error if the string contains the null character:**

	<STRING>\0 {
	BEGIN(STRING_ERROR);
	yylval.error_msg = "String contains null character";
	return ERROR;
	}

**Logic for recognizing \b, \t, \f, \n and converting the general cases:**

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

**Accepting any character not matched in the rules above if it doesn't cause an error:**

	<STRING>.                {
	if (string_buf_ptr - string_buf > MAX_STR_CONST - 2) {
		BEGIN(STRING_ERROR);
		yylval.error_msg = "String constant too long";
		return ERROR;
	}
	*(string_buf_ptr++) = yytext[0];
	}

**Condition called when an error is found in the string. It stops when reaches a quote, break line or End of File:**

	<STRING_ERROR>{STRING_DELIMITER} {
	BEGIN(INITIAL);
	}

	<STRING_ERROR>\n {
	BEGIN(INITIAL);
	}

	<STRING_ERROR><<EOF>> {return 0;}
	<STRING_ERROR>. {}

### Rules for whitespaces and invalid characters

**If an endline is reached, just update the variable curr_lineno:**

	\n              { curr_lineno++; }

**Any other whitespace iss accepted, but no action is needed:**

	[ \t\r\v\f]+    {} 

**Any character that doesn't match with any rule above is an invalid character, and an error should be returned:**

	. { 
	yylval.error_msg = yytext;
	return ERROR;
	}

# Tests

**Testing the unmatched end of comment:**

	*)

**Testing if the conversion is working in general case inside a string and returning \n \b \t \f in the specific cases:**

	"\0\\1\2\3\\4\\\5\\n\b\t\f\0\9\h\l\s"

**Breaking line special character inside a string:**

	"Breaking line in a string \n line break"

**The symbol ! returns an error, and "variavel", "=", "4" are valid tokens:**

	!variavel = 4

**All symbols are valid tokens, but "_" returns an error:**

	_variavel = 5

**Testing quotes inside a string with escape character:**

	" These are two quotes \"inside the string\""

**The greater than signal wasn't defined, so it returns an error:**

	3 > 5

**The greater than signal works inside a string:**

	greaterTesting_than = ">"

**Continue the string in a new line is allowed with the escape character:**

	"End line inside \
	the string"

**This long string constant returns an error:**

	"THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!"

**An object id followed by a point and another object id is allowed:**

	object.property.get_property()

**3three is a lexical valid sentence, but generate a token for an integer and a token for the identifier:**

	3three (* this is valid *)

**invalid-identifier generates two identifiers and a "-" token:**

	invalid-identifier

**gabriel&mariano generates two identifiers and a error for the undefined token "&" token:**

	gabriel&mariano

**Comments inside string are allowed:**

	"I will comment inside (*this string *)"

**Keywords generate a specific token:**

	class else fi if in inherits isvoid let loop then while case esac new of not

**Boolean keywords need to starts with lowercase letter:**

	true false tRUe fALse

**The code below returns two type identifiers:**

	True False

**All these keywords are normally accepted by the lexer:**

	clASS ELse FI iF IN inheRIts iSVoid Let lOOp tHEN wHIle CAse eSAc NEW OF nOT

**The string returns an error if it reaches the end of the file:**

	"Goodbye this is the End of File...
