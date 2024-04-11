package runtime;

import i2.act.fuzzer.runtime.Printable;

import java.util.Objects;

public class UnitType extends Type implements Printable {

  public UnitType(String name) {
    super(name);
  }

  public UnitType clone() {
    return new UnitType(name);
  }

  public static UnitType create() {
    return new UnitType("Unit");
  }

  public static String name() {
    return "Unit";
  }
}
