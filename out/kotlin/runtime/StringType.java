package runtime;

import i2.act.fuzzer.runtime.Printable;

import java.util.Objects;

public class StringType extends Type implements Printable {

  public StringType(String name) {
      super(name);
  }

  public static String name() {
    return "String";
  }
}
