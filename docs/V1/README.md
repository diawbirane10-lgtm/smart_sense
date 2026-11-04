# SmartSense V1 — prototype électronique

Application personnelle du module Smart Capteurs & Actionneurs : barrière infrarouge modulée et acquisition ultrasonore, avec STM32G431 embarqué. Le contexte initial est la détection de blocs sur convoyeur ; cette version est un prototype de laboratoire en boîtier, intérieur, avec câblages courts.

## Ouvrir et consulter

- Ouvrir `KiCad/SmartSense_V1.kicad_pro` avec KiCad 10 et ses bibliothèques standard.
- `Schemas_SmartSense_V1.pdf` : schémas en couleurs avec vues agrandies et légendes Libertinus Serif.
- `Dossier_ingenierie_SmartSense_V1.pdf` et `DOSSIER_CONCEPTION.md` : choix, calculs, hypothèses et limites.
- `PCB_Couches_et_Assemblage_V1.pdf` : couches et vues d’assemblage agrandies.
- `fabrication/` : Gerber X2, perçages et consignes pour revue fabricant.
- `BOM_V1.csv`, `BOM_Elements_Externes.csv`, `Placement_SMD.csv` : nomenclature technique et positions.

## Résultats de vérification

PCB 114 × 90 mm, quatre couches, deux plans internes GND, 138 empreintes, 803 segments, 54 vias. ERC et DRC natifs : zéro violation signalée ; zéro liaison ouverte ; zéro écart de parité schéma/PCB. 302 affectations broche–signal concordent. Les contrôles désactivés par la configuration figurent explicitement dans DRC.json ; une vérification indépendante contrôle notamment les cours de composants et les vias dans les plages CMS.

Le rapport MCP brut contient des candidats géométriques, y compris des éléments marqués overlap=false et des régions sans interdiction de composants : ses compteurs ne représentent pas des violations confirmées. Voir le dossier pour cette distinction et les résultats natifs.

## Avant fabrication et utilisation

Faire confirmer l’empilage et la revue CAM au fabricant, puis les références d’achat exactes des passifs et les caractéristiques effectives des condensateurs. La nomenclature est technique, pas une commande d’assemblage validée. Les points de test et trous ne sont pas des composants à acheter. Respecter les consignes de fabrication.

Cette livraison vérifie la conception en CAO ; elle ne constitue ni une certification industrielle ni une qualification CEM. Stabilité, précision, thermique, immunité, émissions et fiabilité nécessitent les mesures décrites dans le plan de qualification. Les transducteurs ouverts ne conviennent pas à un convoyeur poussiéreux sans adaptation mécanique. Le firmware, la calibration et les essais sur matériel restent à réaliser.
