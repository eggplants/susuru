#!/bin/bash


# txt_link='https://git.io/JRhFi'
txt_link='./susuru_txt/yabai_SUSURU_TV_gayo.txt'

[ -f "$txt_link" ] || {
  echo "'$txt_link' is not found.">&2
  exit 1
}

# command textimg curl > /dev/null || {
command convert textimg > /dev/null || {
  echo "require: convert, textimg">&2
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
    if [ "$ABS" = 1 ]
    then
      mogrify -resize "$max_width"x! "$i"
    else
      mogrify -resize "$max_width" "$i"
    fi
  done

  convert -append $(ls -tr d_h_*.png) "D_h$([ "$ABS" = 1 ]&&echo abs).png"
  rm -f d_h_*.png

}

v(){
  c=0
  # curl -sL "$txt_link" | sed y/〜ーSUR/∫｜ＳＵＲ/ | while read -r i
  sed y/〜ーSUR/∫｜ＳＵＲ/ "$txt_link" | while read -r i
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
    if [ "$ABS" = 1 ]
    then
      mogrify -resize "$max_width"x"$mid_height"! "$i"
    else
      mogrify -resize "$max_width"x"$mid_height" "$i"
    fi
  done
  convert +append $(ls -t d_v_*.png) "D_v$([ "$ABS" = 1 ]&&echo abs).png"
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
  for i in D_?.png D_????.png
  do
    convert -resize 1280x720! "$i" "${i//\./.nico.}"
  done
}
main "$@"
exit "$?"
