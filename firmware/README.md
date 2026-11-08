# SmartSense — noyau C

Le dossier `core/` contient le traitement du signal, sans HAL ni allocation dynamique. **Il ne constitue pas encore un firmware autonome à flasher.**

## Fonctions

- Détection IR **I/Q** sur échantillons ADC, amplitude et résidu.
- Observateur discret à trois états.
- Étalonnage, seuils, hystérésis et validation des mesures.
- Surveillance des blocs ADC/DMA, horodatages et dépassements de délai.

## Hypothèses temps réel à vérifier sur la carte

| Élément | Valeur de conception |
|---|---|
| Acquisition | 200 kéch/s par voie |
| Porteuse IR | 10 kHz |
| Bloc | 400 échantillons par voie / 2 ms |
| Délai de calcul | moins de 1 ms par bloc |
| Double tampon, 3 voies, 16 bits | 4 800 octets |
| État initial | Non étalonné jusqu'à calibration |

Le pilote doit récupérer une moitié DMA stable, appeler `ss_rt_begin`, `ss_ir_block` et éventuellement `ss_observer_step`, puis `ss_rt_finish`. En cas d'erreur ou de bloc périmé : **invalider la mesure** et réinitialiser l'observateur. Interroger régulièrement `ss_rt_status` et `ss_detector_status`.

Le watchdog, les interruptions, la calibration persistante et les communications sont encore à intégrer. Une saturation analogique du TIA peut rester invisible à la détection de saturation ADC.

## Tests

```sh
python firmware/tests/run_tests.py --clang CHEMIN/clang.exe --out build/smartsense
```

**22 tests hôte réussis** et compilation de l'objet Cortex-M4F vérifiée. Cela ne prouve ni les délais ni la précision sur la carte.

[Résultats logiciels](../ingenierie/preuves/RESULTATS_LOGICIEL.json) · [Broches et intégration](INTEGRATION_STM32.md) · [Programmation](../PROGRAMMATION.md)
