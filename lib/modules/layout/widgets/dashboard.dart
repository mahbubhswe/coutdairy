import 'package:flutter/material.dart';
import 'package:card_swiper/card_swiper.dart';
import 'accounts_first_card.dart';
import 'accounts_second_card.dart';
import 'accounts_third_card.dart';
import 'app_text.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 115,
          child: Swiper(
            itemCount: 3,
            loop: true,
            autoplay: true,
            itemBuilder: (context, index) {
              if (index == 0) return AccountsFirstCard();
              if (index == 1) return AccountsSecondCard();
              return AccountsThirdCard();
            },
          ),
        ),
        AppText(),
      ],
    );
  }
}
