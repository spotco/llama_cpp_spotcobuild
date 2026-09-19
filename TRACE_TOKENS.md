# Local token trace

This branch adds an opt-in server trace for local prompt and generation work.
It is enabled with `LLAMA_TRACE_TOKENS=1` and writes to `stderr`:

```text
──── INPUT ────
<the rendered, detokenized request prompt>
──── OUTPUT ────
<each generated token piece, flushed immediately>
```

The input is taken from the server's final tokenized request, so it includes
the chat template and special tokens that are actually evaluated. Output is
written from the server token-processing path before stop-string filtering,
which keeps the trace aligned with generation rather than with an HTTP/SSE
chunk boundary. The trace is disabled unless the environment variable is
non-empty and not `0`.

For the Qwen launcher in the sibling `E:\qwen` project:

```powershell
$env:QWEN_TRACE_TOKENS = "1"
E:\qwen\start-qwen35-9b.ps1
```

The launcher automatically selects `E:\qwen\bin\spotcobuild_9_18_2026\llama-server.exe`
when that deployment exists. Set `QWEN_SERVER_EXE` to override it, or set
`QWEN_TRACE_TOKENS=0` to use the normal server logging path.
