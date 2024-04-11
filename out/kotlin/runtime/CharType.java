package runtime;

import i2.act.fuzzer.runtime.Printable;

import java.util.Objects;

public class CharType extends Type implements Printable {

  public CharType(String name) {
    super(name);
  }

  public CharType clone() {
    return new CharType(name);
  }

  public static CharType create() {
    return new CharType("Char");
  }

  public static String name() {
    return "Char";
  }
}
