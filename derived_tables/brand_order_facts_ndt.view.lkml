explore: brand_order_facts_ndt {}
view: brand_order_facts_ndt {
  derived_table: {
    # distribution: "order_id" # Persistant derived table: Redshift
    # sortkeys: ["order_id"] # Persistant derived table: Redshift
    # indexes: ["order_id"]
    # sql_trigger_value: SELECT CURDATE() ;;
    datagroup_trigger: order_items_datagroup # Doesn't work??
    # persist_for: "8 hours"

    explore_source: order_items {
      column: brand { field: products.brand }
      column: revenue {field: order_items.total_gross_revenue }
      derived_column: brand_rank {
        sql: row_number() over (order by revenue desc)
          ;;
      }

      filters: [order_items.created_date: "365 days"]
      # filters: [order_items.created_year: "2018"]

      # bind_filters: { # doesn't work? Can't find the field
      #   from_field: order_items.created_date
      #   to_field: order_items.created_date
      # }

      # This only works when you have joined the NDT (and not PDT) to its explore_source.
      # bind_all_filters: yes # doesn't work? Cannot use native derived table with "bind_all_filters" outside of its source explore "Order Items"
    }

  }

  dimension: brand {
    primary_key: yes
  }
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
