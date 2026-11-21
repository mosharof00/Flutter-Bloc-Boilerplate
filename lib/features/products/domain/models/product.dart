import 'package:equatable/equatable.dart';

final class Product with Equatable {
  const Product({
    required this.id,
    required this.title,
    required this.price,
    this.thumbnail,
  });

  final int id;
  final String title;
  final double price;
  final String? thumbnail;

  @override
  List<Object?> get props => <Object?>[id, title, price, thumbnail];
}
