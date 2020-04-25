import 'package:flutter/material.dart';
import 'package:seven_spot_mobile/models/Opening.dart';
import 'package:seven_spot_mobile/repositories/OpeningRepository.dart';

class DeleteOpeningUseCase extends ChangeNotifier {
  OpeningRepository _repo;

  bool _deleting = false;
  bool get deleting => _deleting;

  DeleteOpeningUseCase(OpeningRepository repo) {
    _repo = repo;
  }

  Future<void> deleteOpening(String openingId) async {
    _deleting = true;
    notifyListeners();

    try {
      await _repo.deleteOpening(openingId);
    } catch (e) {
      throw e;
    } finally {
      _deleting = false;
      notifyListeners();
    }
  }
}