# Deux modèles, deux usages

`etude_etat_smartsense.m` reprend R14/R15/C16/C17/U7/R16/C19. Ses états correspondent aux tensions du circuit. Il permet de travailler la commandabilité et l’observabilité, mais son observateur suppose connue l’entrée PHOTO_LP, non acquise directement par la carte.

`observateur_ir.m` modélise le **signal ADC** : deux composantes en quadrature à 10 kHz et un biais continu. Sa mesure est `y = x1 + x3`. La matrice d’évolution contient une rotation d’angle `2π × 10000 / 200000` et un état de biais constant. Le modèle est observable à cette cadence. Les pôles de l’observateur sont placés à `0,995 exp(±jθ)` et `0,999`.

Ce second modèle n’utilise pas PHOTO_LP. Ses gains sont portés dans le C. Les 12000 échantillons synthétiques comprennent une variation d’amplitude, un biais variable, du bruit et une harmonique. Le test 13 compare les résultats C simple précision à ceux de MATLAB double précision ; l’écart maximal observé est inférieur à 2 µV sur ce vecteur. Cela ne mesure pas la précision du capteur physique.

L’observateur estime le fondamental du signal, pas une distance ni les états physiques d’un objet extérieur. Le modèle de signal est autonome : on ne lui attribue pas une commandabilité d’actionneur. La détection I/Q par blocs est conservée comme référence plus simple. L’IA par apprentissage n’est pas nécessaire à ces deux traitements.

Exécuter les scripts dans MATLAB avec Control System Toolbox. Les fichiers de `resultats/` sont exclusivement des simulations. Le fonctionnement de l’ADC, le bruit réel et les temps d’exécution doivent encore être mesurés.
