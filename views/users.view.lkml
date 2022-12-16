view: users {
  sql_table_name: `thelook.users`
    ;;
  drill_fields: [id]

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: age {
    type: number
    sql: ${TABLE}.age ;;
  }

  dimension: age_group {
    type: tier
    tiers: [18, 25, 35, 45, 55, 65, 75, 90]
    sql: ${age} ;;
    style: integer
  }

  dimension: city {
    type: string
    sql: ${TABLE}.city ;;
  }

  dimension: country {
    type: string
    map_layer_name: countries
    sql: ${TABLE}.country ;;
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
    sql: ${TABLE}.created_at ;;
  }

  dimension: email {
    type: string
    sql: ${TABLE}.email ;;
    link: {
      label: "User Dashboard" # internal link to a dashboard
      url: "/dashboards/24?Email={{value}}" # email is a filter
    }
    html: <a href="/dashboards/24?Email={{ value}}">{{ value }}</a>;;
  }

  dimension: first_name {
    type: string
    sql: ${TABLE}.first_name ;;
  }

  dimension: gender {
    type: string
    sql: ${TABLE}.gender ;;
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}.last_name ;;
  }

  dimension: latitude {
    type: number
    sql: ${TABLE}.latitude ;;
  }

  dimension: longitude {
    type: number
    sql: ${TABLE}.longitude ;;
  }

  dimension: postal_code {
    type: string
    sql: ${TABLE}.postal_code ;;
  }

  dimension: full_name {
    type: string
    sql: ${first_name} || ' ' || ${last_name};;
  }

  dimension: state {
    type: string
    sql: ${TABLE}.state ;;
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

  dimension: street_address {
    type: string
    sql: ${TABLE}.street_address ;;
  }

  dimension: traffic_source {
    type: string
    sql: ${TABLE}.traffic_source ;;
  }

  dimension: is_email {
    type: yesno
    sql: ${traffic_source} = 'Email' ;;
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

  measure: count_id {
    type: count_distinct
    sql:${id} ;;
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

  # # ------- User-order specific ------
  measure: total_lifetime_orders {
    type: count_distinct
    sql: ${order_items.order_id} ;;
  }

  measure: total_lifetime_orders_bucket {
    sql: CASE
      WHEN ${total_lifetime_orders} < 1 THEN '0 Order'
      WHEN ${total_lifetime_orders} = 1 THEN '1 Order'
      WHEN ${total_lifetime_orders} = 2 THEN '2 Orders'
      WHEN ${total_lifetime_orders} <= 5 THEN '3-5 Orders'
      WHEN ${total_lifetime_orders} <= 9 THEN '6-9 Orders'
      ELSE '10+ Orders'
    END ;;
  }

  set: user_measures {
    fields: [
      total_lifetime_orders,
      total_lifetime_orders_bucket
    ]
  }

  # ----- Templated filters ------
  filter: incoming_traffic_source {
    type: string
    suggest_dimension: users.traffic_source
    suggest_explore: users
  }

  dimension: hidden_traffic_source_filter {
    hidden: no
    type: yesno
    sql: {% condition incoming_traffic_source %}
      ${traffic_source} {% endcondition %} ;;
  }

  measure: changeable_count_measure {
    type: count_distinct
    sql: ${id} ;;
    filters: [hidden_traffic_source_filter: "Yes"]
  }

}
