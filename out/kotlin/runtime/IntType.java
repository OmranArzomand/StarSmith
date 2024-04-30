package runtime;

import i2.act.fuzzer.runtime.Printable;

import java.util.Objects;

public class IntType extends Type implements Printable {

  public IntType(String name) {
      super(name);
      memberFunctions.put("plus", new Function("plus", this, new CustomList<Variable>(new Variable("x", this, true, false))));
  }

  public IntType clone() {
    return new IntType(name);
  }

  public static IntType create() {
    return new IntType("Int");
  }

  public static String name() {
    return "Int";
  }
}
