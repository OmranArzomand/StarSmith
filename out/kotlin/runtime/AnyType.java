package runtime;

import i2.act.fuzzer.runtime.Printable;

import java.util.Objects;

public class AnyType extends Type implements Printable {

  public AnyType(String name) {
    super(name);
  }

  public AnyType clone() {
    return new AnyType(name);
  }

  public static AnyType create() {
    return new AnyType("Any");
  }

  public static String name() {
    return "Any";
  }
}
