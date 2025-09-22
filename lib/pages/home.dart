//จัดทำโดยชัชวาลย์ เมฆารักษ์กุล   รหัสนศ.6749010006

import 'package:chatchawal_anime_diary_006/pages/add_anime.dart'; //นำเข้าหน้า AddAnime สำหรับเพิ่ม Anime ใหม่
import 'package:chatchawal_anime_diary_006/service/database.dart'; //นำเข้าคลาส DatabaseMethods สำหรับจัดการกับ Firestore
import 'package:cloud_firestore/cloud_firestore.dart'; //นำเข้า Firestore ของ Google Firebase
import 'package:flutter/material.dart'; //นำเข้า Flutter Material สำหรับ Widget UI ต่าง ๆ

String bgImageUrl = "";
//ตัวแปรเก็บ URL ของภาพพื้นหลังของหน้าหลัก
//จะเปลี่ยนตาม Anime ที่เลือกใน PageView

// ----------------- สำหรับครึ่งหัวใจ -----------------
class _HalfClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) => Rect.fromLTWH(0, 0, size.width / 2, size.height);

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) => false;
}

// ----------------- หัวใจเพชรแดง -----------------
class DiamondHeart extends StatelessWidget {
  final double size;
  const DiamondHeart({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return RadialGradient(
          colors: [
            Colors.redAccent.shade400,
            Colors.red.shade900,
            Colors.redAccent.shade700,
          ],
          center: Alignment.topLeft,
          radius: 1.2,
          tileMode: TileMode.mirror,
        ).createShader(bounds);
      },
      child: Icon(
        Icons.favorite,
        color: Colors.white,
        size: size,
        shadows: const [
          Shadow(blurRadius: 12, color: Colors.redAccent, offset: Offset(0, 0)),
          Shadow(blurRadius: 24, color: Colors.red, offset: Offset(0, 0)),
        ],
      ),
    );
  }
}
//---------------------------------------------------

// ----------------- หน้า Home -----------------
class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}
// ---------------------------------------------

// ------State ของ Home ---------------
class _HomeState extends State<Home> {
  Stream<QuerySnapshot>? animeStream;
  PageController pageController = PageController(viewportFraction: 0.85);
  int lastIndex = 0;

  @override
  void initState() {
    super.initState();
    loadAnimeStream();
  }

  // ---------- โหลด Stream
  void loadAnimeStream() {
    animeStream = FirebaseFirestore.instance.collection("Anime").snapshots();
  }

  // ------แสดงรายการ Anime
  Widget showAnimeList() {
    return StreamBuilder<QuerySnapshot>(
      stream: animeStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());

        // อัพเดต lastIndex ทุกครั้ง
        lastIndex = snapshot.data!.docs.length - 1;

        return PageView.builder(
          controller: pageController,
          itemCount: snapshot.data!.docs.length,
          onPageChanged: (index) {
            setState(() {
              bgImageUrl =
                  (snapshot.data!.docs[index].data()
                      as Map<String, dynamic>)["ImageURL"] ??
                  "";
            });
          },

          // ------ Card ของแต่ละ Anime
          itemBuilder: (context, index) {
            DocumentSnapshot ds = snapshot.data!.docs[index];
            final data = ds.data() as Map<String, dynamic>;
            double rating = (data["Rating"] ?? 0.0).toDouble();
            String imageUrl = data["ImageURL"] ?? "";
            if (index == 0 && bgImageUrl.isEmpty && imageUrl.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  bgImageUrl = imageUrl;
                });
              });
            }
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 15.0,
              ),
              child: SizedBox(
                height: 320,
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF0f0f0f),
                        Color(0xFF1a0033),
                        Color(0xFF003344),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.5),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //แสดงปุ่มแก้ไขและลบ
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () => showEditDialog(ds),
                            child: const Padding(
                              padding: EdgeInsets.only(right: 10.0),
                              child: Icon(Icons.edit, color: Colors.orange),
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              try {
                                await DatabaseMethods().deleteAnimeData(ds.id);

                                // 🔴 รีเซ็ตภาพ background หลังลบ
                                if (pageController.hasClients &&
                                    snapshot.data!.docs.isNotEmpty) {
                                  int newIndex = pageController.page!
                                      .round()
                                      .clamp(0, snapshot.data!.docs.length - 2);
                                  final newData =
                                      snapshot.data!.docs[newIndex].data()
                                          as Map<String, dynamic>;
                                  setState(() {
                                    bgImageUrl = newData["ImageURL"] ?? "";
                                  });
                                } else {
                                  setState(() {
                                    bgImageUrl = ""; // ไม่มีข้อมูลแล้ว
                                  });
                                }

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Deleted successfully!"),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Error deleting: $e"),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      //แสดงรูปภาพ, ชื่อ, Episode, Season และ Rating
                      if (imageUrl.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            imageUrl,
                            width: double.infinity,
                            height: 450,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) =>
                                progress == null
                                ? child
                                : const SizedBox(
                                    height: 150,
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                                  Icons.image,
                                  size: 70,
                                  color: Colors.grey,
                                ),
                          ),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        data["Anime Title"] ?? "",
                        style: const TextStyle(
                          color: Color.fromARGB(255, 20, 153, 224),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            "Episode: ${data["Episode"] ?? ""}",
                            style: const TextStyle(
                              color: Color.fromARGB(255, 0, 200, 255),
                              fontSize: 17,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Text(
                            "Season: ${data["Season"] ?? ""}",
                            style: const TextStyle(
                              color: Color.fromARGB(255, 0, 200, 255),
                              fontSize: 17,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Text(
                            "Rating: ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: Color.fromARGB(255, 0, 200, 255),
                            ),
                          ),
                          Text(
                            rating.toStringAsFixed(2),
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: List.generate(5, (i) {
                          double heartValue = i + 1;
                          if (rating >= heartValue) {
                            return const DiamondHeart(size: 28);
                          } else if (rating + 0.5 >= heartValue) {
                            return Stack(
                              children: [
                                Icon(
                                  Icons.favorite_border,
                                  color: Colors.pinkAccent.shade100,
                                  size: 28,
                                ),
                                ClipRect(
                                  clipper: _HalfClipper(),
                                  child: const DiamondHeart(size: 28),
                                ),
                              ],
                            );
                          } else {
                            return Icon(
                              Icons.favorite_border,
                              color: Colors.pinkAccent.shade100,
                              size: 28,
                            );
                          }
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // -----------------Dialog แก้ไข Anime-----------------
  void showEditDialog(DocumentSnapshot ds) {
    final data = ds.data() as Map<String, dynamic>;
    final titleController = TextEditingController(
      text: data["Anime Title"] ?? "",
    );
    final episodeController = TextEditingController(
      text: data["Episode"] ?? "",
    );
    final seasonController = TextEditingController(text: data["Season"] ?? "");
    final imageUrlController = TextEditingController(
      text: data["ImageURL"] ?? "",
    );
    double rating = (data["Rating"] ?? 0.0).toDouble();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.transparent,
          child: StatefulBuilder(
            builder: (context, setState) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white, Colors.grey.shade200],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade400,
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          "❀ Benz Diary Update ❀",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      if (imageUrlController.text.isNotEmpty)
                        Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              imageUrlController.text,
                              width: 150,
                              height: 150,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    Icons.image,
                                    size: 70,
                                    color: Colors.grey,
                                  ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          labelText: "Anime Title",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: episodeController,
                        decoration: InputDecoration(
                          labelText: "Episode",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: seasonController,
                        decoration: InputDecoration(
                          labelText: "Season",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: imageUrlController,
                        decoration: InputDecoration(
                          labelText: "Image URL",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Rating",
                        style: TextStyle(
                          color: Color(0xFF0123FF),
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Row(
                        children: [
                          DropdownButton<double>(
                            value: rating,
                            items: List.generate(11, (index) {
                              double value = index * 0.5;
                              return DropdownMenuItem(
                                value: value,
                                child: Text(value.toStringAsFixed(2)),
                              );
                            }),
                            onChanged: (value) {
                              if (value != null) setState(() => rating = value);
                            },
                          ),
                          const SizedBox(width: 20),
                          Row(
                            children: List.generate(5, (i) {
                              double heartValue = i + 1;
                              if (rating >= heartValue)
                                return const DiamondHeart(size: 28);
                              if (rating + 0.5 >= heartValue)
                                return Stack(
                                  children: [
                                    Icon(
                                      Icons.favorite_border,
                                      color: Colors.red.shade200,
                                      size: 28,
                                    ),
                                    ClipRect(
                                      clipper: _HalfClipper(),
                                      child: const DiamondHeart(size: 28),
                                    ),
                                  ],
                                );
                              return Icon(
                                Icons.favorite_border,
                                color: Colors.red.shade200,
                                size: 28,
                              );
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 12,
                              ),
                            ),
                            child: const Text("Cancel"),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .collection("Anime")
                                  .doc(ds.id)
                                  .update({
                                    "Anime Title": titleController.text,
                                    "Episode": episodeController.text,
                                    "Season": seasonController.text,
                                    "Rating": rating,
                                    "ImageURL": imageUrlController.text,
                                  });
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Updated successfully!"),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 12,
                              ),
                            ),
                            child: const Text("Save"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      //FloatingActionButton เพิ่ม Anime//////////////////////////
      floatingActionButton: GestureDetector(
        onTap: () async {
          bool? added = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddAnime()),
          );

          if (added != null && added) {
            // เลื่อนไปหลังสุดอัตโนมัติ//////////////////////////////////
            pageController.animateToPage(
              lastIndex,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
            );

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Added successfully!"),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF00BFFF), Color(0xFF1E90FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.blueAccent.withOpacity(0.7),
                blurRadius: 15,
                spreadRadius: 2,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: const Text(
            "Add To Anime",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  blurRadius: 20,
                  color: Colors.blueAccent,
                  offset: Offset(0, 0),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          //Background/////////////////////////////////////////////////////////////
          if (bgImageUrl.isNotEmpty)
            SizedBox.expand(
              child: Image.network(bgImageUrl, fit: BoxFit.cover),
            ),
          Container(color: Colors.black.withOpacity(0.6)),
          Container(
            margin: const EdgeInsets.only(top: 60.0, left: 20.0, right: 20.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      "❀ Benz ",
                      style: TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(blurRadius: 20, color: Colors.blueAccent),
                        ],
                      ),
                    ),
                    Text(
                      "Anime ",
                      style: TextStyle(
                        color: Colors.orangeAccent,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(blurRadius: 20, color: Colors.orangeAccent),
                        ],
                      ),
                    ),
                    Text(
                      "Diary ❀",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        shadows: [Shadow(blurRadius: 20, color: Colors.white)],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Expanded(child: showAnimeList()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
