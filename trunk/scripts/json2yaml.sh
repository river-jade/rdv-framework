#!/bin/sh
python -c '
import sys, json, yaml
print yaml.safe_dump(yaml.load(sys.stdin), default_flow_style=False)
' $@


