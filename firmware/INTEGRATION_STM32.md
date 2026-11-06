# Intégration sur la carte : travail restant

Ce document décrit une configuration candidate, non encore exécutée sur STM32. Les connexions physiques vérifiées sont dans [SIGNAUX_CARTE.csv](SIGNAUX_CARTE.csv). Le noyau C est compilé et testé séparément ; il ne configure aucun périphérique.

- HSE : l’oscillateur externe 8 MHz fournit une horloge à PF0. Configurer le mode bypass, pas un quartz. Valider PLL, tension interne et latence Flash pour la fréquence CPU retenue.
- IR : PB6/TIM4_CH1, 10 kHz ; ADC1_IN1 sur PA0. Vérifier les fonctions alternatives et les options UCPD au démarrage, notamment la charge dead-battery sur PB6.
- Ultrason : PA8/TIM1_CH1 et PA7/TIM1_CH1N ; PB5 maintient US_SLEEP bas au démarrage. Tester d’abord les deux voies séparément.
- Température : PB0/ADC1_IN15. Référence des ADC : rail analogique 3,3 V, distinct du biais de signal 1,65 V.
- Service : USART2, PA2/PA3 vers J7. Écran : USART1, PA9/PA10 vers J8, PB7/HMI_ENABLE maintenu bas jusqu’à initialisation.
- Conserver PA13/PA14 pour SWD et prévoir la gestion des défauts d’horloge et d’alimentation.

Pour le premier pilote, envisager ADC1 en séquence PA0, PA1, PB0 à 200000 séquences/s. Un tampon `uint16_t adc_dma[2][400][3]` représente 4800 octets. Chaque moitié est disponible toutes les 2 ms. Les demandes DMA, la durée de la séquence et les temps d’échantillonnage doivent être vérifiés avec les horloges réellement configurées. Mesurer VREFINT hors de cette séquence rapide si son ajout empêche de tenir le budget.

La moitié DMA achevée passe au traitement par un échange d’identifiant et d’horodatage. Les interruptions notifient ; elles ne formatent pas de messages et ne réalisent pas de calcul long. Après une perte de bloc, invalider la décision et remettre à zéro l’observateur. Appeler le garde temps réel même si aucune donnée nouvelle n’arrive. Une horloge libre à la microseconde est requise pour les délais.

Ne pas envoyer les données brutes des trois voies en continu à 115200 bauds : elles représentent 1,2 Mo/s, contre environ 11,5 ko/s utiles en UART 8N1. Prévoir des résultats décimés à 20 Hz, des commandes bornées et des captures brutes courtes sur demande. L’écran et le PC doivent recevoir la validité et l’âge en plus de la valeur.

Avant de déclarer le firmware opérationnel : ajouter startup et linker script du STM32G431CB, pilotes, watchdog matériel, protocole de commandes, conversion NTC et interface Nextion ; lier une image avec fichier `.map`, programmer par SWD et mesurer les échéances. Vérifier l’autonomie hors débogueur et les sorties lors d’un reset. Le watchdog surveille la progression des tâches ; il ne transforme pas une saturation optique en cause de redémarrage permanent.

Références : [ST DS12589 rév. 6](https://www.st.com/resource/en/datasheet/stm32g431cb.pdf), [ST AN5346](https://www.st.com/resource/en/application_note/dm00625282-stm32g4-adc-use-tips-and-recommendations-stmicroelectronics.pdf), netliste du PCB V1-HMI.
