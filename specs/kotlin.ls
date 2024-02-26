use Symbol;
use SymbolTable;
use Type;

class Program {
  prog("${decls : OptionalGlobalDeclarationList}
  ${main : MainDeclaration}\n") {
    decls.symbols_before = (SymbolTable:empty);
    main.symbols_before = decls.symbols_after;
  }
}

class OptionalGlobalDeclarationList {

  inh symbols_before : SymbolTable;

  syn symbols_after : SymbolTable;
  
  no_decls ("") {
    this.symbols_after = this.symbols_before;
  }

  @weight(100)
  decls ("${decls : GlobalDeclarationList}\n") {
    decls.symbols_before = this.symbols_before;
    this.symbols_after = decls.symbols_after;
  }

}

@list(200)
class GlobalDeclarationList {

  syn symbols_after : SymbolTable;

  inh symbols_before : SymbolTable;

  @weight(1)
  one_decl ("${decl : GlobalDeclaration}") {
    decl.symbols_before = this.symbols_before;
    this.symbols_after = decl.symbols_after;
  }

  @weight(10)
  mult_decl ("${decl : GlobalDeclaration}\n
              ${rest : GlobalDeclarationList}") {
    decl.symbols_before = this.symbols_before;

    rest.symbols_before = decl.symbols_after;

    this.symbols_after = rest.symbols_after;
  }

}

class GlobalDeclaration {

  syn symbols_after : SymbolTable;

  inh symbols_before : SymbolTable;

  @weight(2)
  global_func_decl ("${func_decl : FunctionDeclaration}") {
    func_decl.symbols_before = this.symbols_before;
    this.symbols_after = (SymbolTable:put this.symbols_before func_decl.symbol);
  }

}

class FunctionDeclaration {

  syn symbol : Symbol;

  inh symbols_before : SymbolTable;

  func_decl_expr
      ("fun ${name : DefIdentifier}(${params : ParameterDeclarationList})${ret_type : OptionalTypeAnnotation} = ${expr: Expr}") {
      
    params.symbols_before = (SymbolTable:enterScope this.symbols_before);
    expr.symbols_before = params.symbols_after;
    expr.expected_type = (if ret_type.has_type ret_type.type (Type:anyType));
    name.symbols_before = this.symbols_before;
    this.symbol = (Symbol:create name.name (Type:createFunctionType (if ret_type.has_type ret_type.type expr.type) params.type) false true);
  }

  func_decl
      ("fun ${name : DefIdentifier}(${params : ParameterDeclarationList})${ret_type : OptionalTypeAnnotation} {\+
          ${body : FunctionBody}\-
        }\n") {
    loc actual_ret_type = (if ret_type.has_type ret_type.type (Type:unitType));
    params.symbols_before = (SymbolTable:enterScope this.symbols_before);
    body.symbols_before = params.symbols_after;
    body.expected_return_type = .actual_ret_type;
    name.symbols_before = this.symbols_before;
    this.symbol = (Symbol:create name.name (Type:createFunctionType .actual_ret_type params.type) false true);
  }

}

@list(10)
class ParameterDeclarationList {

  syn type : Type;
  syn symbols_after : SymbolTable;

  inh symbols_before : SymbolTable;

  one_param ("${param : ParameterDeclaration}") {
    param.symbols_before = this.symbols_before;
    this.symbols_after = (SymbolTable:put this.symbols_before param.symbol);
    this.type = (Type:createTupleType (Symbol:getType param.symbol));
  }

  mult_param ("${param : ParameterDeclaration}, ${rest : ParameterDeclarationList}") {
    param.symbols_before = this.symbols_before;
    rest.symbols_before = (SymbolTable:put this.symbols_before param.symbol);
    this.symbols_after = rest.symbols_after;
    this.type =
      (Type:mergeTupleTypes (Type:createTupleType (Symbol:getType param.symbol)) rest.type);
  }

}

class ParameterDeclaration {

  syn symbol : Symbol;

  inh symbols_before : SymbolTable;

  @copy
  param_decl ("${name : DefIdentifier}: ${type : Type}") {
    name.symbols_before = this.symbols_before;
    this.symbol = (Symbol:create name.name type.type false true);
  }

}

class MainDeclaration {
  inh symbols_before : SymbolTable;

  main ("fun main() {\+${body : FunctionBody}\-}\n") {
    body.symbols_before = (SymbolTable:enterScope this.symbols_before);
    body.expected_return_type = (Type:unitType);
  }
}

class FunctionBody {
  inh symbols_before : SymbolTable;
  inh expected_return_type : Type;

  body ("
      ${stmts : OptionalStmtList}
      ${ret : OptionalReturnStatement}") {

    stmts.symbols_before = this.symbols_before;
    stmts.expected_return_type = this.expected_return_type;
    
    ret.symbols_before = stmts.symbols_after;    
    ret.expected_return_type = this.expected_return_type;
  }
}

class OptionalStmtList {

  inh symbols_before : SymbolTable;
  inh expected_return_type : Type;

  syn symbols_after: SymbolTable;


  no_stmts ("") {
    this.symbols_after = this.symbols_before;
  }

  @weight(100)
  stmts ("${stmts : StmtList}") {
    stmts.symbols_before = this.symbols_before;
    stmts.expected_return_type = this.expected_return_type;

    this.symbols_after = stmts.symbols_after;
  }

}

@list(200)
class StmtList {

  inh symbols_before : SymbolTable;
  inh expected_return_type : Type;

  syn symbols_after : SymbolTable;

  @weight(2)
  one_stmt ("${stmt : Stmt}") {
    stmt.symbols_before = this.symbols_before;
    stmt.expected_return_type = this.expected_return_type;
    
    this.symbols_after = stmt.symbols_after;
  }

  @weight(100)
  mult_stmt ("${stmt : Stmt}\n${rest : StmtList}") {
    stmt.symbols_before = this.symbols_before;
    stmt.expected_return_type = this.expected_return_type;

    rest.symbols_before = stmt.symbols_after;
    rest.expected_return_type = this.expected_return_type;
    
    this.symbols_after = rest.symbols_after;
  }

}

class Stmt {

  inh symbols_before : SymbolTable;
  inh expected_return_type : Type;

  syn symbols_after : SymbolTable;

  grd possible;

  call ("${call : Call}") {
    this.possible = true;

    call.expected_type = (Type:anyType);
    call.symbols_before = this.symbols_before;

    this.symbols_after = this.symbols_before;
  }

  assign ("${assign : AssignStmt}") {
    this.possible = true;

    assign.symbols_before = this.symbols_before;

    this.symbols_after = assign.symbols_after;
  }

  print ("${print : Print}") {
    this.possible = true;

    print.symbols_before = this.symbols_before;
    
    this.symbols_after = this.symbols_before;
  }

  var_decl("${decl : VariableDeclaration}\n") {
    this.possible = true;

    decl.symbols_before = this.symbols_before;

    this.symbols_after = (SymbolTable:put this.symbols_before decl.symbol);
  }

  @weight(4)
  if_then ("if (${cond : Condition}) {\+${then : StmtList}\-}") {
    this.possible = true;

    cond.symbols_before = this.symbols_before;
    then.symbols_before = this.symbols_before;
    then.expected_return_type = this.expected_return_type;

    this.symbols_after = this.symbols_before;
  }

  @weight(4)
  if_then_else ("if (${cond : Condition}) {\+${then : StmtList}\-} else {\+${else : OptionalStmtList}\-}") {
    this.possible = true;

    cond.symbols_before = this.symbols_before;
    then.symbols_before = this.symbols_before;
    then.expected_return_type = this.expected_return_type;
    else.symbols_before = this.symbols_before;
    else.expected_return_type = this.expected_return_type;

    this.symbols_after = this.symbols_before;
  }

  @weight(4)
  while ("while (${cond : Condition}) {\+${body : StmtList}\-}") {
    this.possible = true;

    cond.symbols_before = this.symbols_before;
    body.symbols_before = this.symbols_before;
    body.expected_return_type = this.expected_return_type;

    this.symbols_after = this.symbols_before;
  }

  @weight(30)
  for ("for (${var : DefIdentifier}: Int in ${lo : Expr}..${hi : Expr}) {\+${body : StmtList}\-}") {
    loc var_symbol = (Symbol:create var.name (Type:intType) false true);
    this.possible = true;

    var.symbols_before = this.symbols_before;


    lo.symbols_before = this.symbols_before;
    lo.expected_type = (Type:intType);

    hi.symbols_before = this.symbols_before;
    hi.expected_type = (Type:intType);

    body.symbols_before = (SymbolTable:put this.symbols_before .var_symbol);
    body.expected_return_type = this.expected_return_type;

    this.symbols_after = this.symbols_before;
  }

}

class Condition {

  inh symbols_before : SymbolTable;

  cond_expr ("${expr : Expr}") {
    expr.symbols_before = this.symbols_before;
    expr.expected_type = (Type:booleanType);
  }

}

class Call {

  inh symbols_before : SymbolTable;
  inh expected_type : Type;

  syn type : Type;

  call ("${callee : Callee}(${args : ArgumentList})") {
    loc callee_type = (Symbol:getType callee.symbol);

    args.expected_type = (Type:getParameterType .callee_type);
    args.symbols_before = this.symbols_before;

    callee.symbols_before = this.symbols_before;
    callee.expected_return_type = this.expected_type;

    this.type = (Type:getReturnType .callee_type);
  }

}

@list
class ArgumentList {

  inh symbols_before : SymbolTable;
  inh expected_type : Type;

  grd valid;

  one_arg ("${val : Expr}") {
    val.expected_type = (Type:getTupleTypeHead this.expected_type);
    val.symbols_before = this.symbols_before;

    this.valid = (== (Type:getTupleTypeSize this.expected_type) 1);
  }

  mult_arg ("${val : Expr}, ${rest : ArgumentList}") {
    val.expected_type = (Type:getTupleTypeHead this.expected_type);
    val.symbols_before = this.symbols_before;
    rest.expected_type = (Type:getTupleTypeTail this.expected_type);
    rest.symbols_before = this.symbols_before;

    this.valid = (> (Type:getTupleTypeSize this.expected_type) 1);
  }

}

class Callee {

  inh symbols_before : SymbolTable;
  inh expected_return_type : Type;

  syn symbol : Symbol;

  grd valid;
  grd type_matches;

  @copy
  callee ("${func : UseIdentifier}") {
    loc func_type = (Symbol:getType func.symbol);

    func.expected_type = nil;
    func.symbols_before = this.symbols_before;

    this.symbol = func.symbol;

    this.valid = (Type:isFunctionType .func_type);

    this.type_matches =
      (Type:assignable (Type:getReturnType .func_type) this.expected_return_type);
  }

}

class AssignStmt {

  inh symbols_before : SymbolTable;

  syn symbols_after : SymbolTable;

  grd valid;

  assign ("${lhs : UseIdentifier} = ${rhs : Expr}") {
    lhs.expected_type = (Type:anyType);
    lhs.symbols_before = this.symbols_before;

    this.valid = (Symbol:getIsMutable lhs.symbol);

    rhs.expected_type = (Symbol:getType lhs.symbol);
    rhs.symbols_before = this.symbols_before;

    this.symbols_after = (SymbolTable:setIsInitialised this.symbols_before lhs.symbol true);
  }
}

class VariableDeclaration {

  grd valid;

  syn symbol : Symbol;

  inh symbols_before : SymbolTable;

  var_decl ("${mod: VariableModifier} ${name : DefIdentifier}${type : OptionalTypeAnnotation} ${init : OptionalVariableInitialiation}") {
    init.symbols_before = this.symbols_before;
    init.expected_type = type.type;

    name.symbols_before = this.symbols_before;

    this.valid = (or type.has_type init.isInitialised);

    this.symbol = (Symbol:create name.name (if type.has_type type.type init.type) mod.is_mutable init.isInitialised);
  }
}

class DefIdentifier {

  inh symbols_before : SymbolTable;

  syn name : String;

  grd name_unique;

  def_id ("${id : Identifier}") {
    this.name = id.str;
    this.name_unique = (SymbolTable:mayDefine this.symbols_before id.str);
  }

}

@count(1000)
class Identifier("[a-z][a-zA-Z_]{1,7}");

class OptionalVariableInitialiation {
  inh expected_type : Type;
  inh symbols_before : SymbolTable;

  syn isInitialised : boolean;
  syn type : Type;

  no_init("") {
    this.isInitialised = false;
    this.type = (Type:anyType);
  }

  init("= ${expr : Expr}") {
    expr.symbols_before = this.symbols_before;
    expr.expected_type = this.expected_type;

    this.isInitialised = true;
    this.type = expr.type;
  }
}

class OptionalTypeAnnotation {
  syn type : Type;
  syn has_type : boolean;

  no_type_annotation("") {
    this.type = (Type:anyType);
    this.has_type = false;
  }

  type_annotation(": ${type: Type}") {
    this.type = type.type;
    this.has_type = true;
  }
}

class Type {
  syn type : Type;

  atomic_type ("${type : AtomicType}") {
    this.type = type.type;
  }
}

class AtomicType {
  syn type : Type;

  int_type("Int") {
    this.type = (Type:intType);
  }

  boolean_type("Boolean") {
    this.type = (Type:booleanType);
  }

  char_type("Char") {
    this.type = (Type:charType);
  }

  string_type("String") {
    this.type = (Type:stringType);
  }

  unit_type("Unit") {
    this.type = (Type:unitType);
  }

  any_type("Any") {
    this.type = (Type:anyType);
  }
}

class VariableModifier {
  syn is_mutable : boolean;

  var("var") {
    this.is_mutable = true;
  }

  val("val") {
    this.is_mutable = false;
  }
}

class Print {
  inh symbols_before : SymbolTable;

  print ("print (${expr: Expr})") {
    expr.symbols_before = this.symbols_before;
    expr.expected_type = (Type:anyType);
  }
}

class OptionalReturnStatement {
  grd valid;

  inh symbols_before : SymbolTable;
  inh expected_return_type : Type;

  no_ret ("") {
    this.valid = (Type:is (Type:unitType) this.expected_return_type);
  }

  ret ("\n${ret : ReturnStatement}") {
    this.valid = true;
    ret.symbols_before = this.symbols_before;
    ret.expected_return_type = this.expected_return_type;
  }

}

class ReturnStatement {
  grd valid;

  inh symbols_before : SymbolTable;
  inh expected_return_type : Type;

  ret_void ("return") {
    this.valid = (Type:is (Type:unitType) this.expected_return_type);
  }

  ret_val ("return ${val : Expr}") {
    this.valid = (not (Type:is (Type:unitType) this.expected_return_type));

    val.expected_type = this.expected_return_type;
    val.symbols_before = this.symbols_before;
  }
}

@max_height(8)
class Expr {
  inh symbols_before : SymbolTable;
  inh expected_type : Type;

  syn type : Type;

  grd valid;
  grd valid2;

  @weight(10)
  atom ("${atom : ExprAtom}") {
    this.valid = true;
    this.valid2 = true;

    atom.symbols_before = this.symbols_before;
    atom.expected_type = this.expected_type;

    this.type = atom.type;
  }
  if ("(if (${if : Expr}) (${then : Expr}) else (${else: Expr}))") {
    this.valid = true;
    this.valid2 = true;

    if.symbols_before = this.symbols_before;
    if.expected_type = (Type:booleanType);

    then.symbols_before = this.symbols_before;
    then.expected_type = this.expected_type;

    else.symbols_before = this.symbols_before;
    else.expected_type = then.type;

    this.type = then.type;
  }
  arith_bin_op ("(${lhs : Expr}) ${op : ArithBinaryOperator} (${rhs : Expr})") {
    this.valid2 = true;

    lhs.symbols_before = this.symbols_before;
    lhs.expected_type = (Type:intType);

    rhs.symbols_before = this.symbols_before;
    rhs.expected_type = (Type:intType);

    this.valid = (Type:assignable (Type:intType) this.expected_type);
    this.type = (Type:intType);
  }

  bool_bin_op ("(${lhs : Expr}) ${op : BoolBinaryOperator} (${rhs : Expr})") {
    this.valid2 = true;

    lhs.symbols_before = this.symbols_before;
    lhs.expected_type = (Type:booleanType);

    rhs.symbols_before = this.symbols_before;
    rhs.expected_type = (Type:booleanType);

    this.valid = (Type:assignable (Type:booleanType) this.expected_type);
    this.type = (Type:booleanType);
  }

  bool_unary_op ("${op: BoolUnaryOperator}(${exp: Expr})") {
    this.valid2 = true;

    exp.symbols_before = this.symbols_before;
    exp.expected_type = (Type:booleanType);

    this.valid = (Type:assignable (Type:booleanType) this.expected_type);
    this.type = (Type:booleanType);
  }

  equality_bin_op ("(${lhs : Expr}) ${op : EqualityOp} (${rhs : Expr})") {
    this.valid2 = true;

    lhs.symbols_before = this.symbols_before;
    lhs.expected_type = (Type:anyType);

    rhs.symbols_before = this.symbols_before;
    rhs.expected_type = lhs.type;

    this.valid = (Type:assignable (Type:booleanType) this.expected_type);
    this.type = (Type:booleanType);
  }

  comparison_bin_op ("(${lhs: Expr}) ${op : ComparisonOp} (${rhs : Expr})") {
    lhs.symbols_before = this.symbols_before;
    lhs.expected_type = (Type:anyType);
    
    this.valid2 = (not (Type:is lhs.type (Type:anyType)));

    rhs.symbols_before = this.symbols_before;
    rhs.expected_type = lhs.type;

    this.valid = (Type:assignable (Type:booleanType) this.expected_type);
    this.type = (Type:booleanType);
  }
}

class ArithBinaryOperator("+|-|*|/|%");

class BoolBinaryOperator("&&|[|][|]");

class BoolUnaryOperator("!");

class EqualityOp("==|!=");

class ComparisonOp(">|>=|<|<=");

class ExprAtom {
  inh symbols_before : SymbolTable;
  inh expected_type : Type;

  grd valid;

  syn type : Type;

  call ("${call : Call}") {
    this.valid = true;
    call.expected_type = this.expected_type;
    call.symbols_before = this.symbols_before;

    this.type = call.type;
  }

  num ("${val : Number}") {
    this.valid = true;

    val.expected_type = this.expected_type;
    this.type = val.type;
  }

  string_literal ("${str: StringLiteral}") {
    loc type = (Type:stringType);
    this.valid = (Type:assignable .type this.expected_type);

    this.type = .type;
  }

  boolean_literal ("${bool: BooleanLiteral}") {
    loc type = (Type:booleanType);
    this.valid = (Type:assignable .type this.expected_type);

    this.type = .type;
  }

  char_literal ("${char: CharLiteral}") {
    loc type = (Type:charType);
    this.valid = (Type:assignable .type this.expected_type);

    this.type = .type;
  }

  var ("${name : UseIdentifier}") {  
    loc type = (Symbol:getType name.symbol);
    name.symbols_before = this.symbols_before;
    name.expected_type = this.expected_type;

    this.type = .type;

    this.valid = (and (Symbol:getIsInitialised name.symbol) (not (Type:isFunctionType .type)));
  }

}

class BooleanLiteral("false|true");

class StringLiteral("\"[a-zA-Z0-9]{0,15}\"");

class CharLiteral("\'[a-zA-Z0-9]\'");

class UseIdentifier {

  inh symbols_before : SymbolTable;
  inh expected_type : Type;

  syn symbol : Symbol;

  use_id (SymbolTable:visibleIdentifiers this.symbols_before this.expected_type) : String {
    this.symbol = (SymbolTable:get this.symbols_before $);
  }

}

class Number {

  inh expected_type : Type;
  syn type : Type;

  grd type_matches;

  int_number ("${num : IntNumber}") {
    loc type = (Type:intType);
    this.type_matches = (Type:assignable .type this.expected_type);
    this.type = .type;
  }
}

class IntNumber("0|[1-9][0-9]{0,8}");