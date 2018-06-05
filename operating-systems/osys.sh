#!/usr/bin/env bash

echo "Operating SYStem CLI"

OSYS_WORKING_DIR="$HOME/.osys"
OSYS_OS_LIST="$OSYS_WORKING_DIR/os.list"

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

              s=$HTML_ANCHORS_LIST$DELIMITER
              cat > $OSYS_OS_LIST << EOL
{
  centos: [{
    version: $CENTOS_VERSION,
    isos: [{
      minimal: {
        url: "URL", 
        sha1: "SHA1",
        sha256: "SHA256"
      }},{
      dvd: {
        url: "URL",
        sha1: "SHA1",
        sha256: "SHA256"
      }},{
      everything: {
        url: "URL",
        sha1: "SHA1",
        sha256: "SHA256"
      }},{
      net: {
        url: "URL",
        sha1: "SHA1",
        sha256: "SHA256"
      }},{
      live-kde: {
        url: "URL",
        sha1: "SHA1",
        sha256: "SHA256"
      }},{
      live-gnome: {
        url: "URL",
        sha1: "SHA1"
        sha56: "SHA256"
      }}]
  }]
}
EOL

              while [[ $s ]]; do
                CURRENT_ANCHOR=$(echo "${s%%"$DELIMITER"*}" | cut -d'>' -f2)
                if $(echo $CURRENT_ANCHOR | grep -Eiq "^centos.*iso$|^sha.*txt$"); then  
                  echo "Adding link"
                  echo "$CENTOS_MIRROR/$CURRENT_ANCHOR" >> $OSYS_OS_LIST
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
