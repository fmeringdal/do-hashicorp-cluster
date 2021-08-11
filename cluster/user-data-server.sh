#!/bin/bash

set -e

sudo bash /ops/shared/scripts/server.sh "${nomad_servers_count}" "${retry_join}" 