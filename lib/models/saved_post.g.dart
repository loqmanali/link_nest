// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_post.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SavedPostAdapter extends TypeAdapter<SavedPost> {
  @override
  final int typeId = 0;

  @override
  SavedPost read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SavedPost(
      id: fields[0] as String,
      link: fields[1] as String,
      title: fields[2] as String,
      type: fields[3] as String,
      priority: fields[4] as String,
      createdAt: fields[5] as DateTime,
      platform: fields[6] as String,
      folderId: fields[7] as String?,
      tagsParam: (fields[8] as List?)?.cast<String>(),
      statusParam: fields[9] as String?,
      savedAt: fields[10] as DateTime?,
      lastOpenedAt: fields[11] as DateTime?,
      summary: fields[12] as String?,
      keywordsParam: (fields[13] as List?)?.cast<String>(),
      contentType: fields[14] as String?,
      highlightsParam: (fields[15] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, SavedPost obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.link)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.priority)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.platform)
      ..writeByte(7)
      ..write(obj.folderId)
      ..writeByte(8)
      ..write(obj.tags)
      ..writeByte(9)
      ..write(obj.status)
      ..writeByte(10)
      ..write(obj.savedAt)
      ..writeByte(11)
      ..write(obj.lastOpenedAt)
      ..writeByte(12)
      ..write(obj.summary)
      ..writeByte(13)
      ..write(obj.keywords)
      ..writeByte(14)
      ..write(obj.contentType)
      ..writeByte(15)
      ..write(obj.highlights);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedPostAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
