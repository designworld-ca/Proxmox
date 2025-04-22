# Clear logs older than 5 days
```
journalctl --vacuum-time=5days
```

# view journal or log entries for a service
```
sudo journalctl -u tipi.service
```
# since last boot
```
sudo journalctl -b
```
# since a date
```
journalctl -u tipi.service --since='2023-10-09 12:00:00'
```
# since a time 
```
journalctl --since 09:00 --until "1 hour ago"
```

press q to quit
