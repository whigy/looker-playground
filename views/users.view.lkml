view: users {
  sql_table_name: "PUBLIC"."USERS"
    ;;
  drill_fields: [id]

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ID" ;;
  }

  dimension: age {
    type: number
    sql: ${TABLE}."AGE" ;;
  }

  dimension: age_group {
    type: tier
    tiers: [18, 25, 35, 45, 55, 65, 75, 90]
    sql: ${age} ;;
    style: integer
  }

  dimension: city {
    type: string
    sql: ${TABLE}."CITY" ;;
  }

  dimension: country {
    type: string
    map_layer_name: countries
    sql: ${TABLE}."COUNTRY" ;;
  }

  dimension: city_country {
    type: string
    sql: CONCAT(${city}, ‘, ‘, ${country});;
  }

  dimension_group: created {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."CREATED_AT" ;;
  }

  dimension: email {
    type: string
    sql: ${TABLE}."EMAIL" ;;
    link: {
      label: "User Dashboard" # internal link to a dashboard
      url: "/dashboards/24?Email={{value}}" # email is a filter
    }
    html: <a href="/dashboards/24?Email={{ value}}">{{ value }}</a>;;
  }

  dimension: first_name {
    type: string
    sql: ${TABLE}."FIRST_NAME" ;;
  }

  dimension: gender {
    type: string
    sql: ${TABLE}."GENDER" ;;
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}."LAST_NAME" ;;
  }

  dimension: latitude {
    type: number
    sql: ${TABLE}."LATITUDE" ;;
  }

  dimension: longitude {
    type: number
    sql: ${TABLE}."LONGITUDE" ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}."STATE" ;;
    link: {
      label: "Drill Down to See Customers"
      # if use filter: value --> _filters['users.state']
      url: "/explore/huijie_case_study_playground/users?fields=users.id,users.first_name,users.last_name,users.state&f[users.state]={{ value | url_encode}}"
      icon_url: "https://looker.com/favicon.ico"
    }
    html: {% if _explore._name == "order_items" %}
      <a href=
      "/explore/huijie_case_study_playground/order_items?fields=order_items.detail*&f[users.state]= {{ value }}">{{ value }}</a>
      {% else %}
      <a href=
      "/explore/huijie_case_study_playground/users?fields=users.id,users.first_name,users.last_name,users.state&f[users.state]={{ value }}">{{ value }}</a>
      {% endif %} ;;
  }

  dimension: traffic_source {
    type: string
    sql: ${TABLE}."TRAFFIC_SOURCE" ;;
  }

  dimension: is_email {
    type: yesno
    sql: ${traffic_source} = 'Email' ;;
  }

  dimension: zip {
    type: zipcode
    sql: ${TABLE}."ZIP" ;;
  }

  dimension: order_history_button {
    label: "History Button"
    sql: ${TABLE}.id ;;
    # Quoting a set doesn't work?
    html: <a
      href="/explore/huijie_case_study_playground/order_items?fields=order_items.detail*&f[users.id]={{ value }}"><button>Order History</button></a> ;;
  }

  measure: count {
    type: count
    drill_fields: [id, first_name, last_name, events.count, order_items.count]
  }

  measure: count_female_users {
    type: count
    filters: [gender: "Female"]
  }

  measure: percentage_female_users {
    type: number
    value_format_name: percent_1
    sql: 1.0*${count_female_users}
      /NULLIF(${count}, 0) ;;
  }

  # ----- Templated filters ------
  filter: incoming_traffic_source {
    type: string
    suggest_dimension: users.traffic_source
    suggest_explore: users
  }

  dimension: hidden_traffic_source_filter {
    hidden: yes
    type: yesno
    sql: {% condition incoming_traffic_source %}
      ${traffic_source} {% endcondition %} ;;
  }

  measure: changeable_count_measure {
    type: count_distinct
    sql: ${id} ;;
    filters: [ hidden_traffic_source_filter: "Yes"]
  }

}
