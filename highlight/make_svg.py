import subprocess
import argparse

parser = argparse.ArgumentParser(
    prog = "highlight_helper"
)

parser.add_argument("title")

args = parser.parse_args()

with open(f"./examples/{args.title}.sauce", "r") as file:
    source = file.read()

font_size = 8

subprocess.run(["highlight", f"--input=./examples/{args.title}.sauce", f"--output=./examples/{args.title}.svg", "--config-file=./highlight/sauce.lang", "--style=candy", "--include-style", "--out-format=svg", f"--doc-title={args.title}", f"--font-size={font_size}", f"--height={source.count('\n') * font_size * 2 + font_size}", f"--width={int(max(map(len, source.splitlines())) * font_size * 1.5)}", "--no-version-info"])

with open(f"./examples/{args.title}.svg", "r") as file:
    content = file.read()

with open(f"./examples/{args.title}.svg", "w") as file:
    file.write(content.replace('<rect x="0" y="0" width="100%" height="100%"/>', '<rect x="0" y="0" width="100%" height="100%" rx="3%"/>'))
