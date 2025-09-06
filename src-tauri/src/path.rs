use tauri::{AppHandle, Manager};
use std::path::PathBuf;

pub fn choco_root(app: &AppHandle) -> Option<PathBuf> {
    app.path().app_data_dir().map(|p| p.join("chocolate-doom"))
}
pub fn choco_iwads(app: &AppHandle) -> Option<PathBuf> {
    choco_root(app).map(|p| p.join("iwads"))
}