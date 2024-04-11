package runtime;

import i2.act.fuzzer.runtime.Printable;
import java.util.Map;
import java.util.HashMap;
import java.util.Objects;

public class Type extends Symbol implements Printable{
  public final Map<String, Function> methods;

  public Type(String name) {
    super(name);
    methods = new HashMap();
  }

  @Override
  public Type clone() {
    return new Type(name);
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

  public static boolean is(Type type1, Type type2) {
    return type1.getClass().equals(type2.getClass());
  }

  public static Function getMethod(Type type, String methodName) {
    return type.methods.get(methodName);
  }

  @Override
  public boolean equals(Object obj) {
    if (!(obj instanceof Type)) {
      return false;
    }

    final Type otherType = (Type) obj;

    return Objects.equals(this.name, otherType.name)
      && Objects.equals(this.methods, otherType.methods);
  }

  @Override
  public int hashCode() {
    return Objects.hash(this.name, this.methods);
  }

  @Override
  public final String toString() {
    return String.format("(%s)", this.name);
  }

  @Override
  public final String print() {
    return this.name;
  }
}
