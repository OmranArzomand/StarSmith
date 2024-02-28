package runtime;

import i2.act.fuzzer.runtime.Printable;

import java.util.Objects;

public class Type extends Symbol implements Printable{
  public Type(String name) {
    super(name);
  }

  public static final boolean assignable(final Type sourceType, final Type targetType) {
    if (targetType instanceof AnyType) {
      return true;
    } else if (sourceType instanceof IntType) {
      return targetType instanceof IntType;
    } else if (sourceType instanceof StringType) {
      return targetType instanceof StringType;
    } else if (sourceType instanceof BooleanType) {
      return targetType instanceof BooleanType;
    } else if (sourceType instanceof CharType) {
      return targetType instanceof CharType;
    } else {
      return false;
    }
  }

  public static boolean isUnitType(Type type) {
    return type instanceof UnitType;
  }
}
