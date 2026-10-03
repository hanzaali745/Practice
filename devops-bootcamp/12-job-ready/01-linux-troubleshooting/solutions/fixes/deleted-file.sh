# deleted-file — the reference fix
df -h /var/log/demo-app; du -sh /var/log/demo-app               # df: 75% used, du: almost nothing
lsof -a +L1 /var/log/demo-app                                      # python3 PID ... /var/log/demo-app/ship-buffer.log (deleted)
systemctl status "$(lsof -t -a +L1 /var/log/demo-app | head -1)" --no-pager | head -3   # ● log-shipper.service
systemctl stop log-shipper                                      # obsolete: stop it (in real life also disable/remove it)
df -h /var/log/demo-app                                         # space is back
