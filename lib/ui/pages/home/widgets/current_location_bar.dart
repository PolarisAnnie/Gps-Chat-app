import 'package:flutter/material.dart';
import 'package:gps_chat_app/core/theme/theme.dart';

class CurrentLocationBar extends StatelessWidget {
  final String? location; // 위치 텍스트 (선택적)

  const CurrentLocationBar({super.key, this.location});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // 375 대신 전체 너비 사용
      height: 52,
      color: const Color(0xFF3266FF),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Text(
            '현재위치',
            style: TextStyle(
              fontFamily: 'Paperlogy',
              fontSize: 16,
              // fontWeight: FontWeight.w900,
              color: AppTheme.textOnPrimary,
              shadows: [
                Shadow(
                  offset: Offset(0, 0),
                  blurRadius: 1,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    location ?? '서울시 마포구 서교동', // 기본값 유지
                    style: const TextStyle(
                      fontFamily: 'Paperlogy',
                      fontSize: 16,
                      // fontWeight: FontWeight.w700,
                      color: AppTheme.textOnPrimary,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 0),
                          blurRadius: 1,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Image.asset(
                  'assets/images/pin_white.png',
                  width: 30,
                  height: 30,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
