# Reproduire la revue

1. Avec Python fourni par KiCad 10, exécuter verifier_kicad.py --project <chemin du fichier .kicad_pro>. Cette vérification lit la conception et régénère les rapports ERC/DRC ainsi que AUDIT_NATIF.json. Les contrôles ignorés restent visibles dans les rapports.
2. Dans MATLAB, ajouter le dossier etudes au chemin puis exécuter revue_rd et verifier_simulink_rd. La graine61106 rend les simulations reproductibles. Les modèles utilisent les valeurs exportées par KiCad ; les équations idéales sont documentées dans revue_rd.m. Le modèle Simulink compare une autre implémentation des mêmes équations, pas le matériel.
3. Exécuter les tests firmware selon firmware/README.md ; conserver compilateur, résultats et version des sources. Les objets ARM ne sont pas une image programmable complète.
4. Pour la mécanique locale, ouvrir le maître M2 dans Fusion et les accessoires F3D séparément. Le script local FusionScript/SmartSenseRD peut être lancé dans Scripts et compléments : il importe l’archive M2 exacte, contrôle les interférences et recrée les accessoires. Aucun compte rendu ne doit être marqué PASS après une erreur.
5. Après modification d’un composant, d’une connexion ou d’une empreinte : nouvelle sauvegarde, nouvelles valeurs exportées, nouveaux contrôles et mise à jour des limites. Le manifeste SHA256 relie les fichiers de cette livraison.

Les essais physiques de TESTS.csv ne sont pas exécutables sans carte, instrumentation et protocole de banc. Ils restent A_FAIRE. Aucun résultat de conformité CEM ou ferroviaire n’est fourni.
