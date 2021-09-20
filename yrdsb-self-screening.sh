#!/bin/sh

# student ID and password
USERNAME=123456789
PASSWORD=password

# curl options: use -sS to stay silent unless there are errors, or -v for verbose
CURL_OPTIONS=-sS

# CSRF token parameter name for the login form
TOKEN_PARAM=__RequestVerificationToken

# read the homepage, save the cookies and extract the CSRF token
echo "Opening home page..."
TOKEN=`curl $CURL_OPTIONS \
    -c yrdsb_home.cookies \
    -s https://covidscreening.yrdsb.ca/ \
    | pup "input[name=\"$TOKEN_PARAM\"] attr{value}"`
echo "\tToken acquired."

# authenticate using the initial cookies and the CSRF token
echo "Logging in as $USERNAME..."
curl $CURL_OPTIONS \
    -d "UserName=$USERNAME&Password=$PASSWORD&$TOKEN_PARAM=$TOKEN" \
    -b yrdsb_home.cookies \
    -c yrdsb_login.cookies \
    -X POST https://covidscreening.yrdsb.ca/ \
    > /dev/null
echo "\tSuccess."

# fetch the questionnaire form
echo "Loading questionnaire..."
curl $CURL_OPTIONS \
    -b yrdsb_login.cookies \
    -c yrdsb_questionnaire.cookies \
    -o yrdsb_questionnaire.html \
    https://covidscreening.yrdsb.ca/Home/Questionnaire

# check if the confirmation has already been submitted
CONFIRMED=`cat yrdsb_questionnaire.html \
    | pup "h4:contains(\"COVID Screening Confirmation\") + div > div:last-child text{}"`

if [ "$CONFIRMED" = "Yes" ]
then
    echo "\tAlready confirmed today."
else
    echo -n "\tSuccess.\nAttempting to confirm...\n\t"
    # extract form parameters and package them as form-urlencoded values
    PARAMS=`cat yrdsb_questionnaire.html \
        | pup 'form[action="/Home/Questionnaire"] > input json{}' \
        | jq -r '.[] | [(.name | @uri), (.value | @uri)] | join("=")' \
        | tr '\n' '&'`"Answer=True"

    # submit the confirmation
    curl $CURL_OPTIONS \
        -d "$PARAMS" \
        -b yrdsb_questionnaire.cookies \
        -X POST https://covidscreening.yrdsb.ca/Home/Questionnaire \
        | pup 'h4:contains("COVID Screening Confirmation") + div > div:last-child text{}'
fi
