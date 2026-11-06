/* Freestanding Windows test DLL only. Never link into the STM32 application. */
#ifdef _WIN32
int _fltused = 0;
#endif
