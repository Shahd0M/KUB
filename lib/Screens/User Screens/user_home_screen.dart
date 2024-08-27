import 'package:authentication/Screens/User%20Screens/ads_details.dart';
import 'package:authentication/Screens/User%20Screens/user_cart.dart';
import 'package:authentication/Screens/User%20Screens/user_favourites.dart';
import 'package:authentication/Screens/User%20Screens/user_main_chat_page.dart';
import 'package:authentication/Screens/User%20Screens/user_profile.dart';
import 'package:authentication/Screens/User%20Screens/user_search_screen.dart';
import 'package:authentication/widgets/user_nav_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:authentication/Design/Categories_Design.dart';



class UserHomeScreen extends StatefulWidget {
  final int navBarIndex;

  const UserHomeScreen({super.key, required this.navBarIndex});

  @override
  State<UserHomeScreen> createState() => UserHomeScreenState();
}

class UserHomeScreenState extends State<UserHomeScreen> {
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.navBarIndex;
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      bottomNavigationBar: UserBottomNavigationBarWrapper(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });

          // Handle navigation based on the index
          switch (index) {
            case 0:
            // Navigate to Home screen
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                      const UserHomeScreen(navBarIndex: 0)));
              //Navigator.pushReplacementNamed(context, '/userHome');
              break;
            case 1:
            // Navigate to Profile screen
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                      const UserProfileTab(navBarIndex: 1)));
              //Navigator.pushReplacementNamed(context, '/userProfile');
              break;
            case 2:
            // Navigate to Favorites screen
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                      const UserFavouritesTab(navBarIndex: 2)));
              //Navigator.pushReplacementNamed(context, '/userFavorites');
              break;
            case 3:
            // Navigate to Cart screen
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CartScreen(navBarIndex: 3)));
              //Navigator.pushReplacementNamed(context, '/userCart');
              break;
          }
        },
      ),
      body:
      UserHomeScreenContent(), // Replace with your actual content
    );
  }
}

class UserHomeScreenContent extends StatefulWidget {

  const UserHomeScreenContent({super.key});

  @override
  State<UserHomeScreenContent> createState() => _UserHomeScreenContentState();
}

class _UserHomeScreenContentState extends State<UserHomeScreenContent> {

  List? adsList = [];

  final CarouselController carouselController = CarouselController();
  int currentIndex = 0;

  Future<void> fetchAds() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance.collection('ads').get();

    setState(() {
      adsList = querySnapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    fetchAds();
  }
  

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
        onPressed: () {
          // add chat desired logic
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      UserMainChatScreen()));
        },
        
        backgroundColor: Color.fromARGB(255, 35, 57, 94), // Change background color
        child: Icon(
          Icons.chat, // Change icon to "add image" icon
          color: Color.fromRGBO(255, 198, 50, 1.0), // Change icon color
          size: 28,
        ),
      ),
        appBar: AppBar(
          backgroundColor: Colors.white,
          toolbarHeight: 100,
          elevation: 0,
          leading: Container(
            margin: EdgeInsets.fromLTRB(10,0,0,0),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage('lib/assets/home_images/Logo.png'),
              ),
            ),
          ),
          title: InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                       SearchScreen("All categories")));
            },
            //to make it clickable (to search page)

            child: Container(
              height: MediaQuery.of(context).size.height * .06,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black54,
                  width: 1.4,
                ),
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Row(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    //to make space between icon and text
                    child: Icon(
                      Icons.search,
                      color: Colors.black54,
                      size: 18,
                    ),
                  ),
                  Text(
                    'Search for Store',
                    style: TextStyle(
                      color: Colors.black54,
                      // fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              //for ads

              if (adsList == null) 
                Center(child: CircularProgressIndicator()),
              
              Stack(
                children: [
                  InkWell(
                    onTap: () {
                      // For example, navigate to another screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdsDetailsPage(
                            imageUrl : adsList![currentIndex]['imageUrl'],
                            description: adsList![currentIndex]['description'],
                          ),
                        ),
                      );
                    },
                    child: CarouselSlider(
                      items: adsList!
                          .map<Widget>((ad) => Image.network(
                                ad['imageUrl'],
                                fit: BoxFit.contain,
                                width: double.infinity,
                              ))
                          .toList(),
                      carouselController: carouselController,
                      options: CarouselOptions(
                        scrollPhysics: BouncingScrollPhysics(),
                        autoPlay: true,
                        aspectRatio: 2,
                        viewportFraction: 1,
                        onPageChanged: (index, reason) {
                          // Update currentIndex when page is changed
                          setState(() {
                            currentIndex = index;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20,),


              Container(
                margin: const EdgeInsets.only(left: 15, top: 10),
                alignment: Alignment.centerLeft,
                child: const Text(
                  "Categories",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500 , color: Color.fromARGB(255, 35, 57, 94)),
                ),
              ),
              const SizedBox(height: 10,),

              Container(
                margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: GridView.count(
                  crossAxisCount: 2, // Number of columns in the grid
                  mainAxisSpacing: 10.0, // Spacing between rows
                  crossAxisSpacing: 10.0, // Spacing between columns
                  shrinkWrap: true, // Wrap the GridView in a SizedBox or ListView to enable scrolling
                  physics: NeverScrollableScrollPhysics(), // Disable scrolling if needed
                  children: [
                    CategoriesDesign("lib/assets/categories_images/beauty.png", "Beauty"),
                    CategoriesDesign("lib/assets/categories_images/Accessorise.webp", "Accessories"),
                    CategoriesDesign("lib/assets/categories_images/entertainment.webp", "Entertainment"),
                    CategoriesDesign("lib/assets/categories_images/shoes.jpg", "Shoes"),
                    CategoriesDesign("lib/assets/categories_images/gift.jpg", "Gifts"),
                    CategoriesDesign("lib/assets/categories_images/kids.jpg", "Kids"),
                    CategoriesDesign("lib/assets/categories_images/clothes.jpg", "Clothes"),
                    CategoriesDesign("lib/assets/categories_images/all.webp", "All categories"),
                    // Add more CategoriesDesign widgets as needed
                  ],
                ),
              ),

              SizedBox(height: 20,)
            ],
          ),
        ),
      ),
    );
  }
}
