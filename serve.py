#!/usr/bin/env python3
"""Run the Hortisort Configurator backend (FastAPI)."""

import uvicorn

if __name__ == "__main__":
    uvicorn.run("backend.main:app", host="0.0.0.0", port=8082, reload=True)
