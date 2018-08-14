#!/bin/bash


TAGIA_SLACK_CONFIG='## Slack
# https://github.com/taigaio/taiga-contrib-slack
INSTALLED_APPS += ["taiga_contrib_slack"]'


TAIGA_CONFIG_FILE="/taiga/local.py"

SLACK_FOLDER="/usr/src/taiga-front-dist/dist/plugins/slack/"

download_taiga () {
  echo "Start to download slack plugin"
  if [ -d "$SLACK_FOLDER" ]; then
    echo "slack already downloaded"
    return
  fi
  pip install --no-cache-dir taiga-contrib-slack
  mkdir -p "$SLACK_FOLDER"
  SLACK_VERSION=$(pip show taiga-contrib-slack | awk '/^Version: /{print $2}')
    echo "taiga-contrib-slack version: $SLACK_VERSION" && \
    curl https://raw.githubusercontent.com/taigaio/taiga-contrib-slack/$SLACK_VERSION/front/dist/slack.js -o "$SLACK_FOLDER/slack.js" 
    curl https://raw.githubusercontent.com/taigaio/taiga-contrib-slack/$SLACK_VERSION/front/dist/slack.json -o "$SLACK_FOLDER/slack.json"
  echo "Successfully downloaded slack-contrib"
}


activate_slack () {
  echo "Activate slack plugin"
  if grep -Fxq "$TAGIA_SLACK_CONFIG" "$TAIGA_CONFIG_FILE"
  then
      # code if found
      echo "Slack already active"
  else
      # code if not found
      echo "Slack not yet active"
      echo "" >> "$TAIGA_CONFIG_FILE"
      echo "$TAGIA_SLACK_CONFIG" >> "$TAIGA_CONFIG_FILE"
      echo "Slack actived"
  fi

}


deactivate_slack () {
  echo "Dectivate slack plugin"
  if grep -Fxq "$TAGIA_SLACK_CONFIG" "$TAIGA_CONFIG_FILE"
  then
      # code if found
      echo "Slack is active"
      # for one reasion I cannot use the complete TAIGA_SLACK_CONFIG variable here
      PATTERNTOREMOVE="INSTALLED_APPS += [\"taiga_contrib_slack\"]"
      safe_pattern=$(printf '%s\n' "$PATTERNTOREMOVE" | sed 's/[]\[\.*^$(){}|/#"]/\\&/g' )
      # now we can safely do
      sed -i '/'"${safe_pattern}"'/d' "$TAIGA_CONFIG_FILE"
      echo $safe_pattern
      echo "Slack deactived"
  else
      # code if not found
      echo "Slack is not active"
  fi


}



# Setup database automatically if needed
if [ ! -z "$TAIGA_SLACK" ]; then
  echo "Configure slack-contrib plugin"
  
  if [ "$TAIGA_SLACK" = "ACTIVE" ]; then
    download_taiga
    activate_slack
  fi

  if [ "$TAIGA_SLACK" = "DEACTIVE" ]; then
    deactivate_slack
  fi

fi
