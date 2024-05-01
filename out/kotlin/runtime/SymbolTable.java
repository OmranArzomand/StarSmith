package runtime;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

public final class SymbolTable {

  public static final SymbolTable init() {
    SymbolTable symbolTable = new SymbolTable(true);
    IntType intType = new IntType(IntType.name());
    symbolTable.put(intType);
    symbolTable.put(new AnyType(AnyType.name()));
    symbolTable.put(new UnitType(UnitType.name()));
    symbolTable.put(new BooleanType(BooleanType.name()));
    symbolTable.put(new StringType(StringType.name()));
    symbolTable.put(new CharType(CharType.name()));
    symbolTable.put(new Function("maxOf", intType, new CustomList<Variable>(
      new Variable("x", intType, true, false), new Variable("y", intType, true, false))));
    return symbolTable;
  }

  public static final SymbolTable put(final SymbolTable symbolTable, final Symbol... symbols) {
    final SymbolTable clone = symbolTable.clone();

    for (Symbol symbol : symbols) {
      clone.put(symbol);
    }
    

    return clone;
  }

  public static final SymbolTable putAllNew(final SymbolTable symbolTable, CustomList<Variable> symbols) {
    final SymbolTable clone = symbolTable.clone();

    for (Symbol symbol : symbols.items) {
      if (!symbolTable.scopes.getLast().containsKey(symbol.name)) {
        clone.put(symbol);
      } 
    }

    return clone;
  }

  // XXX performance could be improved
  public static final SymbolTable enterScope(final SymbolTable symbolTable) {
    final SymbolTable clone = symbolTable.clone();

    clone.scopes.add(new LinkedHashMap<String, Symbol>());

    return clone;
  }

  public static final SymbolTable merge(final SymbolTable first, final SymbolTable second) {
    final SymbolTable merged = new SymbolTable(true);

    for (final Map<String, Symbol> scope : first.scopes) {
      for (final Symbol symbol : scope.values()) {
        merged.put(symbol);
      }
    }

    for (final Map<String, Symbol> scope : second.scopes) {
      for (final Symbol symbol : scope.values()) {
        merged.put(symbol);
      }
    }

    return merged;
  }

  public static final boolean mayDefine(final SymbolTable symbolTable, final String name) {
    return !symbolTable.scopes.getLast().containsKey(name) 
      && !name.equals("this") && !name.equals("is");
  }

  public static final Symbol get(final SymbolTable symbolTable, final String name) {
    final Iterator<Map<String, Symbol>> scopeIterator = symbolTable.scopes.descendingIterator();
    while (scopeIterator.hasNext()) {
      final Map<String, Symbol> scope = scopeIterator.next();

      if (scope.containsKey(name)) {
        return scope.get(name);
      }
    }

    throw new RuntimeException("name not defined");
  }

  public static final Type getAsType(final SymbolTable symbolTable, final String name) {
    final Iterator<Map<String, Symbol>> scopeIterator = symbolTable.scopes.descendingIterator();
    while (scopeIterator.hasNext()) {
      final Map<String, Symbol> scope = scopeIterator.next();

      if (scope.containsKey(name)) {
        return (Type) scope.get(name);
      }
    }

    throw new RuntimeException("name not defined");
  }

  public static final Type getAsType(final SymbolTable symbolTable, final String name, boolean b) {
   
    final Iterator<Map<String, Symbol>> scopeIterator = symbolTable.scopes.descendingIterator();
    while (scopeIterator.hasNext()) {
      final Map<String, Symbol> scope = scopeIterator.next();

      if (scope.containsKey(name)) {
        return (Type) scope.get(name);
      }
    }

    throw new RuntimeException("name not defined");
  }

  public static final boolean contains(final SymbolTable symbolTable, final String name) {
    final Iterator<Map<String, Symbol>> scopeIterator = symbolTable.scopes.descendingIterator();
    while (scopeIterator.hasNext()) {
      final Map<String, Symbol> scope = scopeIterator.next();

      if (scope.containsKey(name)) {
        return true;
      }
    }

    return false;
  }

  private static final LinkedHashMap<String, Symbol> flatten(final SymbolTable symbolTable) {
    final LinkedHashMap<String, Symbol> flattened = new LinkedHashMap<>();

    for (final Map<String, Symbol> scope : symbolTable.scopes) {
      for (final Symbol symbol : scope.values()) {
        flattened.put(symbol.name, symbol);
      }
    }

    return flattened;
  }

  public static final List<String> visibleTypeNames(final SymbolTable symbolTable) {
    final List<String> visibleTypeNames = new LinkedList<>();

    final LinkedHashMap<String, Symbol> flattened = flatten(symbolTable);
    for (final Symbol symbol : flattened.values()) {
      if (!(symbol instanceof Type)) {
        continue;
      }
      Type type = (Type) symbol;
      visibleTypeNames.add(type.name);
    }
    return visibleTypeNames;
  }

  public static final List<Variable> visibleVariables(final SymbolTable symbolTable,
      final Type expectedType) {
    final List<Variable> visibleVariables = new LinkedList<>();

    final LinkedHashMap<String, Symbol> flattened = flatten(symbolTable);
    for (final Symbol symbol : flattened.values()) {
      if (!(symbol instanceof Variable)) {
        continue;
      }
      Variable variable = (Variable) symbol;
      if (expectedType == null || Type.assignable(variable.type, expectedType)) {
        visibleVariables.add(variable);
      }
    }

    return visibleVariables;
  }

  public static final List<Variable> visibleVariables(final SymbolTable symbolTable) {
    return visibleVariables(symbolTable, null);
  }

  public static final List<String> visibleVariableNames(final SymbolTable symbolTable,
      final Type expectedType) {
    final List<String> visibleVariableNames = new LinkedList<>();

    final LinkedHashMap<String, Symbol> flattened = flatten(symbolTable);
    for (final Symbol symbol : flattened.values()) {
      if (!(symbol instanceof Variable)) {
        continue;
      }
      Variable variable = (Variable) symbol;
      if (expectedType == null || Type.assignable(variable.type, expectedType)) {
        visibleVariableNames.add(variable.name);
      }
    }

    return visibleVariableNames;
  }

  public static final List<String> visibleVariableNames(final SymbolTable symbolTable) {
    return visibleVariableNames(symbolTable, null);
  }

  public static final Type getClassWithPropertyAndType(final SymbolTable symbolTable,
      final String propertyName, final Type propertyType) {

    final LinkedHashMap<String, Symbol> flattened = flatten(symbolTable);
    for (final Symbol symbol : flattened.values()) {
      if (!(symbol instanceof Type)) {
        continue;
      }
      Type type = (Type) symbol;
      for (Variable property : type.properties.items) {
        if (property.name.equals(propertyName) && Type.assignable(property.type, propertyType)) {
          return type;
        }
      }
    }
    throw new RuntimeException("No class exists with property given property name");
  }

  public static final List<String> visiblePropertyNames(final SymbolTable symbolTable,
      final Type expectedType) {
    final List<String> visiblePropertyNames = new LinkedList<>();

    final LinkedHashMap<String, Symbol> flattened = flatten(symbolTable);
    for (final Symbol symbol : flattened.values()) {
      if (!(symbol instanceof Type)) {
        continue;
      }
      Type type = (Type) symbol;
      for (Variable property : type.properties.items) {
        if (expectedType == null || Type.assignable(property.type, expectedType)) {
          visiblePropertyNames.add(property.name);
        }
      }
    }
    return visiblePropertyNames;
  }

  public static final List<String> visiblePropertyNames(final SymbolTable symbolTable) {
    return visiblePropertyNames(symbolTable, null);
  }

  public static final List<String> visibleFunctionNames(final SymbolTable symbolTable,
      final Type expectedReturnType) {
    final List<String> visibleFunctioneNames = new LinkedList<>();

    final LinkedHashMap<String, Symbol> flattened = flatten(symbolTable);
    for (final Symbol symbol : flattened.values()) {
      Function function;
      if (symbol instanceof Type) {
        Type type = (Type) symbol;
        if (type.constructors.items.size() == 0) {
          continue;
        }
        int randomIndex = (int) (Math.random() * type.constructors.items.size());
        CustomList<Variable> params = type.constructors.items.get(randomIndex);
        function = Function.create(type.name, type, params);
      } else if (symbol instanceof Function){
        function = (Function) symbol;
      } else {
        continue;
      }
      if (expectedReturnType == null || Type.assignable(function.returnType, expectedReturnType)) {
        visibleFunctioneNames.add(function.name);
      }
    }
    return visibleFunctioneNames;
  }

  public static final List<String> visibleFunctionNames(final SymbolTable symbolTable) {
    return visibleFunctionNames(symbolTable, null);
  }

  public static final List<String> visibleMemberFunctionNames(final SymbolTable symbolTable,
      final Type calleeType, final Type expectedReturnType) {
    final List<String> visibleMemberFunctionNames = new ArrayList<>();

    for (Map.Entry<String, Function> entry : calleeType.memberFunctions.entrySet()) {
      if (Type.assignable(entry.getValue().returnType, expectedReturnType)) {
        visibleMemberFunctionNames.add(entry.getKey());
      }
    }

    return visibleMemberFunctionNames;
  }

  public static final SymbolTable removeAll(final SymbolTable symbolTable, 
    final CustomList<Variable> variables) {
      if (variables == null) {
        return symbolTable;
      }
      final SymbolTable clone = symbolTable.clone();
      
      for (Variable var : variables.items) {
        final Map<String, Symbol> containingScope = getContainingScope(clone, var.name);
        if (containingScope != null) {
          containingScope.remove(var.name);
        }
      }

      return clone;
    }

  public static final SymbolTable removeNonProperties(final SymbolTable symbolTable, 
    final CustomList<Variable> constructorParams, final CustomList<Variable> properties) {
      if (constructorParams == null) {
        return symbolTable;
      }

      final SymbolTable clone = symbolTable.clone();

      for (Variable param : constructorParams.items) {
        boolean isProperty = false;
        for (Variable property : properties.items) {
          if (property.name.equals(param.name)) {
            isProperty = true;
            break;
          }
        }
        if (!isProperty) {
          final Map<String, Symbol> containingScope = getContainingScope(clone, param.name);
          containingScope.remove(param.name);
        }
      }
      return clone;
    }

  public static final SymbolTable setIsInitialised(final SymbolTable symbolTable,
      final Variable variable, final Boolean isInitialised) {
    
    final SymbolTable clone = symbolTable.clone();


    final Variable newVariable = new Variable(variable.name, variable.type, variable.isMutable, variable.isInitialised);

    final Map<String, Symbol> containingScope = getContainingScope(clone, variable.name);

    containingScope.remove(variable.name);
    containingScope.put(variable.name, newVariable);
    return clone;
  }

  private static final Map<String, Symbol> getContainingScope(final SymbolTable symbolTable,
      final String name) {
    final Iterator<Map<String, Symbol>> scopeIterator = symbolTable.scopes.descendingIterator();
    while (scopeIterator.hasNext()) {
      final Map<String, Symbol> scope = scopeIterator.next();

      if (scope.containsKey(name)) {
        return scope;
      }
    }

    return null;
  }

  // -----------------------------------------------------------------------------------------------

  public final LinkedList<Map<String, Symbol>> scopes;

  public SymbolTable(final boolean addScope) {
    this.scopes = new LinkedList<Map<String, Symbol>>();

    if (addScope) {
      this.scopes.add(new LinkedHashMap<String, Symbol>());
    }
  }

  public final SymbolTable clone() {
    final SymbolTable clone = new SymbolTable(false);

    for (final Map<String, Symbol> scope : this.scopes) {
      clone.scopes.add(new LinkedHashMap<String, Symbol>(scope));
    }

    return clone;
  }

  public final void put(final Symbol symbol) {
    this.scopes.getLast().put(symbol.name, symbol);
  }

  @Override
  public final boolean equals(final Object other) {
    if (!(other instanceof SymbolTable)) {
      return false;
    }

    final SymbolTable otherSymbolTable = (SymbolTable) other;
    return this.scopes.equals(otherSymbolTable.scopes);
  }

  @Override
  public final int hashCode() {
    throw new RuntimeException("hashCode() not supported");
  }

  @Override
  public final String toString() {
    final StringBuilder builder = new StringBuilder();

    builder.append("[");

    boolean firstScope = true;
    for (final Map<String, Symbol> scope : this.scopes) {
      if (!firstScope) {
        builder.append(", ");
      }
      firstScope = false;

      builder.append("{");

      boolean firstEntry = true;
      for (final Map.Entry<String, Symbol> entry : scope.entrySet()) {
        if (!firstEntry) {
          builder.append(", ");
        }
        firstEntry = false;

        builder.append(String.format("%s: %s", entry.getKey(), entry.getValue()));
      }

      builder.append("}");
    }

    builder.append("]");

    return builder.toString();
  }

}
