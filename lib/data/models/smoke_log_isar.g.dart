// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'smoke_log_isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSmokeLogIsarCollection on Isar {
  IsarCollection<SmokeLogIsar> get smokeLogIsars => this.collection();
}

const SmokeLogIsarSchema = CollectionSchema(
  name: r'SmokeLogIsar',
  id: -1403544242698834944,
  properties: {
    r'accountId': PropertySchema(
      id: 0,
      name: r'accountId',
      type: IsarType.string,
    ),
    r'accountTsIndex': PropertySchema(
      id: 1,
      name: r'accountTsIndex',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 2,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'deviceLocalId': PropertySchema(
      id: 3,
      name: r'deviceLocalId',
      type: IsarType.string,
    ),
    r'durationMs': PropertySchema(
      id: 4,
      name: r'durationMs',
      type: IsarType.long,
    ),
    r'isDirty': PropertySchema(
      id: 5,
      name: r'isDirty',
      type: IsarType.bool,
    ),
    r'lastSyncAt': PropertySchema(
      id: 6,
      name: r'lastSyncAt',
      type: IsarType.dateTime,
    ),
    r'logId': PropertySchema(
      id: 7,
      name: r'logId',
      type: IsarType.string,
    ),
    r'methodId': PropertySchema(
      id: 8,
      name: r'methodId',
      type: IsarType.string,
    ),
    r'moodScore': PropertySchema(
      id: 9,
      name: r'moodScore',
      type: IsarType.long,
    ),
    r'notes': PropertySchema(
      id: 10,
      name: r'notes',
      type: IsarType.string,
    ),
    r'physicalScore': PropertySchema(
      id: 11,
      name: r'physicalScore',
      type: IsarType.long,
    ),
    r'potency': PropertySchema(
      id: 12,
      name: r'potency',
      type: IsarType.long,
    ),
    r'syncError': PropertySchema(
      id: 13,
      name: r'syncError',
      type: IsarType.string,
    ),
    r'ts': PropertySchema(
      id: 14,
      name: r'ts',
      type: IsarType.dateTime,
    ),
    r'updatedAt': PropertySchema(
      id: 15,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _smokeLogIsarEstimateSize,
  serialize: _smokeLogIsarSerialize,
  deserialize: _smokeLogIsarDeserialize,
  deserializeProp: _smokeLogIsarDeserializeProp,
  idName: r'id',
  indexes: {
    r'logIdIdx': IndexSchema(
      id: 3700773556174249472,
      name: r'logIdIdx',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'logId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'accountIdx': IndexSchema(
      id: -1220630423637780992,
      name: r'accountIdx',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'accountId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'tsIdx': IndexSchema(
      id: -7009367181788102656,
      name: r'tsIdx',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'ts',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'dirtyIdx': IndexSchema(
      id: -1775459499094506496,
      name: r'dirtyIdx',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'isDirty',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'accountTsIdx': IndexSchema(
      id: -1407171561156630784,
      name: r'accountTsIdx',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'accountTsIndex',
          type: IndexType.hash,
          caseSensitive: true,
        ),
        IndexPropertySchema(
          name: r'accountId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
        IndexPropertySchema(
          name: r'ts',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _smokeLogIsarGetId,
  getLinks: _smokeLogIsarGetLinks,
  attach: _smokeLogIsarAttach,
  version: '3.1.0+1',
);

int _smokeLogIsarEstimateSize(
  SmokeLogIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.accountId.length * 3;
  bytesCount += 3 + object.accountTsIndex.length * 3;
  {
    final value = object.deviceLocalId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.logId.length * 3;
  {
    final value = object.methodId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.notes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.syncError;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _smokeLogIsarSerialize(
  SmokeLogIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.accountId);
  writer.writeString(offsets[1], object.accountTsIndex);
  writer.writeDateTime(offsets[2], object.createdAt);
  writer.writeString(offsets[3], object.deviceLocalId);
  writer.writeLong(offsets[4], object.durationMs);
  writer.writeBool(offsets[5], object.isDirty);
  writer.writeDateTime(offsets[6], object.lastSyncAt);
  writer.writeString(offsets[7], object.logId);
  writer.writeString(offsets[8], object.methodId);
  writer.writeLong(offsets[9], object.moodScore);
  writer.writeString(offsets[10], object.notes);
  writer.writeLong(offsets[11], object.physicalScore);
  writer.writeLong(offsets[12], object.potency);
  writer.writeString(offsets[13], object.syncError);
  writer.writeDateTime(offsets[14], object.ts);
  writer.writeDateTime(offsets[15], object.updatedAt);
}

SmokeLogIsar _smokeLogIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SmokeLogIsar();
  object.accountId = reader.readString(offsets[0]);
  object.createdAt = reader.readDateTime(offsets[2]);
  object.deviceLocalId = reader.readStringOrNull(offsets[3]);
  object.durationMs = reader.readLong(offsets[4]);
  object.id = id;
  object.isDirty = reader.readBool(offsets[5]);
  object.lastSyncAt = reader.readDateTimeOrNull(offsets[6]);
  object.logId = reader.readString(offsets[7]);
  object.methodId = reader.readStringOrNull(offsets[8]);
  object.moodScore = reader.readLong(offsets[9]);
  object.notes = reader.readStringOrNull(offsets[10]);
  object.physicalScore = reader.readLong(offsets[11]);
  object.potency = reader.readLongOrNull(offsets[12]);
  object.syncError = reader.readStringOrNull(offsets[13]);
  object.ts = reader.readDateTime(offsets[14]);
  object.updatedAt = reader.readDateTime(offsets[15]);
  return object;
}

P _smokeLogIsarDeserializeProp<P>(
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
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (reader.readLong(offset)) as P;
    case 12:
      return (reader.readLongOrNull(offset)) as P;
    case 13:
      return (reader.readStringOrNull(offset)) as P;
    case 14:
      return (reader.readDateTime(offset)) as P;
    case 15:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _smokeLogIsarGetId(SmokeLogIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _smokeLogIsarGetLinks(SmokeLogIsar object) {
  return [];
}

void _smokeLogIsarAttach(
    IsarCollection<dynamic> col, Id id, SmokeLogIsar object) {
  object.id = id;
}

extension SmokeLogIsarQueryWhereSort
    on QueryBuilder<SmokeLogIsar, SmokeLogIsar, QWhere> {
  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterWhere> anyTs() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'tsIdx'),
      );
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterWhere> anyIsDirty() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'dirtyIdx'),
      );
    });
  }
}

extension SmokeLogIsarQueryWhere
    on QueryBuilder<SmokeLogIsar, SmokeLogIsar, QWhereClause> {
  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterWhereClause> idBetween(
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

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterWhereClause> logIdEqualTo(
      String logId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'logIdIdx',
        value: [logId],
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterWhereClause> logIdNotEqualTo(
      String logId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'logIdIdx',
              lower: [],
              upper: [logId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'logIdIdx',
              lower: [logId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'logIdIdx',
              lower: [logId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'logIdIdx',
              lower: [],
              upper: [logId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterWhereClause> accountIdEqualTo(
      String accountId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'accountIdx',
        value: [accountId],
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterWhereClause>
      accountIdNotEqualTo(String accountId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'accountIdx',
              lower: [],
              upper: [accountId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'accountIdx',
              lower: [accountId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'accountIdx',
              lower: [accountId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'accountIdx',
              lower: [],
              upper: [accountId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterWhereClause> tsEqualTo(
      DateTime ts) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'tsIdx',
        value: [ts],
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterWhereClause> tsNotEqualTo(
      DateTime ts) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'tsIdx',
              lower: [],
              upper: [ts],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'tsIdx',
              lower: [ts],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'tsIdx',
              lower: [ts],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'tsIdx',
              lower: [],
              upper: [ts],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterWhereClause> tsGreaterThan(
    DateTime ts, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'tsIdx',
        lower: [ts],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterWhereClause> tsLessThan(
    DateTime ts, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'tsIdx',
        lower: [],
        upper: [ts],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterWhereClause> tsBetween(
    DateTime lowerTs,
    DateTime upperTs, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'tsIdx',
        lower: [lowerTs],
        includeLower: includeLower,
        upper: [upperTs],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterWhereClause> isDirtyEqualTo(
      bool isDirty) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'dirtyIdx',
        value: [isDirty],
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterWhereClause> isDirtyNotEqualTo(
      bool isDirty) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dirtyIdx',
              lower: [],
              upper: [isDirty],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dirtyIdx',
              lower: [isDirty],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dirtyIdx',
              lower: [isDirty],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dirtyIdx',
              lower: [],
              upper: [isDirty],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterWhereClause>
      accountTsIndexEqualToAnyAccountIdTs(String accountTsIndex) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'accountTsIdx',
        value: [accountTsIndex],
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterWhereClause>
      accountTsIndexNotEqualToAnyAccountIdTs(String accountTsIndex) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'accountTsIdx',
              lower: [],
              upper: [accountTsIndex],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'accountTsIdx',
              lower: [accountTsIndex],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'accountTsIdx',
              lower: [accountTsIndex],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'accountTsIdx',
              lower: [],
              upper: [accountTsIndex],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterWhereClause>
      accountTsIndexAccountIdEqualToAnyTs(
          String accountTsIndex, String accountId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'accountTsIdx',
        value: [accountTsIndex, accountId],
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterWhereClause>
      accountTsIndexEqualToAccountIdNotEqualToAnyTs(
          String accountTsIndex, String accountId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'accountTsIdx',
              lower: [accountTsIndex],
              upper: [accountTsIndex, accountId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'accountTsIdx',
              lower: [accountTsIndex, accountId],
              includeLower: false,
              upper: [accountTsIndex],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'accountTsIdx',
              lower: [accountTsIndex, accountId],
              includeLower: false,
              upper: [accountTsIndex],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'accountTsIdx',
              lower: [accountTsIndex],
              upper: [accountTsIndex, accountId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterWhereClause>
      accountTsIndexAccountIdTsEqualTo(
          String accountTsIndex, String accountId, DateTime ts) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'accountTsIdx',
        value: [accountTsIndex, accountId, ts],
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterWhereClause>
      accountTsIndexAccountIdEqualToTsNotEqualTo(
          String accountTsIndex, String accountId, DateTime ts) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'accountTsIdx',
              lower: [accountTsIndex, accountId],
              upper: [accountTsIndex, accountId, ts],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'accountTsIdx',
              lower: [accountTsIndex, accountId, ts],
              includeLower: false,
              upper: [accountTsIndex, accountId],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'accountTsIdx',
              lower: [accountTsIndex, accountId, ts],
              includeLower: false,
              upper: [accountTsIndex, accountId],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'accountTsIdx',
              lower: [accountTsIndex, accountId],
              upper: [accountTsIndex, accountId, ts],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterWhereClause>
      accountTsIndexAccountIdEqualToTsGreaterThan(
    String accountTsIndex,
    String accountId,
    DateTime ts, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'accountTsIdx',
        lower: [accountTsIndex, accountId, ts],
        includeLower: include,
        upper: [accountTsIndex, accountId],
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterWhereClause>
      accountTsIndexAccountIdEqualToTsLessThan(
    String accountTsIndex,
    String accountId,
    DateTime ts, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'accountTsIdx',
        lower: [accountTsIndex, accountId],
        upper: [accountTsIndex, accountId, ts],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterWhereClause>
      accountTsIndexAccountIdEqualToTsBetween(
    String accountTsIndex,
    String accountId,
    DateTime lowerTs,
    DateTime upperTs, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'accountTsIdx',
        lower: [accountTsIndex, accountId, lowerTs],
        includeLower: includeLower,
        upper: [accountTsIndex, accountId, upperTs],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension SmokeLogIsarQueryFilter
    on QueryBuilder<SmokeLogIsar, SmokeLogIsar, QFilterCondition> {
  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      accountIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'accountId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      accountIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'accountId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      accountIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'accountId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      accountIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'accountId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      accountIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'accountId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      accountIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'accountId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      accountIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'accountId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      accountIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'accountId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      accountIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'accountId',
        value: '',
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      accountIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'accountId',
        value: '',
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      accountTsIndexEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'accountTsIndex',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      accountTsIndexGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'accountTsIndex',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      accountTsIndexLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'accountTsIndex',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      accountTsIndexBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'accountTsIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      accountTsIndexStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'accountTsIndex',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      accountTsIndexEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'accountTsIndex',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      accountTsIndexContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'accountTsIndex',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      accountTsIndexMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'accountTsIndex',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      accountTsIndexIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'accountTsIndex',
        value: '',
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      accountTsIndexIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'accountTsIndex',
        value: '',
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      deviceLocalIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'deviceLocalId',
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      deviceLocalIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'deviceLocalId',
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      deviceLocalIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deviceLocalId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      deviceLocalIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'deviceLocalId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      deviceLocalIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'deviceLocalId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      deviceLocalIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'deviceLocalId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      deviceLocalIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'deviceLocalId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      deviceLocalIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'deviceLocalId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      deviceLocalIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'deviceLocalId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      deviceLocalIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'deviceLocalId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      deviceLocalIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deviceLocalId',
        value: '',
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      deviceLocalIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'deviceLocalId',
        value: '',
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      durationMsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'durationMs',
        value: value,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      durationMsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'durationMs',
        value: value,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      durationMsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'durationMs',
        value: value,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      durationMsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'durationMs',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition> idBetween(
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

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      isDirtyEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isDirty',
        value: value,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      lastSyncAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastSyncAt',
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      lastSyncAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastSyncAt',
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      lastSyncAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastSyncAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      lastSyncAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastSyncAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      lastSyncAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastSyncAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      lastSyncAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastSyncAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition> logIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'logId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      logIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'logId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition> logIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'logId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition> logIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'logId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      logIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'logId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition> logIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'logId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition> logIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'logId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition> logIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'logId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      logIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'logId',
        value: '',
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      logIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'logId',
        value: '',
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      methodIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'methodId',
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      methodIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'methodId',
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      methodIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'methodId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      methodIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'methodId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      methodIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'methodId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      methodIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'methodId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      methodIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'methodId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      methodIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'methodId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      methodIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'methodId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      methodIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'methodId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      methodIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'methodId',
        value: '',
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      methodIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'methodId',
        value: '',
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      moodScoreEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'moodScore',
        value: value,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      moodScoreGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'moodScore',
        value: value,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      moodScoreLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'moodScore',
        value: value,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      moodScoreBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'moodScore',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition> notesEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      notesGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition> notesLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition> notesBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'notes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      notesStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition> notesEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition> notesContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition> notesMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'notes',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      physicalScoreEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'physicalScore',
        value: value,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      physicalScoreGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'physicalScore',
        value: value,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      physicalScoreLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'physicalScore',
        value: value,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      physicalScoreBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'physicalScore',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      potencyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'potency',
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      potencyIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'potency',
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      potencyEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'potency',
        value: value,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      potencyGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'potency',
        value: value,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      potencyLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'potency',
        value: value,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      potencyBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'potency',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      syncErrorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'syncError',
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      syncErrorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'syncError',
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      syncErrorEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      syncErrorGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'syncError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      syncErrorLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'syncError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      syncErrorBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'syncError',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      syncErrorStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'syncError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      syncErrorEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'syncError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      syncErrorContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'syncError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      syncErrorMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'syncError',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      syncErrorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncError',
        value: '',
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      syncErrorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'syncError',
        value: '',
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition> tsEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ts',
        value: value,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition> tsGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ts',
        value: value,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition> tsLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ts',
        value: value,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition> tsBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ts',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      updatedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      updatedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterFilterCondition>
      updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension SmokeLogIsarQueryObject
    on QueryBuilder<SmokeLogIsar, SmokeLogIsar, QFilterCondition> {}

extension SmokeLogIsarQueryLinks
    on QueryBuilder<SmokeLogIsar, SmokeLogIsar, QFilterCondition> {}

extension SmokeLogIsarQuerySortBy
    on QueryBuilder<SmokeLogIsar, SmokeLogIsar, QSortBy> {
  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterSortBy> sortByAccountId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accountId', Sort.asc);
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterSortBy> sortByAccountIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accountId', Sort.desc);
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterSortBy>
      sortByAccountTsIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accountTsIndex', Sort.asc);
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterSortBy>
      sortByAccountTsIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accountTsIndex', Sort.desc);
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterSortBy> sortByDeviceLocalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceLocalId', Sort.asc);
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterSortBy>
      sortByDeviceLocalIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceLocalId', Sort.desc);
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterSortBy> sortByDurationMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationMs', Sort.asc);
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterSortBy>
      sortByDurationMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationMs', Sort.desc);
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterSortBy> sortByIsDirty() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDirty', Sort.asc);
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterSortBy> sortByIsDirtyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDirty', Sort.desc);
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterSortBy> sortByLastSyncAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncAt', Sort.asc);
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterSortBy>
      sortByLastSyncAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncAt', Sort.desc);
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterSortBy> sortByLogId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'logId', Sort.asc);
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterSortBy> sortByLogIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'logId', Sort.desc);
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterSortBy> sortByMethodId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'methodId', Sort.asc);
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterSortBy> sortByMethodIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'methodId', Sort.desc);
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterSortBy> sortByMoodScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'moodScore', Sort.asc);
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterSortBy> sortByMoodScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'moodScore', Sort.desc);
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterSortBy> sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterSortBy> sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterSortBy> sortByPhysicalScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'physicalScore', Sort.asc);
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterSortBy>
      sortByPhysicalScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'physicalScore', Sort.desc);
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterSortBy> sortByPotency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'potency', Sort.asc);
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterSortBy> sortByPotencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'potency', Sort.desc);
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterSortBy> sortBySyncError() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncError', Sort.asc);
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterSortBy> sortBySyncErrorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncError', Sort.desc);
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterSortBy> sortByTs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ts', Sort.asc);
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterSortBy> sortByTsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ts', Sort.desc);
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension SmokeLogIsarQuerySortThenBy
    on QueryBuilder<SmokeLogIsar, SmokeLogIsar, QSortThenBy> {
  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterSortBy> thenByAccountId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accountId', Sort.asc);
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterSortBy> thenByAccountIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accountId', Sort.desc);
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterSortBy>
      thenByAccountTsIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accountTsIndex', Sort.asc);
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterSortBy>
      thenByAccountTsIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accountTsIndex', Sort.desc);
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterSortBy> thenByDeviceLocalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceLocalId', Sort.asc);
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterSortBy>
      thenByDeviceLocalIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceLocalId', Sort.desc);
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterSortBy> thenByDurationMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationMs', Sort.asc);
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterSortBy>
      thenByDurationMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationMs', Sort.desc);
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterSortBy> thenByIsDirty() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDirty', Sort.asc);
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterSortBy> thenByIsDirtyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDirty', Sort.desc);
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterSortBy> thenByLastSyncAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncAt', Sort.asc);
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterSortBy>
      thenByLastSyncAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncAt', Sort.desc);
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterSortBy> thenByLogId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'logId', Sort.asc);
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterSortBy> thenByLogIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'logId', Sort.desc);
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterSortBy> thenByMethodId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'methodId', Sort.asc);
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterSortBy> thenByMethodIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'methodId', Sort.desc);
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterSortBy> thenByMoodScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'moodScore', Sort.asc);
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterSortBy> thenByMoodScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'moodScore', Sort.desc);
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterSortBy> thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterSortBy> thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterSortBy> thenByPhysicalScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'physicalScore', Sort.asc);
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterSortBy>
      thenByPhysicalScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'physicalScore', Sort.desc);
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterSortBy> thenByPotency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'potency', Sort.asc);
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterSortBy> thenByPotencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'potency', Sort.desc);
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterSortBy> thenBySyncError() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncError', Sort.asc);
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterSortBy> thenBySyncErrorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncError', Sort.desc);
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterSortBy> thenByTs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ts', Sort.asc);
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterSortBy> thenByTsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ts', Sort.desc);
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension SmokeLogIsarQueryWhereDistinct
    on QueryBuilder<SmokeLogIsar, SmokeLogIsar, QDistinct> {
  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QDistinct> distinctByAccountId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'accountId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QDistinct> distinctByAccountTsIndex(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'accountTsIndex',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QDistinct> distinctByDeviceLocalId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deviceLocalId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QDistinct> distinctByDurationMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'durationMs');
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QDistinct> distinctByIsDirty() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isDirty');
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QDistinct> distinctByLastSyncAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSyncAt');
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QDistinct> distinctByLogId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'logId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QDistinct> distinctByMethodId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'methodId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QDistinct> distinctByMoodScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'moodScore');
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QDistinct> distinctByNotes(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QDistinct>
      distinctByPhysicalScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'physicalScore');
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QDistinct> distinctByPotency() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'potency');
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QDistinct> distinctBySyncError(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncError', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QDistinct> distinctByTs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ts');
    });
  }

  QueryBuilder<SmokeLogIsar, SmokeLogIsar, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension SmokeLogIsarQueryProperty
    on QueryBuilder<SmokeLogIsar, SmokeLogIsar, QQueryProperty> {
  QueryBuilder<SmokeLogIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SmokeLogIsar, String, QQueryOperations> accountIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'accountId');
    });
  }

  QueryBuilder<SmokeLogIsar, String, QQueryOperations>
      accountTsIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'accountTsIndex');
    });
  }

  QueryBuilder<SmokeLogIsar, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<SmokeLogIsar, String?, QQueryOperations>
      deviceLocalIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deviceLocalId');
    });
  }

  QueryBuilder<SmokeLogIsar, int, QQueryOperations> durationMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'durationMs');
    });
  }

  QueryBuilder<SmokeLogIsar, bool, QQueryOperations> isDirtyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isDirty');
    });
  }

  QueryBuilder<SmokeLogIsar, DateTime?, QQueryOperations> lastSyncAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSyncAt');
    });
  }

  QueryBuilder<SmokeLogIsar, String, QQueryOperations> logIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'logId');
    });
  }

  QueryBuilder<SmokeLogIsar, String?, QQueryOperations> methodIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'methodId');
    });
  }

  QueryBuilder<SmokeLogIsar, int, QQueryOperations> moodScoreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'moodScore');
    });
  }

  QueryBuilder<SmokeLogIsar, String?, QQueryOperations> notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<SmokeLogIsar, int, QQueryOperations> physicalScoreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'physicalScore');
    });
  }

  QueryBuilder<SmokeLogIsar, int?, QQueryOperations> potencyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'potency');
    });
  }

  QueryBuilder<SmokeLogIsar, String?, QQueryOperations> syncErrorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncError');
    });
  }

  QueryBuilder<SmokeLogIsar, DateTime, QQueryOperations> tsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ts');
    });
  }

  QueryBuilder<SmokeLogIsar, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
