# Sunrise Trainings Map

This is work-in-progress code to create a new version of the Sunrise [trainings page](https://www.sunrisemovement.org/trainings).

## How it works

* Data about upcoming Sunrise trainings is stored/managed in Airtable (by Sunrise volunteers)
* Every 10 minutes, a Heroku app running this code queries Airtable for updated Sunrise trainings data (using an API key)
* The Heroku app generates a JSON summary of all upcoming trainings marked as `Verified?` and for which we can find a latitude/longitude (either manually entered or geocoded using Mapbox)
* The Heroku app uploads that JSON summary to a public Amazon S3 bucket
* The [training map code](./training_map.html) GETs the JSON summary and uses it to build a map of upcomining Sunrise trainings (in users' browsers)

## TODOs

* Finalize design
* Handle online-only trainings
* Hash out Sunrise volunteer workflow for curating/verifying trainings
