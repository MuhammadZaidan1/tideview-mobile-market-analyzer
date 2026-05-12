// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'price_alert.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPriceAlertCollection on Isar {
  IsarCollection<PriceAlert> get priceAlerts => this.collection();
}

const PriceAlertSchema = CollectionSchema(
  name: r'PriceAlert',
  id: -5963392935112613731,
  properties: {
    r'isAbove': PropertySchema(
      id: 0,
      name: r'isAbove',
      type: IsarType.bool,
    ),
    r'isActive': PropertySchema(
      id: 1,
      name: r'isActive',
      type: IsarType.bool,
    ),
    r'symbol': PropertySchema(
      id: 2,
      name: r'symbol',
      type: IsarType.string,
    ),
    r'targetPrice': PropertySchema(
      id: 3,
      name: r'targetPrice',
      type: IsarType.double,
    )
  },
  estimateSize: _priceAlertEstimateSize,
  serialize: _priceAlertSerialize,
  deserialize: _priceAlertDeserialize,
  deserializeProp: _priceAlertDeserializeProp,
  idName: r'id',
  indexes: {
    r'symbol': IndexSchema(
      id: -7050953154795990356,
      name: r'symbol',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'symbol',
          type: IndexType.value,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _priceAlertGetId,
  getLinks: _priceAlertGetLinks,
  attach: _priceAlertAttach,
  version: '3.1.0+1',
);

int _priceAlertEstimateSize(
  PriceAlert object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.symbol.length * 3;
  return bytesCount;
}

void _priceAlertSerialize(
  PriceAlert object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.isAbove);
  writer.writeBool(offsets[1], object.isActive);
  writer.writeString(offsets[2], object.symbol);
  writer.writeDouble(offsets[3], object.targetPrice);
}

PriceAlert _priceAlertDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PriceAlert();
  object.id = id;
  object.isAbove = reader.readBool(offsets[0]);
  object.isActive = reader.readBool(offsets[1]);
  object.symbol = reader.readString(offsets[2]);
  object.targetPrice = reader.readDouble(offsets[3]);
  return object;
}

P _priceAlertDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _priceAlertGetId(PriceAlert object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _priceAlertGetLinks(PriceAlert object) {
  return [];
}

void _priceAlertAttach(IsarCollection<dynamic> col, Id id, PriceAlert object) {
  object.id = id;
}

extension PriceAlertQueryWhereSort
    on QueryBuilder<PriceAlert, PriceAlert, QWhere> {
  QueryBuilder<PriceAlert, PriceAlert, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<PriceAlert, PriceAlert, QAfterWhere> anySymbol() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'symbol'),
      );
    });
  }
}

extension PriceAlertQueryWhere
    on QueryBuilder<PriceAlert, PriceAlert, QWhereClause> {
  QueryBuilder<PriceAlert, PriceAlert, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<PriceAlert, PriceAlert, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<PriceAlert, PriceAlert, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PriceAlert, PriceAlert, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PriceAlert, PriceAlert, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PriceAlert, PriceAlert, QAfterWhereClause> symbolEqualTo(
      String symbol) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'symbol',
        value: [symbol],
      ));
    });
  }

  QueryBuilder<PriceAlert, PriceAlert, QAfterWhereClause> symbolNotEqualTo(
      String symbol) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'symbol',
              lower: [],
              upper: [symbol],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'symbol',
              lower: [symbol],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'symbol',
              lower: [symbol],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'symbol',
              lower: [],
              upper: [symbol],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<PriceAlert, PriceAlert, QAfterWhereClause> symbolGreaterThan(
    String symbol, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'symbol',
        lower: [symbol],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<PriceAlert, PriceAlert, QAfterWhereClause> symbolLessThan(
    String symbol, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'symbol',
        lower: [],
        upper: [symbol],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<PriceAlert, PriceAlert, QAfterWhereClause> symbolBetween(
    String lowerSymbol,
    String upperSymbol, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'symbol',
        lower: [lowerSymbol],
        includeLower: includeLower,
        upper: [upperSymbol],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PriceAlert, PriceAlert, QAfterWhereClause> symbolStartsWith(
      String SymbolPrefix) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'symbol',
        lower: [SymbolPrefix],
        upper: ['$SymbolPrefix\u{FFFFF}'],
      ));
    });
  }

  QueryBuilder<PriceAlert, PriceAlert, QAfterWhereClause> symbolIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'symbol',
        value: [''],
      ));
    });
  }

  QueryBuilder<PriceAlert, PriceAlert, QAfterWhereClause> symbolIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.lessThan(
              indexName: r'symbol',
              upper: [''],
            ))
            .addWhereClause(IndexWhereClause.greaterThan(
              indexName: r'symbol',
              lower: [''],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.greaterThan(
              indexName: r'symbol',
              lower: [''],
            ))
            .addWhereClause(IndexWhereClause.lessThan(
              indexName: r'symbol',
              upper: [''],
            ));
      }
    });
  }
}

extension PriceAlertQueryFilter
    on QueryBuilder<PriceAlert, PriceAlert, QFilterCondition> {
  QueryBuilder<PriceAlert, PriceAlert, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PriceAlert, PriceAlert, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PriceAlert, PriceAlert, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PriceAlert, PriceAlert, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PriceAlert, PriceAlert, QAfterFilterCondition> isAboveEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isAbove',
        value: value,
      ));
    });
  }

  QueryBuilder<PriceAlert, PriceAlert, QAfterFilterCondition> isActiveEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isActive',
        value: value,
      ));
    });
  }

  QueryBuilder<PriceAlert, PriceAlert, QAfterFilterCondition> symbolEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'symbol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PriceAlert, PriceAlert, QAfterFilterCondition> symbolGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'symbol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PriceAlert, PriceAlert, QAfterFilterCondition> symbolLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'symbol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PriceAlert, PriceAlert, QAfterFilterCondition> symbolBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'symbol',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PriceAlert, PriceAlert, QAfterFilterCondition> symbolStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'symbol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PriceAlert, PriceAlert, QAfterFilterCondition> symbolEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'symbol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PriceAlert, PriceAlert, QAfterFilterCondition> symbolContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'symbol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PriceAlert, PriceAlert, QAfterFilterCondition> symbolMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'symbol',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PriceAlert, PriceAlert, QAfterFilterCondition> symbolIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'symbol',
        value: '',
      ));
    });
  }

  QueryBuilder<PriceAlert, PriceAlert, QAfterFilterCondition>
      symbolIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'symbol',
        value: '',
      ));
    });
  }

  QueryBuilder<PriceAlert, PriceAlert, QAfterFilterCondition>
      targetPriceEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'targetPrice',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PriceAlert, PriceAlert, QAfterFilterCondition>
      targetPriceGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'targetPrice',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PriceAlert, PriceAlert, QAfterFilterCondition>
      targetPriceLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'targetPrice',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PriceAlert, PriceAlert, QAfterFilterCondition>
      targetPriceBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'targetPrice',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension PriceAlertQueryObject
    on QueryBuilder<PriceAlert, PriceAlert, QFilterCondition> {}

extension PriceAlertQueryLinks
    on QueryBuilder<PriceAlert, PriceAlert, QFilterCondition> {}

extension PriceAlertQuerySortBy
    on QueryBuilder<PriceAlert, PriceAlert, QSortBy> {
  QueryBuilder<PriceAlert, PriceAlert, QAfterSortBy> sortByIsAbove() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAbove', Sort.asc);
    });
  }

  QueryBuilder<PriceAlert, PriceAlert, QAfterSortBy> sortByIsAboveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAbove', Sort.desc);
    });
  }

  QueryBuilder<PriceAlert, PriceAlert, QAfterSortBy> sortByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<PriceAlert, PriceAlert, QAfterSortBy> sortByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<PriceAlert, PriceAlert, QAfterSortBy> sortBySymbol() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'symbol', Sort.asc);
    });
  }

  QueryBuilder<PriceAlert, PriceAlert, QAfterSortBy> sortBySymbolDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'symbol', Sort.desc);
    });
  }

  QueryBuilder<PriceAlert, PriceAlert, QAfterSortBy> sortByTargetPrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetPrice', Sort.asc);
    });
  }

  QueryBuilder<PriceAlert, PriceAlert, QAfterSortBy> sortByTargetPriceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetPrice', Sort.desc);
    });
  }
}

extension PriceAlertQuerySortThenBy
    on QueryBuilder<PriceAlert, PriceAlert, QSortThenBy> {
  QueryBuilder<PriceAlert, PriceAlert, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PriceAlert, PriceAlert, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PriceAlert, PriceAlert, QAfterSortBy> thenByIsAbove() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAbove', Sort.asc);
    });
  }

  QueryBuilder<PriceAlert, PriceAlert, QAfterSortBy> thenByIsAboveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAbove', Sort.desc);
    });
  }

  QueryBuilder<PriceAlert, PriceAlert, QAfterSortBy> thenByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<PriceAlert, PriceAlert, QAfterSortBy> thenByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<PriceAlert, PriceAlert, QAfterSortBy> thenBySymbol() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'symbol', Sort.asc);
    });
  }

  QueryBuilder<PriceAlert, PriceAlert, QAfterSortBy> thenBySymbolDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'symbol', Sort.desc);
    });
  }

  QueryBuilder<PriceAlert, PriceAlert, QAfterSortBy> thenByTargetPrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetPrice', Sort.asc);
    });
  }

  QueryBuilder<PriceAlert, PriceAlert, QAfterSortBy> thenByTargetPriceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetPrice', Sort.desc);
    });
  }
}

extension PriceAlertQueryWhereDistinct
    on QueryBuilder<PriceAlert, PriceAlert, QDistinct> {
  QueryBuilder<PriceAlert, PriceAlert, QDistinct> distinctByIsAbove() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isAbove');
    });
  }

  QueryBuilder<PriceAlert, PriceAlert, QDistinct> distinctByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isActive');
    });
  }

  QueryBuilder<PriceAlert, PriceAlert, QDistinct> distinctBySymbol(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'symbol', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PriceAlert, PriceAlert, QDistinct> distinctByTargetPrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'targetPrice');
    });
  }
}

extension PriceAlertQueryProperty
    on QueryBuilder<PriceAlert, PriceAlert, QQueryProperty> {
  QueryBuilder<PriceAlert, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PriceAlert, bool, QQueryOperations> isAboveProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isAbove');
    });
  }

  QueryBuilder<PriceAlert, bool, QQueryOperations> isActiveProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isActive');
    });
  }

  QueryBuilder<PriceAlert, String, QQueryOperations> symbolProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'symbol');
    });
  }

  QueryBuilder<PriceAlert, double, QQueryOperations> targetPriceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'targetPrice');
    });
  }
}
