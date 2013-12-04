SiteJournal
===========

Progress of personal site project

- Clone the repository
- npm install
- bower install

Service specific api data pertaining to MVMAuthenticate script needs to go in a json file in the top level directory named 'services.json'

Requires certain environment variables to be available (either added via .profile or whatever means)
`export HOSTNAME=mariusmiliunas.com`
`export ABSOLUTE_URL=http://www.mariusmiliunas.com/`
`export ABSOLUTE_SSL_URL=https://www.mariusmiliunas.com/`

To get the express server running run `grunt express`

*if running on port 80/443* - until a non sudo solution is found, will need to run with `sude -E grunt express` to use the current enviornment variables
