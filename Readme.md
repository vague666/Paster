## Pastebin service written with Mojolicious

Works like [sprunge](http://sprunge.us) with the addition of a form for pasting text or files

Pipe data to paste:
```
$> cat some.file | curl -F 'paste=<-' http://localhost:8080/paste
```
You can also use the shell script to paste content
```
$> cat some.file | paster
```
or to upload a file
```
$> paster path/to/some.file
```

Paste text or files:
```
$> firefox http://localhost:8080/paste
```
Fill in the form and click Paste!
