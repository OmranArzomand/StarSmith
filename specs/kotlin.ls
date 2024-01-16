use Symbol;
use SymbolTable;
use Type;

class Program {
  prog("${main : MainDeclaration}\n") {
    main.symbols_before = (SymbolTable:empty);
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

@list(50)
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

  @weight(7)
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

}

class AssignStmt {

  inh symbols_before : SymbolTable;

  syn symbols_after : SymbolTable;

  grd valid; 

  assign ("${lhs : UseIdentifier} = ${rhs : Expr};") {
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

  ret_val ("return ${val : Expr};") {
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

  atom ("${atom : ExprAtom}") {
    atom.symbols_before = this.symbols_before;
    atom.expected_type = this.expected_type;

    this.type = atom.type;
  }
}

class ExprAtom {
  inh symbols_before : SymbolTable;
  inh expected_type : Type;

  grd valid;

  syn type : Type;

  num ("${val : Number}") {
    this.valid = true;

    val.expected_type = this.expected_type;
    this.type = val.type;
  }

  var ("${name : UseIdentifier}") {  
    name.symbols_before = this.symbols_before;
    name.expected_type = this.expected_type;

    this.type = (Symbol:getType name.symbol);

    this.valid = (Symbol:getIsInitialised name.symbol);
  }

}

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