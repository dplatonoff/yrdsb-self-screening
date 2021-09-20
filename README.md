# Daily YRDSB Screening Confirmation

This helper script is here to automate the daily YRDSB self-screening submission.

Recently, the [district school board of York Ontario](https://www.yrdsb.ca/) introduced a mandatory COVID self-screening confirmation. It requires parents to go to the YRDSB site every morning, login with their child's student credentials and confirm the child is fit to go to school.

It proved to be a ridiculous waste of time. Logging in with your kid's account to mindlessly click "Yes" every day is certainly not something a parent of a small child has the time to do early in the morning (especially if you have several kids). It does not contribute to public safety in any conceivable fashion and is evidently designed to satisfy a hastily made up legal requirement. You'd think we can trust parents to keep sick kids home without a questionnaire, they managed pretty well for the last few decades.

The supplied script offers to free up these few crucial minutes in the morning and hopefully help retain some sanity.

# Usage

Clone the script, add your kid's credentials.

```
# student ID and password
USERNAME=123456789
PASSWORD=password
```

Drop it into `/etc/cron.daily` or use a schedule like `0 7 * * 1-5` if you only want to run it on weekday mornings.

A handful of temporary files are created in the process, they contain session cookies and parsed HTML content. They're safe to clean up afterwards.
