import '../models/product.dart';

final List<Product> sampleProducts = [
  Product(
    id: '1',
    title: 'iPhone 14 Pro',
    images: ['assets/images/iphone14.jpg'],
    price: 750,
    tradeType: TradeType.tradeAndMoney,
    category: 'Electrónica',
    location: 'Valencia',
    owner: 'Carlos',
    condition: 'Como nuevo',
    description:
        'iPhone 14 Pro en perfecto estado, muy cuidado, con caja original y accesorios.',
    wanted:
        'Busco MacBook Air M2, iPad Pro reciente o productos tecnológicos similares.',
    createdAt: DateTime(2026, 8, 1),
  ),

  Product(
    id: '2',
    title: 'Bicicleta MTB',
    images: [],
    price: 350,
    tradeType: TradeType.sale,
    category: 'Deporte',
    location: 'Albacete',
    owner: 'Laura',
    condition: 'Buen estado',
    description: 'Bicicleta MTB revisada y lista para usar. Tiene poco uso.',
    wanted: 'Acepto ofertas relacionadas con ciclismo o venta directa.',
    createdAt: DateTime(2026, 7, 28),
  ),

  Product(
    id: '3',
    title: 'PlayStation 5',
    images: [],
    price: null,
    tradeType: TradeType.trade,
    category: 'Gaming',
    location: 'Madrid',
    owner: 'Miguel',
    condition: 'Nueva',
    description: 'PlayStation 5 nueva, sin uso, con embalaje original.',
    wanted: 'Busco ordenador gaming o productos tecnológicos equivalentes.',
    createdAt: DateTime(2026, 7, 25),
  ),
];
