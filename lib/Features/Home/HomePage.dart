import 'package:autoelkady/Core/components/custom_container.dart';
import 'package:autoelkady/Core/components/custom_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:autoelkady/Features/Home/Settings.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  String? selectedBrand;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // 🔹 Top bar
            // later  i need to make the app gets the location automatically from the user
            // later i need to take the pp from the user from the settings page
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.grey,
                      );
                    }

                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return const CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.grey,
                        child: Icon(Icons.person, color: Colors.white),
                      );
                    }

                    final userData =
                        snapshot.data!.data() as Map<String, dynamic>;
                    final profileImageUrl = userData['profileImageUrl'];

                    return CircleAvatar(
                      radius: 24,
                      backgroundImage:
                          profileImageUrl != null && profileImageUrl.isNotEmpty
                          ? NetworkImage(profileImageUrl) // 👈 fetch from DB
                          : const AssetImage(
                                  'assets/images/default_profile.png',
                                )
                                as ImageProvider, // fallback image
                    );
                  },
                ),

                const CustomText(
                  text: 'Cairo Egypt',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),

                IconButton(
                  icon: const Icon(CupertinoIcons.settings),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AppSettings(),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 🔹 Greeting hard coded
            // Row(
            //   children: [
            //     CustomText(
            //       text: 'Hello, ',
            //       fontSize: 35,
            //       color: Colors.grey.shade400,
            //     ),
            //     const CustomText(text: 'Elkady', fontSize: 35),
            //   ],
            // ),

            // Greeting by actual user name
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(
                    FirebaseAuth.instance.currentUser!.uid,
                  ) // later replace with FirebaseAuth.instance.currentUser!.uid
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CustomText(
                    text: "Loading...",
                    fontSize: 35,
                    color: Colors.grey,
                  );
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const CustomText(text: "Hello, Guest", fontSize: 35);
                }

                final userData = snapshot.data!.data() as Map<String, dynamic>;
                final firstName = userData['firstName'] ?? "User";

                return Row(
                  children: [
                    CustomText(
                      text: 'Hello, ',
                      fontSize: 35,
                      color: Colors.grey.shade400,
                    ),
                    CustomText(text: firstName, fontSize: 35),
                  ],
                );
              },
            ),

            const CustomText(
              text: 'Choose your preferred Car',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),

            const SizedBox(height: 20),

            // 🔹 Car brand categories
            // i need to make the buttons pressable and change the color of the button when it is pressed
            // and when no button is pressed the color of the button should be grey and view all cars
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ["Bmw", "Mercedes", "Audi", "Toyota"].map((brand) {
                  final isSelected = selectedBrand == brand;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            selectedBrand =
                                null; // 👈 unselect (reset to all cars)
                          } else {
                            selectedBrand = brand; // 👈 select this brand
                          }
                        });
                      },
                      child: CustomContainer(
                        color: isSelected ? Colors.redAccent : Colors.grey,
                        radius: 20,
                        padding: const EdgeInsets.symmetric(
                          vertical: 5,
                          horizontal: 10,
                        ),
                        child: CustomText(text: brand, color: Colors.white),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),
            // 🔹 Firestore cars
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: (selectedBrand == null)
                    ? FirebaseFirestore.instance.collection('cars').snapshots()
                    : FirebaseFirestore.instance
                          .collection('cars')
                          .where('brand', isEqualTo: selectedBrand)
                          .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No cars available"));
                  }

                  final cars = snapshot.data!.docs;

                  return GridView.builder(
                    itemCount: cars.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 3,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1 / 1.2,
                        ),
                    itemBuilder: (context, index) {
                      final car = cars[index].data() as Map<String, dynamic>;

                      return Card(
                        color: Colors.white,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 🔹 Car image
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(24),
                                topRight: Radius.circular(24),
                              ),
                              child: Image.network(
                                car['image'] ?? '',
                                height: 120,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),

                            // 🔹 Car details
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomText(
                                    text: car['name'] ?? '',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  CustomText(
                                    text: car['brand'] ?? '',
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.redAccent,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      CustomText(
                                        text: "\$${car['price'] ?? ''}",
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      const Icon(
                                        Icons.arrow_circle_right_rounded,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}



/*
1\ when i delete account it comeback to homepage which is wrong it should go back to auth page



*/