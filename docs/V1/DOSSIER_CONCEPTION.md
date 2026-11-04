# SmartSense V1 RevA — decisions et dossier de conception

## Perimetre retenu

Carte de mesure integree sous 24 V SELV, IR module a 10 kHz, ultrasons 40 kHz, STM32G431CBT6 embarque. Essais de laboratoire sous boitier, 0 a 50 degres C, sans condensation. Le cas d'usage convoyeur industriel motive les protections et l'organisation du PCB ; les transducteurs Murata ouverts imposent un environnement interieur propre. Aucune preuve d'immunite CEM, de portee ou de precision ne peut etre deduite des seules verifications CAO.

## Choix de circuits

- Entree 18-30 V : fusible 0451.500MRL 0,5 A / 125 V, Schottky SS110 / 100 V contre inversion, TVS SMBJ33A, resistance serie 2,2 ohms / 0,5 W et 2,2 uF / 100 V. A 53,3 V de clamp specifie sous la forme d'onde fabricant, le R-78HB5.0-0.5 reste sous sa limite d'entree 72 V. Ce calcul n'est pas un essai de surge de l'equipement.
- RECOM R-78HB5.0-0.5, 5 V / 0,5 A, puis deux TLV75533PDBVR : rails numerique et analogique separes, masse commune sans coupure. Capacites de sortie LDO 4,7 uF ; exiger une capacitance effective au moins egale a celle de la datasheet apres tolerances et polarisation DC.
- Reference 1,65 V : diviseur 10k / 10k a 0,1 %, filtre 1 uF, tampon OPA320, resistance d'isolation 47 ohms et reservoir 10 uF pour isoler la charge capacitive du suiveur.
- IR : AO3400A avec RDS(on) specifie a 2,5 V ; 180 ohms / 0,25 W pour TSAL6200 externe. L'emetteur doit etre de l'autre cote du passage pour constituer une barriere. BPW34 directement sur la carte, empreinte locale au pas 5,08 mm et orientation cathode marquee.
- TIA : 10 kohms / 100 pF, marge ideale de photocourant continu voisine de 150 uA pour 1,5 V de reserve. Le gain AC 5,02 apres couplage restaure la sensibilite utile tout en evitant d'amplifier le continu ambiant. Le filtre charge donne environ 43,8 kohms a 10 kHz.
- Photo : passe-haut 10 nF / 10 kohms, gain 5,02, passe-bas 1 kohm / 6,8 nF puis Sallen-Key suiveur 5,1k / 5,1k, 2,2 nF / 1 nF. Capacites C0G ; resistances de filtrage a 1 %, rapports de gain a 0,1 %.
- US : DRV8837, VM=5 V et VCC=3,3 V, deux resistances d'amortissement 22 ohms, MA40S4S externe. nSLEEP rappele bas et IR_GATE rappele bas au reset. Salve cible : 8 cycles a 40 kHz, 200 us.
- Reception US : PESD5V0S1BA au connecteur, resistance 4,7 kohms et couplage 1 nF / polarisation 1 Mohm ; gains 11 et 4,3, filtres RC et Sallen-Key 2,49k / 2,49k, 2,2 nF / 1 nF. Sortie ADC isolee par 100 ohms et 22 nF. Le modele lineaire charge donne un gain total voisin de 14,1 a 40 kHz et une attenuation relative de 43,4 dB a 250 kHz.
- Horloge ASV-8.000MHZ-EJ-T, 3,3 V, +/-20 ppm ; liaison amortie 33 ohms vers PF0, mode HSE bypass requis. Contribution ideale de l'erreur d'horloge : 0,02 mm a 1 m, sans les erreurs acoustiques ou de detection.
- Temperature : sonde externe Semitec 103AT-2, 10 kohms a 25 C, B25/85=3435 K, R et B +/-1 %. Cette reference remplace la NTC generique B3950 de la V0.3. Mettre la sonde dans l'air mesure, a l'ecart des sources chaudes, sur un cable court interne au boitier.

## Contrat materiel / firmware

| Fonction | Broche LQFP48 | Signal MCU |
| --- | --- | --- |
| ADC photo | 8 | PA0 / ADC1_IN1 |
| ADC US | 9 | PA1 / ADC2_IN2 |
| ADC temperature | 16 | PB0 / ADC1_IN15 |
| PWM IR 10 kHz | 43 | PB6 / TIM4_CH1 |
| US sortie principale | 30 | PA8 / TIM1_CH1 |
| US sortie complementaire | 15 | PA7 / TIM1_CH1N |
| Veille pont US | 42 | PB5 / GPIO |
| UART TX/RX | 10 / 11 | PA2 / PA3, USART2 |
| SWD | 37 / 38 | PA13 / PA14 |
| Reset | 7 | PG10-NRST, conserver fonction reset |
| HSE bypass 8 MHz | 5 | PF0 |
| BOOT0 | 45 | PB8, rappel 10k a GND |

Configurer HSE bypass, PLL et timers a partir d'un meme domaine temporel. Exemple de cible : systeme 160 MHz, ADC 40 MHz, temps d'acquisition 47,5 cycles, conversion 12,5 cycles : 1,5 us par conversion, compatible avec 500 kS/s par ADC. Photo et US utilisent deux ADC distincts ; temperature entre fenetres de mesure. A 12 bits et 3,3 V, le pas nominal vaut 0,806 mV, sans pretendre a 12 bits de precision effective. Employer DMA circulaire par blocs ; ne pas reserver deux buffers de 8192 echantillons dans les 32 ko de SRAM.

Le firmware doit detecter les ADC satures, perdre explicitement la validite de distance quand aucun echo fiable n'est trouve, masquer le couplage direct apres la salve et calibrer le retard de groupe analogique. Aucune distance fiable ne doit etre produite uniquement parce qu'un seuil arbitraire est franchi. Les coefficients NTC, le seuil IR et les delais de compensation doivent etre versionnes avec les mesures.

## Interfaces et boitier

UART est une interface 3,3 V de maintenance, pas RS-485 ni une entree automate. SWD VTREF est une entree de mesure pour la sonde de programmation, pas une alimentation a injecter sur la carte. Connecteurs NTC, UART et transducteurs a conserver dans le boitier et sur faisceaux courts. Aucun raccordement direct au secteur ou a une sortie automate 24 V. L'ajout d'un bus industriel isole necessiterait une revision materielle distincte.

Le choix de connecteurs et de passifs exige de confirmer les references fournisseur conformes aux boitiers, tensions, tolerances et dielectriques du BOM. Les empreintes standard sont incluses par reference KiCad ; la BPW34 a une empreinte locale. Les pastilles et points de test ne sont pas des composants a acheter. Ne pas appliquer de revetement sur la surface photosensible ou sur l'ouverture acoustique.

## Calculs de marge

Budget de puissance conservateur : 0,9 W en sortie de l'etage d'entree, rendement suppose 80 %, 18 V minimum => 62,5 mA d'entree. Avec 35 um de cuivre, une piste de 0,75 mm sur 100 mm a environ 65,5 milliohms ; pertes de l'ordre de 0,26 mW a 62,5 mA. Ce calcul ohmique ne remplace pas l'evaluation thermique IPC-2152.

Le modele du TIA utilise GBW=20 MHz, un seul pole d'amplificateur et 120 pF d'entree totale. Il constitue une estimation de stabilite, pas le macromodele fabricant ni une preuve de marge de phase reelle. Les reponses des filtres incluent leur chargement par resolution nodale. Le balayage de 1000 tirages de tolerances concerne seulement la cellule Sallen-Key (R 1 %, C 2 %), sans dispersion des capteurs ni des amplificateurs. Les resultats ne sont pas des mesures.

## Plan d'essais du prototype

1. Inspection polarites, pas de court-circuit, tension d'entree limitee a 18 V avec courant limite ; valider 5 V, 3,3 V D/A et 1,65 V avant de programmer.
2. Verifier reset, demarrage HSE, programmation SWD, horloges timers et ADC sur points de test.
3. Injecter des sinusoides de faible amplitude, mesurer les gains et coupures photo/US et la marge avant saturation. Observer les sorties et la reference au scope pour detecter toute oscillation.
4. Essayer lumiere ambiante LED OFF/ON, masquage complet du faisceau, puis passages a vitesse connue ; relever faux positifs, faux negatifs et saturation.
5. Calibrer US sur cibles planes a 0,20 / 0,50 / 1,00 m, temperature mesuree ; estimer le retard fixe, le temps mort et la dispersion sur au moins 100 acquisitions par point.
6. Mesurer l'echauffement a 18/24/30 V et a charge maximale autorisee ; verifier le regulateur, le module, les resistances et la derive de reference.
7. Realiser preconformite CEM au niveau boitier/cables : ESD, EFT et surge selon les ports et l'environnement choisis dans IEC 61326-1:2020. Les niveaux definitifs et criteres de fonctionnement doivent etre fixes avec le laboratoire.
8. Inspection d'assemblage suivant les criteres de classe 2 convenus avec l'assembleur. Revue CAM du fournisseur et validation des passifs avant commande.

## References principales

- RECOM R-78HB : https://recom-power.com/pdf/Innoline/R-78HB-0.5.pdf
- TI TLV755P : https://www.ti.com/lit/ds/symlink/tlv755p.pdf
- TI OPA320 : https://www.ti.com/lit/gpn/opa320
- TI DRV8837 : https://www.ti.com/lit/ds/symlink/drv8837.pdf
- ST STM32G431 : https://www.st.com/resource/en/datasheet/stm32g431cb.pdf
- AOS AO3400A : https://www.aosmd.com/res/data_sheets/AO3400A.pdf
- Vishay BPW34 : https://www.vishay.com/docs/81521/bpw34.pdf
- Nexperia PESD5V0S1BA : https://assets.nexperia.com/documents/data-sheet/PESD5V0S1BA.pdf
- Abracon ASV : https://abracon.com/Oscillators/ASV.pdf
- Semitec 103AT-2 : https://www.semitec-global.com/uploads/2022/01/P12-13-AT-Thermistor.pdf
- Murata MA40S4S/R : https://www.murata.com/-/media/webrenewal/products/sensor/ultrasonic/open/datasheet_maopn.ashx
- IEC 61326-1:2020 : https://webstore.iec.ch/en/publication/62793
- IPC-2152:2009 : https://www.ipc.org/TOC/IPC-2152.pdf
- IPC assembly J revisions : https://www.electronics.org/news-release/ipc-releases-j-revisions-two-leading-standards-electronics-assembly
- JLCPCB : https://jlcpcb.com/capabilities/pcb-capabilities

## Retours de masse et interpretation des audits

Des points de masse de test traversants ont ete ajoutes pres des etages sensibles. Ils offrent un acces a une masse de sonde et une liaison courte aux deux plans internes. La proximite geometrique entre chaque condensateur critique et une liaison de masse inter-couches est inferieure a 5 mm ; cette heuristique ne mesure pas l inductance de boucle. Des pours GND sur les faces externes completent les plans internes. Les deux pads de masse SWD denses sont connectes directement aux plans pour eviter des freins thermiques incomplets.

Les alimentations 3,3 V sont routees a 0,25 mm pour permettre la sortie des broches au pas 0,5 mm du STM32. Le 5 V utilise 0,35 mm, le 24 V 0,75 mm. Ces largeurs sont des choix de conception au courant budgete, pas une preuve globale de conformite IPC.

Le resume du MCP de placement compte des paires candidates comme chevauchements meme quand leur champ overlap est false. Il signale aussi les composants de face avant au-dessus de la zone interdisant uniquement des pistes et vias de face arriere, tout en indiquant is_footprint_keepout=false. Le controle natif DRC et la verification independante des courtyards permettent de distinguer ces candidats des violations reelles ; conserver le rapport brut pour la tracabilite.

## Resultats CAO finaux

La version finale comporte 138 empreintes, dont points de test et trous de fixation, 85 nets, 803 segments routes et 54 vias de routage. Les 302 affectations broche-signal attendues concordent avec le PCB. Les controles natifs ERC/DRC et de parite ne signalent ni violation, ni liaison ouverte. Aucun centre de via de routage n est situe dans une pastille CMS. La longueur cumulee du net de sommation PD_SUM est de 24,6 mm, toute sur F.Cu ; le modele de stabilite garde une hypothese conservatrice de capacite d entree de120 pF, a confronter au prototype. Les liaisons d horloge HSE sont sur F.Cu, environ10,8mm au total.

L empilage cible est explicite dans KiCad :35um exterieur,18um interieur,prepreg0,20mm de chaque cote,core1,074mm,masques0,01mm et finitionENIG. Il doit etre confirme par le fabricant. Les parametres dielectriques sont des hypotheses de FR4, aucune impedance controlee n est demandee.
