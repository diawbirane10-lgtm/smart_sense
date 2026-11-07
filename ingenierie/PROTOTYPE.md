> Mise à jour du 6 novembre 2026 : la [revue R&D](revue_RD_20261106/DECISION_ET_REVUE.md) fixe le nouveau périmètre et les essais bloquants. Les performances physiques restent à mesurer.

# Prototype de laboratoire : périmètre et preuves

L’objectif principal est une **barrière infrarouge modulée caractérisable sur banc**. L’ultrason fournit une seconde chaîne d’émission/réception à étudier ; aucune précision de distance n’est annoncée. La thermistance sert d’abord à relever la température. L’écran est un affichage secondaire, le PC conserve les mesures et les états de validité.

Le premier montage visé place l’émetteur externe dans l’axe de l’ouverture IR du couvercle, à 100 mm, sur un support de laboratoire stable. Les tests seront réalisés en intérieur propre. Cette distance est un objectif d’essai, pas une portée déjà démontrée. Les faisceaux sont à fournir terminés, sans soudure utilisateur.

Le PCB V1-HMI et le boîtier M2 restent inchangés pendant cette passe. La priorité est de vérifier la chaîne déjà conçue avant d’ajouter des fonctions. Les sources CAO, les modèles et le code C sont présents ; le firmware complet, la carte assemblée et les mesures de banc manquent encore.

## Pourquoi ces choix

La détection synchrone est une méthode d’instrumentation documentée par Stanford Research Systems. Analog Devices décrit la modulation et la détection synchrone pour limiter les perturbations lumineuses en photodétection. Cela motive le traitement I/Q de l’IR, sans promettre de supprimer une saturation analogique.

Le découpage exigences → conception → prototype → vérification suit les démarches présentées par NI. Les [exigences et états de validation](EXIGENCES.csv) séparent les preuves logicielles des essais physiques. Il s’agit d’une adaptation à un projet étudiant, sans revendication de certification.

## Risques à suivre

| Risque | Conséquence | Contrôle prévu |
|---|---|---|
| Lumière ambiante saturant le TIA | L’AC peut devenir faible malgré un ADC non saturé | Examiner TP10 ; qualifier les éclairages admis. Une surveillance DC automatique demanderait une évolution matérielle. |
| Câble/émetteur IR coupé | Signal faible similaire à une occultation | Nommer l’état SIGNAL_FAIBLE ; ne pas en déduire la cause sans diagnostic supplémentaire. |
| Bloc DMA perdu, périmé ou écrasé | Résultat trompeur | Identifiant, horodatage, propriété des buffers, échéance et invalidation. Vérifier le pilote sur cible. |
| Écran et émissions perturbant l’analogique | Bruit ou chute d’alimentation | Caractériser d’abord IR seul, puis activer écran et ultrason séparément et comparer les captures. |
| Saturation, reset ou démarrage incomplet | Valeur ancienne affichée | État initial non étalonné, validité verrouillée, âge transmis, watchdog matériel à intégrer. |
| Pièces réelles et impression différentes des modèles | Montage ou accès impossible | Premier assemblage à blanc, contrôle des connecteurs accouplés et des câbles avant fermeture. |

Les contrôles ERC/DRC et les 370 connexions comparées restent sans erreur. Ils ne valident pas la CEM, la portée, la thermique ou l’innocuité d’un dispositif de sécurité. Les transducteurs Murata ouverts retenus imposent notamment un usage intérieur adapté.

## Présenter le travail au professeur

Montrer la chaîne IR sur le schéma, expliquer le choix de la modulation, puis comparer le traitement I/Q à l’observateur. Présenter les tests C et la compilation ARM comme des preuves logicielles. Les graphiques synthétiques portent cette mention et ne doivent pas être présentés comme des essais de la carte.

Après fabrication, ajouter au dossier une photo du banc, le matériel utilisé, les réglages, les captures brutes et les résultats du [protocole de banc](PROTOCOLE_BANC.md). Une limite constatée et expliquée est un résultat de R&D ; elle ne doit pas être remplacée par une performance supposée.

Références et liens : [SOURCES.md](SOURCES.md).
