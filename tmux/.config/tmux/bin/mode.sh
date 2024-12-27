#!/usr/bin/env bash

PREFIX=$(tmux client_prefix)
PANE_MODE=$(tmux pane_mode)
echo $PREFIX
if [[ $PREFIX == "1" ]]; then
  echo "PREFIX" 
elif [[ $PANE_MODE == "copy-mode" ]]; then
  echo "COPY"
else
  echo "DEFAULT"
fi
