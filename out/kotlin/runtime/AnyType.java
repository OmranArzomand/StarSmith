package runtime;

import i2.act.fuzzer.runtime.Printable;

import java.util.Objects;

public class AnyType extends Type implements Printable {

  public AnyType(String name, CustomList<CustomList<Variable>> constructors, SymbolTable symbolTable) {
    super(name, constructors, symbolTable);
  }

  public AnyType clone() {
    return new AnyType(name, constructors, symbolTable);
  }


  public static String name() {
    return "Any";
  }
}
