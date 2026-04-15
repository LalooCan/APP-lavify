import '../models/wash_models.dart';

abstract class OrderRepository {
  List<WashOrder> getOrders();
  WashOrder createOrderFromDraft(WashRequestDraft draft);
  WashOrder updateOrder(WashOrder order);
}
