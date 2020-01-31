# just a collection of useful functions
SETTINGS_FILE=~/.VinoInitDefaults

function getVinoName
{
  #see if vino name was passed as param
  VINONAME=$1
  if [ -z "$VINONAME" ]; then
    # no parameter so ask the user for vino name
    if [ -f  $SETTINGS_FILE ];then
        .  $SETTINGS_FILE
    fi

    VINONAME_DEFAULT=vino

    VINONAME_LAST="${VINONAME_LAST:-$VINONAME_DEFAULT}"

    read -p "Vino Name [$VINONAME_LAST]: " VINONAME

    VINONAME="${VINONAME:-$VINONAME_LAST}"
  fi
}

function getContainerIDFromImageName
{
  PREFIX=$1
  #echo looking for $PREFIX

  docker container ls --format "{{.ID}} {{.Image}}" | while read -r ID NAME; do
  if  [[ $NAME == ${PREFIX}* ]] ;
    then
        echo "$ID"
        #printf "found image %s with ID: %s\n" "$NAME" "$ID"
        break
    #else
        #echo 'No Match'
    fi
  done
}

function getContainerIDFromContainerName
{
  PREFIX=$1
  #echo looking for $PREFIX

  docker container ls --format "{{.ID}} {{.Names}}" | while read -r ID NAME; do
  if  [[ $NAME == ${PREFIX}* ]] ;
    then
        echo "$ID"
        #printf "found image %s with ID: %s\n" "$NAME" "$ID"
        break
    #else
        #echo 'No Match'
    fi
  done
}
