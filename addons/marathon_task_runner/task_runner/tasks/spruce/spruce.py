import argparse
import configparser
import os
import re
import sys
import time
from PIL import Image, ImageChops

progress = 0

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


class Rect:
	def __init__(self, *args):
		if len(args) == 4 and all(isinstance(arg, int) for arg in args):
			self.x, self.y, self.w, self.h = args
		elif len(args) == 2 and all(isinstance(arg, tuple) and len(arg) == 2 for arg in args):
			(self.x, self.y), (self.w, self.h) = args
		else:
			raise TypeError("Expected 4 integers or 2 (x, y) tuples")


	def __repr__(self):
		return f"Rect({self.x}, {self.y} ... {self.w}, {self.h})"


	@property
	def xy(self) -> tuple[int, int]:
		return (self.x, self.y)
	@xy.setter
	def xy(self, value: tuple[int, int]):
		self.x = value[0]
		self.y = value[1]


	@property
	def size(self) -> tuple[int, int]:
		return (self.w, self.h)
	@size.setter
	def size(self, value: tuple[int, int]):
		self.w = value[0]
		self.h = value[1]


	@property
	def r(self) -> int:
		return self.x + self.w
	@r.setter
	def r(self, value):
		self.w = value - self.x


	@property
	def b(self) -> int:
		return self.y + self.h
	@b.setter
	def b(self, value):
		self.h = value - self.y


	@property
	def rb(self) -> tuple[int, int]:
		return (self.r, self.b)
	@rb.setter
	def rb(self, value: tuple[int, int]):
		self.r = value[0]
		self.b = value[1]


	@property
	def area(self) -> int:
		return self.w * self.h


	## Returns true if the other Rect is completely inside self
	def contains(self, other) -> bool:
		if not isinstance(other, Rect):
			raise TypeError("Expected a Rect instance")
		return (
			self.x <= other.x and self.y <= other.y and
			self.r >= other.r and self.b >= other.b
		)

	## Returns true if the Rects touch at all
	def overlaps(self, other) -> bool:
		if not isinstance(other, Rect):
			raise TypeError("Expected a Rect instance")
		return not (
			self.r <= other.x or self.x >= other.r or
			self.b <= other.y or self.y >= other.b
		)

	def union(self, other):
		result = Rect(min(self.x, other.x), min(self.y, other.y), max(self.r, other.r), max(self.b, other.b))
		result.r = result.w
		result.b = result.h
		return result


class TargetImage:
	def __init__(self, root, file):
		self.root = root
		self.file = file
		self.full = os.path.join(root, file)
		self.name, self.ext = os.path.splitext(file)

		self.temp_path_new = os.path.join(args.temp_root, f"{self.name}__new{self.ext}")
		self.temp_path_diff = os.path.join(args.temp_root, f"{self.name}__diff{self.ext}")

		self.image : Image = Image.open(self.full).convert("RGBA")


	def process(self):
		global progress

		try:
			os.makedirs(args.temp_root, exist_ok=True)
			os.makedirs(os.path.dirname(self.full), exist_ok=True)
			bus_set("output", "source_preview", f"\"{self.full}\"")

			## Initialize bitmap

			r, g, b, a = self.image.split()
			a_pixels = a.load()
			w, h = self.image.size
			bitmap = Image.new("1", self.image.size)
			bitmap_pixels = bitmap.load()

			## Cull pixels below opacity threshold in bitmap

			for x in range(w):
				for y in range(h):
					bitmap_pixels[x, y] = 0 if a_pixels[x, y] <= args.island_opacity else 1
			bitmap_original = bitmap.copy()

			## Cull pixel islands below area threshold in bitmap

			if args.island_size < w * h:
				pixels_visited = set()
				island_bitmaps = set()

				def flood_fill(x, y):
					stack = [(x, y)]
					island_pixels = []

					while stack:
						px, py = stack.pop()
						if (px, py) in pixels_visited or px < 0 or py < 0 or px >= w or py >= h:
							continue
						if bitmap_pixels[px, py] == 0:
							continue

						pixels_visited.add((px, py))
						island_pixels.append((px, py))

						stack.extend([(px + 1, py), (px - 1, py), (px, py + 1), (px, py - 1)])
					return island_pixels

				# for x, y in range(w, h):
				for x in range(w):
					for y in range(h):
						if (x, y) in pixels_visited or bitmap_pixels[x, y] == 0: continue

						island_pixels = flood_fill(x, y)
						if not island_pixels: continue

						min_x = min(p[0] for p in island_pixels)
						max_x = max(p[0] for p in island_pixels)
						min_y = min(p[1] for p in island_pixels)
						max_y = max(p[1] for p in island_pixels)
						island_rect = Rect(min_x, min_y, max_x - min_x + 1, max_y - min_y + 1)
						if island_rect.area < args.island_size: continue

						island_bitmaps = island_bitmaps.union(island_pixels)

				for x in range(w):
					for y in range(h):
						bitmap_pixels[x, y] = 1 if (x, y) in island_bitmaps else 0

			## Merge bitmap and original alpha

			mask = bitmap.convert("L")
			mask_pixels = mask.load()
			for x in range(w):
				for y in range(h):
					a_pixels[x, y] = min(mask_pixels[x, y], a_pixels[x, y])
			self.image = Image.merge("RGBA", (r, g, b, a))
			self.image.save(self.temp_path_new)

			## Commit final image

			changes_exist : bool = False
			if args.review_changes:
				changes = ImageChops.difference(bitmap, bitmap_original)
				changes_exist = changes.getbbox()
				if changes_exist:
					changes.save(self.temp_path_diff)
			else:
				self.image.save(self.full)

			bus_set("output", "target_bitmap", f"\"{self.temp_path_diff}\"")
			bus_set("output", "target_preview", f"\"{self.temp_path_new}\"")

			if not changes_exist:
				os.remove(self.temp_path_new)
				os.remove(self.temp_path_diff)

		except Exception as e:
			sys.stderr.write(f"Error processing {self.full}: {e}")
			progress -= 1

		progress += 1
		bus_set("output", "progress", progress)


def assign_targets():
	result = []
	include = re.compile(args.filter_include)
	exclude = re.compile(args.filter_exclude)
	for root, _, files in os.walk(args.target):
		for file in files:
			if args.filter_include != "" and re.search(include, file) == None: continue
			if args.filter_exclude != "" and re.search(exclude, file) != None: continue
			try:
				target = TargetImage(os.path.join(args.target, root), file)
			except: continue
			result.append(target)
	return result


def main():
	bus_set("output", "progress", 0)
	if os.path.isdir(args.target):
		targets = assign_targets()
		bus_set("output", "progress_max", len(targets))
		for target in targets:
			if bus_get("input", "stop"): sys.exit(1)
			target.process()
	elif os.path.isfile(args.target):
		target = TargetImage(os.path.dirname(args.target), os.path.basename(args.target))
		bus_set("output", "progress_max", 1)
		target.process()
	else:
		sys.stderr.write("Input path is not a valid file nor directory.")
		sys.exit(1)


if __name__ == "__main__":
	parser = argparse.ArgumentParser()
	parser.add_argument("bus_path", type=str)
	parser.add_argument("temp_root", type=str)
	parser.add_argument("target", type=str)
	parser.add_argument("review_changes", type=str2bool)
	parser.add_argument("filter_include", type=str)
	parser.add_argument("filter_exclude", type=str)
	parser.add_argument("island_opacity", type=int)
	parser.add_argument("island_size", type=int)
	args = parser.parse_args()

	args.filter_include = args.filter_include[1:-1]
	args.filter_exclude = args.filter_exclude[1:-1]

	bus_path = args.bus_path
	bus = configparser.ConfigParser()
	bus.read(bus_path)

	main()

	sys.exit(0)
