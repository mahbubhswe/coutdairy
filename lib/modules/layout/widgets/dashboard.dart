import 'package:flutter/material.dart';
import 'package:card_swiper/card_swiper.dart';
import 'accounts_first_card.dart';
import 'accounts_second_card.dart';
import 'app_text.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 116,
          child: Swiper(
            itemCount: 2,
            loop: true,
            autoplay: true,
            itemBuilder: (context, index) {
              if (index == 0) return AccountsFirstCard();
              return AccountsSecondCard();
            },
          ),
        ),
        AppText(),
      ],
    );
  }
}
