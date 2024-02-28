package runtime;

import i2.act.fuzzer.runtime.Printable;

import java.util.Objects;

public class BooleanType extends Type implements Printable {

  public BooleanType(String name) {
    super(name);
  }

  public static String name() {
    return "Boolean";
  }
}
