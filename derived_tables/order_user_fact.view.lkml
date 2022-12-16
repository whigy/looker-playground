view: order_user_fact {

  derived_table: {
    explore_source: order_items {
      column: order_id {}
      column: user_id {}
      column: created_raw {}
      derived_column: user_order_sequence {
        sql: row_number() over (PARTITION BY user_id order by created_raw asc)
          ;;
      }
      derived_column: last_order {
        sql: LEAD(order_id) OVER (PARTITION BY user_id order by created_raw asc)
          ;;
      }

    }
  }
  dimension: order_id {
    type: number
  }
  dimension: user_id {
    type: number
  }
  dimension_group: created_raw {
    view_label: "created"
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
  }

  dimension: user_order_sequence {
    type: number
  }

  dimension: last_order {
    type: number
  }

  dimension: is_first_purchase {
    type: yesno
    sql: user_order_sequence=1 ;;
  }
}
