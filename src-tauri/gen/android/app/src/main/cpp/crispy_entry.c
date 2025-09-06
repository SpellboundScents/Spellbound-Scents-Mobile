// Expose a stable entrypoint we can call from JNI.
// We piggyback on Crispy Doom's 'main'.
// NOTE: Do not call exit()/SDL_Quit on Android; let engine handle lifecycle.

int main(int argc, char **argv); // provided by Crispy Doom

int crispy_run(int argc, char **argv) {
  // Call Crispy's normal main.
  // If Crispy uses setlocale or signals, that's fine in-process on Android.
  return main(argc, argv);
}