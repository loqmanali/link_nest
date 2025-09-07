import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../models/tag.dart';

class TagRepository {
  late Box<Tag> _tagBox;
  final _uuid = const Uuid();

  TagRepository() {
    _initBox();
  }

  Future<void> _initBox() async {
    if (Hive.isBoxOpen('tags')) {
      _tagBox = Hive.box<Tag>('tags');
    } else {
      _tagBox = await Hive.openBox<Tag>('tags');
    }
  }

  List<Tag> getAll() {
    if (!Hive.isBoxOpen('tags')) {
      _initBox();
    }
    return _tagBox.values.toList();
  }

  Future<String> add({required String name, String? color}) async {
    if (!Hive.isBoxOpen('tags')) {
      await _initBox();
    }
    final id = _uuid.v4();
    final tag = Tag(id: id, name: name, color: color);
    await _tagBox.put(id, tag);
    return id;
  }

  Future<void> update(Tag tag) async {
    if (!Hive.isBoxOpen('tags')) {
      await _initBox();
    }
    await _tagBox.put(tag.id, tag);
  }

  Future<void> delete(String id) async {
    if (!Hive.isBoxOpen('tags')) {
      await _initBox();
    }
    await _tagBox.delete(id);
  }
}
