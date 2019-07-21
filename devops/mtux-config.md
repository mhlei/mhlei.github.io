tmux配置文件备份
```
unbind C-b
set -g prefix C-a
set -g status off
set -g set-titles on
set -g escape-time 0

set -g terminal-overrides 'xterm*:smcup@:rmcup@'
```

