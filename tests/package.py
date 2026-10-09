from pathlib import Path
from zipfile import ZipFile

archives = list(Path(".release").glob("*.zip"))
assert len(archives) == 1, "Expected one universal addon ZIP"
interfaces = {"Mainline": "120100", "TBC": "20506", "Mists": "50504", "Camelot": "16001", "Vanilla": "11509"}
with ZipFile(archives[0]) as archive:
    assert archive.testzip() is None, "Corrupt ZIP"
    names = archive.namelist()
    assert all(name.startswith("CleanerLootMessages/") for name in names), "Incorrect install folder"
    assert "CleanerLootMessages/CleanerLootMessages.lua" in names
    assert not any(part in {"tests", ".github", ".git", ".gitignore", ".pkgmeta"} for name in names for part in Path(name).parts)
    fallback = archive.read("CleanerLootMessages/CleanerLootMessages.toc").decode("utf-8-sig")
    fallback_interfaces = next(line.split(":", 1)[1] for line in fallback.splitlines() if line.startswith("## Interface:"))
    assert set(fallback_interfaces.replace(" ", "").split(",")) == set(interfaces.values())
    for flavor, interface in interfaces.items():
        toc = archive.read(f"CleanerLootMessages/CleanerLootMessages_{flavor}.toc").decode("utf-8-sig")
        assert f"## Interface: {interface}" in toc.splitlines(), flavor
        assert "@project-version@" not in toc, "Unexpanded release version"
        assert toc.splitlines()[-1] == "CleanerLootMessages.lua", flavor
print("PASS: ZIP folder, all five client manifests, versions and excluded development files")
