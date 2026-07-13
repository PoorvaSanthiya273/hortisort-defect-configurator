import json
import os
from pathlib import Path
from fastapi import FastAPI, HTTPException
from fastapi.staticfiles import StaticFiles
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

app = FastAPI(title="Hortisort Configurator Backend")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

BASE_DIR = Path(__file__).parent
PROGRAMS_DIR = BASE_DIR / "programs"
CONFIG_FILE = BASE_DIR / "config" / "gradingconfig.json"
IMAGES_DIR = BASE_DIR / "images" / "defects"

PROGRAMS_DIR.mkdir(parents=True, exist_ok=True)


# ─── API Routes ────────────────────────────────────────

@app.get("/api/config")
async def get_config():
    if not CONFIG_FILE.exists():
        raise HTTPException(404, "Config file not found")
    return json.loads(CONFIG_FILE.read_text(encoding="utf-8"))


@app.get("/api/programs")
async def list_programs():
    files = sorted(PROGRAMS_DIR.glob("*.json"))
    result = []
    for f in files:
        try:
            data = json.loads(f.read_text(encoding="utf-8"))
            result.append({
                "name": f.stem,
                "produceName": data.get("ProduceName", ""),
                "gradingBasedOn": data.get("GradingBasedOn", "Defect Feature"),
            })
        except Exception:
            result.append({"name": f.stem, "produceName": "", "gradingBasedOn": "Defect Feature"})
    return result


class SaveProgramRequest(BaseModel):
    filename: str
    content: dict


@app.post("/api/programs")
async def save_program(req: SaveProgramRequest):
    filepath = PROGRAMS_DIR / f"{req.filename}.json"
    filepath.write_text(json.dumps(req.content, indent=2), encoding="utf-8")
    return {"status": "ok", "path": str(filepath)}


@app.get("/api/programs/{name}")
async def load_program(name: str):
    filepath = PROGRAMS_DIR / f"{name}.json"
    if not filepath.exists():
        raise HTTPException(404, f"Program '{name}' not found")
    return json.loads(filepath.read_text(encoding="utf-8"))


@app.delete("/api/programs/{name}")
async def delete_program(name: str):
    filepath = PROGRAMS_DIR / f"{name}.json"
    if filepath.exists():
        filepath.unlink()
    return {"status": "deleted", "name": name}


# ─── Static mounts (API routes must come first) ────────

if IMAGES_DIR.exists():
    app.mount(
        "/api/images/defects",
        StaticFiles(directory=str(IMAGES_DIR)),
        name="defect-images",
    )

# Serve the Flutter web build — must be mounted last
WEB_DIR = BASE_DIR.parent / "build" / "web"
if WEB_DIR.exists() and WEB_DIR.is_dir():
    app.mount("/", StaticFiles(directory=str(WEB_DIR), html=True), name="web")


if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8082, reload=True)
