#! /bin/bash

CWD=$(pwd)

VERSION="0.9.0"
VENDOR="AIRcable"
APPNAME="AIRbot"
CAPTION="AIRbot"
SHORT_CAPTION="AIRbot"
LANG="EN"
DRIVE="E"
TARGET="AIRbot.sis"
SOURCE="cellphone"

rm -rf temp
mkdir temp
cp -r $SOURCE/* temp/
rm -rf temp/.svn

cd ~/.wine/drive_c/PythonForS60/
wine ~/.wine/drive_c/Python25/python.exe ensymble.py py2sis --appname="$APPNAME" --version="$VERSION" --lang="$LANG" --shortcaption="$SHORT_CAPTION" --caption="$CAPTION" --drive="$DRIVE" --vendor="$VENDOR" --verbose --ignore-missing-deps $CWD/temp $CWD/$TARGET
