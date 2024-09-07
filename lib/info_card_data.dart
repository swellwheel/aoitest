class InfoCardData {
  final String location;
  final List<String> imageCodes;
  final List<String> foodKinds;
  final String postTime;
  final String finishTime;
  final String postId;
  final String userId;
  final String receiverId;
  final int numLikes;
  final int numDislikes;
  final int numInterests;
  final int foodNum;
  final int takedQuantity;
  final String food_description;
  final String user_name;

  InfoCardData({
    required this.location,
    required this.imageCodes,
    required this.foodKinds,
    required this.postTime,
    required this.finishTime,
    required this.postId,
    required this.receiverId,
    required this.userId,
    required this.numLikes,
    required this.numDislikes,
    required this.numInterests,
    required this.foodNum,
    required this.takedQuantity,
    required this.food_description,
    required this.user_name,
  });
}