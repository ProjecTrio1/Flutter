import 'package:flutter/material.dart';
import '../../config.dart';

class InventoryItemCard extends StatelessWidget {
  final String title;
  final String? price;
  final String? date;
  final bool showImage;
  final VoidCallback? onTap;

  const InventoryItemCard({
    required this.title,
    this.price,
    this.date,
    this.showImage = true,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: showImage
            ? Container(
          width: 60,
          height: 60,
          color: Colors.grey.shade300,
          child: Icon(Icons.image_outlined),
        )
            : null,
        title: Text(title),
        subtitle: (price != null || date != null)
            ? Text('${price ?? ''}${price != null && date != null ? ' / ' : ''}${date ?? ''}')
            : null,
        onTap: onTap,
      ),
    );
  }
}