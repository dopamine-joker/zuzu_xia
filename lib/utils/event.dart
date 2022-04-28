import 'package:event_bus/event_bus.dart';

EventBus eventBus = EventBus();

class LoginInErrEvent {
  String _eventDetail;

  LoginInErrEvent(this._eventDetail);

  String get detail => _eventDetail;
}

class RegisterErrEvent {
  String _eventDetail;

  RegisterErrEvent(this._eventDetail);

  String get detail => _eventDetail;
}

class MenuErrEvent {
  String _eventDetail;

  MenuErrEvent(this._eventDetail);

  String get detail => _eventDetail;
}

class MeErrEvent {
  String _eventDetail;

  MeErrEvent(this._eventDetail);

  String get detail => _eventDetail;
}

class UploadErrEvent {
  String _eventDetail;

  UploadErrEvent(this._eventDetail);

  String get detail => _eventDetail;
}

class HomeErrEvent {
  String _eventDetail;

  HomeErrEvent(this._eventDetail);

  String get detail => _eventDetail;
}

class DetailErrEvenet {
  String _eventDetail;

  DetailErrEvenet(this._eventDetail);

  String get detail => _eventDetail;
}

class RecordErrEvenet {
  String _eventDetail;

  RecordErrEvenet(this._eventDetail);

  String get detail => _eventDetail;
}

class MyOrderErrEvenet {
  String _eventDetail;

  MyOrderErrEvenet(this._eventDetail);

  String get detail => _eventDetail;
}