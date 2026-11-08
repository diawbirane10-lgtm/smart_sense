# Programmer SmartSense — STM32G431CB

Le **STM32G431CBT6** dispose de Flash et de RAM intégrées. Le noyau C existe, mais l'application complète (démarrage, HAL, pilotes ADC/DMA, horloges, UART, écran) **reste à intégrer**.

## Programmer avec ST-LINK

Connecter une sonde **ST-LINK SWD** au connecteur **J6** (Cortex 10 broches, pas 1,27 mm), puis compiler/flasher avec STM32CubeIDE.

| Broche J6 | Signal |
|---|---|
| 1 | +3V3_D (référence de tension, **pas** alimentation USB) |
| 2 | SWDIO |
| 4 | SWCLK |
| 10 | NRST |
| 3, 5, 9 | GND |
| 6, 7, 8 | NC |

Alimenter la carte par son entrée prévue, et vérifier l'adaptateur/câble avant connexion.

## Communiquer avec un PC

**J7 : UART TTL 3,3 V**, via adaptateur USB/UART (pas RS-232 ni logique 5 V).

| Broche J7 | Signal | Adaptateur |
|---|---|---|
| 1 ou 4 | GND | GND |
| 2 | UART_TX (PA2) | RX |
| 3 | UART_RX (PA3) | TX |

J7 n'alimente pas la carte. Le protocole de communication reste à implémenter ; J8 est réservé à l'écran.

[Code C](firmware/README.md) · [Intégration STM32](firmware/INTEGRATION_STM32.md) · [STM32CubeIDE](https://www.st.com/en/development-tools/stm32cubeide.html)
