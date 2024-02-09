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

#### Pipe data to paste:
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

#### Paste text or files with a form:
```
$> firefox http://localhost:8080/paste?token=FOOBAR
```
Fill in the form and click Paste!


#### Paste files from Android with Termux:<br>

Copy paster to ~/bin/ in Termux and create a symlink called termux-file-editor pointing to paster
```
ln -s paster termux-file-editor
```
Edit the script and change the pipe to
```
curl -s -H "Authorization: Token $TOKEN" -F "file=@\"${1}\";filename=\"$f\"" https://$HOST/paste | html2text | termux-share -a send
```
Install html2text with
```
pkg install html2text
```
This will add termux as a choice in the share dialog. When the paste is done a link will be returned and you can share och copy that as usual


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
