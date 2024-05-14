package runtime;

import i2.act.fuzzer.runtime.Printable;
import java.util.Objects;
import java.util.List;
import java.util.ArrayList;

public class GeneratorResult implements Printable {

  public final List<Object> results;

  public GeneratorResult(List results) {
    this.results = results;
  }

  public static final Object get(GeneratorResult results, int index) {
    return results.results.get(index);
  }

  public static final Type asType(Object o) {
    return (Type) o;
  }

  public static final Function asFunction(Object o) {
    return (Function) o;
  }

  @Override
  public final boolean equals(Object other) {
    if (!(other instanceof GeneratorResult)) {
      return false;
    }
    GeneratorResult otherGeneratorResult = (GeneratorResult) other;
    return otherGeneratorResult.results.get(0).equals(this.results.get(0));
  }

  @Override
  public final String toString() {
    return results.get(0).toString();
  }

  @Override
  public final String print() {
    return results.get(0).toString();
  }
}
