// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asset_cache.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAssetCacheCollection on Isar {
  IsarCollection<AssetCache> get assetCaches => this.collection();
}

const AssetCacheSchema = CollectionSchema(
  name: r'AssetCache',
  id: -3103391673878389043,
  properties: {
    r'currentPrice': PropertySchema(
      id: 0,
      name: r'currentPrice',
      type: IsarType.double,
    ),
    r'customCategories': PropertySchema(
      id: 1,
      name: r'customCategories',
      type: IsarType.stringList,
    ),
    r'historicalDataJson': PropertySchema(
      id: 2,
      name: r'historicalDataJson',
      type: IsarType.string,
    ),
    r'isWatchlisted': PropertySchema(
      id: 3,
      name: r'isWatchlisted',
      type: IsarType.bool,
    ),
    r'lastUpdated': PropertySchema(
      id: 4,
      name: r'lastUpdated',
      type: IsarType.dateTime,
    ),
    r'marketType': PropertySchema(
      id: 5,
      name: r'marketType',
      type: IsarType.string,
    ),
    r'name': PropertySchema(
      id: 6,
      name: r'name',
      type: IsarType.string,
    ),
    r'priceChange24h': PropertySchema(
      id: 7,
      name: r'priceChange24h',
      type: IsarType.double,
    ),
    r'sortOrder': PropertySchema(
      id: 8,
      name: r'sortOrder',
      type: IsarType.long,
    ),
    r'symbol': PropertySchema(
      id: 9,
      name: r'symbol',
      type: IsarType.string,
    )
  },
  estimateSize: _assetCacheEstimateSize,
  serialize: _assetCacheSerialize,
  deserialize: _assetCacheDeserialize,
  deserializeProp: _assetCacheDeserializeProp,
  idName: r'id',
  indexes: {
    r'symbol': IndexSchema(
      id: -7050953154795990356,
      name: r'symbol',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'symbol',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _assetCacheGetId,
  getLinks: _assetCacheGetLinks,
  attach: _assetCacheAttach,
  version: '3.1.0+1',
);

int _assetCacheEstimateSize(
  AssetCache object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.customCategories.length * 3;
  {
    for (var i = 0; i < object.customCategories.length; i++) {
      final value = object.customCategories[i];
      bytesCount += value.length * 3;
    }
  }
  {
    final value = object.historicalDataJson;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.marketType.length * 3;
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.symbol.length * 3;
  return bytesCount;
}

void _assetCacheSerialize(
  AssetCache object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.currentPrice);
  writer.writeStringList(offsets[1], object.customCategories);
  writer.writeString(offsets[2], object.historicalDataJson);
  writer.writeBool(offsets[3], object.isWatchlisted);
  writer.writeDateTime(offsets[4], object.lastUpdated);
  writer.writeString(offsets[5], object.marketType);
  writer.writeString(offsets[6], object.name);
  writer.writeDouble(offsets[7], object.priceChange24h);
  writer.writeLong(offsets[8], object.sortOrder);
  writer.writeString(offsets[9], object.symbol);
}

AssetCache _assetCacheDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AssetCache();
  object.currentPrice = reader.readDouble(offsets[0]);
  object.customCategories = reader.readStringList(offsets[1]) ?? [];
  object.historicalDataJson = reader.readStringOrNull(offsets[2]);
  object.isWatchlisted = reader.readBool(offsets[3]);
  object.lastUpdated = reader.readDateTime(offsets[4]);
  object.marketType = reader.readString(offsets[5]);
  object.name = reader.readString(offsets[6]);
  object.priceChange24h = reader.readDouble(offsets[7]);
  object.sortOrder = reader.readLong(offsets[8]);
  object.symbol = reader.readString(offsets[9]);
  return object;
}

P _assetCacheDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readStringList(offset) ?? []) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readDouble(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _assetCacheGetId(AssetCache object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _assetCacheGetLinks(AssetCache object) {
  return [];
}

void _assetCacheAttach(IsarCollection<dynamic> col, Id id, AssetCache object) {}

extension AssetCacheByIndex on IsarCollection<AssetCache> {
  Future<AssetCache?> getBySymbol(String symbol) {
    return getByIndex(r'symbol', [symbol]);
  }

  AssetCache? getBySymbolSync(String symbol) {
    return getByIndexSync(r'symbol', [symbol]);
  }

  Future<bool> deleteBySymbol(String symbol) {
    return deleteByIndex(r'symbol', [symbol]);
  }

  bool deleteBySymbolSync(String symbol) {
    return deleteByIndexSync(r'symbol', [symbol]);
  }

  Future<List<AssetCache?>> getAllBySymbol(List<String> symbolValues) {
    final values = symbolValues.map((e) => [e]).toList();
    return getAllByIndex(r'symbol', values);
  }

  List<AssetCache?> getAllBySymbolSync(List<String> symbolValues) {
    final values = symbolValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'symbol', values);
  }

  Future<int> deleteAllBySymbol(List<String> symbolValues) {
    final values = symbolValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'symbol', values);
  }

  int deleteAllBySymbolSync(List<String> symbolValues) {
    final values = symbolValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'symbol', values);
  }

  Future<Id> putBySymbol(AssetCache object) {
    return putByIndex(r'symbol', object);
  }

  Id putBySymbolSync(AssetCache object, {bool saveLinks = true}) {
    return putByIndexSync(r'symbol', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllBySymbol(List<AssetCache> objects) {
    return putAllByIndex(r'symbol', objects);
  }

  List<Id> putAllBySymbolSync(List<AssetCache> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'symbol', objects, saveLinks: saveLinks);
  }
}

extension AssetCacheQueryWhereSort
    on QueryBuilder<AssetCache, AssetCache, QWhere> {
  QueryBuilder<AssetCache, AssetCache, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AssetCacheQueryWhere
    on QueryBuilder<AssetCache, AssetCache, QWhereClause> {
  QueryBuilder<AssetCache, AssetCache, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<AssetCache, AssetCache, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterWhereClause> idBetween(
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

  QueryBuilder<AssetCache, AssetCache, QAfterWhereClause> symbolEqualTo(
      String symbol) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'symbol',
        value: [symbol],
      ));
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterWhereClause> symbolNotEqualTo(
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
}

extension AssetCacheQueryFilter
    on QueryBuilder<AssetCache, AssetCache, QFilterCondition> {
  QueryBuilder<AssetCache, AssetCache, QAfterFilterCondition>
      currentPriceEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currentPrice',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterFilterCondition>
      currentPriceGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'currentPrice',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterFilterCondition>
      currentPriceLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'currentPrice',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterFilterCondition>
      currentPriceBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'currentPrice',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterFilterCondition>
      customCategoriesElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'customCategories',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterFilterCondition>
      customCategoriesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'customCategories',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterFilterCondition>
      customCategoriesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'customCategories',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterFilterCondition>
      customCategoriesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'customCategories',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterFilterCondition>
      customCategoriesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'customCategories',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterFilterCondition>
      customCategoriesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'customCategories',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterFilterCondition>
      customCategoriesElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'customCategories',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterFilterCondition>
      customCategoriesElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'customCategories',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterFilterCondition>
      customCategoriesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'customCategories',
        value: '',
      ));
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterFilterCondition>
      customCategoriesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'customCategories',
        value: '',
      ));
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterFilterCondition>
      customCategoriesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'customCategories',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterFilterCondition>
      customCategoriesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'customCategories',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterFilterCondition>
      customCategoriesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'customCategories',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterFilterCondition>
      customCategoriesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'customCategories',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterFilterCondition>
      customCategoriesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'customCategories',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterFilterCondition>
      customCategoriesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'customCategories',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterFilterCondition>
      historicalDataJsonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'historicalDataJson',
      ));
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterFilterCondition>
      historicalDataJsonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'historicalDataJson',
      ));
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterFilterCondition>
      historicalDataJsonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'historicalDataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterFilterCondition>
      historicalDataJsonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'historicalDataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterFilterCondition>
      historicalDataJsonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'historicalDataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterFilterCondition>
      historicalDataJsonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'historicalDataJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterFilterCondition>
      historicalDataJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'historicalDataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterFilterCondition>
      historicalDataJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'historicalDataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterFilterCondition>
      historicalDataJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'historicalDataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterFilterCondition>
      historicalDataJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'historicalDataJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterFilterCondition>
      historicalDataJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'historicalDataJson',
        value: '',
      ));
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterFilterCondition>
      historicalDataJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'historicalDataJson',
        value: '',
      ));
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<AssetCache, AssetCache, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<AssetCache, AssetCache, QAfterFilterCondition> idBetween(
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

  QueryBuilder<AssetCache, AssetCache, QAfterFilterCondition>
      isWatchlistedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isWatchlisted',
        value: value,
      ));
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterFilterCondition>
      lastUpdatedEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterFilterCondition>
      lastUpdatedGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterFilterCondition>
      lastUpdatedLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterFilterCondition>
      lastUpdatedBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastUpdated',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterFilterCondition> marketTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'marketType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterFilterCondition>
      marketTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'marketType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterFilterCondition>
      marketTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'marketType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterFilterCondition> marketTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'marketType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterFilterCondition>
      marketTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'marketType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterFilterCondition>
      marketTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'marketType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterFilterCondition>
      marketTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'marketType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterFilterCondition> marketTypeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'marketType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterFilterCondition>
      marketTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'marketType',
        value: '',
      ));
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterFilterCondition>
      marketTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'marketType',
        value: '',
      ));
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterFilterCondition> nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterFilterCondition> nameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterFilterCondition>
      priceChange24hEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'priceChange24h',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterFilterCondition>
      priceChange24hGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'priceChange24h',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterFilterCondition>
      priceChange24hLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'priceChange24h',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterFilterCondition>
      priceChange24hBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'priceChange24h',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterFilterCondition> sortOrderEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sortOrder',
        value: value,
      ));
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterFilterCondition>
      sortOrderGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sortOrder',
        value: value,
      ));
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterFilterCondition> sortOrderLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sortOrder',
        value: value,
      ));
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterFilterCondition> sortOrderBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sortOrder',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterFilterCondition> symbolEqualTo(
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

  QueryBuilder<AssetCache, AssetCache, QAfterFilterCondition> symbolGreaterThan(
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

  QueryBuilder<AssetCache, AssetCache, QAfterFilterCondition> symbolLessThan(
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

  QueryBuilder<AssetCache, AssetCache, QAfterFilterCondition> symbolBetween(
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

  QueryBuilder<AssetCache, AssetCache, QAfterFilterCondition> symbolStartsWith(
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

  QueryBuilder<AssetCache, AssetCache, QAfterFilterCondition> symbolEndsWith(
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

  QueryBuilder<AssetCache, AssetCache, QAfterFilterCondition> symbolContains(
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

  QueryBuilder<AssetCache, AssetCache, QAfterFilterCondition> symbolMatches(
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

  QueryBuilder<AssetCache, AssetCache, QAfterFilterCondition> symbolIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'symbol',
        value: '',
      ));
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterFilterCondition>
      symbolIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'symbol',
        value: '',
      ));
    });
  }
}

extension AssetCacheQueryObject
    on QueryBuilder<AssetCache, AssetCache, QFilterCondition> {}

extension AssetCacheQueryLinks
    on QueryBuilder<AssetCache, AssetCache, QFilterCondition> {}

extension AssetCacheQuerySortBy
    on QueryBuilder<AssetCache, AssetCache, QSortBy> {
  QueryBuilder<AssetCache, AssetCache, QAfterSortBy> sortByCurrentPrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentPrice', Sort.asc);
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterSortBy> sortByCurrentPriceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentPrice', Sort.desc);
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterSortBy>
      sortByHistoricalDataJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'historicalDataJson', Sort.asc);
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterSortBy>
      sortByHistoricalDataJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'historicalDataJson', Sort.desc);
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterSortBy> sortByIsWatchlisted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isWatchlisted', Sort.asc);
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterSortBy> sortByIsWatchlistedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isWatchlisted', Sort.desc);
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterSortBy> sortByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterSortBy> sortByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterSortBy> sortByMarketType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'marketType', Sort.asc);
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterSortBy> sortByMarketTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'marketType', Sort.desc);
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterSortBy> sortByPriceChange24h() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priceChange24h', Sort.asc);
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterSortBy>
      sortByPriceChange24hDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priceChange24h', Sort.desc);
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterSortBy> sortBySortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.asc);
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterSortBy> sortBySortOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.desc);
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterSortBy> sortBySymbol() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'symbol', Sort.asc);
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterSortBy> sortBySymbolDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'symbol', Sort.desc);
    });
  }
}

extension AssetCacheQuerySortThenBy
    on QueryBuilder<AssetCache, AssetCache, QSortThenBy> {
  QueryBuilder<AssetCache, AssetCache, QAfterSortBy> thenByCurrentPrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentPrice', Sort.asc);
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterSortBy> thenByCurrentPriceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentPrice', Sort.desc);
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterSortBy>
      thenByHistoricalDataJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'historicalDataJson', Sort.asc);
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterSortBy>
      thenByHistoricalDataJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'historicalDataJson', Sort.desc);
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterSortBy> thenByIsWatchlisted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isWatchlisted', Sort.asc);
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterSortBy> thenByIsWatchlistedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isWatchlisted', Sort.desc);
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterSortBy> thenByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterSortBy> thenByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterSortBy> thenByMarketType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'marketType', Sort.asc);
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterSortBy> thenByMarketTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'marketType', Sort.desc);
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterSortBy> thenByPriceChange24h() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priceChange24h', Sort.asc);
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterSortBy>
      thenByPriceChange24hDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priceChange24h', Sort.desc);
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterSortBy> thenBySortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.asc);
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterSortBy> thenBySortOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.desc);
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterSortBy> thenBySymbol() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'symbol', Sort.asc);
    });
  }

  QueryBuilder<AssetCache, AssetCache, QAfterSortBy> thenBySymbolDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'symbol', Sort.desc);
    });
  }
}

extension AssetCacheQueryWhereDistinct
    on QueryBuilder<AssetCache, AssetCache, QDistinct> {
  QueryBuilder<AssetCache, AssetCache, QDistinct> distinctByCurrentPrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currentPrice');
    });
  }

  QueryBuilder<AssetCache, AssetCache, QDistinct> distinctByCustomCategories() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'customCategories');
    });
  }

  QueryBuilder<AssetCache, AssetCache, QDistinct> distinctByHistoricalDataJson(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'historicalDataJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AssetCache, AssetCache, QDistinct> distinctByIsWatchlisted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isWatchlisted');
    });
  }

  QueryBuilder<AssetCache, AssetCache, QDistinct> distinctByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUpdated');
    });
  }

  QueryBuilder<AssetCache, AssetCache, QDistinct> distinctByMarketType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'marketType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AssetCache, AssetCache, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AssetCache, AssetCache, QDistinct> distinctByPriceChange24h() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'priceChange24h');
    });
  }

  QueryBuilder<AssetCache, AssetCache, QDistinct> distinctBySortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sortOrder');
    });
  }

  QueryBuilder<AssetCache, AssetCache, QDistinct> distinctBySymbol(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'symbol', caseSensitive: caseSensitive);
    });
  }
}

extension AssetCacheQueryProperty
    on QueryBuilder<AssetCache, AssetCache, QQueryProperty> {
  QueryBuilder<AssetCache, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AssetCache, double, QQueryOperations> currentPriceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currentPrice');
    });
  }

  QueryBuilder<AssetCache, List<String>, QQueryOperations>
      customCategoriesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'customCategories');
    });
  }

  QueryBuilder<AssetCache, String?, QQueryOperations>
      historicalDataJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'historicalDataJson');
    });
  }

  QueryBuilder<AssetCache, bool, QQueryOperations> isWatchlistedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isWatchlisted');
    });
  }

  QueryBuilder<AssetCache, DateTime, QQueryOperations> lastUpdatedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUpdated');
    });
  }

  QueryBuilder<AssetCache, String, QQueryOperations> marketTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'marketType');
    });
  }

  QueryBuilder<AssetCache, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<AssetCache, double, QQueryOperations> priceChange24hProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'priceChange24h');
    });
  }

  QueryBuilder<AssetCache, int, QQueryOperations> sortOrderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sortOrder');
    });
  }

  QueryBuilder<AssetCache, String, QQueryOperations> symbolProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'symbol');
    });
  }
}
