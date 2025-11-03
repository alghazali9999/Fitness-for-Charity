import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:o3d/o3d.dart';
import 'package:provider/provider.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  O3DController o3dController = O3DController();
  PageController mainPageController = PageController();
  PageController textsPageController = PageController();
  int page = 0;
  bool isFirstTime = true;
  late AnimationController animationController;
  late Animation<double> animation;
  final dbHelper = DatabaseHelper.instance;
  double? temp;

  List<CardItem> cardItems = [
    const CardItem(
      title: 'Charity Run',
      description: 'Run for a cause! Each km contributes to our partner charity.',
      image: 'assets/charity-run.jpg',
    ),
    const CardItem(
      title: 'Yoga Event',
      description: 'Find your inner peace and strength in our guided yoga session.',
      image: 'assets/yoga_event.jfif',
    ),
    const CardItem(
      title: 'Fun Walk',
      description:
          'A fun and easy walk for all ages. Enjoy the scenery and company.',
      image: 'assets/fun_walk.jfif',
    )
  ];

  @override
  void initState() {
    super.initState();
    mainPageController.addListener(() {
      if (mainPageController.page == 0.0) {
        setState(() {
          page = 0;
        });
      } else if (mainPageController.page == 1.0) {
        setState(() {
          page = 1;
        });
      } else if (mainPageController.page == 2.0) {
        setState(() {
          page = 2;
        });
      }
    });

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    animation =
        CurvedAnimation(parent: animationController, curve: Curves.easeIn);
  }

  void _onSwipe(DragUpdateDetails details) {
    if (details.delta.dx > 0 && page > 0) {
      mainPageController.previousPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.ease,
      );
    } else if (details.delta.dx < 0 && page < 2) {
      mainPageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.ease,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    GenderProvider genderProvider = Provider.of<GenderProvider>(context);

    if (isFirstTime) {
      isFirstTime = false;
      Timer(const Duration(milliseconds: 500), () {
        o3dController.cameraTarget(-0.25, 1.5, 1.5);
        o3dController.cameraOrbit(0, 90, 1);
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xff5483b3),
      body: Stack(
        children: [
          O3D.asset(
            src: genderProvider.gender == 'male'
                ? 'assets/male_basic_walk_30_frames_loop.glb'
                : 'assets/disney_style_character.glb',
            controller: o3dController,
            ar: false,
            autoPlay: true,
            autoRotate: false,
          ),
          PageView(
            controller: mainPageController,
            children: [
              // PAGE 1
              GestureDetector(
                onHorizontalDragUpdate: _onSwipe,
                child: Container(
                  color: Colors.transparent,
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          const SizedBox(height: 100),
                          const Center(
                            child: Text(
                              'Sunday',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const Center(
                            child: Text(
                              '24 / 7 / 2023',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Center(
                            child: Text(
                              '${temp ?? '--'}°C',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Container(
                            width: 300,
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Steps',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18),
                                ),
                                Text(
                                  '10,000',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        children: [
                                          Text('Calories',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16)),
                                          Text('500',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                  fontWeight:
                                                      FontWeight.bold)),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Text('Distance',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16)),
                                          Text('8 km',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                  fontWeight:
                                                      FontWeight.bold)),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        bottom: 0,
                        child: ClipPath(
                          clipper: InvertedCircleClipper(),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 300,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 270,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color.fromARGB(255, 3, 133, 240),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),

              // PAGE 2
              Scaffold(
                backgroundColor: Colors.transparent,
                body: GestureDetector(
                  onHorizontalDragUpdate: _onSwipe,
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.transparent,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          bottom: 0,
                          child: ClipPath(
                            clipper: InvertedCircleClipper(),
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: 300,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 270,
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color.fromARGB(255, 3, 133, 240),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        ),
                        CarouselSlider(
                          items: cardItems.map((item) {
                            return Builder(
                              builder: (BuildContext context) {
                                return Container(
                                  width: MediaQuery.of(context).size.width,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 5.0),
                                  decoration: BoxDecoration(
                                      color: Colors.amber,
                                      borderRadius:
                                          BorderRadius.circular(20)),
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(20),
                                        child: Image.asset(
                                          item.image,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                        ),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.transparent,
                                              Colors.black.withOpacity(0.7)
                                            ],
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.title,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 24,
                                                  fontWeight:
                                                      FontWeight.bold),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              item.description,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          }).toList(),
                          options: CarouselOptions(
                            height: 400,
                            aspectRatio: 16 / 9,
                            viewportFraction: 0.8,
                            initialPage: 0,
                            enableInfiniteScroll: true,
                            reverse: false,
                            autoPlay: true,
                            autoPlayInterval: const Duration(seconds: 3),
                            autoPlayAnimationDuration:
                                const Duration(milliseconds: 800),
                            autoPlayCurve: Curves.fastOutSlowIn,
                            enlargeCenterPage: true,
                            scrollDirection: Axis.horizontal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // PAGE 3 (unchanged)
              ClipPath(
                clipper: InvertedCircleClipper(),
                child: Container(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: page,
        onTap: (page) {
          mainPageController.animateToPage(page,
              duration: const Duration(milliseconds: 500), curve: Curves.ease);
          textsPageController.animateToPage(page,
              duration: const Duration(milliseconds: 500), curve: Curves.ease);

          if (page == 0) {
            o3dController.cameraTarget(-.25, 1.5, 1.5);
            o3dController.cameraOrbit(0, 90, 1);
          } else if (page == 1) {
            o3dController.cameraTarget(0, 1.8, 0);
            o3dController.cameraOrbit(-90, 90, 1.5);
          } else if (page == 2) {
            if (genderProvider.gender == 'male') {
            } else {
              o3dController.cameraTarget(0, 3, 0);
              o3dController.cameraOrbit(0, 90, -3);
            }
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
