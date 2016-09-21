install:
	rsync -r . /usr/local/lib/icomoon-swift
	chmod +x run.sh
	rsync run.sh /usr/local/bin/icomoon-swift

uninstall:
	rm -rf /usr/local/lib/icomoon-swift
	rm -f /usr/local/bin/icomoon-swift
