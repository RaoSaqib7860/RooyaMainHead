import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:sliver_header_delegate/sliver_header_delegate.dart';
import 'package:sliver_header_delegate/src/extension/header_item_extensions.dart';

class FlexibleTextItemWidget extends StatelessWidget {
  const FlexibleTextItemWidget(
    this._item,
    this._progress, {
    Key? key,
  }) : super(key: key);

  final FlexibleTextItem? _item;
  final double _progress;

  @override
  Widget build(BuildContext context) {
    var ppp = (((65/100)*_progress)*100-80).abs();
    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      padding: _item!.paddingValue(_progress),
      margin: _item!.marginValue(_progress),
      alignment: _item!.alignmentValue(_progress),
      child: CircularProfileAvatar(
        '${_item!.url}',
        radius: ppp<20?20:ppp,
        elevation: 3,
        onTap: _item!.onTap,
      )
    );
  }
}
