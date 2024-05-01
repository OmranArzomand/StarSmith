package runtime;

import i2.act.fuzzer.runtime.Printable;

import java.util.Objects;

public class CharType extends Type implements Printable {

  public CharType(String name, CustomList<CustomList<Variable>> constructors, SymbolTable symbolTable) {
    super(name, constructors, symbolTable);
  }

  public CharType clone() {
    return new CharType(name, constructors, symbolTable);
  }

  public static String name() {
    return "Char";
  }
}
