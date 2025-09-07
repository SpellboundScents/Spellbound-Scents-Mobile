mod install_assets;
mod android_bridge;
mod paths;
mod commands;

use tauri::Manager;

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
  tauri::Builder::default()
    .setup(|app| {
      // copy bundled assets (crispy-doom, chocolate-doom, etc.) on first run
      install_assets::install_all_game_assets(app)?;
      Ok(())
    })
    .invoke_handler(tauri::generate_handler![
      commands::get_choco_paths,
      commands::list_choco_iwads,
      commands::import_iwad,           // if you added the importer earlier
      android_bridge::launch_crispy_android
    ])
    .run(tauri::generate_context!())
    .expect("error while running tauri application");
}
