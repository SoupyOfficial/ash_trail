#!/usr/bin/env python3
"""Generator script for AshTrail.

Parses feature_matrix.yaml and generates:
  - Freezed model classes for each entity
  - entity index mapping
  - telemetry events list
  - feature flags map
  - acceptance test scaffolds

Validations:
  - Unique feature ids
  - Feature enum membership (status, priority)
  - Entity name uniqueness
  - Index name uniqueness per entity
  - Feature order uniqueness within an epic

Generation rules:
  - Only overwrites files starting with banner: // GENERATED - DO NOT EDIT.
  - Deterministic output (sorted where order not defined in source)
  - Type normalization per spec

Exit non‑zero on validation failure.
"""

from __future__ import annotations

import sys
import yaml
import re
from pathlib import Path
from typing import Any, Dict, List, Set

BANNER = "// GENERATED - DO NOT EDIT."
ROOT = Path(__file__).resolve().parent.parent
FEATURE_MATRIX = ROOT / "feature_matrix.yaml"

MODELS_DIR = ROOT / "lib" / "domain" / "models"
INDEXES_FILE = ROOT / "lib" / "domain" / "indexes" / "entity_indexes.dart"
TELEMETRY_EVENTS_FILE = ROOT / "lib" / "telemetry" / "events.dart"
FEATURE_FLAGS_FILE = ROOT / "tool" / "feature_flags.g.dart"
ACCEPTANCE_DIR = ROOT / "test" / "acceptance"

TYPE_MAP = {
    "string": "String",
    "int": "int",
    "bool": "bool",
    "datetime": "DateTime",
    "date": "DateTime",
    "time": "DateTime",
    "json": "Map<String, dynamic>",
}

ENUM_PATTERN = re.compile(r"enum\[([^\]]+)\](\[])?\??$")
FK_PATTERN = re.compile(r"fk\(([^\.]+)\.[^)]+\)\??$")


def load_yaml() -> Dict[str, Any]:
    with FEATURE_MATRIX.open("r", encoding="utf-8") as f:
        return yaml.safe_load(f)


def fail(msg: str):
    print(f"ERROR: {msg}", file=sys.stderr)
    sys.exit(1)


def validate(data: Dict[str, Any]):
    enums = data.get("enums", {})
    enum_status = set(enums.get("status", []))
    enum_priority = set(enums.get("priority", []))

    # Feature id uniqueness & enum membership & order uniqueness per epic
    feature_ids: Set[str] = set()
    epic_order: Dict[str, Set[int]] = {}
    for feat in data.get("features", []):
        fid = feat.get("id")
        if not fid:
            fail("Feature missing id")
        if fid in feature_ids:
            fail(f"Duplicate feature id: {fid}")
        feature_ids.add(fid)
        status = feat.get("status")
        if status not in enum_status:
            fail(f"Feature {fid} has invalid status '{status}'")
        priority = feat.get("priority")
        if priority not in enum_priority:
            fail(f"Feature {fid} has invalid priority '{priority}'")
        epic = feat.get("epic")
        order = feat.get("order")
        if epic is not None and order is not None:
            orders = epic_order.setdefault(epic, set())
            if order in orders:
                fail(f"Duplicate order {order} in epic {epic} (feature {fid})")
            orders.add(order)

    # Entities uniqueness & index name uniqueness
    entity_names: Set[str] = set()
    for ent in data.get("entities", []):
        name = ent.get("name")
        if not name:
            fail("Entity missing name")
        if name in entity_names:
            fail(f"Duplicate entity name: {name}")
        entity_names.add(name)
        seen_index_names: Set[str] = set()
        for idx in ent.get("indexes", []) or []:
            iname = idx.get("name")
            if not iname:
                fail(f"Entity {name} has index without name")
            if iname in seen_index_names:
                fail(f"Entity {name} duplicate index name: {iname}")
            seen_index_names.add(iname)


def snake_case(name: str) -> str:
    s1 = re.sub('(.)([A-Z][a-z0-9]+)', r'\1_\2', name)
    s2 = re.sub('([a-z0-9])([A-Z])', r'\1_\2', s1)
    return s2.replace("__", "_").lower()


def normalize_type(raw: str) -> str:
    opt = raw.endswith("?")
    base = raw[:-1] if opt else raw
    # arrays
    if base.endswith("[]"):
        inner = base[:-2]
        # Enum array
        m_enum = ENUM_PATTERN.match(base)
        if m_enum:
            dart = "List<String>"
        elif inner == "string":
            dart = "List<String>"
        elif inner in TYPE_MAP:
            # Map arrays of known primitive / temporal types (int, bool, datetime, date, time) to concrete typed lists
            # Assumption: 'time' stored as DateTime (time-of-day in UTC or with a sentinel date) – documented in feature_matrix notes.
            dart = f"List<{TYPE_MAP[inner]}>"
        else:
            # Fallback generic list of dynamic
            dart = "List<dynamic>"
        return f"{dart}{'?' if opt else ''}"
    # enum single
    if ENUM_PATTERN.match(base):
        return f"String{'?' if opt else ''}"
    # foreign key -> assume String
    if base.startswith("fk("):
        return f"String{'?' if opt else ''}"
    # direct map
    if base in TYPE_MAP:
        return f"{TYPE_MAP[base]}{'?' if opt else ''}"
    return f"{base}{'?' if opt else ''}"  # fallback (already dart?)


def model_field_comment(raw: str) -> str:
    notes = []
    if ENUM_PATTERN.match(raw.rstrip('?')):
        notes.append("TODO: constrain to enum values")
    m_fk = FK_PATTERN.match(raw)
    if m_fk:
        target = m_fk.group(1)
        notes.append(f"TODO: FK to {target}")
    if not notes:
        return ""
    return " // " + "; ".join(notes)


def generate_models(data: Dict[str, Any]) -> List[Path]:
    generated: List[Path] = []
    MODELS_DIR.mkdir(parents=True, exist_ok=True)
    for ent in data.get("entities", []):
        name = ent["name"]
        fields = ent.get("fields", [])
        file_name = f"{snake_case(name)}.dart"
        path = MODELS_DIR / file_name
        # Place @JsonSerializable at class level per updated requirement.
        lines = [
            BANNER,
            "// coverage:ignore-file",
            "",
            "import 'package:freezed_annotation/freezed_annotation.dart';",
            "",
            "part '" + snake_case(name) + ".freezed.dart';",
            "part '" + snake_case(name) + ".g.dart';",
            "",
            "@freezed",
            f"class {name} with _${name} {{",
            f"  const factory {name}({{",
        ]
        for f in fields:
            fname = f["name"]
            raw_type = f["type"]
            dart_type = normalize_type(raw_type)
            is_nullable = dart_type.endswith('?')
            req = "    " + ("" if is_nullable else "required ") + f"{dart_type} {fname}," + model_field_comment(raw_type)
            lines.append(req)
        lines.append("  }) = _" + name + ";")
        lines.append("")
        lines.append(f"  factory {name}.fromJson(Map<String, dynamic> json) => _${name}FromJson(json);")
        lines.append("}")
        content = "\n".join(lines) + "\n"
        write_generated(path, content)
        generated.append(path)
    return generated


def write_generated(path: Path, content: str):
    if path.exists():
        with path.open("r", encoding="utf-8") as f:
            first = f.readline().rstrip('\n')
        if first != BANNER:
            # Skip touching non-generated file
            print(f"SKIP (not generated): {path.relative_to(ROOT)}")
            return
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding="utf-8")
    print(f"WROTE {path.relative_to(ROOT)}")


def generate_indexes(data: Dict[str, Any]) -> Path:
    INDEXES_FILE.parent.mkdir(parents=True, exist_ok=True)
    lines = [BANNER, "", "/// Per-entity index field groupings.", "const Map<String, List<List<String>>> entityIndexes = {"]
    for ent in data.get("entities", []):
        idxs = ent.get("indexes", []) or []
        if idxs:
            lines.append(f"  '{ent['name']}': [")
            for idx in idxs:
                fields = idx.get("fields", []) or []
                arr = ", ".join([f"'" + f + "'" for f in fields])
                lines.append(f"    [{arr}],")
            lines.append("  ],")
    lines.append("};")
    content = "\n".join(lines) + "\n"
    write_generated(INDEXES_FILE, content)
    return INDEXES_FILE


def extract_telemetry_events(data: Dict[str, Any]) -> List[str]:
    events: Set[str] = set()
    for feat in data.get("features", []):
        # nested telemetry.events
        tel = feat.get("telemetry") or {}
        for e in tel.get("events", []) or []:
            events.add(str(e))
        # root events (quality.telemetry pattern)
        for e in feat.get("events", []) or []:
            events.add(str(e))
    return sorted(events)


def generate_events(events: List[str]) -> Path:
    TELEMETRY_EVENTS_FILE.parent.mkdir(parents=True, exist_ok=True)
    arr = ",\n  ".join([f"'" + e + "'" for e in events])
    content = "\n".join([
        BANNER,
        "",
        "/// Telemetry events collected from feature matrix.",
        "const List<String> kTelemetryEvents = [",
        f"  {arr}",
        "];\n",
    ])
    write_generated(TELEMETRY_EVENTS_FILE, content)
    return TELEMETRY_EVENTS_FILE


def generate_feature_flags(data: Dict[str, Any]) -> Path:
    FEATURE_FLAGS_FILE.parent.mkdir(parents=True, exist_ok=True)
    lines = [BANNER, "", "/// Feature flags derived from feature statuses (status == 'done').", "const Map<String, bool> kFeatureFlags = {"]
    for feat in sorted(data.get("features", []), key=lambda f: f.get("id")):
        fid = feat["id"]
        status = feat.get("status")
        enabled = "true" if status == "done" else "false"
        lines.append(f"  '{fid}': {enabled},")
    lines.append("};\n")
    content = "\n".join(lines)
    write_generated(FEATURE_FLAGS_FILE, content)
    return FEATURE_FLAGS_FILE


def truncate(s: str, limit: int = 80) -> str:
    return s if len(s) <= limit else s[:limit]


def sanitize_test_name(s: str) -> str:
        """Sanitize a test name for safe inclusion inside double quotes in Dart.

        We intentionally switched to double quotes for generated test descriptions so
        that single apostrophes in natural language (user's) don't terminate the
        string literal and break parsing under build_runner on CI. The previous
        implementation attempted to escape single quotes but produced no-op escapes
        ("\'" -> "'") causing invalid Dart in cases like: user's.

        Escaping rules applied:
            - Backslash -> \\
            - Double quote -> \"
            - Carriage returns / newlines collapsed to spaces
        Single quotes are left as-is now that we use double-quoted literals.
        """
        return (
                s.replace("\\", "\\\\")
                 .replace('"', '\\"')
                 .replace("\r", " ")
                 .replace("\n", " ")
        )


def generate_acceptance_tests(data: Dict[str, Any]) -> List[Path]:
    ACCEPTANCE_DIR.mkdir(parents=True, exist_ok=True)
    paths: List[Path] = []
    for feat in data.get("features", []):
        acceptance = feat.get("acceptance") or []
        if not acceptance:
            continue
        fid = feat["id"]
        file_path = ACCEPTANCE_DIR / f"{fid}_test.dart"
        lines = [BANNER, "", "import 'package:test/test.dart';", "", f"void main() {{", f"  group('Feature {fid}', () {{"]
        for idx, line in enumerate(acceptance, start=1):
            name = truncate(line.strip())
            name = sanitize_test_name(name)
            # Use double quotes around test description to avoid escaping apostrophes.
            lines.append(f'    test("{idx}. {name}", () async {{')
            lines.append("      // TODO: implement acceptance validation")
            lines.append("    });")
        lines.append("  });")
        lines.append("}")
        content = "\n".join(lines) + "\n"
        write_generated(file_path, content)
        paths.append(file_path)
    return paths


def main():
    if not FEATURE_MATRIX.exists():
        fail("feature_matrix.yaml not found")
    data = load_yaml()
    validate(data)
    models = generate_models(data)
    indexes = generate_indexes(data)
    events = extract_telemetry_events(data)
    events_file = generate_events(events)
    flags_file = generate_feature_flags(data)
    tests = generate_acceptance_tests(data)
    print("==== SUMMARY ====")
    print(f"Models: {len(models)} files")
    print(f"Indexes: {indexes.relative_to(ROOT)}")
    print(f"Telemetry events: {len(events)} -> {events_file.relative_to(ROOT)}")
    print(f"Feature flags: {flags_file.relative_to(ROOT)}")
    print(f"Acceptance test files: {len(tests)}")


if __name__ == "__main__":
    main()
