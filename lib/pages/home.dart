import 'package:chatchawal_anime_diary_006/pages/add_anime.dart';
import 'package:chatchawal_anime_diary_006/service/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

///นายชัชวาลย์ เมฆารักษ์กุล รหัสนักศึกษา 6749010006////
String bgImageUrl = ""; // ✅ เพิ่มตรงนี้

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Stream<QuerySnapshot>? animeStream;

  @override
  void initState() {
    super.initState();
    loadAnimeStream();
  }

  void loadAnimeStream() {
    animeStream = FirebaseFirestore.instance.collection("Anime").snapshots();
  }

  Widget showAnimeList() {
    return StreamBuilder<QuerySnapshot>(
      stream: animeStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return PageView.builder(
          controller: PageController(viewportFraction: 0.85),
          itemCount: snapshot.data!.docs.length,
          onPageChanged: (index) {
            setState(() {
              bgImageUrl =
                  (snapshot.data!.docs[index].data()
                      as Map<String, dynamic>)["ImageURL"] ??
                  "";
            });
          },
          itemBuilder: (context, index) {
            DocumentSnapshot ds = snapshot.data!.docs[index];
            final data = ds.data() as Map<String, dynamic>;
            double rating = (data["Rating"] ?? 0.0).toDouble();
            String imageUrl = data["ImageURL"] ?? "";

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
                              color: Color.fromARGB(255, 255, 255, 255),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
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
                      // ----------------- แสดงหัวใจ -----------------
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
          elevation: 10,
          backgroundColor: Colors.transparent,
          child: StatefulBuilder(
            builder: (context, setState) {
              var elevatedButton = ElevatedButton(
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
              );
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white, Colors.grey.shade200],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
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
                              if (rating >= heartValue) {
                                return const DiamondHeart(size: 28);
                              } else if (rating + 0.5 >= heartValue) {
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
                              } else {
                                return Icon(
                                  Icons.favorite_border,
                                  color: Colors.red.shade200,
                                  size: 28,
                                );
                              }
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
                          elevatedButton,
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
      floatingActionButton: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddAnime()),
        ),
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

// ----------------- สำหรับครึ่งหัวใจ -----------------
class _HalfClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, size.width / 2, size.height);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) => false;
}

// ----------------- หัวใจเพชรแดง -----------------
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
