#!/bin/bash
PROCESSED_CHANGE=0
SCRIPTNAME=$(basename $0)
USERNAME="tomcat"
GROUPNAME="tomcat"

# Usage Funcation
function usage() {
  cat << USAGEDOC
Usage: $SCRIPTNAME [-u NewUserID] [-g NewGroupID]
This command will modify the user ID from its current value to a new
set of values for either GID or UID or both.  This command must be run
with root permission.

optional arguments:
  -u  Provide a new user ID for the tomcat ID
  -g  Provide a new group ID for the tomcat ID
  -h  Return this usage statement.

Without an argument this usage statement is returned.

Example:
  change_tomcat_id.sh -u 15001
  The Tomcat ID will change from its current UID to the UID 15001.  All files
  that were previously owned by the Tomcat ID will become Owned by this new ID.
USAGEDOC
}

#if [ $# -eq 0 ]
#then
#  usage
#  exit 0
#fi

while getopts ":u:g:h" tcOpt; do
  case $tcOpt in
    u)
      NEW_USERID=$OPTARG
      if ! [ "$NEW_USERID" -eq "$NEW_USERID" ]; then
        echo "Invalid User ID passed: $NEW_USERID, must be a number"
        exit 1
      fi
      ;;
    g)
      NEW_GROUPID=$OPTARG
      if ! [ "$NEW_GROUPID" -eq "$NEW_GROUPID" ] ; then
        echo "Invalid Group ID passed: $NEW_GROUPID, must be a number"
        exit 1
      fi
      ;;
    h)
      usage
      exit 0;
      ;;
    \?)
      echo "Invalid paramter option: $OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

if [ $NEW_USERID -ne 0 ]
then
  EXISTING_UID=`getent passwd $NEW_USERID`
  PREVIOUS_UID=`getent passwd $USERNAME | cut -d ':' -f 3`
  if [ $PREVIOUS_UID -eq $NEW_USERID ]
  then
    echo "Can't change ID match current ID"
    usage
    exit 1;
  fi
  if [[ ! -z $EXISTING_UID ]]; then
    OWNER_UID=`echo $EXISTING_UID | cut -d ':' -f 1`
    echo "That ID is already assigned to: $OWNER_UID"
    exit 1;
  fi
  echo "Changing $USERNAME ID from $PREVIOUS_UID to $NEW_USERID"
  usermod -u $NEW_USERID $USERNAME;
  CONFIRM_UID_CHANGE=`getent passwd $USERNAME | cut -d ':' -f 3`
  if [ $NEW_USERID -ne $CONFIRM_UID_CHANGE ]
  then
    echo "Error processing ID change request."
    exit 1;
  fi
  find / -user $PREVIOUS_UID -not -path /proc -exec chown -h $USERNAME {} \;

  echo "$USERNAME user ID modified from $PREVIOUS_UID to $NEW_USERID"
  PROCESSED_CHANGE=1
fi

if [ $NEW_GROUPID -ne 0 ]
then
  EXISTING_GID=`getent group $NEW_GROUPID`
  PREVIOUS_GID=`getent group $GROUPNAME | cut -d ':' -f 3`
  if [ $PREVIOUS_GID -eq $NEW_GROUPID ]
  then
    echo "Can't change group ID to match the current group ID."
    usage
    exit 1;
  fi
  if [[ ! -z $EXISTING_GID ]]; then
    OWNER_GID=`echo EXISTING_GID | cut -d ':' -f 1`
    echo "That GID is already assigned to the group: $OWNER_GID"
    exit 1;
  fi
  echo "Changing $GROUPNAME ID from $PREVIOUS_GID to $NEW_GROUPID"
  groupmod -g $NEW_GROUPID $GROUPNAME
  CONFIRM_GUID_CHANGE=`getent group $GROUPNAME | cut -d ':' -f 3`
  if [ $NEW_GROUPID -ne $CONFIRM_GUID_CHANGE ]
  then
    echo "Error processing GID change request"
    exit 1;
  fi
  find / -group $PREVIOUS_GID -not -path /proc -exec chgrp -h $GROUPNAME {} \;
  echo "$GROUPNAME group ID modified from $PREVIOUS_GID to $NEW_GROUPID"
  PROCESSED_CHANGE=1
fi


if [ $PROCESSED_CHANGE -eq 0 ]
then
  echo "No valid parameters passed to $SCRIPTNAME"
  usage
  exit 1
fi
