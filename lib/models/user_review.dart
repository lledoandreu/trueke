class UserReview {
  final String id;
  final String reviewerId;
  final String reviewerName;
  final String reviewerAvatar;
  final String receiverId;
  final double rating;
  final String comment;
  final DateTime createdAt;

  const UserReview({
    required this.id,
    required this.reviewerId,
    required this.reviewerName,
    required this.reviewerAvatar,
    required this.receiverId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory UserReview.fromMap(Map<String, dynamic> map) {
    return UserReview(
      id: map['id'] as String,
      reviewerId: map['reviewer_id'] as String? ?? '',
      reviewerName: map['reviewer_name'] as String? ?? 'Usuario',
      reviewerAvatar: map['reviewer_avatar'] as String? ?? '',
      receiverId: map['receiver_id'] as String? ?? '',
      rating: (map['rating'] as num? ?? 0.0).toDouble(),
      comment: map['comment'] as String? ?? '',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
    );
  }
}
