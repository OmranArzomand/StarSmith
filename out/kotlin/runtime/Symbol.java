package runtime;

import i2.act.fuzzer.runtime.Printable;

import java.util.Objects;

public final class Symbol implements Printable {

  public static final Symbol create(final String name, final Type type) {
    return new Symbol(name, type, false, false);
  }

  public static final Symbol create(final String name, final Type type, final Boolean isConst, final Boolean isInitialised) {
    return new Symbol(name, type, isConst, isInitialised);
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

  public static final Boolean getIsInitialised(final Symbol symbol) {
    return symbol.isInitialised;
  }

  // -----------------------------------------------------------------------------------------------

  public final String name;
  public final Type type;
  public final Boolean isConst;
  public final Boolean isInitialised;

  public Symbol(final String name, final Type type) {
    this.name = name;
    this.type = type;
    this.isConst = false;
    this.isInitialised = false;
  }

  public Symbol(final String name, final Type type, final Boolean isConst, Boolean isInitialised) {
    this.name = name;
    this.type = type;
    this.isConst = isConst;
    this.isInitialised = isInitialised;
  }

  @Override
  public final boolean equals(final Object other) {
    if (!(other instanceof Symbol)) {
      return false;
    }

    final Symbol otherSymbol = (Symbol) other;

    return Objects.equals(this.name, otherSymbol.name)
        && Objects.equals(this.type, otherSymbol.type)
        && Objects.equals(this.isConst, otherSymbol.isConst)
        && Objects.equals(this.isInitialised, otherSymbol.isInitialised);
  }

  @Override
  public final int hashCode() {
    return Objects.hash(this.name, this.type, this.isConst, this.isInitialised);
  }

  @Override
  public final String toString() {
    return String.format("(%s, %s, %s, %s)", this.name, this.type, this.isConst, this.isInitialised);
  }

  @Override
  public final String print() {
    return this.name;
  }

}
