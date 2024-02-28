package runtime;

import i2.act.fuzzer.runtime.Printable;

import java.util.Objects;

public class UnitType extends Type implements Printable {

  public UnitType(String name) {
    super(name);
  }

  public static String name() {
    return "Unit";
  }
}
