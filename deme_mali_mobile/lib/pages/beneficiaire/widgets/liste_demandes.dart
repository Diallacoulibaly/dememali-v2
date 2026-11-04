import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../controllers/accueil_beneficiaire_controller.dart';
import '../../../styles/couleurs.dart';
import '../detail/detail_aide_page.dart';
import 'carte_demande.dart';

class ListeDemandes extends ConsumerWidget {
  const ListeDemandes({super.key, this.onVoirTout, this.onDemander});
  final VoidCallback? onVoirTout, onDemander;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(mesDemandesBeneficiaireProvider);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Expanded(child: Text('Mes dernières demandes',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: CouleursApp.noir))),
        TextButton(onPressed: onVoirTout, child: const Text('Voir tout')),
      ]),
      const SizedBox(height: 8),
      async.when(
        loading: () => const Padding(padding: EdgeInsets.all(22),
          child: Center(child: CircularProgressIndicator(color: CouleursApp.vert))),
        error: (error, stack) => _Etat(message: 'Impossible de charger les demandes.',
          action: 'Réessayer', onPressed: () => ref.invalidate(mesDemandesBeneficiaireProvider)),
        data: (demandes) {
          if (demandes.isEmpty) {
            return _Etat(
              message: 'Vous n’avez pas encore de demande d’aide.',
              action: 'Faire une demande', onPressed: onDemander);
          }
          final recent = demandes.take(3).toList();
          return Column(children: [
            for (var i = 0; i < recent.length; i++) ...[
              CarteDemande(
                demande: recent[i],
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => DetailAidePage(demande: recent[i]),
                    ),
                  );
                },
              ),
              if (i < recent.length - 1) const SizedBox(height: 10),
            ],
          ]);
        },
      ),
    ]);
  }
}

class _Etat extends StatelessWidget {
  const _Etat({required this.message, this.action, this.onPressed});
  final String message;
  final String? action;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Container(width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: CouleursApp.blanc, borderRadius: BorderRadius.circular(16)),
    child: Column(children: [
      const Icon(Icons.description_outlined, color: CouleursApp.vert, size: 30),
      const SizedBox(height: 9),
      Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54)),
      if (action != null) TextButton(onPressed: onPressed, child: Text(action!)),
    ]),
  );
}
