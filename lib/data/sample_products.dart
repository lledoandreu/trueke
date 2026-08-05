import '../models/product.dart';

const sampleProducts = [
  Product(
    id: '1',
    title: 'iPhone 14 Pro',
    imageUrl: 'assets/images/iphone14.jpg',
    price: 750,
    tradeType: TradeType.tradeAndMoney,
    location: 'Valencia',
    owner: 'Carlos',
    condition: 'Como nuevo',
    description:
        'iPhone 14 Pro de 128 GB en color azul. Siempre utilizado con funda y protector de pantalla. Sin golpes ni arañazos. Batería en excelente estado y funcionamiento perfecto. Se entrega con caja original.',
    wanted:
        'Busco un MacBook Air M2, un iPad Pro reciente o una cámara Sony Alpha. También valoro otros dispositivos Apple o tecnología de valor similar.',
  ),

  Product(
    id: '2',
    title: 'Bicicleta MTB',
    imageUrl: '',
    price: 350,
    tradeType: TradeType.sale,
    location: 'Albacete',
    owner: 'Laura',
    condition: 'Buen estado',
    description:
        'Bicicleta de montaña de aluminio, talla M. Revisada recientemente y lista para usar. Ideal para rutas de montaña y caminos.',
    wanted:
        'Principalmente venta, aunque podría aceptar un smartwatch Garmin o material de ciclismo de calidad.',
  ),

  Product(
    id: '3',
    title: 'PlayStation 5',
    imageUrl: '',
    price: null,
    tradeType: TradeType.trade,
    location: 'Madrid',
    owner: 'Miguel',
    condition: 'Nueva',
    description:
        'PlayStation 5 prácticamente nueva. Incluye mando DualSense, cables originales y caja. Muy poco uso.',
    wanted:
        'Busco una Xbox Series X, un PC Gaming o componentes informáticos equivalentes.',
  ),
];
