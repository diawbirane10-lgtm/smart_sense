# Noyau de calcul pour le futur firmware

Le C de `core/` fonctionne sans HAL, sans allocation dynamique et sans système d’exploitation. Il est testé sur PC et compilé en objet Cortex-M4F. **Ce n’est pas encore une application à flasher** : démarrage, pilotes, horloges, ADC/DMA, UART et écran restent à intégrer.

## Fonctions réalisées

- Détection synchrone I/Q sur des blocs ADC 12 bits ; amplitude du fondamental en volts crête, polarisation et résidu RMS.
- Observateur de signal à trois états, calculé sous MATLAB, alimenté uniquement par le signal ADC.
- Étalonnage avec contraste minimum, hystérésis et confirmation sur trois blocs. Un signal faible ne permet pas de distinguer un obstacle d’un émetteur débranché.
- Surveillance de séquence, cadence, âge des données, échéance de calcul et erreurs ADC/DMA. Les défauts et données périmées ne sont pas présentés comme des mesures valides.

## Contrat temps réel

Fréquence d’acquisition **200 kéch/s par voie**, IR **10 kHz**, même base de temps ; le rapport 20 doit rester exact. Blocs de **400 échantillons par voie, soit 2 ms**. Ces choix doivent être mesurés sur la carte. L’observateur exige 2000 échantillons valides après remise à zéro, soit 10 ms.

Le garde temps réel refuse un début de traitement à plus de 1 ms de la fin du bloc, un calcul de plus de 1 ms, ou une fin à 2 ms ou plus de la fin du bloc. La cadence admise est 2 ms ±100 µs. Ces limites sont des choix de prototype, pas une mesure du temps d’exécution réel. La péremption à 100 ms est verrouillée jusqu’à reprise correcte.

Le pilote doit appeler les fonctions dans cet ordre :

1. Lire atomiquement l’identifiant et l’horodatage du bloc DMA terminé. Ne traiter qu’une moitié qui n’est plus en cours d’écriture.
2. Appeler `ss_rt_begin`. En cas d’échec, invalider la décision avec `ss_detector_update(d, NULL, ms)`, réinitialiser l’observateur et publier le défaut.
3. Traiter le bloc avec `ss_ir_block`, et passer ses échantillons à `ss_observer_step` si l’observateur est activé. Appeler `ss_rt_finish` avec l’heure mesurée après les calculs.
4. Publier une nouvelle décision uniquement si garde temps réel **et** qualité ADC sont valides. Sinon invalider immédiatement la décision. Au démarrage, conserver NON_ETALONNE jusqu’à calibration.
5. Appeler `ss_rt_status` et `ss_detector_status` au moins toutes les 10 ms, même sans nouvelle interruption DMA. Transmettre aussi l’âge, la séquence et le motif d’invalidité au PC/écran.

Un dépassement de délai ne doit jamais être masqué en réutilisant le bloc précédent. Les callbacks d’erreur ADC/DMA doivent appeler `ss_rt_acquisition_fault`. Après un redémarrage d’acquisition, réinitialiser les horodatages, l’observateur et la décision. L’étalonnage du noyau est actuellement en RAM.

Le watchdog matériel reste à intégrer dans le pilote STM32. Son rafraîchissement devra dépendre de la progression des tâches d’acquisition et de traitement, pas d’une boucle qui tourne. Une saturation optique ne doit pas provoquer une boucle de redémarrages : afficher le défaut et gérer la reprise. Les émissions restent désactivées au démarrage.

## Mémoire et tests

Trois voies entrelacées et deux moitiés DMA demanderaient `400 × 3 × 2 × 2 = 4800` octets. Prévoir leur placement explicite en SRAM1 accessible au DMA. Les contextes observateur, détecteur et garde occupent ensemble 84 octets. Les sections allouées de l’objet ARM du noyau occupent 2690 octets ; ce n’est pas la taille du firmware complet. Le fichier `.map` et la pile complète restent à vérifier après intégration.

Sous Windows, avec Python et Clang/LLD :

```text
python firmware/tests/run_tests.py --clang CHEMIN/clang.exe --out build/smartsense
```

Le script construit une DLL de test, exécute **22 tests**, compile le même C pour Cortex-M4F et écrit le rapport JSON. Le vecteur MATLAB est dans `etudes/resultats/STIMULUS_ADC.csv`. Les résultats publiés sont dans [RESULTATS_LOGICIEL.json](../ingenierie/preuves/RESULTATS_LOGICIEL.json).

Le résidu quasi nul du test idéal à 9 kHz vient de l’orthogonalité des fenêtres choisies. Il ne représente pas un rejet de bruit mesuré sur la carte. La saturation détectée par le noyau concerne l’ADC ; une saturation du TIA en amont doit être recherchée séparément à TP10.
