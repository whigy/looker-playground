explore: huijie_test {
  hidden: no
  from: huijie_test_dates
}

view: huijie_test_dates {
  derived_table: {
    # BQ
    sql: SELECT
      CAST(date AS TIMESTAMP) date,
      CAST(10*RAND() AS INT64) as count
      FROM UNNEST(GENERATE_DATE_ARRAY("2021-01-01", "2021-12-01", INTERVAL 4 DAY)) date
      WHERE DATE_TRUNC(date, MONTH) != "2021-04-01"
      group by 1
      order by 1
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension_group: date {
    type: time
    # allow_fill: no
    sql: ${TABLE}.date ;;
  }

  dimension: count_ {
    type: number
    sql: ${TABLE}.count ;;
  }

  set: detail {
    fields: [date_time, count_]
  }
}
