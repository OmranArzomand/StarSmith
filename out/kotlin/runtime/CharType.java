package runtime;

import i2.act.fuzzer.runtime.Printable;

import java.util.Objects;

public class CharType extends Type implements Printable {

  public CharType(String name) {
    super(name);
  }

  public static String name() {
    return "Char";
  }
}
