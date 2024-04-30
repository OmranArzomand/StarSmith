use Symbol;
use SymbolTable;
use Type;
use AnyType;
use BooleanType;
use CharType;
use Function;
use IntType;
use CustomList;
use StringType;
use UnitType;
use Variable;

class Program {
  prog("${decls : OptionalGlobalDeclarationList}
  ${main : MainDeclaration}\n") {
    decls.symbols_before = (SymbolTable:init);
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

  global_func_decl ("${func_decl : FunctionDeclaration}") {
    func_decl.symbols_before = this.symbols_before;
    this.symbols_after = (SymbolTable:put this.symbols_before func_decl.symbol);
  }

  @weight(10)
  global_class_decl("${class_decl : ClassDeclaration}") {
    class_decl.symbols_before = this.symbols_before;
    this.symbols_after = (SymbolTable:put this.symbols_before class_decl.symbol);
  }
}

class ClassDeclaration {
  syn symbol : Type;
  inh symbols_before : SymbolTable;

  class_decl("class ${ident : DefIdentifier}${primary_constructor : OptionalPrimaryConstructor} {\+${body : ClassMemberList}\-}\n") {
    ident.symbols_before = this.symbols_before;
    primary_constructor.symbols_before = (SymbolTable:enterScope this.symbols_before);
    body.symbols_before = primary_constructor.symbols_after;
    body.primary_constructor = primary_constructor.params;
    body.constructors_before = (CustomList:empty);
    body.properties_before = primary_constructor.properties;
    body.member_functions_before = (CustomList:empty);
    body.class_name = ident.name;
    this.symbol = (Type:create ident.name (CustomList:prepend body.constructors_after primary_constructor.params) body.properties_after body.member_functions_after);
  }
}

class ClassMemberList {
  inh symbols_before : SymbolTable;
  inh constructors_before : CustomList;
  inh properties_before : CustomList;
  inh primary_constructor : CustomList;
  inh member_functions_before : CustomList;
  inh class_name : String;

  syn properties_after : CustomList;
  syn symbols_after : SymbolTable;
  syn member_functions_after : CustomList;
  syn constructors_after : CustomList;

  member ("${member : ClassMember}") {
    member.symbols_before = this.symbols_before;
    member.properties_before = this.properties_before;
    member.constructors_before = this.constructors_before;
    member.member_functions_before = this.member_functions_before;
    member.primary_constructor = this.primary_constructor;
    member.class_name = this.class_name;

    this.properties_after = member.properties_after;
    this.symbols_after = member.symbols_after;
    this.member_functions_after = member.member_functions_after;
    this.constructors_after = member.constructors_after;
  } 

  @weight(100)
  mult_members ("${member : ClassMember}\n${rest : ClassMemberList}") {
    member.symbols_before = this.symbols_before;
    member.properties_before = this.properties_before;
    member.constructors_before = this.constructors_before;
    member.member_functions_before = this.member_functions_before;
    member.primary_constructor = this.primary_constructor;
    member.class_name = this.class_name;

    rest.symbols_before = member.symbols_after;
    rest.properties_before = member.properties_after;
    rest.constructors_before = member.constructors_after;
    rest.member_functions_before = member.member_functions_after;
    rest.primary_constructor = this.primary_constructor;
    rest.class_name = this.class_name;

    this.symbols_after = rest.symbols_after;
    this.properties_after = rest.properties_after;
    this.member_functions_after = rest.member_functions_after;
    this.constructors_after = rest.constructors_after;
  }
}

class ClassMember {
  grd valid;

  inh symbols_before : SymbolTable;
  inh constructors_before : CustomList;
  inh properties_before : CustomList;
  inh member_functions_before : CustomList;
  inh primary_constructor : CustomList;
  inh class_name : String;

  syn symbols_after : SymbolTable;
  syn properties_after : CustomList;
  syn member_functions_after : CustomList;
  syn constructors_after : CustomList;

  property ("${decl : VariableDeclaration}") {
    this.valid = true;

    decl.symbols_before = this.symbols_before;
    decl.must_initialise = true;
    this.properties_after = (CustomList:prepend this.properties_before decl.symbol);
    this.symbols_after = (SymbolTable:put this.symbols_before decl.symbol);
    this.member_functions_after = this.member_functions_before;
    this.constructors_after = this.constructors_before;
  }

  init ("init {\+${stmts : StmtList}\-}") {
    this.valid = true;

    stmts.symbols_before = (SymbolTable:enterScope this.symbols_before);

    this.properties_after = this.properties_before;
    this.symbols_after = this.symbols_before;
    this.member_functions_after = this.member_functions_before;
    this.constructors_after = this.constructors_before;
  }

  member_function ("${func : FunctionDeclaration}") {
    this.valid = true;

    func.symbols_before = (SymbolTable:removeNonProperties this.symbols_before this.primary_constructor this.properties_before);

    this.properties_after = this.properties_before;
    this.symbols_after = this.symbols_before;
    this.member_functions_after = (CustomList:prepend this.member_functions_before func.symbol);
    this.constructors_after = this.constructors_before;
  }

  secondary_constructor ("constructor (${params : ParameterDeclarationList})${delagation : OptionalConstructorDelegation} {\+${stmts : StmtList}\-}") {
    loc class_type = (Type:create this.class_name (CustomList:prepend this.constructors_before this.primary_constructor) this.properties_before this.member_functions_before);
    loc this_object = (Variable:create "this" .class_type true false);

    this.valid = (not (CustomList:contains (CustomList:prepend this.constructors_before this.primary_constructor) params.params));

    params.symbols_before = (SymbolTable:enterScope this.symbols_before);

    delagation.symbols_before = (SymbolTable:removeAll (SymbolTable:removeAll params.symbols_after this.primary_constructor) this.properties_before);
    delagation.constructors = this.constructors_before;
    delagation.primary_constructor = this.primary_constructor;

    stmts.symbols_before = (SymbolTable:put (SymbolTable:put (SymbolTable:removeNonProperties params.symbols_after this.primary_constructor this.properties_before) .class_type) .this_object);

    this.symbols_after = this.symbols_before;
    this.properties_after = this.properties_before;
    this.member_functions_after = this.member_functions_before;
    this.constructors_after = (CustomList:prepend this.constructors_before params.params);
  }
}

class OptionalConstructorDelegation {
  grd valid;
  inh symbols_before : SymbolTable;
  inh primary_constructor : CustomList;
  inh constructors : CustomList;

  no_delegation ("") {
    this.valid = (== this.primary_constructor nil);

  }

  delegation (": this(${args : ArgumentList})") {
    this.valid = (or (not (== this.primary_constructor nil)) (> (CustomList:getSize this.constructors) 0));

    args.symbols_before = this.symbols_before;
    args.expected_params = (CustomList:random (CustomList:prepend this.constructors this.primary_constructor));
  }
}

class OptionalPrimaryConstructor {
  inh symbols_before : SymbolTable;
  syn symbols_after : SymbolTable;
  syn params : CustomList;
  syn properties : CustomList;

  no_constructor("") {
    this.params = nil;
    this.properties = (CustomList:empty);
    this.symbols_after = this.symbols_before;
  }

  @weight(100)
  constructor("(${constructorList: ConstructorList})") {
    constructorList.symbols_before = this.symbols_before;
    this.symbols_after = constructorList.symbols_after;
    this.params = constructorList.params;
    this.properties = constructorList.properties;
  }
}

class ConstructorList {
  inh symbols_before : SymbolTable;
  syn symbols_after : SymbolTable;
  syn params : CustomList;
  syn properties : CustomList;

  no_param ("") {
    this.symbols_after = this.symbols_before;
    this.params = (CustomList:empty);
    this.properties = (CustomList:empty);
  }

  @weight(10)
  mult_param ("${param : ConstructorParameterDeclaration}, ${rest : ConstructorList}") {
    param.symbols_before = this.symbols_before;
    rest.symbols_before = (SymbolTable:put this.symbols_before param.symbol);
    this.symbols_after = rest.symbols_after;
    this.params = (CustomList:prepend rest.params param.symbol);
    this.properties = (if param.add_to_properties (CustomList:prepend rest.properties param.symbol) rest.properties);
  }
}

class ConstructorParameterDeclaration {
  inh symbols_before : SymbolTable;
  syn symbol : Variable;
  syn add_to_properties : boolean;

  no_property("${param : ParameterDeclaration}") {
    param.symbols_before = this.symbols_before;
    param.is_mutable = false;
    this.symbol = param.symbol;
    this.add_to_properties = false; 
  }

  val_property("val ${param : ParameterDeclaration}") {
    param.symbols_before = this.symbols_before;
    param.is_mutable = false;
    this.symbol = param.symbol;
    this.add_to_properties = true;
  }

  var_property("var ${param : ParameterDeclaration}") {
    param.symbols_before = this.symbols_before;
    param.is_mutable = true;
    this.symbol = param.symbol;
    this.add_to_properties = true;
  }
}

class FunctionDeclaration {

  syn symbol : Function;

  inh symbols_before : SymbolTable;

  func_decl_expr
      ("fun ${name : DefIdentifier}(${params : ParameterDeclarationList})${ret_type : OptionalTypeAnnotation} = ${expr: Expr}") {
      
    params.symbols_before = (SymbolTable:enterScope this.symbols_before);
    ret_type.symbols_before = this.symbols_before;
    expr.symbols_before = params.symbols_after;
    expr.expected_type = (if ret_type.has_type ret_type.type (SymbolTable:getAsType this.symbols_before (AnyType:name)));
    name.symbols_before = this.symbols_before;
    this.symbol = (Function:create name.name (if ret_type.has_type ret_type.type expr.type) params.params );
  }

  func_decl
      ("fun ${name : DefIdentifier}(${params : ParameterDeclarationList})${ret_type : OptionalTypeAnnotation} {\+
          ${body : FunctionBody}\-
        }\n") {
    loc actual_ret_type = (if ret_type.has_type ret_type.type (SymbolTable:getAsType this.symbols_before (UnitType:name)));
    ret_type.symbols_before = this.symbols_before;
    params.symbols_before = (SymbolTable:enterScope this.symbols_before);
    body.symbols_before = params.symbols_after;
    body.expected_return_type = .actual_ret_type;
    name.symbols_before = this.symbols_before;
    this.symbol = (Function:create name.name .actual_ret_type params.params);
  }

}

@list(10)
class ParameterDeclarationList {

  syn params : CustomList;
  syn symbols_after : SymbolTable;

  inh symbols_before : SymbolTable;

  one_param ("${param : ParameterDeclaration}") {
    param.symbols_before = this.symbols_before;
    param.is_mutable = false;
    this.symbols_after = (SymbolTable:put this.symbols_before param.symbol);
    this.params = (CustomList:create param.symbol);
  }

  mult_param ("${param : ParameterDeclaration}, ${rest : ParameterDeclarationList}") {
    param.symbols_before = this.symbols_before;
    param.is_mutable = false;
    rest.symbols_before = (SymbolTable:put this.symbols_before param.symbol);
    this.symbols_after = rest.symbols_after;
    this.params = (CustomList:prepend rest.params param.symbol);
  }

}

class ParameterDeclaration {

  syn symbol : Variable;

  inh symbols_before : SymbolTable;
  inh is_mutable : boolean;

  @copy
  param_decl ("${name : DefIdentifier}: ${type : Type}") {
    name.symbols_before = this.symbols_before;
    type.symbols_before = this.symbols_before;
    this.symbol = (Variable:create name.name type.type true this.is_mutable);
  }

}

class MainDeclaration {
  inh symbols_before : SymbolTable;

  main ("fun main() {\+${body : FunctionBody}\-}\n") {
    body.symbols_before = (SymbolTable:enterScope this.symbols_before);
    body.expected_return_type = (SymbolTable:getAsType this.symbols_before (UnitType:name));
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

    this.symbols_after = stmts.symbols_after;
  }

}

@list(200)
class StmtList {

  inh symbols_before : SymbolTable;

  syn symbols_after : SymbolTable;

  @weight(2)
  one_stmt ("${stmt : Stmt}") {
    stmt.symbols_before = this.symbols_before;
    
    this.symbols_after = stmt.symbols_after;
  }

  @weight(100)
  mult_stmt ("${stmt : Stmt}\n${rest : StmtList}") {
    stmt.symbols_before = this.symbols_before;

    rest.symbols_before = stmt.symbols_after;
    
    this.symbols_after = rest.symbols_after;
  }

}

class Stmt {

  inh symbols_before : SymbolTable;

  syn symbols_after : SymbolTable;

  grd possible;

  call ("${call : Call}") {
    this.possible = true;

    call.expected_type = (SymbolTable:getAsType this.symbols_before (AnyType:name));
    call.symbols_before = this.symbols_before;

    this.symbols_after = this.symbols_before;
  }

  member_function_call ("${member_function_call : MemberFunctionCall}") {
    this.possible = true;
    
    member_function_call.symbols_before = this.symbols_before;
    member_function_call.expected_type = (SymbolTable:getAsType this.symbols_before (AnyType:name));

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
    decl.must_initialise = false;

    this.symbols_after = (SymbolTable:put this.symbols_before decl.symbol);
  }

}

class MemberFunctionCall {
  inh symbols_before : SymbolTable;
  inh expected_type : Type;

  syn type : Type;

  member_function_call("${expr : Expr}.${member_function_callee : MemberFunctionCallee}(${args : ArgumentList})") {
    loc functionSymbol = member_function_callee.symbol;

    expr.symbols_before = this.symbols_before;
    expr.expected_type = this.expected_type;

    args.expected_params = (Function:getParams .functionSymbol);
    args.symbols_before = this.symbols_before;

    member_function_callee.symbols_before = this.symbols_before;
    member_function_callee.expected_return_type = this.expected_type;
    member_function_callee.callee_type = (SymbolTable:getAsType this.symbols_before (Symbol:getName expr.type));

    this.type = (Function:getReturnType .functionSymbol);

  }
}

class Call {

  inh symbols_before : SymbolTable;
  inh expected_type : Type;

  syn type : Type;

  call ("${callee : Callee}(${args : ArgumentList})") {
    loc functionSymbol = callee.symbol;

    args.expected_params = (Function:getParams .functionSymbol);
    args.symbols_before = this.symbols_before;

    callee.symbols_before = this.symbols_before;
    callee.expected_return_type = this.expected_type;

    this.type = (Function:getReturnType .functionSymbol);
  }

}

@list
class ArgumentList {

  inh symbols_before : SymbolTable;
  inh expected_params : CustomList;

  grd valid;

  no_arg ("") {
    this.valid = (== (CustomList:getSize this.expected_params) 0);
  }

  one_arg ("${val : Expr}") {
    this.valid = (== (CustomList:getSize this.expected_params) 1);

    val.expected_type = (Variable:getType (CustomList:asVariable (CustomList:getHead this.expected_params)));
    val.symbols_before = this.symbols_before;
  }

  mult_arg ("${val : Expr}, ${rest : ArgumentList}") {
    this.valid = (> (CustomList:getSize this.expected_params) 1);

    val.expected_type = (Variable:getType (CustomList:asVariable (CustomList:getHead this.expected_params)));
    val.symbols_before = this.symbols_before;
    rest.expected_params = (CustomList:getTail this.expected_params);
    rest.symbols_before = this.symbols_before;
  }

}

class MemberFunctionCallee {
  inh symbols_before : SymbolTable;
  inh expected_return_type : Type;
  inh callee_type : Type;

  syn symbol : Function;

  callee ("${member_function : UseMemberFunctionIdentifier}") {
    member_function.expected_return_type = this.expected_return_type;
    member_function.callee_type = this.callee_type;
    member_function.symbols_before = this.symbols_before;

    this.symbol = member_function.symbol;

  }
}

class Callee {

  inh symbols_before : SymbolTable;
  inh expected_return_type : Type;

  syn symbol : Function;


  callee ("${func : UseFunctionIdentifier}") {
    func.expected_return_type = this.expected_return_type;
    func.symbols_before = this.symbols_before;

    this.symbol = func.symbol;

  }

}

class AssignStmt {

  inh symbols_before : SymbolTable;

  syn symbols_after : SymbolTable;

  grd valid; 

  assign ("${lhs : AssignableExpr} = ${rhs : Expr}") {
    lhs.symbols_before = this.symbols_before;

    this.valid = (Variable:getIsMutable lhs.symbol);

    rhs.expected_type = (Variable:getType lhs.symbol);
    rhs.symbols_before = this.symbols_before;

    this.symbols_after = (if lhs.is_property this.symbols_before (SymbolTable:setIsInitialised this.symbols_before lhs.symbol true));
  }
}

class AssignableExpr {
  inh symbols_before : SymbolTable;

  syn symbol : Variable;
  syn is_property : Boolean;

  variable ("${var : UseVariableIdentifier}") {
    var.expected_type = (SymbolTable:getAsType this.symbols_before (AnyType:name));
    var.symbols_before = this.symbols_before;
    this.symbol = var.symbol;
    this.is_property = false;
  }

  property ("${classType : Expr}.${property : UsePropertyIdentifier}") {
    property.symbols_before = this.symbols_before;
    property.expected_type = (SymbolTable:getAsType this.symbols_before (AnyType:name));
    classType.symbols_before = this.symbols_before;
    classType.expected_type = property.classType;
    this.symbol = property.symbol;
    this.is_property = true;
  }
}

class VariableDeclaration {

  grd valid;
  
  syn symbol : Variable;

  inh symbols_before : SymbolTable;
  inh must_initialise : boolean;

  var_decl ("${mod: VariableModifier} ${name : DefIdentifier}${type : OptionalTypeAnnotation} ${init : OptionalVariableInitialiation}") {
    type.symbols_before = this.symbols_before;
    init.symbols_before = this.symbols_before;
    init.expected_type = type.type;
    init.must_initialise = this.must_initialise;
    
    name.symbols_before = this.symbols_before;

    this.valid = (or type.has_type init.is_initialised);

    this.symbol = (Variable:create name.name (if type.has_type type.type init.type) init.is_initialised mod.is_mutable);
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
  grd valid;

  inh expected_type : Type;
  inh symbols_before : SymbolTable;
  inh must_initialise : boolean;
  
  syn is_initialised : boolean;
  syn type : Type;

  no_init("") {
    this.valid = (not this.must_initialise);

    this.is_initialised = false;
    this.type = (SymbolTable:getAsType this.symbols_before (AnyType:name));
  }

  init("= ${expr : Expr}") {
    this.valid = true;

    expr.symbols_before = this.symbols_before;
    expr.expected_type = this.expected_type;

    this.is_initialised = true;
    this.type = expr.type;
  }
}

class OptionalTypeAnnotation {
  inh symbols_before: SymbolTable;

  syn type : Type;
  syn has_type : boolean;

  no_type_annotation("") {
    this.type = (SymbolTable:getAsType this.symbols_before (AnyType:name));
    this.has_type = false;
  }

  type_annotation(": ${type: Type}") {
    type.symbols_before = this.symbols_before;
    this.type = type.type;
    this.has_type = true;
  }
}

class Type {
  inh symbols_before: SymbolTable;
  syn type : Type;

  type (SymbolTable:visibleTypeNames this.symbols_before) : String {
    this.type = (SymbolTable:getAsType this.symbols_before $);
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
    expr.expected_type = (SymbolTable:getAsType this.symbols_before (AnyType:name));
  }
}

class OptionalReturnStatement {
  grd valid;

  inh symbols_before : SymbolTable;
  inh expected_return_type : Type;

  no_ret ("") {
    this.valid = (Type:isUnitType this.expected_return_type);
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
    this.valid = (Type:isUnitType this.expected_return_type);
  }

  ret_val ("return ${val : Expr}") {
    this.valid = (not (Type:isUnitType this.expected_return_type));

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

  property ("${classType : Expr}.${property : UsePropertyIdentifier}") {
    this.valid = true;
    this.valid2 = true;

    property.symbols_before = this.symbols_before;
    property.expected_type = this.expected_type;
    classType.symbols_before = this.symbols_before;
    classType.expected_type = property.classType;
    this.type = (Variable:getType property.symbol);
  }

  member_function_call ("${member_function_call : MemberFunctionCall}") {
    this.valid = true;
    this.valid2 = true;

    member_function_call.symbols_before = this.symbols_before;
    member_function_call.expected_type = this.expected_type;

    this.type = member_function_call.type;
  }

  arith_bin_op ("(${lhs : Expr}) ${op : ArithBinaryOperator} (${rhs : Expr})") {
    loc int_type = (SymbolTable:getAsType this.symbols_before (IntType:name));
    this.valid2 = true;

    lhs.symbols_before = this.symbols_before;
    lhs.expected_type = .int_type;

    rhs.symbols_before = this.symbols_before;
    rhs.expected_type = .int_type;

    this.valid = (Type:assignable .int_type this.expected_type);
    this.type = .int_type;
  }

  bool_bin_op ("(${lhs : Expr}) ${op : BoolBinaryOperator} (${rhs : Expr})") {
    loc bool_type = (SymbolTable:getAsType this.symbols_before (BooleanType:name));
    this.valid2 = true;

    lhs.symbols_before = this.symbols_before;
    lhs.expected_type = .bool_type;

    rhs.symbols_before = this.symbols_before;
    rhs.expected_type = .bool_type;

    this.valid = (Type:assignable .bool_type this.expected_type);
    this.type = .bool_type;
  }

  bool_unary_op ("${op: BoolUnaryOperator}(${exp: Expr})") {
    loc bool_type = (SymbolTable:getAsType this.symbols_before (BooleanType:name));
    this.valid2 = true;

    exp.symbols_before = this.symbols_before;
    exp.expected_type = .bool_type;

    this.valid = (Type:assignable .bool_type this.expected_type);
    this.type = .bool_type;
  }

  equality_bin_op ("(${lhs : Expr}) ${op : EqualityOp} (${rhs : Expr})") {
    this.valid2 = true;

    lhs.symbols_before = this.symbols_before;
    lhs.expected_type = (SymbolTable:getAsType this.symbols_before (AnyType:name));

    rhs.symbols_before = this.symbols_before;
    rhs.expected_type = lhs.type;

    this.valid = (Type:assignable (SymbolTable:getAsType this.symbols_before (BooleanType:name)) this.expected_type);
    this.type = (SymbolTable:getAsType this.symbols_before (BooleanType:name));
  }

  comparison_bin_op ("(${lhs: Expr}) ${op : ComparisonOp} (${rhs : Expr})") {
    lhs.symbols_before = this.symbols_before;
    lhs.expected_type = (SymbolTable:getAsType this.symbols_before (AnyType:name));
    
    this.valid2 = (not (Type:is lhs.type (SymbolTable:getAsType this.symbols_before (AnyType:name))));

    rhs.symbols_before = this.symbols_before;
    rhs.expected_type = lhs.type;

    this.valid = (Type:assignable (SymbolTable:getAsType this.symbols_before (BooleanType:name)) this.expected_type);
    this.type = (SymbolTable:getAsType this.symbols_before (BooleanType:name));
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
    
    val.symbols_before = this.symbols_before;
    val.expected_type = this.expected_type;
    this.type = val.type;
  }

  string_literal ("${str: StringLiteral}") {
    loc type = (SymbolTable:getAsType this.symbols_before (StringType:name));
    this.valid = (Type:assignable .type this.expected_type);

    this.type = .type;
  }

  boolean_literal ("${bool: BooleanLiteral}") {
    loc type = (SymbolTable:getAsType this.symbols_before (BooleanType:name));
    this.valid = (Type:assignable .type this.expected_type);

    this.type = .type;
  }

  char_literal ("${char: CharLiteral}") {
    loc type = (SymbolTable:getAsType this.symbols_before (CharType:name));
    this.valid = (Type:assignable .type this.expected_type);

    this.type = .type;
  }

  var ("${name : UseVariableIdentifier}") {  
    loc type = (Variable:getType name.symbol);
    name.symbols_before = this.symbols_before;
    name.expected_type = this.expected_type;

    this.type = .type;

    this.valid = (Variable:getIsInitialised name.symbol);
  }

}

class BooleanLiteral("false|true");

class StringLiteral("\"[a-zA-Z0-9]{0,15}\"");

class CharLiteral("\'[a-zA-Z0-9]\'");

class UseVariableIdentifier {

  inh symbols_before : SymbolTable;
  inh expected_type : Type;

  syn symbol : Variable;

  use_id (SymbolTable:visibleVariableNames this.symbols_before this.expected_type) : String {
    this.symbol = (Symbol:asVariable (SymbolTable:get this.symbols_before $));
  }

}

class UsePropertyIdentifier {

  inh expected_type : Type;
  inh symbols_before : SymbolTable;

  syn symbol : Variable;
  syn classType : Type;

  use_id (SymbolTable:visiblePropertyNames this.symbols_before this.expected_type) : String {
    loc classType = (SymbolTable:getClassWithPropertyAndType this.symbols_before $ this.expected_type);
    this.classType = .classType;
    this.symbol = (Type:getProperty .classType $);
  }
}

class UseFunctionIdentifier {

  inh symbols_before : SymbolTable;
  inh expected_return_type : Type;

  syn symbol : Function;

  use_id (SymbolTable:visibleFunctionNames this.symbols_before this.expected_return_type) : String {
    this.symbol = (Symbol:asFunction (SymbolTable:get this.symbols_before $));
  }

}

class UseMemberFunctionIdentifier {

  inh symbols_before : SymbolTable;
  inh expected_return_type : Type;
  inh callee_type : Type;

  syn symbol : Function;

  use_id (SymbolTable:visibleMemberFunctionNames this.symbols_before this.callee_type this.expected_return_type) : String {
    this.symbol = (Type:getMemberFunction this.callee_type $);
  }

}

class Number {
  inh symbols_before : SymbolTable;
  inh expected_type : Type;
  syn type : Type;

  grd type_matches;

  int_number ("${num : IntNumber}") {
    loc type = (SymbolTable:getAsType this.symbols_before (IntType:name));
    this.type_matches = (Type:assignable .type this.expected_type);
    this.type = .type;
  }
}

class IntNumber("0|[1-9][0-9]{0,8}");