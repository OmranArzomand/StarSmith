package runtime;

import i2.act.fuzzer.runtime.Printable;

import java.util.Objects;

public class StringType extends Type implements Printable {

  public StringType(String name, CustomList<CustomList<Variable>> constructors, SymbolTable symbolTable) {
    super(name, constructors, symbolTable);
  }

  public StringType clone() {
    return new StringType(name, constructors, symbolTable);
  }

  public static String name() {
    return "String";
  }
}
