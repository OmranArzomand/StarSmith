package runtime;

import i2.act.fuzzer.runtime.Printable;

import java.util.Objects;

public class IntType extends Type implements Printable {

  public IntType(String name, CustomList<CustomList<Variable>> constructors, SymbolTable symbolTable) {
    super(name, constructors, symbolTable);
  }

  public IntType clone() {
    return new IntType(name, constructors, symbolTable);
  }

  public static String name() {
    return "Int";
  }
}
