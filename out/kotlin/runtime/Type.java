package runtime;

import i2.act.fuzzer.runtime.Printable;
import java.util.Map;
import java.util.HashMap;
import java.util.List;
import java.util.Objects;
import java.util.ArrayList;

import javax.lang.model.element.VariableElement;

public class Type extends Symbol implements Printable{
  public final Map<String, Function> memberFunctions;
  public final CustomList<CustomList<Variable>> constructors;
  public final CustomList<Variable> properties;

  public Type(String name) {
    super(name);
    this.memberFunctions = new HashMap();
    this.constructors = CustomList.empty();
    this.properties = CustomList.empty();
  }

  public Type(String name, CustomList<CustomList<Variable>> constructors, CustomList<Variable> properties,
      CustomList<Function> memberFunctions) {
    super(name);
    this.memberFunctions = new HashMap();
    for (Function func : memberFunctions.items) {
      this.memberFunctions.put(func.name, func);
    }
    this.constructors = constructors;
    this.properties = properties;
  }

  @Override
  public Type clone() {
    return new Type(name);
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

  public static Function getMemberFunction(Type type, String functionName) {
    return type.memberFunctions.get(functionName);
  }

  public static Type create(String name) {
    return new Type(name);
  }

  public static Type create(String name, CustomList<CustomList<Variable>> constructors,
    CustomList<Variable> properties, CustomList<Function> memberFunctions) {
    return new Type(name, constructors, properties, memberFunctions);
  }

  public static List<String> visiblePropertyNames(Type classType, Type expectedType) {
    List<String> propertyNames = new ArrayList<>();
    for (Variable property : classType.properties.items) {
      if (Type.assignable(property.type, expectedType)){
        propertyNames.add(property.name);
      }
    }
    return propertyNames;
  }

  public static Variable getProperty(Type classType, String name) {
    for (Variable property : classType.properties.items) {
      if (property.name.equals(name)){
        return property;
      }
    }
    throw new RuntimeException("Property doesn't exist in class");
  }

  @Override
  public boolean equals(Object obj) {
    if (!(obj instanceof Type)) {
      return false;
    }

    final Type otherType = (Type) obj;

    return Objects.equals(this.name, otherType.name)
      && Objects.equals(this.memberFunctions, otherType.memberFunctions);
  }

  @Override
  public int hashCode() {
    return Objects.hash(this.name, this.memberFunctions);
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
