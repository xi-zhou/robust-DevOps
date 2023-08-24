import argparse
import os
import subprocess
import sys
import signal
import time
import psutil

CONFIG_FILE = '/tmp/config.ini'
PGID_FILE = '/tmp/pgid.txt'
RESTORE_CMD = ""


class Parser:
    def __init__(self):
        self.parser = argparse.ArgumentParser(description='generate noisy env')

        self.parser.add_argument('--file-output',
                                 help='Redirect output to file')

        self.subparsers = self.parser.add_subparsers(title='subcommands', required=True)

        self.add_fuzz_load_subcommand()
        self.add_concurrency_subcommand()
        self.add_ram_io_subcommand()
        self.add_network_subcommand()
        self.add_activate_subcommand()
        self.add_deactivate_subcommand()
        self.add_config_subcommand()
        self.add_test_subcommand()

    def add_fuzz_load_subcommand(self):
        fuzz_load_parser = self.subparsers.add_parser('fuzz-load', help="define system load")
        fuzz_load_parser.add_argument('--cpu', type=int, help='CPU load in percentage', choices=range(0, 101),
                                      metavar="[0-100]", required=True)
        fuzz_load_parser.add_argument('--ram', type=int, help='RAM load in percentage', choices=range(0, 101),
                                      metavar="[0-100]", required=True)
        fuzz_load_parser.set_defaults(func=fuzz_load_command)

    def add_concurrency_subcommand(self):
        concurrency_parser = self.subparsers.add_parser("concurrency", help="define cores and threads")
        concurrency_parser.add_argument('--cores', type=int, help="number of cores (0 for all)", required=True)
        concurrency_parser.add_argument('--cpu-load', type=int, help='CPU load in percentage', choices=range(0, 101), metavar="[0-100]", required=True)
        concurrency_parser.set_defaults(func=concurrency_command)

    def add_ram_io_subcommand(self):
        ram_io_parser = self.subparsers.add_parser('ram_io', help="define ram and io load")
        ram_io_parser.add_argument('--workers', type=int, help='number of workers for ram and io', required=True, choices=range(1, 11), metavar="[1-10]")
        ram_io_parser.add_argument('--ram', type=int, help="ram load in percent", required=True, choices=range(0, 101), metavar="[0-100]%")
        ram_io_parser.add_argument('--io', type=int, help="io load in gigabytes", required=True, choices=range(0, 101), metavar="[0-100]GB")
        ram_io_parser.set_defaults(func=ram_io_command)

    def add_network_subcommand(self):
        network_parser = self.subparsers.add_parser('network', help="define network behavior")
        group = network_parser.add_mutually_exclusive_group(required=True)
        group.add_argument('--delay', help='delay of incoming packet in milliseconds', type=int)
        group.add_argument('--packageLoss', help='package loss in percentage', type=int)
        group.add_argument('--bandwidth', help='bandwidth in Mbps', type=int)
        network_parser.set_defaults(func=network_command)

    def add_test_subcommand(self):
        test_parser = self.subparsers.add_parser('test', help="prints 'Noise-Tool Test <date>' repeatedly every second")
        test_parser.set_defaults(func=test_command)

    def add_config_subcommand(self):
        config_parser = self.subparsers.add_parser('config', help="manage config")
        group = config_parser.add_mutually_exclusive_group(required=True)
        group.add_argument('--write', help='write noise configuration')
        group.add_argument('--append', help='append noise configuration')
        config_parser.set_defaults(func=config_command)

    def add_activate_subcommand(self):
        activate_parser = self.subparsers.add_parser('activate', help="activate noise tool")
        activate_parser.add_argument('--file-out', help='Redirect output of activated commands to file')
        activate_parser.set_defaults(func=activate_command)

    def add_deactivate_subcommand(self):
        deactivate_parser = self.subparsers.add_parser('deactivate', help="deactivate noise tool")
        deactivate_parser.set_defaults(func=deactivate_command)

    def parse_args(self):
        return self.parser.parse_args()


def config_command(args):
    # Create the directory structure if not exist
    os.makedirs(os.path.dirname(CONFIG_FILE), exist_ok=True)
    if args.write is not None:
        mode = 'w'
        content = args.write
    elif args.append is not None:
        mode = 'a'
        content = args.append
    else:
        print("Invalid arguments")
        return

    with open(CONFIG_FILE, mode) as file:
        file.write(content + "\n")

    print(f"Writing to {CONFIG_FILE}:\n{content}")


def activate_command(args):
    print("Activating Noise tool...")

    if os.path.exists(PGID_FILE):
        print(f"Error: PGID file ({PGID_FILE}) exists. Probably already running. Deactivate first")
        return
    if not os.path.exists(CONFIG_FILE):
        print(f"Error: no config file ({CONFIG_FILE}) found.")
        return

    # Read the commands from the file
    cmd_list = []
    with open(CONFIG_FILE, 'r') as conf_file:
        # Split file content by lines and remove empty strings
        cmd_list = list(filter(None, conf_file.read().splitlines()))

    print(f"Command list: {cmd_list}")

    process_list = []
    for cmd in cmd_list:
        # if --file-out was given to activate command, give --file-output to the started commands
        file_out_cmd = (['--file-output', os.path.abspath(args.file_out)] if args.file_out is not None else [])
        process = subprocess.Popen(['noise-tool'] + file_out_cmd + cmd.split(),
                                   start_new_session=True,
                                   bufsize=1,
                                   text=True
                                   # stdout=subprocess.DEVNULL,   # Redirect to null
                                   # stderr=subprocess.STDOUT)    # This one too
                                   )
        process_list.append(process)

    # Store the program's process group ID in a file
    os.makedirs(os.path.dirname(PGID_FILE), exist_ok=True)
    with open(PGID_FILE, 'w') as pgid_file:
        for process in process_list:
            print(f"PID: {process.pid}, PGID: {os.getpgid(process.pid)}")
            pgid_file.write(str(os.getpgid(process.pid)))
            pgid_file.write('\n')

    print(f"PGIDs saved to {PGID_FILE}")


def deactivate_command(args):
    print("Deactivating Noise...")
    if not os.path.exists(PGID_FILE):
        print(f"Error: no pgid file ({PGID_FILE}) found.")
        return
    # Read the program's process ID from the file
    pgid_list = []
    with open(PGID_FILE, 'r') as pgid_file:
        pgid_list = list(filter(None, pgid_file.read().splitlines()))

    for pgid in pgid_list:
        try:
            # Terminate the running program using the process ID
            # os.kill(pid, signal.SIGTERM)
            # os.killpg(os.getpgid(int(pid)), signal.SIGTERM)
            os.killpg(int(pgid), signal.SIGTERM)
            print(f"Killed process group {pgid}")
        except (ProcessLookupError, ValueError):
            print(f"Error: Process group with PGID {pgid} not found.")

    # Clean up the PGID and output files
    os.remove(PGID_FILE)

    print('Program deactivated.')


def test_command(args):
    print("Running test command")
    subprocess.Popen('while true; do echo Noise-Tool Test $(date); sleep 1; done', shell=True, stdout=sys.stdout,
                     stderr=sys.stderr).wait()


def concurrency_command(args):
    print(args)
    print(f"Running concurrent command with {args.cores} cores and {args.cpu_load} cpu load")
    process = subprocess.Popen(["stress-ng", "--cpu", str(args.cores), "--cpu-load", str(args.cpu_load), "--cpu-method", "ackermann"],
                               stdout=sys.stdout,
                               stderr=sys.stderr
                               )
    process.wait()


def fuzz_load_command(args):
    print(f"Running fuzz load command with {args.cpu}% CPU and {args.ram}% RAM")


# ram_io --workers 3  --ram 3 --io 4
def ram_io_command(args):
    bytes_absolute = int(psutil.virtual_memory().total * (args.ram / 100.0))
    print(
        f"Running stress ram and io command with {args.workers} workers, {args.ram}% ({bytes_absolute}bytes) RAM load, and {args.io}GB I/O load")
    command = "stress" + ("" if args.ram == 0 else f" --vm {args.workers} --vm-bytes {bytes_absolute}") + ("" if args.io == 0 else f" --hdd {args.workers} --hdd-bytes {args.io}G")
    print(command)
    process = subprocess.Popen(command, shell=True,
                               stdout=sys.stdout,
                               stderr=sys.stderr
                               )
    process.wait()


def network_command(args):
    global RESTORE_CMD
    if args.delay is not None:
        command = f"tc qdisc add dev eth0 root netem delay {args.delay}ms"
        print("Delay: " + str(args.delay))
        RESTORE_CMD = "tc qdisc del dev eth0 root netem"
    if args.packageLoss is not None:
        command = f"tc qdisc add dev eth0 root netem loss {args.packageLoss}%"
        print("Package loss: " + str(args.packageLoss))
        RESTORE_CMD = "tc qdisc del dev eth0 root netem"
    if args.bandwidth is not None:
        command = f"tc qdisc add dev eth0 root tbf rate {args.bandwidth}mbit burst 32kbit latency 400ms"
        print("Bandwidth: " + str(args.bandwidth))
        RESTORE_CMD = f"tc qdisc del dev eth0 root tbf rate {args.bandwidth}mbit burst 32kbit latency 400ms"
    subprocess.run(command, shell=True, check=True, stdout=sys.stdout, stderr=sys.stderr)

    while True:
        time.sleep(1)


def sigterm_handler(signal, frame):
    subprocess.run(RESTORE_CMD, shell=True, check=True, stdout=sys.stdout, stderr=sys.stderr)
    sys.exit(0)
