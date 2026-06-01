"""Minimal multi-tier sample API for CKAD practice.

This FastAPI service is deliberately generic (no ML/GPU). It exposes a visit
counter backed by PostgreSQL so that Kubernetes primitives can be exercised
end-to-end: ConfigMap/Secret (DB connection), PersistentVolumeClaim (DB state),
readiness vs liveness probes (DB reachability), Services, Ingress and HPA.
"""

from __future__ import annotations

import os
from contextlib import asynccontextmanager
from typing import Any

import psycopg2
from fastapi import FastAPI, Response
from fastapi.responses import JSONResponse


def _db_config() -> dict[str, Any]:
    """Build the PostgreSQL connection parameters from the environment.

    Connection settings come from a ConfigMap (host/name/port/user) and a Secret
    (password) when running on Kubernetes, or from defaults for local use.

    Returns:
        dict[str, Any]: Keyword arguments for ``psycopg2.connect``.
    """
    return {
        "host": os.getenv("DB_HOST", "localhost"),
        "port": int(os.getenv("DB_PORT", "5432")),
        "dbname": os.getenv("DB_NAME", "app"),
        "user": os.getenv("DB_USER", "app"),
        "password": os.getenv("DB_PASSWORD", ""),
        "connect_timeout": 2,
    }


def _connect() -> "psycopg2.extensions.connection":
    """Open a short-lived PostgreSQL connection.

    Returns:
        psycopg2.extensions.connection: An open database connection.

    Raises:
        psycopg2.OperationalError: If the database cannot be reached.
    """
    return psycopg2.connect(**_db_config())


def _ensure_schema() -> None:
    """Create the counter table if it does not yet exist.

    Best-effort: failures are swallowed so the API can still start and report
    "not ready" via the readiness probe until the database becomes available.
    """
    try:
        with _connect() as conn, conn.cursor() as cur:
            cur.execute(
                "CREATE TABLE IF NOT EXISTS visits ("
                "id INT PRIMARY KEY, count BIGINT NOT NULL)"
            )
            cur.execute(
                "INSERT INTO visits (id, count) VALUES (1, 0) "
                "ON CONFLICT (id) DO NOTHING"
            )
            conn.commit()
    except Exception:  # noqa: BLE001 - startup is best-effort; readiness reports truth
        pass


@asynccontextmanager
async def lifespan(_: FastAPI):
    """Initialise the database schema on startup (FastAPI lifespan)."""
    _ensure_schema()
    yield


app = FastAPI(title="ckad-sample-api", lifespan=lifespan)


@app.get("/")
def root() -> JSONResponse:
    """Increment and return the visit counter.

    Returns:
        JSONResponse: ``{"app": ..., "visits": <int>}`` on success, or HTTP 503
        with an error message when the database is unavailable.
    """
    try:
        with _connect() as conn, conn.cursor() as cur:
            cur.execute(
                "UPDATE visits SET count = count + 1 WHERE id = 1 RETURNING count"
            )
            row = cur.fetchone()
            conn.commit()
        return JSONResponse({"app": "ckad-sample-api", "visits": int(row[0])})
    except Exception as exc:  # noqa: BLE001 - surface DB outage as 503
        return JSONResponse({"error": "database unavailable", "detail": str(exc)}, status_code=503)


@app.get("/healthz")
def healthz() -> dict[str, str]:
    """Liveness probe: the process is up and serving.

    Returns:
        dict[str, str]: A static OK payload (does not touch the database).
    """
    return {"status": "ok"}


@app.get("/readyz")
def readyz() -> Response:
    """Readiness probe: ready only when the database is reachable.

    Returns:
        Response: HTTP 200 when the database responds, HTTP 503 otherwise.
    """
    try:
        with _connect() as conn, conn.cursor() as cur:
            cur.execute("SELECT 1")
            cur.fetchone()
        return JSONResponse({"status": "ready"})
    except Exception:  # noqa: BLE001 - not ready until DB is up
        return JSONResponse({"status": "not-ready"}, status_code=503)
