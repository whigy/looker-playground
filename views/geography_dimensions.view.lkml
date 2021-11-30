view: geography_dimensions {
  extension: required # this view is only an extension

  dimension: city {
    group_label: "geography"
    type: string
    sql: ${TABLE}."CITY" ;;
  }

  dimension: country {
    group_label: "geography"
    type: string
    map_layer_name: countries
    sql: ${TABLE}."COUNTRY" ;;
  }

  dimension: city_country {
    group_label: "geography"
    type: string
    sql: CONCAT(${city}, ', ', ${country});;
  }

  dimension: latitude {
    group_label: "geography"
    type: number
    sql: ${TABLE}."LATITUDE" ;;
  }

  dimension: longitude {
    group_label: "geography"
    type: number
    sql: ${TABLE}."LONGITUDE" ;;
  }

  dimension: location {
    type: location
    sql_latitude:${latitude} ;;
    sql_longitude:${longitude} ;;
  }

  dimension: zip {
    group_label: "geography"
    type: zipcode
    sql: ${TABLE}."ZIP" ;;
  }


}
