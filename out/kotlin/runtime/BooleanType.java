package runtime;

import i2.act.fuzzer.runtime.Printable;

import java.util.Objects;

public class BooleanType extends Type implements Printable {

  public BooleanType(String name, CustomList<CustomList<Variable>> constructors, SymbolTable symbolTable) {
    super(name, constructors, symbolTable);
  }

  public BooleanType clone() {
    return new BooleanType(name, constructors, symbolTable);
  }

  public static String name() {
    return "Boolean";
  }
}
