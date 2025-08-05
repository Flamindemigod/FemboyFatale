#!/usr/bin/env nix-shell
#! nix-shell -i bash -p imagemagick

Usage() {
    echo "./run.sh input_path output_path"
}

Convert(){
    if [ $# -lt 2 ]
        then
            echo "Not enough Arguments Supplied"
            Usage
        else
            magick $1                            \
                -resize 256x256                  \
                -gravity center                  \
                -define dds:compression=dxt5     \
                -define dds:mipmaps=all          \
                -define dds:mipmap-filter=linear \
                -depth 8                         \
                -alpha on                        \
                $2
    fi
}

Convert ./testing/jesus_beam.png ./icons/overrides/JesusBeam.dds
