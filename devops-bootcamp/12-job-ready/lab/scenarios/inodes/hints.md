## Hint 1
"No space left" has two meanings: no free **blocks** (`df -h`) or no free **inodes** (`df -i`). Every file, however
small, needs one inode.

## Hint 2
Find the directory with the most files: `find /var/log/demo-app -xdev -type f | cut -d/ -f1-5 | sort | uniq -c | sort -n | tail`.

## Hint 3
`rm -r` on a directory with thousands of files works; `rm *` may fail with "Argument list too long" (then use
`find DIR -type f -delete`). Afterwards ask the real question: what writes these files, and who will clean them up next time?
