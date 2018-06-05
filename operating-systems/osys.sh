#!/usr/bin/env bash

echo "Operating SYStem CLI"

SCRIPT_DIR=${BASH_SOURCE%/*}
OSYS_WORKING_DIR="$HOME/.osys"
OSYS_OS_LIST="$OSYS_WORKING_DIR/os.list"
OSYS_TEMPLATE_DIR="$SCRIPT_DIR/src/templates/"

function init(){
  if [ ! -d "$OSYS_WORKING_DIR" ]; then
    echo "OSYS appears to be running for the first time..."

    mkdir "$OSYS_WORKING_DIR"
    touch "$OSYS_OS_LIST"
  fi
}

init

case "$1" in
    list)
        case "$2" in
          update)
              echo "Updating CentOS"
              CENTOS_VERSION="7.5.1804"
              CENTOS_MIRROR="http://sjc.edge.kernel.org/centos/$CENTOS_VERSION/isos/x86_64"
              HTML_ANCHORS_LIST="$(curl -sL $CENTOS_MIRROR | xmllint --html --xpath //a -)"
              DELIMITER="</a>"

              cp $OSYS_TEMPLATE_DIR/centos_template.json $OSYS_OS_LIST

              sed "s/CENTOS_VERSION/$CENTOS_VERSION/g" $OSYS_OS_LIST > $OSYS_OS_LIST.bak
              mv $OSYS_OS_LIST.bak $OSYS_OS_LIST

              s=$HTML_ANCHORS_LIST$DELIMITER
              while [[ $s ]]; do
                CURRENT_ANCHOR=$(echo "${s%%"$DELIMITER"*}" | cut -d'>' -f2)
                if $(echo $CURRENT_ANCHOR | grep -Eiq "^centos.*iso$|^sha.*txt$"); then

                  echo "Adding link"
                  FILETYPE=$(echo $CURRENT_ANCHOR | cut -d'-' -f4 | tr '[:upper:]' '[:lower:]')

                  if $(echo $FILETYPE | grep -Eiq "^[^sha]"); then
                    ISOTYPE_URL="${FILETYPE}_url"
                    sed "s@$ISOTYPE_URL@$CENTOS_MIRROR/$CURRENT_ANCHOR@g" $OSYS_OS_LIST > $OSYS_OS_LIST.bak
                    mv $OSYS_OS_LIST.bak $OSYS_OS_LIST
                  else
                    SHA_LIST="$(curl -sL $CENTOS_MIRROR/$FILETYPE)"
                    echo $SHA_LIST
                  fi


                fi
                s=${s#*"$DELIMITER"};
              done;
            ;;
          *)
              cat "$OSYS_OS_LIST"
              echo ""
              echo "To update this list run ./osys list update"
            ;;
        esac
      ;;
    --help|-h)
        echo "Operating SYStem Manager is a tool for the download and management of various Linux distros"
        echo ""
        echo "You may want to start with seeing which Linux Distros and versions OSYS is currently aware of."
      ;;
    *)
        echo "Usage Instructions:"
        echo " > ./osys.sh --help"
      ;;
esac

exit 0;
