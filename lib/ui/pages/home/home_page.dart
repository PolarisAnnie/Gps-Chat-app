import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero, // 기본 여백 제거
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: 375,
                height: 52,
                color: Color(0xFF3266FF),
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Text(
                      '현재위치',
                      style: TextStyle(
                        fontFamily: 'Paperlogy',
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
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
                          const Expanded(
                            child: Text(
                              '서울시 마포구 서교동',
                              style: TextStyle(
                                fontFamily: 'Paperlogy',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
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
                          Container(
                            child: Image.asset(
                              'assets/images/pin_white.png',
                              width: 30,
                              height: 30,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // 지금 바로 연결 가능한, 텍스트
            Container(
              width: 375,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              alignment: Alignment.centerLeft,
              child: const Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '지금 ',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    TextSpan(
                      text: '바로 연결',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3266FF),
                      ),
                    ),
                    TextSpan(
                      text: ' 가능한,',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 연결 가능한 친구 리스트
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: ListView.separated(
                physics:
                    NeverScrollableScrollPhysics(), // 바깥 ListView 스크롤과 충돌 방지
                shrinkWrap: true,
                itemCount: 4,
                separatorBuilder: (context, index) => Container(
                  margin: EdgeInsets.symmetric(vertical: 12),
                  width: double.infinity,
                  height: 1,
                  color: Colors.grey,
                ),
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 18),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            '영호느님',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'flutter 앱 차업 준비중입니다!',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Color(0xFF3266FF),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Image.asset(
                            'assets/images/chat_white.png',
                            width: 24,
                            height: 24,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 40),
            Container(
              width: 375,
              padding: EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.centerLeft,
              child: const Text(
                '코딩하기 좋은 카페 추천',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 카페 추천 가로 스크롤 리스트
            SizedBox(
              height: 250,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 5,
                padding: EdgeInsets.only(left: 16, right: 12),
                itemBuilder: (context, index) {
                  return Container(
                    width: 268,
                    margin: EdgeInsets.only(right: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 188,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          // 이미지나 내용 넣는 자리
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '모각코 카페',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const Text(
                          '서울시 마포구 서교동 433-2 1층',
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                      ],
                    ),
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
