// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drift_food_dao.dart';

// ignore_for_file: type=lint
mixin _$DriftFoodDaoMixin on DatabaseAccessor<CoreDatabase> {
  $FoodVariantsTable get foodVariants => attachedDatabase.foodVariants;
  DriftFoodDaoManager get managers => DriftFoodDaoManager(this);
}

class DriftFoodDaoManager {
  final _$DriftFoodDaoMixin _db;
  DriftFoodDaoManager(this._db);
  $$FoodVariantsTableTableManager get foodVariants =>
      $$FoodVariantsTableTableManager(_db.attachedDatabase, _db.foodVariants);
}
