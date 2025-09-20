//จัดทำโดยชัชวาลย์ เมฆารักษ์กุล   รหัสนศ.6749010006
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  Future addAnime(Map<String, dynamic> animeInfoMap, String id) async {
    return await FirebaseFirestore.instance
        .collection("Anime")
        .doc(id)
        .set(animeInfoMap);
  }

  Future<Stream<QuerySnapshot>> getAnimeDetails() async {
    return FirebaseFirestore.instance.collection("Anime").snapshots();
  }

  Future updateRating(double updateRating, String id) async {
    return await FirebaseFirestore.instance.collection("Anime").doc(id).update({
      "Rating": updateRating,
    });
  }

  deleteAnimeData(String id) async {
    return await FirebaseFirestore.instance
        .collection("Anime")
        .doc(id)
        .delete();
  }
}
