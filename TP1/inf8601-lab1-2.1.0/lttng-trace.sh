lttng create inf8601_tbb_8_trace
lttng enable-event -ak
lttng start
./trace-dragon
lttng stop
traceViewer
