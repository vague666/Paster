# Pastebin service written with Mojolicious

Prerequisites:
```
perl 5.24+
Mojolicious
For scripts:
  Pandoc
  curl
  xmessage
  scrot
'Authorization: Token FOOBAR' header field for curl, where FOOBAR is the secret you defined in paster.conf
```

## Examples

Works like [sprunge](http://sprunge.us) with the addition of a form for pasting text or files

Pipe data to paste:
```
$> cat some.file | curl -H 'Authorization: Token FOOBAR' -F 'paste=<-' http://localhost:8080/paste
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
$> firefox http://localhost:8080/paste?token=FOOBAR
```
Fill in the form and click Paste!



## Installation

1. Create the www user
```
   $> sudo useradd -m -r -U -s /bin/false www
```
2. Copy or move Paster dir to www's home dir
```
   sudo cp -a Paster /home/www/
```
3. Modify paster.conf to fit your environment
```
   $> sudo nano -w /home/www/Paster/paster.conf
```
4. Change ownership of files
```
   $> sudo chown -R www:www /home/www/Paster
```
5. Start paster
```
   sudo hypnotoad /home/www/Paster/scripts/paster
```
