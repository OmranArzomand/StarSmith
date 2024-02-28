package runtime;

import java.util.ArrayList;

import i2.act.fuzzer.runtime.Printable;

import java.util.Objects;
import java.util.List;

public class CustomList<T> implements Printable {
	public final List<T> items;

  public CustomList(T item) {
    this.items = new ArrayList<>();
    this.items.add(item);
  }

  public CustomList() {
    this.items = new ArrayList<>();
  }
    
  public static <U> CustomList<U> create(U item) {
    return new CustomList<U>(item);
  }
    
  public static <U> U get(CustomList<U> list, int index) {
    return list.items.get(index);
  }

  public static <U> CustomList<U> prepend(CustomList<U> list, U item) {
    CustomList<U> newList = new CustomList<>(item);
    for (U i : list.items) {
      newList.items.add(i);
    }
    return newList;
  }

  public static <U> CustomList<U> getTail(CustomList<U> list) {
    CustomList<U> newList = new CustomList<U>();
    for (int i = 1; i < list.items.size(); i++) {
      newList.items.add(list.items.get(i));
    }
    return newList;
  }

  public static <U> U getHead(CustomList<U> list) {
    return list.items.get(0);
  }

  public static <U> int getSize(CustomList<U> list) {
    return list.items.size();
  }

  public static Variable asVariable(Object o) {
    return (Variable) o;
  }

  @Override
  public boolean equals(Object obj) {
    if (!(obj instanceof CustomList)) {
      return false;
    }
    CustomList otherList = (CustomList) obj;
    return Objects.equals(this.items, otherList.items);
  }

  @Override
  public int hashCode() {
    return Objects.hash(this.items);
  }

  @Override
  public final String toString() {
    return this.items.toString();
  }

  @Override
  public final String print() {
    return this.items.toString();
  }
}