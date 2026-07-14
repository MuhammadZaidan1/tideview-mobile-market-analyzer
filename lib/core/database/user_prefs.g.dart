// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_prefs.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetUserPrefsCollection on Isar {
  IsarCollection<UserPrefs> get userPrefs => this.collection();
}

const UserPrefsSchema = CollectionSchema(
  name: r'UserPrefs',
  id: -38711120304771490,
  properties: {
    r'activeThemeHex': PropertySchema(
      id: 0,
      name: r'activeThemeHex',
      type: IsarType.string,
    ),
    r'baseCurrency': PropertySchema(
      id: 1,
      name: r'baseCurrency',
      type: IsarType.string,
    ),
    r'exchangeRate': PropertySchema(
      id: 2,
      name: r'exchangeRate',
      type: IsarType.double,
    ),
    r'isDarkMode': PropertySchema(
      id: 3,
      name: r'isDarkMode',
      type: IsarType.bool,
    ),
    r'languageCode': PropertySchema(
      id: 4,
      name: r'languageCode',
      type: IsarType.string,
    ),
    r'lastCryptoSyncTime': PropertySchema(
      id: 5,
      name: r'lastCryptoSyncTime',
      type: IsarType.dateTime,
    ),
    r'syncIntervalMinutes': PropertySchema(
      id: 6,
      name: r'syncIntervalMinutes',
      type: IsarType.long,
    ),
    r'widgetAssetSymbol': PropertySchema(
      id: 7,
      name: r'widgetAssetSymbol',
      type: IsarType.string,
    )
  },
  estimateSize: _userPrefsEstimateSize,
  serialize: _userPrefsSerialize,
  deserialize: _userPrefsDeserialize,
  deserializeProp: _userPrefsDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _userPrefsGetId,
  getLinks: _userPrefsGetLinks,
  attach: _userPrefsAttach,
  version: '3.1.0+1',
);

int _userPrefsEstimateSize(
  UserPrefs object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.activeThemeHex.length * 3;
  bytesCount += 3 + object.baseCurrency.length * 3;
  bytesCount += 3 + object.languageCode.length * 3;
  bytesCount += 3 + object.widgetAssetSymbol.length * 3;
  return bytesCount;
}

void _userPrefsSerialize(
  UserPrefs object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.activeThemeHex);
  writer.writeString(offsets[1], object.baseCurrency);
  writer.writeDouble(offsets[2], object.exchangeRate);
  writer.writeBool(offsets[3], object.isDarkMode);
  writer.writeString(offsets[4], object.languageCode);
  writer.writeDateTime(offsets[5], object.lastCryptoSyncTime);
  writer.writeLong(offsets[6], object.syncIntervalMinutes);
  writer.writeString(offsets[7], object.widgetAssetSymbol);
}

UserPrefs _userPrefsDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = UserPrefs();
  object.activeThemeHex = reader.readString(offsets[0]);
  object.baseCurrency = reader.readString(offsets[1]);
  object.exchangeRate = reader.readDouble(offsets[2]);
  object.id = id;
  object.isDarkMode = reader.readBool(offsets[3]);
  object.languageCode = reader.readString(offsets[4]);
  object.lastCryptoSyncTime = reader.readDateTimeOrNull(offsets[5]);
  object.syncIntervalMinutes = reader.readLong(offsets[6]);
  object.widgetAssetSymbol = reader.readString(offsets[7]);
  return object;
}

P _userPrefsDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _userPrefsGetId(UserPrefs object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _userPrefsGetLinks(UserPrefs object) {
  return [];
}

void _userPrefsAttach(IsarCollection<dynamic> col, Id id, UserPrefs object) {
  object.id = id;
}

extension UserPrefsQueryWhereSort
    on QueryBuilder<UserPrefs, UserPrefs, QWhere> {
  QueryBuilder<UserPrefs, UserPrefs, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension UserPrefsQueryWhere
    on QueryBuilder<UserPrefs, UserPrefs, QWhereClause> {
  QueryBuilder<UserPrefs, UserPrefs, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<UserPrefs, UserPrefs, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterWhereClause> idBetween(
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
}

extension UserPrefsQueryFilter
    on QueryBuilder<UserPrefs, UserPrefs, QFilterCondition> {
  QueryBuilder<UserPrefs, UserPrefs, QAfterFilterCondition>
      activeThemeHexEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activeThemeHex',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterFilterCondition>
      activeThemeHexGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'activeThemeHex',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterFilterCondition>
      activeThemeHexLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'activeThemeHex',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterFilterCondition>
      activeThemeHexBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'activeThemeHex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterFilterCondition>
      activeThemeHexStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'activeThemeHex',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterFilterCondition>
      activeThemeHexEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'activeThemeHex',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterFilterCondition>
      activeThemeHexContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'activeThemeHex',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterFilterCondition>
      activeThemeHexMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'activeThemeHex',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterFilterCondition>
      activeThemeHexIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activeThemeHex',
        value: '',
      ));
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterFilterCondition>
      activeThemeHexIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'activeThemeHex',
        value: '',
      ));
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterFilterCondition> baseCurrencyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'baseCurrency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterFilterCondition>
      baseCurrencyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'baseCurrency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterFilterCondition>
      baseCurrencyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'baseCurrency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterFilterCondition> baseCurrencyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'baseCurrency',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterFilterCondition>
      baseCurrencyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'baseCurrency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterFilterCondition>
      baseCurrencyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'baseCurrency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterFilterCondition>
      baseCurrencyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'baseCurrency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterFilterCondition> baseCurrencyMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'baseCurrency',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterFilterCondition>
      baseCurrencyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'baseCurrency',
        value: '',
      ));
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterFilterCondition>
      baseCurrencyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'baseCurrency',
        value: '',
      ));
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterFilterCondition> exchangeRateEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'exchangeRate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterFilterCondition>
      exchangeRateGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'exchangeRate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterFilterCondition>
      exchangeRateLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'exchangeRate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterFilterCondition> exchangeRateBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'exchangeRate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<UserPrefs, UserPrefs, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<UserPrefs, UserPrefs, QAfterFilterCondition> idBetween(
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

  QueryBuilder<UserPrefs, UserPrefs, QAfterFilterCondition> isDarkModeEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isDarkMode',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterFilterCondition> languageCodeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'languageCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterFilterCondition>
      languageCodeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'languageCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterFilterCondition>
      languageCodeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'languageCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterFilterCondition> languageCodeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'languageCode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterFilterCondition>
      languageCodeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'languageCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterFilterCondition>
      languageCodeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'languageCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterFilterCondition>
      languageCodeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'languageCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterFilterCondition> languageCodeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'languageCode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterFilterCondition>
      languageCodeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'languageCode',
        value: '',
      ));
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterFilterCondition>
      languageCodeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'languageCode',
        value: '',
      ));
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterFilterCondition>
      lastCryptoSyncTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastCryptoSyncTime',
      ));
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterFilterCondition>
      lastCryptoSyncTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastCryptoSyncTime',
      ));
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterFilterCondition>
      lastCryptoSyncTimeEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastCryptoSyncTime',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterFilterCondition>
      lastCryptoSyncTimeGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastCryptoSyncTime',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterFilterCondition>
      lastCryptoSyncTimeLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastCryptoSyncTime',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterFilterCondition>
      lastCryptoSyncTimeBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastCryptoSyncTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterFilterCondition>
      syncIntervalMinutesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncIntervalMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterFilterCondition>
      syncIntervalMinutesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'syncIntervalMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterFilterCondition>
      syncIntervalMinutesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'syncIntervalMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterFilterCondition>
      syncIntervalMinutesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'syncIntervalMinutes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterFilterCondition>
      widgetAssetSymbolEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'widgetAssetSymbol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterFilterCondition>
      widgetAssetSymbolGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'widgetAssetSymbol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterFilterCondition>
      widgetAssetSymbolLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'widgetAssetSymbol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterFilterCondition>
      widgetAssetSymbolBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'widgetAssetSymbol',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterFilterCondition>
      widgetAssetSymbolStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'widgetAssetSymbol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterFilterCondition>
      widgetAssetSymbolEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'widgetAssetSymbol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterFilterCondition>
      widgetAssetSymbolContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'widgetAssetSymbol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterFilterCondition>
      widgetAssetSymbolMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'widgetAssetSymbol',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterFilterCondition>
      widgetAssetSymbolIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'widgetAssetSymbol',
        value: '',
      ));
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterFilterCondition>
      widgetAssetSymbolIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'widgetAssetSymbol',
        value: '',
      ));
    });
  }
}

extension UserPrefsQueryObject
    on QueryBuilder<UserPrefs, UserPrefs, QFilterCondition> {}

extension UserPrefsQueryLinks
    on QueryBuilder<UserPrefs, UserPrefs, QFilterCondition> {}

extension UserPrefsQuerySortBy on QueryBuilder<UserPrefs, UserPrefs, QSortBy> {
  QueryBuilder<UserPrefs, UserPrefs, QAfterSortBy> sortByActiveThemeHex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeThemeHex', Sort.asc);
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterSortBy> sortByActiveThemeHexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeThemeHex', Sort.desc);
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterSortBy> sortByBaseCurrency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baseCurrency', Sort.asc);
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterSortBy> sortByBaseCurrencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baseCurrency', Sort.desc);
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterSortBy> sortByExchangeRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exchangeRate', Sort.asc);
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterSortBy> sortByExchangeRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exchangeRate', Sort.desc);
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterSortBy> sortByIsDarkMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDarkMode', Sort.asc);
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterSortBy> sortByIsDarkModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDarkMode', Sort.desc);
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterSortBy> sortByLanguageCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'languageCode', Sort.asc);
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterSortBy> sortByLanguageCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'languageCode', Sort.desc);
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterSortBy> sortByLastCryptoSyncTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCryptoSyncTime', Sort.asc);
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterSortBy>
      sortByLastCryptoSyncTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCryptoSyncTime', Sort.desc);
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterSortBy> sortBySyncIntervalMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncIntervalMinutes', Sort.asc);
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterSortBy>
      sortBySyncIntervalMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncIntervalMinutes', Sort.desc);
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterSortBy> sortByWidgetAssetSymbol() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'widgetAssetSymbol', Sort.asc);
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterSortBy>
      sortByWidgetAssetSymbolDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'widgetAssetSymbol', Sort.desc);
    });
  }
}

extension UserPrefsQuerySortThenBy
    on QueryBuilder<UserPrefs, UserPrefs, QSortThenBy> {
  QueryBuilder<UserPrefs, UserPrefs, QAfterSortBy> thenByActiveThemeHex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeThemeHex', Sort.asc);
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterSortBy> thenByActiveThemeHexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeThemeHex', Sort.desc);
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterSortBy> thenByBaseCurrency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baseCurrency', Sort.asc);
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterSortBy> thenByBaseCurrencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baseCurrency', Sort.desc);
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterSortBy> thenByExchangeRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exchangeRate', Sort.asc);
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterSortBy> thenByExchangeRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exchangeRate', Sort.desc);
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterSortBy> thenByIsDarkMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDarkMode', Sort.asc);
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterSortBy> thenByIsDarkModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDarkMode', Sort.desc);
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterSortBy> thenByLanguageCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'languageCode', Sort.asc);
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterSortBy> thenByLanguageCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'languageCode', Sort.desc);
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterSortBy> thenByLastCryptoSyncTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCryptoSyncTime', Sort.asc);
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterSortBy>
      thenByLastCryptoSyncTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCryptoSyncTime', Sort.desc);
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterSortBy> thenBySyncIntervalMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncIntervalMinutes', Sort.asc);
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterSortBy>
      thenBySyncIntervalMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncIntervalMinutes', Sort.desc);
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterSortBy> thenByWidgetAssetSymbol() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'widgetAssetSymbol', Sort.asc);
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QAfterSortBy>
      thenByWidgetAssetSymbolDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'widgetAssetSymbol', Sort.desc);
    });
  }
}

extension UserPrefsQueryWhereDistinct
    on QueryBuilder<UserPrefs, UserPrefs, QDistinct> {
  QueryBuilder<UserPrefs, UserPrefs, QDistinct> distinctByActiveThemeHex(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'activeThemeHex',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QDistinct> distinctByBaseCurrency(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'baseCurrency', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QDistinct> distinctByExchangeRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'exchangeRate');
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QDistinct> distinctByIsDarkMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isDarkMode');
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QDistinct> distinctByLanguageCode(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'languageCode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QDistinct> distinctByLastCryptoSyncTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastCryptoSyncTime');
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QDistinct>
      distinctBySyncIntervalMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncIntervalMinutes');
    });
  }

  QueryBuilder<UserPrefs, UserPrefs, QDistinct> distinctByWidgetAssetSymbol(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'widgetAssetSymbol',
          caseSensitive: caseSensitive);
    });
  }
}

extension UserPrefsQueryProperty
    on QueryBuilder<UserPrefs, UserPrefs, QQueryProperty> {
  QueryBuilder<UserPrefs, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<UserPrefs, String, QQueryOperations> activeThemeHexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'activeThemeHex');
    });
  }

  QueryBuilder<UserPrefs, String, QQueryOperations> baseCurrencyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'baseCurrency');
    });
  }

  QueryBuilder<UserPrefs, double, QQueryOperations> exchangeRateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'exchangeRate');
    });
  }

  QueryBuilder<UserPrefs, bool, QQueryOperations> isDarkModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isDarkMode');
    });
  }

  QueryBuilder<UserPrefs, String, QQueryOperations> languageCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'languageCode');
    });
  }

  QueryBuilder<UserPrefs, DateTime?, QQueryOperations>
      lastCryptoSyncTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastCryptoSyncTime');
    });
  }

  QueryBuilder<UserPrefs, int, QQueryOperations> syncIntervalMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncIntervalMinutes');
    });
  }

  QueryBuilder<UserPrefs, String, QQueryOperations>
      widgetAssetSymbolProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'widgetAssetSymbol');
    });
  }
}
