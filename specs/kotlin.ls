use Symbol;
use SymbolTable;
use Type;
use Function;
use CustomList;
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
    func_decl.in_interface = false;
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

  class_decl("${open : OptionalOpen}${class_or_interface : ClassOrInterface} ${ident : DefIdentifier}${primary_constructor : OptionalPrimaryConstructor} {\+${body : ClassMemberList}\-}\n") {
    ident.symbols_before = this.symbols_before;
    primary_constructor.symbols_before = (SymbolTable:enterScope this.symbols_before);
    primary_constructor.is_interface = class_or_interface.is_interface;
    body.symbols_before = primary_constructor.symbols_after;
    body.class_type_before = (Type:addSupertype (Type:create ident.name class_or_interface.is_interface (or open.is_open class_or_interface.is_interface) (if (== primary_constructor.params nil) (CustomList:empty) (CustomList:create primary_constructor.params)) primary_constructor.property_constrcutor_params) (SymbolTable:getKotlinAnyType this.symbols_before));
    body.non_property_constrcutor_params = primary_constructor.non_property_constrcutor_params;
    this.symbol = body.class_type_after;
  }
}

class ClassOrInterface {
  syn is_interface : Boolean;

  @weight(8)
  class_("class") {
    this.is_interface = false;
  }

  @weight(2)
  interface("interface") {
    this.is_interface = true;
  }
}

class OptionalOpen {
  syn is_open : Boolean;

  no_open("") {
    this.is_open = false;
  }

  open("open ") {
    this.is_open = true;
  }
}

class ClassMemberList {
  inh symbols_before : SymbolTable;
  inh class_type_before : Type;
  inh non_property_constrcutor_params : CustomList;

  syn symbols_after : SymbolTable;
  syn class_type_after : Type;

  member ("${member : ClassMember}") {
    member.symbols_before = this.symbols_before;
    member.non_property_constrcutor_params = this.non_property_constrcutor_params;
    member.class_type_before = this.class_type_before;

    this.symbols_after = member.symbols_after;
    this.class_type_after = member.class_type_after;
  } 

  @weight(100)
  mult_members ("${member : ClassMember}\n${rest : ClassMemberList}") {
    member.symbols_before = this.symbols_before;
    member.non_property_constrcutor_params = this.non_property_constrcutor_params;
    member.class_type_before = this.class_type_before;

    rest.symbols_before = member.symbols_after;
    rest.non_property_constrcutor_params = this.non_property_constrcutor_params;
    rest.class_type_before = member.class_type_after;

    this.symbols_after = rest.symbols_after;
    this.class_type_after = rest.class_type_after;
  }
}

class ClassMember {
  grd valid;
  grd valid2;

  inh symbols_before : SymbolTable;
  inh class_type_before : Type;
  inh non_property_constrcutor_params : CustomList;

  syn symbols_after : SymbolTable;
  syn class_type_after : Type;

  property ("${decl : PropertyDeclaration}") {
    this.valid = true;
    this.valid2 = true;

    decl.symbols_before = this.symbols_before;
    decl.is_interface = (Type:isInterface this.class_type_before);
    this.symbols_after = (SymbolTable:put this.symbols_before decl.symbol);
    this.class_type_after = (Type:addProperty this.class_type_before decl.symbol);
  }

  init ("init {\+${stmts : StmtList}\-}") {
    this.valid = (not (Type:isInterface this.class_type_before));
    this.valid2 = true;

    stmts.symbols_before = (SymbolTable:enterScope (SymbolTable:putAll this.symbols_before this.non_property_constrcutor_params));

    this.symbols_after = this.symbols_before;
    this.class_type_after = this.class_type_before;
  }

  member_function ("${func : FunctionDeclaration}") {
    this.valid = true;
    this.valid2 = true;

    func.symbols_before = this.symbols_before;
    func.in_interface = (Type:isInterface this.class_type_before);

    this.symbols_after = (SymbolTable:put this.symbols_before func.symbol);
    this.class_type_after = (Type:addMemberFunction this.class_type_before func.symbol);
  }

  secondary_constructor ("constructor (${params : ParameterDeclarationList})${delagation : OptionalConstructorDelegation} {\+${stmts : StmtList}\-}") {
    loc this_object = (Variable:create "this" this.class_type_before true false);

    this.valid = (not (CustomList:contains (Type:getConstructors this.class_type_before) params.params));
    this.valid2 = (not (Type:isInterface this.class_type_before));

    params.symbols_before = (SymbolTable:enterScope this.symbols_before);

    delagation.symbols_before = (SymbolTable:putAll (SymbolTable:exitScope this.symbols_before) params.params);
    delagation.class_type_before = this.class_type_before;

    stmts.symbols_before = (SymbolTable:put (SymbolTable:put params.symbols_after this.class_type_before) .this_object);

    this.symbols_after = this.symbols_before;
    this.class_type_after = (Type:addConstrcutor this.class_type_before params.params);
  }
}

class PropertyDeclaration {  
  syn symbol : Variable;

  inh symbols_before : SymbolTable;
  inh is_interface : boolean;

  var_decl ("${mod: VariableModifier} ${name : DefIdentifier}${type : OptionalTypeAnnotation} ${init : OptionalVariableInitialiation}\n${getter : OptionalPropertyGetter}${setter : OptionalPropertySetter}") {
    loc uses_field = (or getter.uses_field setter.uses_field);
    loc no_custom_accessor = (and (not getter.has_getter) (not setter.has_setter));
    loc has_all_accessors = (and getter.has_getter (or (not mod.is_mutable) setter.has_setter));
    loc mutable_and_missing_accessor = (and mod.is_mutable (or (and (not getter.has_getter) setter.has_setter) (and getter.has_getter (not setter.has_setter))));

    type.symbols_before = this.symbols_before;
    type.required = true;
    
    name.symbols_before = this.symbols_before;

    getter.symbols_before = this.symbols_before;
    getter.property_type = type.type;
    getter.is_interface = this.is_interface;

    setter.symbols_before = this.symbols_before;
    setter.property_type = type.type;
    setter.is_interface = this.is_interface;
    setter.is_mutable = mod.is_mutable;

    init.symbols_before = this.symbols_before;
    init.expected_type = type.type;
    init.must_initialise = (or (or .uses_field .no_custom_accessor) .mutable_and_missing_accessor);
    init.must_not_initialise = (or this.is_interface (and .has_all_accessors (not .uses_field)));

    this.symbol = (Variable:create name.name (if type.has_type type.type init.type) init.is_initialised mod.is_mutable);
  }
}

class OptionalPropertyGetter {
  grd valid;
  inh symbols_before : SymbolTable;
  inh is_interface : boolean;
  inh property_type : Type;

  syn has_getter : boolean;
  syn uses_field : boolean;
  
  no_getter ("") {
    this.valid = true;
    this.has_getter = false;
    this.uses_field = false;
  }

  getter_without_field ("get() {\+
          ${body : FunctionBody}\-
        }\n") {
    this.valid = true;
    body.symbols_before = (SymbolTable:enterScope this.symbols_before);
    body.expected_return_type = this.property_type;
    this.has_getter = true;
    this.uses_field = false;
  }

  getter_with_field ("get() {\+
          println(field)\n
          ${body : FunctionBody}\-
        }\n") {
    loc field = (Variable:create "field" this.property_type true false); 
    this.valid = (not this.is_interface);
    body.symbols_before = (SymbolTable:put (SymbolTable:enterScope this.symbols_before) .field);
    body.expected_return_type = this.property_type;
    this.has_getter = true;
    this.uses_field = true;
  }
}

class OptionalPropertySetter {
  grd valid1;
  grd valid2;
  inh symbols_before : SymbolTable;
  inh is_interface : boolean;
  inh property_type : Type;
  inh is_mutable : boolean;

  syn has_setter : boolean;
  syn uses_field : boolean;
  
  no_setter ("") {
    this.valid1 = true;
    this.valid2 = true;
    this.has_setter = false;
    this.uses_field = false;
  }

  setter_without_field ("set(value) {\+
          ${body : FunctionBody}\-
        }\n") {
    loc value = (Variable:create "value" this.property_type true false);
    this.valid1 = this.is_mutable;
    this.valid2 = true;
    body.symbols_before = (SymbolTable:put (SymbolTable:enterScope this.symbols_before) .value);
    body.expected_return_type = (SymbolTable:getAsType this.symbols_before "Unit");
    this.has_setter = true;
    this.uses_field = false;
  }

  setter_with_field ("set(value) {\+
          println(field)\n
          ${body : FunctionBody}\-
        }\n") {
    loc value = (Variable:create "value" this.property_type true false);
    loc field = (Variable:create "field" this.property_type true true); 
    this.valid1 = this.is_mutable;
    this.valid2 = (not this.is_interface);
    body.symbols_before = (SymbolTable:put (SymbolTable:put (SymbolTable:enterScope this.symbols_before) .field) .value);
    body.expected_return_type = (SymbolTable:getAsType this.symbols_before "Unit");
    this.has_setter = true;
    this.uses_field = true;
  }
}

class OptionalConstructorDelegation {
  grd valid;
  inh symbols_before : SymbolTable;
  inh class_type_before : Type;

  no_delegation ("") {
    this.valid = (== (CustomList:getSize (Type:getConstructors this.class_type_before)) 0);

  }

  delegation (": this(${chosen_params : UseConstructor}${args : ArgumentList})") {
    this.valid = (> (CustomList:getSize (Type:getConstructors this.class_type_before)) 0);
    chosen_params.class_type = this.class_type_before;
    args.symbols_before = this.symbols_before;
    args.expected_params = chosen_params.params;
  }
}

class UseConstructor {
  inh class_type : Type;
  syn params : CustomList;
  constructor(SymbolTable:visibleConstructors this.class_type) : CustomList {
    this.params = $;
  }
}

class OptionalPrimaryConstructor {
  grd valid;
  inh symbols_before : SymbolTable;
  inh is_interface : boolean;
  syn symbols_after : SymbolTable;
  syn params : CustomList;
  syn non_property_constrcutor_params : CustomList;
  syn property_constrcutor_params : CustomList;

  no_constructor("") {
    this.valid = true;
    this.params = nil;
    this.non_property_constrcutor_params = (CustomList:empty);
    this.property_constrcutor_params = (CustomList:empty);
    this.symbols_after = this.symbols_before;
  }

  @weight(100)
  constructor("(${constructorList: ConstructorList})") {
    this.valid = (not this.is_interface);
    constructorList.symbols_before = this.symbols_before;
    this.symbols_after = constructorList.symbols_after;
    this.params = constructorList.params;
    this.non_property_constrcutor_params = constructorList.non_property_constrcutor_params;
    this.property_constrcutor_params = constructorList.property_constrcutor_params;
  }
}

class ConstructorList {
  inh symbols_before : SymbolTable;
  syn symbols_after : SymbolTable;
  syn params : CustomList;
  syn non_property_constrcutor_params : CustomList;
  syn property_constrcutor_params : CustomList;

  no_param ("") {
    this.symbols_after = this.symbols_before;
    this.params = (CustomList:empty);
    this.non_property_constrcutor_params = (CustomList:empty);
    this.property_constrcutor_params = (CustomList:empty);
  }

  @weight(10)
  mult_param ("${param : ConstructorParameterDeclaration}, ${rest : ConstructorList}") {
    param.symbols_before = this.symbols_before;
    rest.symbols_before = (if param.add_to_properties (SymbolTable:put this.symbols_before param.symbol) this.symbols_before);
    this.symbols_after = rest.symbols_after;
    this.params = (CustomList:prepend rest.params param.symbol);
    this.non_property_constrcutor_params = (if param.add_to_properties rest.non_property_constrcutor_params (CustomList:prepend rest.non_property_constrcutor_params param.symbol));
    this.property_constrcutor_params = (if param.add_to_properties (CustomList:prepend rest.property_constrcutor_params param.symbol) rest.property_constrcutor_params);
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
  grd valid;

  syn symbol : Function;

  inh symbols_before : SymbolTable;
  inh in_interface : boolean;

  func_decl_no_body ("fun ${name : DefIdentifier}(${params : ParameterDeclarationList})${ret_type : OptionalTypeAnnotation}") {
    this.valid = this.in_interface;
    name.symbols_before = this.symbols_before;
    params.symbols_before = (SymbolTable:enterScope this.symbols_before);
    ret_type.symbols_before = this.symbols_before;
    ret_type.required = true;
    this.symbol = (Function:create name.name ret_type.type params.params);

  }

  func_decl_expr
      ("fun ${name : DefIdentifier}(${params : ParameterDeclarationList})${ret_type : OptionalTypeAnnotation} = ${expr: Expr}") {
    
    this.valid = true;
    params.symbols_before = (SymbolTable:enterScope this.symbols_before);
    ret_type.symbols_before = this.symbols_before;
    ret_type.required = false;
    expr.symbols_before = params.symbols_after;
    expr.expected_type = (if ret_type.has_type ret_type.type (SymbolTable:getKotlinAnyType this.symbols_before));
    name.symbols_before = this.symbols_before;
    this.symbol = (Function:create name.name (if ret_type.has_type ret_type.type expr.type) params.params );
  }

  func_decl
      ("fun ${name : DefIdentifier}(${params : ParameterDeclarationList})${ret_type : OptionalTypeAnnotation} {\+
          ${body : FunctionBody}\-
        }\n") {
    loc actual_ret_type = (if ret_type.has_type ret_type.type (SymbolTable:getAsType this.symbols_before "Unit"));
    this.valid = true;
    ret_type.symbols_before = this.symbols_before;
    ret_type.required = false;
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
    body.expected_return_type = (SymbolTable:getAsType this.symbols_before "Unit");
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

@list(100)
class StmtList {

  inh symbols_before : SymbolTable;

  syn symbols_after : SymbolTable;

  @weight(2)
  one_stmt ("${stmt : Stmt}") {
    stmt.symbols_before = this.symbols_before;
    
    this.symbols_after = stmt.symbols_after;
  }

  @weight(50)
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

  @weight(0)
  extension_func ("${extension_func : ExtensionFunctionDeclaration}") {
    this.possible = true;

    extension_func.symbols_before = this.symbols_before;

    this.symbols_after = (SymbolTable:put this.symbols_before (Type:addMemberFunction extension_func.type extension_func.function));
  }

  call ("${call : Call}") {
    this.possible = true;

    call.expected_type = (SymbolTable:getKotlinAnyType this.symbols_before);
    call.symbols_before = this.symbols_before;

    this.symbols_after = this.symbols_before;
  }

  member_function_call ("${member_function_call : MemberFunctionCall}") {
    this.possible = true;
    
    member_function_call.symbols_before = this.symbols_before;
    member_function_call.expected_type = (SymbolTable:getKotlinAnyType this.symbols_before);

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

class ExtensionFunctionDeclaration {

  syn function : Function;
  syn type : Type;

  inh symbols_before : SymbolTable;

  func_decl_expr
      ("fun ${type : Type}.${name : DefIdentifier}(${params : ParameterDeclarationList})${ret_type : OptionalTypeAnnotation} = ${expr: Expr}") {
    
    loc this_object = (Variable:create "this" type.type true false);

    type.symbols_before = this.symbols_before;
    this.type = type.type;
    params.symbols_before = (SymbolTable:enterScope this.symbols_before);
    ret_type.symbols_before = this.symbols_before;
    ret_type.required = false;
    expr.symbols_before = (SymbolTable:put (SymbolTable:putAll (SymbolTable:merge this.symbols_before this.symbols_before) params.params) .this_object);
    expr.expected_type = (if ret_type.has_type ret_type.type (SymbolTable:getKotlinAnyType this.symbols_before));
    name.symbols_before = this.symbols_before;
    this.function = (Function:create name.name (if ret_type.has_type ret_type.type expr.type) params.params );
  }

  func_decl
      ("fun ${type : Type}.${name : DefIdentifier}(${params : ParameterDeclarationList})${ret_type : OptionalTypeAnnotation} {\+
          ${body : FunctionBody}\-
        }\n") {
    loc actual_ret_type = (if ret_type.has_type ret_type.type (SymbolTable:getAsType this.symbols_before "Unit"));
    loc this_object = (Variable:create "this" type.type true false);

    type.symbols_before = this.symbols_before;
    this.type = type.type;
    ret_type.symbols_before = this.symbols_before;
    ret_type.required = false;
    params.symbols_before = (SymbolTable:enterScope this.symbols_before);
    body.symbols_before = (SymbolTable:put (SymbolTable:putAll (SymbolTable:merge this.symbols_before this.symbols_before) params.params) .this_object);
    body.expected_return_type = .actual_ret_type;
    name.symbols_before = this.symbols_before;
    this.function = (Function:create name.name .actual_ret_type params.params);
  }
}

class MemberFunctionCall {
  inh symbols_before : SymbolTable;
  inh expected_type : Type;

  syn type : Type;

  member_function_call("${expr : Expr}.${member_function_callee : MemberFunctionCallee}(${args : ArgumentList})") {
    expr.symbols_before = this.symbols_before;
    expr.expected_type = (SymbolTable:getKotlinAnyType this.symbols_before);

    member_function_callee.expected_return_type = this.expected_type;
    member_function_callee.callee_type = (SymbolTable:getAsType this.symbols_before (Symbol:getName expr.type));

    args.expected_params = (Function:getParams member_function_callee.symbol);
    args.symbols_before = this.symbols_before;

    

    this.type = (Function:getReturnType member_function_callee.symbol);

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
  inh expected_return_type : Type;
  inh callee_type : Type;

  syn symbol : Function;

  callee ("${member_function : UseMemberFunctionIdentifier}") {
    member_function.expected_return_type = this.expected_return_type;
    member_function.callee_type = this.callee_type;

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

  @weight(1)
  variable ("${var : UseVariableIdentifier}") {
    var.expected_type = (SymbolTable:getKotlinAnyType this.symbols_before);
    var.symbols_before = this.symbols_before;
    this.symbol = var.symbol;
    this.is_property = false;
  }

  @weight(5)
  property ("${class_type : Expr}.${property : UsePropertyIdentifier}") {
    class_type.symbols_before = this.symbols_before;
    class_type.expected_type = (SymbolTable:getKotlinAnyType this.symbols_before);
    property.class_type = class_type.type;
    property.expected_type = (SymbolTable:getKotlinAnyType this.symbols_before);
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
    type.required = false;
    init.symbols_before = this.symbols_before;
    init.expected_type = type.type;
    init.must_initialise = this.must_initialise;
    init.must_not_initialise = false;
    
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
  inh must_not_initialise : boolean;
  
  syn is_initialised : boolean;
  syn type : Type;

  no_init("") {
    this.valid = (not this.must_initialise);

    this.is_initialised = false;
    this.type = (SymbolTable:getKotlinAnyType this.symbols_before);
  }

  init("= ${expr : Expr}") {
    this.valid = (not this.must_not_initialise);

    expr.symbols_before = this.symbols_before;
    expr.expected_type = this.expected_type;

    this.is_initialised = true;
    this.type = expr.type;
  }
}

class OptionalTypeAnnotation {
  grd valid;
  inh symbols_before: SymbolTable;
  inh required : boolean;

  syn type : Type;
  syn has_type : boolean;

  no_type_annotation("") {
    this.valid = (not this.required);
    this.type = (SymbolTable:getKotlinAnyType this.symbols_before);
    this.has_type = false;
  }

  type_annotation(": ${type: Type}") {
    this.valid = true;
    type.symbols_before = this.symbols_before;
    this.type = type.type;
    this.has_type = true;
  }
}

class Type {
  inh symbols_before: SymbolTable;
  syn type : Type;

  type (SymbolTable:visibleTypes this.symbols_before) : Type {
    this.type = $;
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
    expr.expected_type = (SymbolTable:getKotlinAnyType this.symbols_before);
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


  member_function_call ("${member_function_call : MemberFunctionCall}") {
    this.valid = true;
    this.valid2 = true;

    member_function_call.symbols_before = this.symbols_before;
    member_function_call.expected_type = this.expected_type;

    this.type = member_function_call.type;
  }

  arith_bin_op ("((${lhs : Expr}) ${op : ArithBinaryOperator} (${rhs : Expr}))") {
    loc int_type = (SymbolTable:getAsType this.symbols_before "Int");
    this.valid2 = true;

    lhs.symbols_before = this.symbols_before;
    lhs.expected_type = .int_type;

    rhs.symbols_before = this.symbols_before;
    rhs.expected_type = .int_type;

    this.valid = (Type:assignable .int_type this.expected_type);
    this.type = .int_type;
  }

  bool_bin_op ("((${lhs : Expr}) ${op : BoolBinaryOperator} (${rhs : Expr}))") {
    loc bool_type = (SymbolTable:getAsType this.symbols_before "Boolean");
    this.valid2 = true;

    lhs.symbols_before = this.symbols_before;
    lhs.expected_type = .bool_type;

    rhs.symbols_before = this.symbols_before;
    rhs.expected_type = .bool_type;

    this.valid = (Type:assignable .bool_type this.expected_type);
    this.type = .bool_type;
  }

  bool_unary_op ("(${op: BoolUnaryOperator}(${exp: Expr}))") {
    loc bool_type = (SymbolTable:getAsType this.symbols_before "Boolean");
    this.valid2 = true;

    exp.symbols_before = this.symbols_before;
    exp.expected_type = .bool_type;

    this.valid = (Type:assignable .bool_type this.expected_type);
    this.type = .bool_type;
  }

  equality_bin_op ("((${lhs : Expr}) ${op : EqualityOp} (${rhs : Expr}))") {
    this.valid2 = true;

    lhs.symbols_before = this.symbols_before;
    lhs.expected_type = (SymbolTable:getKotlinAnyType this.symbols_before);

    rhs.symbols_before = this.symbols_before;
    rhs.expected_type = lhs.type;

    this.valid = (Type:assignable (SymbolTable:getAsType this.symbols_before "Boolean") this.expected_type);
    this.type = (SymbolTable:getAsType this.symbols_before "Boolean");
  }

  comparison_bin_op ("((${lhs: Expr}) ${op : ComparisonOp} (${rhs : Expr}))") {
    lhs.symbols_before = this.symbols_before;
    lhs.expected_type = (SymbolTable:getKotlinAnyType this.symbols_before);
    
    this.valid2 = true;

    rhs.symbols_before = this.symbols_before;
    rhs.expected_type = lhs.type;

    this.valid = (and (Type:assignable (SymbolTable:getAsType this.symbols_before "Boolean") this.expected_type) false);
    this.type = (SymbolTable:getAsType this.symbols_before "Boolean");
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

  property ("${ident : UseVariableIdentifier}.${property : UsePropertyIdentifier}") {
    this.valid = (Variable:getIsInitialised ident.symbol);

    ident.symbols_before = this.symbols_before;
    ident.expected_type = (SymbolTable:getKotlinAnyType this.symbols_before);

    property.class_type = (Variable:getType ident.symbol);
    property.expected_type = this.expected_type;
    this.type = (Variable:getType property.symbol);
  }


  num ("${val : Number}") {
    this.valid = true;
    
    val.symbols_before = this.symbols_before;
    val.expected_type = this.expected_type;
    this.type = val.type;
  }

  string_literal ("${str: StringLiteral}") {
    loc type = (SymbolTable:getAsType this.symbols_before "String");
    this.valid = (Type:assignable .type this.expected_type);

    this.type = .type;
  }

  boolean_literal ("${bool: BooleanLiteral}") {
    loc type = (SymbolTable:getAsType this.symbols_before "Boolean");
    this.valid = (Type:assignable .type this.expected_type);

    this.type = .type;
  }

  char_literal ("${char: CharLiteral}") {
    loc type = (SymbolTable:getAsType this.symbols_before "Char");
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

  use_id (SymbolTable:visibleVariables this.symbols_before this.expected_type) : Variable {
    this.symbol = $;
  }

}

class UsePropertyIdentifier {

  inh expected_type : Type;
  inh class_type : Type;

  syn symbol : Variable;

  use_id (SymbolTable:visibleProperties this.class_type this.expected_type) : Variable {
    this.symbol = $;
  }
}

class UseFunctionIdentifier {

  inh symbols_before : SymbolTable;
  inh expected_return_type : Type;

  syn symbol : Function;

  use_id (SymbolTable:visibleFunctions this.symbols_before this.expected_return_type) : Function {
    this.symbol = $;
  }

}

class UseMemberFunctionIdentifier {

  inh expected_return_type : Type;
  inh callee_type : Type;

  syn symbol : Function;

  use_id (SymbolTable:visibleMemberFunctions this.callee_type this.expected_return_type) : Function {
    this.symbol = $;
  }

}

class Number {
  inh symbols_before : SymbolTable;
  inh expected_type : Type;
  syn type : Type;

  grd type_matches;

  int_number ("${num : IntNumber}") {
    loc type = (SymbolTable:getAsType this.symbols_before "Int");
    this.type_matches = (Type:assignable .type this.expected_type);
    this.type = .type;
  }
}

class IntNumber("0|[1-9][0-9]{0,8}");