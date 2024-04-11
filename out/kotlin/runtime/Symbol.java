package runtime;

import i2.act.fuzzer.runtime.Printable;

import java.util.Objects;

import javax.lang.model.element.VariableElement;


public class Symbol implements Printable {

  public final String name;

  public Symbol(String name) {
    this.name = name;
  }

  public Symbol clone() {
    return new Symbol(name);
  }

  public static final String getName(final Symbol symbol) {
    return symbol.name;
  }

  public static final Function asFunction(final Symbol symbol) {
    if (!(symbol instanceof Function)) {
      throw new RuntimeException("Invalid cast of Symbol to Function");
    }
    return (Function) symbol;
  }

  public static final Variable asVariable(final Symbol symbol) {
    if (!(symbol instanceof Variable)) {
      throw new RuntimeException("Invalid cast of Symbol to Variable");
    }
    return (Variable) symbol;
  }

  @Override
  public boolean equals(Object obj) {
    if (!(obj instanceof Symbol)) {
      return false;
    }
    return Objects.equals(this.name, ((Symbol) obj).name);
  }

  @Override
  public int hashCode() {
    return Objects.hash(this.name);
  }

  @Override
  public String toString() {
    return String.format("(%s)", this.name);
  }

  @Override
  public String print() {
    return this.name;
  }
}