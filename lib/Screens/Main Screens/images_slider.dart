import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class CarouselWithDotsPage extends StatefulWidget {
  final List<String> imgList;
  final List<String> textList;
  final List<Color> containerColors;

  const CarouselWithDotsPage({super.key, required this.imgList, required this.textList, required this.containerColors});

  @override
  CarouselWithDotsPageState createState() => CarouselWithDotsPageState();
}

class CarouselWithDotsPageState extends State<CarouselWithDotsPage> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> imageSliders = widget.imgList
        .asMap()
        .entries
        .map(
          (entry) => ClipRRect(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
                  child: Image.asset(
                    entry.value,
                    height: 300,
                    width: 1000,
                  ),
                ),
                Positioned(
                  bottom: 0.0,
                  left: 0.0,
                  right: 0.0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    color: widget.containerColors[entry.key],
                    child: Text(
                      widget.textList[entry.key],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _current == 0 ? Colors.white : Colors.black,
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
        .toList();

    return Column(
      children: [
        Container(
          height: 435,
          color: _current == 0 ? const Color(0xFF9DAFFB) : Colors.white,
          child: Column(
            children: [
              CarouselSlider(
                items: imageSliders,
                options: CarouselOptions(
                  autoPlay: false,
                  aspectRatio: 1,
                  viewportFraction: 2,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _current = index;
                    });
                  },
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: widget.imgList.map((url) {
                  int index = widget.imgList.indexOf(url);
                  return Container(
                    width: _current == index ? 18.0 : 11.0,
                    height: _current == index ? 18.0 : 11.0,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _current == index ? const Color(0xFFFFC632) : const Color(0xFFD7D7D7),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
