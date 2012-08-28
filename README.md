Find your better half on **github** with:

# CupidHub

Cupidhub is a matching service that helps you find developers with similar interests,
make new friends to collaborate on projects or simply have a beer.

* Engage with new intresting people around github matching your interests.
* Score your best matches and watch for ranking updates.
* Discover new exciting repositories from your matches.
* Fork new babies with your matches and make the world better.
* Your soulmate could be around the corner. Find matches near you and have a beer together <3
* You could even fall in love here. Seriously, you have been warned!

# Developer documentation
## Project resources

* Pivotal tracker
* github
* jenkins (redhat paas)

## Development deploy
```bash
bundle install
cp config/database.yml.template config/database.yml
...edit database config...
rails s
```


## Commit policies
* Prepend pivotal tracker story number to commit message.
```bash
~$ git commit -m "[10435617] Adding geospatial search for users"
```

## Unit tests
