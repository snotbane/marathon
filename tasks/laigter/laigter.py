import argparse
import configparser
import os
import re
import subprocess
import sys
import time
from PIL import Image

progress_display = 0


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
	def __init__(self, root, file, src_root, src_file):
		self.root = root
		self.file = file
		self.full = os.path.join(root, file)
		self.name, self.ext = os.path.splitext(file)

		self.src_root = src_root
		self.src_file = src_file
		self.src_full = os.path.join(src_root, src_file)

		self.src_name, self.src_ext = os.path.splitext(src_file)
		self.extra_path = os.path.join(src_root, f"{self.src_name}_s{self.src_ext}")


	def __str__(self):
		return self.file


	def generate(self):
		global progress_display
		try:
			bus_set("output", "source_preview", f"\"{self.src_full}\"")
			os.makedirs(os.path.dirname(self.full), exist_ok=True)

			result_path = os.path.join(self.src_root, f"{self.name}{self.ext}")

			sub_args = ["--no-gui", "--diffuse", self.src_full, "--preset", args.laigter_preset, "--normal"]

			process = subprocess.Popen(executable=args.laigter_path, args=sub_args, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, universal_newlines=True)

			while process.poll() is None:
				if bus_get("input", "stop"):
					process.kill()
					sys.exit(2)
				time.sleep(0.25)

			if not os.path.exists(result_path): raise Exception(f"Normal file '{result_path}' does not exist and/or was not created.")
			image = Image.open(result_path)

			source : Image = Image.open(self.src_full).convert("RGBA")
			image.putalpha(source.getchannel("A"))
			image.save(self.full)
			if args.source_path != args.target_path:
				os.remove(result_path)
				bus_set("output", "target_preview", f"\"{self.full}\"")
			else:
				bus_set("output", "target_preview", f"\"{result_path}\"")
		except Exception as e:
			sys.stderr.write(f"Error processing {self.full}: {e}")

		if os.path.exists(self.extra_path): os.remove(self.extra_path)

		progress_display += 1
		bus_set("output", "progress_display", progress_display)


def assign_image_targets():
	result = []
	include = re.compile(args.filter_include)
	exclude = re.compile(args.filter_exclude)
	for root, _, files in os.walk(args.source):
		for file in files:
			if args.filter_include != "" and re.search(include, file) == None: continue
			if args.filter_exclude != "" and re.search(exclude, file) != None: continue
			name, ext = os.path.splitext(file)
			target_file = f"{name}_n{ext}"
			target = TargetImage(args.target, target_file, os.path.join(args.source, root), file)
			if not args.overwrite and os.path.exists(target.full): continue
			result.append(target)
	return result


def main():
	if args.target == "": args.target = args.source

	bus_set("output", "progress_display", 0)
	if os.path.isdir(args.source):
		targets = assign_image_targets()
		bus_set("output", "progress_display_max", len(targets))
		for target in targets: target.generate()
	elif os.path.isfile(args.source):
		bus_set("output", "progress_display_max", 1)
		root = os.path.dirname(args.source)
		file = os.path.basename(args.source)
		name, ext = os.path.splitext(file)
		target_file = f"{name}_n{ext}"
		target = TargetImage(args.target, target_file, os.path.join(args.source, root), file)
		if not args.overwrite and os.path.exists(target.full): return
		target.generate()
	else:
		sys.stderr.write("Input path is not a valid file nor directory.")
		sys.exit(1)


if __name__ == "__main__":
	parser = argparse.ArgumentParser()
	parser.add_argument("bus_path", type=str)
	parser.add_argument("laigter_path", type=str)
	parser.add_argument("laigter_preset", type=str)
	parser.add_argument("source", type=str)
	parser.add_argument("target", type=str)
	parser.add_argument("filter_include", type=str)
	parser.add_argument("filter_exclude", type=str)
	parser.add_argument("overwrite", type=str2bool)
	args = parser.parse_args()

	bus_path = args.bus_path
	bus = configparser.ConfigParser()
	bus.read(bus_path)

	main()

	sys.exit(0)
