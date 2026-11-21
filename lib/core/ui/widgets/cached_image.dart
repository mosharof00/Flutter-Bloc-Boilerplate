import 'package:cached_network_image/cached_network_image.dart';
import 'package:enterprise_mvvm/core/ui/widgets/shimmer_box.dart';
import 'package:enterprise_mvvm/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CachedImage extends StatelessWidget {
  const CachedImage({
    super.key,
    required this.imgUrl,
    this.height,
    this.width,
    this.fit,
    this.borderRadius,
  });

  final String imgUrl;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final double? borderRadius;

  static const Map<String, String> _headers = <String, String>{
    'User-Agent': 'EnterpriseMvvm/1.0',
  };

  bool get _isSvg => imgUrl.toLowerCase().endsWith('.svg');

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius ?? 0),
      child: _isSvg ? _svg() : _raster(),
    );
  }

  Widget _svg() {
    return SvgPicture.network(
      imgUrl,
      height: height,
      width: width,
      fit: fit ?? BoxFit.contain,
      headers: _headers,
      placeholderBuilder: (BuildContext context) =>
          ShimmerBox(height: height, width: width, borderRadius: borderRadius),
    );
  }

  Widget _raster() {
    return CachedNetworkImage(
      imageUrl: imgUrl,
      httpHeaders: _headers,
      width: width,
      height: height,
      fit: fit ?? BoxFit.cover,
      placeholder: (BuildContext context, String url) =>
          ShimmerBox(height: height, width: width, borderRadius: borderRadius),
      errorWidget: (BuildContext context, String url, Object error) =>
          Image.asset(
            Assets.images.placeholder.path,
            height: height,
            width: width,
            fit: BoxFit.cover,
          ),
    );
  }
}
