import '../../domain/entities/family_secret.dart';

abstract class IFamilySecretRepository {
  Future<List<FamilySecret>> getAll();
  Future<FamilySecret?> getByDish(int dishId);
  Future<void> upsert(FamilySecret secret);
  Future<void> delete(int id);
}
