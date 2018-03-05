/* MAFTEI Stefan - Radu, grupa 336CC */
%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#define MAX_BUFF 100

	// details for functions' parameters
	typedef struct param {
		int size_of_name;
		int size_of_defaultValue;
		char* name;
		int hasDefaultValue;
		char* defaultValue;
	} TParam;

	// python functions details
	typedef struct functionPy{
		int size_of_name;
		char* name;
		int nrParamsAccept;
		int isDecoratorReturn;
		int nrReturns;
		int nrParams;
		TParam* params;
		int nrCodeLines;
		int nrTODOs;
	} TFunctionPy;

	int alreadyAllocated = 0; // a function has been allocated because of a decorator
	int nr_functions = 0, nr_functions_aux; // nr of functions at the moment
	TFunctionPy* functions; // current functions

	// print details about the function till parameters' default values
	void printFunctionPart1()
	{
		int i;
		if (nr_functions > 1)
		{
			printf("\ninner ");
		}

		if (functions[nr_functions - 1].nrParams > 0)
		{
			printf("function %s(", functions[nr_functions - 1].name);
		}
		else
		{
			printf("function %s()\n", functions[nr_functions - 1].name);
		}

		for (i = 0; i < functions[nr_functions - 1].nrParams - 1; i++)
		{
			printf("%s, ", functions[nr_functions - 1].params[i].name);
		}
		if (functions[nr_functions - 1].nrParams > 0)
		{
			printf("%s)\n", functions[nr_functions - 1].params[i].name);
		}

		for (i = 0; i < functions[nr_functions - 1].nrParams; i++)
		{
			if (functions[nr_functions - 1].params[i].hasDefaultValue == 1)
			{
				printf("parameter %s has default value %s\n", functions[nr_functions - 1].params[i].name, functions[nr_functions - 1].params[i].defaultValue);
			}
		}	
	}

	// print details about the function from number of code lines till the end
	void printFunctionPart2()
	{
		int i;

		printf("has %d lines of code\n", functions[nr_functions - 1].nrCodeLines);

		if (functions[nr_functions - 1].nrReturns > 0)
		{
			printf("has returns\n");
		}

		if (functions[nr_functions - 1].nrTODOs > 0)
		{
			printf("function incomplete: %d TODOs remaining\n", functions[nr_functions - 1].nrTODOs);
		}

		if (functions[nr_functions - 1].nrParamsAccept != -1 && functions[nr_functions - 1].nrParamsAccept != functions[nr_functions - 1].nrParams)
		{
			printf("decorator inconsistency: wrong parameter number\n");
		}

		if (functions[nr_functions - 1].isDecoratorReturn == 1 && functions[nr_functions - 1].nrReturns == 0)
		{
			printf("decorator inconsistency: no return found\n");
		}

		printf("\n");
	}

	// free allocated space
	void freeFunction()
	{
		int i;
		for (i = 0; i < functions[nr_functions - 1].nrParams; i++)
		{
			free(functions[nr_functions - 1].params[i].name);
			free(functions[nr_functions - 1].params[i].defaultValue);
		}
		free(functions[nr_functions - 1].params);
		free(functions[nr_functions - 1].name);

		if (nr_functions == 1)
		{
			free(functions);
		}
	}
%}

index [0-9]+
multipleSpaces [ ]*
whitespaces [ \t\n]*

%s commentSharp commentSharpTask commentQuoteTask commentQuote
%s decoratorAccepts decoratorReturns
%s mainFunction mainFunctionParams mainFunctionParamsDefaultValues mainFunctionLines mainFunctionLinesBegin mainFunctionReturnLines
%s mainFunctionCommentSharp mainFunctionCommentQuote mainFunctionCommentSharpTODO mainFunctionCommentQuoteTODO
%s decoratorAcceptsInner decoratorReturnsInner innerFunction innerFunctionParams innerFunctionParamsDefaultValues innerFunctionLines innerFunctionLinesBegin innerFunctionReturnLines
%s innerFunctionCommentSharp innerFunctionCommentQuote innerFunctionCommentSharpTODO innerFunctionCommentQuoteTODO

%%
<INITIAL>"# TODO:"|"# TODO"{index}":" { BEGIN(commentSharpTask);
										printf("found task:"); }
<INITIAL>"#" { BEGIN(commentSharp); }
<INITIAL>"''' TODO:"|"''' TODO"{index}":" { BEGIN(commentQuoteTask);
											printf("found task:"); }
<INITIAL>"'''" { BEGIN(commentQuote); }
<INITIAL>"@accepts(" { // accepts decorator for outer function
					   BEGIN(decoratorAccepts);
					   // allocate the function that comes next
					   nr_functions++;
					   functions = (TFunctionPy*) malloc(sizeof(TFunctionPy));
					   functions->nrParamsAccept = 0;
					   functions->nrReturns = 0;
					   functions->nrParams = 0;
					   functions->isDecoratorReturn = 0;
					   alreadyAllocated = 1; }
<INITIAL>"@returns(" { // returns decorator for outer function
					   BEGIN(decoratorReturns);
					   if (alreadyAllocated == 1)
					   {
					   		functions->isDecoratorReturn = 1;
					   }
					   else
					   {
							nr_functions++;
							functions = (TFunctionPy*) malloc(sizeof(TFunctionPy));
							functions->nrParamsAccept = -1;
							functions->isDecoratorReturn = 1;
							functions->nrParams = 0;
							alreadyAllocated = 1;
					   }; }
<INITIAL>"def" { // outer function found
				 BEGIN(mainFunction);
				 if (alreadyAllocated == 1)
			     {
			   		alreadyAllocated = 0;
			   	 }
			     else
			     {
					nr_functions++;
					functions = (TFunctionPy*) malloc(sizeof(TFunctionPy));
					functions->nrParamsAccept = -1;
					functions->nrParams = 0;
					alreadyAllocated = 0;
			     };
			     functions->size_of_name = 0;
			     functions->name = (char*) calloc(MAX_BUFF, sizeof(char)); }
<INITIAL>.|\n ;

<commentSharpTask>\n { BEGIN(INITIAL);
					   printf("\n\n"); }
<commentSharpTask><<EOF>> { BEGIN(INITIAL); printf("\n\n"); }

<commentSharp>. ;
<commentSharp>\n { BEGIN(INITIAL); }
<commentSharp><<EOF>> { BEGIN(INITIAL); }

<commentQuoteTask>"'''" { BEGIN(INITIAL); printf("\n\n"); }

<commentQuote>.|\n ;
<commentQuote>"'''" { BEGIN(INITIAL); }

<decoratorAccepts>","|")" { functions->nrParamsAccept++; /* new accepts parameter read*/ }
<decoratorAccepts>\n { BEGIN(INITIAL); }
<decoratorAccepts>. ;

<decoratorReturns>\n { BEGIN(INITIAL); }
<decoratorReturns>. ;

<mainFunction>"("/[^,)]+ {  // time to read parameters for the outer function
							BEGIN(mainFunctionParams);
							functions->nrParams = 1;
							functions->params = (TParam*) malloc(sizeof(TParam));
						 	functions->params->name = (char*) calloc(MAX_BUFF, sizeof(char));
						 	functions->params->hasDefaultValue = 0;
						 	functions->params->defaultValue = NULL;
						 	functions->nrCodeLines = 0;
						 	functions->nrReturns = 0;
						 	functions->nrTODOs = 0; }
<mainFunction>"(" { // there are no parameters
					BEGIN(mainFunctionParams);
					functions->nrParams = 0;
					functions->nrCodeLines = 0;
					functions->nrReturns = 0;
					functions->nrTODOs = 0; }
<mainFunction>" " ;
<mainFunction>. { // obtain outer function's name
				  functions->name[functions->size_of_name] = yytext[0];
				  functions->size_of_name++; }

<mainFunctionParams>"=" { // obtain default value for parameters that have default values
						  BEGIN(mainFunctionParamsDefaultValues);
						  if (functions->nrParams == 1)
						  {
						   		functions->params->hasDefaultValue = 1;
						   		functions->params->defaultValue = (char*) calloc(MAX_BUFF, sizeof(char));
						  }
						  else
						  {
								functions->params[functions->nrParams - 1].defaultValue = (char*) calloc(MAX_BUFF, sizeof(char));
						  		functions->params[functions->nrParams - 1].hasDefaultValue = 1;
						  }; }
<mainFunctionParams>"," { // new parameter comes next
						  functions->nrParams++;
						  functions->params = (TParam*) realloc(functions->params, functions->nrParams * sizeof(TParam));
						  functions->params[functions->nrParams - 1].name = (char*) calloc(MAX_BUFF, sizeof(char));
						  functions->params[functions->nrParams - 1].hasDefaultValue = 0; }
<mainFunctionParams>"):"[^\n]* { // end of parameters reading
								 BEGIN(mainFunctionLines);
								 printFunctionPart1(); }
<mainFunctionParams>[^,)\n\t ] { // read parameter's name
								 if (functions->nrParams == 1)
							     {
							   		strcat(functions->params->name, yytext);
							     }
							     else
							     {
								 	strcat(functions->params[functions->nrParams - 1].name, yytext);
							     }; }
<mainFunctionParams>" "|\n|\t ;

<mainFunctionParamsDefaultValues>"," { // new parameter found
									   BEGIN(mainFunctionParams);
									   functions->nrParams++;
									   functions->params = (TParam*) realloc(functions->params, functions->nrParams * sizeof(TParam));
									   functions->params[functions->nrParams - 1].name = (char*) calloc(MAX_BUFF, sizeof(char));
									   functions->params[functions->nrParams - 1].hasDefaultValue = 0; }
<mainFunctionParamsDefaultValues>"):"[^\n]* { // end of reading parameters
											  BEGIN(mainFunctionLines);
											  printFunctionPart1(); }
<mainFunctionParamsDefaultValues>[^\n ] { // obtain default values for certain parameters
										  if (functions->nrParams == 1)
										  {
										   		strcat(functions->params->defaultValue, yytext);
										  }
										  else
										  {
										 		strcat(functions->params[functions->nrParams - 1].defaultValue, yytext);
										  }; }
<mainFunctionParamsDefaultValues>" "|\n ;

<mainFunctionLines>"# TODO:"|"# TODO"{index}":" { BEGIN(mainFunctionCommentSharpTODO);
												  functions->nrTODOs++; }
<mainFunctionLines>"#" { BEGIN(mainFunctionCommentSharp); }
<mainFunctionLines>"''' TODO:"|"''' TODO"{index}":" { BEGIN(mainFunctionCommentQuoteTODO);
													  functions->nrTODOs++; }
<mainFunctionLines>"'''" { BEGIN(mainFunctionCommentQuote); }
<mainFunctionLines>\n { BEGIN(mainFunctionLinesBegin);
						functions->nrCodeLines++; }
<mainFunctionLines>. ;

<mainFunctionLinesBegin>\t|"    " { BEGIN(mainFunctionReturnLines); }
<mainFunctionLinesBegin>. { BEGIN(INITIAL);
							printFunctionPart2();
							freeFunction(); nr_functions = 0;
							// no indentation found so we exited function
							yyless(0); }
<mainFunctionLinesBegin>\n ;

<mainFunctionReturnLines>{whitespaces}"return " { BEGIN(mainFunctionLines);
									 			  functions->nrReturns++; }
<mainFunctionReturnLines>{whitespaces}"return"\n { BEGIN(mainFunctionLinesBegin);
												   functions->nrCodeLines++;
												   functions->nrReturns++; }
<mainFunctionReturnLines>\n { BEGIN(mainFunctionLinesBegin); }
<mainFunctionReturnLines>"# TODO:"|"# TODO"{index}":" { BEGIN(mainFunctionCommentSharpTODO);
												  	    functions->nrTODOs++; }
<mainFunctionReturnLines>"#" { BEGIN(mainFunctionCommentSharp); }
<mainFunctionReturnLines>"''' TODO:"|"''' TODO"{index}":" { BEGIN(mainFunctionCommentQuoteTODO);
													 		functions->nrTODOs++; }
<mainFunctionReturnLines>"'''" { BEGIN(mainFunctionCommentQuote); }
<mainFunctionReturnLines>"@accepts(" { // found inner functions decorator
									   BEGIN(decoratorAcceptsInner);
									   // alocate inner function
					   				   nr_functions++;
									   functions = (TFunctionPy*) realloc(functions, nr_functions * sizeof(TFunctionPy));
									   functions[nr_functions - 1].nrParamsAccept = 0;
									   functions[nr_functions - 1].nrReturns = 0;
									   functions[nr_functions - 1].nrParams = 0;
									   functions[nr_functions - 1].isDecoratorReturn = 0;
									   alreadyAllocated = 1; }
<mainFunctionReturnLines>"@returns(" { // found inner functions decorator
									   BEGIN(decoratorReturnsInner);
									   // alocate inner function if it wasn't already allocated
									   if (alreadyAllocated == 1)
									   {
									   		functions[nr_functions - 1].isDecoratorReturn = 1;
									   }
									   else
									   {
											nr_functions++;
											functions = (TFunctionPy*) realloc(functions, nr_functions * sizeof(TFunctionPy));
										    functions[nr_functions - 1].nrParamsAccept = -1;
										    functions[nr_functions - 1].nrReturns = 0;
										    functions[nr_functions - 1].nrParams = 0;
										    functions[nr_functions - 1].isDecoratorReturn = 1;
										    alreadyAllocated = 1;
									   }; }
<mainFunctionReturnLines>"def" { // found inner function
								 BEGIN(innerFunction);
								 // allocate inner function if it wasn't already allocated
								 if (alreadyAllocated == 1)
							     {
							   		alreadyAllocated = 0;
							   	 }
							     else
							     {
									nr_functions++;
									functions = (TFunctionPy*) realloc(functions, nr_functions * sizeof(TFunctionPy));
									functions[nr_functions - 1].nrParamsAccept = -1;
									functions[nr_functions - 1].nrParams = 0;
									alreadyAllocated = 0;
							     };
							     functions[nr_functions - 1].size_of_name = 0;
							     functions[nr_functions - 1].name = (char*) calloc(MAX_BUFF, sizeof(char)); }
<mainFunctionReturnLines>. { BEGIN(mainFunctionLines); }

<mainFunctionCommentSharpTODO>\n { BEGIN(mainFunctionLinesBegin); }
<mainFunctionCommentSharpTODO><<EOF>> { BEGIN(INITIAL); }
<mainFunctionCommentSharpTODO>. ;

<mainFunctionCommentSharp>. ;
<mainFunctionCommentSharp>\n { BEGIN(mainFunctionLinesBegin); }
<mainFunctionCommentSharp><<EOF>> { BEGIN(INITIAL); }

<mainFunctionCommentQuoteTODO>"'''"|"'''"{multipleSpaces}\n { BEGIN(mainFunctionLinesBegin); }
<mainFunctionCommentQuoteTODO><<EOF>> { BEGIN(INITIAL); }
<mainFunctionCommentQuoteTODO>.|\n ;

<mainFunctionCommentQuote>.|\n ;
<mainFunctionCommentQuote>"'''"|"'''"{multipleSpaces}\n { BEGIN(mainFunctionLinesBegin); }
<mainFunctionCommentQuote><<EOF>> { BEGIN(INITIAL); }

<decoratorAcceptsInner>","|")" { functions[nr_functions - 1].nrParamsAccept++; /* inner function's new accepts parameter */}
<decoratorAcceptsInner>\n { BEGIN(innerFunctionLinesBegin); }
<decoratorAcceptsInner>. ;

<decoratorReturnsInner>\n { BEGIN(innerFunctionLinesBegin); }
<decoratorReturnsInner>. ;

<innerFunction>"("/[^,)]+ { // inner function with parameters (allocate space for them)
							BEGIN(innerFunctionParams);
							functions[nr_functions - 1].nrParams = 1;
							functions[nr_functions - 1].params = (TParam*) malloc(sizeof(TParam));
						 	functions[nr_functions - 1].params->name = (char*) calloc(MAX_BUFF, sizeof(char));
						 	functions[nr_functions - 1].params->hasDefaultValue = 0;
						 	functions[nr_functions - 1].params->defaultValue = NULL;
						 	functions[nr_functions - 1].nrCodeLines = 0;
						 	functions[nr_functions - 1].nrReturns = 0;
						 	functions[nr_functions - 1].nrTODOs = 0; }
<innerFunction>"(" { // inner function without parameters
					 BEGIN(innerFunctionParams);
					 functions[nr_functions - 1].nrParams = 0;
					 functions[nr_functions - 1].nrCodeLines = 0;
					 functions[nr_functions - 1].nrReturns = 0;
					 functions[nr_functions - 1].nrTODOs = 0; }
<innerFunction>" " ;
<innerFunction>. { // read function's name
				   functions[nr_functions - 1].name[functions[nr_functions - 1].size_of_name] = yytext[0];
				   functions[nr_functions - 1].size_of_name++; }

<innerFunctionParams>"=" { // inner function's parameter has default value
						   BEGIN(innerFunctionParamsDefaultValues);
						   if (functions[nr_functions - 1].nrParams == 1)
						   {
						   		functions[nr_functions - 1].params->hasDefaultValue = 1;
						   		functions[nr_functions - 1].params->defaultValue = (char*) calloc(MAX_BUFF, sizeof(char));
						   }
						   else
						   {
								functions[nr_functions - 1].params[functions[nr_functions - 1].nrParams - 1].defaultValue = (char*) calloc(MAX_BUFF, sizeof(char));
						  		functions[nr_functions - 1].params[functions[nr_functions - 1].nrParams - 1].hasDefaultValue = 1;
						   }; }
<innerFunctionParams>"," { // new parameter to come
						   functions[nr_functions - 1].nrParams++;
						   functions[nr_functions - 1].params = (TParam*) realloc(functions[nr_functions - 1].params, functions[nr_functions - 1].nrParams * sizeof(TParam));
						   functions[nr_functions - 1].params[functions[nr_functions - 1].nrParams - 1].name = (char*) calloc(MAX_BUFF, sizeof(char));
						   functions[nr_functions - 1].params[functions[nr_functions - 1].nrParams - 1].hasDefaultValue = 0; }
<innerFunctionParams>"):"[^\n]* { // end of reading inner function's parameters
								  BEGIN(innerFunctionLines);
								  printFunctionPart1(); }
<innerFunctionParams>[^,)\n\t ] { // read parameter's name
								  if (functions[nr_functions - 1].nrParams == 1)
							      {
							   		strcat(functions[nr_functions - 1].params->name, yytext);
							      }
							      else
							      {
								 	strcat(functions[nr_functions - 1].params[functions[nr_functions - 1].nrParams - 1].name, yytext);
							      }; }
<innerFunctionParams>" "|\n|\t ;

<innerFunctionParamsDefaultValues>"," { // comes new parameter
										BEGIN(innerFunctionParams);
									    functions[nr_functions - 1].nrParams++;
									    functions[nr_functions - 1].params = (TParam*) realloc(functions[nr_functions - 1].params, functions[nr_functions - 1].nrParams * sizeof(TParam));
									    functions[nr_functions - 1].params[functions[nr_functions - 1].nrParams - 1].name = (char*) calloc(MAX_BUFF, sizeof(char));
									    functions[nr_functions - 1].params[functions[nr_functions - 1].nrParams - 1].hasDefaultValue = 0; }
<innerFunctionParamsDefaultValues>"):"[^\n]* { // all parameters have been read
											   BEGIN(innerFunctionLines);
											   printFunctionPart1(); }
<innerFunctionParamsDefaultValues>[^\n ] { // reading default value for current parameter
										   if (functions[nr_functions - 1].nrParams == 1)
										   {
										   		strcat(functions[nr_functions - 1].params->defaultValue, yytext);
										   }
										   else
										   {
										 		strcat(functions[nr_functions - 1].params[functions[nr_functions - 1].nrParams - 1].defaultValue, yytext);
										   }; }
<innerFunctionParamsDefaultValues>" "|\n ;

<innerFunctionLines>"# TODO:"|"# TODO"{index}":" { BEGIN(innerFunctionCommentSharpTODO);
												  	    functions[nr_functions - 1].nrTODOs++; }
<innerFunctionLines>"#" { BEGIN(innerFunctionCommentSharp); }
<innerFunctionLines>"''' TODO:"|"''' TODO"{index}":" { BEGIN(innerFunctionCommentQuoteTODO);
													 		functions[nr_functions - 1].nrTODOs++; }
<innerFunctionLines>"'''" { BEGIN(innerFunctionCommentQuote); }

<innerFunctionLines>\n { BEGIN(innerFunctionLinesBegin);
						 functions[nr_functions - 1].nrCodeLines++; nr_functions_aux = nr_functions; }
<innerFunctionLines>. ;

<innerFunctionLinesBegin>\t|"    " { // we have to read a number of tabs equal cu nr_functions - 1 to remain in function
									 if (nr_functions_aux > 1)
									 {
									 	nr_functions_aux--;
									 	BEGIN(innerFunctionLinesBegin);
									 }
									 else
									 {
										BEGIN(innerFunctionReturnLines);
									 }; }
<innerFunctionLinesBegin>. { // if there was not enough tabs to remain in function then it means we exit it
							 if (nr_functions == 2) // return in outer function
							 {
							 	BEGIN(mainFunctionReturnLines);
							 }
							 else
							 {
								BEGIN(innerFunctionReturnLines); // stay in an inner function
							 }
							 printFunctionPart2();
							 freeFunction();
							 functions[nr_functions - 2].nrCodeLines += functions[nr_functions - 1].nrCodeLines;
							 nr_functions--;
							 yyless(0); }
<innerFunctionLinesBegin>\n ;

<innerFunctionReturnLines>{whitespaces}"return " { BEGIN(innerFunctionLines);
									 			   functions[nr_functions - 1].nrReturns++; }
<innerFunctionReturnLines>{whitespaces}"return"\n { BEGIN(innerFunctionLinesBegin);
									  				functions[nr_functions - 1].nrCodeLines++;
									  				functions[nr_functions - 1].nrReturns++; }
<innerFunctionReturnLines>\n { BEGIN(innerFunctionLinesBegin); }
<innerFunctionReturnLines>"# TODO:"|"# TODO"{index}":" { BEGIN(innerFunctionCommentSharpTODO);
												  	    functions[nr_functions - 1].nrTODOs++; }
<innerFunctionReturnLines>"#" { BEGIN(innerFunctionCommentSharp); }
<innerFunctionReturnLines>"''' TODO:"|"''' TODO"{index}":" { BEGIN(innerFunctionCommentQuoteTODO);
													 		functions[nr_functions - 1].nrTODOs++; }
<innerFunctionReturnLines>"'''" { BEGIN(innerFunctionCommentQuote); }
<innerFunctionReturnLines>{whitespaces}"@accepts(" { // inner function's accepts decorator found
													 BEGIN(decoratorAcceptsInner);
													 // allocate space for inner function
								   				     nr_functions++;
												     functions = (TFunctionPy*) realloc(functions, nr_functions * sizeof(TFunctionPy));
												     functions[nr_functions - 1].nrParamsAccept = 0;
												     functions[nr_functions - 1].nrReturns = 0;
												     functions[nr_functions - 1].nrParams = 0;
												     functions[nr_functions - 1].isDecoratorReturn = 0;
												     alreadyAllocated = 1; }
<innerFunctionReturnLines>{whitespaces}"@returns(" { // inner function's returns decorator found
													 BEGIN(decoratorReturnsInner);
													 // allocate space for inner function if not already allocated
												     if (alreadyAllocated == 1)
												     {
												   		functions[nr_functions - 1].isDecoratorReturn = 1;
												     }
												     else
												     {
														nr_functions++;
														functions = (TFunctionPy*) realloc(functions, nr_functions * sizeof(TFunctionPy));
													    functions[nr_functions - 1].nrParamsAccept = -1;
													    functions[nr_functions - 1].nrReturns = 0;
													    functions[nr_functions - 1].nrParams = 0;
													    functions[nr_functions - 1].isDecoratorReturn = 1;
													    alreadyAllocated = 1;
													 }; }
<innerFunctionReturnLines>{whitespaces}"def" { // inner function found
											   BEGIN(innerFunction);
											   // allocate space for inner function if not already allocated
											   if (alreadyAllocated == 1)
										       {
										   			alreadyAllocated = 0;
										   	   }
										       else
										       {
													nr_functions++;
													functions = (TFunctionPy*) realloc(functions, nr_functions * sizeof(TFunctionPy));
													functions[nr_functions - 1].nrParamsAccept = -1;
													functions[nr_functions - 1].nrParams = 0;
													alreadyAllocated = 0;
										       };
										       functions[nr_functions - 1].size_of_name = 0;
										       functions[nr_functions - 1].name = (char*) calloc(MAX_BUFF, sizeof(char)); }
<innerFunctionReturnLines>. { BEGIN(innerFunctionLines);
							  // no return on this line so we analyze a normal line
							  yyless(0); }

<innerFunctionCommentSharpTODO>\n { BEGIN(innerFunctionLinesBegin); }
<innerFunctionCommentSharpTODO><<EOF>> { BEGIN(INITIAL); }
<innerFunctionCommentSharpTODO>. ;
<innerFunctionCommentSharp>. ;
<innerFunctionCommentSharp>\n { BEGIN(innerFunctionLinesBegin); }
<innerFunctionCommentSharp><<EOF>> { BEGIN(INITIAL); }
<innerFunctionCommentQuoteTODO>"'''"|"'''"{multipleSpaces}\n { BEGIN(innerFunctionLinesBegin); }
<innerFunctionCommentQuoteTODO><<EOF>> { BEGIN(INITIAL); }
<innerFunctionCommentQuoteTODO>.|\n ;
<innerFunctionCommentQuote>.|\n ;
<innerFunctionCommentQuote>"'''"|"'''"{multipleSpaces}\n { BEGIN(innerFunctionLinesBegin); }
<innerFunctionCommentQuote><<EOF>> { BEGIN(INITIAL); }
%%

int main()
{
	yylex();
	return 0;
}