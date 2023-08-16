%skeleton "lalr1.cc"
%require  "3.0.1"

%defines 
%define api.namespace {IPL}
%define api.parser.class {Parser}

%define parse.trace

%code requires{
   #include "ast.hh"
   #include "location.hh"
   #include "symbtab.hh"
   #include "type.hh"
   namespace IPL {
      class Scanner;
   }

  // # ifndef YY_NULLPTR
  // #  if defined __cplusplus && 201103L <= __cplusplus
  // #   define YY_NULLPTR nullptr
  // #  else
  // #   define YY_NULLPTR 0
  // #  endif
  // # endif

}

%printer { std::cerr << $$; } IDENTIFIER
%printer { std::cerr << $$; } INT_CONST
%printer { std::cerr << $$; } FLOAT_CONST
%printer { std::cerr << $$; } STRING_LITERAL
%printer { std::cerr << $$; } INT
%printer { std::cerr << $$; } FLOAT
%printer { std::cerr << $$; } VOID
%printer { std::cerr << $$; } IF
%printer { std::cerr << $$; } ELSE
%printer { std::cerr << $$; } WHILE
%printer { std::cerr << $$; } RETURN
%printer { std::cerr << $$; } FOR
%printer { std::cerr << $$; } STRUCT
%printer { std::cerr << $$; } EQ_OP
%printer { std::cerr << $$; } NE_OP
%printer { std::cerr << $$; } LE_OP
%printer { std::cerr << $$; } GE_OP
%printer { std::cerr << $$; } AND_OP
%printer { std::cerr << $$; } OR_OP
%printer { std::cerr << $$; } INC_OP
%printer { std::cerr << $$; } PRINTF
%printer { std::cerr << $$; } MAIN
%printer { std::cerr << $$; } PTR_OP
%printer { std::cerr << $$; } OTHER

%parse-param { Scanner  &scanner  }
%locations
%code{   

#include "scanner.hh"
#undef yylex
#define yylex IPL::Parser::scanner.yylex
#include <map>
#include <string>
#include <algorithm>

extern std::map<std::string, abstract_astnode*> ast;
extern SymbolTable gst;
extern std::map<std::string, SymbolTable> predefined;
extern std::map<string, ASM> asmb;
extern ASM format_asm;
std::string curr_fun="";
std::string curr_struct="";
SymbolTable *curr_symbtab=new SymbolTable();
int curr_offset=0;
}




%define api.value.type variant
%define parse.assert

%start program

%token '\n'
%token <std::string> IDENTIFIER
%token <std::string> INT_CONST
%token <std::string> FLOAT_CONST
%token <std::string> STRING_LITERAL
%token <std::string> INT
%token <std::string> FLOAT
%token <std::string> VOID
%token <std::string> IF
%token <std::string> FOR 
%token <std::string> WHILE 
%token <std::string> RETURN 
%token <std::string> ELSE 
%token <std::string> STRUCT
%token <std::string> EQ_OP 
%token <std::string> NE_OP 
%token <std::string> LE_OP 
%token <std::string> GE_OP 
%token <std::string> AND_OP 
%token <std::string> OR_OP 
%token <std::string> INC_OP 
%token <std::string> PTR_OP 
%token <std::string> OTHER
%token <std::string> MAIN
%token <std::string> PRINTF

%token '=' '-' '+' '*' '/' '&' '<' '>' '!' '[' ']' '{' '}' ';' ',' '(' ')' '.'

%nterm <abstract_astnode*> translation_unit ;
%nterm <abstract_astnode*> struct_specifier;
%nterm <abstract_astnode*> function_definition; 
%nterm <abstract_astnode*> main_definition; 
%nterm <abstract_astnode*> program; 

%nterm <type_specifier_class*> type_specifier;
%nterm <declarator_class*> declarator_arr ;
%nterm <declarator_class*> declarator ;
%nterm <declaration_class*> declaration; 
%nterm <declarator_list_class*> declarator_list;
%nterm <declaration_list_class*> declaration_list ;

%nterm <exp_astnode*> expression ;
%nterm <fun_declarator_class*> fun_declarator ;
%nterm <parameter_list_class*> parameter_list ;
%nterm <parameter_declaration_class*> parameter_declaration ;
%nterm <statement_astnode*> statement ;
%nterm <assignS_astnode*> assignment_statement ;

%nterm <abstract_astnode*> compound_statement;
%nterm <seq_astnode*> statement_list ;
%nterm <assignE_astnode*> assignment_expression
%nterm <exp_astnode*> logical_and_expression ;
%nterm <exp_astnode*> equality_expression ;
%nterm <exp_astnode*> relational_expression ;
%nterm <exp_astnode*> additive_expression ;
%nterm <exp_astnode*> multiplicative_expression ;
%nterm <exp_astnode*> unary_expression ;
%nterm <if_astnode*> selection_statement ;
%nterm <statement_astnode*> iteration_statement ;
%nterm <exp_astnode*> postfix_expression ;
%nterm <exp_astnode*> primary_expression ;
%nterm <op_unary_astnode*> unary_operator ;
/* ------------------------------------------------------------ */
%nterm <proccall_astnode*> procedure_call;
%nterm <proccall_astnode*> printf_call;
%nterm <vector<exp_astnode*>*> expression_list ;
%%

program:
         main_definition 
         {
            $$ = $1;
            ast[curr_fun]=$1;
         }
         | translation_unit main_definition
         {
            $$ = $2;
            ast[curr_fun]=$2;
         }

translation_unit:
         struct_specifier
         {
            $$ = $1;
         }
         | function_definition
         {
            $$ = $1;
            ast[curr_fun]=$1;
         }
         | translation_unit struct_specifier
         {
            $$ = $2;
         }
         | translation_unit function_definition
         {
            $$ = $2;
            ast[curr_fun]=$2;
         }
         ;

struct_specifier:
         STRUCT IDENTIFIER 
         {
            curr_struct="struct "+$2;
            if(gst.Entries.find(curr_struct)!=gst.Entries.end())
            {
               string err="\"struct "+$2+"\" has a previous definition";
               error(@$, err);
            }
         }
         '{' declaration_list '}' ';'
         {
            Entry *e=new Entry();
            e->name=curr_struct;
            e->varfun="struct";
            e->param_local="global";
            e->offset="\"-\"";
            e->type="-";
            e->size=0;
            SymbolTable *symbtab=curr_symbtab;
            for(auto it=symbtab->Entries.begin();it!=symbtab->Entries.end();it++)
            {
               e->size+=it->second.size;
            }
            for(auto it=symbtab->Entries.begin();it!=symbtab->Entries.end();it++)
            {
               it->second.offset=to_string(-(stoi(it->second.offset)+it->second.size));
            }
            gst.Entries[e->name]=*e;
            gst.Entries[e->name].symbtab=curr_symbtab;
            curr_symbtab=new SymbolTable();
            curr_offset=0;
         }
         ;

function_definition:
         type_specifier fun_declarator 
         {
            curr_symbtab=new SymbolTable();
            Entry *e=new Entry();
            curr_fun=$2->fun_name;
            e->name=curr_fun;
            e->varfun="fun";
            e->param_local="global";
            e->offset="0";
            e->type=$1->type;
            e->size=0;
            if(e->type.substr(0,6)=="struct")
            {
               if(gst.Entries.find(e->type)==gst.Entries.end())
               {
                  string err="\""+e->type+"\" not declared";
                  error(@$,err);
               }
            }
            if(gst.Entries.find($2->fun_name)!=gst.Entries.end())
            {
               string err="The function \""+$2->fun_name+"\" has a previous definition";
               error(@$, err);
            }
            gst.Entries[$2->fun_name]=*e;
            SymbolTable *symbtab=new SymbolTable();
            vector<string> param_list;
            curr_offset=12;
            for(int i=(int)($2->parameter_list->parameter_list.size())-1;i>=0;i--)
            {
               Entry *e=new Entry();
               e->name=$2->parameter_list->parameter_list[i]->declarator->identifier;
               e->varfun="var";
               e->param_local="param";
               string ptrs="";
               for(int k=0;k<$2->parameter_list->parameter_list[i]->declarator->pointer;k++)
                  ptrs+="*";
               e->type=$2->parameter_list->parameter_list[i]->type_specifier->type+ptrs+$2->parameter_list->parameter_list[i]->declarator->type;
             
               if($2->parameter_list->parameter_list[i]->type_specifier->type=="void" && ptrs=="")
               {
                  string err="Invalid use of type \"void\"";
                  error(@$, err);
               }
               if(ptrs!="")
               {
                  e->size=4;
                  e->size*=$2->parameter_list->parameter_list[i]->declarator->array_size;
               }
               else if(e->type.substr(0,6)=="struct")
               {
                  if(gst.Entries.find($2->parameter_list->parameter_list[i]->type_specifier->type)!=gst.Entries.end())
                  e->size=gst.Entries[$2->parameter_list->parameter_list[i]->type_specifier->type].size*$2->parameter_list->parameter_list[i]->declarator->array_size;
                  else
                  {
                     string err="\""+$2->parameter_list->parameter_list[i]->type_specifier->type+"\" is not defined";
                     error(@$, err);                     
                  }
               }
               else
               {
                  e->size=4*$2->parameter_list->parameter_list[i]->declarator->array_size;
               }
               e->offset=to_string(curr_offset);
               curr_offset+=e->size;
               symbtab->Entries[$2->parameter_list->parameter_list[i]->declarator->identifier]=*e;
               param_list.push_back(e->type);
            }
            std::reverse(param_list.begin(),param_list.end());
            gst.Entries[$2->fun_name].symbtab=symbtab;
            gst.Entries[$2->fun_name].param_list=param_list;
            curr_symbtab=symbtab;
            curr_offset=0;
         }
         compound_statement
         {               
            $$ = $4;
            curr_symbtab=new SymbolTable();
            curr_offset=0;
         }
         ;

main_definition:
         INT MAIN '(' ')'
         {
            curr_symbtab=new SymbolTable();
            Entry *e=new Entry();
            curr_fun="main";
            e->name=curr_fun;
            e->varfun="fun";
            e->param_local="global";
            e->offset="0";
            e->type="int";
            e->size=0;
            if(e->type.substr(0,6)=="struct")
            {
                  if(gst.Entries.find(e->type)==gst.Entries.end())
                  {
                     string err="\""+e->type+"\" not declared";
                     error(@$,err);
                  }
            }
            if(gst.Entries.find("main")!=gst.Entries.end())
            {
                  string err="The function \"main\" has a previous definition";
                  error(@$, err);
            }
            gst.Entries["main"]=*e;
            SymbolTable *symbtab=new SymbolTable();
            curr_offset=12;
            vector<string> param_list;
            gst.Entries["main"].symbtab=symbtab;
            gst.Entries["main"].param_list = param_list;
            curr_symbtab=symbtab;
            curr_offset=0;
         }
         compound_statement 
         {               
               $$ = $6;
               curr_symbtab=new SymbolTable();
               curr_offset=0;
         }
         ;

type_specifier:
         VOID
         {
            // nhi likhna hai
            $$=new type_specifier_class();
            $$->type="void";
         }
         | INT
         {
            $$=new type_specifier_class();
            $$->type="int";
         }
         | FLOAT
         {
            $$=new type_specifier_class();
            $$->type="float";
         }
         | STRUCT IDENTIFIER
         {
            $$=new type_specifier_class();
            $$->type="struct "+$2;
         }
         ;

fun_declarator:
         IDENTIFIER '(' parameter_list ')'
         {
            // nhi likhna hai
            $$=new fun_declarator_class();
            $$->fun_name=$1;
            $$->parameter_list=$3;

         }
         | IDENTIFIER '(' ')'
         {
            // nhi likhna hai
            $$=new fun_declarator_class();
            $$->fun_name=$1;
            $$->parameter_list=new parameter_list_class();
         }
         ;

parameter_list:
         parameter_declaration
         {
            // nhi likhna hai
            $$=new parameter_list_class();
            $$->parameter_list.push_back($1);            
         }
         | parameter_list ',' parameter_declaration
         {
            $$=$1;
            $$->parameter_list.push_back($3);
         }
         ;
parameter_declaration:
         type_specifier declarator
         {
            $$=new parameter_declaration_class();
            $$->type_specifier=$1;
            $$->declarator=$2;  
         }
         ;

declarator_arr:
         IDENTIFIER 
         {
            $$=new declarator_class();
            $$->identifier=$1;
            $$->pointer=0;
            $$->array_size=1;
            // nhi likhna hai
         }
         | declarator_arr '[' INT_CONST ']'
         {
            $$=$1;
            $$->array_size*=atoi($3.c_str());
            $$->type+="["+to_string(atoi($3.c_str()))+"]";
         }
         ;

declarator:
         declarator_arr
         {
            // nhi likhna hai
            $$=$1;
         }
         | '*' declarator
         {
            // nhi likhna hai
            $$=$2;
            $$->pointer++;
         }
         ;

declaration_list:
         declaration
         {
            if($1->type_specifier->type=="void" && $1->declarator_list->declarator_list[0]->pointer==0)
            {
               string err="Cannot declare variable of type \"void\"";
               error(@1,err);
            }
            $$=new declaration_list_class();
            $$->declaration_list.push_back($1);
            for(int i=0;i<(int)($1->declarator_list->declarator_list.size());i++)
            {
               int ptr=$1->declarator_list->declarator_list[i]->pointer;
               int sz=0;
               Entry *e=new Entry();
               e->name=$1->declarator_list->declarator_list[i]->identifier;
               e->varfun="var";
               e->param_local="local";
               string ptrs="";
               for(int k=0;k<ptr;k++)
                  ptrs+="*";
               e->type=$1->type_specifier->type+ptrs+$1->declarator_list->declarator_list[i]->type;
               if(ptrs!="")
               {
                  sz=4;
                  sz*=$1->declarator_list->declarator_list[i]->array_size;
               }
               else if(e->type.substr(0,6)=="struct")
               {
                  if(gst.Entries.find($1->type_specifier->type)!=gst.Entries.end())
                      {   
                        sz=gst.Entries[$1->type_specifier->type].size*$1->declarator_list->declarator_list[i]->array_size;
                      }
                  else
                     {
                        string err="\""+$1->type_specifier->type+"\" is not defined";
                        error(@1,err);
                     }
               }
               else
               {
                  sz=4*$1->declarator_list->declarator_list[i]->array_size;
               }
               e->size=sz;
               curr_offset-=e->size;
               e->offset=to_string(curr_offset);
               if(curr_symbtab->Entries.find(e->name)==curr_symbtab->Entries.end())
                  curr_symbtab->Entries[e->name]=*e;
               else
               {
                  string err="\""+e->name+"\" has a previous declaration"; 
                  error(@1,err);
               }
            }
         }
         | declaration_list declaration
         {
             if($2->type_specifier->type=="void" && $2->declarator_list->declarator_list[0]->pointer==0)
            {
               string err="Cannot declare variable of type \"void\"";
               error(@2,err);
            }
            $$=$1;
            $$->declaration_list.push_back($2);
            for(int i=0;i<(int)($2->declarator_list->declarator_list.size());i++)
            {
               int ptr=$2->declarator_list->declarator_list[i]->pointer;
               int sz=0;
               Entry *e=new Entry();
               e->name=$2->declarator_list->declarator_list[i]->identifier;
               e->varfun="var";
               e->param_local="local";
               string ptrs="";
               for(int k=0;k<ptr;k++)
                  ptrs+="*";
               e->type=$2->type_specifier->type+ptrs+$2->declarator_list->declarator_list[i]->type;
               if(ptrs!="")
               {
                  sz=4;
                  sz*=$2->declarator_list->declarator_list[i]->array_size;
               }
               else  if(e->type.substr(0,6)=="struct")
               {
                  if(gst.Entries.find($2->type_specifier->type)!=gst.Entries.end())
                     {
                        sz=gst.Entries[$2->type_specifier->type].size*$2->declarator_list->declarator_list[i]->array_size;
                     }
                  else
                  {
                     string err="\""+$2->type_specifier->type+"\" is not defined";
                     error(@2,err);
                  }
               } 
               else
               {
                  sz=4*$2->declarator_list->declarator_list[i]->array_size;
               }
               e->size=sz;
               curr_offset-=e->size;
               e->offset=to_string(curr_offset);
               if(curr_symbtab->Entries.find(e->name)==curr_symbtab->Entries.end())
                  curr_symbtab->Entries[e->name]=*e;
               else
               {
                  string err="\""+e->name+"\" has a previous declaration"; 
                  error(@2,err);
               }
            }
         }
         ;

declaration:
      type_specifier declarator_list ';'
      {
         // nhi likhna hai
         $$=new declaration_class();
         $$->type_specifier=$1;
         $$->declarator_list=$2;
      }
      ;

declarator_list:
      declarator
      {
         // nhi likhna hai
         $$=new declarator_list_class();
         $$->declarator_list.push_back($1);
      }
      | declarator_list ',' declarator
      {
         $$=$1;
         $$->declarator_list.push_back($3);
      }
      ;

compound_statement:
         '{' '}'
         {
            // nhi likhna hai
            $$=new seq_astnode();
            gst.Entries[curr_fun].symbtab=curr_symbtab;
         }
         | '{' statement_list '}'
         {
            $$=$2;
            gst.Entries[curr_fun].symbtab=curr_symbtab;
         }
         | '{' declaration_list '}'
         {
            $$=new seq_astnode();
            gst.Entries[curr_fun].symbtab=curr_symbtab;
         }
         | '{' declaration_list statement_list '}'
         {
            $$=$3;
            gst.Entries[curr_fun].symbtab=curr_symbtab;
         }
         ;

statement_list:
         statement
         {
            // nhi likhna hai
            $$=new seq_astnode();
            $$->seq.push_back($1);
         }
         | statement_list statement
         {
            $$=$1;
            $$->seq.push_back($2);
         }
         ;

statement:
         ';'
         {
            $$=new empty_astnode();
         }
         | '{' statement_list '}'
         {
            $$=$2;
         }
         | selection_statement
         {
           $$=$1;
         }
         | iteration_statement
         {
            $$=$1;
         }
         | assignment_statement
         {
            $$=$1;
         }
         | procedure_call
         {
            $$=$1;
         }
         | printf_call
         {
            $$=$1;
         }
         | RETURN expression ';'
         {
            // kaafi likhna hai
            pair<string,pair<int,vector<int>>> p=get_type(gst.Entries[curr_fun].type);
            if(p.first=="void")
            {  
               string err="Incompatible type \"";
               err+=print_type($2->type,$2->deref,$2->array,$2->adr);
               err+="\" returned, expected \"";
               err+=print_type(p.first,p.second.first,p.second.second,0);
               err+="\"";
               error(@$,err);
            }
            else if(p.first=="int")
            {
               if(($2->type!="int" && $2->type!="float" )|| $2->deref!=0 || $2->array.size()!=0 || $2->adr!=0)
               {
                  string err="Incompatible type \"";
                  err+=print_type($2->type,$2->deref,$2->array,$2->adr);
                  err+="\" returned, expected \"";
                  err+=print_type(p.first,p.second.first,p.second.second,0);
                  err+="\"";
                  error(@$,err);
               }
               else
               {
                  if($2->type=="float")
                  {
                     $2=new op_unary_astnode("TO_INT",$2);
                  }
               }
            }
            else if(p.first=="float")
            {
               if(($2->type!="int" && $2->type!="float" )|| $2->deref!=0 || $2->array.size()!=0 || $2->adr!=0)
               {
                  string err="Incompatible type \"";
                  err+=print_type($2->type,$2->deref,$2->array,$2->adr);
                  err+="\" returned, expected \"";
                  err+=print_type(p.first,p.second.first,p.second.second,0);
                  err+="\"";
                  error(@$,err);
               }
               else
               {
                  if($2->type=="int")
                  {
                     $2=new op_unary_astnode("TO_FLOAT",$2);
                  }
               }
            }
            else if(p.first.substr(0,6)=="struct")
            {
               if($2->type!=p.first || $2->deref!=0 || $2->array.size()!=0 || $2->adr!=0)
               {
                  string err="Incompatible type \"";
                  err+=print_type($2->type,$2->deref,$2->array,$2->adr);
                  err+="\" returned, expected \"";
                  err+=print_type(p.first,p.second.first,p.second.second,0);
                  err+="\"";
                  error(@$,err);
               }
            }
            else
            {
               string err="Incompatible type \"";
               err+=print_type($2->type,$2->deref,$2->array,$2->adr);
               err+="\" returned, expected \"";
               err+=print_type(p.first,p.second.first,p.second.second,0);
               err+="\"";
               error(@$,err);
            }
            $$=new return_astnode($2);                      
         }
         ;

assignment_expression:
         unary_expression '=' expression
         {  
            if($3->type=="void" && $3->array.size()+$3->adr+$3->deref==0)
            {
               string err = "Incompatible assignment when assigning to type \"";
               err += print_type($1->type, $1->deref, $1->array, $1->adr);
               err += "\" from type \"";
               err += print_type($3->type, $3->deref, $3->array, $3->adr);
               err += "\"";
               error(@$, err);
            }
            if ($1->type=="string" || $3->type=="string")
            {
               string err = "Incompatible assignment when assigning to type \"";
               err += print_type($1->type, $1->deref, $1->array, $1->adr);
               err += "\" from type \"";
               err += print_type($3->type, $3->deref, $3->array, $3->adr);
               err += "\"";
               error(@$, err);
            }
            if(!($1->lvalue))
            {
               string err="Left operand of assignment should have an lvalue";
               error(@$,err);
            }
            else if($1->array.size())
            {
               string err="array assignment not allowed";
               error(@$,err);
            }
            else if($1->deref+$1->adr+$1->array.size()==0 && $3->deref+$3->adr+$3->array.size()==0)
               {
               if($1->type.substr(0,6)=="struct" || $3->type.substr(0,6)=="struct")
               {
                  if($1->type!=$3->type){
               string err = "Incompatible assignment when assigning to type \"";
               err += print_type($1->type, $1->deref, $1->array, $1->adr);
               err += "\" from type \"";
               err += print_type($3->type, $3->deref, $3->array, $3->adr);
               err += "\"";
               error(@$, err);}
               }
               else
                  if($1->type=="int" && $3->type=="float")
                  {
                     $3=new op_unary_astnode("TO_INT",$3);
                  }
                  else if($1->type=="float" && $3->type=="int")
                  {
                     $3=new op_unary_astnode("TO_FLOAT",$3);
                  }
               }
            else if($1->deref+$1->adr && $3->is_const && !$3->const_val)
            {

            } 
            else if($1->type=="void")
            {
               if($3->type=="void" && $3->deref+$3->adr+$3->array.size()==1)
               {

               }
               else
               {
                  string err="Incompatible assignment when assigning to type \"";
                  err+=print_type($1->type,$1->deref,$1->array,$1->adr);
                  err+="\" from type \"";
                if($1->deref+$1->adr==1)
                  {
                     if($3->deref+$3->adr+$3->array.size()!=0)
                     {

                     }
                     else
                     {  
                        err+=print_type($3->type,$3->deref,$3->array,$3->adr);
                        err+="\"";
                        error(@$,err);
                     }
                  }
                  else
                  {
                     if($3->type!="void") 
                     {
                        err+=print_type($3->type,$3->deref,$3->array,$3->adr);
                        err+="\"";
                        error(@$,err);
                     }
                     string type3;
                     if($3->adr==0)
                     {
                        vector<int> v=$3->array;
                        if(v.size())
                        {
                           v.erase(v.begin());
                           if(v.size())
                              type3=print_type($3->type, $3->deref, v, $3->adr+1);
                           else
                              type3=print_type($3->type, $3->deref+1, v, $3->adr);
                        }
                        else
                        {
                           type3=print_type($3->type, $3->deref, v, $3->adr);
                        }
                     }
                     else
                     {
                        type3=print_type($3->type, $3->deref, $3->array, $3->adr);
                     }
                     if(print_type($1->type,$1->deref,$1->array,$1->adr)!=type3)
                     {
                        err+=type3+"\"";
                        error(@$,err);
                     }
                  }
               }
            }
            else if($3->type=="void" && $1->deref+$1->adr)
            {
               if($3->adr+$3->deref+$3->array.size()==1)
               {

               }
               else 
               {
                  string err="Incompatible assignment when assigning to type \"";
                  err+=print_type($1->type,$1->deref,$1->array,$1->adr);
                  err+="\" from type \"";
                  err+=print_type($3->type,$3->deref,$3->array,$3->adr);
                  err+="\"";
                  error(@$,err);
               }
            }
            else if($1->adr+$1->deref)
            {
               string t1,t2;  
               t1=print_type($1->type, $1->deref, $1->array, $1->adr);
               if($3->adr==0)
               {
                  vector<int> v=$3->array;
                  if(v.size())
                  {
                     v.erase(v.begin());
                     if(v.size())
                        t2=print_type($3->type, $3->deref, v, $3->adr+1);
                     else
                        t2=print_type($3->type, $3->deref+1, v, $3->adr);
                  }
                  else
                  {
                     t2=print_type($3->type, $3->deref, v, $3->adr);
                  }
                  // cout<<"here "<<t1<<" "<<t2<<endl;
               }
               else
               {
                     if($3->array.size())
                        t2=print_type($3->type, $3->deref, $3->array, $3->adr);
                     else
                        t2=print_type($3->type, $3->deref+1, $3->array, $3->adr-1);
               }
               if(t1!=t2)
               {
                  string err="Incompatible assignment when assigning to type \"";
                  err += t1;
                  err += "\" from type \"";
                  err += t2;
                  err += "\"";  
                  error(@$, err);
               }
            }
            else 
            {
               string err="Incompatible assignment when assigning to type \"";
               err+=print_type($1->type,$1->deref,$1->array,$1->adr);
               err+="\" from type \"";
               err+=print_type($3->type,$3->deref,$3->array,$3->adr);
               err+="\"";
               error(@$,err);
            }
            $$=new assignE_astnode($1,$3);
         }
         ;

assignment_statement:
         assignment_expression ';'
         {
            // nhi likhna hai
            $$=new assignS_astnode($1->left,$1->right);
         }
         ;

procedure_call:
         IDENTIFIER '(' ')' ';'
         {
            if(predefined.find($1)==predefined.end())
            {
               Entry *st=gst.search($1);
               if(st==NULL)
               {
                  string err="Function \""+$1+"\" is not declared";
                  error(@$,err);
               }
               if(st->varfun!="fun")
               {
                  string err="Object \""+$1+"\" is not a function";
                  error(@$,err);
               }
               vector<string> param_list=st->param_list;
               if(param_list.size()!=0)
               {
                  string err="Function \""+$1+"\" called with too few arguments";
                  error(@$,err);
               }
            }
            exp_astnode *a=new identifier_astnode($1);
            $$=new proccall_astnode({a});
            $$->label_r = 0;
            $$->label_l = 1;
            if(predefined.find($1)!=predefined.end())
            {
               if($1=="mod")
                  $$->type="int";
               else
                  $$->type="void";
            }
            else
            {
               $$->type=gst.search($1)->type;
            }
            $$->lvalue=false;
         }
         | IDENTIFIER '(' expression_list ')' ';'
         {
            // likhna hai
            if(predefined.find($1)==predefined.end())
            {
               Entry *st=gst.search($1);
               if(st==NULL)
               {
                  string err="Function \""+$1+"\" is not declared";
                  error(@$,err);
               }
               if(st->varfun!="fun")
               {
                  string err="Object \""+$1+"\" is not a function";
                  error(@$,err);
               }
               vector<string> param_list=st->param_list;
               if(param_list.size()>$3->size())
               {
                  string err="Function \""+$1+"\" called with too few arguments";
                  error(@$,err);
               }
               if(param_list.size()<$3->size())
               {
                  string err="Function \""+$1+"\" called with too many arguments";
                  error(@$,err);
               }
               for(int i=0;i<(int)($3->size());i++)
               {
                  if(param_list[i]=="int" || param_list[i]=="float")
                  {
                      if(($3->at(i)->type!="float" && $3->at(i)->type!="int")|| $3->at(i)->array.size() || $3->at(i)->deref || $3->at(i)->adr)
                        {
                           pair<string,pair<int,vector<int>>> p_type=get_type(param_list[i]);
                           string t1=print_type(p_type.first,p_type.second.first,p_type.second.second,0);
                           string t2=print_type($3->at(i)->type,$3->at(i)->deref,$3->at(i)->array,$3->at(i)->adr);
                        
                           string err="Expected \""+t1+"\" but argument is of type \""+t2+"\"";
                           error(@3,err);
                        }
                     if(param_list[i]=="int" && $3->at(i)->type=="float")
                     {
                        $3->at(i)=new op_unary_astnode("TO_INT",$3->at(i));
                     }
                     if(param_list[i]=="float" && $3->at(i)->type=="int")
                     {
                        $3->at(i)=new op_unary_astnode("TO_FLOAT",$3->at(i));
                     }
                  }
                  else if(param_list[i]==print_type($3->at(i)->type,$3->at(i)->deref,$3->at(i)->array,$3->at(i)->adr))
                  {
                     continue;
                  }
                  else
                  {           
                     pair<string,pair<int,vector<int>>> p_type=get_type(param_list[i]);
                   if(p_type.second.first+p_type.second.second.size() && $3->at(i)->is_const && !$3->at(i)->const_val)
                     {
                        continue;
                     } 
                     if(p_type.first=="void")
                     {
                        if($3->at(i)->type=="void" && $3->at(i)->deref+$3->at(i)->adr+$3->at(i)->array.size()==1)
                        {
                           continue;
                        }
                        else
                        {
                           string err="Expected \"";
                           err+=print_type(p_type.first,p_type.second.first,p_type.second.second,0);
                           err+="\" but argument is of type \"";
                           if(p_type.second.first+p_type.second.second.size()==1)
                           {
                              if($3->at(i)->deref+$3->at(i)->adr+$3->at(i)->array.size()!=0)
                              {
                                 continue;
                              }
                              else
                              {  
                                 err+=print_type($3->at(i)->type,$3->at(i)->deref,$3->at(i)->array,$3->at(i)->adr);
                                 err+="\"";
                                 error(@$,err);
                              }
                           }
                           else
                           {
                              if($3->at(i)->type!="void") 
                              {
                                 err+=print_type($3->at(i)->type,$3->at(i)->deref,$3->at(i)->array,$3->at(i)->adr);
                                 err+="\"";
                                 error(@$,err);
                              }
                              string type3;
                              if($3->at(i)->adr==0)
                              {
                                 vector<int> v=$3->at(i)->array;
                                 if(v.size())
                                 {
                                    v.erase(v.begin());
                                    if(v.size())
                                       type3=print_type($3->at(i)->type, $3->at(i)->deref, v, $3->at(i)->adr+1);
                                    else
                                       type3=print_type($3->at(i)->type, $3->at(i)->deref+1, v, $3->at(i)->adr);
                                 }
                                 else
                                 {
                                    type3=print_type($3->at(i)->type, $3->at(i)->deref, v, $3->at(i)->adr);
                                 }
                              }
                              else
                              {
                                 type3=print_type($3->at(i)->type, $3->at(i)->deref, $3->at(i)->array, $3->at(i)->adr);
                              }
                              if(print_type(p_type.first,p_type.second.first,p_type.second.second,0)!=type3)
                              {
                                 err+=type3+"\"";
                                 error(@$,err);
                              }
                           }
                        }
                     }
                     else if($3->at(i)->type=="void" && p_type.second.first+p_type.second.second.size())
                     {
                        if($3->at(i)->deref+$3->at(i)->adr+$3->at(i)->array.size()==1)
                        {
                           continue;
                        }
                        else
                        {
                           string err="Expected \"";
                           err+=print_type(p_type.first,p_type.second.first,p_type.second.second,0);
                           err+="\" but argument is of type \"";
                           err+=print_type($3->at(i)->type,$3->at(i)->deref,$3->at(i)->array,$3->at(i)->adr);
                           err+="\"";
                           error(@$,err);
                        }
                     }
                     else 
                     {
                        string t1,t2;     
                        vector<int> v=p_type.second.second;
                        if(v.size())
                        {
                           v.erase(v.begin());
                           if(v.size())
                              t1=print_type(p_type.first, p_type.second.first, v,1);
                           else
                              t1=print_type(p_type.first, p_type.second.first+1, v,0);
                        }
                        else
                        {
                           t1=print_type(p_type.first, p_type.second.first, v, 0);
                        }
                        
                        if($3->at(i)->adr==0)
                        {
                           vector<int> v=$3->at(i)->array;
                           if(v.size())
                           {
                              v.erase(v.begin());
                              if(v.size())
                                 t2=print_type($3->at(i)->type, $3->at(i)->deref, v, $3->at(i)->adr+1);
                              else
                                 t2=print_type($3->at(i)->type, $3->at(i)->deref+1, v, $3->at(i)->adr);
                           }
                           else
                           {
                              t2=print_type($3->at(i)->type, $3->at(i)->deref, v, $3->at(i)->adr);
                           }
                        }
                        else
                        {
                           if($3->at(i)->array.size())
                              t2=print_type($3->at(i)->type, $3->at(i)->deref, $3->at(i)->array, $3->at(i)->adr);
                           else
                              t2=print_type($3->at(i)->type, $3->at(i)->deref+1, $3->at(i)->array, $3->at(i)->adr-1);
                        }
                        if(t1!=t2)
                        {
                           string err="Expected \""+t1+"\" but argument is of type \""+t2+"\"";
                           error(@3,err);
                        }
                     }
                  }
               }
            }
            exp_astnode *a=new identifier_astnode($1);
            $3->insert($3->begin(),a);
            $$=new proccall_astnode(*$3);
            $$->label_r = 0;
            $$->label_l = 1;
            if(predefined.find($1)!=predefined.end())
            {
               if($1=="mod")
                  $$->type="int";
               else
                  $$->type="void";
            }
            else
            {
               $$->type=gst.search($1)->type;
            }
            $$->lvalue=false;
            
         }
         ;

printf_call:
   PRINTF '(' STRING_LITERAL ')' ';'
   {
      exp_astnode *a=new identifier_astnode($1);
      string lbl = get_flabel();
      exp_astnode *arg = new stringconst_astnode(lbl);
      arg->is_strconst = true;
      arg->strconst = lbl;

      vector<string> fstr = format_string($3, lbl);
      format_asm.ins.insert(format_asm.ins.end(), fstr.begin(), fstr.end());
      
      $$=new proccall_astnode({a, arg});
      if(predefined.find($1)!=predefined.end())
      {
         if($1=="mod")
            $$->type="int";
         else
            $$->type="void";
      }
      else
      {
         $$->type=gst.search($1)->type;
      }
      $$->lvalue=false;
      
   }
   | PRINTF '(' STRING_LITERAL ',' expression_list ')' ';'
   {
      exp_astnode *a=new identifier_astnode($1);

      string lbl = get_flabel();
      exp_astnode *arg = new stringconst_astnode(lbl);
      arg->is_strconst = true;
      arg->strconst = lbl;

      vector<string> fstr = format_string($3, lbl);
      format_asm.ins.insert(format_asm.ins.end(), fstr.begin(), fstr.end());

      $5->insert($5->begin(),arg);
      $5->insert($5->begin(),a);
      $$=new proccall_astnode(*$5);
      if(predefined.find($1)!=predefined.end())
      {
         if($1=="mod")
            $$->type="int";
         else
            $$->type="void";
      }
      else
      {
         $$->type=gst.search($1)->type;
      }
      $$->lvalue=false;
   }



expression:
         logical_and_expression
         {
            $$=$1;
            $$->label_l = $1->label_l;
            $$->label_r = $1->label_r;
         }
         | expression OR_OP logical_and_expression
         {
            // likhna hai
            if ($1->type=="string" || $3->type=="string")
            {
               string err = "Invalid operand types for binary || , \"";
               err += print_type($1->type, $1->deref, $1->array, $1->adr);
               err += "\" and \"";
               err += print_type($3->type, $3->deref, $3->array, $3->adr);
               err += "\"";
               error(@$, err);
            }
            if($1->adr+$1->deref+$1->array.size() || $3->adr+$3->deref+$3->array.size())
            {
               if($1->adr+$1->deref+$1->array.size()==0 && $1->type!="int" && $1->type!="float")
               {
                  string err="Invalid operands to binary operator \"||\"";
                  error(@$,err);
               }
               if($3->adr+$3->deref+$3->array.size()==0 && $3->type!="int" && $3->type!="float")
               {
                  string err="Invalid operands to binary operator \"||\"";
                  error(@$,err);
               }
            }
            else
            {
               if($1->type!="int" && $1->type!="float")
               {
                  string err="Invalid operands to binary operator \"||\"";
                  error(@$,err);
               }
               if($3->type!="int" && $3->type!="float")
               {
                  string err="Invalid operands to binary operator \"||\"";
                  error(@$,err);
               }
            }
            if($1->is_calculatable || $3->is_calculatable)
            {
               $$->is_calculatable=true;
               $$->int_val=$1->int_val || $3->int_val;
            }
            $$=new op_binary_astnode("OR_OP",$1,$3);
            $$->type="int";
            $$->lvalue=false;
            $$->is_const=$1->is_const && $3->is_const;
            ($1->label_l == $3->label_r) ? ($$->label_l = $1->label_l+1) 
                                          : ($$->label_l = max($1->label_l, $3->label_r));
            $$->label_r = $$->label_l;
            $1->label_r = $1->label_l; $3->label_l = $1->label_r;
            if($$->is_const)
            {
               $$->const_val=$1->const_val || $3->const_val;
            }
         }
         ;

logical_and_expression:
         equality_expression
         {
            $$=$1;
            $$->label_r = $1->label_r;
            $$->label_l = $1->label_l;
         }
         | logical_and_expression AND_OP equality_expression
         {
              if ($1->type=="string" || $3->type=="string")
            {
               string err = "Invalid operand types for binary && , \"";
               err += print_type($1->type, $1->deref, $1->array, $1->adr);
               err += "\" and \"";
               err += print_type($3->type, $3->deref, $3->array, $3->adr);
               err += "\"";
               error(@$, err);
            }
            if($1->adr+$1->deref+$1->array.size() || $3->adr+$3->deref+$3->array.size())
            {
               if($1->adr+$1->deref+$1->array.size()==0 && $1->type!="int" && $1->type!="float")
               {
                  string err="Invalid operands to binary operator \"&&\"";
                  error(@$,err);
               }
               if($3->adr+$3->deref+$3->array.size()==0 && $3->type!="int" && $3->type!="float")
               {
                  string err="Invalid operands to binary operator \"&&\"";
                  error(@$,err);
               }
            }
            else
            {
               if($1->type!="int" && $1->type!="float")
               {
                  string err="Invalid operands to binary operator \"&&\"";
                  error(@$,err);
               }
               if($3->type!="int" && $3->type!="float")
               {
                  string err="Invalid operands to binary operator \"&&\"";
                  error(@$,err);
               }
            }
            if($1->is_calculatable || $3->is_calculatable)
            {
               $$->is_calculatable=true;
               $$->int_val=$1->int_val && $3->int_val;
            }
            $$=new op_binary_astnode("AND_OP",$1,$3);
            $$->type="int";
            $$->lvalue=false;
            $$->is_const=$1->is_const && $3->is_const;
            ($1->label_l == $3->label_r) ? ($$->label_l = $1->label_l+1) 
                                          : ($$->label_l = max($1->label_l, $3->label_r));
            $$->label_r = $$->label_l;
            $1->label_r = $1->label_l; $3->label_l = $1->label_r;
            if($$->is_const)
            {
               $$->const_val=$1->const_val && $3->const_val;
            }
         }
         ;

equality_expression:
         relational_expression
         {
            $$=$1;
            $$->label_l = $1->label_l;
            $$->label_r = $1->label_r;
         }
         | equality_expression EQ_OP relational_expression
         {
              if ($1->type=="string" || $3->type=="string")
            {
               string err = "Invalid operand types for binary == , \"";
               err += print_type($1->type, $1->deref, $1->array, $1->adr);
               err += "\" and \"";
               err += print_type($3->type, $3->deref, $3->array, $3->adr);
               err += "\"";
               if ($1->type=="string" && $3->type=="string")
            {
            }
            else
               error(@$, err);
            }
             if(($1->deref+$1->adr+$1->array.size() != $3->deref+$3->adr+$3->array.size()))
            {
               
               string err="Invalid operand types for binary == , \"";
               err+=print_type($1->type,$1->deref,$1->array,$1->adr);
               err+="\" and \"";
               err+=print_type($3->type,$3->deref,$3->array,$3->adr);
               err+="\"";         
                  if(($1->is_const && $1->const_val==0) ||($3->is_const && $3->const_val==0))
                  { 
                     $$=new op_binary_astnode("EQ_OP_INT",$1,$3);
                     $$->type="int";
                  }
                  else if($1->type=="void" && $1->adr+$1->array.size()+$1->deref==1 && $3->adr+$3->array.size()+$3->deref)
                  {
                      $$=new op_binary_astnode("EQ_OP_INT",$1,$3);
                     $$->type="int";                    
                  }
                  else if($3->type=="void" && $3->adr+$3->array.size()+$3->deref==1 && $1->adr+$1->array.size()+$1->deref)
                  {
                      $$=new op_binary_astnode("EQ_OP_INT",$1,$3);
                     $$->type="int";                    
                  }
                  else
                     error(@$,err);
            }
            if($1->deref+$1->adr+$1->array.size()==0 && $3->deref+$3->adr+$3->array.size()==0)
             { 
               if($1->type.substr(0,6)=="struct" || $3->type.substr(0,6)=="struct")
               {
                  string err = "Invalid operand types for binary == , \"";
                  err += print_type($1->type, $1->deref, $1->array, $1->adr);
                  err += "\" and \"";
                  err += print_type($3->type, $3->deref, $3->array, $3->adr);
                  err += "\"";
                  error(@$, err);
               }
               if(($1->type=="float" || $3->type=="float"))
                  {
                  if($1->type=="int")
                     {$1=new op_unary_astnode("TO_FLOAT",$1);}
                  if($3->type=="int")
                     {$3=new op_unary_astnode("TO_FLOAT",$3);}
                  $$=new op_binary_astnode("EQ_OP_FLOAT",$1,$3);
                  $$->type="float";
               }
               else
               {
                  $$=new op_binary_astnode("EQ_OP_INT",$1,$3);
                  $$->type="int";
               }
             }
            if($1->deref+$1->adr+$1->array.size() && $3->deref+$3->adr+$3->array.size())
               {
                  string t1,t2;             
                  if($1->adr==0)
                  {
                     vector<int> v=$1->array;
                     if(v.size())
                     {
                        v.erase(v.begin());
                        if(v.size())
                           t1=print_type($1->type, $1->deref, v, $1->adr+1);
                        else
                           t1=print_type($1->type, $1->deref+1, v, $1->adr);
                     }
                     else
                     {
                        t1=print_type($1->type, $1->deref, v, $1->adr);
                     }
                  }
                  else
                  {
                     if($1->array.size())
                        t1=print_type($1->type, $1->deref, $1->array, $1->adr);
                     else
                        t1=print_type($1->type, $1->deref+1, $1->array, $1->adr-1);
                  }
                  if($3->adr==0)
                  {
                     vector<int> v=$3->array;
                     if(v.size())
                     {
                        v.erase(v.begin());
                        if(v.size())
                           t2=print_type($3->type, $3->deref, v, $3->adr+1);
                        else
                           t2=print_type($3->type, $3->deref+1, v, $3->adr);
                     }
                     else
                     {
                        t2=print_type($3->type, $3->deref, v, $3->adr);
                     }
                  }
                  else
                  {
                     if($3->array.size())
                        t2=print_type($3->type, $3->deref, $3->array, $3->adr);
                     else
                        t2=print_type($3->type, $3->deref+1, $3->array, $3->adr-1);
                  }
                if(t1=="void*" || t2=="void*")
                  {
                  }
                  else
                  if(t1!=t2)
                  {
                     string err = "Invalid operand types for binary == , \"";
                     err += t1;
                     err += "\" and \"";
                     err += t2;
                     err += "\"";  
                     error(@$, err);
                  }
                  $$=new op_binary_astnode("EQ_OP_INT",$1,$3);
                  $$->type="int";
               }
            if($1->is_calculatable || $3->is_calculatable)
            {
               $$->is_calculatable=true;
               $$->int_val=$1->int_val == $3->int_val;
            }
            $$->lvalue=false;
            $$->is_const=$1->is_const && $3->is_const;
            ($1->label_l == $3->label_r) ? ($$->label_l = $1->label_l+1) 
                                          : ($$->label_l = max($1->label_l, $3->label_r));
            $$->label_r = $$->label_l;
            $1->label_r = $1->label_l; $3->label_l = $1->label_r;
            if($$->is_const)
            {
               $$->const_val=$1->const_val == $3->const_val;
            }
         }
         | equality_expression NE_OP relational_expression
         {
             if ($1->type=="string" || $3->type=="string")
            {
               string err = "Invalid operand types for binary != , \"";
               err += print_type($1->type, $1->deref, $1->array, $1->adr);
               err += "\" and \"";
               err += print_type($3->type, $3->deref, $3->array, $3->adr);
               err += "\"";         
                     if ($1->type=="string" && $3->type=="string")
            {
            }
            else
               error(@$, err);
            }
            if(($1->deref+$1->adr+$1->array.size() != $3->deref+$3->adr+$3->array.size()))
            {
               string err="Invalid operand types for binary != , \"";
               err+=print_type($1->type,$1->deref,$1->array,$1->adr);
               err+="\" and \"";
               err+=print_type($3->type,$3->deref,$3->array,$3->adr);
               err+="\"";         
                  if(($1->is_const && $1->const_val==0) ||($3->is_const && $3->const_val==0))
                  { 
                     $$=new op_binary_astnode("NE_OP_INT",$1,$3);
                     $$->type="int";
                  }                 
                   else if($1->type=="void" && $1->adr+$1->array.size()+$1->deref==1 && $3->adr+$3->array.size()+$3->deref)
                  {
                      $$=new op_binary_astnode("NE_OP_INT",$1,$3);
                     $$->type="int";                    
                  }
                  else if($3->type=="void" && $3->adr+$3->array.size()+$3->deref==1 && $1->adr+$1->array.size()+$1->deref)
                  {
                      $$=new op_binary_astnode("NE_OP_INT",$1,$3);
                     $$->type="int";                    
                  }
            }
            if($1->deref+$1->adr+$1->array.size()==0 && $3->deref+$3->adr+$3->array.size()==0)
             { 
                  if($1->type.substr(0,6)=="struct" || $3->type.substr(0,6)=="struct")
                  {
                     string err = "Invalid operand types for binary != , \"";
                     err += print_type($1->type, $1->deref, $1->array, $1->adr);
                     err += "\" and \"";
                     err += print_type($3->type, $3->deref, $3->array, $3->adr);
                     err += "\"";
                     error(@$, err);
                  }
                  if(($1->type=="float" || $3->type=="float"))
                  {
                  if($1->type=="int")
                     {$1=new op_unary_astnode("TO_FLOAT",$1);}
                  if($3->type=="int")
                     {$3=new op_unary_astnode("TO_FLOAT",$3);}
                  $$=new op_binary_astnode("NE_OP_FLOAT",$1,$3);
                  $$->type="float";
                  }
                  else
                  {
                     $$=new op_binary_astnode("NE_OP_INT",$1,$3);
                     $$->type="int";
                  }
            }
            if($1->deref+$1->adr+$1->array.size() && $3->deref+$3->adr+$3->array.size())
               {
                  string t1,t2;             
                  if($1->adr==0)
                  {
                     vector<int> v=$1->array;
                     if(v.size())
                     {
                        v.erase(v.begin());
                        if(v.size())
                           t1=print_type($1->type, $1->deref, v, $1->adr+1);
                        else
                           t1=print_type($1->type, $1->deref+1, v, $1->adr);
                     }
                     else
                     {
                        t1=print_type($1->type, $1->deref, v, $1->adr);
                     }
                  }
                  else
                  {
                     if($1->array.size())
                        t1=print_type($1->type, $1->deref, $1->array, $1->adr);
                     else
                        t1=print_type($1->type, $1->deref+1, $1->array, $1->adr-1);
                  }
                  if($3->adr==0)
                  {
                     vector<int> v=$3->array;
                     if(v.size())
                     {
                        v.erase(v.begin());
                        if(v.size())
                           t2=print_type($3->type, $3->deref, v, $3->adr+1);
                        else
                           t2=print_type($3->type, $3->deref+1, v, $3->adr);
                     }
                     else
                     {
                        t2=print_type($3->type, $3->deref, v, $3->adr);
                     }
                  }
                  else
                  {
                     if($3->array.size())
                        t2=print_type($3->type, $3->deref, $3->array, $3->adr);
                     else
                        t2=print_type($3->type, $3->deref+1, $3->array, $3->adr-1);
                  }
                  if(t1=="void*" || t2=="void*")
                  {
                  }
                  else
                  if(t1!=t2)
                  {
                     string err = "Invalid operand types for binary != , \"";
                     err += t1;
                     err += "\" and \"";
                     err += t2;
                     err += "\"";  
                     error(@$, err);
                  }
                  $$=new op_binary_astnode("NE_OP_INT",$1,$3);
                  $$->type="int";
               }
            if($1->is_calculatable || $3->is_calculatable)
            {
               $$->is_calculatable=true;
               $$->int_val=$1->int_val == $3->int_val;
            }
            $$->lvalue=false;
            $$->is_const=$1->is_const && $3->is_const;
            ($1->label_l == $3->label_r) ? ($$->label_l = $1->label_l+1) 
                                          : ($$->label_l = max($1->label_l, $3->label_r));
            $$->label_r = $$->label_l;
            $1->label_r = $1->label_l; $3->label_l = $1->label_r;
            if($$->is_const)
            {
               $$->const_val=$1->const_val == $3->const_val;
            }
         }
         ;

relational_expression:
         additive_expression
         {
            $$=$1;
            $$->label_r = $1->label_r;
            $$->label_l = $1->label_l;
         }
         | relational_expression '<' additive_expression
         {
            if ($1->type=="string" || $3->type=="string")
            {
               string err = "Invalid operand types for binary < , \"";
               err += print_type($1->type, $1->deref, $1->array, $1->adr);
               err += "\" and \"";
               err += print_type($3->type, $3->deref, $3->array, $3->adr);
               err += "\"";
               if ($1->type=="string" && $3->type=="string")
            {
            }
            else
               error(@$, err);
            }
             if(($1->deref+$1->adr+$1->array.size() != $3->deref+$3->adr+$3->array.size()))
            {
               string err="Invalid operand types for binary < , \"";
               err+=print_type($1->type,$1->deref,$1->array,$1->adr);
               err+="\" and \"";
               err+=print_type($3->type,$3->deref,$3->array,$3->adr);
               err+="\"";
               if(($1->is_const && $1->const_val==0) ||($3->is_const && $3->const_val==0))
               { 
                  $$=new op_binary_astnode("LT_OP_INT",$1,$3);
                  $$->type="int";
               }
               else
               error(@$,err);
            }
           if($1->deref+$1->adr+$1->array.size()==0 && $3->deref+$3->adr+$3->array.size()==0)
             { 
               if($1->type.substr(0,6)=="struct" || $3->type.substr(0,6)=="struct")
               {
                  string err = "Invalid operand types for binary < , \"";
                  err += print_type($1->type, $1->deref, $1->array, $1->adr);
                  err += "\" and \"";
                  err += print_type($3->type, $3->deref, $3->array, $3->adr);
                  err += "\"";
                  error(@$, err);
               }
               if(($1->type=="float" || $3->type=="float"))
               {
               if($1->type=="int")
                  {$1=new op_unary_astnode("TO_FLOAT",$1);}
               if($3->type=="int")
                  {$3=new op_unary_astnode("TO_FLOAT",$3);}
               $$=new op_binary_astnode("LT_OP_FLOAT",$1,$3);
               $$->type="float";
            }
            else
            {
               $$=new op_binary_astnode("LT_OP_INT",$1,$3);
               $$->type="int";
            }
             }
            if($1->deref+$1->adr+$1->array.size() && $3->deref+$3->adr+$3->array.size())
               {
                  string t1,t2;             
                  if($1->adr==0)
                  {
                     vector<int> v=$1->array;
                     if(v.size())
                     {
                        v.erase(v.begin());
                        if(v.size())
                           t1=print_type($1->type, $1->deref, v, $1->adr+1);
                        else
                           t1=print_type($1->type, $1->deref+1, v, $1->adr);
                     }
                     else
                     {
                        t1=print_type($1->type, $1->deref, v, $1->adr);
                     }
                  }
                  else
                  {
                     if($1->array.size())
                        t1=print_type($1->type, $1->deref, $1->array, $1->adr);
                     else
                        t1=print_type($1->type, $1->deref+1, $1->array, $1->adr-1);
                  }
                  if($3->adr==0)
                  {
                     vector<int> v=$3->array;
                     if(v.size())
                     {
                        v.erase(v.begin());
                        if(v.size())
                           t2=print_type($3->type, $3->deref, v, $3->adr+1);
                        else
                           t2=print_type($3->type, $3->deref+1, v, $3->adr);
                     }
                     else
                     {
                        t2=print_type($3->type, $3->deref, v, $3->adr);
                     }
                  }
                  else
                  {
                     if($3->array.size())
                        t2=print_type($3->type, $3->deref, $3->array, $3->adr);
                     else
                        t2=print_type($3->type, $3->deref+1, $3->array, $3->adr-1);
                  }
                  if(t1!=t2)
                  {
                  string err = "Invalid operand types for binary < , \"";
                  err += t1;
                  err += "\" and \"";
                  err += t2;
                  err += "\"";  
                     error(@$, err);
                  }
                  $$=new op_binary_astnode("LT_OP_INT",$1,$3);
                  $$->type="int";
               }
            $$->lvalue=false;   
            $$->is_calculatable=false;
            $$->int_val=0;
            $$->deref=0;
            $$->adr=0;
            $$->array.clear();
            $$->is_const=$1->is_const && $3->is_const;
            ($1->label_l == $3->label_r) ? ($$->label_l = $1->label_l+1) 
                                          : ($$->label_l = max($1->label_l, $3->label_r));
            $$->label_r = $$->label_l;
            $1->label_r = $1->label_l; $3->label_l = $1->label_r;
            if($$->is_const)
            {
               $$->const_val=$1->const_val < $3->const_val;
            }
         }
         | relational_expression '>' additive_expression
         {
            if ($1->type=="string" || $3->type=="string")
            {
               string err = "Invalid operand types for binary > , \"";
               err += print_type($1->type, $1->deref, $1->array, $1->adr);
               err += "\" and \"";
               err += print_type($3->type, $3->deref, $3->array, $3->adr);
               err += "\"";
          if ($1->type=="string" && $3->type=="string")
            {
            }
            else
               error(@$, err);
            }
               if($1->deref+$1->adr+$1->array.size() != $3->deref+$3->adr+$3->array.size())
               {
                  string err="Invalid operand types for binary > , \"";
                  err+=print_type($1->type,$1->deref,$1->array,$1->adr);
                  err+="\" and \"";
                  err+=print_type($3->type,$3->deref,$3->array,$3->adr);
                  err+="\"";               
                  if(($1->is_const && $1->const_val==0) ||($3->is_const && $3->const_val==0))
                  { 
                     $$=new op_binary_astnode("GT_OP_INT",$1,$3);
                     $$->type="int";
                  }
                  else
                     error(@$,err);
               }

            if($1->deref+$1->adr+$1->array.size()==0 && $3->deref+$3->adr+$3->array.size()==0)
             { 
               if($1->type.substr(0,6)=="struct" || $3->type.substr(0,6)=="struct")
               {
                  string err = "Invalid operand types for binary > , \"";
                  err += print_type($1->type, $1->deref, $1->array, $1->adr);
                  err += "\" and \"";
                  err += print_type($3->type, $3->deref, $3->array, $3->adr);
                  err += "\"";
                  error(@$, err);
               }
               if(($1->type=="float" || $3->type=="float"))
               {
                  if($1->type=="int")
                     {$1=new op_unary_astnode("TO_FLOAT",$1);}
                  if($3->type=="int")
                     {$3=new op_unary_astnode("TO_FLOAT",$3);}
                  $$=new op_binary_astnode("GT_OP_FLOAT",$1,$3);
                  $$->type="float";
               }
               else
               {
                  $$=new op_binary_astnode("GT_OP_INT",$1,$3);
                  $$->type="int";
               }
             }
               if($1->deref+$1->adr+$1->array.size() && $3->deref+$3->adr+$3->array.size())
               {
                  string t1,t2;             
                  if($1->adr==0)
                  {
                     vector<int> v=$1->array;
                     if(v.size())
                     {
                        v.erase(v.begin());
                        if(v.size())
                           t1=print_type($1->type, $1->deref, v, $1->adr+1);
                        else
                           t1=print_type($1->type, $1->deref+1, v, $1->adr);
                     }
                     else
                     {
                        t1=print_type($1->type, $1->deref, v, $1->adr);
                     }
                  }
                  else
                  {
                     if($1->array.size())
                        t1=print_type($1->type, $1->deref, $1->array, $1->adr);
                     else
                        t1=print_type($1->type, $1->deref+1, $1->array, $1->adr-1);
                  }
                  if($3->adr==0)
                  {
                     vector<int> v=$3->array;
                     if(v.size())
                     {
                        v.erase(v.begin());
                        if(v.size())
                           t2=print_type($3->type, $3->deref, v, $3->adr+1);
                        else
                           t2=print_type($3->type, $3->deref+1, v, $3->adr);
                     }
                     else
                     {
                        t2=print_type($3->type, $3->deref, v, $3->adr);
                     }
                  }
                  else
                  {
                     if($3->array.size())
                        t2=print_type($3->type, $3->deref, $3->array, $3->adr);
                     else
                        t2=print_type($3->type, $3->deref+1, $3->array, $3->adr-1);
                  }
                  if(t1!=t2)
                  {
                  string err = "Invalid operand types for binary > , \"";
                  err += t1;
                  err += "\" and \"";
                  err += t2;
                  err += "\"";  
                     error(@$, err);
                  }
                  $$=new op_binary_astnode("GT_OP_INT",$1,$3);
                  $$->type="int";
               }
               $$->lvalue=false;   
               $$->is_calculatable=false;
               $$->int_val=0;
               $$->deref=0;
               $$->adr=0;
               $$->array.clear();
               $$->is_const=$1->is_const && $3->is_const;
               ($1->label_l == $3->label_r) ? ($$->label_l = $1->label_l+1) 
                                          : ($$->label_l = max($1->label_l, $3->label_r));
               $$->label_r = $$->label_l;
               if($$->is_const)
               {
                  $$->const_val=$1->const_val > $3->const_val;
               }
         }
         | relational_expression LE_OP additive_expression
         {
            if ($1->type=="string" || $3->type=="string")
            {
               string err = "Invalid operand types for binary <= , \"";
               err += print_type($1->type, $1->deref, $1->array, $1->adr);
               err += "\" and \"";
               err += print_type($3->type, $3->deref, $3->array, $3->adr);
               err += "\"";        
                      if ($1->type=="string" && $3->type=="string")
            {
            }
            else
               error(@$, err);
            }
            if($1->deref+$1->adr+$1->array.size() != $3->deref+$3->adr+$3->array.size())
            {
               string err="Invalid operand types for binary <= , \"";
               err+=print_type($1->type,$1->deref,$1->array,$1->adr);
               err+="\" and \"";
               err+=print_type($3->type,$3->deref,$3->array,$3->adr);
               err+="\"";            
                  if(($1->is_const && $1->const_val==0) ||($3->is_const && $3->const_val==0))
                  { 
                     $$=new op_binary_astnode("LE_OP_INT",$1,$3);
                     $$->type="int";
                  }
                  else
                     error(@$,err);
            }
            if($1->deref+$1->adr+$1->array.size()==0 && $3->deref+$3->adr+$3->array.size()==0)
             { 
               if($1->type.substr(0,6)=="struct" || $3->type.substr(0,6)=="struct")
               {
                  string err = "Invalid operand types for binary <= , \"";
                  err += print_type($1->type, $1->deref, $1->array, $1->adr);
                  err += "\" and \"";
                  err += print_type($3->type, $3->deref, $3->array, $3->adr);
                  err += "\"";
                  error(@$, err);
               }
               if(($1->type=="float" || $3->type=="float"))
               {
                  if($1->type=="int")
                     {$1=new op_unary_astnode("TO_FLOAT",$1);}
                  if($3->type=="int")
                     {$3=new op_unary_astnode("TO_FLOAT",$3);}
                  $$=new op_binary_astnode("LE_OP_FLOAT",$1,$3);
                  $$->type="float";
               }
               else
               {
                  $$=new op_binary_astnode("LE_OP_INT",$1,$3);
                  $$->type="int";
               }
             }
            if($1->deref+$1->adr+$1->array.size() && $3->deref+$3->adr+$3->array.size())
               {
                  string t1,t2;             
                  if($1->adr==0)
                  {
                     vector<int> v=$1->array;
                     if(v.size())
                     {
                        v.erase(v.begin());
                        if(v.size())
                           t1=print_type($1->type, $1->deref, v, $1->adr+1);
                        else
                           t1=print_type($1->type, $1->deref+1, v, $1->adr);
                     }
                     else
                     {
                        t1=print_type($1->type, $1->deref, v, $1->adr);
                     }
                  }
                  else
                  {
                     if($1->array.size())
                        t1=print_type($1->type, $1->deref, $1->array, $1->adr);
                     else
                        t1=print_type($1->type, $1->deref+1, $1->array, $1->adr-1);
                  }
                  if($3->adr==0)
                  {
                     vector<int> v=$3->array;
                     if(v.size())
                     {
                        v.erase(v.begin());
                        if(v.size())
                           t2=print_type($3->type, $3->deref, v, $3->adr+1);
                        else
                           t2=print_type($3->type, $3->deref+1, v, $3->adr);
                     }
                     else
                     {
                        t2=print_type($3->type, $3->deref, v, $3->adr);
                     }
                  }
                  else
                  {
                     if($3->array.size())
                        t2=print_type($3->type, $3->deref, $3->array, $3->adr);
                     else
                        t2=print_type($3->type, $3->deref+1, $3->array, $3->adr-1);
                  }
                  if(t1!=t2)
                  {
                  string err = "Invalid operand types for binary <= , \"";
                  err += t1;
                  err += "\" and \"";
                  err += t2;
                  err += "\"";  
                     error(@$, err);
                  }
                  $$=new op_binary_astnode("LE_OP_INT",$1,$3);
                  $$->type="int";
               }
            $$->lvalue=false;
            $$->is_calculatable=false;
            $$->int_val=0;
            $$->deref=0;
            $$->adr=0;
            $$->array.clear();
            $$->is_const=$1->is_const && $3->is_const;
            ($1->label_l == $3->label_r) ? ($$->label_l = $1->label_l+1) 
                                          : ($$->label_l = max($1->label_l, $3->label_r));
            $$->label_r = $$->label_l;
            $1->label_r = $1->label_l; $3->label_l = $1->label_r;
            if($$->is_const)
            {
               $$->const_val=$1->const_val <= $3->const_val;
            }
         }
         | relational_expression GE_OP additive_expression
         {
            if ($1->type=="string" || $3->type=="string")
            {
               string err = "Invalid operand types for binary >= , \"";
               err += print_type($1->type, $1->deref, $1->array, $1->adr);
               err += "\" and \"";
               err += print_type($3->type, $3->deref, $3->array, $3->adr);
               err += "\"";
      if ($1->type=="string" && $3->type=="string")
            {
            }
            else
               error(@$, err);
            }
            if($1->deref+$1->adr+$1->array.size() != $3->deref+$3->adr+$3->array.size())
            {
               string err="Invalid operand types for binary >= , \"";
               err+=print_type($1->type,$1->deref,$1->array,$1->adr);
               err+="\" and \"";
               err+=print_type($3->type,$3->deref,$3->array,$3->adr);
               err+="\"";         
                  if(($1->is_const && $1->const_val==0) ||($3->is_const && $3->const_val==0))
                  { 
                     $$=new op_binary_astnode("GE_OP_INT",$1,$3);
                     $$->type="int";
                  }
                  else
                     error(@$,err);
            }
             if($1->deref+$1->adr+$1->array.size()==0 && $3->deref+$3->adr+$3->array.size()==0)
             { 
               if($1->type.substr(0,6)=="struct" || $3->type.substr(0,6)=="struct")
               {
                  string err = "Invalid operand types for binary >= , \"";
                  err += print_type($1->type, $1->deref, $1->array, $1->adr);
                  err += "\" and \"";
                  err += print_type($3->type, $3->deref, $3->array, $3->adr);
                  err += "\"";
                  error(@$, err);
               }
               if(($1->type=="float" || $3->type=="float"))
               {
                  if($1->type=="int")
                     {$1=new op_unary_astnode("TO_FLOAT",$1);}
                  if($3->type=="int")
                     {$3=new op_unary_astnode("TO_FLOAT",$3);}
                  $$=new op_binary_astnode("GE_OP_FLOAT",$1,$3);
                  $$->type="float";
               }
               else
               {
                  $$=new op_binary_astnode("GE_OP_INT",$1,$3);
                  $$->type="int";
               }
            }
            if($1->deref+$1->adr+$1->array.size() && $3->deref+$3->adr+$3->array.size())
               {
                  string t1,t2;             
                  if($1->adr==0)
                  {
                     vector<int> v=$1->array;
                     if(v.size())
                     {
                        v.erase(v.begin());
                        if(v.size())
                           t1=print_type($1->type, $1->deref, v, $1->adr+1);
                        else
                           t1=print_type($1->type, $1->deref+1, v, $1->adr);
                     }
                     else
                     {
                        t1=print_type($1->type, $1->deref, v, $1->adr);
                     }
                  }
                  else
                  {
                     if($1->array.size())
                        t1=print_type($1->type, $1->deref, $1->array, $1->adr);
                     else
                        t1=print_type($1->type, $1->deref+1, $1->array, $1->adr-1);
                  }
                  if($3->adr==0)
                  {
                     vector<int> v=$3->array;
                     if(v.size())
                     {
                        v.erase(v.begin());
                        if(v.size())
                           t2=print_type($3->type, $3->deref, v, $3->adr+1);
                        else
                           t2=print_type($3->type, $3->deref+1, v, $3->adr);
                     }
                     else
                     {
                        t2=print_type($3->type, $3->deref, v, $3->adr);
                     }
                  }
                  else
                  {
                     if($3->array.size())
                        t2=print_type($3->type, $3->deref, $3->array, $3->adr);
                     else
                        t2=print_type($3->type, $3->deref+1, $3->array, $3->adr-1);
                  }
                  if(t1!=t2)
                  {
                  string err = "Invalid operand types for binary >= , \"";
                  err += t1;
                  err += "\" and \"";
                  err += t2;
                  err += "\"";  
                     error(@$, err);
                  }
                  $$=new op_binary_astnode("GE_OP_INT",$1,$3);
                  $$->type="int";
               }
            $$->lvalue=false;
            $$->is_calculatable=false;
            $$->int_val=0;
            $$->deref=0;
            $$->adr=0;
            $$->array.clear();
            $$->is_const=$1->is_const && $3->is_const;
            ($1->label_l == $3->label_r) ? ($$->label_l = $1->label_l+1) 
                                          : ($$->label_l = max($1->label_l, $3->label_r));
            $$->label_r = $$->label_l;
            $1->label_r = $1->label_l; $3->label_l = $1->label_r;
            if($$->is_const)
            {
               $$->const_val=$1->const_val >= $3->const_val;
            }
         }
         ;

additive_expression:
         multiplicative_expression
         {
           $$=$1;
           $$->label_l = $1->label_l;
           $$->label_r = $1->label_r;
         }
         | additive_expression '+' multiplicative_expression
         {
             if ($1->type=="string" || $3->type=="string")
            {
               string err = "Invalid operand types for binary + , \"";
               err += print_type($1->type, $1->deref, $1->array, $1->adr);
               err += "\" and \"";
               err += print_type($3->type, $3->deref, $3->array, $3->adr);
               err += "\"";
               error(@$, err);
            }
            if ($1->deref + $1->adr + $1->array.size() && $3->deref + $3->adr + $3->array.size() == 0)
            {
               if($3->type!="int")
               {
                   string err = "Invalid operand types for binary + , \"";
               err += print_type($1->type, $1->deref, $1->array, $1->adr);
               err += "\" and \"";
               err += print_type($3->type, $3->deref, $3->array, $3->adr);
               err += "\"";
               error(@$, err);
               }
               $$ = new op_binary_astnode("PLUS_INT", $1, $3);
               $$->type = $1->type;
               $$->lvalue = false;
               $$->array = $1->array;
               $$->deref = $1->deref;
               $$->adr = $1->adr;
            }
            else if ($3->deref + $3->adr + $3->array.size() && $1->deref + $1->adr + $1->array.size() == 0)
            {
                if($1->type!="int")
               {
                   string err = "Invalid operand types for binary + , \"";
               err += print_type($1->type, $1->deref, $1->array, $1->adr);
               err += "\" and \"";
               err += print_type($3->type, $3->deref, $3->array, $3->adr);
               err += "\"";
               error(@$, err);
               }
               $$ = new op_binary_astnode("PLUS_INT", $1, $3);
               $$->type = $3->type;
               $$->lvalue = false;
               $$->array = $3->array;
               $$->deref = $3->deref;
               $$->adr = $3->adr;
            }
            else if ($1->deref + $1->adr + $1->array.size() && $3->deref + $3->adr + $3->array.size())
            {
               string err = "Invalid operand types for binary + , \"";
               err += print_type($1->type, $1->deref, $1->array, $1->adr);
               err += "\" and \"";
               err += print_type($3->type, $3->deref, $3->array, $3->adr);
               err += "\"";
               error(@$, err);
            }
            else
            {
               if($1->type.substr(0,6)=="struct" || $3->type.substr(0,6)=="struct")
               {
                  string err = "Invalid operand types for binary + , \"";
                  err += print_type($1->type, $1->deref, $1->array, $1->adr);
                  err += "\" and \"";
                  err += print_type($3->type, $3->deref, $3->array, $3->adr);
                  err += "\"";
                  error(@$, err);
               }
               if ($1->type == "float" || $3->type == "float")
               {
                  if ($1->type == "int")
                  {
                        $1 = new op_unary_astnode("TO_FLOAT", $1);
                  }
                  if ($3->type == "int")
                  {
                        $3 = new op_unary_astnode("TO_FLOAT", $3);
                  }
                  $$ = new op_binary_astnode("PLUS_FLOAT", $1, $3);
                  $$->type = "float";
               }
               else
               {
                  $$ = new op_binary_astnode("PLUS_INT", $1, $3);
                  $$->type = "int";
               }
               $$->lvalue = false;
               $$->is_calculatable = false;
               $$->int_val = $1->int_val + $3->int_val;
               $$->deref = 0;
               $$->adr = 0;
               $$->array.clear();
            }
            $$->is_const = $1->is_const && $3->is_const;
            ($1->label_l == $3->label_r) ? ($$->label_l = $1->label_l+1) 
                                          : ($$->label_l = max($1->label_l, $3->label_r));
            $$->label_r = $$->label_l;
            $1->label_r = $1->label_l; $3->label_l = $1->label_r;
            if($$->is_const)
            {
               $$->const_val=$1->const_val + $3->const_val;
            }
         }
         | additive_expression '-' multiplicative_expression
         {
             if ($1->type=="string" || $3->type=="string")
            {
               string err = "Invalid operand types for binary + , \"";
               err += print_type($1->type, $1->deref, $1->array, $1->adr);
               err += "\" and \"";
               err += print_type($3->type, $3->deref, $3->array, $3->adr);
               err += "\"";
               error(@$, err);
            }
            if ($1->deref + $1->adr + $1->array.size()  && $3->deref + $3->adr + $3->array.size() == 0)
            {
                if($3->type!="int")
               {
                   string err = "Invalid operand types for binary - , \"";
               err += print_type($1->type, $1->deref, $1->array, $1->adr);
               err += "\" and \"";
               err += print_type($3->type, $3->deref, $3->array, $3->adr);
               err += "\"";
               error(@$, err);
               }
               $$ = new op_binary_astnode("MINUS_INT", $1, $3);
               $$->type = $1->type;
               $$->lvalue = true;
               $$->array = $1->array;
               $$->deref = $1->deref;
               $$->adr = $1->adr;
            }
           else if (($1->type!=$3->type && $1->deref + $1->adr + $1->array.size() && $3->deref + $3->adr + $3->array.size() ) || ($1->deref + $1->adr + $1->array.size() != $3->deref + $3->adr + $3->array.size()))
            {
               string err = "Invalid operand types for binary - , \"";
               err += print_type($1->type, $1->deref, $1->array, $1->adr);
               err += "\" and \"";
               err += print_type($3->type, $3->deref, $3->array, $3->adr);
               err += "\"";
               error(@$, err);
            }
            else if($1->deref + $1->adr + $1->array.size() && $3->deref + $3->adr + $3->array.size())
            {
               string t1,t2;             
               if($1->adr==0)
               {
                  vector<int> v=$1->array;
                  if(v.size())
                  {
                     v.erase(v.begin());
                     if(v.size())
                     {
                        t1=print_type($1->type, $1->deref, v, $1->adr+1);
                     }
                     else
                     {
                        t1=print_type($1->type, $1->deref+1, v, $1->adr);
                     }
                  }
                  else
                  {
                     t1=print_type($1->type, $1->deref, v, $1->adr);
                  }
               }
               else
               {
                     if($1->array.size())
                        t1=print_type($1->type, $1->deref, $1->array, $1->adr);
                     else
                        t1=print_type($1->type, $1->deref+1, $1->array, $1->adr-1);
               }
               if($3->adr==0)
               {
                  vector<int> v=$3->array;
                  if(v.size())
                  {
                     v.erase(v.begin());
                     if(v.size())
                     {
                        t2=print_type($3->type, $3->deref, v, $3->adr+1);
                     }
                     else
                     {
                        t2=print_type($3->type, $3->deref+1, v, $3->adr);
                     }
                  }
                  else
                  {
                     t2=print_type($3->type, $3->deref, v, $3->adr);
                  }
               }
               else
               {
                  if($3->array.size())
                     t2=print_type($3->type, $3->deref, $3->array, $3->adr);
                  else
                     t2=print_type($3->type, $3->deref+1, $3->array, $3->adr-1);
               }
               if(t1!=t2)
               {
               string err = "Invalid operand types for binary - , \"";
               err += t1;
               err += "\" and \"";
               err += t2;
               err += "\"";  
                  error(@$, err);
               }
               else
               {
                  $$ = new op_binary_astnode("MINUS_INT", $1, $3);
                  $$->type = "int";
                  $$->lvalue = false;
                  vector<int> v;
                  $$->array = v;
                  $$->deref = 0;
                  $$->adr = 0;
               }
            }
            else
            {
               if($1->type.substr(0,6)=="struct" || $3->type.substr(0,6)=="struct")
               {
                  string err = "Invalid operand types for binary - , \"";
                  err += print_type($1->type, $1->deref, $1->array, $1->adr);
                  err += "\" and \"";
                  err += print_type($3->type, $3->deref, $3->array, $3->adr);
                  err += "\"";
                  error(@$, err);
               }
               if ($1->type == "float" || $3->type == "float")
               {
                  if ($1->type == "int")
                  {
                        $1 = new op_unary_astnode("TO_FLOAT", $1);
                  }
                  if ($3->type == "int")
                  {
                        $3 = new op_unary_astnode("TO_FLOAT", $3);
                  }
                  $$ = new op_binary_astnode("MINUS_FLOAT", $1, $3);
                  $$->type = "float";
               }
               else
               {
                  $$ = new op_binary_astnode("MINUS_INT", $1, $3);
                  $$->type = "int";
               }
               $$->lvalue = false;
               $$->is_calculatable = false;
               $$->int_val = $1->int_val - $3->int_val;
               $$->deref = 0;
               $$->adr = 0;
               $$->array.clear();
            }
            $$->is_const = $1->is_const && $3->is_const;
            ($1->label_l == $3->label_r) ? ($$->label_l = $1->label_l+1) 
                                          : ($$->label_l = max($1->label_l, $3->label_r));
            $$->label_r = $$->label_l;
            $1->label_r = $1->label_l; $3->label_l = $1->label_r;
            if($$->is_const)
            {
               $$->const_val=$1->const_val-$3->const_val;
            }
         }
         ;

unary_expression:
         postfix_expression
         {
            $$=$1;
            $$->label_l = $1->label_l;
            $$->label_r = $1->label_r;
            
            // cout<<"unary_expression: postfix_expression "<<$$->type<<endl;
         }
         | unary_operator unary_expression
         {
            $1->child=$2;
            $$=$1;
            $$->label_l = $2->label_l;
            $$->label_r = $2->label_l;
            $2->label_r = $2->label_l;
            if($1->op=="UMINUS")
            {
               if($2->type=="void")
               {
                  string err = "Invalid operand type \"";
                  err += print_type($2->type, $2->deref, $2->array, $2->adr);
                  err += "\"";
                  err +=" for unary -";
                  error(@$, err);
               }
               op_unary_astnode *unary = new op_unary_astnode("UMINUS", $2);
               $$ = unary;
            }
            if($1->op=="DEREF")
            {
               if($2->type=="void" && $2->deref+$2->adr+$2->array.size()<2)
               {
                  string err = "Invalid operand type \"";
                  err += print_type($2->type, $2->deref, $2->array, $2->adr);
                  err += "\"";
                  err +=" for unary *";
                  error(@$, err);
               }
               if($2->adr)
               {
                  $$->adr=$2->adr-1;
                  $$->type=$2->type;
                  $$->lvalue=true;
                  $$->deref=$2->deref;
                  $$->array=$2->array;
               }
               else if($2->array.size())
               {
                  $$->array=$2->array;
                  $$->array.erase($$->array.begin());
                  $$->type=$2->type;
                  $$->lvalue=true;
                  $$->deref=$2->deref;
                  $$->adr=$2->adr;
               }
               else if($2->deref)
               {
                  $$->deref=$2->deref-1;
                  $$->type=$2->type;
                  $$->lvalue=true;
                  $$->adr=$2->adr;
                  $$->array=$2->array;
               }
               else
               {
                  string err="Invalid operand type \"";
                  err+=print_type($2->type,$2->deref,$2->array,$2->adr);
                  err+="\" of unary *";
                  error(@$,err);
               }
               $$->is_const=false;
            }
            else if($1->op=="ADDRESS")
            {
               if($2->type=="void" && $2->deref==0 && $2->adr==0 && $2->array.size()==0)
               {
                  string err = "Invalid operand type \"";
                  err += print_type($2->type, $2->deref, $2->array, $2->adr);
                  err += "\"";
                  err +=" for unary &";
                  error(@$, err);
               }
               if($2->lvalue)
               {
                  $$->adr=$2->adr+1;
                  $$->type=$2->type;
                  $$->lvalue=false;
                  $$->deref=$2->deref;
                  $$->array=$2->array;
                  // cout<<"address of "<<$2->type<<" "<<$2->deref<<" "<<$2->adr<<" "<<$2->array.size()<<endl;
                  // cout<<"address of "<<$$->type<<" "<<$$->deref<<" "<<$$->adr<<" "<<$$->array.size()<<endl;
               }
               else
               {
                  string err="Operand of & should have lvalue";
                  error(@$,err);
               }
               $$->is_const=false;
            }
            else if($1->op=="UMINUS")
            {
               if(($2->type!="int" && $2->type!="float") || $2->deref+$2->adr+$2->array.size())
               {
                  string err= "Operand of unary - should be an int or float";
                  error(@$,err);
               }
               $$->type=$2->type;
               $$->lvalue=false;
               $$->deref=0;
               $$->adr=0;
               $$->array=$2->array;
               $$->array.clear();
               $$->is_const=$2->is_const;
               if($2->is_const)
               {
                  $$->const_val=-$2->const_val;
               }
            }
            else if($1->op=="NOT")
            {
               if($2->adr+$2->deref+$2->array.size())
               {
               }
               else if(($2->type!="int" && $2->type!="float") )
               {
                  string err= "Invalid operand type \"";
                  err+=print_type($2->type,$2->deref,$2->array,$2->adr);
                  err+="\" for unary !";
                  error(@$,err);
               }
               $$->type="int";
               $$->lvalue=false;
               $$->deref=0;
               $$->adr=0;
               $$->array=$2->array;
               $$->array.clear();
               $$->is_const=$2->is_const;
               if($2->is_const)
               {
                  $$->const_val=!$2->const_val;
               }
            }
         }
         ;

multiplicative_expression:
         unary_expression
         {
            $$=$1;    
            $$->label_l = $1->label_l;
            $$->label_r = $1->label_r;     
         }
         | multiplicative_expression '*' unary_expression
         {
            if($1->deref+$1->adr+$1->array.size() || $3->deref+$3->adr+$3->array.size())
            {
               string err="Invalid operand types for binary * , \"";
               err+=print_type($1->type,$1->deref,$1->array,$1->adr);
               err+="\" and \"";
               err+=print_type($3->type,$3->deref,$3->array,$3->adr);
               err+="\"";
               error(@$,err);
            }
            if($1->type.substr(0,6)=="struct" || $3->type.substr(0,6)=="struct")
               {
                  string err = "Invalid operand types for binary * , \"";
                  err += print_type($1->type, $1->deref, $1->array, $1->adr);
                  err += "\" and \"";
                  err += print_type($3->type, $3->deref, $3->array, $3->adr);
                  err += "\"";
                  error(@$, err);
               }
            if($1->type=="float" || $3->type=="float")
            {
               if($1->type=="int")
                  {$1=new op_unary_astnode("TO_FLOAT",$1);}
               if($3->type=="int")
                  {$3=new op_unary_astnode("TO_FLOAT",$3);}
               $$=new op_binary_astnode("MULT_FLOAT",$1,$3);
               $$->type="float";
            }
            else
            {
               $$=new op_binary_astnode("MULT_INT",$1,$3);
               $$->type="int";
            }
            $$->lvalue=false;
            $$->deref=$1->deref;
            $$->adr=$1->adr;
            $$->array=$1->array;
            $$->is_const=$1->is_const && $3->is_const;
            
            ($1->label_l == $3->label_r) ? ($$->label_l = $1->label_l+1) 
                                          : ($$->label_l = max($1->label_l, $3->label_r));
            $$->label_r = $$->label_l;
            $1->label_r = $1->label_l; $3->label_l = $1->label_r;

            if($$->is_const)
            {
               $$->const_val=$1->const_val*$3->const_val;
            }
         }
         | multiplicative_expression '/' unary_expression
         {
            if($1->deref+$1->adr+$1->array.size() || $3->deref+$3->adr+$3->array.size())
            {
               string err="Invalid operand types for binary / , \"";
               err+=print_type($1->type,$1->deref,$1->array,$1->adr);
               err+="\" and \"";
               err+=print_type($3->type,$3->deref,$3->array,$3->adr);
               err+="\"";
               error(@$,err);
            }
            if($1->type.substr(0,6)=="struct" || $3->type.substr(0,6)=="struct")
               {
                  string err = "Invalid operand types for binary / , \"";
                  err += print_type($1->type, $1->deref, $1->array, $1->adr);
                  err += "\" and \"";
                  err += print_type($3->type, $3->deref, $3->array, $3->adr);
                  err += "\"";
                  error(@$, err);
               }
            if($1->type=="float" || $3->type=="float")
            {
               if($1->type=="int")
                  {$1=new op_unary_astnode("TO_FLOAT",$1);}
               if($3->type=="int")
                  {$3=new op_unary_astnode("TO_FLOAT",$3);}
               $$=new op_binary_astnode("DIV_FLOAT",$1,$3);
               $$->type="float";
            }
            else
            {
               $$=new op_binary_astnode("DIV_INT",$1,$3);
               $$->type="int";
            }
            $$->lvalue=false;
            $$->deref=$1->deref;
            $$->adr=$1->adr;
            $$->array=$1->array;
            $$->is_const=$1->is_const && $3->is_const;

            ($1->label_l == $3->label_r) ? ($$->label_l = $1->label_l+1) 
                                          : ($$->label_l = max($1->label_l, $3->label_r));
            $$->label_r = $$->label_l;
            $1->label_r = $1->label_l; $3->label_l = $1->label_r;

            if($$->is_const)
            {
               if($3->const_val==0)
               {
                  string err="Division by zero";
                  error(@$,err);
               }
               $$->const_val=$1->const_val/$3->const_val;
            }
         }
         ;

postfix_expression:
         primary_expression
         {
            $$=$1;
            $$->label_l = $1->label_l;
            $$->label_r = $1->label_r;
         }
         | postfix_expression '[' expression ']'
         {
            $$=new arrayref_astnode($1,$3);
            if($1->array.size()+$1->deref==0)
            {
               string err="Subscripted value is neither array nor pointer";
               error(@$,err);
            }
            if($3->type!="int" || $3->array.size() || $3->deref)
            {
               string err="Array subscript is not an integer";
               error(@$,err);
            }
            if($1->array.size())
            {
               $$->array=$1->array;
               $$->array.erase($$->array.begin());
               $$->deref=$1->deref;
               $$->adr=$1->adr;
            }
            else
            {
               $$->deref=$1->deref-1;
               $$->adr=$1->adr;
               $$->array=$1->array;
            }
            $$->type=$1->type;
            $$->lvalue=true;
            $$->is_const=false;
         }
         | IDENTIFIER '(' ')'
         {
            $$=new funcall_astnode({new identifier_astnode($1)});
            $$->label_r = 0;
            $$->label_l = 1;
            if(predefined.find($1)==predefined.end())
            {
               Entry *st=gst.search($1);
               if(st==NULL)
               {
                  string err="Function \""+$1+"\" is not declared";
                  error(@$,err);                  
               }
               if(st->varfun!="fun")
               {
                  string err="Object \""+$1+"\" is not a function";
                  error(@$,err);
               }
               vector<string> param_list=st->param_list;
               if(param_list.size()!=0)
               {
                  string err="Function \""+$1+"\" called with too few arguments";
                  error(@$,err);
               }
               pair<string,pair<int,vector<int>>> p=get_type(st->type);
               $$->type=p.first;
               $$->deref=p.second.first;
               $$->array=p.second.second;
               $$->adr=0;
            }
            else
            {  if($1=="mod")
                  $$->type="int";
               else
                  $$->type="void";

               $$->deref=0;
               $$->array.clear();
               $$->adr=0;
            }
            $$->lvalue=false;
            $$->is_const=false;
         }
         | IDENTIFIER '(' expression_list ')'
         {
             if(predefined.find($1)==predefined.end())
            {
               Entry *st=gst.search($1);
               if(st==NULL)
               {
                  string err="Function \""+$1+"\" is not declared";
                  error(@$,err);
               }
               if(st->varfun!="fun")
               {
                  string err="Object \""+$1+"\" is not a function";
                  error(@$,err);
               }
               vector<string> param_list=st->param_list;
               if(param_list.size()>$3->size())
               {
                  string err="Function \""+$1+"\" called with too few arguments";
                  error(@$,err);
               }
               if(param_list.size()<$3->size())
               {
                  string err="Function \""+$1+"\" called with too many arguments";
                  error(@$,err);
               }
               for(int i=0;i<(int)($3->size());i++)
               {
                  if(param_list[i]=="int" || param_list[i]=="float")
                  {
                     if(($3->at(i)->type!="float" && $3->at(i)->type!="int")|| $3->at(i)->array.size() || $3->at(i)->deref || $3->at(i)->adr)
                     {
                        string err="Expected \""+param_list[i]+"\" but argument is of type \""+print_type($3->at(i)->type,$3->at(i)->deref,$3->at(i)->array,$3->at(i)->adr)+"\"";
                        error(@$,err);
                     }
                     if(param_list[i]=="int" && $3->at(i)->type=="float")
                     {
                        $3->at(i)=new op_unary_astnode("TO_INT",$3->at(i));
                     }
                     if(param_list[i]=="float" && $3->at(i)->type=="int")
                     {
                        $3->at(i)=new op_unary_astnode("TO_FLOAT",$3->at(i));
                     }
                  }
                  else if(param_list[i]==print_type($3->at(i)->type,$3->at(i)->deref,$3->at(i)->array,$3->at(i)->adr))
                  {
                     continue;
                  }
                  else
                  {           
                     pair<string,pair<int,vector<int>>> p_type=get_type(param_list[i]);
                     if(p_type.second.first+p_type.second.second.size() && $3->at(i)->is_const && !$3->at(i)->const_val)
                     {
                        continue;
                     } 
                     if(p_type.first=="void")
                     {
                        if($3->at(i)->type=="void" && $3->at(i)->deref+$3->at(i)->adr+$3->at(i)->array.size()==1)
                        {
                           continue;
                        }
                        else
                        {
                           string err="Expected \"";
                           err+=print_type(p_type.first,p_type.second.first,p_type.second.second,0);
                           err+="\" but argument is of type \"";
                           if(p_type.second.first+p_type.second.second.size()==1)
                           {
                              if($3->at(i)->deref+$3->at(i)->adr+$3->at(i)->array.size()!=0)
                              {
                                 continue;
                              }
                              else
                              {  
                                 err+=print_type($3->at(i)->type,$3->at(i)->deref,$3->at(i)->array,$3->at(i)->adr);
                                 err+="\"";
                                 error(@$,err);
                              }
                           }
                           else
                           {
                              if($3->at(i)->type!="void") 
                              {
                                 err+=print_type($3->at(i)->type,$3->at(i)->deref,$3->at(i)->array,$3->at(i)->adr);
                                 err+="\"";
                                 error(@$,err);
                              }
                              string type3;
                              if($3->at(i)->adr==0)
                              {
                                 vector<int> v=$3->at(i)->array;
                                 if(v.size())
                                 {
                                    v.erase(v.begin());
                                    if(v.size())
                                       type3=print_type($3->at(i)->type, $3->at(i)->deref, v, $3->at(i)->adr+1);
                                    else
                                       type3=print_type($3->at(i)->type, $3->at(i)->deref+1, v, $3->at(i)->adr);
                                 }
                                 else
                                 {
                                    type3=print_type($3->at(i)->type, $3->at(i)->deref, v, $3->at(i)->adr);
                                 }
                              }
                              else
                              {
                                 type3=print_type($3->at(i)->type, $3->at(i)->deref, $3->at(i)->array, $3->at(i)->adr);
                              }
                              if(print_type(p_type.first,p_type.second.first,p_type.second.second,0)!=type3)
                              {
                                 err+=type3+"\"";
                                 error(@$,err);
                              }
                           }
                        }
                     }
                     else if($3->at(i)->type=="void" && p_type.second.first+p_type.second.second.size())
                     {
                        if($3->at(i)->deref+$3->at(i)->adr+$3->at(i)->array.size()==1)
                        {
                           continue;
                        }
                        else
                        {
                           string err="Expected \"";
                           err+=print_type(p_type.first,p_type.second.first,p_type.second.second,0);
                           err+="\" but argument is of type \"";
                           err+=print_type($3->at(i)->type,$3->at(i)->deref,$3->at(i)->array,$3->at(i)->adr);
                           err+="\"";
                           error(@$,err);
                        }
                     }
                     else 
                     {
                        string t1,t2;     
                        vector<int> v=p_type.second.second;
                        if(v.size())
                        {
                           v.erase(v.begin());
                           if(v.size())
                              t1=print_type(p_type.first, p_type.second.first, v,1);
                           else
                              t1=print_type(p_type.first, p_type.second.first+1, v,0);
                        }
                        else
                        {
                           t1=print_type(p_type.first, p_type.second.first, v, 0);
                        }
                        
                        if($3->at(i)->adr==0)
                        {
                           vector<int> v=$3->at(i)->array;
                           if(v.size())
                           {
                              v.erase(v.begin());
                              if(v.size())
                                 t2=print_type($3->at(i)->type, $3->at(i)->deref, v, $3->at(i)->adr+1);
                              else
                                 t2=print_type($3->at(i)->type, $3->at(i)->deref+1, v, $3->at(i)->adr);
                           }
                           else
                           {
                              t2=print_type($3->at(i)->type, $3->at(i)->deref, v, $3->at(i)->adr);
                           }
                        }
                        else
                        {
                           if($3->at(i)->array.size())
                              t2=print_type($3->at(i)->type, $3->at(i)->deref, $3->at(i)->array, $3->at(i)->adr);
                           else
                              t2=print_type($3->at(i)->type, $3->at(i)->deref+1, $3->at(i)->array, $3->at(i)->adr-1);
                        }
                        if(t1!=t2)
                        {
                           string err="Expected \""+t1+"\" but argument is of type \""+t2+"\"";
                           error(@3,err);
                        }
                     }
                  
                  }
               }
            }
            $3->insert($3->begin(),new identifier_astnode($1));
            $$=new funcall_astnode(*$3);
            $$->label_r = 0;
            $$->label_l = 1;
            if(predefined.find($1)!=predefined.end())
            {
               if($1=="mod")
                  $$->type="int";
               else
                  $$->type="void";
               $$->deref=0;
               $$->array.clear();
               $$->adr=0;
            }
            else
            {
               Entry *st=gst.search($1);
               pair<string,pair<int,vector<int>>> p=get_type(st->type);
               $$->type=p.first;
               $$->deref=p.second.first;
               $$->array=p.second.second;
               $$->adr=0;
            }
            $$->lvalue=false;
            $$->is_const=false;
         }
         | postfix_expression '.' IDENTIFIER
         {
           $$=new member_astnode($1,new identifier_astnode($3));
           if($1->type.substr(0,6)!="struct" || $1->deref || $1->array.size() || $1->adr)
           {
               string err="Left operand of \".\" is not a structure";
               error(@$,err);
           }
            Entry *st=gst.search($1->type);
             if(st==NULL)
             {
               string err="\""+print_type($1->type,$1->deref,$1->array,$1->adr)+"\" is not defined";
               error(@$,err);
             }
             SymbolTable *curr_symb=st->symbtab;
            if(curr_symb->Entries.find($3)==curr_symb->Entries.end())
            {
               string err="\""+$3+"\" is not a member of \""+print_type($1->type,$1->deref,$1->array,$1->adr)+"\"";
               error(@$,err);
            }
            Entry *st1=curr_symb->search($3);
            pair<string,pair<int,vector<int>>> p=get_type(st1->type);
            $$->type=p.first;
            $$->deref=p.second.first;
            $$->array=p.second.second;
            $$->lvalue=true;
            $$->adr=0;
            $$->is_const=false;
         }
         | postfix_expression PTR_OP IDENTIFIER
         {
            $$=new arrow_astnode($1,new identifier_astnode($3));
            if($1->type.substr(0,6)!="struct" || $1->deref+$1->array.size()+$1->adr!=1)         
            {
               //cout<<"type is "<<$1->type<<" "<<$1->deref<<" "<<$1->array.size()<<" "<<$1->adr<<endl;
               string err="Left operand of \"->\" is not a pointer to structure";
               error(@$,err);
            }
            Entry *st=gst.search($1->type);
             if(st==NULL)
             {
               string err="\""+print_type($1->type,$1->deref,$1->array,$1->adr)+"\" is not defined";
               error(@$,err);
             }
             SymbolTable *curr_symb=st->symbtab;
            if(curr_symb->Entries.find($3)==curr_symb->Entries.end())
            {
               string err="\""+$3+"\" is not a member of \""+print_type($1->type,$1->deref,$1->array,$1->adr)+"\"";
               error(@$,err);
            }
            Entry *st1=curr_symb->search($3);
            pair<string,pair<int,vector<int>>> p=get_type(st1->type);
            $$->type=p.first;
            $$->deref=p.second.first;
            $$->array=p.second.second;
            $$->lvalue=true;
            $$->adr=0;
            $$->is_const=false;
         }
         | postfix_expression INC_OP
         {
            $$=new op_unary_astnode("PP",$1);
            $$->label_l = $1->label_l;
            $$->label_r = $1->label_l;
            $1->label_r = $1->label_l;
            if($1->lvalue==false)
            {
               string err="Operand of \"++\" should have lvalue";
               error(@$,err);
            }
            if($1->type!="int" && $1->type!="float")
            {
               if($1->deref+$1->array.size()+$1->adr==0)
               {
                  string err="Operand of \"++\" should be a int, float or pointer";
                  error(@$,err);
               }
            }
            if($1->array.size())
            {
               string err="Operand of \"++\" should be a int, float or pointer";
                  error(@$,err);
            }
            $$->type=$1->type;
            $$->deref=$1->deref;
            $$->array=$1->array;
            $$->lvalue=false;
            $$->adr=0;
            $$->is_const=false;
         }
         ;
/* it is done and tested */
primary_expression:
       IDENTIFIER
       { 
         $$=new identifier_astnode($1);
         $$->label_l = 1;
         $$->label_r = 0;
         
         if(curr_symbtab->Entries.find($1)!=curr_symbtab->Entries.end())
         {
            pair<string,pair<int,vector<int>>> p=get_type(curr_symbtab->Entries[$1].type);
            $$->type=p.first;
            $$->lvalue=true;
            $$->deref=p.second.first;
            $$->array=p.second.second;
            $$->adr=0;
         }
         else
         {
            string err="Variable \""+string($1)+"\" not declared";
            error(@$,err);
         }
       }
       | INT_CONST
       { 
         $$=new intconst_astnode(stoi($1));
         $$->label_l = 1;
         $$->label_r = 0;
         $$->type="int";
         $$->lvalue=false;
         $$->deref=0;
         $$->const_val=stoi($1);
         $$->is_const=true;
       }
       | FLOAT_CONST
       { 
         $$=new floatconst_astnode(stof($1));
         $$->type="float";
         $$->lvalue=false;
         $$->deref=0;
       }
       | STRING_LITERAL
       {
         $$=new stringconst_astnode($1);
         $$->label_l = 1;
         $$->label_r = 0;
         $$->type="string";
         $$->lvalue=false;
         $$->deref=0;
       }
       | '(' expression ')'
       {
         $$=$2;
         $$->label_l = $2->label_l;
         $$->label_r = $2->label_r;
       }
       ;

expression_list: 
            expression
            {
               $$=new vector<exp_astnode*>();
               $$->push_back($1);
            }
            | expression_list ',' expression
            {
               $$=$1;
               $$->push_back($3);
            }
            ;

unary_operator:
            '-'
         {
            $$=new op_unary_astnode();
            $$->op="UMINUS";
         }
         | '!'
         {
            $$=new op_unary_astnode();
            $$->op="NOT";
         }
         | '&'
         {
            $$=new op_unary_astnode();
            $$->op="ADDRESS";
         }
         | '*'
         {
            $$=new op_unary_astnode();
            $$->op="DEREF";
         }
         ;

selection_statement: 
         IF '(' expression ')' statement ELSE statement
         {
            $$=new if_astnode($3,$5,$7);
         }
         ;

iteration_statement:
         WHILE '(' expression ')' statement
         {
            $$=new while_astnode($3,$5);            
         }
         | FOR '(' assignment_expression ';' expression ';' assignment_expression ')' statement
         {
            $$=new for_astnode($3,$5,$7,$9);
         };
      
%%
void 
IPL::Parser::error( const location_type &l, const std::string &err_message )
{
      std::cout << "Error at line " << l.begin.line << ": " << err_message <<
 "\n";
   exit(1);
}
