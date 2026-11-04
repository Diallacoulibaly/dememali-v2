import 'package:flutter/material.dart';

import '../../../styles/couleurs.dart';
import '../don/faire_un_don_page.dart';

class BanniereDonGeneral extends StatelessWidget {
  final int donateurId;
  final String prenom;

  const BanniereDonGeneral({
    super.key,
    required this.donateurId,
    required this.prenom,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 20),
      child: SizedBox(
        width: double.infinity,
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FaireUnDonPage(
                        donateurId: donateurId,
                        prenom: prenom,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: CouleursApp.vert,
                  foregroundColor: CouleursApp.blanc,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    vertical: 17,
                    horizontal: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite_outline,
                      color: Colors.white,
                      size: 22,
                    ),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Faire un don',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
