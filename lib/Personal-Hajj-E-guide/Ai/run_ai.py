import argparse
import subprocess
import sys
from pathlib import Path


AI_DIR = Path(__file__).resolve().parent


def run(cmd):
    print(f"\n$ {' '.join(cmd)}")
    completed = subprocess.run(cmd, check=False)
    if completed.returncode != 0:
        raise SystemExit(completed.returncode)


def main():
    parser = argparse.ArgumentParser(description="Single entrypoint for AI RAG and RAGAS tasks.")
    subparsers = parser.add_subparsers(dest="command", required=True)

    dataset = subparsers.add_parser("dataset", help="Generate RAGAS dataset CSV.")
    dataset.add_argument("--no-unanswerable", action="store_true")
    dataset.add_argument("--unanswerable-ratio", type=float, default=0.15)
    retrieve = subparsers.add_parser("retrieve", help="Run retrieval smoke test.")
    retrieve.add_argument("-q", "--question", default=None)
    benchmark = subparsers.add_parser("benchmark-retrieval", help="Run retrieval benchmark metrics.")
    benchmark.add_argument("--max-questions", type=int, default=0)
    subparsers.add_parser("rag", help="Run interactive RAG answer flow with Ollama.")

    compare = subparsers.add_parser("compare", help="Compare two or more Ollama models side by side.")
    compare.add_argument("--models", nargs="+", default=["silma-kashif:2b", "llama3"])
    compare.add_argument("--max-questions", type=int, default=0)
    compare.add_argument("--question", "-q", default=None)
    compare.add_argument("--out", default=None)

    answers = subparsers.add_parser("answers", help="Generate answers for RAGAS dataset.")
    answers.add_argument("--max-questions", type=int, default=0)
    answers.add_argument("--overwrite", action="store_true")

    evaluate = subparsers.add_parser("eval", help="Evaluate with RAGAS.")
    evaluate.add_argument("--in", dest="input_csv", default=None)
    evaluate.add_argument("--out", dest="output_csv", default=None)
    evaluate.add_argument("--separate", action="store_true")
    evaluate.add_argument("--allow-partial-data", action="store_true")
    evaluate.add_argument("--min-answered-ratio", type=float, default=0.95)
    evaluate.add_argument("--min-retrieved-ratio", type=float, default=0.95)
    evaluate.add_argument("--judge-model", default=None)
    evaluate.add_argument("--judge-base-url", default="http://localhost:11434")
    evaluate.add_argument("--judge-provider", default="ollama", choices=("ollama", "gemini"))
    evaluate.add_argument("--judge-sample", type=int, default=0)

    suite = subparsers.add_parser("suite", help="Run dataset + answers + eval in order.")
    suite.add_argument("--max-questions", type=int, default=10)
    suite.add_argument("--full", action="store_true")
    suite.add_argument("--separate", action="store_true")
    suite.add_argument("--overwrite", action="store_true")
    suite.add_argument("--smoke-first", action="store_true")
    suite.add_argument("--smoke-questions", type=int, default=10)
    suite.add_argument("--with-retrieval-benchmark", action="store_true")
    suite.add_argument("--min-answered-ratio", type=float, default=0.95)
    suite.add_argument("--min-retrieved-ratio", type=float, default=0.95)
    suite.add_argument("--judge-model", default=None)
    suite.add_argument("--judge-base-url", default="http://localhost:11434")
    suite.add_argument("--judge-provider", default="ollama", choices=("ollama", "gemini"))
    suite.add_argument("--judge-sample", type=int, default=0)

    args = parser.parse_args()

    compare_script = AI_DIR / "tests" / "scripts" / "compare_models.py"
    scripts_dir = AI_DIR / "tests" / "scripts"
    dataset_script = scripts_dir / "generate_dataset.py"
    retrieve_script = scripts_dir / "smoke_retrieval.py"
    benchmark_retrieval_script = scripts_dir / "benchmark_retrieval.py"
    answers_script = scripts_dir / "generate_answers.py"
    eval_script = scripts_dir / "eval_ragas.py"
    suite_script = scripts_dir / "run_ragas_suite.py"
    rag_script = AI_DIR / "rag" / "ollama_pipeline.py"

    if args.command == "dataset":
        cmd = [sys.executable, str(dataset_script), "--unanswerable-ratio", str(args.unanswerable_ratio)]
        if args.no_unanswerable:
            cmd.append("--no-unanswerable")
        run(cmd)
        return

    if args.command == "retrieve":
        cmd = [sys.executable, str(retrieve_script)]
        if args.question:
            cmd += ["--question", args.question]
        run(cmd)
        return

    if args.command == "benchmark-retrieval":
        cmd = [sys.executable, str(benchmark_retrieval_script)]
        if args.max_questions:
            cmd += ["--max-questions", str(args.max_questions)]
        run(cmd)
        return

    if args.command == "rag":
        run([sys.executable, str(rag_script)])
        return

    if args.command == "compare":
        cmd = [sys.executable, str(compare_script), "--models"] + args.models
        if args.max_questions:
            cmd += ["--max-questions", str(args.max_questions)]
        if args.question:
            cmd += ["--question", args.question]
        if args.out:
            cmd += ["--out", args.out]
        run(cmd)
        return

    if args.command == "answers":
        cmd = [sys.executable, str(answers_script)]
        if args.max_questions:
            cmd += ["--max-questions", str(args.max_questions)]
        if args.overwrite:
            cmd.append("--overwrite")
        run(cmd)
        return

    if args.command == "eval":
        cmd = [
            sys.executable,
            str(eval_script),
            "--min-answered-ratio",
            str(args.min_answered_ratio),
            "--min-retrieved-ratio",
            str(args.min_retrieved_ratio),
        ]
        if args.input_csv:
            cmd += ["--in", args.input_csv]
        if args.output_csv:
            cmd += ["--out", args.output_csv]
        if args.separate:
            cmd.append("--separate")
        if args.allow_partial_data:
            cmd.append("--allow-partial-data")
        if args.judge_model:
            cmd += ["--judge-model", args.judge_model]
            cmd += ["--judge-base-url", args.judge_base_url]
            cmd += ["--judge-provider", args.judge_provider]
            if args.judge_sample:
                cmd += ["--judge-sample", str(args.judge_sample)]
        run(cmd)
        return

    if args.command == "suite":
        cmd = [sys.executable, str(suite_script)]
        if not args.full:
            cmd += ["--max-questions", str(args.max_questions)]
        else:
            cmd.append("--full")
        if args.separate:
            cmd.append("--separate")
        if args.overwrite:
            cmd.append("--overwrite")
        if args.smoke_first:
            cmd.append("--smoke-first")
            cmd += ["--smoke-questions", str(args.smoke_questions)]
        if args.with_retrieval_benchmark:
            cmd.append("--with-retrieval-benchmark")
        cmd += [
            "--min-answered-ratio",
            str(args.min_answered_ratio),
            "--min-retrieved-ratio",
            str(args.min_retrieved_ratio),
        ]
        if args.judge_model:
            cmd += ["--judge-model", args.judge_model]
            cmd += ["--judge-base-url", args.judge_base_url]
            cmd += ["--judge-provider", args.judge_provider]
            if args.judge_sample:
                cmd += ["--judge-sample", str(args.judge_sample)]
        run(cmd)
        return


if __name__ == "__main__":
    main()
