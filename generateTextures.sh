#!/usr/bin/env nix-shell
#! nix-shell -i bash -p imagemagick

Usage() {
    echo "./run.sh input_path output_path"
}

while IFS='=' read -r oldpath col1 col2; do
     # echo "$col1"
     # echo "$col2"
    # echo "${col1// /_}"
    # printf "%s, %s\n" "${col2}" "${col1}"
    printf " { \"%s\" , \"%s.dds\" }, -- %s\n" "${oldpath}" "${col1// /_}" "${col1}"
done < IconOverrides.txt



Convert(){
    if [ $# -lt 2 ]
        then
            echo "Not enough Arguments Supplied"
            Usage
        else
            magick $1                               \
                -resize 256x256                  \
                -gravity center                   \
                -extent 256x256                   \
                -background white \
                -alpha remove \
                -size 256x256 xc:white \
                -compose CopyOpacity \
                -composite                        \
                -define dds:compression=dxt5      \
                -define dds:mipmaps=all              \
                -define dds:mipmap-filter=linear              \
                -depth 8                            \
                -alpha on \
                -background transparent \
                $2
    fi
}
