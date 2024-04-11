package runtime;

import i2.act.fuzzer.runtime.Printable;

import java.util.Objects;

public class StringType extends Type implements Printable {

  public StringType(String name) {
      super(name);
  }

  public StringType clone() {
    return new StringType(name);
  }

  public static StringType create() {
    return new StringType("StringType");
  }

  public static String name() {
    return "String";
  }
}
