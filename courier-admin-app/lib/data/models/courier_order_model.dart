class CourierOrderModel {
  final String id;
  final String buyerName;
  final String buyerPhone;
  final String address;
  final double? lat;
  final double? lng;
  final int totalTiyin;
  final String status;
  final DateTime createdAt;
  // Delivery details
  final String? productTitle;
  final String? productPhotoUrl;
  final String? sellerName;
  final String? sellerAddress;
  final double? sellerLat;
  final double? sellerLng;
  final String? deliveryAddress;
  final double? deliveryLat;
  final double? deliveryLng;
  final int feeTiyin;
  final double? distanceKm;
  final int? etaMinutes;

  const CourierOrderModel({
    required this.id,
    required this.buyerName,
    required this.buyerPhone,
    required this.address,
    this.lat, this.lng,
    required this.totalTiyin,
    required this.status,
    required this.createdAt,
    this.productTitle,
    this.productPhotoUrl,
    this.sellerName,
    this.sellerAddress,
    this.sellerLat, this.sellerLng,
    this.deliveryAddress,
    this.deliveryLat, this.deliveryLng,
    this.feeTiyin = 0,
    this.distanceKm,
    this.etaMinutes,
  });

  int get totalSum => totalTiyin ~/ 100;
  int get feeSum   => feeTiyin ~/ 100;

  factory CourierOrderModel.fromJson(Map<String, dynamic> j) => CourierOrderModel(
    id:             j['id'] as String,
    buyerName:      j['buyerName']  as String? ?? '',
    buyerPhone:     j['buyerPhone'] as String? ?? '',
    address:        j['address']    as String? ?? j['deliveryAddress'] as String? ?? '',
    lat:            (j['lat']  as num?)?.toDouble(),
    lng:            (j['lng']  as num?)?.toDouble(),
    totalTiyin:     (j['totalAmount'] as num?)?.toInt() ?? 0,
    status:         j['status'] as String? ?? '',
    createdAt:      DateTime.tryParse(j['createdAt'] as String? ?? '') ?? DateTime.now(),
    productTitle:   j['productTitle']   as String?,
    productPhotoUrl:j['productPhotoUrl'] as String?,
    sellerName:     j['sellerName']    as String?,
    sellerAddress:  j['sellerAddress'] as String?,
    sellerLat:      (j['sellerLat']  as num?)?.toDouble(),
    sellerLng:      (j['sellerLng']  as num?)?.toDouble(),
    deliveryAddress:j['deliveryAddress'] as String?,
    deliveryLat:    (j['deliveryLat'] as num?)?.toDouble(),
    deliveryLng:    (j['deliveryLng'] as num?)?.toDouble(),
    feeTiyin:       (j['feeTiyin'] as num?)?.toInt() ?? 0,
    distanceKm:     (j['distanceKm'] as num?)?.toDouble(),
    etaMinutes:     (j['etaMinutes'] as num?)?.toInt(),
  );
}
