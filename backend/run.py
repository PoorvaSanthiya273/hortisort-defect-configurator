#!/usr/bin/env python3
"""Start the Hortisort Configurator backend server."""

import uvicorn
from pathlib import Path

BASE = Path(__file__).parent

if __name__ == "__main__":
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8082,
        reload=True,
        app_dir=str(BASE),
    )
