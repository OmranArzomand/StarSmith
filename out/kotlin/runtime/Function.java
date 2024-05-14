package runtime;

import i2.act.fuzzer.runtime.Printable;
import java.util.Objects;
import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import java.util.HashMap;

public class Function extends Symbol implements Printable {

  public final Type returnType;
  public final CustomList<Variable> params;

  public Function(String name, Type returnType, CustomList<Variable> params) {
    super(name);
    this.returnType = returnType;
    this.params = params;
  }

  @Override
  public Function clone() {
    List<Variable> paramClones = new ArrayList<>();
    for (Variable param : params.items) {
      paramClones.add(param);
    }
    return new Function(name, returnType.clone(), new CustomList<>(paramClones));
  }

  public static Function create(String name, Type returnType, CustomList<Variable> params) {
    return new Function(name, returnType, params);
  }

  public static CustomList<Variable> getParams(Function function) {
    return function.params;
  }

  public static Type getReturnType(Function function) {
    return function.returnType;
  }

  @Override
  public boolean equals(Object obj) {
    if (!(obj instanceof Function)) {
      return false;
    }

    final Function otherFunction = (Function) obj;

    return Objects.equals(this.name, otherFunction.name)
      && Objects.equals(this.returnType, otherFunction.returnType)
      && Objects.equals(this.params, otherFunction.params);
  }

  public static final Map<String, List<String>> operatorNameToSymbols = new HashMap<>() {{
    put("plus", List.of("+"));
    put("times", List.of("*"));
    put("div", List.of("/"));
    put("rem", List.of("%"));
    put("minus", List.of("-"));
    put("compareTo", List.of(">", "<", ">=", "<="));
    put("equals", List.of("==", "!="));
  }};

  @Override
  public int hashCode() {
    return Objects.hash(this.name, this.returnType, this.params);
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
