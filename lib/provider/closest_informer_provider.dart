import 'package:flutter/material.dart';
import 'package:quick_social/services/closest_informer_service.dart';

class ClosestInformerProvider with ChangeNotifier {
  final ClosestInformerService _service = ClosestInformerService();
  List<dynamic> _closestInformers = [];
  List<dynamic> _allInformers = [];
  bool _isLoading = false;
  Map<String, dynamic>? _specificInformer;

  List<dynamic> get closestInformers => _closestInformers;
  bool get isLoading => _isLoading;
  Map<String, dynamic>? get specificInformer => _specificInformer;

  Future<void> fetchClosestInformers() async {
    _isLoading = true;
    notifyListeners();

    try {
      _closestInformers = await _service.getClosestLocation();
    } catch (e) {
      _closestInformers = [];
      debugPrint('Error fetching closest informers: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllInformers() async {
    _isLoading = true;
    notifyListeners();

    try {
      _allInformers = await _service.getAllInformers();
    } catch (e) {
      _allInformers = [];
      debugPrint('Error fetching closest informers: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchSpecificInformer(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final informer = _closestInformers.firstWhere(
        (element) => element['id'] == id,
        orElse: () => null,
      );

      if (informer != null) {
        _specificInformer = informer;
      } else {
        throw Exception('Specific informer not found locally.');
      }
    } catch (e) {
      _specificInformer = null;
      debugPrint('Error fetching specific informer: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
