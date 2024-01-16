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

  @weight(18)
  print ("${print : Print}") {
    this.possible = true;

    print.symbols_before = this.symbols_before;
    
    this.symbols_after = this.symbols_before;
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

  syn type : Type;

  num ("${val : Number}") {
    val.expected_type = this.expected_type;
    this.type = val.type;
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