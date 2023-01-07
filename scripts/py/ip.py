import argparse
import platform
import socket
import subprocess
import urllib.request

parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter, description="IP address utility")
parser.add_argument("--type", choices=("public", "local"), default="public", help="specify type")
parser.add_argument("--copy", action="store_true", help="copy to clipboard")
args = parser.parse_args()

ip = None

if args.type == "public":
	ip = urllib.request.urlopen("https://checkip.amazonaws.com").read().decode("utf-8").strip()
elif args.type == "local":
	sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
	sock.connect(("1.1.1.1", 1))
	ip = sock.getsockname()[0]

print(ip, end="")

if (args.copy):
	process = subprocess.Popen({"Windows": "clip", "Darwin": "pbcopy", "Linux": "xclip"}[platform.system()], stdin=subprocess.PIPE)
	process.stdin.write(bytes(ip, "utf-8"))
	process.stdin.flush()
