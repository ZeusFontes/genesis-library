import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/constants/colors.dart';
import '../models/cast_member.dart';

class CastAvatar extends StatelessWidget {
  final CastMember member;

  const CastAvatar({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: CachedNetworkImage(
              imageUrl: member.photo,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.secondary,
                child: Text(
                  member.name[0],
                  style: const TextStyle(fontSize: 22, color: AppColors.white),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            member.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: AppColors.white),
          ),
          Text(
            member.role,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10, color: AppColors.grey),
          ),
        ],
      ),
    );
  }
}
