use tauri::{AppHandle, Manager};
use std::{fs, path::{Path, PathBuf}};

#[derive(serde::Serialize)]
pub struct LaunchResult {
  pub status: i32,
  pub stdout: String,
  pub stderr: String,
  pub commandline: Vec<String>,
  pub binary_path: String,
  pub iwad_path: String,
}

fn app_crispy_root(app: &AppHandle) -> anyhow::Result<PathBuf> {
  let root = app.path()
    .app_data_dir()
    .ok_or_else(|| anyhow::anyhow!("Could not resolve app_data_dir"))?
    .join("crispy-doom");
  Ok(root)
}

fn iwad_path(app: &AppHandle, iwad_file: &str) -> anyhow::Result<PathBuf> {
  Ok(app_crispy_root(app)?.join("iwads").join(iwad_file))
}

fn binary_path(app: &AppHandle) -> anyhow::Result<PathBuf> {
  #[cfg(windows)]
  let bin_name = "crispy-doom.exe";
  #[cfg(not(windows))]
  let bin_name = "crispy-doom";

  Ok(app_crispy_root(app)?.join("bin").join(bin_name))
}

#[cfg(unix)]
fn ensure_executable(path: &Path) -> std::io::Result<()> {
  use std::os::unix::fs::PermissionsExt;
  let mut perms = fs::metadata(path)?.permissions();
  let mode = perms.mode() | 0o755;
  perms.set_mode(mode);
  fs::set_permissions(path, perms)
}

#[cfg(not(unix))]
fn ensure_executable(_path: &Path) -> std::io::Result<()> { Ok(()) }

/// Build argv for Crispy Doom: binary + [-iwad <path>] + extra args
fn build_args(iwad: &Path, extra_args: &[String]) -> Vec<String> {
  let mut args = Vec::new();
  args.push("-iwad".to_string());
  args.push(iwad.to_string_lossy().to_string());
  args.extend(extra_args.iter().cloned());
  args
}

#[tauri::command]
pub fn get_crispy_paths(app: AppHandle) -> Result<(String, String), String> {
  let root = app_crispy_root(&app).map_err(|e| e.to_string())?;
  let iwads = root.join("iwads");
  Ok((root.to_string_lossy().into_owned(), iwads.to_string_lossy().into_owned()))
}

/// Launch Crispy Doom (DESKTOP TARGETS ONLY).
/// On Android/iOS this returns a helpful error (see notes below).
#[tauri::command]
pub async fn launch_crispy(
  app: AppHandle,
  // e.g. "freedoom2.wad" or "DOOM2.WAD"
  iwad_filename: String,
  // extra cmdline args, e.g. ["-file", "some_mod.wad", "-warp", "01"]
  extra_args: Option<Vec<String>>,
) -> Result<LaunchResult, String> {

  let iwad = iwad_path(&app, &iwad_filename).map_err(|e| e.to_string())?;
  if !iwad.exists() {
    return Err(format!("IWAD not found: {}", iwad.display()));
  }

  let bin = binary_path(&app).map_err(|e| e.to_string())?;
  if !bin.exists() {
    // We copy your binary there during your app's setup step.
    return Err(format!(
      "Crispy binary not found at {}.\n\
       Expected you to place it via your 'copy on first run' step.\n\
       Place your build at: crispy-doom/bin/{}",
      bin.display(),
      bin.file_name().unwrap().to_string_lossy()
    ));
  }

  // Mobile note
  #[cfg(any(target_os = "android", target_os = "ios"))]
  {
    return Err("Directly spawning native processes is restricted on mobile. \
    On Android/iOS, build Crispy as a native library and call it via JNI/FFI. \
    (See notes: 'Mobile execution path'.)".to_string());
  }

  // Desktop path
  #[cfg(not(any(target_os = "android", target_os = "ios")))]
  {
    ensure_executable(&bin).map_err(|e| format!("Failed to set exec perms: {e}"))?;

    let argv = build_args(&iwad, &extra_args.unwrap_or_default());
    let mut cmdline = vec![bin.to_string_lossy().to_string()];
    cmdline.extend(argv.clone());

    // Prefer tauri::process::Command for portability/capture
    use tauri::process::Command;
    let (rx, _child) = Command::new(bin.to_string_lossy().to_string())
      .args(argv.clone())
      .spawn()
      .map_err(|e| format!("Failed to spawn Crispy: {e}"))?;

    // Collect output (this waits until the process exits)
    let output = rx
      .await
      .map_err(|e| format!("Failed waiting for Crispy: {e}"))?;

    let code = output.code.unwrap_or(-1);
    let stdout = String::from_utf8_lossy(&output.stdout).to_string();
    let stderr = String::from_utf8_lossy(&output.stderr).to_string();

    Ok(LaunchResult {
      status: code,
      stdout,
      stderr,
      commandline: cmdline,
      binary_path: bin.to_string_lossy().to_string(),
      iwad_path: iwad.to_string_lossy().to_string(),
    })
  }
}