@echo off
echo Git Status:
git status
echo ----------------------------

echo Aenderungen uebernehmen...
git add .

set /p MESSAGE=Bitte Commit-Nachricht eingeben: 
git commit -m "%MESSAGE%"

echo Push zu GitHub...
git push

pause
