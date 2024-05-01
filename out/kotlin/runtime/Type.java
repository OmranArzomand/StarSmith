package runtime;

import i2.act.fuzzer.runtime.Printable;
import java.util.Map;
import java.util.HashMap;
import java.util.List;
import java.util.Objects;
import java.util.ArrayList;

import javax.lang.model.element.VariableElement;

public class Type extends Symbol implements Printable{
  public final CustomList<CustomList<Variable>> constructors;
  public final SymbolTable symbolTable;

  public Type(String name, CustomList<CustomList<Variable>> constructors, SymbolTable symbolTable) {
    super(name);
    this.constructors = constructors;
    this.symbolTable = symbolTable;
  }

  @Override
  public Type clone() {
    return new Type(name, constructors, symbolTable);
  }

  public static final boolean assignable(final Type sourceType, final Type targetType) {
    if (targetType.getClass() == Type.class) {
      return sourceType.name.equals(targetType.name);
    }
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

  public static Type addExtensionFunction(Type type, Function function) {
    SymbolTable clone = type.symbolTable.clone();
    clone.put(function);
    return Type.create(type.name, type.constructors, clone);
  }

  public static Type create(String name, CustomList<CustomList<Variable>> constructors,
    SymbolTable symbolTable) {
    return new Type(name, constructors, symbolTable);
  }

  public static SymbolTable getSymbolTable(Type type) {
    return type.symbolTable;
  }

  @Override
  public boolean equals(Object obj) {
    if (!(obj instanceof Type)) {
      return false;
    }

    final Type otherType = (Type) obj;

    return Objects.equals(this.name, otherType.name)
      && Objects.equals(this.symbolTable, otherType.symbolTable)
      && Objects.equals(this.constructors, otherType.constructors);
  }

  @Override
  public int hashCode() {
    return Objects.hash(this.name, this.symbolTable, this.constructors);
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
