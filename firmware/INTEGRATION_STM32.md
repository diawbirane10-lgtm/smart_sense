# STM32G431 — intégration à réaliser

Configuration proposée, **non encore testée sur la carte**. Se référer à [SIGNAUX_CARTE.csv](SIGNAUX_CARTE.csv) et aux schémas KiCad.

| Fonction | Connexion |
|---|---|
| HSE externe | PF0, source 8 MHz en **bypass** |
| IR PWM / ADC | PB6 / TIM4_CH1, PA0 / ADC1_IN1 |
| Ultrason | PA8 / TIM1_CH1, PA7 / TIM1_CH1N, PB5 / US_SLEEP |
| Température | PB0 / ADC1_IN15 |
| PC UART2 / J7 | PA2 / PA3 |
| Écran UART1 / J8 | PA9 / PA10, PB7 / HMI_ENABLE |
| SWD | PA13 / PA14 |

**Acquisition envisagée :** ADC1 en séquence PA0/PA1/PB0, **200 000 séquences/s**, tampon `uint16_t adc_dma[2][400][3]` = **4 800 octets**, 2 ms par moitié. Vérifier la fréquence réellement réalisable et l'accès DMA à la mémoire.

Le pilote devra :
1. Horodater les blocs et ne traiter que la moitié DMA terminée.
2. Invalider immédiatement les mesures lors d'une perte de bloc ou d'un retard.
3. Garder les émissions et l'écran désactivés au démarrage jusqu'à initialisation.
4. Transmettre au PC des **résultats décimés** plutôt que les trois voies brutes (≈ 1,2 Mo/s, trop pour UART 115200).
5. Ajouter startup, linker, drivers, watchdog et mesure des temps sur cible.

Les sorties et le comportement lors d'un reset doivent être vérifiés avant tout essai fonctionnel.

[Datasheet STM32G431](https://www.st.com/resource/en/datasheet/stm32g431cb.pdf) · [Conseils ADC ST](https://www.st.com/resource/en/application_note/dm00625282-stm32g4-adc-use-tips-and-recommendations-stmicroelectronics.pdf)
