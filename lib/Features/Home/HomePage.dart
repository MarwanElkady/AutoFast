import 'package:autoelkady/Core/components/custom_container.dart';
import 'package:autoelkady/Core/components/custom_text.dart';
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

            // Top bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(
                    'https://preview.redd.it/k7qeur2wcmm61.jpg?width=640&crop=smart&auto=webp&s=4f8ee906ddd2f4af24643d375b24364f1ede3569',
                  ),
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

            // Greeting
            Row(
              children: [
                CustomText(
                  text: 'Hello, ',
                  fontSize: 35,
                  color: Colors.grey.shade400,
                ),
                const CustomText(text: 'Elkady', fontSize: 35),
              ],
            ),

            const CustomText(
              text: 'Choose your preferred Car',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),

            const SizedBox(height: 20),

            // Categories row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ["BMW", "Mercedes", "Audi", "Toyota"].map((brand) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedBrand = brand;
                        });
                      },
                      child: CustomContainer(
                        color: selectedBrand == brand
                            ? Colors.redAccent
                            : Colors.grey,
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

            // Firestore data
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
                            // Car image from Firebase Storage
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

                            // Car details
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
