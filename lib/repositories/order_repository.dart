import '../models/wash_models.dart';

abstract class OrderRepository {
  Stream<List<WashOrder>> watchOrders();

  List<WashOrder> getOrders();

  Future<WashOrder> createOrder(WashOrder order);

  Future<WashOrder> updateOrder(WashOrder order);
}
