This is a script I wrote to pull an RSS (or ATOM, maybe) feed from a blog and turn it into basic text files to use in a phlog. 

It requires `XML::Feed` and `LWP::Protocol::https` modules, and can be called with `-h` or `--help` for usage info. 

Required arguments: 
`-r` path to output directory, e.g.`-r /var/gopher/`
`-f` url to rss feed in double quotes, e.g. `-f "https://rss.example.feed"`


TODO:
* Remove text files for posts which have been deleted from the RSS stream.
* Update a file when the post's title has changed (currently creates a second file) 
