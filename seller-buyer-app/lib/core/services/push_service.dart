/// Firebase Push — будет активирован после добавления google-services.json
/// Пока это заглушка
class PushService {
  static final PushService instance = PushService._();
  factory PushService() => instance;
  PushService._();
  Future<void> init() async {}
}
