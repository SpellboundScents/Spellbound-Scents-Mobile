#include <jni.h>
#include <android/log.h>
#include <stdlib.h>
#include <string.h>

#define LOG_TAG "CrispyBridge"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO,  LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

// Provided by our crispy_entry.c
int crispy_run(int argc, char **argv);

static char** jstring_array_to_argv(JNIEnv* env, jobjectArray jargs, int* out_argc) {
    jsize len = (*env)->GetArrayLength(env, jargs);
    char** argv = (char**) calloc((size_t)len + 1, sizeof(char*));
    for (jsize i = 0; i < len; i++) {
        jstring jstr = (jstring)(*env)->GetObjectArrayElement(env, jargs, i);
        const char* utf = (*env)->GetStringUTFChars(env, jstr, 0);
        argv[i] = strdup(utf);
        (*env)->ReleaseStringUTFChars(env, jstr, utf);
        (*env)->DeleteLocalRef(env, jstr);
    }
    argv[len] = NULL;
    *out_argc = (int)len;
    return argv;
}

static void free_argv(char** argv, int argc) {
    for (int i = 0; i < argc; i++) free(argv[i]);
    free(argv);
}

JNIEXPORT jint JNICALL
Java_com_spellbound_crispy_Crispy_run(JNIEnv* env, jclass clazz, jobjectArray jargs) {
    int argc = 0;
    char** argv = jstring_array_to_argv(env, jargs, &argc);

    LOGI("Launching Crispy Doom (argc=%d)", argc);
    int code = crispy_run(argc, argv);

    free_argv(argv, argc);
    return (jint) code;
}