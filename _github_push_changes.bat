cd /d "D:\DEVELOPMENT\Delphi\Projekte\Firma\ESD Zeiterfassung 1.0.0.5"
del _git_output.txt >nul 2>&1
del push_error.txt >nul 2>&1
git remote remove origin 2>nul
git remote add origin https://github.com/es3006/Zeiterfassung-1.0.0.5.git
git branch -M main
git add . > nul
git status >> "D:\DEVELOPMENT\Delphi\Projekte\Firma\ESD Zeiterfassung 1.0.0.5\_git_output.txt"
git commit -m "v1.0.0.5: README angepasst" --allow-empty >> "D:\DEVELOPMENT\Delphi\Projekte\Firma\ESD Zeiterfassung 1.0.0.5\_git_output.txt"
git push -u origin main >> "D:\DEVELOPMENT\Delphi\Projekte\Firma\ESD Zeiterfassung 1.0.0.5\_git_output.txt"