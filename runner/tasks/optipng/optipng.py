import argparse
import configparser
import os
import subprocess
import sys
import time

files_completed = 0
bytes_reduced = 0


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


def get_png_files(folder, result = []):
	for file in os.listdir(folder):
		full_path = os.path.join(folder, file)
		if os.path.isdir(full_path):
			result = get_png_files(full_path, result)
		elif file.lower().endswith(".png"):
			result.append(full_path)
	return result


def compress_png_file(target):
	global bytes_reduced
	global files_completed
	try:
		bus_set("output", "image_preview", f"\"{target}\"")

		file_size_before = os.path.getsize(target)

		process = subprocess.Popen([args.optipng_path, "-o7", "-out", target, target], stdout=subprocess.PIPE, stderr=subprocess.STDOUT, universal_newlines=True)

		while process.poll() is None:
			if bus_get("input", "stop"):
				process.kill()
				sys.exit(2)
			time.sleep(0.25)

		bytes_reduced += file_size_before - os.path.getsize(target)
		bus_set("output", "bytes", bytes_reduced)

		files_completed += 1
		bus_set("output", "progress", files_completed)
	except Exception as e:
		sys.stderr.write(f"Error compressing \"{target}\": {e}\n")


def main():
	bus_set("output", "progress", 0)
	bus_set("output", "bytes", 0)
	if os.path.isdir(args.target):
		files = get_png_files(args.target)
		bus_set("output", "progress_max", len(files))
		for file in files:
			compress_png_file(file)
	elif os.path.isfile(args.target):
		bus_set("output", "progress_max", 1)
		compress_png_file(args.target)
	else:
		sys.stderr.write("Input path is not a valid file nor directory.")
		sys.exit(1)


if __name__ == "__main__":
	parser = argparse.ArgumentParser()
	parser.add_argument("bus_path", type=str)
	parser.add_argument("optipng_path", type=str)
	parser.add_argument("target", type=str)
	args = parser.parse_args()

	bus_path = args.bus_path
	bus = configparser.ConfigParser()
	bus.read(bus_path)

	main()

	sys.exit(0)
