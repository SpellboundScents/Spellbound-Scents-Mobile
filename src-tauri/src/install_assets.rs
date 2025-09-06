use include_dir::{include_dir, Dir};
use std::{fs, io, path::Path};
use tauri::AppHandle;

static EMBEDDED_CRISPY: Dir = include_dir!("$CARGO_MANIFEST_DIR/assets/crispy-doom");

fn ensure_parent(path: &Path) -> io::Result<()> {
    if let Some(p) = path.parent() {
        fs::create_dir_all(p)?;
    }
    Ok(())
}

pub fn install_crispy_assets(app: &AppHandle) -> anyhow::Result<()> {
    let dest = app
        .path()
        .app_data_dir()
        .ok_or_else(|| anyhow::anyhow!("No app_data_dir"))?
        .join("crispy-doom");

    if dest.exists() {
        return Ok(()); // already installed
    }

    for d in EMBEDDED_CRISPY.dirs() {
        fs::create_dir_all(dest.join(d.path()))?;
    }
    for f in EMBEDDED_CRISPY.files() {
        let out = dest.join(f.path());
        ensure_parent(&out)?;
        fs::write(out, f.contents())?;
    }
    Ok(())
}