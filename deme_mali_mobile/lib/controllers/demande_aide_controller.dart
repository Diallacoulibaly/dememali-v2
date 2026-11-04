import '../repositories/demande_aide_donateur_repository.dart' as donateur_repo;
import '../models/demande_aide.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/article_demande.dart';
import '../models/categorie_demande.dart';
import '../models/justificatif.dart';
import '../models/type_justificatif.dart';
import '../repositories/demande_aide_repository.dart';
import 'accueil_beneficiaire_controller.dart';

/// Contrôleur gérant toute la logique métier de création d'une demande d'aide.
/// Il sépare complètement la logique du formulaire de son affichage visuel.
class DemandeAideFormController extends ChangeNotifier {
  final DemandeAideRepository repository;

  DemandeAideFormController({required this.repository});

  // 1. État de la navigation entre les 3 étapes
  int etape = 1;

  // Identifiant de la demande si on est en mode édition
  int? demandeIdAModifier;
  int? organisationPartenaireIdAModifier;
  bool get estModification => demandeIdAModifier != null;

  void preparerPourModification(DemandeAide demande) {
    demandeIdAModifier = demande.id;
    organisationPartenaireIdAModifier = demande.organisationPartenaireId;
    titre = demande.titre;
    description = demande.descriptionSituation;

    final u = demande.niveauUrgence.toUpperCase();
    if (u.contains('FAIBLE')) {
      urgence = 'Faible';
    } else if (u.contains('MOYEN')) {
      urgence = 'Moyenne';
    } else {
      urgence = 'Urgente';
    }

    final t = (demande.typeDemande ?? '').toUpperCase();
    typeAide = t.contains('COLLECTIF') ? 'Collective' : 'Individuelle';
    nombrePersonne = demande.nombrePersonne ?? (typeAide == 'Collective' ? 2 : 1);

    final bool materielle = demande.articles.isNotEmpty || (demande.typeDemandeAide?.toUpperCase() == 'MATERIELLE');
    typeDemandeAide = materielle ? 'MATERIELLE' : 'FINANCIERE';
    montant = demande.montantNecessaire ?? demande.montantTotalRequis;

    articles = List<ArticleDemande>.from(demande.articles);
    categorieIdSelectionnee = demande.categorieDemandeId;

    etape = 1;
    notifyListeners();
  }

  void reinitialiser() {
    demandeIdAModifier = null;
    organisationPartenaireIdAModifier = null;
    etape = 1;
    titre = '';
    typeAide = 'Individuelle';
    nombrePersonne = 1;
    description = '';
    urgence = 'Urgente';
    montant = 0;
    typeDemandeAide = 'FINANCIERE';
    articles = [];
    justificatifs = [];
    chargement = false;
    messageErreur = null;
    notifyListeners();
  }

  // 2. Données saisies par le bénéficiaire
  String titre = '';
  String typeAide = 'Individuelle';
  int nombrePersonne = 1;
  String description = '';
  String urgence = 'Urgente';
  double montant = 0;
  int? categorieIdSelectionnee;

  // Nature de la demande : 'FINANCIERE' ou 'MATERIELLE' (valeurs de l'enum backend TypeDemandeAide)
  String typeDemandeAide = 'FINANCIERE';
  bool get estMaterielle => typeDemandeAide == 'MATERIELLE';

  // Articles demandés (uniquement pour une demande matérielle)
  List<ArticleDemande> articles = [];

  // 3. Catégories chargées depuis le backend Spring Boot
  List<CategorieDemande> categories = [];
  bool chargementCategories = false;

  // Types de justificatifs chargés depuis le backend
  List<TypeJustificatif> typesJustificatifs = [];
  int? typeJustificatifIdSelectionne;
  String typeJustificatifNomSelectionne = 'Certificat médical';

  List<String> get typesJustificatifsNoms => typesJustificatifs.isNotEmpty
      ? typesJustificatifs.map((t) => t.nom).toList()
      : const [
          'Certificat médical',
          'Pièce d’identité',
          'Certificat de scolarité',
          'Facture d’électricité / eau',
          'Autre justificatif',
        ];

  // 4. Justificatifs ajoutés (vide par défaut pour être 100% dynamique)
  List<Justificatif> justificatifs = [];

  // 5. Indicateurs d'état pour l'interface
  bool chargement = false;
  String? messageErreur;

  // Charger les catégories depuis le backend
  Future<void> chargerCategories() async {
    chargementCategories = true;
    notifyListeners();
    try {
      categories = await repository.getCategories();
      if (categories.isNotEmpty && categorieIdSelectionnee == null) {
        categorieIdSelectionnee = categories.first.id;
      }
      await chargerTypesJustificatifs();
    } catch (_) {}
    chargementCategories = false;
    notifyListeners();
  }

  // Changer la catégorie sélectionnée
  void changerCategorie(int? nouvelleCategorieId) {
    categorieIdSelectionnee = nouvelleCategorieId;
    notifyListeners();
  }

  // Définir la nature de la demande choisie avant d'ouvrir le formulaire
  void definirTypeDemandeAide(String type) {
    typeDemandeAide = type == 'MATERIELLE' ? 'MATERIELLE' : 'FINANCIERE';
  }

  // Mémoriser les articles en cours de saisie (sans reconstruire l'écran)
  void enregistrerBrouillonArticles(List<ArticleDemande> saisis) {
    articles = List<ArticleDemande>.from(saisis);
  }

  // Passer à l'étape suivante ou précédente
  void changerEtape(int nouvelleEtape) {
    etape = nouvelleEtape;
    notifyListeners();
  }

  // Changer le type d'aide ('Individuelle', 'Collective')
  void changerTypeAide(String nouveauType) {
    typeAide = nouveauType;
    if (nouveauType.toLowerCase().contains('individu')) {
      nombrePersonne = 1;
    } else {
      if (nombrePersonne <= 1) {
        nombrePersonne = 2; // Valeur par défaut pour une demande collective
      }
    }
    notifyListeners();
  }

  // Mettre à jour le nombre de personnes (uniquement si Collectif)
  void changerNombrePersonne(int nouveauNombre) {
    if (typeAide.toLowerCase().contains('individu')) {
      nombrePersonne = 1;
    } else {
      nombrePersonne = nouveauNombre;
    }
    notifyListeners();
  }

  // Changer le niveau d'urgence (Faible, Moyenne, Urgente)
  void changerUrgence(String nouvelleUrgence) {
    urgence = nouvelleUrgence;
    notifyListeners();
  }

  // Mettre à jour le montant
  void changerMontant(double nouveauMontant) {
    montant = nouveauMontant;
    notifyListeners();
  }

  // Sélectionner un vrai fichier depuis l'appareil
  
  // Charger les types de justificatifs depuis le backend
  Future<void> chargerTypesJustificatifs() async {
    try {
      typesJustificatifs = await repository.getTypesJustificatifs();
      if (typesJustificatifs.isNotEmpty) {
        typeJustificatifIdSelectionne ??= typesJustificatifs.first.id;
        typeJustificatifNomSelectionne = typesJustificatifs.first.nom;
      }
    } catch (_) {}
    notifyListeners();
  }

  // Changer le type de justificatif sélectionné par son nom
  void changerTypeJustificatifParNom(String nom) {
    typeJustificatifNomSelectionne = nom;
    final match = typesJustificatifs.firstWhere(
      (t) => t.nom.toLowerCase().trim() == nom.toLowerCase().trim(),
      orElse: () => typesJustificatifs.isNotEmpty
          ? typesJustificatifs.first
          : const TypeJustificatif(id: 1, nom: 'Certificat médical'),
    );
    typeJustificatifIdSelectionne = match.id;
    notifyListeners();
  }

  Future<bool> choisirFichier() async {
    try {
      final fichiers = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (fichiers.isEmpty) {
        return false;
      }

      final fichier = fichiers.first;
      final nomFichier = fichier.name;
      final extensionFichier = fichier.extension?.toLowerCase() ?? 'pdf';

      // Formatage lisible de la taille
      final octets = fichier.lengthSync() ?? (await fichier.length()) ?? 0;
      String tailleLisible;
      if (octets >= 1024 * 1024) {
        tailleLisible = '${(octets / (1024 * 1024)).toStringAsFixed(1)} MB';
      } else {
        tailleLisible = '${(octets / 1024).toStringAsFixed(0)} KB';
      }

      final octetsFichier = await fichier.readAsBytes();

      final nouveauJustificatif = Justificatif(
        nom: nomFichier,
        taille: tailleLisible,
        extension: extensionFichier,
        chemin: fichier.path,
        octets: octetsFichier,
        typeJustificatifId: typeJustificatifIdSelectionne ?? 1,
      );

      justificatifs.add(nouveauJustificatif);
      notifyListeners();
      return true;
    } catch (e) {
      messageErreur = 'Impossible de sélectionner le fichier : $e';
      notifyListeners();
      return false;
    }
  }

  // Ajouter un justificatif manuellement si nécessaire
  void ajouterJustificatif(Justificatif j) {
    justificatifs.add(j);
    notifyListeners();
  }

  // Supprimer un justificatif
  void supprimerJustificatif(int index) {
    justificatifs.removeAt(index);
    notifyListeners();
  }

  // Validation de l'étape 1
  bool validerEtape1({
    required String titreSaisi,
    required String descriptionSaisie,
    int? nbPersonneSaisi,
  }) {
    if (titreSaisi.trim().isEmpty) {
      messageErreur = 'Veuillez indiquer le titre de votre demande.';
      notifyListeners();
      return false;
    }
    if (descriptionSaisie.trim().isEmpty) {
      messageErreur = 'Veuillez décrire brièvement votre situation.';
      notifyListeners();
      return false;
    }
    if (typeAide.toLowerCase().contains('collectif')) {
      final nb = nbPersonneSaisi ?? nombrePersonne;
      if (nb < 2) {
        messageErreur =
            'Pour une demande collective, le nombre de personnes doit être au moins 2.';
        notifyListeners();
        return false;
      }
      nombrePersonne = nb;
    } else {
      nombrePersonne = 1;
    }

    titre = titreSaisi.trim();
    description = descriptionSaisie.trim();
    messageErreur = null;
    etape = 2;
    notifyListeners();
    return true;
  }

  // Validation de l'étape 2 (demande financière)
  bool validerEtape2({
    required double montantSaisi,
  }) {
    if (montantSaisi <= 0) {
      messageErreur = 'Veuillez saisir un montant valide supérieur à 0 FCFA.';
      notifyListeners();
      return false;
    }

    montant = montantSaisi;
    messageErreur = null;
    etape = 3;
    notifyListeners();
    return true;
  }

  // Fusionner automatiquement les articles identiques (addition des quantités)
  static List<ArticleDemande> fusionnerArticles(List<ArticleDemande> liste) {
    final Map<String, ArticleDemande> map = {};
    for (final a in liste) {
      final des = a.designation.trim();
      final uni = a.unite.trim();
      if (des.isEmpty) continue;
      final cle = '${des.toLowerCase()}__${uni.toLowerCase()}';
      if (map.containsKey(cle)) {
        final existant = map[cle]!;
        map[cle] = ArticleDemande(
          id: existant.id,
          designation: existant.designation,
          quantiteDemandee: existant.quantiteDemandee + a.quantiteDemandee,
          unite: existant.unite,
          prixUnitaireEstime: (a.prixUnitaireEstime != null && a.prixUnitaireEstime! > 0)
              ? a.prixUnitaireEstime
              : existant.prixUnitaireEstime,
        );
      } else {
        map[cle] = a;
      }
    }
    return map.values.toList();
  }

  // Validation de l'étape 2 pour une demande matérielle (articles + montant)
  bool validerEtape2Materielle({
    required List<ArticleDemande> articlesSaisis,
    required double montantSaisi,
  }) {
    final fusionnes = fusionnerArticles(articlesSaisis);
    articles = fusionnes;

    if (articles.isEmpty) {
      messageErreur = 'Veuillez ajouter au moins un article.';
    } else if (articles.any((a) => a.designation.trim().isEmpty)) {
      messageErreur = 'Veuillez indiquer la désignation de chaque article.';
    } else if (articles.any((a) => a.quantiteDemandee <= 0)) {
      messageErreur = 'La quantité de chaque article doit être supérieure à 0.';
    } else if (articles.any((a) => a.unite.trim().isEmpty)) {
      messageErreur = 'Veuillez choisir l\'unité de chaque article.';
    } else if (montantSaisi <= 0) {
      final totalEstime = articles.fold(0.0, (somme, a) => somme + a.sousTotal);
      if (totalEstime > 0) {
        montant = totalEstime;
        messageErreur = null;
        etape = 3;
        notifyListeners();
        return true;
      }
      messageErreur = 'Veuillez saisir un montant valide supérieur à 0 FCFA.';
    } else {
      montant = montantSaisi;
      messageErreur = null;
      etape = 3;
      notifyListeners();
      return true;
    }
    notifyListeners();
    return false;
  }


  // Envoi final de la demande au backend Spring Boot
  Future<bool> envoyerDemande() async {
    chargement = true;
    messageErreur = null;
    notifyListeners();

    try {
      // 1. Récupérer l'ID de l'utilisateur connecté (Bénéficiaire)
      final userIdStr = await repository.stockage.read(key: 'userId');
      final userId = userIdStr != null ? int.tryParse(userIdStr) : null;

      if (userId == null) {
        throw Exception(
            'Session expirée ou identifiant utilisateur introuvable. Veuillez vous reconnecter.');
      }

      // 2. Récupérer l'organisation partenaire liée à ce bénéficiaire
      int? organisationId = organisationPartenaireIdAModifier ??
          await repository.getOrganisationDuBeneficiaire(userId);
      // Si aucune organisation spécifique n'est trouvée, repli vers 1
      organisationId ??= 1;

      // 3. Déterminer la catégorie sélectionnée
      final int categorieId = categorieIdSelectionnee ??
          (categories.isNotEmpty ? categories.first.id : 1);

      // 4. Normaliser le niveau d'urgence
      String urgenceBackend = urgence.toUpperCase();
      if (urgenceBackend == 'URGENTE' || urgenceBackend == 'URGENT') {
        urgenceBackend = 'FORTE';
      }

      // 5. Nombre de personnes et type de demande pour le backend (INDIVIDUEL ou COLLECTIF)
      final String typeDemandeBackend =
          typeAide.toUpperCase().contains('COLLECTIF')
              ? 'COLLECTIF'
              : 'INDIVIDUEL';
      final int nbPersonnesEnvoye = typeDemandeBackend == 'INDIVIDUEL'
          ? 1
          : (nombrePersonne > 0 ? nombrePersonne : 2);

      // 6. Construire le DTO complet attendu par DemandeAideServiceImpl
      final dto = <String, dynamic>{
        'titre': titre,
        'descriptionSituation': description,
        'typeDemande': typeDemandeBackend,
        'typeDemandeAide': typeDemandeAide,
        'niveauUrgence': urgenceBackend,
        'montantNecessaire': montant,
        'nombrePersonne': nbPersonnesEnvoye,
        'beneficiaireId': userId,
        'organisationPartenaireId': organisationId,
        'categorieDemandeId': categorieId,
        if (estMaterielle)
          'articles': articles.map((a) => a.toJson()).toList(),
      };

      // 7. Appel de l'API via le repository (création ou modification)
      final DemandeAide demandeResultat;
      if (estModification) {
        demandeResultat = await repository.modifierDemande(demandeIdAModifier!, dto);
      } else {
        demandeResultat = await repository.creer(dto);
      }

      // 8. Téléversement des justificatifs attachés s'il y en a
      if (justificatifs.isNotEmpty && demandeResultat.id > 0) {
        final Map<int, List<Justificatif>> groupes = {};
        for (final j in justificatifs) {
          final tId = j.typeJustificatifId ??
              typeJustificatifIdSelectionne ??
              (typesJustificatifs.isNotEmpty ? typesJustificatifs.first.id : 1);
          groupes.putIfAbsent(tId, () => []).add(j);
        }

        for (final entry in groupes.entries) {
          await repository.uploaderJustificatifs(
            demandeAideId: demandeResultat.id,
            typeJustificatifId: entry.key,
            justificatifs: entry.value,
          );
        }
      }

      chargement = false;
      notifyListeners();
      return true;
    } catch (e) {
      chargement = false;
      messageErreur = 'Échec de l\'envoi de la demande : $e';
      notifyListeners();
      return false;
    }
  }
}

/// Provider Riverpod exposant le contrôleur de formulaire pour les pages.
/// autoDispose permet de remettre le formulaire à zéro quand on quitte la page.
final demandeAideFormControllerProvider =
    Provider.autoDispose<DemandeAideFormController>((ref) {
  final repo = ref.watch(demandeAideRepositoryProvider);
  final controller = DemandeAideFormController(repository: repo);
  ref.onDispose(controller.dispose);
  return controller;
});



final demandeAideControllerProvider =
    AsyncNotifierProvider<DemandeAideController, List<DemandeAide>>(
  DemandeAideController.new,
);

class DemandeAideController extends AsyncNotifier<List<DemandeAide>> {
  @override
  Future<List<DemandeAide>> build() async {
    return _chargerDemandes();
  }

  Future<List<DemandeAide>> _chargerDemandes() async {
    final repository = ref.read(donateur_repo.demandeAideRepositoryProvider);
    final demandes = await repository.getDemandesDisponibles();

    return demandes
        .where((demande) => demande.statut == 'VALIDEE')
        .toList();
  }

  Future<void> actualiser() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_chargerDemandes);
  }
}

/// Récupérer une demande d'aide précise par son identifiant.
final demandeAideDetailProvider =
    FutureProvider.family<DemandeAide, int>((ref, id) async {
  final repository = ref.watch(donateur_repo.demandeAideRepositoryProvider);
  return repository.getDemandeById(id);
});