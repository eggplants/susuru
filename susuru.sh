#!/bin/bash


# txt_link='https://git.io/JRhFi'
txt_link='./susuru_txt/yabai_SUSURU_TV_gayo.txt'

[ -f "$txt_link" ] || {
  echo "'$txt_link' is not found.">&2
  exit 1
}
command textimg curl > /dev/null || {
  echo "require: curl, textimg">&2
  exit 1
}

h(){
  c=0
  # curl -sL "$txt_link" | while read -r i
  cat "$txt_link" | while read -r i
  do
    [ -z "$i" ] && continue
    echo "$i" | textimg -o "d_h_$(printf %02d $c).png" -F"${1-100}"
    ((c++))
  done

  max_height="$(
    identify -format "%h\n" 'd_h_*.png' | sort -nr | head -1
  )"
  max_width="$(
    identify -format "%w\n" 'd_h_*.png' | sort -nr | head -1
  )"

  for i in d_h_*.png
  do
    mogrify -resize "$max_width"x! "$i"
  done

  convert -append $(ls -tr d_h_*.png) D_h.png
  rm -f d_h_*.png

}

v(){
  c=0
  # curl -sL "$txt_link" | sed y/〜ー/∫｜/ | while read -r i
  sed y/〜ー/∫｜/ "$txt_link" | while read -r i
  do
    [ -z "$i" ] && continue
    echo "$i" | grep -o . | textimg -o "d_v_$(printf %02d $c).png" -F"${1-100}"
    ((c++))
  done
  mid_height="$(
    identify -format "%h\n" 'd_v_*.png' | sort -n | sed '5!d'
  )"
  max_width="$(
    identify -format "%w\n" 'd_v_*.png' | sort -nr | head -1
  )"

  for i in d_v_*.png
  do
    mogrify -resize "$max_width"x"$mid_height"! "$i"
  done
  convert +append $(ls -t d_v_*.png) D_v.png
  rm -f d_v_*.png
}

main(){
  op="${1}"
  size="${2-100}"
  if [ -z "$op" ]
  then
    h "$size" && v "$size"
  elif [ "$op" = "h" ]
  then
    h "$size"
  elif [ "$op" = "v" ]
  then
    v "$size"
  fi
}
main "$@"
exit "$?"
