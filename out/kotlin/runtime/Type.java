package runtime;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Objects;

public abstract class Type {
  @Override
  public abstract boolean equals(final Object other);

  @Override
  public abstract String toString();

  @Override
  public abstract int hashCode();

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

    @Override
    public final int hashCode() {
      return System.identityHashCode(this);
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

  // ===============================================================================================


  private static final class TupleType extends Type {

    public final List<Type> types;

    public TupleType() {

      this.types = new ArrayList<Type>();
    }

    public final TupleType clone() {
      final TupleType clone = new TupleType();

      for (final Type type : this.types) {
        clone.types.add(type);
      }

      return clone;
    }

    @Override
    public final boolean equals(final Object other) {
      if (!(other instanceof TupleType)) {
        return false;
      }

      final TupleType otherTupleType = (TupleType) other;
      return this.types.equals(otherTupleType.types);
    }

    @Override
    public int hashCode() {
      return Objects.hash(this.types);
    }

    @Override
    public final String toString() {
      final StringBuilder builder = new StringBuilder();

      builder.append("(");

      boolean first = true;
      for (final Type type : this.types) {
        if (!first) {
          builder.append(", ");
        }
        first = false;

        builder.append(type);
      }

      builder.append(")");

      return builder.toString();
    }

  }

 
  // ------------------------------------------------------
  

  public static final Type createEmptyTupleType() {
    return new TupleType();
  }

  public static final Type createTupleType(final Type firstElement) {
    final TupleType tupleType = new TupleType();
    tupleType.types.add(firstElement);

    return tupleType;
  }

  public static final Type mergeTupleTypes(final Type first, final Type second) {
    final TupleType merged = ((TupleType) first).clone();
    merged.types.addAll(((TupleType) second).types);

    return merged;
  }

  public static final int getTupleTypeSize(final Type tupleType) {
    return ((TupleType) tupleType).types.size();
  }

  public static final Type getTupleTypeHead(final Type tupleType) {
    if (((TupleType) tupleType).types.isEmpty()) {
      throw new RuntimeException("tuple is empty");
    }
    return ((TupleType) tupleType).types.get(0);
  }

  public static final Type getTupleTypeTail(final Type tupleType) {
    if (((TupleType) tupleType).types.isEmpty()) {
      throw new RuntimeException("tuple is empty");
    }

    final TupleType tailType = new TupleType();

    final int numberOfTypes = ((TupleType) tupleType).types.size();
    for (int index = 1; index < numberOfTypes; ++index) {
      tailType.types.add(((TupleType) tupleType).types.get(index));
    }

    return tailType;
  }


  // ===============================================================================================

  private static final class FunctionType extends Type {
    
    public final Type returnType;
    public final Type parameterType;

    public FunctionType(final Type returnType, final Type parameterType) {

      this.returnType = returnType;
      this.parameterType = parameterType;
    }

    @Override
    public final String toString() {
      final StringBuilder builder = new StringBuilder();

      builder.append("FunctionType(");
      builder.append(this.parameterType);
      builder.append(" -> ");
      builder.append(this.returnType);
      builder.append(")");

      return builder.toString();
    }

    @Override
    public final boolean equals(final Object other) {
      if (!(other instanceof FunctionType)) {
        return false;
      }

      final FunctionType otherFunctionType = (FunctionType) other;

      return this.returnType.equals(otherFunctionType.returnType)
          && this.parameterType.equals(otherFunctionType.parameterType);
    }

    @Override
    public final int hashCode() {
      return Objects.hash(this.returnType, this.parameterType);
    }

  }


  public static final Type createFunctionType(final Type returnType, final Type parameterType) {
    return new FunctionType(returnType, parameterType);
  }

  public static final Type getReturnType(final Type functionType) {
    return ((FunctionType) functionType).returnType;
  }

  public static final Type getParameterType(final Type functionType) {
    return ((FunctionType) functionType).parameterType;
  }

  public static final boolean isFunctionType(final Type type) {
    return (type instanceof FunctionType);
  }



  // ===============================================================================================

} 