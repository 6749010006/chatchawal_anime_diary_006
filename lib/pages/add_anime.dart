import 'package:chatchawal_anime_diary_006/service/database.dart';
import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';

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
          Shadow(blurRadius: 6, color: Colors.redAccent, offset: Offset(0, 0)),
        ],
      ),
    );
  }
}

// ----------------- หน้า AddAnime -----------------
class AddAnime extends StatefulWidget {
  const AddAnime({super.key});

  @override
  State<AddAnime> createState() => _AddAnimeState();
}

class _AddAnimeState extends State<AddAnime> {
  TextEditingController animetitlecontroller = TextEditingController();
  TextEditingController imageUrlController = TextEditingController();
  TextEditingController episodecontroller = TextEditingController();
  TextEditingController seasoncontroller = TextEditingController();
  double rating = 0.0; // Default rating

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.only(top: 60.0, left: 20.0, right: 20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------- Header ----------
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios_new_outlined),
                  ),
                  const SizedBox(width: 80.0),
                  const Text(
                    "❀ Add To ",
                    style: TextStyle(
                      color: Color(0xFF0123FF),
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    "Anime ❀ ",
                    style: TextStyle(
                      color: Color.fromARGB(255, 255, 153, 0),
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30.0),

              // ---------- Anime Title ----------
              const Text(
                "Anime Title ",
                style: TextStyle(
                  color: Color(0xFF0123FF),
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10.0),
              Container(
                padding: const EdgeInsets.only(left: 20.0),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(15, 23, 0, 0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: animetitlecontroller,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Enter Anime Title",
                  ),
                ),
              ),

              const SizedBox(height: 30.0),
              // ---------- Episode ----------
              const Text(
                "Episode ",
                style: TextStyle(
                  color: Color(0xFF0123FF),
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10.0),
              Container(
                padding: const EdgeInsets.only(left: 20.0),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(15, 23, 0, 0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: episodecontroller,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Enter Episode",
                  ),
                ),
              ),

              const SizedBox(height: 30.0),
              // ---------- Season ----------
              const Text(
                "Season ",
                style: TextStyle(
                  color: Color(0xFF0123FF),
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10.0),
              Container(
                padding: const EdgeInsets.only(left: 20.0),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(15, 23, 0, 0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: seasoncontroller,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Enter Season",
                  ),
                ),
              ),

              const SizedBox(height: 30.0),
              // ---------- Image URL ----------
              const Text(
                "Image URL",
                style: TextStyle(
                  color: Color(0xFF0123FF),
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10.0),
              Container(
                padding: const EdgeInsets.only(left: 20.0),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(15, 255, 253, 253),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: imageUrlController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Enter Image URL",
                  ),
                ),
              ),

              const SizedBox(height: 50.0),
              // ---------- Rating ----------
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
                  // Dropdown เลือก rating
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
                      setState(() => rating = value!);
                    },
                  ),
                  const SizedBox(width: 20),
                  // ---------- แสดงหัวใจ ----------
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
                              child: DiamondHeart(size: 28),
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
              // ---------- Add Button ----------
              GestureDetector(
                onTap: () async {
                  if (animetitlecontroller.text != "" &&
                      episodecontroller.text != "" &&
                      seasoncontroller.text != "") {
                    String addID = randomNumeric(10);
                    Map<String, dynamic> animeInfoMap = {
                      "Anime Title": animetitlecontroller.text,
                      "Episode": episodecontroller.text,
                      "Season": seasoncontroller.text,
                      "Rating": rating,
                      "ImageURL": imageUrlController.text,
                    };
                    await DatabaseMethods().addAnime(animeInfoMap, addID).then((
                      value,
                    ) {
                      animetitlecontroller.clear();
                      episodecontroller.clear();
                      seasoncontroller.clear();
                      imageUrlController.clear();
                      setState(() => rating = 0.0);
                      // กลับไปหน้า Home และบอกว่ามีการเพิ่มสำเร็จ
                      Navigator.pop(context, true);
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  width: 150,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text(
                      "Add ",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
