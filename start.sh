#!/bin/bash

echo -e "\n### Container Environment Variables\n\n$(printenv | grep -v KUBERNETES_)\n"
tail -f /dev/null # Pretend to be a long-running process
