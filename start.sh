#!/bin/bash

/start-with-ui.sh &
/start-styletts2.sh &

# Wait for any process to exit
wait -n
exit $?