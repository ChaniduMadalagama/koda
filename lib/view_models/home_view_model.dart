// filepath: /Users/developer/Desktop/flutter/koda/lib/view_models/home_view_model.dart
import 'base_view_model.dart';

class HomeViewModel extends BaseViewModel {
  int _counter = 0;
  int get counter => _counter;

  void incrementCounter() {
    _counter++;
    notifyListeners();
  }
}
