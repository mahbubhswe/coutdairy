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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Widget buildCarouselCard(Widget child) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            colors: isDark
                ? const [Color(0xFF151A2B), Color(0xFF10131F)]
                : const [Color(0xFFEFF3FF), Color(0xFFF9FBFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.45)
                  : Colors.black.withOpacity(0.08),
              blurRadius: 26,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: child,
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: SizedBox(
            height: 360,
            child: Swiper(
              itemCount: 3,
              loop: true,
              autoplay: true,
              viewportFraction: 0.94,
              scale: 0.98,
              pagination: SwiperPagination(
                builder: DotSwiperPaginationBuilder(
                  size: 6,
                  activeSize: 10,
                  color: theme.colorScheme.primary.withOpacity(0.2),
                  activeColor: theme.colorScheme.primary,
                ),
              ),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return buildCarouselCard(AccountsFirstCard());
                }
                if (index == 1) {
                  return buildCarouselCard(AccountsSecondCard());
                }
                return buildCarouselCard(AccountsThirdCard());
              },
            ),
          ),
        ),
        const AppText(),
      ],
    );
  }
}
