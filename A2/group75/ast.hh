#ifndef TYPES_HH
#define TYPES_HH
#include <iostream>
#include <vector>
#include "type.hh"
using namespace std;
enum typeExp
{
  ABSTRACT,
  STATEMENT,
  EXP,
  EMPTY,
  SEQ,
  ASSIGNS,
  RETURN,
  PROCCALL,
  IF,
  WHILE,
  FOR,
  OP_BINARY,
  OP_UNARY,
  ASSIGNE,
  FUNCALL,
  INTCONST,
  FLOATCONST,
  STRINGCONST,
  POINTERS,
  REF,
  MEMBER,
  IDENTIFIER,
  ARROW,
  ARRAYREF
};
//  In general a group of non-terminals may share the same set of attributes

class abstract_astnode
{
public:  
  bool is_calculatable;
  int int_val;
  bool lvalue;
  string type;
  int deref;
  int adr=0;
  int const_val;
  bool is_const=false;
  vector<int> array;
  enum typeExp astnode_type;
  int ptr=0;
  abstract_astnode()
  {
    astnode_type = ABSTRACT;
  }
  virtual void print(int blanks) = 0;
};

class statement_astnode : public abstract_astnode
{
public:
  virtual void print(int blanks) = 0;
  statement_astnode()
  {
    astnode_type = STATEMENT;
  }
};

class exp_astnode : public abstract_astnode
{
public:
  exp_astnode()
  {
    astnode_type = EXP;
    }
  virtual void print(int blanks) = 0;
};

class empty_astnode : public statement_astnode
{
public:
  empty_astnode()
  {
    astnode_type = EMPTY;
  }
  void print(int blanks);
};

class seq_astnode : public statement_astnode
{
public:
  vector<statement_astnode *> seq;
  seq_astnode()
  {
    astnode_type = SEQ;
  }
  seq_astnode(vector<statement_astnode *> seq)
  {
    astnode_type = SEQ;
    this->seq = seq;
  }
  void print(int blanks);
};

class assignS_astnode : public statement_astnode
{
public:
  exp_astnode *left;
  exp_astnode *right;
  assignS_astnode(exp_astnode *left, exp_astnode *right)
  {
    astnode_type = ASSIGNS;
    this->left = left;
    this->right = right;
  }
  assignS_astnode()
  {
    astnode_type = ASSIGNS;
  }
  void print(int blanks);
};

class return_astnode : public statement_astnode
{
public:
  exp_astnode *ret;
  return_astnode(exp_astnode *ret)
  {
    astnode_type = RETURN;
    this->ret = ret;
  }
  return_astnode()
  {
    astnode_type = RETURN;
  }
void print(int blanks);
};

class proccall_astnode : public statement_astnode
{
public:
  vector<exp_astnode *> params;
  proccall_astnode(vector<exp_astnode *> params)
  {
    astnode_type = PROCCALL;
    this->params = params;
  }
  proccall_astnode()
  {
    astnode_type = PROCCALL;
  }
  void print(int blanks);
};

class if_astnode : public statement_astnode
{
public:
  exp_astnode *cond;
  statement_astnode *then;
  statement_astnode *els;
  if_astnode(exp_astnode *cond, statement_astnode *then, statement_astnode *els)
  {
    astnode_type = IF;
    this->cond = cond;
    this->then = then;
    this->els = els;
  }
  if_astnode()
  {
    astnode_type = IF;
  }
  void print(int blanks);
};

class while_astnode : public statement_astnode
{
public:
  exp_astnode *cond;
  statement_astnode *stmt;
  while_astnode(exp_astnode *cond, statement_astnode *stmt)
  {
    astnode_type = WHILE;
    this->cond = cond;
    this->stmt = stmt;
  }
  while_astnode()
  {
    astnode_type = WHILE;
  }
  void print(int blanks);
};

class for_astnode : public statement_astnode
{
public:
  exp_astnode *init;
  exp_astnode *guard;
  exp_astnode *step;
  statement_astnode *body;
  for_astnode(exp_astnode *init, exp_astnode *guard, exp_astnode *step, statement_astnode *body)
  {
    astnode_type = FOR;
    this->init = init;
    this->guard = guard;
    this->step = step;
    this->body = body;
  }
  for_astnode()
  {
    astnode_type = FOR;
  }
  void print(int blanks);
};

class op_binary_astnode : public exp_astnode
{
public:
  string op;
  exp_astnode *left;
  exp_astnode *right;
  op_binary_astnode(string op, exp_astnode *left, exp_astnode *right)
  {
    astnode_type = OP_BINARY;
    this->op = op;
    this->left = left;
    this->right = right;
  }
  op_binary_astnode()
  {
    astnode_type = OP_BINARY;
  }
  void print(int blanks);
};

class op_unary_astnode : public exp_astnode
{
public:
  string op;
  exp_astnode *child;
  op_unary_astnode(string op, exp_astnode *child)
  {
    astnode_type = OP_UNARY;
    this->op = op;
    this->child = child;
  }
  op_unary_astnode()
  {
    astnode_type = OP_UNARY;
  }
  void print(int blanks);
};

class assignE_astnode : public exp_astnode
{
public:
  exp_astnode *left;
  exp_astnode *right;
  assignE_astnode(exp_astnode *left, exp_astnode *right)
  {
    astnode_type = ASSIGNE;
    this->left = left;
    this->right = right;
  }
  assignE_astnode()
  {
    astnode_type = ASSIGNE;
  }
  void print(int blanks);
};

class funcall_astnode : public exp_astnode
{
public:
  vector<exp_astnode *> params;
  funcall_astnode(vector<exp_astnode *> params)
  {
    astnode_type = FUNCALL;
    this->params = params;
  }
  funcall_astnode()
  {
    astnode_type = FUNCALL;
  }
  void print(int blanks);
};

class intconst_astnode : public exp_astnode
{
public:
  int value;
  intconst_astnode(int value)
  {
    astnode_type = INTCONST;
    this->value = value;
  }
  intconst_astnode()
  {
    astnode_type = INTCONST;
  }
  void print(int blanks);
};

class floatconst_astnode : public exp_astnode
{
public:
  float value;
  floatconst_astnode(float value)
  {
    astnode_type = FLOATCONST;
    this->value = value;
  }
  floatconst_astnode()
  {
    astnode_type = FLOATCONST;
  }
  void print(int blanks);
};

class stringconst_astnode : public exp_astnode
{
public:
  string value;
  stringconst_astnode(string value)
  {
    astnode_type = STRINGCONST;
    this->value = value;
  }
  stringconst_astnode()
  {
    astnode_type = STRINGCONST;
  }
  void print(int blanks);
};

class ref_astnode : public exp_astnode
{
public:
  ref_astnode()
  {
    astnode_type = REF;
  }
  virtual void print(int blanks) = 0;
};

class identifier_astnode : public ref_astnode
{
public:
  string name;
  identifier_astnode(string name)
  {
    astnode_type = IDENTIFIER;
    this->name = name;
  }
  identifier_astnode()
  {
    astnode_type = IDENTIFIER;
  }
  void print(int blanks);
};

class member_astnode : public ref_astnode
{
public:
  exp_astnode *structname;
  identifier_astnode *field;
  member_astnode(exp_astnode *structname, identifier_astnode *field)
  {
    astnode_type = MEMBER;
    this->structname = structname;
    this->field = field;
  }
  member_astnode()
  {
    astnode_type = MEMBER;
  }
  void print(int blanks);
};

class arrow_astnode : public ref_astnode
{
public:
  exp_astnode *pointer;
  identifier_astnode *field;
  arrow_astnode(exp_astnode *pointer, identifier_astnode *field)
  {
    astnode_type = ARROW;
    this->pointer = pointer;
    this->field = field;
  }
  arrow_astnode()
  {
    astnode_type = ARROW;
  }
  void print(int blanks);
};

class arrayref_astnode : public ref_astnode
{
public:
  exp_astnode *array;
  exp_astnode *index;
  arrayref_astnode(exp_astnode *array, exp_astnode *index)
  {
    astnode_type = ARRAYREF;
    this->array = array;
    this->index = index;
  }
  arrayref_astnode()
  {
    astnode_type = ARRAYREF;
  }
  void print(int blanks);
};

#endif /* TYPE_H_ */
