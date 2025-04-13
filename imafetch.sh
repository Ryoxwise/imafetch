#!/bin/bash

function ctrl_c(){
	echo -e "\n\n[!] Program has been terminated by the user\n"
	exit 2
}

trap ctrl_c INT

# Help panel
function help(){
  echo -e "\n[+] Image Fetcher - Syntax"
  echo -e "\nParameter\tDescription"  
  echo -e "---------\t-----------"
  echo -e "    i\t\tSearch for image file extensions"
  echo -e "    v\t\tSearch for video file extensions"
  echo -e "    a\t\tSearch for audio file extensions"
  echo -e "    f\t\tSearch for document file extensions"
  echo -e "    d\t\tSpecify a search directory. Default set to \$(pwd)"
  echo -e "    s\t\tRelocate files based on format: Vertical/Horizontal"
  echo -e "    m\t\tRelocate files based on date"
  echo -e "    n\t\tDo not perform partial renaming to files"
}

function checkPath(){
  local dir="$1"
  local outDir 
  local override="$2"
  local -i iter=1
  
  #echo "ending directory: $dir"

  if [ $override = "true" ]; then
    outDir="$dir"
    while [ -d "$outDir" ]; do
      #echo "$outDir exists" 
      outDir="${dir}_${iter}"
      let iter++
    done
  elif [ ! -d "$dir" ]; then
    #echo "$outDir does not exist"
    outDir="$dir"
  fi
  
  mkdir $outDir
  echo $outDir 
}

# Global variable to store the found files' paths
#declare fetchResult

#         -- Main script function --
# 1. Obtains the files based on file extension
# 2. Relocates the files in a new folder
# 3. Files are sorted based on: origin_date/size_format[images only]

function fetch(){
  local targetD=$1
  local fSplit=$2
  local dSplit=$3
  local nRename=$4

  printf "\n[+] Fetching mode set to [Image]\n\ntarget: %s \nform split: %s \ndate split: %s \nno renaming: %s\n\n" $targetD $fSplit $dSplit $nRename

  echo -e "> Fetching [image] files from $targetD"

  # Get all the file paths using the command [find]
  find $targetD -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.bmp" -o -iname "*.tiff" -o -iname "*.webp" \) 2>/dev/null > .fetched.txt
  
  #echo "$fetchResult"
  echo -e "> Fetch complete - Proceed to data extraction\n"
  
  # Variable used for feedback only
  local -i fileIndex=1
  
  # Extract information from files: filename and size[for image only]
#  for i in $fetchResult; do
#    local filename="$(basename $i)"
#    local imageSize=$(identify -format "%wx%h" $i)
    # echo "[+] Image file found: $filename with size: $imageSize"
#    printf "\r[+] Extracting image data [%3d/$(echo $fetchResult | wc -w)] - Please wait..." "$((fileIndex))"
#    let fileIndex++
#  done
#  printf "\n" #Prevents "%" from displaying in zsh terminal
  
#  echo -e "\n> Data extraction completed - Proceed to file relocation\n"

  if [ $nRename = false ]; then
    echo -e "[+] Files will be partially renamed using format: <DATE> <Filename>.<ext>"
  fi

  if [ $fSplit = true ]; then
    echo -e "[+] Files will be relocated based on size format - Vertical/Horizontal"
  fi

  if [ $dSplit = true ]; then
    echo -e "[+] Files will be relocated based on date"
  fi

  fileIndex=1

  local endPath=$(checkPath "$(pwd)/relocated" true)

  for i in $(seq 1 $(cat .fetched.txt | wc -l)); do
    printf "\r[+] Relocating files [%3d/$(cat .fetched.txt | wc -l)] - Please wait..." "$((fileIndex))"

    local origin=$(cat .fetched.txt | head -n $i | tail -n 1)
    local startName=$(basename "$origin")
    local endName
    local imageSize=$(identify -format "%wx%h" "$origin")
    local imageDate=$(stat "$origin" | grep "Modify" | awk '{print $2}')
    local imageYear=$(echo $imageDate | tr '-' ' ' | awk '{print $1}')
    local imageMonth=$(echo $imageDate | tr '-' ' ' | awk '{print $2}')
   
    #Generate new filepath and move file

    let fileIndex++
  done
  printf "\n\n"

  echo -e "> Files relocated successfully at $endPath"
  echo -e "> Terminating program..."
}

#                     -- Main program variables --
# [These are used to run syntax checks and drive the output of the script]

runHelp=false
#TargetDirectory is by default set to user's current directory
targetDirectory="$(pwd)"
outputDirectory="$(pwd)"
FormSplit=false
DateSplit=false
NoRename=false
#Numerical variable used to check if a wrong parameter combination is used
declare -i syn=0

while getopts "d:smnh" arg; do
  case "$arg" in
    d)  targetDirectory=$OPTARG 
    ;;
    s)  FormSplit=true
    ;;
    m)  DateSplit=true
    ;;
    n)  NoRename=true
    ;;
    h)  runHelp=true
        let syn++
    ;;
    *)  echo "Syntax Error. Use \"-h\" for help"
        exit 2
    ;;
  esac
done

let syn++

# Currently, $syn must be equal to "1" run the script.
# If true, then the user has made a correct use of the syntax
# This prevents the help function to be called if the main script function is being used

if [ $syn -gt 1 ]; then
  echo "Syntax Error. Unexpected use of parameters. Use \"-h\" for help"
  exit 1
fi


if [ $runHelp = true ]; then
  help
  exit 0
# The other parameters will define the output of the script
else
  fetch $targetDirectory $FormSplit $DateSplit $NoRename
  exit 0
fi
