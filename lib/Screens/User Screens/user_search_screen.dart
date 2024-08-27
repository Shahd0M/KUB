import 'package:authentication/Screens/User%20Screens/provider_store_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../Design/SearchShortcut.dart';

class SearchScreen extends StatefulWidget {
  String title;

  SearchScreen(this.title, {super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List pages = [];
  List _resultList = [];
  String uid="";

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    _searchController.addListener(_onSearchChange);
    super.initState();
  }

  _onSearchChange() {
    //print(_searchController.text);
    searchResultList();
  }

  searchResultList() {
    var showResults = [];
    var _categoriesFilter = pages;

    if (_searchController.text != "") {
      for (var userSnapShot in pages) {
        var username = userSnapShot["username"].toString().toLowerCase();
        if (username.contains(_searchController.text.toLowerCase())) {
          showResults.add(userSnapShot);
        }
      }
    }else if (widget.title!="All categories") {
      showResults = pages.where((item) {
        List<dynamic> itemCategories = item['categories'];
        return _categoriesFilter
            .every((category) => itemCategories.contains(widget.title));
      }).toList();

    } else{
      showResults = List.from(pages);
    }
    setState(() {
      _resultList = showResults;
    });
  }

  getProvidersPages() async {
    var data = await FirebaseFirestore.instance
        .collection("providers")
        .orderBy("username")
        .get();
    setState(() {
      pages = data.docs;
    });
    searchResultList();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChange);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    getProvidersPages();
    super.didChangeDependencies();
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: CupertinoSearchTextField(
            controller: _searchController,
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child:widget.title=="All categories"? Row(
                  children: [
                    SearchShortcut("Accessories"),
                    SizedBox(width: MediaQuery.of(context).size.width * .02),
                    SearchShortcut("Beauty"),
                    SizedBox(width: MediaQuery.of(context).size.width * .02),
                    SearchShortcut("Clothes"),
                    SizedBox(width: MediaQuery.of(context).size.width * .02),
                    SearchShortcut("Entertainment"),
                    SizedBox(width: MediaQuery.of(context).size.width * .02),
                    SearchShortcut("Gift"),
                    SizedBox(width: MediaQuery.of(context).size.width * .02),
                    SearchShortcut("Kids"),
                    SizedBox(width: MediaQuery.of(context).size.width * .02),
                    SearchShortcut("Shoes"),
                    SizedBox(width: MediaQuery.of(context).size.width * .02),
                    SearchShortcut("All categories"),
                  ],
                ):const SizedBox(),
              ),
            ),
            Expanded(
                child: _resultList.isNotEmpty
                    ? ListView.builder(
  itemCount: _resultList.length,
  itemBuilder: (context, index) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.all(12),
          title: InkWell(
            onTap: () {
              final pageName = _resultList[index]["username"];
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                    ProviderScreen(pageName: pageName!),
                ),
              );
            },
            child: Text(
              _resultList[index]["username"],
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
          leading: CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(
              _resultList[index]["LogoURL"],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12), // Add horizontal padding to the Divider
          child: Divider(
            height: 1, // Set the height of the Divider
            thickness: 1, // Set the thickness of the Divider
            color: Colors.grey, // Set the color of the Divider
          ),
        ),
      ],
    );
  },
)

                    : Center(
                  child: Container(
                    child: const Text(
                      "No Result Found",
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: Colors.red),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
