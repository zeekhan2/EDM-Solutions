import 'package:flutter/material.dart';
import 'package:edm_solutions/consts/images.dart';

import '../../UserApp/Auth/SignUpView/signup_views.dart';
import '../Auth/SignUpView/facility_signup_views.dart';


class OnBoardViews extends StatefulWidget {
  final String mode; // "Worker" or "Facility"

  const OnBoardViews({super.key, required this.mode});

  @override
  State<OnBoardViews> createState() => _OnBoardViewsState();
}

class _OnBoardViewsState extends State<OnBoardViews> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  final List<Map<String, String>> _onBoardData = [
    {
      "image": onboard1,
      "title": "Find & Claim Shifts Instantly",
      "desc":
          "Browse available shifts in real-time and claim them with just one tap.",
    },
    {
      "image": onboard2,
      "title": "Smart & Secure Staffing",
      "desc":
          "Get matched with shifts that fit your skills and verified credentials.",
    },
    {
      "image": onboard3,
      "title": "Hassle-Free Work Experience",
      "desc":
          "Clock in via GPS, manage your documents, and enjoy smooth payments.",
    },
  ];

  @override
  void initState() {
    super.initState();
    // debug print — confirm mode arrived
    debugPrint('OnBoardViews.init -> received mode: "${widget.mode}"');
  }

  void _goNext() {
    final incomingMode = widget.mode.trim().toLowerCase();
    debugPrint('OnBoardViews._goNext -> currentIndex=$_currentIndex, mode=$incomingMode');

    if (_currentIndex == _onBoardData.length - 1) {
      // Last page → route depending on mode (case-insensitive)
      if (incomingMode == 'facility') {
        debugPrint('OnBoardViews -> navigating to FacilitySignupView');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const FacilitySignupView()),
        );
      } else {
        debugPrint('OnBoardViews -> navigating to WorkerSignupView');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const WorkerSignupView()),
        );
      }
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // keep your existing decorative dot helper if you like (omitted here for brevity)
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: _onBoardData.length,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemBuilder: (context, index) {
              final item = _onBoardData[index];
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    item["image"] ?? "",
                    width: size.width * 0.75,
                    height: size.height * 0.4,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 30),
                  Text(
                    item["title"] ?? "",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0A6CF2),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      item["desc"] ?? "",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // Small on-screen label to visually confirm the mode (useful for debugging)
          Positioned(
            top: 40,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Mode: ${widget.mode}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // bottom dots + button
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // progress dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _onBoardData.length,
                    (dotIndex) {
                      final active = dotIndex == _currentIndex;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        height: 8,
                        width: active ? 20 : 8,
                        decoration: BoxDecoration(
                          color: active
                              ? const Color(0xFF0A6CF2)
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 22),

                // next / get started button
                GestureDetector(
                  onTap: _goNext,
                  child: Container(
                    height: 56,
                    width: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A6CF2),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: const Icon(Icons.arrow_forward,
                        color: Colors.white, size: 26),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
