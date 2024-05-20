package runtime;

import i2.act.fuzzer.runtime.Printable;

public class TypeParam extends Type {

  public final String variance;

  public TypeParam(String name, String variance) {
    super(name, new CustomList<>());
    this.variance = variance;
  }

  public TypeParam(String name, boolean isInterface, boolean isOpen, CustomList<CustomList<Variable>> constructors, 
  CustomList<Function> memberFunctions, CustomList<Variable> properties, CustomList<Type> supertypes,
  CustomList<Pair<String, Type>> typeArguments, String variance) {
    super(name, isInterface, isOpen, constructors, memberFunctions, properties, supertypes, typeArguments);
    this.variance = variance;
  }

  public static TypeParam create(String name, String variance) {
    return new TypeParam(name, variance);
  }

  public static String getVariance(TypeParam typeParam) {
    return typeParam.variance;
  }

  public static boolean isContravariant(Type type) {
    if (!(type instanceof TypeParam)) {
      return false;
    }
    TypeParam typeParam = (TypeParam) type;
    return typeParam.variance.equals("in");
  }

  public static boolean isCovariant(Type type) {
    if (!(type instanceof TypeParam)) {
      return false;
    }
    TypeParam typeParam = (TypeParam) type;
    return typeParam.variance.equals("out");
  }

  @Override
  public TypeParam clone() {
    return new TypeParam(name, isInterface, isOpen, constructors.clone(), memberFunctions.clone(), properties.clone(), supertypes.clone(), typeArguments.clone(), variance);
  }
}
