class Product {
  final int id;
  final String name;
  final List<String> location;
  final List<String> application;
  final int horizontal;
  final int vertical;
  final double pixelPitch;
  final double width;
  final double height;
  final double depth;
  final double consumption;
  final double weight;
  final int brightness;
  final String image;
  final double? refreshRate;
  final String? contrast;
  final String? visionAngle;
  final String? redundancy;
  final String? curvedVersion;
  final String? opticalMultilayerInjection;

  Product({
    required this.id,
    required this.name,
    required this.location,
    required this.application,
    required this.horizontal,
    required this.vertical,
    required this.pixelPitch,
    required this.width,
    required this.height,
    required this.depth,
    required this.consumption,
    required this.weight,
    required this.brightness,
    required this.image,
    this.refreshRate,
    this.contrast,
    this.visionAngle,
    this.redundancy,
    this.curvedVersion,
    this.opticalMultilayerInjection,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      location: List<String>.from(json['location']),
      application: List<String>.from(json['application']),
      horizontal: json['horizontal'],
      vertical: json['vertical'],
      pixelPitch: (json['pixelPitch'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      depth: (json['depth'] as num).toDouble(),
      consumption: (json['consumption'] as num).toDouble(),
      weight: (json['weight'] as num).toDouble(),
      brightness: json['brightness'],
      image: json['image'],
      refreshRate: (json['refreshRate'] as num?)?.toDouble(),
      contrast: json['contrast'],
      visionAngle: json['visionAngle'],
      redundancy: json['redundancy'],
      curvedVersion: json['curvedVersion'],
      opticalMultilayerInjection: json['opticalMultilayerInjection'],
    );
  }
} 