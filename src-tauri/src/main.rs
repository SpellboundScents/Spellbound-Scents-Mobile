mod install_assets;
mod android_bridge;
mod paths;
mod commands;

fn main() {
  tauri::Builder::default()
    .setup(|app| {
      install_assets::install_all_game_assets(app)?;
      Ok(())
    })
    .invoke_handler(tauri::generate_handler![
      commands::get_choco_paths,
      commands::list_choco_iwads
    ])
    .run(tauri::generate_context!())
    .expect("error while running tauri application");
}
fn main() {
  tauri::Builder::default()
    .setup(|app| {
      // Copy embedded assets (crispy-doom + freedoom wads) to app data on first run.
      install_assets::install_crispy_assets(app)?;
      Ok(())
    })
    .invoke_handler(tauri::generate_handler![
      android_bridge::launch_crispy_android
    ])
    .run(tauri::generate_context!())
    .expect("error while running tauri application");
}
fn main() {
  // Call into the library’s run() so desktop builds work too.
  app::run();
}
