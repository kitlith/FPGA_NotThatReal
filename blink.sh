# Put this script in the powerslaves examples folder, and run as root after compiling the examples.
while true; do
	./arbitrary FF000000000000FF;
	sleep 0.5s;
	./arbitrary FF00000000000000;
	sleep 0.5s;
done
