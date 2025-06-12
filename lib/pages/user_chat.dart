import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:social/pages/search_page.dart';
import 'package:social/pages/user_service.dart';
import 'package:social/util/chat_tabs/all_tab2.dart';

import '../util/chat_tabs/contact_tab1.dart';

class UserChat extends StatelessWidget {
  UserChat({super.key});

  List<String> people = [
    'Ali',
    'John',
    'Joe',
    'Sem',
    'Ali',
    'John',
    'Joe',
    'Sem',
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        // appBar: AppBar(
        //   backgroundColor: Colors.transparent,
        //   elevation: 0,
        //   title: Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //     children: [
        //       // MyIconsSquare(
        //       //   iconPath: 'assets/logo.png',
        //       //   color: Colors.white.withOpacity(0.1),
        //       // ),
        //       Text(
        //         'Chats',
        //         style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        //       ),
        //       Row(
        //         children: [
        //           GestureDetector(
        //             onTap: () {
        //               Navigator.push(
        //                 context,
        //                 MaterialPageRoute(builder: (context) => SearchPage()),
        //               );
        //             },
        //             child: Icon(Icons.search),
        //           ),
        //           SizedBox(width: 24),
        //           Icon(Icons.more_vert),
        //         ],
        //       ),
        //     ],
        //   ),
        // ),
        body: Column(
          children: [
            SizedBox(height: 70),
            // Stories
            // SizedBox(
            //   height: 85,
            //   child: ListView.builder(
            //     scrollDirection: Axis.horizontal,
            //     itemCount: people.length + 1,
            //     itemBuilder: (context, index) {
            //       return index == 0
            //           ? Padding(
            //             padding: const EdgeInsets.only(right: 3.0, left: 15),
            //             child: Column(
            //               children: [
            //                 GestureDetector(
            //                   onTap:
            //                       () => Navigator.push(
            //                         context,
            //                         MaterialPageRoute(
            //                           builder: (context) => UserService(),
            //                         ),
            //                       ),
            //                   child: Container(
            //                     decoration: BoxDecoration(
            //                       gradient: LinearGradient(
            //                         begin: Alignment.topLeft,
            //                         end: Alignment.bottomRight,
            //                         colors: [
            //                           Color(0xFF84D3FC),
            //                           Color(0xFF7870DB),
            //                         ],
            //                       ),
            //                       shape: BoxShape.circle,
            //                     ),
            //                     height: 55,
            //                     width: 55,
            //                     child: Padding(
            //                       padding: const EdgeInsets.all(8.0),
            //                       child: Icon(
            //                         FontAwesomeIcons.plus,
            //                         color: Colors.white,
            //                         size: 18,
            //                       ),
            //                     ),
            //                   ),
            //                 ),
            //                 Text('My Story', style: TextStyle(fontSize: 12)),
            //               ],
            //             ),
            //           )
            //           : Column(
            //             children: [
            //               Padding(
            //                 padding: const EdgeInsets.symmetric(
            //                   horizontal: 3.0,
            //                 ),
            //                 child: Container(
            //                   height: 55,
            //                   width: 55,
            //                   decoration: BoxDecoration(
            //                     color: Colors.pink,
            //                     shape: BoxShape.circle,
            //                   ),
            //                   child: Padding(
            //                     padding: const EdgeInsets.all(8.0),
            //                     child: Icon(FontAwesomeIcons.p),
            //                   ),
            //                 ),
            //               ),
            //               Text('Nice', style: TextStyle(fontSize: 12)),
            //             ],
            //           );
            //     },
            //   ),
            // ),

            //Contacts
            PreferredSize(
              preferredSize: Size.fromHeight(40),
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(4)),
                child: Container(
                  height: 40,
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.inversePrimary.withOpacity(.2),
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                  child: TabBar(
                    indicator: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    labelColor: Theme.of(context).colorScheme.inversePrimary,
                    unselectedLabelColor: Colors.black,
                    labelStyle: TextStyle(fontWeight: FontWeight.bold),
                    unselectedLabelStyle: TextStyle(
                      fontWeight: FontWeight.normal,
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    tabs: [Tab(text: 'Contacts'), Tab(text: 'All')],
                  ),
                ),
              ),
            ),
            Expanded(child: TabBarView(children: [ContactTab1(), AllTab2()])),
          ],
        ),
      ),
    );
  }
}
