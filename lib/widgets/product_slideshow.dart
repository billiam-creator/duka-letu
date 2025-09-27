import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'dart:async';

class ProductSlideshow extends StatefulWidget {
  // It's good practice to pass data to the widget
  final List<String> imageUrls;

  const ProductSlideshow({super.key, this.imageUrls = const []});

  @override
  State<ProductSlideshow> createState() => _ProductSlideshowState();
}

class _ProductSlideshowState extends State<ProductSlideshow> {
  final PageController _pageController = PageController();
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // Start the timer to auto-scroll every 3 seconds
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_pageController.hasClients && widget.imageUrls.isNotEmpty) {
        int nextPage = _pageController.page!.round() + 1;
        if (nextPage >= widget.imageUrls.length) {
          nextPage = 0; // Loop back to the first page
        }
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeIn,
        );
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer.cancel(); // Remember to cancel the timer
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      // Display a placeholder if no images are provided
      return SizedBox(
        height: 200,
        child: Center(
          child: Text('No promotional images available', style: Theme.of(context).textTheme.bodyLarge),
        ),
      );
    }
    
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.imageUrls.length,
            itemBuilder: (context, index) {
              return Image.network(
                widget.imageUrls[index],
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.error)),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        SmoothPageIndicator(
          controller: _pageController,
          count: widget.imageUrls.length,
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
