// lib/widgets/product_slideshow.dart

import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ProductSlideshow extends StatefulWidget {
  const ProductSlideshow({super.key});

  @override
  State<ProductSlideshow> createState() => _ProductSlideshowState();
}

class _ProductSlideshowState extends State<ProductSlideshow> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PageView(
            controller: _pageController,
            children: const [
              // You can replace these with dynamic image widgets
              Card(child: Center(child: Text('Promo 1'))),
              Card(child: Center(child: Text('Promo 2'))),
              Card(child: Center(child: Text('Promo 3'))),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SmoothPageIndicator(
          controller: _pageController,
          count: 3,
          effect: WormEffect(
            dotWidth: 6.0,
            dotHeight: 6.0,
            activeDotColor: Theme.of(context).colorScheme.primary,
            dotColor: Colors.grey,
          ),
        ),
      ],
    );
  }
}