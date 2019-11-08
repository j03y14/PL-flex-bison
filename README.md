# PL-flex-bison

### 1. 컴파일 방법

	flex lexical_analyzer.l	

	bison -d parser.y

	gcc -o parser lex.yy.c parser.tab.c
	
### 2. 토큰 종류
	%token <str> T_ID
	%token <int_num> T_INTEGER
	%token <float_num> T_FLOAT
	%token <str> T_KEYWORD
	%token <str> T_OPERATOR
	%token <str> T_DELIMITER
	%token T_WHITESPACE
	
	한 토큰 안에서 lexeme이 어떤건지는 yyval 안에 들어있다.
	예를들어,
	Exp : Exp ‘+’ T_INTEGER {$$=$1+$3;}
		| Exp ‘-’ T_INTEGER {$$=$1-$3;}
 		| T_INTEGER {$$=$1;} 
	같은 경우에 $1, $3의 값이 각 토큰을 가져왔을 때 yyval에 들어있는 것.
	
	
### 3. 참고 자료
<https://www.joinc.co.kr/w/Site/Development/Env/Yacc>
<http://web.donga.ac.kr/jwjo/Lectures/Compiler_Notes/5.1.YACC%EC%98%88%EC%A0%9C(%EA%B3%84%EC%82%B0%EA%B8%B0).pdf>

### 4. 참고
혹시 gcc 컴파일 할 때 Internal error: Aborted (program collect2)에러가 뜨면
<https://sourceforge.net/projects/mingw/> 여기서 gcc 다시 설치하면 에러 없어져요
