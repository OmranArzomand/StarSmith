package runtime;

import i2.act.fuzzer.runtime.Printable;

import java.util.Objects;

public class IntType extends Type implements Printable {

  public IntType(String name) {
      super(name);
  }

  public static String name() {
    return "Int";
  }
}
