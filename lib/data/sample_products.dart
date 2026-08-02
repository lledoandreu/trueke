import '../models/product.dart';

const sampleProducts = [
  Product(
    id: '1',
    title: 'iPhone 14 Pro',
    imageUrl: 'assets/images/iphone.jpg',
    price: 750,
    tradeType: TradeType.tradeAndMoney,
    location: 'Valencia',
    owner: 'Carlos',
    condition: 'Como nuevo',
  ),
  Product(
    id: '2',
    title: 'Bicicleta MTB',
    imageUrl: 'assets/images/bike.jpg',
    price: 350,
    tradeType: TradeType.sale,
    location: 'Albacete',
    owner: 'Laura',
    condition: 'Buen estado',
  ),
  Product(
    id: '3',
    title: 'PlayStation 5',
    imageUrl: 'assets/images/ps5.jpg',
    price: null,
    tradeType: TradeType.trade,
    location: 'Madrid',
    owner: 'Miguel',
    condition: 'Nueva',
  ),
];
