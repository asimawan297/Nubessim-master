import 'package:flutter/material.dart';
import 'package:super_tooltip/super_tooltip.dart';

class InfoTooltip extends StatefulWidget {
  final String text;

  const InfoTooltip({super.key, required this.text});

  @override
  State<InfoTooltip> createState() => _InfoTooltipState();
}

class _InfoTooltipState extends State<InfoTooltip> {
  final SuperTooltipController controller = SuperTooltipController();

  @override
  Widget build(BuildContext context) {
    return SuperTooltip(
      controller: controller,

      style: TooltipStyle(
              backgroundColor: Colors.white,
      borderColor: Colors.black12,
boxShadows: [
        BoxShadow(
    color: Colors.black.withOpacity(0.08),
    blurRadius: 12,
    spreadRadius: 1,
    offset: const Offset(0, 3)
  )
      ],
      
      ),
      
        arrowConfig: ArrowConfiguration(
        baseWidth: 18,tipDistance: 8
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 240),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.text,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => controller.hideTooltip(),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10,vertical: 4),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(30)),
                child: Text("OK, GOT IT",
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.black,
                        fontWeight: FontWeight.w600)),
              ),
            ),
            
          ],
        ),
      ),
      child: const Icon(
        Icons.info_outline,
        size: 18,
        color: Colors.black54,
      ),
    );
  }
}
