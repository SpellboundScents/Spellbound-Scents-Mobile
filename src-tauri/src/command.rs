use tauri::AppHandle;
use std::fs;

#[tauri::command]
pub fn get_choco_paths(app: AppHandle) -> Result<(String, String), String> {
    let root = crate::paths::choco_root(&app).ok_or("no app_data_dir")?;
    let iwads = root.join("iwads");
    Ok((
        root.to_string_lossy().into_owned(),
        iwads.to_string_lossy().into_owned(),
    ))
}

#[tauri::command]
pub fn list_choco_iwads(app: AppHandle) -> Result<Vec<String>, String> {
    let iwads_dir = crate::paths::choco_iwads(&app).ok_or("no app_data_dir")?;
    let mut out = Vec::new();
    if let Ok(entries) = fs::read_dir(&iwads_dir) {
        for e in entries.flatten() {
            let p = e.path();
            if p.is_file() {
                if let Some(ext) = p.extension() {
                    if ext == "wad" || ext == "WAD" {
                        if let Some(name) = p.file_name().and_then(|n| n.to_str()) {
                            out.push(name.to_string());
                        }
                    }
                }
            }
        }
    }
    Ok(out)
}