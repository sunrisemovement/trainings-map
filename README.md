# Sunrise Trainings Map

This code powers the map that appears on the Sunrise [trainings page](https://www.sunrisemovement.org/trainings).

## Overall information flow

* Data about upcoming Sunrise trainings is stored/managed in Airtable (by Sunrise volunteers)
* Every 10 minutes, a Heroku app running this code queries Airtable for updated Sunrise trainings data (using an API key)
* From this query, the Heroku app generates a JSON summary of all trainings that:
    - haven't yet started
    - are marked as `Verified?` in Airtable (by a Sunrise volunteer)
    - have a `Training Registration link`
    - have latitude/longitude (either manually entered or geocoded using Mapbox)
* The Heroku app uploads the resulting JSON summary to a public Amazon S3 bucket
* The [training map code](./training_map.html) GETs the JSON summary and uses it to build a map of upcomining Sunrise trainings (in users' browsers)

## Code in this repository

* [`training_map.html`](./training_map.html) contains the HTML/CSS/JS code used within the Squarespace custom code element to render the map
* [`airtable.rb`](./airtable.rb) contains the basic functionality necessary to generate trainings JSON
* [`upload_training_data.rb`](./upload_training_data.rb) is the actual script run every 10 minutes by the Heroku app
