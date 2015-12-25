install:
	cp -r . /usr/local/lib/icomoon-swift
	chmod +x run.sh
	cp run.sh /usr/local/bin/icomoon-swift

uninstall:
	rm -rf /usr/local/lib/icomoon-swift
	rm -f /usr/local/bin/icomoon-swift
