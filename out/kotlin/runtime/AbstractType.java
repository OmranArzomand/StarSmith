package runtime;

import i2.act.fuzzer.runtime.Printable;

public class AbstractType extends Type {
  public final CustomList<TypeParam> typeParams;
  public final CustomList<Type> concreteInstances;

  public AbstractType(String name, boolean isInterface, boolean isOpen, CustomList<CustomList<Variable>> constructors, 
    CustomList<Function> memberFunctions, CustomList<Variable> properties, CustomList<Type> supertypes, CustomList<TypeParam> typeParams,
    CustomList<Type> concreteInstances) {
    super(name, isInterface, isOpen, constructors, memberFunctions, properties, supertypes);
    this.typeParams = typeParams;
    this.concreteInstances = concreteInstances;
  }

  public static Type create(String name, boolean isInterface, boolean isOpen, CustomList<CustomList<Variable>> constructors, 
  CustomList<Variable> properties, CustomList<Type> supertypes, CustomList<TypeParam> typeParams) {
    return new AbstractType(name, isInterface, isOpen, constructors, new CustomList<>(), properties, supertypes, typeParams, new CustomList<>());
  }

  public static boolean isAbstractType(Type type) {
    return type instanceof AbstractType;
  }

  public static AbstractType asAbstractType(Type type) {
    if (!(type instanceof AbstractType)) {
      throw new RuntimeException("Tried to cast non abstract type into an abstract type");
    }
    return (AbstractType) type;
  }

  public static CustomList<TypeParam> getTypeParams(AbstractType type) {
    return type.typeParams;
  }

  public static AbstractType addConcreteInstance(AbstractType abstractType, Type concreteType) {
    abstractType.concreteInstances.add(concreteType);
    return abstractType;
  }

  public static Type instantiate(AbstractType type, CustomList<Type> typeArguments) {
    StringBuilder sb = new StringBuilder();
    sb.append(type.name);
    sb.append("<");
    boolean first = true;
    for (Type typeArgument : typeArguments.items) {
      if (!first) {
        sb.append(", ");
        first = false;
      }
      sb.append(typeArgument.name);
    }
    sb.append(">");
    Type clone = new Type(sb.toString(), type.isInterface, type.isOpen, type.constructors.clone(), type.memberFunctions.clone(), type.properties.clone(), type.supertypes.clone());
    for (CustomList<Variable> constructor : clone.constructors.items) {
      for (Variable param : constructor.items) {
        int index = type.typeParams.indexOf(param.type);
        if (index != -1) {
          param.type = typeArguments.items.get(index);
        }
      }
    }
    for (Function memberFunction : clone.memberFunctions.items) {
      for (Variable param : memberFunction.params.items) {
        int index = type.typeParams.indexOf(param.type);
        if (index != -1) {
          param.type = typeArguments.items.get(index);
        }
      }
      int index = type.typeParams.indexOf(memberFunction.returnType);
      if (index != -1) {
        memberFunction.returnType = typeArguments.items.get(index);
      }
    }
    for (Variable property : clone.properties.items) {
      int index = type.typeParams.indexOf(property.type);
      if (index != -1) {
        property.type = typeArguments.items.get(index);
      }
    }
    return clone;
  }

  @Override 
  public AbstractType clone() {
    return new AbstractType(name, isInterface, isOpen, constructors.clone(), memberFunctions.clone(), properties.clone(), supertypes.clone(), typeParams.clone(), concreteInstances.clone());
  }
}
