import '../../data/dtos/family_secret_dto.dart';
import '../../domain/entities/family_secret.dart';
import '../../implementations/local/app_database.dart';
import '../../interfaces/repositories/i_family_secret_repository.dart';

class LocalFamilySecretRepository implements IFamilySecretRepository {
  final AppDatabase _db;

  LocalFamilySecretRepository(this._db);

  @override
  Future<FamilySecret?> getByDish(int dishId) async {
    final db = await _db.database;
    final maps = await db.query(
      'family_secrets',
      where: 'dish_id = ?',
      whereArgs: [dishId],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return FamilySecretDto.fromMap(maps.first);
  }

  @override
  Future<void> upsert(FamilySecret secret) async {
    final db = await _db.database;
    if (secret.id != null) {
      final updated = secret.copyWith(updatedAt: DateTime.now());
      await db.update(
        'family_secrets',
        FamilySecretDto.toMap(updated),
        where: 'id = ?',
        whereArgs: [secret.id],
      );
    } else {
      final newSecret = secret.copyWith(
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await db.insert('family_secrets', FamilySecretDto.toMap(newSecret));
    }
  }

  @override
  Future<void> delete(int id) async {
    final db = await _db.database;
    await db.delete('family_secrets', where: 'id = ?', whereArgs: [id]);
  }
}
