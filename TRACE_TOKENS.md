# Local token trace

This branch adds opt-in server logging for local prompt and generation work.
The streams can be enabled independently and write to `stderr`:

```text
--log-input-tokens     rendered input prompt
--log-output-tokens    generated output token pieces
--log-output-tps       calculated generation speed at the end of output
--log-tokens           both streams
```

The combined `LLAMA_TRACE_TOKENS=1` environment variable remains supported for
backward compatibility and enables both streams. The explicit environment
equivalents are `LLAMA_ARG_LOG_INPUT_TOKENS`, `LLAMA_ARG_LOG_OUTPUT_TOKENS`,
`LLAMA_ARG_LOG_TOKENS`, and `LLAMA_ARG_LOG_OUTPUT_TPS`. The TPS option also
enables output-token logging; `--no-log-output-tps` or
`LLAMA_ARG_LOG_OUTPUT_TPS=0` disables only the speed line.

```text
──── INPUT ────
<the rendered, detokenized request prompt>
──── OUTPUT ────
<each generated token piece>
[output tokens/sec: 37.41 | generated tokens: 32 | model buffers: 73.8% device / 26.2% host]
──── END OUTPUT ────
```

The input is taken from the server's final tokenized request, so it includes
the chat template and special tokens that are actually evaluated. Output is
written from the server token-processing path before stop-string filtering,
which keeps the trace aligned with generation rather than with an HTTP/SSE
chunk boundary. The speed value uses the same generation timing calculation as
llama.cpp's normal timing report (`n_gen_tps()`), including its existing
exclusion of the initial prompt-logits step. The TPS line also reports the
allocated model-weight buffer split between non-host/device memory and
host-accessible memory. On a discrete CUDA GPU, these correspond to VRAM and
system RAM respectively.

The default llama.cpp model loader also reports byte-based loading progress as
`loading model: NN%` instead of printing one dot per percentage point.

Trace output is sent through a background sink, so terminal writes and flushes
are not performed synchronously by the decode thread. With tracing disabled,
the hot path only checks the disabled flags and does not create the sink. When
tracing is enabled, each piece still has a small queue/copy cost; no logging
implementation can make that overhead literally zero, but it avoids blocking
token generation on terminal I/O.

For the Qwen launcher in the sibling `E:\qwen` project, use switches:

```powershell
E:\qwen\start-qwen35-9b.ps1 -LogTokens
E:\qwen\start-qwen35-9b.ps1 -LogInputTokens
E:\qwen\start-qwen35-9b.ps1 -LogOutputTokens
E:\qwen\start-qwen35-9b.ps1 -LogOutputTps
```

The launcher automatically selects `E:\qwen\bin\spotcobuild_9_18_2026\llama-server.exe`
when that deployment exists. Set `QWEN_SERVER_EXE` to override it, or set
`QWEN_TRACE_TOKENS=0` to disable both streams. The environment equivalents for
the launcher switches are `QWEN_LOG_INPUT_TOKENS=1` and
`QWEN_LOG_OUTPUT_TOKENS=1`. The launcher enables output TPS by default
whenever output tracing is enabled; set `QWEN_LOG_OUTPUT_TPS=0` or pass
`-NoLogOutputTps` to suppress the speed line.
