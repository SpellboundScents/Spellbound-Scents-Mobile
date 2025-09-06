use anyhow::Result;
use jni::{objects::{JObject, JString, JValue}, strings::JNIString, JNIEnv};
use tauri::{AppHandle, Manager};
use std::path::PathBuf;

fn iwad_fullpath(app: &AppHandle, iwad: &str) -> Result<PathBuf> {
    let base = app.path().app_data_dir()
        .ok_or_else(|| anyhow::anyhow!("No app_data_dir"))?
        .join("crispy-doom").join("iwads");
    Ok(base.join(iwad))
}

fn call_crispy(env: &mut JNIEnv, args: &[String]) -> Result<i32> {
    let klass = env.find_class("com/spellbound/crispy/Crispy")?;
    let string_class = env.find_class("java/lang/String")?;
    let arr = env.new_object_array(args.len() as i32, string_class, JObject::null())?;
    for (i, s) in args.iter().enumerate() {
        let jstr = env.new_string(JNIString::from(s.as_str()))?;
        env.set_object_array_element(&arr, i as i32, JString::from(jstr))?;
    }
    let ret = env.call_static_method(klass, "run", "([Ljava/lang/String;)I", &[JValue::Object(&arr)])?;
    Ok(ret.i()?)
}

#[tauri::command]
pub async fn launch_crispy_android(
    app: AppHandle,
    iwad_filename: String,
    extra_args: Option<Vec<String>>,
) -> Result<i32, String> {
    let iwad = iwad_fullpath(&app, &iwad_filename).map_err(|e| e.to_string())?;
    if !iwad.exists() {
        return Err(format!("IWAD not found: {}", iwad.display()));
    }
    let mut argv = vec![
        "crispy-doom".to_string(),
        "-iwad".to_string(),
        iwad.to_string_lossy().to_string()
    ];
    if let Some(more) = extra_args { argv.extend(more); }

    let activity = tauri::android::activity::current().ok_or("No current Android activity")?;
    let vm = activity.vm();
    let mut env = vm.get_env().map_err(|e| format!("JNI env error: {e}"))?;
    let code = call_crispy(&mut env, &argv).map_err(|e| e.to_string())?;
    Ok(code)
}