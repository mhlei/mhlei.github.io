tmux配置文件备份
```
unbind C-b
set -g prefix C-a
set -g status off
set -g set-titles on
set -g escape-time 0

set -g terminal-overrides 'xterm*:smcup@:rmcup@'
```

linux命令行关闭屏幕
```
set dpms force off
```

linux设置运行级别
```
sudo systemctl set-default multi-user.target
```

synergy连接
```
/usr/bin/synergyc -f --no-tray --debug INFO --name leman-ThinkPad-X1-Carbon-3rd 192.168.1.6:2480/usr/bin/synergyc -f --no-tray --debug INFO --name leman-ThinkPad-X1-Carbon-3rd 192.168.1.6:2480
```


