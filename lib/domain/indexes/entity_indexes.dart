// GENERATED - DO NOT EDIT.
/// Per-entity index field groupings.
const Map<String, List<List<String>>> entityIndexes = {
  'SmokeLog': [
    ['accountId', 'ts'],
  ],
  'SmokeLogTag': [
    ['smokeLogId'],
    ['tagId'],
    ['accountId', 'tagId'],
    ['accountId', 'tagId', 'ts'],
  ],
  'Reason': [
    ['accountId', 'orderIndex'],
    ['accountId', 'name'],
  ],
  'SmokeLogReason': [
    ['smokeLogId'],
    ['reasonId'],
    ['accountId', 'reasonId'],
    ['accountId', 'reasonId', 'ts'],
  ],
  'FilterPreset': [
    ['accountId', 'updatedAt'],
  ],
  'Goal': [
    ['accountId', 'active'],
  ],
  'Rule': [
    ['accountId', 'enabled'],
  ],
  'RuleTrigger': [
    ['ruleId', 'triggeredAt'],
  ],
  'ImportItem': [
    ['batchId', 'status'],
  ],
  'PushToken': [
    ['deviceId', 'active'],
  ],
  'Device': [
    ['platform'],
  ],
  'AuthIdentity': [
    ['accountId', 'provider'],
  ],
  'Session': [
    ['accountId', 'status'],
  ],
  'SyncOp': [
    ['accountId', 'status', 'createdAt'],
  ],
  'ImportBatch': [
    ['accountId', 'startedAt'],
  ],
  'ChartView': [
    ['accountId', 'updatedAt'],
  ],
  'StatsDaily': [
    ['accountId', 'date'],
  ],
  'Tag': [
    ['accountId', 'name'],
  ],
  'Reminder': [
    ['accountId', 'time'],
  ],
  'Method': [
    ['accountId', 'name'],
  ],
};
