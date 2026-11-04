import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../models/article_demande.dart';
import '../../../../styles/couleurs.dart';

/// Étape 2 d'une demande MATÉRIELLE :
/// - Formulaire pour ajouter un article (désignation, quantité, unité, prix unitaire).
/// - Si l'article existe déjà (même désignation et même unité), la quantité est automatiquement additionnée.
/// - Les articles choisis sont affichés sous forme d'une liste interactive (avec ajustement + / - et suppression).
class Etape2Articles extends StatefulWidget {
  const Etape2Articles({
    super.key,
    required this.articlesInitiaux,
    required this.montantController,
    required this.onArticlesChange,
    required this.onRetour,
    required this.onContinuer,
  });

  /// Articles déjà saisis (utile si on revient sur cette étape)
  final List<ArticleDemande> articlesInitiaux;
  final TextEditingController montantController;

  /// Appelé à chaque modification pour mémoriser le brouillon
  final ValueChanged<List<ArticleDemande>> onArticlesChange;
  final VoidCallback onRetour;
  final ValueChanged<List<ArticleDemande>> onContinuer;

  static const List<String> unitesDisponibles = [
    'Kg',
    'Sac',
    'Litre',
    'Pièce',
    'Boîte',
    'Paquet',
    'Carton',
    'Bidon',
  ];

  @override
  State<Etape2Articles> createState() => _Etape2ArticlesState();
}

class _Etape2ArticlesState extends State<Etape2Articles> {
  // Liste des articles choisis
  final List<ArticleDemande> _articles = [];

  // Contrôleurs pour le formulaire d'ajout d'article
  final TextEditingController _designationController = TextEditingController();
  final TextEditingController _quantiteController = TextEditingController();
  final TextEditingController _prixController = TextEditingController();
  String _uniteSelectionnee = 'Kg';

  @override
  void initState() {
    super.initState();
    // Charger les articles initiaux en s'assurant de fusionner les éventuels doublons
    for (final a in widget.articlesInitiaux) {
      _ajouterOuFusionner(a, notifier: false);
    }
  }

  @override
  void dispose() {
    _designationController.dispose();
    _quantiteController.dispose();
    _prixController.dispose();
    super.dispose();
  }

  // Notifier le parent des changements et mettre à jour le state local
  void _notifierChangements() {
    setState(() {});
    widget.onArticlesChange(List.unmodifiable(_articles));
  }

  /// Ajouter un article ou additionner sa quantité s'il existe déjà
  void _ajouterOuFusionner(ArticleDemande nouvelArticle, {bool notifier = true}) {
    final desNorm = nouvelArticle.designation.trim().toLowerCase();
    final uniNorm = nouvelArticle.unite.trim().toLowerCase();

    final indexExistant = _articles.indexWhere((a) =>
        a.designation.trim().toLowerCase() == desNorm &&
        a.unite.trim().toLowerCase() == uniNorm);

    if (indexExistant >= 0) {
      // L'article existe déjà avec les mêmes champs : on fait juste une addition de la quantité !
      final existant = _articles[indexExistant];
      final nouvelleQuantite = existant.quantiteDemandee + nouvelArticle.quantiteDemandee;
      final nouveauPrix = (nouvelArticle.prixUnitaireEstime != null &&
              nouvelArticle.prixUnitaireEstime! > 0)
          ? nouvelArticle.prixUnitaireEstime
          : existant.prixUnitaireEstime;

      _articles[indexExistant] = existant.copyWith(
        quantiteDemandee: nouvelleQuantite,
        prixUnitaireEstime: nouveauPrix,
      );
    } else {
      // Nouvel article : on l'ajoute à la liste
      _articles.add(nouvelArticle);
    }

    if (notifier) {
      _notifierChangements();
    }
  }

  /// Action du bouton "Ajouter cet article"
  void _validerEtAjouterArticle() {
    final designation = _designationController.text.trim();
    final quantite = int.tryParse(_quantiteController.text.trim()) ?? 0;
    final prix = double.tryParse(_prixController.text.trim());

    if (designation.isEmpty) {
      _afficherAlerte('Veuillez saisir la désignation de l\'article (ex: Riz).');
      return;
    }
    if (quantite <= 0) {
      _afficherAlerte('Veuillez indiquer une quantité supérieure à 0.');
      return;
    }

    final desNorm = designation.toLowerCase();
    final uniNorm = _uniteSelectionnee.toLowerCase();
    final existant = _articles.any((a) =>
        a.designation.trim().toLowerCase() == desNorm &&
        a.unite.trim().toLowerCase() == uniNorm);

    _ajouterOuFusionner(
      ArticleDemande(
        designation: designation,
        quantiteDemandee: quantite,
        unite: _uniteSelectionnee,
        prixUnitaireEstime: prix != null && prix > 0 ? prix : null,
      ),
    );

    // Vider les champs pour le prochain article
    _designationController.clear();
    _quantiteController.clear();
    _prixController.clear();
    FocusScope.of(context).unfocus();

    // Message de confirmation
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          existant
              ? 'Quantité de "$designation" additionnée (+ $quantite $_uniteSelectionnee) !'
              : 'Article "$designation" ajouté à la liste.',
        ),
        backgroundColor: CouleursApp.vert,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _afficherAlerte(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Augmenter la quantité d'un article (+1)
  void _incrementerQuantite(int index) {
    final a = _articles[index];
    _articles[index] = a.copyWith(quantiteDemandee: a.quantiteDemandee + 1);
    _notifierChangements();
  }

  // Diminuer la quantité d'un article (-1)
  void _decrementerQuantite(int index) {
    final a = _articles[index];
    if (a.quantiteDemandee > 1) {
      _articles[index] = a.copyWith(quantiteDemandee: a.quantiteDemandee - 1);
      _notifierChangements();
    }
  }

  // Supprimer un article de la liste
  void _supprimerArticle(int index) {
    final supprime = _articles.removeAt(index);
    _notifierChangements();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${supprime.designation}" retiré de la liste.'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Calcul du montant total estimé
  double get _totalEstime =>
      _articles.fold(0.0, (somme, a) => somme + a.sousTotal);

  String _formaterMontant(num valeur) {
    final regex = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final texte = valeur.round().toString().replaceAllMapped(
          regex,
          (m) => '${m[1]} ',
        );
    return '$texte FCFA';
  }

  InputDecoration _decoration(String hint, {String? suffixe}) {
    OutlineInputBorder bordure(Color couleur, [double largeur = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: couleur, width: largeur),
        );

    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: Colors.black.withValues(alpha: 0.35),
        fontSize: 14,
      ),
      suffixText: suffixe,
      filled: true,
      fillColor: CouleursApp.blanc,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: bordure(Colors.black.withValues(alpha: 0.15)),
      enabledBorder: bordure(Colors.black.withValues(alpha: 0.15)),
      focusedBorder: bordure(CouleursApp.vert, 1.5),
    );
  }

  Widget _label(String texte) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          texte,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: CouleursApp.noir,
            letterSpacing: 0.3,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final total = _totalEstime;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. CARTE PRINCIPALE : FORMULAIRE D'AJOUT & LISTE DES ARTICLES
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: CouleursApp.blanc,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Quels articles\nvous faut-il ?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: CouleursApp.noir,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Ajoutez les articles. Si vous ajoutez le même article, sa quantité sera automatiquement additionnée.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black.withValues(alpha: 0.55),
                ),
              ),
              const SizedBox(height: 20),

              // BLOC DE SAISIE DE L'ARTICLE
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBF9F5),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: CouleursApp.vert,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add,
                            color: CouleursApp.blanc,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Ajouter un article',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: CouleursApp.noir,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Champ Désignation
                    _label('DÉSIGNATION DE L\'ARTICLE'),
                    TextField(
                      controller: _designationController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: _decoration('Ex : Riz, Huile, Cahiers...'),
                    ),
                    const SizedBox(height: 12),

                    // Ligne Quantité + Unité
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('QUANTITÉ'),
                              TextField(
                                controller: _quantiteController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                decoration: _decoration('Ex : 10'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 6,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('UNITÉ'),
                              DropdownButtonFormField<String>(
                                initialValue: _uniteSelectionnee,
                                isExpanded: true,
                                decoration: _decoration(''),
                                items: Etape2Articles.unitesDisponibles
                                    .map((u) => DropdownMenuItem(
                                          value: u,
                                          child: Text(u),
                                        ))
                                    .toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _uniteSelectionnee = val);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Champ Prix unitaire estimé (optionnel)
                    _label('PRIX UNITAIRE ESTIMÉ (OPTIONNEL)'),
                    TextField(
                      controller: _prixController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: _decoration('Ex : 500', suffixe: 'FCFA'),
                    ),
                    const SizedBox(height: 16),

                    // Bouton Ajouter à la liste
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton.icon(
                        onPressed: _validerEtAjouterArticle,
                        icon: const Icon(Icons.playlist_add_rounded, size: 20),
                        label: const Text(
                          'Ajouter à la liste',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CouleursApp.vert,
                          foregroundColor: CouleursApp.blanc,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // TITRE DE LA SECTION "LISTE DES ARTICLES CHOISIS"
              Row(
                children: [
                  const Text(
                    'Articles choisis',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: CouleursApp.noir,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _articles.isNotEmpty
                          ? CouleursApp.vert
                          : Colors.black.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${_articles.length}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: _articles.isNotEmpty ? CouleursApp.blanc : CouleursApp.noir,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // LISTE DES ARTICLES CHOISIS
              if (_articles.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 36,
                        color: Colors.black.withValues(alpha: 0.25),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Aucun article dans la liste pour l\'instant.',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Utilisez le formulaire ci-dessus pour ajouter des articles.',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.black.withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Column(
                  children: [
                    for (var i = 0; i < _articles.length; i++)
                      _buildElementListeArticle(i, _articles[i]),
                  ],
                ),

              const SizedBox(height: 24),

              // MONTANT NÉCESSAIRE
              const Text(
                'MONTANT NÉCESSAIRE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: CouleursApp.noir,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: widget.montantController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: _decoration('Ex : 150000', suffixe: 'FCFA'),
              ),
              const SizedBox(height: 12),

              // Total estimé des articles
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF9EE),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: CouleursApp.jaune.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total estimé des articles',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6B5838),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formaterMontant(total),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: CouleursApp.noir,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (total > 0)
                      TextButton(
                        onPressed: () {
                          widget.montantController.text = total.round().toString();
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: CouleursApp.vert,
                        ),
                        child: const Text(
                          'Utiliser',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // 2. BOUTONS RETOUR ET CONTINUER
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 54,
                child: OutlinedButton(
                  onPressed: widget.onRetour,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: CouleursApp.blanc,
                    foregroundColor: CouleursApp.noir,
                    side: BorderSide(
                      color: Colors.black.withValues(alpha: 0.15),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Retour',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    if (_articles.isEmpty) {
                      _afficherAlerte('Veuillez ajouter au moins un article à la liste.');
                      return;
                    }
                    widget.onContinuer(_articles);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CouleursApp.vert,
                    foregroundColor: CouleursApp.blanc,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Continuer',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Carte d'affichage d'un article dans la liste (disposition épurée sur 2 lignes)
  Widget _buildElementListeArticle(int index, ArticleDemande article) {
    final aPrix = article.prixUnitaireEstime != null && article.prixUnitaireEstime! > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAF9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ligne 1 : Nom de l'article en gras + Bouton supprimer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: CouleursApp.vert,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        article.designation,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: CouleursApp.noir,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () => _supprimerArticle(index),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: Colors.black.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Ligne 2 : Prix unitaire / unité à gauche et Stepper compact à droite
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  aPrix
                      ? '${article.prixUnitaireEstime!.round()} FCFA / ${article.unite}'
                      : 'Unité : ${article.unite}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.black.withValues(alpha: 0.65),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                height: 30,
                decoration: BoxDecoration(
                  color: CouleursApp.blanc,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black.withValues(alpha: 0.12)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: article.quantiteDemandee > 1
                          ? () => _decrementerQuantite(index)
                          : null,
                      borderRadius: BorderRadius.circular(14),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        child: Icon(
                          Icons.remove,
                          size: 14,
                          color: article.quantiteDemandee > 1
                              ? CouleursApp.noir
                              : Colors.black.withValues(alpha: 0.25),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        '${article.quantiteDemandee} ${article.unite}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: CouleursApp.vert,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => _incrementerQuantite(index),
                      borderRadius: BorderRadius.circular(14),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        child: Icon(Icons.add, size: 14, color: CouleursApp.noir),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

