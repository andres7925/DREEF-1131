@echo off
git config --global user.name "andres7925"
git config --global user.email "andresfelipe.gomez@utp.edu.co"
git fetch
git add .
git commit -m "s"
git push
git config --global user.name "agomez"
git config --global user.email "agomez@inforcol.com"
pause