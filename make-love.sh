#!/bin/bash

zip -9r age-gobble.`date +%Y%m%d%H%M`.love . -x*.swp -xage-project/* -x.git*
