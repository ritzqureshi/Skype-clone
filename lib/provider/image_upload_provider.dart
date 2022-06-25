import 'package:flutter/widgets.dart';

import '../enum/view_state.dart';

class ImageUploadProvider with ChangeNotifier {
  ViewState _viewState = ViewState.idle;
  ViewState get getViewState => _viewState;

  void setToLoading() {
    _viewState = ViewState.loading;
    notifyListeners();
  }

  void setToIdle() {
    _viewState = ViewState.idle;
    notifyListeners();
  }
}
