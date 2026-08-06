import '../models/product.dart';

final sampleProducts = [
  Product(
    id: '1',
    title: 'iPhone 14 Pro',
    images: ['assets/images/iphone14.jpg'],
    price: 750,
    tradeType: TradeType.tradeAndMoney,
    location: 'Valencia',
    owner: 'Carlos',
    condition: 'Como nuevo',
    category: 'Electrónica',
    description:
        'iPhone 14 Pro en perfecto estado. Siempre utilizado con funda y protector de pantalla. Incluye caja original y accesorios.',
    wanted:
        'Busco MacBook Air M2, iPad Pro reciente o cámara Sony Alpha. También acepto tecnología equivalente.',
    createdAt: DateTime(2026, 8, 1),
  ),
  Product(
    id: '2',
    title: 'Bicicleta MTB',
    images: [],
    price: 350,
    tradeType: TradeType.sale,
    location: 'Albacete',
    owner: 'Laura',
    condition: 'Buen estado',
    category: 'Deporte',
    description:
        'Bicicleta de montaña revisada y lista para usar. Ideal para rutas y caminos.',
    wanted: 'Acepto ofertas relacionadas con deporte o movilidad.',
    createdAt: DateTime(2026, 8, 2),
  ),
  Product(
    id: '3',
    title: 'PlayStation 5',
    images: [],
    price: null,
    tradeType: TradeType.trade,
    location: 'Madrid',
    owner: 'Miguel',
    condition: 'Nueva',
    category: 'Gaming',
    description:
        'PlayStation 5 nueva sin estrenar. Incluye mando original y embalaje.',
    wanted: 'Busco portátil gaming o productos tecnológicos de valor similar.',
    createdAt: DateTime(2026, 8, 3),
  ),
];
