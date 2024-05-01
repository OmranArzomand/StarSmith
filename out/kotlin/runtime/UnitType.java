package runtime;

import i2.act.fuzzer.runtime.Printable;

import java.util.Objects;

public class UnitType extends Type implements Printable {

  public UnitType(String name, CustomList<CustomList<Variable>> constructors, SymbolTable symbolTable) {
    super(name, constructors, symbolTable);
  }

  public UnitType clone() {
    return new UnitType(name, constructors, symbolTable);
  }

  public static String name() {
    return "Unit";
  }
}
