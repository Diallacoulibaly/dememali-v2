
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:deme_mali_mobile/controllers/preuve_distribution_controoller.dart';
import 'package:deme_mali_mobile/models/aide_distribuee.dart';
import 'package:deme_mali_mobile/styles/couleurs.dart';

import 'preuve_distribution_widget.dart';

class PreuvesDistributionWidget extends ConsumerWidget {
  const PreuvesDistributionWidget({
    super.key,
    required this.aide,
  });

  final AideDistribuee aide;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preuvesAsync = ref.watch(
      preuvesParDistributionProvider(aide.id),
    );

    return SizedBox.expand(
      child: preuvesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: CouleursApp.vert,
          ),
        ),

        error: (error, stackTrace) => const _MessagePreuve(
          icone: Icons.cloud_off_outlined,
          message: 'Impossible de charger les preuves.',
        ),

        data: (preuves) {
          if (preuves.isEmpty) {
            return const _MessagePreuve(
              icone: Icons.photo_library_outlined,
              message: 'Aucune preuve disponible pour cette distribution.',
            );
          }

          return PageView.builder(
            itemCount: preuves.length,
            controller: PageController(
              viewportFraction: 1,
            ),
            itemBuilder: (context, index) {
              return SizedBox.expand(
                child: PreuveDistributionWidget(
                  preuve: preuves[index],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _MessagePreuve extends StatelessWidget {
  const _MessagePreuve({
    required this.icone,
    required this.message,
  });

  final IconData icone;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icone,
              size: 30,
              color: CouleursApp.noir.withValues(alpha: 0.45),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: CouleursApp.noir.withValues(alpha: 0.65),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
