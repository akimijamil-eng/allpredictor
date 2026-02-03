import 'package:flutter/material.dart';
import '../main.dart'; // pour t()

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: Text(t('Termes & Conditions', 'Terms & Conditions')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Text(
          t(
            // 🇫🇷 FR
            '''
En utilisant AllPredictor, vous acceptez les conditions suivantes :

1. L’application fournit des informations à titre indicatif uniquement.
2. Aucune garantie de gains ou de résultats n’est fournie.
3. L’utilisateur est seul responsable de l’utilisation des informations.
4. AllPredictor ne peut être tenu responsable des pertes ou dommages.
5. L’accès à certains contenus peut dépendre de sites tiers.

Ces conditions peuvent être modifiées à tout moment.
            ''',

            // 🇬🇧 EN
            '''
By using AllPredictor, you agree to the following terms:

1. The app provides information for informational purposes only.
2. No guarantee of profit or results is provided.
3. The user is solely responsible for the use of the information.
4. AllPredictor cannot be held responsible for losses or damages.
5. Access to some content may depend on third-party websites.

These terms may be updated at any time.
            ''',
          ),
          style: const TextStyle(fontSize: 15, height: 1.6),
        ),
      ),
    );
  }
}
