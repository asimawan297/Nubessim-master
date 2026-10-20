import 'package:flutter/material.dart';
import 'package:nubesim/constants/app_colors.dart';

class FAQTile extends StatelessWidget {
  final String question;
  final List<Widget> answers;

  const FAQTile({super.key, required this.question, required this.answers});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 5,
            spreadRadius: 1,
            offset: Offset(2, 2),
          ),
        ],
        color: AppColors.white,
        borderRadius: BorderRadius.circular(11),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          // childrenPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          initiallyExpanded: false,
          iconColor: AppColors.questionColorColor,
          collapsedIconColor: AppColors.questionColorColor,
          title: Text(question,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.questionColorColor,
                    fontWeight: FontWeight.w400,
                    fontSize: 13.0,
                  )),
          children: answers,
        ),
      ),
    );
  }
}

class AnswerWidget extends StatelessWidget {
  const AnswerWidget({super.key, required this.answer, this.padding});

  final String answer;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.all(12.0),
      child: Text(
        answer,
        textAlign: TextAlign.left,
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.questionColorColor,
              fontWeight: FontWeight.w500,
              fontSize: 12.0,
            ),
      ),
    );
  }
}
