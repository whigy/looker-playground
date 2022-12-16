view: products {
  sql_table_name: `thelook.products`
    ;;
  drill_fields: [id]

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: brand {
    type: string
    sql: ${TABLE}.brand ;;
    link: {
      label: "Google"
      url: "http://www.google.com/search?q={{ value | encode_uri}}"
      icon_url: "http://google.com/favicon.ico"
    }
  }

  dimension: category {
    type: string
    sql: ${TABLE}.category ;;
  }

  dimension: cost {
    type: number
    sql: ${TABLE}.cost ;;
  }

  dimension: department {
    type: string
    sql: ${TABLE}.department ;;
  }

  dimension: distribution_center_id {
    type: number
    # hidden: yes
    sql: ${TABLE}.distribution_center_id ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}.name ;;
  }

  dimension: retail_price {
    type: number
    sql: ${TABLE}.retail_price ;;
  }

  dimension: sku {
    type: string
    sql: ${TABLE}.sku ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      id,
      name,
      distribution_centers.name,
      distribution_centers.id,
      order_items.count,
      inventory_items.count
    ]


  # ----- Templated filters ------
  filter: choose_a_category_to_compare {
    type: string
    suggest_explore: inventory_items
    suggest_dimension: products.category
  }

  dimension: category_comparator {
    type: string
    sql:  CASE
          WHEN {% condition choose_a_category_to_compare %}
          ${category}
          {% endcondition %}
          THEN ${category}
          ELSE 'All Other Categories'
          END
    ;;
  }
}
