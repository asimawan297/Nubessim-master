import 'package:flutter/material.dart';

class AnimatedChild extends AnimatedWidget {
  final int? index;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final Size buttonSize;
  final Widget? child;
  final List<BoxShadow>? labelShadow;
  final Key? btnKey;

  final String? label;
  final TextStyle? labelStyle;
  final Color? labelBackgroundColor;
  final Widget? labelWidget;

  final bool visible;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? toggleChildren;
  final ShapeBorder? shape;
  final String? heroTag;
  final bool useColumn;
  final bool switchLabelPosition;
  final EdgeInsets? margin;

  final EdgeInsets childMargin;
  final EdgeInsets childPadding;

  const AnimatedChild({
    super.key,
    this.btnKey,
    required Animation<double> animation,
    this.index,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 6.0,
    this.buttonSize = const Size(56.0, 56.0),
    this.child,
    this.label,
    this.labelStyle,
    this.labelShadow,
    this.labelBackgroundColor,
    this.labelWidget,
    this.visible = true,
    this.onTap,
    required this.switchLabelPosition,
    required this.useColumn,
    required this.margin,
    this.onLongPress,
    this.toggleChildren,
    this.shape,
    this.heroTag,
    required this.childMargin,
    required this.childPadding,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = listenable as Animation<double>;
    bool dark = Theme.of(context).brightness == Brightness.dark;

    void performAction([bool isLong = false]) {
      if (onTap != null && !isLong) {
        onTap!();
      } else if (onLongPress != null && isLong) {
        onLongPress!();
      }
      toggleChildren!();
    }

    Widget buildLabel() {
      const borderRadius = BorderRadius.all(Radius.circular(50.0));
      return InkWell(
        onTap: performAction,
        onLongPress:
            onLongPress == null ? null : () => performAction(true),
        child: Container(
          margin: EdgeInsets.all(7),
           decoration: BoxDecoration(
          color: labelBackgroundColor ??
              (dark ? Colors.grey[800] : Colors.grey[50]),
          borderRadius: borderRadius,
          boxShadow: labelShadow ??
              [
                BoxShadow(
                  color: dark
                      ? Colors.grey[900]!.withOpacity(0.7)
                      : Colors.grey.withOpacity(0.7),
                  offset: const Offset(0.8, 0.8),
                  blurRadius: 2.4,
                ),
              ],
        ),
        
          child: Center(child: child),
        ),
      );
    }

    Widget button = ScaleTransition(
        scale: animation,
        child: buildLabel());

    List<Widget> children = [
     
      if (child != null)
        SizedBox(
          // color: Colors.red.shade100,
          // alignment: Alignment.center,
          // padding: EdgeInsets.all(2),
          width: 200,
          // width: 200,
          height: 60,
          child: (onLongPress == null)
              ? button
              : GestureDetector(
                onLongPress: () => performAction(true),
                child: button,
              ),
        )
    ];

    Widget buildColumnOrRow(bool isColumn,
        {CrossAxisAlignment? crossAxisAlignment,
        MainAxisAlignment? mainAxisAlignment,
        required List<Widget> children,
        MainAxisSize? mainAxisSize}) {
      return Column(
              // mainAxisSize:  MainAxisSize.max,
              mainAxisAlignment:  MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: children,
            )
         ;
    }

    return visible
        ? Container(
          // alignment: Alignment.bottomRight,
            // margin: EdgeInsets.all(10),
            child: buildColumnOrRow(
              useColumn,
              // mainAxisSize: MainAxisSize.min,
              children:
                  switchLabelPosition ? children.reversed.toList() : children,
            ),
          )
        : Container();
  }
}
