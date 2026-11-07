# SmartSense — revue critique et décision de développement

Revue commencée le 6 novembre et finalisée le 7 novembre 2026. Cette revue remplace les propositions conversationnelles d'application directe sur train. Les documents historiques décrivent la V1 ; ce fichier fixe le périmètre R&D actuel.

## Décision

**GO conditionnel pour un banc expérimental de diagnostic de chaînes de mesure. NO-GO pour une revendication de nouveauté établie, un produit ferroviaire embarqué ou une commande PCBA présentée comme un produit validé.** Aucun essai physique de SmartSense n'a été réalisé. Aucune décision de circulation ou de protection de personnes ne doit être confiée au prototype.

Titre retenu : **SmartSense — Banc de caractérisation et d'identifiabilité des dégradations de chaînes infrarouge et ultrasonore, avec perspective ferroviaire.** Le contexte GoA4 motive le problème ; il ne constitue pas une qualification du dispositif. Un banc contrôlé doit précéder toute maquette de manœuvre de dépôt.

La piste mérite un investissement limité parce que la V1 possède une acquisition analogique caractérisable, une émission commandable et des points de test. En revanche, augmenter l'ambition en annonçant un diagnostic actif original ne serait pas justifié : le PGA460 réalise déjà du diagnostic ultrasonore, AutomatedTrain étudie déjà le diagnostic des capteurs de perception, et la sollicitation active est connue. La contribution devra être une méthode précise ou un résultat expérimental reproductible, avec limites d'identifiabilité, pas une liste de composants.

## Ce que la V1 est réellement

- IR : émetteur TSAL6200 externe, récepteur BPW34 dans la console, TIA 10 kΩ // 100 pF, filtrage et gain, ADC. La barrière en transmission est le premier montage prévu. Ce n'est ni un télémètre optique ni une caméra thermique.
- Ultrason : émetteur/récepteur Murata 40 kHz séparés, pont DRV8837, gain et filtres analogiques fixes. La portée et la précision n'ont pas été mesurées. Les transducteurs ouverts ne conviennent pas à l'extérieur selon Murata. Une variation large de fréquence ne peut pas être supposée utilisable.
- STM32G431CB : acquisition/traitement possibles ; un noyau C testé existe, mais pas encore d'image autonome complète liée, programmée et chronométrée sur cette carte.
- Console M2 : boîtier de laboratoire ventilé, avec écran secondaire et câbles externes. Ni étanchéité, ni matériau ferroviaire, ni qualification vibratoire. La BPW34 reste sur le PCB ; déplacer la tête suppose une nouvelle étude de capacité/câble et de stabilité du TIA.

Le puits optique est un autre verrou : diamètre intérieur 8 mm, longueur construite d'environ 26 mm. Pour un point récepteur centré, l'ordre de grandeur géométrique du demi-angle est seulement atan(4/26), soit 8,7°. La surface réelle de la diode, sa hauteur et l'alignement changent cette couverture. Cette console privilégie une barrière alignée et le rejet de lumière latérale ; elle ne surveille pas une grande zone autour d'un train. Les essais à ±15/±30° servent à mesurer les limites, pas à exiger une couverture inexistante. Ne pas agrandir le trou sans budget de lumière ambiante et calcul de stabilité/saturation.

## Verrou scientifique et expérience décisive

Modèle simplifié y_i = u_i T G + bruit : excitation connue u, transmission de scène T, gain de chaîne G. Toutes les amplitudes d'excitation ne donnent que le produit T·G. Le Jacobien par rapport à T et G est de rang 1 ; deux causes différentes peuvent être indiscernables. La simulation vérifie exactement ce contre-exemple. Ajouter un chemin de référence connu donne le rang 2 **dans ce modèle**. Cela ne démontre pas que notre référence physique isolera toutes les pannes : l'émetteur, les trajets et l'environnement peuvent varier ensemble.

Il faut séparer : (1) signal électrique invalide, (2) signal valide mais scène non identifiable, (3) diagnostic d'une cause étayé par une référence indépendante. Une faible amplitude ne doit pas être étiquetée automatiquement « obstacle » ou « encrassement ».

Question retenue : quelle information supplémentaire minimale permet de distinguer perte de transmission et dégradation de chaîne, pour quels défauts et avec quel coût temporel ? Première preuve : calibration manuelle dans une géométrie connue, avant/après essais. La référence autonome en ligne est une extension non réalisée, à justifier par ces résultats.

## Audit électrique et calculs exécutés

ERC et DRC réexécutés : zéro violation signalée. Netliste fraîche comparée aux pads : 370 affectations vérifiées, zéro écart. PCB : 4 couches, 156 empreintes, 1097 segments, 88 vias. Ces contrôles ne démontrent ni stabilité analogique, ni CEM, ni fiabilité d'assemblage.

Les rapports complets conservent la configuration réelle : ERC ignore les étiquettes globales uniques, jonctions à quatre branches, modèles SPICE et filtres de noms d'empreintes ; DRC ignore les géométries de profils d'accord. Aucune de ces options n'a été changée pour obtenir le résultat. Les empreintes personnalisées doivent donc être contrôlées par cotes fabricant ; le zéro ERC n'en est pas la preuve. L'audit combiné du MCP authoring a expiré deux fois après 30 s : il n'est pas déclaré réussi. Les vérifications natives de connectivité et les rapports CLI sont les preuves effectivement obtenues.

Le transfert petits signaux est calculé depuis les valeurs de la netliste KiCad et les connexions inspectées. Le réseau passif US passe-haut/passe-bas est traité comme un réseau chargé, pas comme deux RC indépendants. Les amplificateurs sont idéaux ; parasitiques et transducteurs ne sont pas caractérisés. 5000 tirages de tolérances indépendantes uniformes ont été exécutés avec graine fixe : ce n'est pas une borne de pire cas.

| Résultat de modèle | Valeur | Interprétation |
|---|---:|---|
| IR, transimpédance totale à 10 kHz | 45,27 kV/A | Ordre de grandeur à confronter à injection calibrée |
| IR, quantiles 5–95 % | 44,85–45,70 kV/A | Tolérances modélisées uniquement |
| US, gain tension à 40 kHz | 14,08 | La résonance du transducteur n'est pas incluse |
| US, quantiles 5–95 % | 13,47–14,69 | Ne prédit pas une précision de distance |
| IR, atténuation à 190 kHz relative à 10 kHz | −59,49 dB | Une fréquence qui se replie à 10 kHz à 200 kéch/s |
| US, atténuation à 160 kHz relative à 40 kHz | −29,82 dB | Essai de réjection indispensable avant de décider d'un filtre V2 |
| Acquisition brute, deux voies 16 bits à 200 kéch/s | 800 ko/s | Environ 69 fois le débit utile UART 115200 8N1 |

Avec trois voies, le contrat firmware actuel requiert 1,2 Mo/s et un double tampon de 4800 octets. L'hypothèse deux voies du calcul de revue n'est pas une modification de ce contrat. Utiliser captures déclenchées courtes et résultats décimés ; ne pas augmenter le débit sans vérifier le câble et les horloges.

Le TIA peut saturer sous lumière ambiante puis produire un ADC situé dans ses rails après le couplage AC. L'absence de clipping ADC ne prouve donc pas la validité optique. À la marge hypothétique de 1,4 V et R9=10 kΩ, le courant continu admissible serait de l'ordre de 140 µA ; mesurer la marge réelle, ne pas présenter ce calcul comme une spécification. Pour l'instant observer V_TIA avec une sonde adaptée. Un moniteur DC intégré serait une évolution matérielle candidate, pas une fonction existante.

Simulink vérifie seulement la cohérence de deux modèles discrets linéaires à 200 kéch/s sur 5 ms : écarts maximaux MATLAB/Simulink 1,63e-15 V et 2,82e-14 V. Les mêmes équations sont utilisées : ce test détecte des erreurs d'implémentation du modèle, pas une erreur physique commune. Les 22 tests C hôte repassent et l'objet Cortex-M4F compile ; cela ne mesure pas l'exécution sur STM32.

## Décisions appliquées et décisions différées

1. Recentrage du titre, des critères et du plan de validation ; aucune revendication de SIL, portée, précision ou nouveauté mondiale.
2. Valeurs KiCad exportées vers MATLAB avec provenance ; modèles, tirages, résultats JSON, figure et modèle Simulink enregistrés. L'outil de calcul graphique KiCad n'a pas été automatisé : ne pas lui attribuer ces calculs.
3. Annotations non électriques des schémas pour annoncer le statut de laboratoire et les tests non réalisés. Netliste et PCB inchangés ; on ne reroute pas une carte sans exigence nouvelle et preuve d'un défaut.
4. Console M2 conservée comme console de banc. Deux accessoires de l'ouverture IR de 8 mm sont ajoutés : bouchon de zéro et porte-LED pour référence manuelle. Maillages fermés contrôlés ; jeu radial nominal 0,2 mm, insertion 2,5 mm. Ajustement imprimé, opacité IR et immobilisation restent à mesurer. Ce montage n'est pas une référence automatique en service.

Le porte-LED proche du récepteur peut saturer la chaîne : commencer avec une source limitée et une atténuation caractérisée, en surveillant V_TIA. Réduire seulement le rapport cyclique ne garantit pas de réduire le pic optique. Une LED différente non caractérisée ne constitue pas une référence absolue. Le fichier STL définit une interface mécanique, pas une procédure d'étalonnage déjà validée.
5. Aucun ajout de caméra, radar, CAN, IA ou batterie : ils augmenteraient coût et risques sans résoudre le verrou identifié. Le protocole PC de mesures est prioritaire sur l'écran.

## Revue PCB, alimentation et environnement

PD_SUM est routé sur une face sans via, longueur totale 11,35 mm. ADC_PHOTO totalise 65,20 mm et deux vias ; cette longueur n'est pas automatiquement un défaut à 10 kHz mais motive une comparaison écran/US actifs et inactifs. Les plans internes et le DRC ne remplacent pas l'examen des boucles de retour, du découplage local, du câble de photodétection et du couplage émission/réception.

Avant commande : valider démarrage à 18/24/30 V sous charge réelle écran, stabilité des LDO, marges TVS/fusible, appel de courant, pertes et échauffement. Confirmer les modèles fournisseurs, les empreintes THT personnalisées, les orientations et le montage des faisceaux avec le prestataire. L'assemblage doit être complet, aucune soudure utilisateur. Demander contrôle et devis avant fabrication ; pas de commande passée par cette revue.

Une application extérieure/dépôt réel demanderait notamment têtes fermées adaptées, alimentation/interfaces propres au matériel roulant, montage, environnement et dossier de sécurité spécifiques. Les normes applicables, éditions, catégories et niveaux seraient définis avec un partenaire ferroviaire. Les essais étudiants proposés ne sont pas des essais de conformité ferroviaire.

## Plan d'essais et décision scientifique

La matrice TESTS.csv distingue tests exécutés, simulations et essais physiques à faire. On n'annonce pas « testé sous tous les angles » : le domaine d'essai est fini et documenté. Commencer en intérieur 20–30 °C, distance IR 100 mm, alimentations SELV limitées ; étendre seulement après résultats. Les angles, matières et niveaux de lumière ont une vérité terrain indépendante. Ne pas exposer les transducteurs ouverts à l'eau ni les circuits sous tension à des contaminants.

Baselines : seuil simple, fusion fixe si les zones observées sont effectivement communes, diagnostic passif, référence manuelle puis éventuel test actif. Comparer à taux de fausses alertes ou disponibilité comparables ; un système qui dit toujours « indéterminé » ne constitue pas un progrès. Séparer séances, objets et conditions entre mise au point et évaluation ; conserver un jeu d'essai aveugle. Les tirages synthétiques ne remplacent pas les répétitions physiques.

Règle de poursuite : poursuivre la contribution active seulement si une information ajoutée distingue physiquement au moins deux hypothèses ambiguës, avec incertitude et coût rapportés. À défaut, conserver un résultat de caractérisation/limite et changer la méthode, sans fabriquer une V2 pour sauver le titre. Une publication reste conditionnelle à cette preuve et à la comparaison des travaux les plus proches.

Zéro erreur sur 200 essais ne prouve pas une fiabilité de 99,9 %. Sous hypothèse d'essais Bernoulli indépendants, il faut 2995 essais sans échec pour une borne supérieure unilatérale de 0,1 % à 95 % ; cela ne couvre pas les scénarios non testés ni une certification.

## État de livraison

Sauvegarde préalable hors dossier actif. Aucun PDF ajouté. Schémas et PCB restent éditables dans KiCad. Le F3D M2 est conservé et ses 78 entrées ont un CRC vérifié. Après récupération de Fusion, son archive exacte a été importée et recalculée le 7 novembre : zéro collision imprévue et zéro avertissement de construction. Deux contacts de modèles sont explicitement classés dans VERIFICATION_FUSION_RD.json : enveloppe du connecteur accouplé et contact des pattes JST dans les trous. Leur classification n'est pas une preuve d'ajustement fournisseur. Les deux accessoires ont été construits en solides paramétriques dans un document distinct, sans avertissement, puis exportés en F3D et STEP ; les STL restent disponibles. Les volumes natifs sont 716,60 et 595,26 mm³. Aucun changement du maître M2 ni du PCB n'a été effectué. La commande native MCP Fusion est restée inaccessible ; la vérification a été exécutée par un script local dans Fusion via le contrôleur Windows.

Les preuves de cette passe sont dans AUDIT_NATIF.json, RESULTATS_MATLAB.json, RESULTATS_SIMULINK.json et RESULTATS_LOGICIEL.json. Les annotations non électriques des schémas ont été contrôlées sans modification de la netliste. Les résultats physiques restent à acquérir ; la carte n'est pas libérée pour usage ferroviaire.

Sources : SOURCES.md. Méthode et modèle : ../../etudes/revue_rd.m et ../../etudes/verifier_simulink_rd.m.
