view: brand_order_facts_ndt {
  derived_table: {
    # distribution: "order_id" # Persistant derived table: Redshift
    # sortkeys: ["order_id"] # Persistant derived table: Redshift
    # indexes: ["order_id"]
    # datagroup_trigger: order_items # Doesn't work??
    persist_for: "8 hours"

    explore_source: order_items {
      column: brand { field: products.brand }
      column: revenue {field: order_items.total_gross_revenue }
      derived_column: brand_rank {
        sql: row_number() over (order by revenue desc)
          ;;
      }
      # bind_all_filters: yes

      filters: [order_items.created_date: "365 days"]

      # bind_filters: { # doesn't work? Can't find the field
      #   from_field: order_items.created_date
      #   to_field: order_items.created_date
      # }
      # bind_all_filters: yes # doesn't work? Cannot use native derived table with "bind_all_filters" outside of its source explore "Order Items"


    }
  }

  dimension: brand {}
  dimension: revenue {}
  dimension: brand_rank {}

  dimension: is_brand_rank_top_5 {
    type: yesno
    sql: ${brand_rank} <= 5 ;;
  }

  dimension: ranked_brands {
    type: string
    sql: case when ${is_brand_rank_top_5} then
            ${brand_rank}||') '||${brand}
            else 'Other' end;;
  }

  measure: total_revenue {
    type: sum
    sql: ${revenue} ;;
  }
}
