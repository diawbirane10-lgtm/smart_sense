# Programmer SmartSense

Le STM32G431CBT6 est déjà le processeur de la carte. Sa mémoire Flash de 128 Ko conserve le programme hors tension ; ses 32 Ko de RAM servent aux calculs et aux buffers. Il exécute le firmware après le démarrage. Il n’est pas nécessaire d’ajouter un processeur ou une mémoire externe pour les premières fonctions de mesure et d’estimation.

## Du modèle au firmware

MATLAB sert à vérifier les équations du filtre et le comportement de l’observateur. Le firmware de la carte s’écrit en C ou C++, par exemple avec STM32CubeIDE, puis se compile pour le STM32. Le programme doit gérer l’horloge, les ADC, les timers d’émission, les calculs et les communications.

Le [noyau C](firmware/README.md) contient maintenant la détection I/Q, un observateur du signal ADC et les contrôles de validité temps réel. Il passe 22 tests sur PC et compile en objet Cortex-M4F. Le nouveau modèle de signal ne demande pas l’entrée PHOTO_LP ; le modèle physique du filtre conserve cette hypothèse pour son étude pédagogique. Une application complète à flasher, avec ses pilotes et ses tests sur carte, reste à réaliser.

## Charger et déboguer le code : J6

```text
PC avec STM32CubeIDE → USB → sonde ST-LINK → câble Cortex 10 broches / 1,27 mm → J6
```

La sonde est externe et doit être compatible SWD. Vérifier le câble ou l’adaptateur adapté au connecteur Cortex 10 broches. Le brochage ci-dessous provient de la netliste de la carte.

| J6 | Signal | Fonction |
|---|---|---|
| 1 | +3V3_D | Référence de tension de la cible pour la sonde |
| 2 | SWDIO | Données de programmation/débogage |
| 4 | SWCLK | Horloge SWD |
| 10 | NRST | Réinitialisation |
| 3, 5, 9 | GND | Masse commune |
| 6, 7, 8 | Non connectées | Ne pas utiliser |

Alimenter la carte par son entrée prévue, suivant sa procédure de mise sous tension. J6/1 n’est pas une entrée d’alimentation USB ou 5 V. Avec les réglages de démarrage usuels, le programme chargé en Flash fonctionne ensuite sans PC ni sonde.

## Échanger avec le PC ou le laboratoire : J7

```text
PC → USB → adaptateur USB/UART logique 3,3 V → J7
```

| J7 | Signal côté carte | Raccordement adaptateur |
|---|---|---|
| 1 ou 4 | GND | GND |
| 2 | UART_TX, PA2 | RX |
| 3 | UART_RX, PA3 | TX |

J7 ne fournit pas d’alimentation. Utiliser des signaux UART TTL 3,3 V, pas du RS-232 ou du 5 V. La carte ne possède pas de connecteur USB direct. Le firmware devra définir les commandes, le format des mesures et le débit. Cette liaison pourra servir aux réglages et à l’acquisition depuis le laboratoire ; elle n’est pas présentée ici comme un chargeur de firmware déjà réalisé. J8 est réservé à l’écran.

Sources : [STM32G431CB et mémoires intégrées](https://www.st.com/en/microcontrollers-microprocessors/stm32g431cb.html), [STM32CubeIDE](https://www.st.com/en/development-tools/stm32cubeide.html), schémas `12_MCU_Core`, `14_Service` et netliste SmartSense V1-HMI.
