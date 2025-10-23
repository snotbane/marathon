import argparse
import configparser
import os
import re
import subprocess
import sys
import time
from PIL import Image

SUPPORTED_EXTS = [".png", ".jpg", ".jpeg"]
progress: int = 0

def str2bool(value: str) -> bool:
    if isinstance(value, bool):
        return value
    val = value.lower()
    if val in ('yes', 'true', 't', '1'):
        return True
    elif val in ('no', 'false', 'f', '0'):
        return False
    else:
        raise argparse.ArgumentTypeError('Boolean value expected.')


def bus_get(section: str, key: str):
	bus.read(bus_path)
	if not (bus.has_section(section) and bus.has_option(section, key)): return None

	result = bus.get(section, key)
	try:
		b = str2bool(result)
		return b
	except:	pass
	return result


def bus_set(section: str, key: str, value):
	bus.read(bus_path)
	value = str(value)
	if not bus.has_section(section): bus.add_section(section)
	bus.set(section, key, value)
	with open(bus_path, 'w') as file:
		bus.write(file, space_around_delimiters=False)


class TargetImage:
	def __init__(self, name, dir_path_src, file_path_src, dir_path_tgt):
		## Directory in which the source file belongs.
		self.dir_path_src = dir_path_src
		## Local filename of the source file.
		self.file_path_src = file_path_src
		## Full filepath of the source.
		self.full_path_src = os.path.join(dir_path_src, file_path_src)

		## Name of both source and target without suffix.
		self.name = name
		## Ext of both source and target files.
		_, self.ext = os.path.splitext(file_path_src)

		## Directory in which this file belongs.
		self.dir_path_tgt = dir_path_tgt
		## Local filename.
		self.file_path_tgt = f"{self.name}{args.target_suffix}{self.ext}"
		## Full filepath.
		self.full_path_tgt = os.path.join(dir_path_tgt, self.file_path_tgt)

		## Full filepath of intermediate path 0. Located with the source.
		self.inter_path_s = os.path.join(dir_path_src, f"{self.name}_s{self.ext}")
		## Full filepath of intermediate path 1.
		self.inter_path_n = os.path.join(dir_path_src, f"{self.name}_n{self.ext}")


	def __str__(self):
		return self.file_path_tgt


	def generate(self):
		global progress
		try:
			bus_set("output", "source_preview", f"\"{self.full_path_src}\"")
			os.makedirs(os.path.dirname(self.full_path_tgt), exist_ok=True)

			result_path = os.path.join(self.dir_path_src, f"{self.name}{self.ext}")

			process = subprocess.Popen(executable=args.laigter_path, args=["--no-gui", "--diffuse", self.full_path_src, "--preset", args.laigter_preset, "--normal"], shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, universal_newlines=True)

			while process.poll() is None:
				if bus_get("input", "stop"):
					process.kill()
					sys.exit(2)
				time.sleep(0.25)

			if not os.path.exists(self.inter_path_n): raise Exception(f"Normal file '{self.inter_path_n}' does not exist and/or was not created.")
			image = Image.open(self.inter_path_n)

			source : Image = Image.open(self.full_path_src).convert("RGBA")
			image.putalpha(source.getchannel("A"))
			image.save(self.full_path_tgt)

			bus_set("output", "target_preview", f"\"{self.full_path_tgt}\"")
			progress += 1
			bus_set("output", "progress", progress)
		except Exception as e:
			sys.stderr.write(f"Error processing {self.full_path_tgt}: {e}")
			bus_set("output", "target_preview", f"\"\"")

		if os.path.exists(self.inter_path_s):
			os.remove(self.inter_path_s)
		if os.path.exists(self.inter_path_n) and self.inter_path_n != self.full_path_tgt:
			os.remove(self.inter_path_n)


def assign_image_targets():
	result = []
	include_any = args.filter_include != ""
	exclude_any = args.filter_exclude != ""
	include_regex = re.compile(args.filter_include)
	exclude_regex = re.compile(args.filter_exclude)
	for sub_dir, _, files in os.walk(args.source):
		for file in files:
			name, ext = os.path.splitext(file)
			if not ext.lower() in SUPPORTED_EXTS: continue

			if include_any and re.search(include_regex, name) == None: continue
			if exclude_any and re.search(exclude_regex, name) != None: continue

			target = TargetImage(name, os.path.join(args.source, sub_dir), file, args.target)
			if not args.overwrite and os.path.exists(target.full_path_tgt): continue

			result.append(target)
	return result


def main():
	global progress
	progress_max: int

	if args.target == "": args.target = args.source

	bus_set("output", "progress", 0)
	if os.path.isdir(args.source):
		targets = assign_image_targets()
		progress_max = len(targets)
		bus_set("output", "progress_max", progress_max)
		for target in targets: target.generate()
	elif os.path.isfile(args.source):
		progress_max = 1
		bus_set("output", "progress_max", progress_max)
		root = os.path.dirname(args.source)
		file = os.path.basename(args.source)
		name, _ = os.path.splitext(file)
		target = TargetImage(name, root, file, args.target)
		if not args.overwrite and os.path.exists(target.full_path_tgt): return

		target.generate()

	else:
		sys.stderr.write("Input path is not a valid file nor directory.")
		sys.exit(7) ## ERR_FILE_NOT_FOUND

	if progress < progress_max:
		sys.stderr.write("Not all images were successfully processed.")
		sys.exit(39) ## ERR_SCRIPT_FAILED

if __name__ == "__main__":
	parser = argparse.ArgumentParser()
	parser.add_argument("bus_path", type=str)
	parser.add_argument("laigter_path", type=str)
	parser.add_argument("laigter_preset", type=str)
	parser.add_argument("source", type=str)
	parser.add_argument("target", type=str)
	parser.add_argument("target_suffix", type=str)
	parser.add_argument("filter_include", type=str)
	parser.add_argument("filter_exclude", type=str)
	parser.add_argument("overwrite", type=str2bool)
	args = parser.parse_args()

	args.target_suffix = args.target_suffix[1:-1]
	args.filter_include = args.filter_include[1:-1]
	args.filter_exclude = args.filter_exclude[1:-1]

	bus_path = args.bus_path
	bus = configparser.ConfigParser()
	bus.read(bus_path)

	main()

	sys.exit(0) ## OK
