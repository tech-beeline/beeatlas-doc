#!/usr/bin/env python3
"""
Сбор документации BeeAtlas в zip и отправка в fdm-search.

"""

from __future__ import annotations

import argparse
import io
import logging
import os
import zipfile
from pathlib import Path

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(levelname)s | %(message)s",
)
logger = logging.getLogger("init-search")

REPO_ROOT = Path(__file__).resolve().parents[1]
DOCS_SUBDIR = "docs"
USER_DOCS_DIR = "beeatlas-docs"
SKIP_FILE_NAMES = frozenset({"readme.md"})

INTEGRATION_SEARCH_SERVER_URL = "http://127.0.0.1:8002"

DSL_PATHS = (
    "templates/workspace.dsl",
    "spdd_templates/workspace.dsl",
)
REINDEX_PATH = "/api/v1/docs/reindex"
UPLOAD_TIMEOUT_SEC = 600.0


def docs_root_from_args(docs_dir: str | None) -> Path:
    root = Path(docs_dir).resolve() if docs_dir else (REPO_ROOT / DOCS_SUBDIR).resolve()
    if not root.is_dir():
        raise SystemExit(f"Папка docs не найдена: {root}")
    return root


def relative_posix(path: Path, root: Path) -> str:
    return path.resolve().relative_to(root.resolve()).as_posix()


def is_indexable_md(path: Path, docs_root: Path) -> bool:
    try:
        rel = path.resolve().relative_to(docs_root.resolve())
    except ValueError:
        return False
    if path.name.lower() in SKIP_FILE_NAMES:
        return False
    if path.suffix.lower() != ".md":
        return False
    parts = rel.parts
    if len(parts) == 1:
        return True
    return parts[0] == USER_DOCS_DIR


def collect_files(docs_root: Path) -> list[Path]:
    files = sorted(p for p in docs_root.rglob("*.md") if is_indexable_md(p, docs_root))

    for rel in DSL_PATHS:
        dsl = docs_root / rel
        if dsl.is_file():
            files.append(dsl)
            logger.info("DSL-пример: %s", rel)
        else:
            logger.warning("DSL-пример не найден, пропуск: %s", dsl)

    return files


def build_zip(files: list[Path], docs_root: Path) -> bytes:
    buffer = io.BytesIO()
    with zipfile.ZipFile(buffer, "w", compression=zipfile.ZIP_DEFLATED) as archive:
        for path in files:
            arcname = relative_posix(path, docs_root)
            archive.write(path, arcname=arcname)
            logger.info("  + %s", arcname)
    return buffer.getvalue()


def upload_zip(zip_bytes: bytes, *, base_url: str) -> None:
    import httpx

    url = f"{base_url.rstrip('/')}{REINDEX_PATH}"

    logger.info("POST %s (%s байт)", url, len(zip_bytes))
    with httpx.Client(timeout=UPLOAD_TIMEOUT_SEC) as client:
        response = client.post(
            url,
            files={"file": ("docs.zip", zip_bytes, "application/zip")},
        )
    if response.status_code >= 400:
        raise SystemExit(
            f"fdm-search ответил {response.status_code}: {response.text[:500]}"
        )
    logger.info("Ответ %s: %s", response.status_code, response.text[:500])


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Упаковать docs и отправить в fdm-search",
    )
    parser.add_argument(
        "--docs-dir",
        default=None,
        help="Папка docs/ (по умолчанию ../docs от этого скрипта)",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Только собрать zip, без отправки",
    )
    parser.add_argument(
        "--zip-out",
        default=None,
        help="Куда сохранить zip (опционально)",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    docs_root = docs_root_from_args(args.docs_dir)
    logger.info("docs_root=%s", docs_root)

    files = collect_files(docs_root)
    if not files:
        raise SystemExit(f"Нет файлов для архива в {docs_root}")
    logger.info("Файлов в zip: %s", len(files))

    zip_bytes = build_zip(files, docs_root)
    logger.info("Размер zip: %s байт", len(zip_bytes))

    if args.zip_out:
        out = Path(args.zip_out)
        out.write_bytes(zip_bytes)
        logger.info("Zip записан: %s", out.resolve())

    if args.dry_run:
        logger.info("dry-run: в fdm-search не отправляем")
        return

    base_url = os.environ.get("INTEGRATION_SEARCH_SERVER_URL", INTEGRATION_SEARCH_SERVER_URL).strip()
    if not base_url:
        raise SystemExit("Заполните INTEGRATION_SEARCH_SERVER_URL")
    upload_zip(zip_bytes, base_url=base_url)


if __name__ == "__main__":
    try:
        main()
    except SystemExit:
        raise
    except Exception:
        logger.exception("Фатальная ошибка")
        raise SystemExit(1) from None
