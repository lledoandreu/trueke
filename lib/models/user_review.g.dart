// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_review.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserReview _$UserReviewFromJson(Map<String, dynamic> json) => _UserReview(
  id: json['id'] as String,
  reviewerId: json['reviewer_id'] as String,
  receiverId: json['receiver_id'] as String,
  rating: (json['rating'] as num).toDouble(),
  comment: json['comment'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
  reviewerName: json['reviewerName'] as String? ?? 'Usuario',
  reviewerAvatar: json['reviewerAvatar'] as String? ?? '',
);

Map<String, dynamic> _$UserReviewToJson(_UserReview instance) =>
    <String, dynamic>{
      'id': instance.id,
      'reviewer_id': instance.reviewerId,
      'receiver_id': instance.receiverId,
      'rating': instance.rating,
      'comment': instance.comment,
      'created_at': instance.createdAt.toIso8601String(),
      'reviewerName': instance.reviewerName,
      'reviewerAvatar': instance.reviewerAvatar,
    };
