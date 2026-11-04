import 'package:deme_mali_mobile/repositories/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import 'package:deme_mali_mobile/models/affectation_don.dart';
import 'package:deme_mali_mobile/models/affectation_don_materiel.dart';
import 'package:deme_mali_mobile/models/demande_aide.dart';
import 'package:deme_mali_mobile/models/don_financier.dart';
import 'package:deme_mali_mobile/models/don_materiel.dart';
import 'package:deme_mali_mobile/models/aide_distribuee.dart';
import 'package:deme_mali_mobile/models/preuve_distribution.dart';
import 'package:deme_mali_mobile/models/rapport_technique.dart';

import 'package:deme_mali_mobile/controllers/beneficiaire_controller.dart';
import 'package:deme_mali_mobile/controllers/aide_distribuee_controller.dart';
import 'package:deme_mali_mobile/controllers/preuve_distribution_controoller.dart';
import 'package:deme_mali_mobile/controllers/rapport_technique_controller.dart';

import 'package:deme_mali_mobile/styles/couleurs.dart';

final String _baseUrl = AuthRepository.baseUrl;

class SuiviDonTimeline extends ConsumerWidget {
  final DonFinancier? donFinancier;
  final DonMateriel? donMateriel;

  final List<AffectationDon> affectations;
  final List<AffectationDonMateriel> affectationsMaterielles;
  final DemandeAide? demandeAide;

  const SuiviDonTimeline({
    super.key,
    this.donFinancier,
    this.donMateriel,
    this.affectations = const [],
    this.affectationsMaterielles = const [],
    this.demandeAide,
  }) : assert(
  (donFinancier != null) != (donMateriel != null),
  'Fournir un seul type de don.',
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final financier = donFinancier != null;

    // Ajout : chargement du rapport technique associé à la demande.
    final rapportTechniqueAsync = demandeAide == null
        ? null
        : ref.watch(rapportTechniqueProvider(demandeAide!.id));

    final demandeDirecteId = financier
        ? donFinancier!.demandeAideId
        : donMateriel!.demandeAideId;

    final affectationsDuDon = financier
        ? affectations
        .where((a) => a.donFinancierId == donFinancier!.id)
        .toList()
        : <AffectationDon>[];

    final affectationsMateriellesDuDon = !financier
        ? affectationsMaterielles
        .where((a) => a.donMaterielId == donMateriel!.id)
        .toList()
        : <AffectationDonMateriel>[];

    final events = <_Etape>[
      _Etape(
        titre: 'Don enregistré',
        description: financier
            ? 'Montant du don : '
            '${_nombre(donFinancier!.montant)} FCFA'
            : 'Don matériel : '
            '${donMateriel!.quantite} ${donMateriel!.unite}',
        terminee: true,
        icone: Icons.volunteer_activism_outlined,
      ),
    ];

    // Cibles dont les distributions doivent être consultées.
    final cibles = <_CibleDistribution>[];

    if (demandeDirecteId != null) {
      // Un don lié directement à une demande ne nécessite
      // pas d'affectation pour retrouver cette demande.
      cibles.add(
        _CibleDistribution(
          demandeAideId: demandeDirecteId,
        ),
      );

      events.add(
        _Etape(
          titre: 'Demande d’aide associée',
          description: demandeAide == null
              ? 'Les informations de la demande ne sont pas disponibles.'
              : rapportTechniqueAsync == null
              ? _descriptionDemande(demandeAide!)
              : rapportTechniqueAsync.when(
            data: (rapportTechnique) => _descriptionDemande(
              demandeAide!,
              rapportTechnique,
            ),
            loading: () => _descriptionDemande(demandeAide!),
            error: (error, stackTrace) =>
                _descriptionDemande(demandeAide!),
          ),
          terminee: demandeAide != null,
          icone: Icons.assignment_outlined,
        ),
      );
    } else {
      // Don général : récupérer les affectations existantes.
      if (financier) {
        if (affectationsDuDon.isEmpty) {
          events.add(
            const _Etape(
              titre: 'Affectations du don',
              description:
              'Aucune affectation enregistrée pour le moment.',
              terminee: false,
              icone: Icons.assignment_outlined,
            ),
          );
        } else {
          for (var i = 0; i < affectationsDuDon.length; i++) {
            final a = affectationsDuDon[i];

            events.add(
              _Etape(
                titre: 'Affectation ${i + 1}',
                description: _descriptionFinanciere(a),
                terminee: true,
                icone: Icons.assignment_turned_in_outlined,
                beneficiaireId:
                a.demandeAideId == null ? a.beneficiaireId : null,
              ),
            );

            if (a.demandeAideId != null) {
              cibles.add(
                _CibleDistribution(
                  demandeAideId: a.demandeAideId!,
                ),
              );
            } else if (a.beneficiaireId != null) {
              cibles.add(
                _CibleDistribution(
                  beneficiaireId: a.beneficiaireId!,
                ),
              );
            }
          }
        }
      } else {
        if (affectationsMateriellesDuDon.isEmpty) {
          events.add(
            const _Etape(
              titre: 'Affectations du don',
              description:
              'Aucune affectation enregistrée pour le moment.',
              terminee: false,
              icone: Icons.assignment_outlined,
            ),
          );
        } else {
          for (var i = 0;
          i < affectationsMateriellesDuDon.length;
          i++) {
            final a = affectationsMateriellesDuDon[i];

            events.add(
              _Etape(
                titre: 'Affectation ${i + 1}',
                description: _descriptionMaterielle(a),
                terminee: true,
                icone: Icons.assignment_turned_in_outlined,
                beneficiaireId:
                a.demandeAideId == null ? a.beneficiaireId : null,
              ),
            );

            if (a.demandeAideId != null) {
              cibles.add(
                _CibleDistribution(
                  demandeAideId: a.demandeAideId!,
                ),
              );
            } else if (a.beneficiaireId != null) {
              cibles.add(
                _CibleDistribution(
                  beneficiaireId: a.beneficiaireId!,
                ),
              );
            }
          }
        }
      }
    }

    // Éviter de charger plusieurs fois la même demande
    // ou le même bénéficiaire.
    final ciblesUniques = <String, _CibleDistribution>{};

    for (final cible in cibles) {
      final cle = cible.demandeAideId != null
          ? 'demande-${cible.demandeAideId}'
          : 'beneficiaire-${cible.beneficiaireId}';

      ciblesUniques[cle] = cible;
    }

    return Container(
      color: CouleursApp.fond,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...List.generate(
            events.length,
                (index) => _TimelineItem(
              event: events[index],
              last: index == events.length - 1,
            ),
          ),

          const SizedBox(height: 8),

          // Nouvelle section : distributions et preuves.
          const Text(
            'Suivi des distributions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: CouleursApp.noir,
            ),
          ),
          const SizedBox(height: 12),

          if (ciblesUniques.isEmpty)
            const _MessageDistribution(
              message:
              'Aucune distribution enregistrer pour le moment. ',
            )
          else
            ...ciblesUniques.values.map(
                  (cible) => _DistributionsPourCible(cible: cible),
            ),
        ],
      ),
    );
  }

  // Description existante, avec ajout du montant final du rapport technique.
  static String _descriptionDemande(
      DemandeAide demande, [
        RapportTechnique? rapportTechnique,
      ]) {
    final parts = <String>[
      demande.titre,
    ];

    if (demande.statutCollecte != null) {
      parts.add(
        'Statut de collecte : '
            '${_statutLisible(demande.statutCollecte)}',
      );
    }

    if (demande.estFinanciere) {
      if (demande.montantCollecte != null) {
        parts.add(
          'Montant collecté : '
              '${_nombre(demande.montantCollecte)} FCFA',
        );
      }
    }

    // Ajout : montant final provenant du rapport technique.
    if (rapportTechnique != null) {
      parts.add(
        'Objectif : '
            '${_nombre(rapportTechnique.montantFinal)} FCFA',
      );
    }

    return parts.join('\n');
  }

  static String _descriptionFinanciere(AffectationDon a) {
    final parts = <String>[];

    if (a.demandeAideId != null) {
      parts.add('Demande #${a.demandeAideId}');
    }

    if (a.beneficiaireId != null) {
      parts.add('Bénéficiaire #${a.beneficiaireId}');
    }

    if (a.organisationPartenaireId != null) {
      parts.add('Organisation #${a.organisationPartenaireId}');
    }

    parts.add('${_nombre(a.montantAffecte)} FCFA affectés');

    if (a.dateAffectation != null &&
        a.dateAffectation!.isNotEmpty) {
      parts.add('Date : ${a.dateAffectation}');
    }

    return parts.join('\n');
  }

  static String _descriptionMaterielle(AffectationDonMateriel a) {
    final parts = <String>[];

    if (a.demandeAideId != null) {
      parts.add('Demande #${a.demandeAideId}');
    }

    if (a.beneficiaireId != null) {
      parts.add('Bénéficiaire #${a.beneficiaireId}');
    }

    if (a.organisationPartenaireId != null) {
      parts.add('Organisation #${a.organisationPartenaireId}');
    }

    parts.add(
      '${a.quantiteAffectee ?? 0} '
          '${a.unite ?? 'article(s)'} affecté(s)',
    );

    if (a.dateAffectation != null &&
        a.dateAffectation!.isNotEmpty) {
      parts.add('Date : ${a.dateAffectation}');
    }

    return parts.join('\n');
  }

  static String _statutLisible(String? statut) {
    switch ((statut ?? '').trim().toUpperCase()) {
      case 'NON_COMMENCEE':
        return 'Non commencée';
      case 'EN_COURS':
        return 'En cours';
      case 'TERMINEE':
        return 'Terminée';
      default:
        return statut ?? 'Non renseigné';
    }
  }

  static String _nombre(num? valeur) {
    if (valeur == null) return '—';

    return valeur.toStringAsFixed(
      valeur == valeur.roundToDouble() ? 0 : 2,
    );
  }
}

class _CibleDistribution {
  final int? demandeAideId;
  final int? beneficiaireId;

  const _CibleDistribution({
    this.demandeAideId,
    this.beneficiaireId,
  });
}

class _Etape {
  final String titre;
  final String description;
  final bool terminee;
  final IconData icone;
  final int? beneficiaireId;

  const _Etape({
    required this.titre,
    required this.description,
    required this.terminee,
    required this.icone,
    this.beneficiaireId,
  });
}

class _TimelineItem extends ConsumerWidget {
  final _Etape event;
  final bool last;

  const _TimelineItem({
    required this.event,
    required this.last,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final couleurBordure = event.terminee
        ? CouleursApp.vert
        : const Color(0xFFD0C9BC);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 38,
            child: Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: event.terminee
                        ? CouleursApp.vert
                        : CouleursApp.blanc,
                    shape: BoxShape.circle,
                    border: Border.all(color: couleurBordure),
                  ),
                  child: Icon(
                    event.terminee ? Icons.check : event.icone,
                    color: event.terminee
                        ? CouleursApp.blanc
                        : CouleursApp.jaune,
                    size: 17,
                  ),
                ),
                if (!last)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: event.terminee
                          ? CouleursApp.vert.withValues(alpha: 0.4)
                          : const Color(0xFFD0C9BC),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: CouleursApp.blanc,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: CouleursApp.fond,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.titre,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: CouleursApp.noir,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    event.description,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: CouleursApp.noir.withValues(alpha: 0.75),
                    ),
                  ),
                  if (event.beneficiaireId != null) ...[
                    const SizedBox(height: 12),
                    _InformationsBeneficiaire(
                      beneficiaireId: event.beneficiaireId!,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DistributionsPourCible extends ConsumerWidget {
  final _CibleDistribution cible;

  const _DistributionsPourCible({
    required this.cible,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultat = cible.demandeAideId != null
        ? ref.watch(
      aidesDistribueesParDemandeProvider(cible.demandeAideId!),
    )
        : ref.watch(
      aidesDistribueesParBeneficiaireProvider(cible.beneficiaireId!),
    );

    return resultat.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: CircularProgressIndicator(
            color: CouleursApp.vert,
          ),
        ),
      ),
      error: (error, stackTrace) => _MessageDistribution(
        message: 'Impossible de charger les distributions.',
        detail: '$error',
        onRetry: () {
          if (cible.demandeAideId != null) {
            ref.invalidate(
              aidesDistribueesParDemandeProvider(cible.demandeAideId!),
            );
          } else {
            ref.invalidate(
              aidesDistribueesParBeneficiaireProvider(
                cible.beneficiaireId!,
              ),
            );
          }
        },
      ),
      data: (distributions) {
        if (distributions.isEmpty) {
          return const _MessageDistribution(
            message:
            'Aucune distribution enregistrée pour cette demande '
                'ou ce bénéficiaire.',
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final distribution in distributions)
              _CarteDistribution(distribution: distribution),
          ],
        );
      },
    );
  }
}

class _CarteDistribution extends ConsumerWidget {
  final AideDistribuee distribution;

  const _CarteDistribution({
    required this.distribution,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preuvesAsync = ref.watch(
      preuvesParDistributionProvider(distribution.id),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: CouleursApp.vert.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.inventory_2_outlined,
                color: CouleursApp.vert,
                size: 24,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 5),
                    _LigneInfo(
                      icone: Icons.calendar_today_outlined,
                      texte: 'Date : '
                          '${distribution.dateDistribution ?? 'Non renseignée'}',
                    ),
                    _LigneInfo(
                      icone: Icons.location_on_outlined,
                      texte: 'Lieu : '
                          '${distribution.lieuDistribution?.trim().isNotEmpty == true ? distribution.lieuDistribution! : 'Non renseigné'}',
                    ),
                    _LigneInfo(
                      icone: Icons.info_outline,
                      texte: 'Statut : '
                          '${distribution.statut ?? 'Non renseigné'}',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(),
          const Text(
            'Preuves de distribution',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: CouleursApp.vert,
            ),
          ),
          const SizedBox(height: 10),
          preuvesAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(
                  color: CouleursApp.vert,
                ),
              ),
            ),
            error: (error, stackTrace) => _MessageDistribution(
              message: 'Impossible de charger les preuves.',
              detail: '$error',
              icone: Icons.error_outline,
            ),
            data: (preuves) {
              if (preuves.isEmpty) {
                return const Text(
                  'Aucune preuve enregistrée pour cette distribution.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: preuves
                    .map((preuve) => _CartePreuve(preuve: preuve))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CartePreuve extends StatelessWidget {
  final PreuveDistribution preuve;

  const _CartePreuve({
    required this.preuve,
  });

  @override
  Widget build(BuildContext context) {
    final type = (preuve.typeMedia ?? '').toLowerCase().trim();
    final url = _urlComplete(preuve.urlFichier);

    if (url == null) {
      return const _MessageDistribution(
        message: 'Le fichier de cette preuve ne possède pas d’URL valide.',
        icone: Icons.broken_image_outlined,
      );
    }

    final estVideo = type.contains('video') ||
        type.contains('vidéo') ||
        type.contains('mp4') ||
        type.contains('webm');

    final estImage = type.contains('image') ||
        type.contains('photo') ||
        type.contains('jpg') ||
        type.contains('jpeg') ||
        type.contains('png') ||
        type.contains('webp');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: CouleursApp.fond,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                estVideo ? Icons.videocam_outlined : Icons.image_outlined,
                color: CouleursApp.vert,
              ),
              const SizedBox(width: 8),
            ],
          ),
          const SizedBox(height: 10),
          if (estVideo)
            _LecteurVideo(url: url)
          else if (estImage)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                url,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;

                  return const SizedBox(
                    height: 150,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: CouleursApp.vert,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return const _MessageDistribution(
                    message: 'Impossible de charger cette image.',
                    icone: Icons.broken_image_outlined,
                  );
                },
              ),
            )
          else
            const _MessageDistribution(
              message: 'Type de média non reconnu.',
              icone: Icons.insert_drive_file_outlined,
            ),
        ],
      ),
    );
  }
}

class _LecteurVideo extends StatefulWidget {
  final String url;

  const _LecteurVideo({
    required this.url,
  });

  @override
  State<_LecteurVideo> createState() => _LecteurVideoState();
}

class _LecteurVideoState extends State<_LecteurVideo> {
  late final VideoPlayerController _controller;
  late final Future<void> _initialisation;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.url),
    );

    _initialisation = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initialisation,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 150,
            child: Center(
              child: CircularProgressIndicator(
                color: CouleursApp.vert,
              ),
            ),
          );
        }

        if (snapshot.hasError || !_controller.value.isInitialized) {
          return const _MessageDistribution(
            message: 'Impossible de charger cette vidéo.',
            icone: Icons.videocam_off_outlined,
          );
        }

        return Column(
          children: [
            AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            ),
            Row(
              children: [
                IconButton(
                  tooltip: _controller.value.isPlaying
                      ? 'Mettre en pause'
                      : 'Lire la vidéo',
                  icon: Icon(
                    _controller.value.isPlaying
                        ? Icons.pause_circle
                        : Icons.play_circle,
                    color: CouleursApp.vert,
                    size: 32,
                  ),
                  onPressed: () {
                    setState(() {
                      if (_controller.value.isPlaying) {
                        _controller.pause();
                      } else {
                        _controller.play();
                      }
                    });
                  },
                ),
                Expanded(
                  child: VideoProgressIndicator(
                    _controller,
                    allowScrubbing: true,
                    colors: const VideoProgressColors(
                      playedColor: CouleursApp.vert,
                      bufferedColor: Color(0xFFD0C9BC),
                      backgroundColor: Color(0xFFE8E1D5),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _InformationsBeneficiaire extends ConsumerWidget {
  final int beneficiaireId;

  const _InformationsBeneficiaire({
    required this.beneficiaireId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(
      beneficiaireDetailProvider(beneficiaireId),
    ).when(
      loading: () => const Text(
        'Chargement du bénéficiaire...',
        style: TextStyle(fontSize: 12),
      ),
      error: (error, stackTrace) => const Text(
        'Impossible de récupérer le bénéficiaire.',
        style: TextStyle(
          fontSize: 12,
          color: Colors.red,
        ),
      ),
      data: (beneficiaire) {
        final nomComplet =
        '${beneficiaire.prenom} ${beneficiaire.nom}'.trim();

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: CouleursApp.fond,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.person_outline,
                color: CouleursApp.vert,
                size: 22,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bénéficiaire',
                      style: TextStyle(
                        color: CouleursApp.vert,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      nomComplet.isEmpty
                          ? 'Nom indisponible'
                          : nomComplet,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: CouleursApp.noir,
                      ),
                    ),
                    if (beneficiaire.ville != null &&
                        beneficiaire.ville!.trim().isNotEmpty)
                      Text(
                        beneficiaire.ville!,
                        style: const TextStyle(fontSize: 12),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LigneInfo extends StatelessWidget {
  final IconData icone;
  final String texte;

  const _LigneInfo({
    required this.icone,
    required this.texte,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icone,
            size: 16,
            color: CouleursApp.vert,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              texte,
              style: const TextStyle(
                fontSize: 12,
                height: 1.4,
                color: CouleursApp.noir,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageDistribution extends StatelessWidget {
  final String message;
  final String? detail;
  final IconData icone;
  final VoidCallback? onRetry;

  const _MessageDistribution({
    required this.message,
    this.detail,
    this.icone = Icons.info_outline,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: CouleursApp.jaune.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icone,
                color: CouleursApp.vert,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: CouleursApp.noir,
                  ),
                ),
              ),
            ],
          ),
          if (detail != null) ...[
            const SizedBox(height: 6),
            Text(
              detail!,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.red,
              ),
            ),
          ],
          if (onRetry != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

String? _urlComplete(String? chemin) {
  if (chemin == null || chemin.trim().isEmpty) {
    return null;
  }

  final valeur = chemin.trim();
  final uri = Uri.tryParse(valeur);

  if (uri != null && uri.hasScheme) {
    return valeur;
  }

  return Uri.parse(_baseUrl).resolve(valeur).toString();
}