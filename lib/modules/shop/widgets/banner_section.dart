import 'package:flutter/material.dart';
import 'package:nubesim/constants/app_colors.dart';
import 'package:nubesim/utils/extensions/padding_extension.dart';
import 'package:nubesim/utils/heights_and_widths.dart';
import 'package:sizer/sizer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class BannerSection extends StatefulWidget {
  final List<String> bannerList;

  const BannerSection({
    super.key,
    required this.bannerList,
  });

  @override
  State<BannerSection> createState() => _BannerSectionState();
}

class _BannerSectionState extends State<BannerSection> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    // Auto move every 3 seconds
    Future.delayed(const Duration(seconds: 3), _autoScroll);
  }

  void _autoScroll() {
    if (_pageController.hasClients) {
      int nextPage = (_currentIndex + 1) % widget.bannerList.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentIndex = nextPage;
      });

      // Schedule next move
      Future.delayed(const Duration(seconds: 3), _autoScroll);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Stay updated!",
          style: TextStyle(
              fontFamily: "Inter",
              color: AppColors.black,
              fontSize: 12.0,
              fontWeight: FontWeight.w400),
        ).paddingSymmetric(horizontal: 16,vertical: 0.0),
        SizedBox(
          height: 14.h,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.bannerList.length,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemBuilder: (context, index) {
              return Padding(
      padding: EdgeInsets.symmetric(horizontal: 1.w), 
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    widget.bannerList[index],
                    height: 12.h,
                    fit: BoxFit.fitWidth,
                  ),
                ),
              );
            },
          ),
        ).paddingSymmetric(horizontal: 14, vertical: 0.0),
        h1,
        // Dot Indicator
        Center(
          child: SmoothPageIndicator(
            controller: _pageController,
            count: widget.bannerList.length,
            effect: ExpandingDotsEffect(
              dotHeight: 8,
              dotWidth: 8,
              activeDotColor: AppColors.primaryColor,
              dotColor: Colors.grey.shade300,
            ),
          ),
        ),
      ],
    );
  }
}
