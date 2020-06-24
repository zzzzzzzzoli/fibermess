// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cell.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Cell _$CellFromJson(Map<String, dynamic> json) {
  return Cell(
    type: _$enumDecodeNullable(_$CellTypeEnumMap, json['type']),
    connections: (json['connections'] as List)
        ?.map((e) => _$enumDecodeNullable(_$SideEnumMap, e))
        ?.toSet(),
    bridgeConnections: (json['bridgeConnections'] as List)
        ?.map((e) => _$enumDecodeNullable(_$SideEnumMap, e))
        ?.toSet(),
    color: (json['color'] as List)
        ?.map((e) => _$enumDecodeNullable(_$CellColorEnumMap, e))
        ?.toSet(),
    bridgeColor: (json['bridgeColor'] as List)
        ?.map((e) => _$enumDecodeNullable(_$CellColorEnumMap, e))
        ?.toSet(),
    originalColor: (json['originalColor'] as List)
        ?.map((e) => _$enumDecodeNullable(_$CellColorEnumMap, e))
        ?.toSet(),
    sourceSideColors: (json['sourceSideColors'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(
          _$enumDecodeNullable(_$SideEnumMap, k),
          (e as List)
              ?.map((e) => _$enumDecodeNullable(_$CellColorEnumMap, e))
              ?.toSet()),
    ),
  );
}

Map<String, dynamic> _$CellToJson(Cell instance) => <String, dynamic>{
      'type': _$CellTypeEnumMap[instance.type],
      'connections':
          instance.connections?.map((e) => _$SideEnumMap[e])?.toList(),
      'bridgeConnections':
          instance.bridgeConnections?.map((e) => _$SideEnumMap[e])?.toList(),
      'color': instance.color?.map((e) => _$CellColorEnumMap[e])?.toList(),
      'bridgeColor':
          instance.bridgeColor?.map((e) => _$CellColorEnumMap[e])?.toList(),
      'originalColor':
          instance.originalColor?.map((e) => _$CellColorEnumMap[e])?.toList(),
      'sourceSideColors': instance.sourceSideColors?.map((k, e) => MapEntry(
          _$SideEnumMap[k], e?.map((e) => _$CellColorEnumMap[e])?.toList())),
    };

T _$enumDecode<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }

  final value = enumValues.entries
      .singleWhere((e) => e.value == source, orElse: () => null)
      ?.key;

  if (value == null && unknownValue == null) {
    throw ArgumentError('`$source` is not one of the supported values: '
        '${enumValues.values.join(', ')}');
  }
  return value ?? unknownValue;
}

T _$enumDecodeNullable<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source, unknownValue: unknownValue);
}

const _$CellTypeEnumMap = {
  CellType.source: 'source',
  CellType.through: 'through',
  CellType.end: 'end',
};

const _$SideEnumMap = {
  Side.left: 'left',
  Side.up: 'up',
  Side.right: 'right',
  Side.down: 'down',
};

const _$CellColorEnumMap = {
  CellColor.blue: 'blue',
  CellColor.green: 'green',
  CellColor.red: 'red',
  CellColor.cyan: 'cyan',
  CellColor.yellow: 'yellow',
  CellColor.magenta: 'magenta',
  CellColor.white: 'white',
};
