"""Execute one EPS notebook in a fresh kernel, saving progress after every cell.

Optional process affinity is an explicit machine-local runtime argument, never a
project default. No microdata are exported by this runner.
"""
import argparse
import os
from pathlib import Path
import time
import asyncio
import nbformat
from nbclient import NotebookClient

def main():
    if os.name == "nt":
        asyncio.set_event_loop_policy(asyncio.WindowsSelectorEventLoopPolicy())
    parser = argparse.ArgumentParser()
    parser.add_argument("notebook")
    parser.add_argument("--affinity", help="Comma-separated logical processor numbers")
    parser.add_argument("--through", type=int, help="Execute through this zero-based cell for a preliminary check")
    parser.add_argument("--output-dir", help="Project-relative aggregate-output directory for an independent reproduction")
    args = parser.parse_args()
    if args.affinity:
        import psutil
        psutil.Process().cpu_affinity([int(x) for x in args.affinity.split(",")])
    if args.output_dir:
        assert not Path(args.output_dir).is_absolute() and ".." not in Path(args.output_dir).parts
        os.environ["EPS_MARKOV_OUTPUT"] = args.output_dir
    path = Path(args.notebook).resolve()
    doc = nbformat.read(path, as_version=4)
    start = time.monotonic()
    original_cells = doc.cells
    if args.through is not None:
        doc.cells = doc.cells[:args.through + 1]
    def save():
        if args.through is None:
            nbformat.write(doc, path)
        else:
            full = nbformat.from_dict(dict(doc))
            full.cells = doc.cells + original_cells[args.through + 1:]
            nbformat.write(full, path)
    def done(cell, cell_index, execute_reply=None, **kwargs):
        save()
        print(f"cell {cell_index} completed; {(time.monotonic()-start)/60:.2f} min", flush=True)
    class ProgressClient(NotebookClient):
        def process_message(self, msg, cell, cell_index):
            if msg.get("msg_type") == "stream":
                for line in msg.get("content", {}).get("text", "").splitlines():
                    if line.startswith(("CV repeat", "EPS design JKn", "Person bootstrap")):
                        print(line, flush=True)
            return super().process_message(msg, cell, cell_index)
    client = ProgressClient(doc, timeout=None, kernel_name="ir", allow_errors=False,
                            resources={"metadata":{"path":str(path.parent)}},
                            on_cell_executed=done)
    try:
        client.execute()
    finally:
        save()
    print(f"EXECUTION PASS: {path.name}; {(time.monotonic()-start)/60:.2f} minutes", flush=True)

if __name__ == "__main__":
    main()
