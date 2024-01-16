package runtime;

import i2.act.fuzzer.runtime.Printable;

import java.util.Objects;

public final class Symbol implements Printable {

  public static final Symbol create(final String name, final Type type) {
    return new Symbol(name, type, false);
  }

  public static final Symbol create(final String name, final Type type, final Boolean isConst) {
    return new Symbol(name, type, isConst);
  }

  public static final String getName(final Symbol symbol) {
    return symbol.name;
  }

  public static final Type getType(final Symbol symbol) {
    return symbol.type;
  }

  public static final Boolean getIsConst(final Symbol symbol) {
    return symbol.isConst;
  }

  // -----------------------------------------------------------------------------------------------

  public final String name;
  public final Type type;
  public final Boolean isConst;

  public Symbol(final String name, final Type type) {
    this.name = name;
    this.type = type;
    this.isConst = false;
  }

  public Symbol(final String name, final Type type, final Boolean isConst) {
    this.name = name;
    this.type = type;
    this.isConst = isConst;
  }

  @Override
  public final boolean equals(final Object other) {
    if (!(other instanceof Symbol)) {
      return false;
    }

    final Symbol otherSymbol = (Symbol) other;

    return Objects.equals(this.name, otherSymbol.name)
        && Objects.equals(this.type, otherSymbol.type)
        && Objects.equals(this.isConst, otherSymbol.isConst);
  }

  @Override
  public final int hashCode() {
    return Objects.hash(this.name, this.type, this.isConst);
  }

  @Override
  public final String toString() {
    return String.format("(%s, %s, %s)", this.name, this.type, this.isConst);
  }

  @Override
  public final String print() {
    return this.name;
  }

}
