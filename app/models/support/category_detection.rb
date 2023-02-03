module Support
  class CategoryDetection
    include ActiveModel::Model
    attr_accessor :category_id, :tower, :category, :similarity, :matching_words

    STOP_WORDS = File.read(Rails.root.join("config/support/category_stop_words.txt")).freeze

    QUERY = <<-SQL.freeze
      WITH main AS (
        SELECT
          query,
          custom_stop_words,
          tsvector_to_array(to_tsvector(query)) as vparts
        FROM (SELECT $1 AS query, $2 AS custom_stop_words) AS main_data
      )
      , categories AS (
        SELECT cat.*
        FROM support_categories cat
        JOIN support_towers tow ON cat.support_tower_id = tow.id
        WHERE $4 IS false OR tow.title = 'Energy & Utilities'
      )
      , words AS (
        SELECT
          main.query,
          word,
          main.custom_stop_words ~ lower(word) as is_custom_stop_word,
          (
            tsvector_to_array(to_tsvector(word)) && main.vparts AND
            main.custom_stop_words !~ lower(word)
          ) as is_dict_word
        FROM
        (
          SELECT array_to_string(regexp_matches(lower(main.query), '([a-z]+)', 'gi'), '') AS word
          FROM main
        ) AS split_words, main
      )
      , category_hits AS (
        SELECT
          id,
          similarity(title, words.word) as similarity,
          words.word as matching_word,
          'ch' as result_source
        FROM categories
        JOIN words ON title ~* words.word AND NOT words.is_custom_stop_word
        WHERE NOT archived
      )
      , rfh_history AS (
        SELECT
          cat.id,
          similarity(request_text, words.query),
          words.word as matching_word,
          'rfhh' as result_source
        FROM support_cases sc
        JOIN words ON request_text ~* words.word AND words.is_dict_word
        INNER JOIN categories cat ON sc.category_id = cat.id AND NOT cat.archived
        INNER JOIN support_towers tower ON cat.support_tower_id = tower.id
        WHERE request_text IS NOT NULL
      )

      SELECT
        cat.id as category_id,
        tower.title as tower,
        cat.title as category,
        (
          coalesce(sum(similarity * 2)  FILTER (WHERE result_source = 'ch'), 0.0) +
          coalesce(avg(similarity)      FILTER (WHERE result_source = 'rfhh'), 0.0) +
          count(distinct matching_word)
        ) as similarity,
        array_to_string(array_remove(array_agg(distinct matching_word), ''), ',	') as matching_words
      FROM
      (
        SELECT * FROM category_hits UNION ALL
        SELECT * FROM rfh_history
      ) AS omnisearch
      JOIN support_categories cat ON cat.id = omnisearch.id
      INNER JOIN support_towers tower ON tower.id = cat.support_tower_id
      GROUP BY omnisearch.id, cat.id, cat.title, tower.title
      ORDER BY similarity DESC
      LIMIT $3
    SQL

    def self.results_for(request_text, is_energy_request: false, num_results: 1)
      query_binds = [request_text, STOP_WORDS, num_results, is_energy_request]
      ApplicationRecord.connection.exec_query(QUERY, "SQL", query_binds, prepare: true).rows.map do |row|
        new(category_id: row[0], tower: row[1], category: row[2], similarity: row[3], matching_words: row[4])
      end
    end
  end
end
