Archived. 
My personal usecase has changed, and I'm no longer using this script. 

This is a script I wrote to pull an RSS (or ATOM, maybe) feed from a blog and turn it into basic text files to use in a phlog. 

It requires `XML::Feed` and `LWP::Protocol::https` modules, and can be called with `-h` or `--help` for usage info. 

Required arguments: 
`-r` path to output directory, e.g.`-r /var/gopher/`
`-f` url to rss feed in double quotes, e.g. `-f "https://rss.example.feed"`

