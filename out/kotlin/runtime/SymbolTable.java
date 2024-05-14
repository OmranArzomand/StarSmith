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

    Type anyType = new Type("Any");
    symbolTable.put(anyType);

    Type booleanType = new Type("Boolean");
    booleanType.supertypes.add(anyType);
    booleanType.operators.add(new Function("compareTo", booleanType, new CustomList<>(new Variable(booleanType))));
    booleanType.operators.add(new Function("equals", booleanType, new CustomList<>(new Variable(booleanType))));
    symbolTable.put(booleanType);

    Type intType = new Type("Int");
    intType.supertypes.add(anyType);
    intType.operators.add(new Function("plus", intType, new CustomList<>(new Variable(intType))));
    intType.operators.add(new Function("minus", intType, new CustomList<>(new Variable(intType))));
    intType.operators.add(new Function("times", intType, new CustomList<>(new Variable(intType))));
    intType.operators.add(new Function("div", intType, new CustomList<>(new Variable(intType))));
    intType.operators.add(new Function("rem", intType, new CustomList<>(new Variable(intType))));
    intType.operators.add(new Function("compareTo", booleanType, new CustomList<>(new Variable(intType))));
    intType.operators.add(new Function("equals", booleanType, new CustomList<>(new Variable(intType))));
    symbolTable.put(intType);


    Type stringType = new Type("String");
    stringType.supertypes.add(anyType);
    stringType.operators.add(new Function("compareTo", booleanType, new CustomList<>(new Variable(stringType))));
    stringType.operators.add(new Function("equals", booleanType, new CustomList<>(new Variable(stringType))));
    symbolTable.put(stringType);

    Type charType = new Type("Char");
    charType.supertypes.add(anyType);
    charType.operators.add(new Function("compareTo", booleanType, new CustomList<>(new Variable(charType))));
    charType.operators.add(new Function("equals", booleanType, new CustomList<>(new Variable(charType))));
    symbolTable.put(charType);

    Type unitType = new Type("Unit");
    unitType.supertypes.add(anyType);
    symbolTable.put(unitType);

    // Type nothingType = new Type("Nothing");
    // nothingType.supertypes.add(charType, stringType, booleanType, intType);
    // symbolTable.put(nothingType);

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

  public static final SymbolTable putAll(final SymbolTable symbolTable, final CustomList<Variable> symbols) {
    final SymbolTable clone = symbolTable.clone();

    for (Symbol symbol : symbols.items) {
      clone.put(symbol);
    }
    

    return clone;
  }

  // XXX performance could be improved
  public static final SymbolTable enterScope(final SymbolTable symbolTable) {
    final SymbolTable clone = symbolTable.clone();

    clone.scopes.add(new LinkedHashMap<String, Symbol>());

    return clone;
  }

  public static final SymbolTable exitScope(final SymbolTable symbolTable) {
    final SymbolTable clone = symbolTable.clone();

    clone.scopes.removeLast();

    return clone;
  }

  public static final SymbolTable merge(final SymbolTable first, final SymbolTable second) {
    final SymbolTable merged = new SymbolTable(true);

    for (final Map<String, Symbol> scope : first.scopes) {
      merged.scopes.add(scope);
    }

    for (final Map<String, Symbol> scope : second.scopes) {
      merged.scopes.add(scope);
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
        Symbol symbol = scope.get(name);
        if (!(symbol instanceof Type)) {
          continue;
        }
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

  public static final List<GeneratorResult> visibleBinaryOperators(final Type classType, final Type expectedType) {
    final List<GeneratorResult> operators = new LinkedList<>();


    for (Function operator : classType.operators.items) {
      if (operator.params.items.size() == 1 
          && (expectedType == null || Type.assignable(operator.returnType, expectedType))) {
            for (String opSymbol : Function.operatorNameToSymbols.get(operator.name)) {
              operators.add(new GeneratorResult(List.of(opSymbol, operator)));
            }
          }
    }
    System.out.println(operators);
    return operators;
  }

  public static final List<Type> visibleTypes(final SymbolTable symbolTable) {
    final List<Type> visibleTypes = new LinkedList<>();

    final LinkedHashMap<String, Symbol> flattened = flatten(symbolTable);
    for (final Symbol symbol : flattened.values()) {
      if (!(symbol instanceof Type)) {
        continue;
      }
      Type type = (Type) symbol;
      visibleTypes.add(type);
    }
    return visibleTypes;
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

  // public static final Type getClassWithPropertyAndType(final SymbolTable symbolTable,
  //     final String propertyName, final Type propertyType) {

  //   final LinkedHashMap<String, Symbol> flattened = flatten(symbolTable);
  //   for (final Symbol symbol : flattened.values()) {
  //     if (!(symbol instanceof Type)) {
  //       continue;
  //     }
  //     Type type = (Type) symbol;
  //     for (Variable property : type.properties.items) {
  //       if (property.name.equals(propertyName) && Type.assignable(property.type, propertyType)) {
  //         return type;
  //       }
  //     }
  //   }
  //   throw new RuntimeException("No class exists with property given property name");
  // }

  public static final List<Variable> visibleProperties(final Type classType,
      final Type expectedType) {
    final List<Variable> visibleProperties = new LinkedList<>();

    for (Variable variable : classType.properties.items) {
      if (expectedType == null || Type.assignable(variable.type, expectedType)) {
        visibleProperties.add(variable);
      }
    }

    return visibleProperties;
  }

  public static final List<Function> visibleFunctions(final SymbolTable symbolTable,
      final Type expectedReturnType) {
    final List<Function> visibleFunctions = new LinkedList<>();

    final LinkedHashMap<String, Symbol> flattened = flatten(symbolTable);
    for (final Symbol symbol : flattened.values()) {
      if (symbol instanceof Type) {
        Type type = (Type) symbol;
        if (expectedReturnType == null || Type.assignable(type, expectedReturnType)) {
          for (CustomList<Variable> constructorParams : type.constructors.items) {
            visibleFunctions.add(Function.create(type.name, type, constructorParams));
          }
        }
      } else if (symbol instanceof Function) {
        Function function = (Function) symbol;
        if (expectedReturnType == null || Type.assignable(function.returnType, expectedReturnType)) {
          visibleFunctions.add(function);
        }
      }
    }
    return visibleFunctions;
  }

  public static final List<Function> visibleMemberFunctions(final Type calleeType, final Type expectedReturnType) {
    final List<Function> visibleMemberFunctions = new ArrayList<>();

    for (Function function : calleeType.memberFunctions.items) {
      if (Type.assignable(function.returnType, expectedReturnType)) {
        visibleMemberFunctions.add(function);
      }
    }
    return visibleMemberFunctions;
  }

  public static final List<CustomList<Variable>> visibleConstructors(final Type type) {
    return type.constructors.items;
  }

  public static final Type getKotlinAnyType(SymbolTable symbolTable) {
    return SymbolTable.getAsType(symbolTable, "Any");
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

  // public static final SymbolTable removeNonProperties(final SymbolTable symbolTable, 
  //   final CustomList<Variable> constructorParams, final CustomList<Variable> properties) {
  //     if (constructorParams == null) {
  //       return symbolTable;
  //     }

  //     final SymbolTable clone = symbolTable.clone();

  //     for (Variable param : constructorParams.items) {
  //       boolean isProperty = false;
  //       for (Variable property : properties.items) {
  //         if (property.name.equals(param.name)) {
  //           isProperty = true;
  //           break;
  //         }
  //       }
  //       if (!isProperty) {
  //         final Map<String, Symbol> containingScope = getContainingScope(clone, param.name);
  //         containingScope.remove(param.name);
  //       }
  //     }
  //     return clone;
  //   }

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
