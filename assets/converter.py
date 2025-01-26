import os
import struct
import zlib

def read_tga(file_path):
    with open(file_path, "rb") as f:
        header = f.read(18)  # TGA header is 18 bytes
        width, height, pixel_depth = struct.unpack_from("<HHB", header, 12)

        if pixel_depth not in (24, 32):
            raise ValueError("Only 24-bit and 32-bit TGA files are supported")

        image_descriptor = header[17]
        rle_encoded = (header[2] & 0x80) != 0

        bytes_per_pixel = pixel_depth // 8
        data = bytearray()

        if rle_encoded:
            while len(data) < width * height * bytes_per_pixel:
                packet_header = ord(f.read(1))
                is_rle = packet_header & 0x80
                pixel_count = (packet_header & 0x7F) + 1

                if is_rle:
                    pixel_data = f.read(bytes_per_pixel)
                    data.extend(pixel_data * pixel_count)
                else:
                    data.extend(f.read(bytes_per_pixel * pixel_count))
        else:
            data = f.read()

        if len(data) < width * height * bytes_per_pixel:
            raise ValueError(
                f"Incomplete pixel data: expected {width * height * bytes_per_pixel} bytes, got {len(data)} bytes"
            )

        converted_data = bytearray()
        for i in range(0, len(data), bytes_per_pixel):
            b, g, r = data[i:i+3]
            converted_data.extend([r, g, b])
            if bytes_per_pixel == 4:
                converted_data.append(data[i+3])

        return width, height, pixel_depth, converted_data

def write_png(file_path, width, height, pixel_depth, data):
    with open(file_path, "wb") as f:
        f.write(b"\x89PNG\r\n\x1a\n")

        def write_chunk(chunk_type, chunk_data):
            f.write(struct.pack("!I", len(chunk_data)))
            f.write(chunk_type)
            f.write(chunk_data)
            crc = struct.pack("!I", zlib.crc32(chunk_type + chunk_data) & 0xffffffff)
            f.write(crc)

        color_type = 6 if pixel_depth == 32 else 2
        ihdr_data = struct.pack(
            "!IIBBBBB",
            width, height, 8, color_type, 0, 0, 0
        )
        write_chunk(b"IHDR", ihdr_data)

        bytes_per_pixel = pixel_depth // 8
        scanline_length = width * bytes_per_pixel
        png_data = b"".join(
            b"\x00" + data[y * scanline_length:(y + 1) * scanline_length]
            for y in range(height)
        )

        compressed_data = zlib.compress(png_data)
        write_chunk(b"IDAT", compressed_data)
        write_chunk(b"IEND", b"")

def convert_tga_to_png(tga_path, png_path):
    width, height, pixel_depth, data = read_tga(tga_path)
    write_png(png_path, width, height, pixel_depth, data)

def convert_tga_files_in_tree(root_dir):
    for root, _, files in os.walk(root_dir):
        for file in files:
            if file.lower().endswith(".tga"):
                tga_path = os.path.join(root, file)
                png_path = os.path.splitext(tga_path)[0] + ".png"
                try:
                    convert_tga_to_png(tga_path, png_path)
                    print(f"Converted: {tga_path} -> {png_path}")
                except Exception as e:
                    print(f"Failed to convert {tga_path}: {e}")

if __name__ == "__main__":
    import sys
    if len(sys.argv) != 2:
        print("Usage: python convert_tga_to_png.py <directory>")
    else:
        convert_tga_files_in_tree(sys.argv[1])