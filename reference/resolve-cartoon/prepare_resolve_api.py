"""Prepare Resolve API edit plans, visual fades, and mixed jazz audio."""

import argparse
from fractions import Fraction
import json
from pathlib import Path
import subprocess
from urllib.parse import unquote, urlsplit
import xml.etree.ElementTree as ET

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
OUTPUTS = ROOT / "outputs"
FADE_DIR = OUTPUTS / "resolve-assets" / "fades"


def frames(value):
    return int(Fraction(value[:-1]) * 30)


def path_for(asset):
    uri = asset.find("media-rep").get("src")
    return Path(unquote(urlsplit(uri).path).lstrip("/"))


def fade_frames(kind):
    if kind == "opening":
        return [round(255 * (1 - i / 23)) for i in range(24)]
    if kind == "transition":
        return [round(255 * (i / 17)) for i in range(18)] + [round(255 * (1 - i / 17)) for i in range(18)]
    return [round(255 * i / 89) for i in range(90)]


def prepare_fades():
    FADE_DIR.mkdir(parents=True, exist_ok=True)
    for kind in ("opening", "transition", "ending"):
        for index, alpha in enumerate(fade_frames(kind)):
            file = FADE_DIR / f"{kind}_{index:04d}.png"
            if not file.exists():
                Image.new("RGBA", (1920, 1080), (0, 0, 0, alpha)).save(file)


def clip_fades(clip):
    adjust = clip.find("adjust-volume")
    if adjust is None:
        return 0, 0, "0dB"
    param = adjust.find("param")
    fade_in = param.find("fadeIn") if param is not None else None
    fade_out = param.find("fadeOut") if param is not None else None
    return (
        frames(fade_in.get("duration")) if fade_in is not None else 0,
        frames(fade_out.get("duration")) if fade_out is not None else 0,
        adjust.get("amount", "0dB"),
    )


def make_mix(slug, audio, assets):
    mix = OUTPUTS / slug / "resolve" / "jazz-mix.m4a"
    if mix.exists() and mix.stat().st_size > 1000000:
        print(f"Already mixed: {slug}", flush=True)
        return mix
    duration = max(frames(clip.get("offset")) + frames(clip.get("duration")) for clip in audio)
    args = ["ffmpeg", "-hide_banner", "-loglevel", "error", "-y"]
    filters = []
    labels = []
    for index, clip in enumerate(audio):
        source = path_for(assets[clip.get("ref")])
        args += ["-i", str(source)]
        length = frames(clip.get("duration"))
        offset = frames(clip.get("offset"))
        fade_in, fade_out, gain = clip_fades(clip)
        stages = [
            f"[{index}:a]aresample=48000",
            f"atrim=end_sample={length * 1600}",
            "asetpts=PTS-STARTPTS",
            f"volume={gain}",
        ]
        if fade_in:
            stages.append(f"afade=t=in:st=0:d={fade_in/30:.8f}")
        if fade_out:
            stages.append(f"afade=t=out:st={(length-fade_out)/30:.8f}:d={fade_out/30:.8f}")
        stages.append(f"adelay={offset * 1600}S:all=1[a{index}]")
        filters.append(",".join(stages))
        labels.append(f"[a{index}]")
    filters.append("".join(labels) + f"amix=inputs={len(labels)}:duration=longest:dropout_transition=0,atrim=end_sample={duration * 1600}[out]")
    filter_file = mix.with_suffix(".filter.txt")
    filter_file.write_text(";\n".join(filters), encoding="utf-8")
    print(f"Mixing {slug}: {duration/1800:.1f} minutes, {len(audio)} songs", flush=True)
    subprocess.run(args + ["-filter_complex", ";\n".join(filters), "-map", "[out]", "-ac", "2", "-ar", "48000", "-c:a", "aac", "-b:a", "192k", str(mix)], check=True)
    return mix


def prepare(slug, mix_audio):
    folder = OUTPUTS / slug / "resolve"
    xml = ET.parse(folder / f"{slug}.fcpxml").getroot()
    assets = {asset.get("id"): asset for asset in xml.find("resources").findall("asset")}
    clips = xml.findall(".//gap/asset-clip")
    source_manifest = json.loads((folder / "timeline-manifest.json").read_text(encoding="utf-8"))
    manifest = {"duration": source_manifest["durationInFrames"], "clips": clips}
    video = [c for c in clips if int(c.get("lane", "0")) > 0 and int(c.get("lane", "0")) != 4]
    audio = [c for c in clips if int(c.get("lane", "0")) < 0]
    rows = []
    for clip in video:
        source = path_for(assets[clip.get("ref")])
        rows.append(("video", str(source), frames(clip.get("offset")), frames(clip.get("start", "0s")), frames(clip.get("duration")), int(clip.get("lane")), clip.get("name", "")))
    music_duration = max(frames(clip.get("offset")) + frames(clip.get("duration")) for clip in audio)
    minimum_music_frames = int(source_manifest.get("minimumMusicDurationInFrames") or 0)
    if minimum_music_frames and music_duration < minimum_music_frames:
        raise ValueError(f"{slug}: complete music mix is below its configured minimum; add full tracks without shortening them")
    mix = folder / "jazz-mix.m4a"
    if mix_audio:
        mix = make_mix(slug, audio, assets)
    rows.append(("audio", str(mix), 0, 0, music_duration, 1, "Original Mureka jazz mix"))
    visual = sorted((c for c in video if c.get("lane") == "1"), key=lambda c: frames(c.get("offset")))
    for i in range(1, len(visual)):
        boundary = frames(visual[i].get("offset"))
        rows.append(("fade", str(FADE_DIR / "transition_%04d.png"), max(0, boundary - 18), 0, 36, 4, "Fade through black"))
    rows.append(("fade", str(FADE_DIR / "opening_%04d.png"), 0, 0, 24, 4, "Fade from black"))
    rows.append(("fade", str(FADE_DIR / "ending_%04d.png"), manifest["duration"] - 90, 0, 90, 4, "Fade to black"))
    plan = folder / "resolve-api-plan.tsv"
    plan.write_text("\n".join("\t".join(map(str, row)) for row in rows) + "\n", encoding="utf-8")
    print(f"Prepared {slug}: {len(rows)} timeline items", flush=True)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--mix", action="store_true")
    args = parser.parse_args()
    prepare_fades()
    for file in sorted(OUTPUTS.glob("*/resolve/timeline-manifest.json")):
        prepare(file.parent.parent.name, args.mix)
