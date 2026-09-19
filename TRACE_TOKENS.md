# Local token trace

This branch adds opt-in server logging for local prompt and generation work.
The streams can be enabled independently and write to `stderr`:

```text
--log-input-tokens     rendered input prompt
--log-output-tokens    generated output token pieces
--log-tokens           both streams
```

The combined `LLAMA_TRACE_TOKENS=1` environment variable remains supported for
backward compatibility and enables both streams. The explicit environment
equivalents are `LLAMA_ARG_LOG_INPUT_TOKENS`, `LLAMA_ARG_LOG_OUTPUT_TOKENS`,
and `LLAMA_ARG_LOG_TOKENS`.

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

For the Qwen launcher in the sibling `E:\qwen` project, use switches:

```powershell
E:\qwen\start-qwen35-9b.ps1 -LogTokens
E:\qwen\start-qwen35-9b.ps1 -LogInputTokens
E:\qwen\start-qwen35-9b.ps1 -LogOutputTokens
```

The launcher automatically selects `E:\qwen\bin\spotcobuild_9_18_2026\llama-server.exe`
when that deployment exists. Set `QWEN_SERVER_EXE` to override it, or set
`QWEN_TRACE_TOKENS=0` to disable both streams. The environment equivalents for
the launcher switches are `QWEN_LOG_INPUT_TOKENS=1` and
`QWEN_LOG_OUTPUT_TOKENS=1`.
