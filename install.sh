#!/bin/zsh

cd "$(dirname "$0")"

xcodebuild

fr="build/Deployment/SIMBL.osax"

#install_name_tool -change  ...

D="/System/Library/ScriptingAdditions/"
echo "copying .."
sudo rm -rf "$D/SIMBL.osax"
sudo cp -a ${fr} $D

# reinstall SIMBL Agent
launchctl remove net.culater.SIMBL.Agent
open "$D/SIMBL.osax/Contents/Resources/SIMBL Agent.app"
