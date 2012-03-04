#!/bin/bash
# 
# 	reflac.sh
#
# 	Script to reencode flac files while preserving metadata
#
# Copyright 2011 Torben Deumert. All rights reserved.
#
# File		: reflac.sh
# Author	: Torben Deumert (tordeu at googlemail dot com)
# Date		: 2011-07-07
# Version	: 2011-11-28
# License	: FreeBSD License (see "License" section below)
#
#================[ Description ]========================================
#
# 	Reflac reencodes a flac file while preserving metadata. It was 
#	created to "repair" flac files that can not be used with oggenc 
# 	because of the way the metadata is stored. In those cases oggenc 
#	produces the following error message:
# 	  ERROR: Input file <file> is not a supported format
# 
#	Because reflac REPLACES the flac files, backing up the original flac
# 	files is encouraged in case something goes wrong.
#
#==============================[ Usage ]================================
#
# Usage:
#
#   reflac.sh <flac file>...
#
# Examples:
#
#   to reflac a single flac file named foo.flac, run:
#   
#		reflac.sh foo.flac
#
#	to reflac multi flac files (named foo.flac, bar.flac and what.flac):
#
#		reflac.sh foo.flac bar.flac what.flac
#
#	to reflac all flac files in the current directory
#
#		reflac.sh *.flac
#
#==============================[ License ]==============================
#
# Copyright 2011 Torben Deumert. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without 
# modification, are permitted provided that the following conditions are 
# met:
#
#    1. Redistributions of source code must retain the above copyright 
#		notice, this list of conditions and the following disclaimer.
# 
#    2. Redistributions in binary form must reproduce the above 
#		copyright notice, this list of conditions and the following 
#		disclaimer in the documentation and/or other materials provided
#		with the distribution.
# 
# THIS SOFTWARE IS PROVIDED BY <COPYRIGHT HOLDER> ''AS IS'' AND ANY 
# EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR 
# PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> OR 
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR 
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS 
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#=======================================================================

# let's make the script a little more robust
set -u			# exit if the script tries to use an unbound variable
set -e			# exit we a command fails 
set -o pipefail # exit if a command in a pipe fails

# loop through all the arguments
while [ $# -ne 0 ]; do

FLAC=$1

# create two temporary files (one for the metadata, one for the wav)
META_TMP=`mktemp reflac.XXX`
WAV_TMP=`mktemp reflac.XXX.wav`

#make sure the temporary files get deleted even if the script fails
trap "rm -f  \"$META_TMP\" \"$WAV_TMP\"" EXIT

# export the metadata
metaflac --export-tags-to="$META_TMP" "$FLAC"

# reencode the flac
flac -d "$FLAC" -f -o "$WAV_TMP"

# reencode the wav
flac "$WAV_TMP" -f -o "$FLAC"

# add the metadata to the new flac
metaflac --import-tags-from="$META_TMP" "$FLAC"

# delete both temporary files
rm "$META_TMP"
rm "$WAV_TMP"

shift

done

