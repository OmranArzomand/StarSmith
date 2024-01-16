package runtime;

public abstract class Type {
  @Override
  public abstract boolean equals(final Object other);

  @Override
  public abstract String toString();

  // ===============================================================================================

  public static final class BuiltInType extends Type {

    public final String name;

    public BuiltInType(final String name) {
      this.name = name;
    }


    @Override
    public final boolean equals(final Object other) {
      return other == this;
    }

    @Override
    public final String toString() {
      return this.name;
    }

  }

  private static final Type ANY_TYPE = new BuiltInType("Any");
  private static final Type INT_TYPE = new BuiltInType("Int");
  private static final Type UNIT_TYPE = new BuiltInType("Unit");
  private static final Type BOOLEAN_TYPE = new BuiltInType("Boolean");
  private static final Type CHAR_TYPE = new BuiltInType("Char");
  private static final Type STRING_TYPE = new BuiltInType("String");

  public static final boolean is(Type type1, Type type2) {
    return type1.equals(type2);
  }
  
  public static final Type unitType() {
    return UNIT_TYPE;
  }

  public static final Type anyType() {
    return ANY_TYPE;
  }

  public static final Type intType() {
    return INT_TYPE;
  }

  public static final Type charType() {
    return CHAR_TYPE;
  }

  public static final Type stringType() {
    return STRING_TYPE;
  }

  public static final Type booleanType() {
    return BOOLEAN_TYPE;
  }

  // ===============================================================================================


  public static final boolean equals(final Type first, final Type second) {
    return first.equals(second);
  }

  public static final boolean assignable(final Type sourceType, final Type targetType) {
    if (ANY_TYPE.equals(targetType)) {
      return true;
    } else if (INT_TYPE.equals(sourceType)) {
      return INT_TYPE.equals(targetType);
    } else if (STRING_TYPE.equals(sourceType)) {
      return STRING_TYPE.equals(targetType);
    } else if (BOOLEAN_TYPE.equals(sourceType)) {
      return BOOLEAN_TYPE.equals(targetType);
    } else if (CHAR_TYPE.equals(sourceType)) {
      return CHAR_TYPE.equals(targetType);
    } else {
      return false;
    }
  }

} 