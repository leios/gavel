Some quick notes on these scripts:

### Python playlist_create.py
1. The python `playlist_create.py` code requires google api verification via an OAuth client. This means you need to create the project with google api, enable the youtube v3 API, and then create the OAuth Credential.
2. If you get an error with the python script, check the video ID first! It could have been privated (precondition check failed), or removed (video not found)
3. There is a limit to 200 videos per day (I think) for the python script. The reason we don't do it as a single batch is that this limit still applies even if it is in a batch

### Julia simple_sort.jl
1. This script does everything needed to get the entries in a format supported by Gavel
2. Note that the entries are "chunked" into batches of 50 because otherwise gmail will not be able to process the e-mails and a few people will be missed
3. The feedback e-mail script relies on the UNIX utility `sendmail`, which can be set up via the link provided in the script: https://wiki.archlinux.org/title/msmtp

