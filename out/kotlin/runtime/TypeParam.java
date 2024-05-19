package runtime;

import i2.act.fuzzer.runtime.Printable;

public class TypeParam extends Type {

  public TypeParam(String name) {
    super(name, new CustomList<>());
  }

  public TypeParam(String name, boolean isInterface, boolean isOpen, CustomList<CustomList<Variable>> constructors, 
  CustomList<Function> memberFunctions, CustomList<Variable> properties, CustomList<Type> supertypes) {
    super(name, isInterface, isOpen, constructors, memberFunctions, properties, supertypes);
  }

  public static TypeParam create(String name) {
    return new TypeParam(name);
  }

  @Override
  public TypeParam clone() {
    return new TypeParam(name, isInterface, isOpen, constructors.clone(), memberFunctions.clone(), properties.clone(), supertypes.clone());
  }
}
